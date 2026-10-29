//! Turning geometry into coverage: an anti-aliased polygon filler
//! (signed-area accumulation, non-zero winding), round brush capsules,
//! the 1-pixel pencil line, and the paths of shapes and curves.

use crate::geom::{PointF, Rect};
use crate::mask::Mask;

/// Fills closed contours into a mask over their bounds clipped to
/// `clip`. Contours wound against each other cut holes (a ring is an
/// outer contour and a reversed inner one). Without `antialias` the edge
/// is hard: a pixel is in when at least half of it is covered, which is
/// its centre for straight edges.
pub fn fill_polygon(contours: &[Vec<PointF>], clip: Rect, antialias: bool) -> Mask {
    fill_with_rule(contours, clip, antialias, false)
}

/// Like [`fill_polygon`] with the even-odd rule of GDI+ paths: a
/// self-crossing lasso leaves its doubly wound parts out, as in the
/// source.
pub fn fill_polygon_even_odd(contours: &[Vec<PointF>], clip: Rect, antialias: bool) -> Mask {
    fill_with_rule(contours, clip, antialias, true)
}

fn fill_with_rule(contours: &[Vec<PointF>], clip: Rect, antialias: bool, even_odd: bool) -> Mask {
    let sanitized: Vec<Vec<PointF>> = contours
        .iter()
        .map(|c| c.iter().map(|p| p.sanitized()).collect())
        .collect();
    let contours = &sanitized[..];
    let mut bounds = Rect::default();
    for contour in contours {
        for p in contour {
            bounds = bounds.union(Rect::covering(p.x, p.y, p.x, p.y));
        }
    }
    let rect = bounds.intersect(clip);
    if rect.is_empty() {
        return Mask::new(rect);
    }
    let w = rect.width as usize;
    let h = rect.height as usize;
    let stride = w + 2;
    let mut acc = vec![0f32; stride * h];
    for contour in contours {
        let n = contour.len();
        if n < 3 {
            continue;
        }
        for i in 0..n {
            let a = contour[i];
            let b = contour[(i + 1) % n];
            accumulate_line(
                &mut acc,
                stride,
                h,
                w as f32,
                PointF::new(a.x - rect.x as f32, a.y - rect.y as f32),
                PointF::new(b.x - rect.x as f32, b.y - rect.y as f32),
            );
        }
    }
    let mut data = Vec::with_capacity(w * h);
    for row in acc.chunks(stride) {
        let mut sum = 0f32;
        for &v in &row[..w] {
            sum += v;
            let coverage = if even_odd {
                let w = sum.abs() % 2.0;
                if w > 1.0 {
                    2.0 - w
                } else {
                    w
                }
            } else {
                sum.abs().min(1.0)
            };
            let value = if antialias {
                (coverage * 255.0 + 0.5) as u8
            } else if coverage >= 0.5 {
                255
            } else {
                0
            };
            data.push(value);
        }
    }
    Mask::from_data(rect, data)
}

