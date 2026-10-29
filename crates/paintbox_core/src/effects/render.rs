//! Render: Clouds and the two fractals draw a new picture over the
//! selection; Perlin noise also drives Dents.

use std::sync::atomic::AtomicBool;

use super::{by_pixels, by_rows, clamp_byte};
use crate::blend::{blend, BlendMode};
use crate::color::Rgba8;
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// Ken Perlin's permutation, shared by `CloudsEffect` and
/// `PerlinNoise2D`; the source doubles it to 512 entries, which is the
/// same as indexing it modulo 256.
const PERMUTATION: [u8; 256] = [
    151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69,
    142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219,
    203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175,
    74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230,
    220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76,
    132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173,
    186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206,
    59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163,
    70, 221, 153, 101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232,
    178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162,
    241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204,
    176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141,
    128, 195, 78, 66, 215, 61, 156, 180,
];

fn perm(i: usize) -> usize {
    PERMUTATION[i & 255] as usize
}

fn fade(t: f64) -> f64 {
    t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
}

fn grad(hash: usize, x: f64, y: f64) -> f64 {
    let h = hash & 15;
    let u = if h < 8 { x } else { y };
    let v = if h < 4 {
        y
    } else if h == 12 || h == 14 {
        x
    } else {
        0.0
    };
    (if h & 1 == 0 { u } else { -u }) + (if h & 2 == 0 { v } else { -v })
}

fn mix(a: f64, b: f64, t: f64) -> f64 {
    a + t * (b - a)
}

/// Perlin noise in the lattice cell `(ix, iy)` (each 0 ..= 255) at the
/// fraction `(x, y)` within it, about −1 ..= 1.
fn cell_noise(ix: usize, iy: usize, x: f64, y: f64, seed: u8) -> f64 {
    let (u, v) = (fade(x), fade(y));
    let s = seed as usize;
    let a = perm(ix + s) + iy;
    let (aa, ab) = (perm(a), perm(a + 1));
    let b = perm(ix + 1 + s) + iy;
    let (ba, bb) = (perm(b), perm(b + 1));
    let edge1 = mix(grad(perm(aa), x, y), grad(perm(ba), x - 1.0, y), u);
    let edge2 = mix(
        grad(perm(ab), x, y - 1.0),
        grad(perm(bb), x - 1.0, y - 1.0),
        u,
    );
    mix(edge1, edge2, v)
}

fn noise_at(x: f64, y: f64, seed: u8) -> f64 {
    let (xf, yf) = (x.floor(), y.floor());
    cell_noise(
        (xf as i64 & 255) as usize,
        (yf as i64 & 255) as usize,
        x - xf,
        y - yf,
        seed,
    )
}

/// `PerlinNoise2D.Noise`: octaves of noise, each twice the frequency
/// and `roughness` times the amplitude of the one before, the last one
/// weighed by the fraction of `detail`. Each octave turns the
/// coordinates by 137.2° and moves them by (499, 506) so the octaves do
/// not line up.
pub(super) fn perlin(mut x: f64, mut y: f64, detail: f64, roughness: f64, seed: u8) -> f64 {
    let angle = 137.2f64.to_radians();
    let (sin, cos) = angle.sin_cos();
    let (mut total, mut frequency, mut amplitude) = (0.0, 1.0, 1.0);
    let mut partial = detail;
    for _ in 0..detail.ceil() as i32 {
        let xr = x * cos - y * sin;
        let yr = x * sin + y * cos;
        let mut n = noise_at(xr * frequency, yr * frequency, seed) * amplitude;
        if partial < 1.0 {
            n *= partial;
        }
        total += n;
        amplitude *= roughness;
        if amplitude < 0.001 {
            break;
        }
        frequency += frequency;
        partial -= 1.0;
        x = xr + 499.0;
        y = yr + 506.0;
    }
    total
}

