//! Line / Curve's pen: the line's ends (flat, arrow, filled arrow,
//! rounded) and its dash, as Paint.NET's `PenInfo` sets up a GDI+ pen.
//! The arrows are GDI+'s `AdjustableArrowCap(5, 5)`: five pen widths
//! long and wide, the tip on the line's end. Dashes are lengths in pen
//! widths, as GDI+'s dash styles.

use serde::{Deserialize, Serialize};

use crate::geom::{PointF, Rect};
use crate::mask::Mask;
use crate::raster::{self, BrushTip};

/// How a line ends.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Hash, Serialize, Deserialize)]
pub enum LineCap {
    #[default]
    Flat,
    Arrow,
    ArrowFilled,
    Rounded,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Hash, Serialize, Deserialize)]
pub enum DashStyle {
    #[default]
    Solid,
    Dash,
    DashDot,
    DashDotDot,
    Dot,
}

impl LineCap {
    pub const ALL: [LineCap; 4] = [
        LineCap::Flat,
        LineCap::Arrow,
        LineCap::ArrowFilled,
        LineCap::Rounded,
    ];

    /// The next in the bar's order (`,` and `/` cycle the ends).
    pub fn next(self) -> LineCap {
        let i = LineCap::ALL.iter().position(|&c| c == self).unwrap_or(0);
        LineCap::ALL[(i + 1) % LineCap::ALL.len()]
    }
}

impl DashStyle {
    pub const ALL: [DashStyle; 5] = [
        DashStyle::Solid,
        DashStyle::Dash,
        DashStyle::DashDot,
        DashStyle::DashDotDot,
        DashStyle::Dot,
    ];

    /// The next in the bar's order (`.` cycles the dash).
    pub fn next(self) -> DashStyle {
        let i = DashStyle::ALL.iter().position(|&d| d == self).unwrap_or(0);
        DashStyle::ALL[(i + 1) % DashStyle::ALL.len()]
    }

    /// On and off lengths in pen widths, GDI+'s patterns.
    fn pattern(self) -> &'static [f32] {
        match self {
            DashStyle::Solid => &[],
            DashStyle::Dash => &[3.0, 1.0],
            DashStyle::DashDot => &[3.0, 1.0, 1.0, 1.0],
            DashStyle::DashDotDot => &[3.0, 1.0, 1.0, 1.0, 1.0, 1.0],
            DashStyle::Dot => &[1.0, 1.0],
        }
    }
}

/// Paint.NET's arrow: five pen widths long and across.
const ARROW: f32 = 5.0;

/// The coverage of `path` stroked `width` wide with the given ends and
/// dash, clipped to `canvas`. Joins are round; dashes have flat ends.
pub fn stroke_line(
    path: &[PointF],
    width: f32,
    start: LineCap,
    end: LineCap,
    dash: DashStyle,
    antialias: bool,
    canvas: Rect,
) -> Mask {
    let half = width * 0.5;
    let mut bounds = Rect::default();
    for p in path {
        bounds = bounds.union(Rect::covering(p.x, p.y, p.x, p.y));
    }
    let reach = (width * ARROW).ceil() as i32 + 2;
    let mut mask = Mask::new(bounds.inflate(reach).intersect(canvas));
    let path = dedup(path);
    if path.len() < 2 {
        // A click: a dot the pen's width.
        if let Some(&p) = path.first() {
            disc(&mut mask, p, width, antialias);
        }
        return mask;
    }
    // The arrows' bases stand back from the ends; the line stops there so
    // a wide pen does not poke through the tip.
    let back = |cap: LineCap| match cap {
        LineCap::Arrow | LineCap::ArrowFilled => width * ARROW * 0.5,
        _ => 0.0,
    };
    let body = trim(&path, back(start), back(end));
    for run in dashes(&body, dash.pattern(), width) {
        stroke_run(&mut mask, &run, half, antialias, canvas);
    }
    let first = (path[0], path[1]);
    let n = path.len();
    let last = (path[n - 1], path[n - 2]);
    for (cap, (tip, toward)) in [(start, first), (end, last)] {
        draw_cap(&mut mask, cap, tip, toward, width, antialias, canvas);
    }
    mask
}