/// Adds one edge's signed area to the accumulation buffer (the
/// font-rs scheme). X is clamped into `[0, width]`: an edge left of the
/// box still counts for every pixel right of it, one right of the box
/// counts for none, so clamping keeps the winding exact inside.
fn accumulate_line(acc: &mut [f32], stride: usize, h: usize, width: f32, p0: PointF, p1: PointF) {
    if p0.y == p1.y {
        return;
    }
    let (dir, mut p0, mut p1) = if p0.y < p1.y {
        (1.0f32, p0, p1)
    } else {
        (-1.0f32, p1, p0)
    };
    let hf = h as f32;
    if p1.y <= 0.0 || p0.y >= hf {
        return;
    }
    let dxdy = (p1.x - p0.x) / (p1.y - p0.y);
    if p0.y < 0.0 {
        p0.x -= p0.y * dxdy;
        p0.y = 0.0;
    }
    if p1.y > hf {
        p1.x -= (p1.y - hf) * dxdy;
        p1.y = hf;
    }
    let mut x = p0.x;
    let y_start = p0.y as usize;
    let y_end = (p1.y.ceil() as usize).min(h);
    for y in y_start..y_end {
        let line = y * stride;
        let dy = ((y + 1) as f32).min(p1.y) - (y as f32).max(p0.y);
        let x_next = x + dxdy * dy;
        let d = dy * dir;
        let xa = x.clamp(0.0, width);
        let xb = x_next.clamp(0.0, width);
        let (x0, x1) = if xa < xb { (xa, xb) } else { (xb, xa) };
        let x0_floor = x0.floor();
        let x0i = x0_floor as usize;
        let x1_ceil = x1.ceil();
        let x1i = x1_ceil as usize;
        if x1i <= x0i + 1 {
            let xmf = 0.5 * (xa + xb) - x0_floor;
            acc[line + x0i] += d - d * xmf;
            acc[line + x0i + 1] += d * xmf;
        } else {
            let s = (x1 - x0).recip();
            let x0f = x0 - x0_floor;
            let a0 = 0.5 * s * (1.0 - x0f) * (1.0 - x0f);
            let x1f = x1 - x1_ceil + 1.0;
            let am = 0.5 * s * x1f * x1f;
            acc[line + x0i] += d * a0;
            if x1i == x0i + 2 {
                acc[line + x0i + 1] += d * (1.0 - a0 - am);
            } else {
                let a1 = s * (1.5 - x0f);
                acc[line + x0i + 1] += d * (a1 - a0);
                for xi in x0i + 2..x1i - 1 {
                    acc[line + xi] += d * s;
                }
                let a2 = a1 + (x1i - x0i - 3) as f32 * s;
                acc[line + x1i - 1] += d * (1.0 - a2 - am);
            }
            acc[line + x1i] += d * am;
        }
        x = x_next;
    }
}

/// The round brush: how a stroke of `width` covers pixels.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct BrushTip {
    pub width: f32,
    /// 1 — a hard rim; lower — coverage falls off from `hardness · r`
    /// to `r`.
    pub hardness: f32,
    pub antialias: bool,
}

impl BrushTip {
    fn coverage(&self, distance: f32) -> u8 {
        let r = (self.width * 0.5).max(0.5);
        if !self.antialias {
            return if distance <= r { 255 } else { 0 };
        }
        let rim = (r + 0.5 - distance).clamp(0.0, 1.0);
        let hardness = self.hardness.clamp(0.0, 1.0);
        let inner = r * hardness;
        let soft = if hardness >= 1.0 || distance <= inner {
            1.0
        } else {
            ((r - distance) / (r - inner)).clamp(0.0, 1.0)
        };
        (rim * soft * 255.0 + 0.5) as u8
    }

    /// Raises `mask` with the capsule from `a` to `b`. Returns the
    /// pixels touched.
    pub fn stamp_segment(&self, mask: &mut Mask, a: PointF, b: PointF) -> Rect {
        let (a, b) = (a.sanitized(), b.sanitized());
        let reach = self.width * 0.5 + 1.5;
        let rect = Rect::covering(a.x - reach, a.y - reach, b.x + reach, b.y + reach)
            .union(Rect::covering(
                b.x - reach,
                b.y - reach,
                a.x + reach,
                a.y + reach,
            ))
            .intersect(mask.rect());
        let (dx, dy) = (b.x - a.x, b.y - a.y);
        let length_sq = dx * dx + dy * dy;
        for y in rect.y..rect.bottom() {
            for x in rect.x..rect.right() {
                let p = PointF::new(x as f32 + 0.5, y as f32 + 0.5);
                let t = if length_sq == 0.0 {
                    0.0
                } else {
                    (((p.x - a.x) * dx + (p.y - a.y) * dy) / length_sq).clamp(0.0, 1.0)
                };
                let distance = p.distance(PointF::new(a.x + dx * t, a.y + dy * t));
                let value = self.coverage(distance);
                if value > 0 {
                    mask.raise(x, y, value);
                }
            }
        }
        rect
    }
}