/// `CloudsEffect.RenderClouds`: up to 12 octaves of noise about the
/// layer's centre, the first `scale` pixels across, each next one half
/// the size and `power` times as strong; black at −1, white at 1,
/// blended over the layer with `mode`.
pub(super) fn clouds(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    scale: u32,
    power: f64,
    mode: BlendMode,
    seed: u8,
) -> Result<Surface> {
    let (w, h) = (src.width() as i32, src.height() as i32);
    by_pixels(rect, cancel, |x, y| {
        let (dx, dy) = (2 * x - w, 2 * y - h);
        let (mut value, mut mult, mut div) = (0.0, 1.0, scale as i32);
        let mut octave = 0u8;
        while octave < 12 && mult > 0.03 && div > 0 {
            // Shifted far right so the cell index is never negative.
            let xr = 65536.0 + dx as f64 / div as f64;
            let yr = 65536.0 + dy as f64 / div as f64;
            let (xi, yi) = (xr as i64, yr as i64);
            let n = cell_noise(
                (xi & 255) as usize,
                (yi & 255) as usize,
                xr - xi as f64,
                yr - yi as f64,
                seed ^ octave,
            );
            value += n * mult;
            div /= 2;
            mult *= power;
            octave += 1;
        }
        let v = clamp_byte((value + 1.0) / 2.0 * 255.0);
        blend(src.at(x, y), Rgba8::opaque(v, v, v), mode, 255)
    })
}

/// The sub-pixel point `i` of `count` for the fractals: spread along
/// the diagonal of the pixel as the source does, in units of the
/// layer's height around its centre, turned by `angle`.
fn fractal_point(
    x: i32,
    y: i32,
    i: u32,
    count: u32,
    quality: u32,
    size: (f64, f64),
    angle: f64,
) -> (f64, f64) {
    let (w, h) = size;
    let i = i as f64;
    let u = (2.0 * x as f64 - w + i / count as f64) / h;
    let v = (2.0 * y as f64 - h + (i / quality as f64) % 1.0) / h;
    let radius = (u * u + v * v).sqrt();
    let theta = v.atan2(u) + angle;
    (radius * theta.cos(), radius * theta.sin())
}

/// `JuliaFractal.Julia`: the smoothed escape count of `z² + c` from
/// `(x, y)`, up to 256 steps.
fn julia_count(mut x: f64, mut y: f64, r: f64, i: f64) -> f64 {
    let mut c = 0.0;
    while c < 256.0 && x * x + y * y < 10000.0 {
        let t = x;
        x = x * x - y * y + r;
        y = 2.0 * t * y + i;
        c += 1.0;
    }
    c - (2.0 - 2.0 * 10000f64.ln() / (x * x + y * y).ln())
}

/// `JuliaFractalEffect`: the Julia set of `c = 0.3125 + 0.03i`, its
/// count times `factor` read as alpha, red, green, blue in turn as it
/// passes 0, 256, 512, 768.
pub(super) fn julia(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    factor: f64,
    zoom: f64,
    angle: f64,
    quality: u32,
) -> Result<Surface> {
    let size = (src.width() as f64, src.height() as f64);
    let aspect = size.1 / size.0;
    let count = quality * quality + 1;
    let angle = angle.to_radians();
    by_pixels(rect, cancel, |x, y| {
        let mut sums = [0u32; 4];
        for i in 0..count {
            let (u, v) = fractal_point(x, y, i, count, quality, size, angle);
            let jx = (u - v * aspect) / zoom;
            let jy = (v + u * aspect) / zoom;
            let c = factor * julia_count(jx, jy, 0.3125, 0.03);
            for (s, shift) in sums.iter_mut().zip([256.0, 512.0, 768.0, 0.0]) {
                *s += clamp_byte(c - shift) as u32;
            }
        }
        let [r, g, b, a] = sums.map(|s| (s / count) as u8);
        Rgba8::new(r, g, b, a)
    })
}

/// Inside the main cardioid or the period-2 bulb: such points never
/// escape, so their orbit need not be followed.
fn in_main_bulbs(r: f64, i: f64) -> bool {
    let q = (r - 0.25) * (r - 0.25) + i * i;
    q * (q + (r - 0.25)) < 0.25 * i * i || (r + 1.0) * (r + 1.0) + i * i < 0.0625
}

/// How near an orbit must come back to a point it passed to count as
/// caught in a cycle: attracting cycles near the set's edge settle
/// slowly, and in 1024 steps come this close, while escaping orbits
/// there do not (a test checks the default view point by point).
const CYCLE_EPSILON: f64 = 1e-6;

/// Escape radius² of the source's loop.
const ESCAPE: f64 = 100000.0;

/// [`mandelbrot_values`] of one point.
#[cfg(test)]
fn mandelbrot_value(r: f64, i: f64, factor: u32) -> f64 {
    let mut out = [0.0];
    mandelbrot_values(&[(r, i)], factor, &mut out);
    out[0]
}

