//! The selection: a coverage mask over the canvas and whether anything
//! is selected. Without a selection tools, adjustments and effects act
//! on the whole layer; Copy, Cut, Erase, Fill and Invert do nothing.

use std::sync::atomic::{AtomicU64, Ordering};

use crate::geom::{PointF, Rect};
use crate::mask::{CombineMode, Mask};
use crate::raster;

/// A pixel counts as selected for the outline from half coverage on.
const OUTLINE_INSIDE: u8 = 128;

/// An edge between pixels in image coordinates, `(x0, y0, x1, y1)` with
/// either `x0 == x1` or `y0 == y1`.
pub type Segment = (i32, i32, i32, i32);

fn next_stamp() -> u64 {
    static STAMPS: AtomicU64 = AtomicU64::new(1);
    STAMPS.fetch_add(1, Ordering::Relaxed)
}

#[derive(Debug, Clone)]
pub struct Selection {
    mask: Mask,
    active: bool,
    /// The non-zero bounds of `mask`, kept so edits and strokes do not
    /// rescan the canvas.
    bounds: Rect,
    /// New on every change, kept by clones: shells cache what they
    /// draw from a selection by it instead of comparing masks.
    stamp: u64,
}

impl PartialEq for Selection {
    fn eq(&self, other: &Self) -> bool {
        self.stamp == other.stamp
            || (self.active == other.active
                && self.bounds == other.bounds
                && self.mask == other.mask)
    }
}

impl Eq for Selection {}

impl Selection {
    fn make(mask: Mask, active: bool) -> Self {
        let bounds = mask.bounds();
        Self {
            mask,
            active,
            bounds,
            stamp: next_stamp(),
        }
    }

    pub(crate) fn none(canvas: Rect) -> Self {
        Self {
            mask: Mask::new(canvas),
            active: false,
            bounds: Rect::default(),
            stamp: next_stamp(),
        }
    }

    pub(crate) fn all(canvas: Rect) -> Self {
        Self {
            mask: Mask::full(canvas),
            active: true,
            bounds: canvas,
            stamp: next_stamp(),
        }
    }

    pub(crate) fn from_mask(mask: Mask) -> Self {
        Self::make(mask, true)
    }

    /// Whether something is selected (even if it covers no pixel).
    pub fn is_active(&self) -> bool {
        self.active
    }

    pub fn mask(&self) -> &Mask {
        &self.mask
    }

    /// How much a pixel takes part in an edit: its coverage, or 255
    /// everywhere when nothing is selected.
    #[inline]
    pub fn coverage(&self, x: i32, y: i32) -> u8 {
        if self.active {
            self.mask.get(x, y)
        } else if self.mask.rect().contains(x, y) {
            255
        } else {
            0
        }
    }

    /// The rectangle an edit can touch: the selected pixels' bounds, or
    /// the canvas when nothing is selected.
    pub fn bounds(&self) -> Rect {
        if self.active {
            self.bounds
        } else {
            self.mask.rect()
        }
    }

    /// Changes whenever the selection does (two selections with one
    /// stamp are equal; equal ones may still differ in stamp).
    pub fn stamp(&self) -> u64 {
        self.stamp
    }

    /// "Marching ants": the outline of the selected area as edges
    /// between pixels, horizontal runs where a row differs from the one
    /// above and vertical runs where a column differs from the one to
    /// its left. Empty when nothing is selected.
    pub fn outline(&self) -> Vec<Segment> {
        let mut segments = Vec::new();
        let b = self.bounds;
        if !self.active || b.is_empty() {
            return segments;
        }
        let inside = |x: i32, y: i32| self.mask.get(x, y) >= OUTLINE_INSIDE;
        let width = (b.width + 1) as usize;
        let mut run_start = vec![-1i32; width];
        for y in b.y..=b.bottom() {
            // Horizontal edges above row y.
            let mut start: Option<i32> = None;
            for x in b.x..=b.right() {
                let edge = x < b.right() && inside(x, y) != inside(x, y - 1);
                match (edge, start) {
                    (true, None) => start = Some(x),
                    (false, Some(s)) => {
                        segments.push((s, y, x, y));
                        start = None;
                    }
                    _ => {}
                }
            }
            // Vertical edges left of each column in row y.
            for (i, x) in (b.x..=b.right()).enumerate() {
                let edge = y < b.bottom() && inside(x, y) != inside(x - 1, y);
                let open = run_start[i];
                if edge && open < 0 {
                    run_start[i] = y;
                } else if !edge && open >= 0 {
                    segments.push((x, open, x, y));
                    run_start[i] = -1;
                }
            }
        }
        segments
    }