/// The pencil: a 1-pixel Bresenham line between pixel cells, both ends
/// included. Returns the pixels touched.
pub fn pencil_line(mask: &mut Mask, a: (i32, i32), b: (i32, i32)) -> Rect {
    let bounds = mask.rect().inflate(1);
    let Some((a, b)) = clip_segment(a, b, bounds) else {
        return Rect::default();
    };
    let (mut x, mut y) = a;
    let dx = (b.0 - a.0).abs();
    let dy = -(b.1 - a.1).abs();
    let sx = if a.0 < b.0 { 1 } else { -1 };
    let sy = if a.1 < b.1 { 1 } else { -1 };
    let mut err = dx + dy;
    loop {
        mask.set(x, y, 255);
        if (x, y) == b {
            break;
        }
        let e2 = 2 * err;
        if e2 >= dy {
            err += dy;
            x += sx;
        }
        if e2 <= dx {
            err += dx;
            y += sy;
        }
    }
    Rect::from_edges(
        a.0.min(b.0),
        a.1.min(b.1),
        a.0.max(b.0) + 1,
        a.1.max(b.1) + 1,
    )
}

/// The part of the segment inside `bounds` (Liang–Barsky), so a pointer
/// far off the canvas does not walk millions of cells. Segments with
/// both ends inside are returned unchanged.
fn clip_segment(a: (i32, i32), b: (i32, i32), bounds: Rect) -> Option<((i32, i32), (i32, i32))> {
    let inside = |p: (i32, i32)| bounds.contains(p.0, p.1);
    if inside(a) && inside(b) {
        return Some((a, b));
    }
    let (x0, y0) = (a.0 as f64, a.1 as f64);
    let (dx, dy) = (b.0 as f64 - x0, b.1 as f64 - y0);
    let (mut t0, mut t1) = (0.0f64, 1.0f64);
    let edges = [
        (-dx, x0 - bounds.x as f64),
        (dx, (bounds.right() - 1) as f64 - x0),
        (-dy, y0 - bounds.y as f64),
        (dy, (bounds.bottom() - 1) as f64 - y0),
    ];
    for (p, q) in edges {
        if p == 0.0 {
            if q < 0.0 {
                return None;
            }
        } else {
            let t = q / p;
            if p < 0.0 {
                t0 = t0.max(t);
            } else {
                t1 = t1.min(t);
            }
        }
    }
    if t0 > t1 {
        return None;
    }
    let at = |t: f64| ((x0 + dx * t).round() as i32, (y0 + dy * t).round() as i32);
    Some((at(t0), at(t1)))
}

/// How many straight pieces approximate a curve spanning `extent`
/// pixels: enough that the chord error stays under a quarter pixel.
fn segments_for(extent: f32) -> usize {
    (extent.abs().sqrt() * 4.0).clamp(8.0, 512.0) as usize
}

/// The ellipse inscribed in the box, clockwise in screen space.
pub fn ellipse_path(a: PointF, b: PointF) -> Vec<PointF> {
    let cx = (a.x + b.x) * 0.5;
    let cy = (a.y + b.y) * 0.5;
    let rx = (b.x - a.x).abs() * 0.5;
    let ry = (b.y - a.y).abs() * 0.5;
    let n = segments_for(rx.max(ry) * 6.0);
    (0..n)
        .map(|i| {
            let t = i as f32 / n as f32 * std::f32::consts::TAU;
            PointF::new(cx + rx * t.cos(), cy + ry * t.sin())
        })
        .collect()
}

/// The rectangle of the box, clockwise.
pub fn rectangle_path(a: PointF, b: PointF) -> Vec<PointF> {
    let (x0, x1) = (a.x.min(b.x), a.x.max(b.x));
    let (y0, y1) = (a.y.min(b.y), a.y.max(b.y));
    vec![
        PointF::new(x0, y0),
        PointF::new(x1, y0),
        PointF::new(x1, y1),
        PointF::new(x0, y1),
    ]
}