/// Orbits are stepped side by side in lanes, `BLOCK` steps at a time
/// with no checks, which the compiler turns into vector code; the
/// source's loop checks after every step. A lane whose orbit escaped or
/// reached the step limit inside a block replays that block step by
/// step from its start, so counts and values are the source's. After an
/// escape the blind steps overflow to infinity or not a number, which
/// the replay discards.
const LANES: usize = 8;
const BLOCK: u32 = 16;

/// Orbits in lanes; `index` is `usize::MAX` in a free lane.
struct Lanes {
    index: [usize; LANES],
    r: [f64; LANES],
    i: [f64; LANES],
    x: [f64; LANES],
    y: [f64; LANES],
    count: [u32; LANES],
    saved: [(f64, f64); LANES],
    next_save: [u32; LANES],
}

/// The channel value of an orbit that stopped after `count` steps at
/// `(x, y)`.
fn escaped(count: u32, x: f64, y: f64, factor: u32) -> f64 {
    64.0 + factor as f64 * (count as f64 - (y * y + x * x).ln() / ESCAPE.ln())
}

fn near(a: (f64, f64), b: (f64, f64)) -> bool {
    (a.0 - b.0).abs() < CYCLE_EPSILON && (a.1 - b.1).abs() < CYCLE_EPSILON
}

/// `MandelbrotFractalEffect.Mandelbrot` of every point, turned into the
/// effect's channel value `64 + factor · m`, into `out`. Points that
/// never escape come out past 1023 in the source whatever their last
/// `z` (the count reaches `1024 / factor`), so they are infinity here
/// and need no more steps: inside the main bulbs, or once the orbit
/// comes back to where it was (Brent's cycle check: a point saved at
/// each power of 2).
fn mandelbrot_values(points: &[(f64, f64)], factor: u32, out: &mut [f64]) {
    // The source steps while `count · factor < 1024`.
    let limit = 1023 / factor + 1;
    let mut l = Lanes {
        index: [usize::MAX; LANES],
        r: [0.0; LANES],
        i: [0.0; LANES],
        x: [0.0; LANES],
        y: [0.0; LANES],
        count: [0; LANES],
        saved: [(0.0, 0.0); LANES],
        next_save: [0; LANES],
    };
    let mut next = 0;
    loop {
        for k in 0..LANES {
            while l.index[k] == usize::MAX && next < points.len() {
                let (r, i) = points[next];
                if in_main_bulbs(r, i) {
                    out[next] = f64::INFINITY;
                } else {
                    l.index[k] = next;
                    (l.r[k], l.i[k], l.x[k], l.y[k]) = (r, i, 0.0, 0.0);
                    (l.count[k], l.saved[k], l.next_save[k]) = (0, (0.0, 0.0), 8);
                }
                next += 1;
            }
        }
        if l.index.iter().all(|&i| i == usize::MAX) {
            return;
        }
        let (start_x, start_y) = (l.x, l.y);
        for _ in 0..BLOCK {
            for k in 0..LANES {
                let t = l.x[k];
                l.x[k] = l.x[k] * l.x[k] - l.y[k] * l.y[k] + l.r[k];
                l.y[k] = 2.0 * t * l.y[k] + l.i[k];
            }
        }
        for k in 0..LANES {
            if l.index[k] == usize::MAX {
                continue;
            }
            let (x, y) = (l.x[k], l.y[k]);
            // Not a number (an overflowed escape) counts as escaped.
            let inside_bound = x * x + y * y < ESCAPE;
            let done = if !inside_bound || l.count[k] + BLOCK >= limit {
                let (mut x, mut y, mut count) = (start_x[k], start_y[k], l.count[k]);
                let mut done = None;
                while done.is_none() && count < l.count[k] + BLOCK {
                    let t = x;
                    x = x * x - y * y + l.r[k];
                    y = 2.0 * t * y + l.i[k];
                    count += 1;
                    if x * x + y * y >= ESCAPE {
                        done = Some(escaped(count, x, y, factor));
                    } else if near((x, y), l.saved[k]) {
                        done = Some(f64::INFINITY);
                    } else if count >= limit {
                        done = Some(escaped(count, x, y, factor));
                    }
                }
                done
            } else if near((x, y), l.saved[k]) {
                Some(f64::INFINITY)
            } else {
                l.count[k] += BLOCK;
                if l.count[k] >= l.next_save[k] {
                    l.saved[k] = (x, y);
                    l.next_save[k] *= 2;
                }
                None
            };
            if let Some(value) = done {
                out[l.index[k]] = value;
                (l.index[k], l.r[k], l.i[k], l.x[k], l.y[k]) = (usize::MAX, 0.0, 0.0, 0.0, 0.0);
            }
        }
    }
}

