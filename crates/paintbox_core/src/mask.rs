//! Coverage masks: 0 – 255 per pixel over a rectangle. The selection
//! is a mask over the canvas; a brush stroke and a rasterised shape are
//! masks over their bounds.

use serde::{Deserialize, Serialize};

use crate::color::mul255;
use crate::geom::Rect;

/// How a new selection joins the existing one (Paint.NET's
/// `CombineMode`).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default, Serialize, Deserialize)]
pub enum CombineMode {
    #[default]
    Replace,
    Union,
    Exclude,
    Xor,
    Intersect,
}

impl CombineMode {
    /// The order the toolbar button cycles through.
    pub const CYCLE: [CombineMode; 5] = [
        CombineMode::Replace,
        CombineMode::Union,
        CombineMode::Exclude,
        CombineMode::Intersect,
        CombineMode::Xor,
    ];

    /// The mode a selection gesture uses: Ctrl or Alt with the left or
    /// right button override the toolbar's mode, as `SelectionTool`.
    pub fn for_gesture(
        toolbar: CombineMode,
        button: crate::Button,
        ctrl: bool,
        alt: bool,
    ) -> CombineMode {
        match (button, ctrl, alt) {
            (crate::Button::Primary, true, _) => CombineMode::Union,
            (crate::Button::Primary, false, true) => CombineMode::Exclude,
            (crate::Button::Secondary, true, _) => CombineMode::Xor,
            (crate::Button::Secondary, false, true) => CombineMode::Intersect,
            _ => toolbar,
        }
    }