/// The rectangle with quarter-circle corners of `radius`, clockwise.
pub fn rounded_rectangle_path(a: PointF, b: PointF, radius: f32) -> Vec<PointF> {
    let (x0, x1) = (a.x.min(b.x), a.x.max(b.x));
    let (y0, y1) = (a.y.min(b.y), a.y.max(b.y));
    let r = radius.min((x1 - x0) * 0.5).min((y1 - y0) * 0.5).max(0.0);
    if r <= 0.0 {
        return rectangle_path(a, b);
    }
    let steps = segments_for(r * 2.0) / 4 + 2;
    let corners = [
        (x1 - r, y0 + r, -90.0f32),
        (x1 - r, y1 - r, 0.0),
        (x0 + r, y1 - r, 90.0),
        (x0 + r, y0 + r, 180.0),
    ];
    let mut out = Vec::with_capacity(steps * 4 + 4);
    for (cx, cy, start) in corners {
        for i in 0..=steps {
            let t = (start + 90.0 * i as f32 / steps as f32).to_radians();
            out.push(PointF::new(cx + r * t.cos(), cy + r * t.sin()));
        }
    }
    out
}

/// The same contour shrunk (negative `by`) or grown along each vertex's
/// direction from the centroid; for convex shapes this is the inner and
/// outer edge of an outline.
pub fn offset_convex(path: &[PointF], a: PointF, b: PointF, by: f32) -> Vec<PointF> {
    let cx = (a.x + b.x) * 0.5;
    let cy = (a.y + b.y) * 0.5;
    let rx = ((b.x - a.x).abs() * 0.5).max(1e-3);
    let ry = ((b.y - a.y).abs() * 0.5).max(1e-3);
    let sx = ((rx + by) / rx).max(0.0);
    let sy = ((ry + by) / ry).max(0.0);
    path.iter()
        .map(|p| PointF::new(cx + (p.x - cx) * sx, cy + (p.y - cy) * sy))
        .collect()
}

/// A cubic Bézier through four control points.
pub fn bezier_path(p: [PointF; 4]) -> Vec<PointF> {
    let extent = p[0].distance(p[1]) + p[1].distance(p[2]) + p[2].distance(p[3]);
    let n = segments_for(extent * 4.0);
    (0..=n)
        .map(|i| {
            let t = i as f32 / n as f32;
            let u = 1.0 - t;
            let w = [u * u * u, 3.0 * u * u * t, 3.0 * u * t * t, t * t * t];
            PointF::new(
                w[0] * p[0].x + w[1] * p[1].x + w[2] * p[2].x + w[3] * p[3].x,
                w[0] * p[0].y + w[1] * p[1].y + w[2] * p[2].y + w[3] * p[3].y,
            )
        })
        .collect()
}