/// `MandelbrotFractalEffect`: the set around `(−0.7, −0.29)`, zoomed
/// `1 + 20 · zoom` times; the value is read as alpha, blue, green, red
/// in turn as it passes 0, 256, 512, 768. Inside the set is white.
#[allow(clippy::too_many_arguments)]
pub(super) fn mandelbrot(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    factor: u32,
    zoom: f64,
    angle: f64,
    quality: u32,
    invert_colors: bool,
) -> Result<Surface> {
    let view = MandelbrotView {
        size: (src.width() as f64, src.height() as f64),
        zoom: 1.0 + 20.0 * zoom,
        angle: angle.to_radians(),
        quality,
        factor,
        invert_colors,
    };
    by_rows(rect, cancel, |y, line| {
        let at: Vec<(i32, i32)> = (0..line.len() as i32).map(|j| (rect.x + j, y)).collect();
        line.copy_from_slice(&view.pixels(&at));
    })
}

/// The Mandelbrot renderer's parameters.
struct MandelbrotView {
    size: (f64, f64),
    zoom: f64,
    angle: f64,
    quality: u32,
    factor: u32,
    invert_colors: bool,
}

impl MandelbrotView {
    /// The colour of each pixel at `at`.
    fn pixels(&self, at: &[(i32, i32)]) -> Vec<Rgba8> {
        let count = self.quality * self.quality + 1;
        let mut points = Vec::with_capacity(at.len() * count as usize);
        for &(x, y) in at {
            for i in 0..count {
                let (u, v) = fractal_point(x, y, i, count, self.quality, self.size, self.angle);
                points.push((u / self.zoom - 0.7, v / self.zoom - 0.29));
            }
        }
        let mut values = vec![0.0; points.len()];
        mandelbrot_values(&points, self.factor, &mut values);
        values
            .chunks(count as usize)
            .map(|pixel| {
                let mut sums = [0u32; 4];
                for &c in pixel {
                    for (s, shift) in sums.iter_mut().zip([768.0, 512.0, 256.0, 0.0]) {
                        *s += clamp_byte(c - shift) as u32;
                    }
                }
                let [r, g, b, a] = sums.map(|s| (s / count) as u8);
                if self.invert_colors {
                    Rgba8::new(255 - r, 255 - g, 255 - b, a)
                } else {
                    Rgba8::new(r, g, b, a)
                }
            })
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    /// The source's loop, followed to the end every time.
    fn mandelbrot_by_iterating(r: f64, i: f64, factor: u32) -> f64 {
        let (mut x, mut y, mut c) = (0.0f64, 0.0f64, 0u32);
        while c * factor < 1024 && x * x + y * y < 100000.0 {
            let t = x;
            x = x * x - y * y + r;
            y = 2.0 * t * y + i;
            c += 1;
        }
        64.0 + factor as f64 * (c as f64 - (y * y + x * x).ln() / 100000f64.ln())
    }

    #[test]
    fn mandelbrot_shortcuts_agree_with_the_full_loop() {
        for factor in [1, 3, 7, 10] {
            for k in 0..400 {
                let (r, i) = (-2.0 + (k % 20) as f64 * 0.13, -1.2 + (k / 20) as f64 * 0.12);
                let fast = mandelbrot_value(r, i, factor);
                let slow = mandelbrot_by_iterating(r, i, factor);
                // Every channel reads the same either way.
                for shift in [0.0, 256.0, 512.0, 768.0] {
                    assert_eq!(
                        clamp_byte(fast - shift),
                        clamp_byte(slow - shift),
                        "{r} {i} {factor}"
                    );
                }
            }
        }
    }

    #[test]
    fn the_cycle_check_agrees_with_the_full_loop_at_the_default_view() {
        // The default view (zoom 10, 201 times) lies on the set's edge,
        // where orbits are slowest to settle or escape.
        for k in 0..128 * 128 {
            let (x, y) = ((k % 128) as f64 / 64.0 - 1.0, (k / 128) as f64 / 64.0 - 1.0);
            let (r, i) = (x / 201.0 - 0.7, y / 201.0 - 0.29);
            let (fast, slow) = (mandelbrot_value(r, i, 1), mandelbrot_by_iterating(r, i, 1));
            for shift in [0.0, 256.0, 512.0, 768.0] {
                assert_eq!(
                    clamp_byte(fast - shift),
                    clamp_byte(slow - shift),
                    "{r} {i}"
                );
            }
        }
    }

    #[test]
    fn inside_the_mandelbrot_set_is_white_or_black_inverted() {
        // Zoom 0: the picture is 2 units high about (−0.7, −0.29), so
        // pixel (48, 41) is near −0.2 + 0i, in the main cardioid.
        let s = Surface::new(64, 64).unwrap();
        let fx = |invert_colors| Effect::MandelbrotFractal {
            factor: 1,
            zoom: 0.0,
            angle: 0.0,
            quality: 2,
            invert_colors,
        };
        let out = render(fx(false), &s);
        assert_eq!(out.at(48, 41), Rgba8::WHITE);
        let inverted = render(fx(true), &s);
        assert_eq!(inverted.at(48, 41), Rgba8::BLACK);
        // Far outside it escapes at once: dark and nearly transparent.
        let corner = out.at(0, 0);
        assert!(corner.a < 128 && corner.r == 0, "{corner:?}");
    }

    #[test]
    fn julia_matches_its_formula_at_a_pixel() {
        let s = Surface::new(40, 30).unwrap();
        let out = render(
            Effect::JuliaFractal {
                factor: 4.0,
                zoom: 1.0,
                angle: 0.0,
                quality: 1,
            },
            &s,
        );
        // Quality 1: two points per pixel, at 0 and half a pixel across.
        let (x, y) = (7, 22);
        let mut sums = [0u32; 4];
        for i in 0..2 {
            let u = (2.0 * x as f64 - 40.0 + i as f64 / 2.0) / 30.0;
            let v = (2.0 * y as f64 - 30.0) / 30.0;
            let aspect = 30.0 / 40.0;
            let c = 4.0 * julia_count(u - v * aspect, v + u * aspect, 0.3125, 0.03);
            for (s, shift) in sums.iter_mut().zip([256.0, 512.0, 768.0, 0.0]) {
                *s += clamp_byte(c - shift) as u32;
            }
        }
        let [r, g, b, a] = sums.map(|s| (s / 2) as u8);
        assert!(close(out.at(x, y), Rgba8::new(r, g, b, a), 1));
    }

    #[test]
    fn clouds_are_repeatable_and_blend_by_their_mode() {
        let s = Surface::filled(64, 48, Rgba8::opaque(200, 40, 40)).unwrap();
        let clouds = |seed, blend_mode| Effect::Clouds {
            scale: 40,
            power: 0.5,
            blend_mode,
            seed,
        };
        let a = render(clouds(5, 0), &s);
        assert_eq!(a, render(clouds(5, 0), &s));
        assert_ne!(a, render(clouds(6, 0), &s));
        // Normal: grey clouds replace the layer.
        assert!(a
            .pixels()
            .iter()
            .all(|p| p.r == p.g && p.g == p.b && p.a == 255));
        assert!(a.pixels().iter().any(|p| p.r < 110) && a.pixels().iter().any(|p| p.r > 145));
        // Multiply keeps the layer's hue under the clouds.
        let m = render(clouds(5, 1), &s);
        let (p, q) = (m.at(10, 10), a.at(10, 10));
        assert_eq!(p.r, crate::color::mul255(200, q.r as u32) as u8);
        assert_eq!(p.g, crate::color::mul255(40, q.r as u32) as u8);
    }

    #[test]
    fn perlin_noise_is_smooth_and_bounded() {
        let mut last = perlin(0.0, 0.0, 3.0, 0.5, 9);
        for k in 1..2000 {
            let n = perlin(k as f64 * 0.01, k as f64 * 0.007, 3.0, 0.5, 9);
            assert!(n.abs() < 2.0);
            assert!((n - last).abs() < 0.2);
            last = n;
        }
        assert_eq!(cell_noise(3, 4, 0.0, 0.0, 0), 0.0);
    }
}
