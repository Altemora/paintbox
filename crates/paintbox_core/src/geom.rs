//! Integer rectangles for regions and float points for pointer input.

use serde::{Deserialize, Serialize};

/// A rectangle of pixels: `x..x + width`, `y..y + height`. Empty when
/// either side is zero.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Hash, Serialize, Deserialize)]
pub struct Rect {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
}

impl Rect {
    pub const fn new(x: i32, y: i32, width: u32, height: u32) -> Self {
        Self {
            x,
            y,
            width,
            height,
        }
    }

    /// The rectangle with corners `(x0, y0)` inclusive and `(x1, y1)`
    /// exclusive; inverted corners give an empty rectangle.
    pub fn from_edges(x0: i32, y0: i32, x1: i32, y1: i32) -> Self {
        Self {
            x: x0,
            y: y0,
            width: (x1 as i64 - x0 as i64).clamp(0, u32::MAX as i64) as u32,
            height: (y1 as i64 - y0 as i64).clamp(0, u32::MAX as i64) as u32,
        }
    }

    pub fn of_size(width: u32, height: u32) -> Self {
        Self::new(0, 0, width, height)
    }

    pub fn is_empty(&self) -> bool {
        self.width == 0 || self.height == 0
    }

    pub fn right(&self) -> i32 {
        clamp_i32(self.x as i64 + self.width as i64)
    }

    pub fn bottom(&self) -> i32 {
        clamp_i32(self.y as i64 + self.height as i64)
    }

    pub fn area(&self) -> u64 {
        self.width as u64 * self.height as u64
    }

    pub fn contains(&self, x: i32, y: i32) -> bool {
        x >= self.x && y >= self.y && x < self.right() && y < self.bottom()
    }

    /// The overlap; `Rect::default()` (0 × 0 at the origin) when there is
    /// none, so loops over an empty result never index anything.
    pub fn intersect(&self, other: Rect) -> Rect {
        let r = Rect::from_edges(
            self.x.max(other.x),
            self.y.max(other.y),
            self.right().min(other.right()),
            self.bottom().min(other.bottom()),
        );
        if r.is_empty() {
            Rect::default()
        } else {
            r
        }
    }

    /// The smallest rectangle holding both; an empty side is ignored.
    pub fn union(&self, other: Rect) -> Rect {
        if self.is_empty() {
            return other;
        }
        if other.is_empty() {
            return *self;
        }
        Rect::from_edges(
            self.x.min(other.x),
            self.y.min(other.y),
            self.right().max(other.right()),
            self.bottom().max(other.bottom()),
        )
    }

    pub fn inflate(&self, by: i32) -> Rect {
        Rect::from_edges(
            self.x.saturating_sub(by),
            self.y.saturating_sub(by),
            self.right().saturating_add(by),
            self.bottom().saturating_add(by),
        )
    }

    pub fn translate(&self, dx: i32, dy: i32) -> Rect {
        Rect::new(
            self.x.saturating_add(dx),
            self.y.saturating_add(dy),
            self.width,
            self.height,
        )
    }

    /// The pixel rectangle covering every pixel a float box touches.
    pub fn covering(x0: f32, y0: f32, x1: f32, y1: f32) -> Rect {
        let (x0, y0, x1, y1) = (sane(x0), sane(y0), sane(x1), sane(y1));
        Rect::from_edges(
            x0.min(x1).floor() as i32,
            y0.min(y1).floor() as i32,
            x0.max(x1).ceil() as i32 + 1,
            y0.max(y1).ceil() as i32 + 1,
        )
    }
}

/// How far from the canvas a coordinate may go. Pointer input can be
/// anything (a drag far off the window, infinity, NaN); clamping keeps
/// every sum inside `i32` and every loop bounded.
pub const COORD_LIMIT: f32 = 1.0e6;

#[inline]
fn clamp_i32(value: i64) -> i32 {
    value.clamp(i32::MIN as i64, i32::MAX as i64) as i32
}

/// A coordinate made finite and brought within [`COORD_LIMIT`].
#[inline]
pub(crate) fn sane(v: f32) -> f32 {
    if v.is_nan() {
        0.0
    } else {
        v.clamp(-COORD_LIMIT, COORD_LIMIT)
    }
}

/// An integer offset (a drag, a paste position) within the same limit.
#[inline]
pub(crate) fn sane_offset(v: i32) -> i32 {
    v.clamp(-(COORD_LIMIT as i32), COORD_LIMIT as i32)
}

/// A position in image pixels; `(0.5, 0.5)` is the centre of the first
/// pixel. Pointer input arrives in this space.
#[derive(Debug, Clone, Copy, PartialEq, Default, Serialize, Deserialize)]
pub struct PointF {
    pub x: f32,
    pub y: f32,
}

impl PointF {
    pub const fn new(x: f32, y: f32) -> Self {
        Self { x, y }
    }

    /// Finite and within [`COORD_LIMIT`]; every tool sees points so.
    pub fn sanitized(self) -> PointF {
        PointF::new(sane(self.x), sane(self.y))
    }

    pub fn distance(&self, other: PointF) -> f32 {
        ((self.x - other.x).powi(2) + (self.y - other.y).powi(2)).sqrt()
    }

    pub fn lerp(&self, other: PointF, t: f32) -> PointF {
        PointF::new(
            self.x + (other.x - self.x) * t,
            self.y + (other.y - self.y) * t,
        )
    }

    /// The pixel this point falls in.
    pub fn pixel(&self) -> (i32, i32) {
        (self.x.floor() as i32, self.y.floor() as i32)
    }
}

/// Snaps `to` around `from` to the nearest 15° direction, keeping the
/// length: Shift on lines, gradients and rotation.
pub fn constrain_angle(from: PointF, to: PointF) -> PointF {
    let dx = to.x - from.x;
    let dy = to.y - from.y;
    let length = (dx * dx + dy * dy).sqrt();
    if length == 0.0 {
        return to;
    }
    let step = std::f32::consts::PI / 12.0;
    let angle = (dy.atan2(dx) / step).round() * step;
    PointF::new(from.x + length * angle.cos(), from.y + length * angle.sin())
}

/// The box from `a` to `b`, made square on its shorter side when
/// `square` (Shift on rectangles and ellipses).
pub fn drag_box(a: PointF, b: PointF, square: bool) -> (PointF, PointF) {
    if !square {
        return (a, b);
    }
    let side = (b.x - a.x).abs().min((b.y - a.y).abs());
    let sx = if b.x < a.x { -side } else { side };
    let sy = if b.y < a.y { -side } else { side };
    (a, PointF::new(a.x + sx, a.y + sy))
}