    #[inline]
    pub fn apply(self, existing: u8, new: u8) -> u8 {
        match self {
            CombineMode::Replace => new,
            CombineMode::Union => existing.max(new),
            CombineMode::Exclude => mul255(existing as u32, 255 - new as u32) as u8,
            CombineMode::Xor => existing.abs_diff(new),
            CombineMode::Intersect => existing.min(new),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Mask {
    rect: Rect,
    data: Vec<u8>,
}

impl Mask {
    pub fn new(rect: Rect) -> Self {
        Self {
            rect,
            data: vec![0; rect.area() as usize],
        }
    }

    pub fn full(rect: Rect) -> Self {
        Self {
            rect,
            data: vec![255; rect.area() as usize],
        }
    }

    pub(crate) fn from_data(rect: Rect, data: Vec<u8>) -> Self {
        debug_assert_eq!(data.len(), rect.area() as usize);
        Self { rect, data }
    }

    pub fn rect(&self) -> Rect {
        self.rect
    }

    pub fn data(&self) -> &[u8] {
        &self.data
    }

    #[inline]
    fn index(&self, x: i32, y: i32) -> usize {
        (y - self.rect.y) as usize * self.rect.width as usize + (x - self.rect.x) as usize
    }

    /// Coverage at a pixel; 0 outside the mask's rectangle.
    #[inline]
    pub fn get(&self, x: i32, y: i32) -> u8 {
        if self.rect.contains(x, y) {
            self.data[self.index(x, y)]
        } else {
            0
        }
    }

    #[inline]
    pub fn set(&mut self, x: i32, y: i32, value: u8) {
        if self.rect.contains(x, y) {
            let i = self.index(x, y);
            self.data[i] = value;
        }
    }

    /// Raises a pixel to `value` if it is lower (strokes accumulate the
    /// maximum so overlapping segments do not double up).
    #[inline]
    pub fn raise(&mut self, x: i32, y: i32, value: u8) {
        if self.rect.contains(x, y) {
            let i = self.index(x, y);
            if self.data[i] < value {
                self.data[i] = value;
            }
        }
    }

    pub fn is_blank(&self) -> bool {
        self.data.iter().all(|&v| v == 0)
    }

    /// The tight rectangle of non-zero coverage; empty if blank.
    pub fn bounds(&self) -> Rect {
        let w = self.rect.width as usize;
        let mut out = Rect::default();
        for (row_index, row) in self.data.chunks(w.max(1)).enumerate() {
            let Some(first) = row.iter().position(|&v| v != 0) else {
                continue;
            };
            let last = row.iter().rposition(|&v| v != 0).unwrap_or(first);
            let y = self.rect.y + row_index as i32;
            out = out.union(Rect::from_edges(
                self.rect.x + first as i32,
                y,
                self.rect.x + last as i32 + 1,
                y + 1,
            ));
        }
        out
    }

    /// Joins `other` into this mask; pixels outside `other` count as 0.
    pub fn combine(&mut self, other: &Mask, mode: CombineMode) {
        let rect = self.rect;
        for y in rect.y..rect.bottom() {
            for x in rect.x..rect.right() {
                let i = self.index(x, y);
                self.data[i] = mode.apply(self.data[i], other.get(x, y));
            }
        }
    }

    pub fn invert(&mut self) {
        for v in &mut self.data {
            *v = 255 - *v;
        }
    }

    /// The same coverage shifted by `(dx, dy)`, kept within this mask's
    /// rectangle (what falls off is lost).
    pub fn translated(&self, dx: i32, dy: i32) -> Mask {
        let mut out = Mask::new(self.rect);
        let mut shifted = self.clone();
        shifted.rect = self.rect.translate(dx, dy);
        out.copy_from(&shifted);
        out
    }

    /// Copies `other` row by row where the two rectangles overlap.
    pub(crate) fn copy_from(&mut self, other: &Mask) {
        let overlap = self.rect.intersect(other.rect);
        if overlap.is_empty() {
            return;
        }
        let w = overlap.width as usize;
        for y in overlap.y..overlap.bottom() {
            let from = other.index(overlap.x, y);
            let to = self.index(overlap.x, y);
            self.data[to..to + w].copy_from_slice(&other.data[from..from + w]);
        }
    }

    /// Every value pushed to 0 or 255 at the half-way mark: a hard edge.
    pub fn harden(&mut self) {
        for v in &mut self.data {
            *v = if *v >= 128 { 255 } else { 0 };
        }
    }

    /// Multiplies this mask by `other` (clipping to a selection).
    pub fn multiply(&mut self, other: &Mask) {
        let rect = self.rect;
        for y in rect.y..rect.bottom() {
            for x in rect.x..rect.right() {
                let i = self.index(x, y);
                self.data[i] = mul255(self.data[i] as u32, other.get(x, y) as u32) as u8;
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::Button;

    #[test]
    fn combine_modes_follow_the_formulas() {
        assert_eq!(CombineMode::Replace.apply(200, 10), 10);
        assert_eq!(CombineMode::Union.apply(200, 10), 200);
        assert_eq!(CombineMode::Exclude.apply(255, 255), 0);
        assert_eq!(CombineMode::Exclude.apply(255, 0), 255);
        assert_eq!(CombineMode::Xor.apply(255, 255), 0);
        assert_eq!(CombineMode::Xor.apply(0, 255), 255);
        assert_eq!(CombineMode::Intersect.apply(200, 10), 10);
    }

    #[test]
    fn gesture_modifiers_override_the_toolbar() {
        let t = CombineMode::Replace;
        assert_eq!(
            CombineMode::for_gesture(t, Button::Primary, true, false),
            CombineMode::Union
        );
        assert_eq!(
            CombineMode::for_gesture(t, Button::Primary, false, true),
            CombineMode::Exclude
        );
        assert_eq!(
            CombineMode::for_gesture(t, Button::Secondary, true, false),
            CombineMode::Xor
        );
        assert_eq!(
            CombineMode::for_gesture(t, Button::Secondary, false, true),
            CombineMode::Intersect
        );
        assert_eq!(
            CombineMode::for_gesture(CombineMode::Xor, Button::Primary, false, false),
            CombineMode::Xor
        );
    }

    #[test]
    fn bounds_translate_and_combine() {
        let canvas = Rect::of_size(10, 10);
        let mut a = Mask::new(canvas);
        a.set(2, 3, 255);
        a.set(4, 5, 255);
        assert_eq!(a.bounds(), Rect::new(2, 3, 3, 3));
        let moved = a.translated(1, 1);
        assert_eq!(moved.get(3, 4), 255);
        assert_eq!(moved.get(2, 3), 0);
        let mut b = Mask::new(canvas);
        b.set(2, 3, 255);
        a.combine(&b, CombineMode::Exclude);
        assert_eq!(a.get(2, 3), 0);
        assert_eq!(a.get(4, 5), 255);
        a.invert();
        assert_eq!(a.get(4, 5), 0);
        assert_eq!(a.get(0, 0), 255);
    }
}