fn dedup(path: &[PointF]) -> Vec<PointF> {
    let mut out: Vec<PointF> = Vec::with_capacity(path.len());
    for &p in path {
        if out.last().is_none_or(|q| dist(*q, p) > 1e-4) {
            out.push(p);
        }
    }
    out
}

fn dist(a: PointF, b: PointF) -> f32 {
    ((b.x - a.x).powi(2) + (b.y - a.y).powi(2)).sqrt()
}

fn lerp(a: PointF, b: PointF, t: f32) -> PointF {
    PointF::new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
}

/// `path` with `from_start` and `from_end` of its length cut off.
fn trim(path: &[PointF], from_start: f32, from_end: f32) -> Vec<PointF> {
    let total: f32 = path.windows(2).map(|w| dist(w[0], w[1])).sum();
    if from_start + from_end >= total {
        return Vec::new();
    }
    cut(path, from_start, total - from_end)
}

/// The part of `path` between lengths `a` and `b` along it.
fn cut(path: &[PointF], a: f32, b: f32) -> Vec<PointF> {
    let mut out = Vec::new();
    let mut at = 0.0;
    for w in path.windows(2) {
        let len = dist(w[0], w[1]);
        let (s, e) = (at, at + len);
        if e >= a && s <= b && len > 0.0 {
            let t0 = ((a - s) / len).clamp(0.0, 1.0);
            let t1 = ((b - s) / len).clamp(0.0, 1.0);
            let p0 = lerp(w[0], w[1], t0);
            if out.last().is_none_or(|q| dist(*q, p0) > 1e-4) {
                out.push(p0);
            }
            out.push(lerp(w[0], w[1], t1));
        }
        at = e;
    }
    out
}

/// The "on" runs of a dash pattern scaled by the pen width.
fn dashes(path: &[PointF], pattern: &[f32], width: f32) -> Vec<Vec<PointF>> {
    if path.len() < 2 {
        return Vec::new();
    }
    if pattern.is_empty() {
        return vec![path.to_vec()];
    }
    let total: f32 = path.windows(2).map(|w| dist(w[0], w[1])).sum();
    // A pen thinner than a pixel still dashes in whole pixels.
    let unit = width.max(1.0);
    let mut out = Vec::new();
    let (mut at, mut i) = (0.0, 0);
    while at < total {
        let on = pattern[i % pattern.len()] * unit;
        let off = pattern[(i + 1) % pattern.len()] * unit;
        out.push(cut(path, at, (at + on).min(total)));
        at += on + off;
        i += 2;
    }
    out
}

/// One run with flat ends and round joins.
fn stroke_run(mask: &mut Mask, run: &[PointF], half: f32, aa: bool, canvas: Rect) {
    for w in run.windows(2) {
        let (a, b) = (w[0], w[1]);
        let len = dist(a, b);
        if len <= 0.0 {
            continue;
        }
        let (nx, ny) = (-(b.y - a.y) / len * half, (b.x - a.x) / len * half);
        let quad = vec![
            PointF::new(a.x + nx, a.y + ny),
            PointF::new(b.x + nx, b.y + ny),
            PointF::new(b.x - nx, b.y - ny),
            PointF::new(a.x - nx, a.y - ny),
        ];
        merge(mask, &raster::fill_polygon(&[quad], canvas, aa));
    }
    if run.len() > 2 {
        for &p in &run[1..run.len() - 1] {
            disc(mask, p, half * 2.0, aa);
        }
    }
}

