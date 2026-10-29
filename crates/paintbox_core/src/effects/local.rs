//! Effects of a disc around each pixel, the source's
//! `LocalHistogramEffect`: the disc's histogram (Median, Sharpen,
//! Outline, Surface Blur, Reduce Noise) or its sums (Unfocus) slide
//! along the row, so each step adds and removes only the disc's edges.

use std::sync::atomic::AtomicBool;

use super::{by_rows, clamp_byte};
use crate::color::{clamp_u8, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// What slides over the disc.
trait Window {
    fn add(&mut self, p: Rgba8);
    fn remove(&mut self, p: Rgba8);
}

/// Each channel's histogram (r, g, b, a) and the pixels counted.
struct Histogram {
    channels: [[u32; 256]; 4],
    area: u32,
}

impl Window for Histogram {
    fn add(&mut self, p: Rgba8) {
        for (h, v) in self.channels.iter_mut().zip([p.r, p.g, p.b, p.a]) {
            h[v as usize] += 1;
        }
        self.area += 1;
    }

    fn remove(&mut self, p: Rgba8) {
        for (h, v) in self.channels.iter_mut().zip([p.r, p.g, p.b, p.a]) {
            h[v as usize] -= 1;
        }
        self.area -= 1;
    }
}

/// Premultiplied sums `[r·a, g·a, b·a, a]` and the pixels counted: the
/// source's alpha-weighted histogram, of which Unfocus needs the sums
/// alone.
struct Sums {
    sums: [u64; 4],
    area: u32,
}

impl Window for Sums {
    fn add(&mut self, p: Rgba8) {
        let a = p.a as u64;
        self.sums[0] += p.r as u64 * a;
        self.sums[1] += p.g as u64 * a;
        self.sums[2] += p.b as u64 * a;
        self.sums[3] += a;
        self.area += 1;
    }

    fn remove(&mut self, p: Rgba8) {
        let a = p.a as u64;
        self.sums[0] -= p.r as u64 * a;
        self.sums[1] -= p.g as u64 * a;
        self.sums[2] -= p.b as u64 * a;
        self.sums[3] -= a;
        self.area -= 1;
    }
}

/// `LocalHistogramEffect.RenderRect`: `window` over the disc
/// `u² + v² ≤ ((2r + 1)² + 2) / 4` around each pixel of row `y`, slid
/// along the row; pixels outside the picture are left out.
fn slide<W: Window>(
    src: &Surface,
    rect: Rect,
    y: i32,
    radius: u32,
    window: &mut W,
    line: &mut [Rgba8],
    emit: impl Fn(&W, Rgba8) -> Rgba8,
) {
    let r = radius as i32;
    let cutoff = ((r * 2 + 1) * (r * 2 + 1) + 2) / 4;
    let half: Vec<i32> = (0..=r)
        .map(|v| (0..=r).take_while(|u| u * u + v * v <= cutoff).count() as i32 - 1)
        .collect();
    let (w, h) = (src.width() as i32, src.height() as i32);
    let rows = (y - r).max(0)..(y + r + 1).min(h);
    for yy in rows.clone() {
        let hw = half[(yy - y).unsigned_abs() as usize];
        for x in (rect.x - hw).max(0)..(rect.x + hw + 1).min(w) {
            window.add(src.at(x, yy));
        }
    }
    for (i, out) in line.iter_mut().enumerate() {
        let x = rect.x + i as i32;
        if i > 0 {
            for yy in rows.clone() {
                let hw = half[(yy - y).unsigned_abs() as usize];
                let (gone, new) = (x - 1 - hw, x + hw);
                if gone >= 0 {
                    window.remove(src.at(gone, yy));
                }
                if new < w {
                    window.add(src.at(new, yy));
                }
            }
        }
        *out = emit(window, src.at(x, y));
    }
}

/// Every pixel of `rect` from its disc's histogram.
fn histogram(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    apply: impl Fn(&Histogram, Rgba8) -> Rgba8 + Sync,
) -> Result<Surface> {
    by_rows(rect, cancel, |y, line| {
        let mut window = Histogram {
            channels: [[0; 256]; 4],
            area: 0,
        };
        slide(src, rect, y, radius, &mut window, line, &apply);
    })
}

pub(super) fn median(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    percentile: u32,
) -> Result<Surface> {
    histogram(src, rect, cancel, radius, |h, _| {
        percentile_color(&h.channels, h.area, percentile)
    })
}

/// The median of a disc of radius Amount, and the pixel pushed away
/// from it: `ColorBgra.Lerp(src, median, -0.5)`.
pub(super) fn sharpen(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    amount: u32,
) -> Result<Surface> {
    histogram(src, rect, cancel, amount, |h, p| {
        let median = percentile_color(&h.channels, h.area, 50);
        let push =
            |s: u8, m: u8| clamp_u8((s as f32 + (m as f32 - s as f32) * -0.5).round() as i32);
        Rgba8::new(
            push(p.r, median.r),
            push(p.g, median.g),
            push(p.b, median.b),
            push(p.a, median.a),
        )
    })
}

pub(super) fn outline(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    thickness: u32,
    intensity: u32,
) -> Result<Surface> {
    histogram(src, rect, cancel, thickness, |h, _| {
        outline_color(&h.channels, h.area, intensity)
    })
}

/// `SurfaceBlurEffect`: each channel the average of the disc's values
/// weighted by how near they are to the pixel's own: weight
/// `255 − diff · 96 / threshold`, none past zero, so edges stay sharp.
pub(super) fn surface_blur(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    threshold: u32,
) -> Result<Surface> {
    let slope = 96.0 / threshold as f64;
    let mut factors = [0u64; 256];
    for (i, f) in factors.iter_mut().enumerate() {
        *f = (255.0 - i as f64 * slope).round().max(0.0) as u64;
    }
    // Values this far from the pixel or further weigh nothing; the
    // source walks all 256, which gives the same sums.
    let reach = factors.iter().position(|&f| f == 0).unwrap_or(256);
    let blur = |current: u8, h: &[u32; 256]| -> u8 {
        let c = current as usize;
        let (mut sum, mut divisor) = (0u64, 0u64);
        for (bin, &n) in h
            .iter()
            .enumerate()
            .take((c + reach).min(256))
            .skip((c + 1).saturating_sub(reach))
        {
            if n > 0 {
                let t = n as u64 * factors[c.abs_diff(bin)];
                sum += t * bin as u64;
                divisor += t;
            }
        }
        (sum + divisor / 2)
            .checked_div(divisor)
            .map_or(current, |v| v as u8)
    };
    histogram(src, rect, cancel, radius, |h, p| {
        // Alpha cannot be blurred this way once the channels are apart;
        // the source keeps the pixel's own.
        Rgba8::new(
            blur(p.r, &h.channels[0]),
            blur(p.g, &h.channels[1]),
            blur(p.b, &h.channels[2]),
            p.a,
        )
    })
}

/// `ReduceNoiseEffect`: each channel's rank in the disc (the share of
/// values below it, as 0 ..= 255) is where the pixel would sit if the
/// disc were spread evenly; the pixel moves away from it by
/// `0.2 · strength`, less in light pixels.
pub(super) fn reduce_noise(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    strength: f64,
) -> Result<Surface> {
    let strength = -0.2 * strength;
    histogram(src, rect, cancel, radius, |h, p| {
        let rank = |c: usize, v: u8| {
            (h.channels[c][..v as usize].iter().sum::<u32>() * 255 / h.area) as u8
        };
        let ranked = Rgba8::opaque(rank(0, p.r), rank(1, p.g), rank(2, p.b));
        let intensity = (0.114 * p.b as f64 + 0.587 * p.g as f64 + 0.299 * p.r as f64) / 255.0;
        let t = strength * (1.0 - 0.75 * intensity);
        let mix = |from: u8, to: u8| clamp_byte(from as f64 + t * (to as f64 - from as f64));
        Rgba8::new(
            mix(p.r, ranked.r),
            mix(p.g, ranked.g),
            mix(p.b, ranked.b),
            mix(p.a, ranked.a),
        )
    })
}

/// `UnfocusEffect`: the alpha-weighted average of the disc. The source
/// divides the weighted sums by `area · 255`, which darkens translucent
/// pixels in straight alpha; this divides by the alpha sum, the same for
/// opaque ones.
pub(super) fn unfocus(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
) -> Result<Surface> {
    by_rows(rect, cancel, |y, line| {
        let mut window = Sums {
            sums: [0; 4],
            area: 0,
        };
        slide(src, rect, y, radius, &mut window, line, |w, _| {
            let [r, g, b, a] = w.sums;
            if a == 0 {
                return Rgba8::TRANSPARENT;
            }
            let c = |v: u64| ((v + a / 2) / a) as u8;
            Rgba8::new(c(r), c(g), c(b), (a / w.area as u64) as u8)
        });
    })
}

/// The smallest value from `v` on whose running count (carried in
/// `count`, which already includes `h[v]`) reaches `min_count`.
/// `GetPercentile` in the source steps one value past it, so the median
/// of a flat 100 comes out 101; this one returns 100.
fn walk(h: &[u32; 256], mut v: usize, count: &mut u32, min_count: u32) -> usize {
    while v < 255 && *count < min_count {
        v += 1;
        *count += h[v];
    }
    v
}

fn first_used(h: &[u32; 256]) -> usize {
    h.iter().position(|&n| n > 0).unwrap_or(0)
}

/// The `percentile` of each channel among `area` pixels.
fn percentile_color(hist: &[[u32; 256]; 4], area: u32, percentile: u32) -> Rgba8 {
    let min_count = area * percentile / 100;
    let mut out = [0u8; 4];
    for (c, h) in hist.iter().enumerate() {
        let v = first_used(h);
        let mut count = h[v];
        out[c] = walk(h, v, &mut count, min_count) as u8;
    }
    Rgba8::new(out[0], out[1], out[2], out[3])
}

/// `OutlineEffect.Apply`: `255 − (c₂ − c₁)` between the percentiles
/// `(100 ∓ intensity) / 2`; alpha is the upper percentile.
fn outline_color(hist: &[[u32; 256]; 4], area: u32, intensity: u32) -> Rgba8 {
    let min1 = area * (100 - intensity) / 200;
    let min2 = area * (100 + intensity) / 200;
    let mut out = [0u8; 4];
    for (c, h) in hist.iter().enumerate() {
        let start = first_used(h);
        let mut count = h[start];
        let v1 = walk(h, start, &mut count, min1);
        let v2 = walk(h, v1, &mut count, min2);
        out[c] = if c == 3 {
            v2 as u8
        } else {
            (255 - (v2 - v1)) as u8
        };
    }
    Rgba8::new(out[0], out[1], out[2], out[3])
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    fn gray(v: u8) -> Rgba8 {
        Rgba8::opaque(v, v, v)
    }

    #[test]
    fn median_removes_a_speck_and_sharpen_pushes_away() {
        let mut s = Surface::filled(9, 9, gray(100)).unwrap();
        s.set(4, 4, Rgba8::WHITE);
        let m = render(
            Effect::Median {
                radius: 2,
                percentile: 50,
            },
            &s,
        );
        assert_eq!(m.at(4, 4), gray(100));
        let sharp = render(Effect::Sharpen { amount: 2 }, &s);
        assert_eq!(sharp.at(4, 4), gray(255));
        assert_eq!(sharp.at(0, 0), gray(100));
    }

    #[test]
    fn outline_is_white_on_flat_areas_and_dark_on_edges() {
        let mut s = Surface::filled(20, 10, Rgba8::WHITE).unwrap();
        for y in 0..10 {
            for x in 10..20 {
                s.set(x, y, Rgba8::BLACK);
            }
        }
        let o = render(
            Effect::Outline {
                thickness: 3,
                intensity: 50,
            },
            &s,
        );
        assert_eq!(o.at(2, 5).r, 255);
        assert!(o.at(10, 5).r < 10);
    }

    #[test]
    fn surface_blur_smooths_near_values_and_keeps_edges() {
        let mut s = Surface::filled(9, 9, gray(50)).unwrap();
        s.set(4, 4, gray(60));
        for y in 0..9 {
            s.set(8, y, gray(200));
        }
        let out = render(
            Effect::SurfaceBlur {
                radius: 1,
                threshold: 15,
            },
            &s,
        );
        // Radius 1 is the 3 × 3 square. Threshold 15: weight
        // round(255 − 6.4 · 10) = 191 for the eight 50s, 255 for the 60:
        // (8·191·50 + 255·60 + 891) / 1783 = 51.
        assert_eq!(out.at(4, 4), gray(51));
        // 200 is 150 away from 50: nothing crosses the edge.
        assert_eq!(out.at(8, 4), gray(200));
        assert_eq!(out.at(7, 0), gray(50));
        let flat = Surface::filled(12, 12, Rgba8::new(9, 99, 199, 120)).unwrap();
        let same = render(
            Effect::SurfaceBlur {
                radius: 6,
                threshold: 100,
            },
            &flat,
        );
        assert_eq!(same, flat);
    }

    #[test]
    fn reduce_noise_moves_away_from_the_rank() {
        // Radius 0: the disc is the pixel, no value lies below it, so its
        // rank is 0 and the pixel moves up by
        // 0.2 · 0.4 · (1 − 0.75 · 100/255) · 100 = 5.6 to 105.
        let s = Surface::filled(5, 5, gray(100)).unwrap();
        let out = render(
            Effect::ReduceNoise {
                radius: 0,
                strength: 0.4,
            },
            &s,
        );
        assert!(all(&out, gray(105)));
        let v = varied(20, 20);
        let none = render(
            Effect::ReduceNoise {
                radius: 10,
                strength: 0.0,
            },
            &v,
        );
        assert_eq!(none, v);
    }

    #[test]
    fn unfocus_averages_the_disc() {
        let mut s = Surface::filled(9, 9, Rgba8::BLACK).unwrap();
        s.set(4, 4, Rgba8::WHITE);
        let out = render(Effect::Unfocus { radius: 1 }, &s);
        // One white pixel in nine: 255 / 9 = 28.
        assert_eq!(out.at(4, 4), gray(28));
        assert_eq!(out.at(3, 3), gray(28));
        assert_eq!(out.at(2, 2), Rgba8::BLACK);
        let flat = Rgba8::new(200, 100, 50, 90);
        let f = Surface::filled(30, 30, flat).unwrap();
        assert!(all(&render(Effect::Unfocus { radius: 12 }, &f), flat));
    }
}