/// A cardinal spline through the points with GDI+'s default tension
/// 0.5, as `GraphicsPath.AddCurve` used by the line tool.
pub fn spline_path(points: &[PointF]) -> Vec<PointF> {
    if points.len() < 3 {
        return points.to_vec();
    }
    let tension = 0.5 / 3.0;
    let mut out = vec![points[0]];
    for i in 0..points.len() - 1 {
        let p0 = points[i.saturating_sub(1)];
        let p1 = points[i];
        let p2 = points[i + 1];
        let p3 = points[(i + 2).min(points.len() - 1)];
        let c1 = PointF::new(
            p1.x + (p2.x - p0.x) * tension,
            p1.y + (p2.y - p0.y) * tension,
        );
        let c2 = PointF::new(
            p2.x - (p3.x - p1.x) * tension,
            p2.y - (p3.y - p1.y) * tension,
        );
        out.extend(bezier_path([p1, c1, c2, p2]).into_iter().skip(1));
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_pixel_aligned_square_fills_exactly() {
        let path = rectangle_path(PointF::new(2.0, 2.0), PointF::new(5.0, 4.0));
        let mask = fill_polygon(&[path], Rect::of_size(10, 10), true);
        assert_eq!(mask.get(2, 2), 255);
        assert_eq!(mask.get(4, 3), 255);
        assert_eq!(mask.get(5, 3), 0);
        assert_eq!(mask.get(1, 3), 0);
        assert_eq!(mask.bounds(), Rect::new(2, 2, 3, 2));
    }

    #[test]
    fn half_covered_pixels_get_half_coverage() {
        let path = rectangle_path(PointF::new(2.5, 0.0), PointF::new(5.0, 4.0));
        let mask = fill_polygon(&[path], Rect::of_size(10, 10), true);
        assert!(mask.get(2, 1).abs_diff(128) <= 1);
        let hard = fill_polygon(
            &[rectangle_path(PointF::new(2.6, 0.0), PointF::new(5.0, 4.0))],
            Rect::of_size(10, 10),
            false,
        );
        assert_eq!(hard.get(2, 1), 0);
        assert_eq!(hard.get(3, 1), 255);
    }

    #[test]
    fn a_reversed_inner_contour_cuts_a_hole_and_clipping_keeps_winding() {
        let outer = rectangle_path(PointF::new(-5.0, 0.0), PointF::new(8.0, 8.0));
        let mut inner = rectangle_path(PointF::new(2.0, 2.0), PointF::new(6.0, 6.0));
        inner.reverse();
        let mask = fill_polygon(&[outer, inner], Rect::of_size(6, 10), true);
        assert_eq!(mask.get(0, 1), 255);
        assert_eq!(mask.get(3, 3), 0);
        assert_eq!(mask.get(5, 7), 255);
    }

    #[test]
    fn ellipse_area_is_close_to_pi_r_squared() {
        let path = ellipse_path(PointF::new(10.0, 10.0), PointF::new(50.0, 50.0));
        let mask = fill_polygon(&[path], Rect::of_size(64, 64), true);
        let area: f32 = mask.data().iter().map(|&v| v as f32 / 255.0).sum();
        let want = std::f32::consts::PI * 400.0;
        assert!((area - want).abs() / want < 0.01, "{area} vs {want}");
    }

    #[test]
    fn brush_capsule_covers_its_width() {
        let tip = BrushTip {
            width: 4.0,
            hardness: 1.0,
            antialias: false,
        };
        let mut mask = Mask::new(Rect::of_size(20, 20));
        tip.stamp_segment(&mut mask, PointF::new(5.5, 10.5), PointF::new(15.5, 10.5));
        assert_eq!(mask.get(10, 10), 255);
        assert_eq!(mask.get(10, 12), 255);
        assert_eq!(mask.get(10, 13), 0);
        assert_eq!(mask.get(3, 10), 255);
        assert_eq!(mask.get(1, 10), 0);
    }

    #[test]
    fn soft_brush_falls_off_towards_the_rim() {
        let tip = BrushTip {
            width: 20.0,
            hardness: 0.0,
            antialias: true,
        };
        let mut mask = Mask::new(Rect::of_size(30, 30));
        tip.stamp_segment(&mut mask, PointF::new(15.5, 15.5), PointF::new(15.5, 15.5));
        assert!(mask.get(15, 15) > 240);
        assert!(mask.get(20, 15) < 160 && mask.get(20, 15) > 90);
        assert_eq!(mask.get(27, 15), 0);
    }

    #[test]
    fn pencil_line_is_one_pixel_and_ends_inclusive() {
        let mut mask = Mask::new(Rect::of_size(10, 10));
        pencil_line(&mut mask, (1, 1), (6, 3));
        assert_eq!(mask.get(1, 1), 255);
        assert_eq!(mask.get(6, 3), 255);
        let count = mask.data().iter().filter(|&&v| v == 255).count();
        assert_eq!(count, 6);
    }

    #[test]
    fn splines_pass_through_their_points() {
        let points = [
            PointF::new(0.0, 0.0),
            PointF::new(10.0, 5.0),
            PointF::new(20.0, 0.0),
        ];
        let path = spline_path(&points);
        assert!(path.iter().any(|p| p.distance(points[1]) < 1e-3));
        assert_eq!(*path.last().unwrap(), points[2]);
    }
}