fn draw_cap(
    mask: &mut Mask,
    cap: LineCap,
    tip: PointF,
    toward: PointF,
    width: f32,
    aa: bool,
    canvas: Rect,
) {
    let len = dist(tip, toward);
    if len <= 0.0 {
        return;
    }
    let (ux, uy) = ((toward.x - tip.x) / len, (toward.y - tip.y) / len);
    let size = width * ARROW;
    let base = PointF::new(tip.x + ux * size, tip.y + uy * size);
    let (nx, ny) = (-uy * size * 0.5, ux * size * 0.5);
    let left = PointF::new(base.x + nx, base.y + ny);
    let right = PointF::new(base.x - nx, base.y - ny);
    match cap {
        LineCap::Flat => {}
        LineCap::Rounded => disc(mask, tip, width, aa),
        LineCap::ArrowFilled => {
            merge(
                mask,
                &raster::fill_polygon(&[vec![tip, left, right]], canvas, aa),
            );
        }
        LineCap::Arrow => {
            // The open arrow: its two sides and the shaft up to the tip.
            let half = width * 0.5;
            stroke_run(mask, &[left, tip, right], half, aa, canvas);
            stroke_run(mask, &[base, tip], half, aa, canvas);
            disc(mask, tip, width, aa);
        }
    }
}

fn disc(mask: &mut Mask, at: PointF, width: f32, aa: bool) {
    let tip = BrushTip {
        width,
        hardness: 1.0,
        antialias: aa,
    };
    tip.stamp_segment(mask, at, at);
}

/// The larger coverage of the two, as strokes union.
fn merge(mask: &mut Mask, other: &Mask) {
    let r = other.rect().intersect(mask.rect());
    for y in r.y..r.bottom() {
        for x in r.x..r.right() {
            let c = other.get(x, y);
            if c > mask.get(x, y) {
                mask.set(x, y, c);
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn canvas() -> Rect {
        Rect::new(0, 0, 100, 60)
    }

    fn covered(mask: &Mask) -> usize {
        let r = mask.rect();
        let mut n = 0;
        for y in r.y..r.bottom() {
            for x in r.x..r.right() {
                if mask.get(x, y) > 127 {
                    n += 1;
                }
            }
        }
        n
    }

    fn line(start: LineCap, end: LineCap, dash: DashStyle) -> Mask {
        let path = [PointF::new(10.0, 30.0), PointF::new(90.0, 30.0)];
        stroke_line(&path, 4.0, start, end, dash, true, canvas())
    }

    #[test]
    fn flat_ends_stop_at_the_points_and_rounded_ones_go_past() {
        let flat = line(LineCap::Flat, LineCap::Flat, DashStyle::Solid);
        assert_eq!(flat.get(50, 30), 255);
        assert_eq!(flat.get(8, 30), 0);
        assert_eq!(flat.get(91, 30), 0);
        assert_eq!(covered(&flat), 80 * 4);
        let round = line(LineCap::Rounded, LineCap::Rounded, DashStyle::Solid);
        assert!(round.get(8, 30) > 200);
        assert!(round.get(91, 30) > 200);
    }

    #[test]
    fn arrows_are_five_widths_wide() {
        let filled = line(LineCap::Flat, LineCap::ArrowFilled, DashStyle::Solid);
        // Ten pixels either side of the line at the base, narrowing to the tip.
        assert!(filled.get(72, 38) > 127 && filled.get(72, 21) > 127);
        assert_eq!(filled.get(85, 21), 0);
        assert!(filled.get(85, 30) > 127);
        let open = line(LineCap::Flat, LineCap::Arrow, DashStyle::Solid);
        // The open arrow is hollow between its sides.
        assert!(open.get(71, 21) > 127);
        assert_eq!(open.get(75, 26), 0);
        assert!(filled.get(75, 26) > 127);
    }

    #[test]
    fn dashes_leave_gaps_of_their_pattern() {
        let dash = line(LineCap::Flat, LineCap::Flat, DashStyle::Dash);
        // On 12, off 4 at a 4-pixel pen.
        assert_eq!(dash.get(15, 30), 255);
        assert_eq!(dash.get(24, 30), 0);
        assert_eq!(dash.get(27, 30), 255);
        let dot = line(LineCap::Flat, LineCap::Flat, DashStyle::Dot);
        assert_eq!(covered(&dot), 40 * 4);
        assert_eq!(DashStyle::Dot.next(), DashStyle::Solid);
        assert_eq!(LineCap::Rounded.next(), LineCap::Flat);
    }
}