    pub(crate) fn combine(&mut self, shape: &Mask, mode: CombineMode) {
        if !self.active {
            self.mask = Mask::new(self.mask.rect());
        }
        self.mask.combine(shape, mode);
        self.active = true;
        self.bounds = self.mask.bounds();
        self.stamp = next_stamp();
    }

    pub(crate) fn invert(&mut self) {
        self.mask.invert();
        self.bounds = self.mask.bounds();
        self.stamp = next_stamp();
    }

    pub(crate) fn translated(&self, dx: i32, dy: i32) -> Selection {
        let mask = self.mask.translated(dx, dy);
        let bounds = self.bounds.translate(dx, dy).intersect(mask.rect());
        Selection {
            mask,
            active: self.active,
            bounds,
            stamp: next_stamp(),
        }
    }

    /// The selection stored for history: the mask cropped to its bounds,
    /// so a small selection on a 4k canvas costs little.
    pub(crate) fn snapshot(&self) -> SelectionSnapshot {
        let mut cropped = Mask::new(self.bounds);
        cropped.copy_from(&self.mask);
        SelectionSnapshot {
            canvas: self.mask.rect(),
            mask: cropped,
            active: self.active,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub(crate) struct SelectionSnapshot {
    canvas: Rect,
    mask: Mask,
    active: bool,
}

impl SelectionSnapshot {
    pub(crate) fn restore(&self) -> Selection {
        let mut mask = Mask::new(self.canvas);
        mask.copy_from(&self.mask);
        Selection::make(mask, self.active)
    }

    pub(crate) fn bytes(&self) -> usize {
        self.mask.data().len()
    }
}

/// The hard-edged masks of the selection tools.
pub(crate) fn rectangle_mask(canvas: Rect, a: PointF, b: PointF) -> Mask {
    raster::fill_polygon(&[raster::rectangle_path(a, b)], canvas, false)
}

pub(crate) fn ellipse_mask(canvas: Rect, a: PointF, b: PointF) -> Mask {
    raster::fill_polygon(&[raster::ellipse_path(a, b)], canvas, false)
}

pub(crate) fn lasso_mask(canvas: Rect, points: &[PointF]) -> Mask {
    raster::fill_polygon_even_odd(&[points.to_vec()], canvas, false)
}

#[cfg(test)]
mod tests {
    use crate::color::Rgba8;
    use crate::document::Document;
    use crate::geom::PointF;
    use crate::mask::CombineMode;

    #[test]
    fn a_rectangle_has_four_edges() {
        let mut doc = Document::new(20, 20, Rgba8::WHITE).unwrap();
        doc.select_rectangle(
            PointF::new(2.0, 3.0),
            PointF::new(7.0, 9.0),
            CombineMode::Replace,
        )
        .unwrap();
        let mut s = doc.selection().outline();
        s.sort();
        assert_eq!(
            s,
            vec![(2, 3, 2, 9), (2, 3, 7, 3), (2, 9, 7, 9), (7, 3, 7, 9)]
        );
    }

    #[test]
    fn a_selection_touching_the_canvas_edge_is_closed() {
        let mut doc = Document::new(8, 8, Rgba8::WHITE).unwrap();
        doc.select_all().unwrap();
        assert_eq!(doc.selection().outline().len(), 4);
    }

    #[test]
    fn a_hole_has_its_own_edges() {
        let mut doc = Document::new(10, 10, Rgba8::WHITE).unwrap();
        doc.select_all().unwrap();
        doc.select_rectangle(
            PointF::new(3.0, 3.0),
            PointF::new(5.0, 5.0),
            CombineMode::Exclude,
        )
        .unwrap();
        assert_eq!(doc.selection().outline().len(), 8);
    }

    #[test]
    fn the_stamp_changes_with_the_selection() {
        let mut doc = Document::new(10, 10, Rgba8::WHITE).unwrap();
        let before = doc.selection().stamp();
        let copy = doc.selection().clone();
        assert_eq!(copy.stamp(), before);
        doc.select_all().unwrap();
        assert_ne!(doc.selection().stamp(), before);
        doc.undo().unwrap();
        assert_eq!(doc.selection(), &copy);
    }
}
