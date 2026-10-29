//! Distortions: Pixelate, Bulge, Dents, Frosted Glass, Polar Inversion,
//! Tile Reflection, Twist. Most sample the picture at moved points,
//! bilinearly, several times per pixel at a higher quality.

use std::sync::atomic::AtomicBool;

use super::render::perlin;
use super::{by_pixels, by_rows, rgss_offsets, Rng};
use crate::color::{average, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// Cells `size × size` from the canvas origin, each the average of its
/// four corners.
pub(super) fn pixelate(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    cell_size: u32,
) -> Result<Surface> {
    let size = cell_size as i32;
    let (w, h) = (src.width() as i32, src.height() as i32);
    by_pixels(rect, cancel, |x, y| {
        let (cx, cy) = (x - x % size, y - y % size);
        let (right, bottom) = ((cx + size).min(w) - 1, (cy + size).min(h) - 1);
        average(&[
            src.at(cx, cy),
            src.at(right, cy),
            src.at(cx, bottom),
            src.at(right, bottom),
        ])
    })
}

/// Where a warp that lands outside the picture samples.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub(super) enum Edge {
    Clamp,
    Reflect,
    Wrap,
}

/// `WarpEffectBase.ReflectCoord`: the picture mirrored at each edge, a
/// period of two sides (the source steps one side at a time).
fn reflect(v: f32, side: f32) -> f32 {
    let v = v.rem_euclid(2.0 * side);
    if v > side {
        2.0 * side - v
    } else {
        v
    }
}

fn warp_sample(src: &Surface, x: f32, y: f32, edge: Edge) -> Rgba8 {
    if !x.is_finite() || !y.is_finite() {
        return Rgba8::TRANSPARENT;
    }
    let (w, h) = (src.width() as f32, src.height() as f32);
    if (0.0..=w - 1.0).contains(&x) && (0.0..=h - 1.0).contains(&y) {
        return src.bilinear(x, y);
    }
    match edge {
        Edge::Clamp => src.bilinear(x, y),
        Edge::Wrap => src.bilinear_wrapped(x, y),
        Edge::Reflect => src.bilinear(reflect(x, w), reflect(y, h)),
    }
}

/// `WarpEffectBase.OnRender`: each of the `quality²` sub-pixel points,
/// relative to the centre (the selection's, moved by `offset` of its
/// half-size), goes through `inverse` and is sampled there; the pixel is
/// their average.
fn warp(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    offset: (f64, f64),
    edge: Edge,
    quality: u32,
    inverse: impl Fn(f64, f64) -> (f64, f64) + Sync,
) -> Result<Surface> {
    let cx = rect.x as f64 + rect.width as f64 * (1.0 + offset.0) * 0.5;
    let cy = rect.y as f64 + rect.height as f64 * (1.0 + offset.1) * 0.5;
    let points = rgss_offsets(quality);
    by_rows(rect, cancel, |y, line| {
        let mut samples = Vec::with_capacity(points.len());
        let ry = y as f64 - cy;
        for (i, out) in line.iter_mut().enumerate() {
            let rx = (rect.x + i as i32) as f64 - cx;
            samples.clear();
            for &(px, py) in &points {
                let (tx, ty) = inverse(rx + px as f64, ry - py as f64);
                samples.push(warp_sample(src, (tx + cx) as f32, (ty + cy) as f32, edge));
            }
            *out = average(&samples);
        }
    })
}

/// The radius of the largest circle inside the selection's bounds.
fn selection_radius(rect: Rect) -> f64 {
    rect.width.min(rect.height) as f64 * 0.5
}

/// Dents' parameters, the seed already the noise's byte.
pub(super) struct Dents {
    pub scale: f64,
    pub refraction: f64,
    pub roughness: f64,
    pub tension: f64,
    pub seed: u8,
}

/// `DentsEffect`: each point is pushed by Perlin noise, a direction of
/// `tension`-scaled noise and a distance of `refraction`; the picture
/// reflects at its edges.
pub(super) fn dents(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    d: Dents,
    quality: u32,
) -> Result<Surface> {
    let scale_r = (400.0 / selection_radius(rect)) / d.scale;
    let refraction = (d.refraction / 100.0) / scale_r;
    let theta = std::f64::consts::TAU * d.tension / 10.0;
    let roughness = d.roughness / 100.0;
    // Octaves finer than a pixel would alias, so the source caps the
    // detail at the octave where the noise's period reaches one pixel.
    let wanted = 1.0 + d.roughness / 10.0;
    let max_detail = (scale_r.ln() / 0.5f64.ln()).floor();
    let detail = if wanted > max_detail && max_detail >= 1.0 {
        max_detail
    } else {
        wanted
    };
    warp(
        src,
        rect,
        cancel,
        (0.0, 0.0),
        Edge::Reflect,
        quality,
        |x, y| {
            let angle = theta * perlin(x * scale_r, y * scale_r, detail, roughness, d.seed);
            (
                x + refraction * (-angle).sin(),
                y + refraction * angle.cos(),
            )
        },
    )
}

/// `PolarInversionEffect`: a point at distance `d` from the centre goes
/// to distance `R² / d` (`R` the selection's inner radius), `amount` of
/// the way.
pub(super) fn polar_inversion(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    amount: f64,
    offset: (f64, f64),
    edge: Edge,
    quality: u32,
) -> Result<Surface> {
    let r2 = selection_radius(rect).powi(2);
    warp(src, rect, cancel, offset, edge, quality, |x, y| {
        // At the centre itself this is not a number and the sample is
        // transparent, as in the source.
        let inverted = 1.0 + (r2 / (x * x + y * y) - 1.0) * amount;
        (x * inverted, y * inverted)
    })
}

/// `FrostedGlassEffect`: the average of `samples` bilinear samples at
/// random points between the two scatter radii, drawn again until they
/// fall on the picture.
pub(super) fn frosted_glass(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    (min, max): (f64, f64),
    samples: u32,
    seed: u64,
) -> Result<Surface> {
    let (w, h) = (src.width() as f64, src.height() as f64);
    // Integer halving, as the source.
    let min = min.min((src.width().min(src.height()) / 2) as f64);
    let delta = max - min;
    by_rows(rect, cancel, |y, line| {
        let mut rng = Rng::for_row(seed, y);
        let mut picked = Vec::with_capacity(samples as usize);
        for (i, out) in line.iter_mut().enumerate() {
            let x = rect.x + i as i32;
            picked.clear();
            for _ in 0..samples {
                let (mut sx, mut sy) = (x as f64, y as f64);
                // The source draws until a point lands; a few hundred
                // misses only happen on slivers, which then keep the pixel.
                for _ in 0..256 {
                    let angle = rng.unit() * std::f64::consts::TAU;
                    let distance = rng.unit() * delta + min;
                    let (px, py) = (
                        x as f64 + angle.cos() * distance,
                        y as f64 + angle.sin() * distance,
                    );
                    if (0.0..=w).contains(&px) && (0.0..=h).contains(&py) {
                        (sx, sy) = (px, py);
                        break;
                    }
                }
                picked.push(src.bilinear(sx as f32, sy as f32));
            }
            *out = average(&picked);
        }
    })
}

/// `BulgeEffect`: inside the circle that fits the layer, a point at
/// relative distance `t` from the edge samples `1 − amount · t²` of its
/// distance from the centre; outside, the pixel stays.
pub(super) fn bulge(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    amount: i32,
    offset: (f64, f64),
) -> Result<Surface> {
    let (hw0, hh0) = (src.width() as f32 / 2.0, src.height() as f32 / 2.0);
    let max_radius = hw0.min(hh0);
    let amount = amount as f32 / 100.0;
    let hw = hw0 + offset.0 as f32 * hw0;
    let hh = hh0 + offset.1 as f32 * hh0;
    by_pixels(rect, cancel, |x, y| {
        let (u, v) = (x as f32 - hw, y as f32 - hh);
        let t = 1.0 - (u * u + v * v).sqrt() / max_radius;
        if t > 0.0 {
            let scale = 1.0 - amount * t * t;
            src.bilinear(u * scale + hw, v * scale + hh)
        } else {
            src.at(x, y)
        }
    })
}

/// `TwistEffect`: each point turns about the centre by
/// `amount² · t³ / 100` radians, `t` falling from 1 at the centre to 0 at
/// `size` times the radius of the circle that fits the layer.
pub(super) fn twist(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    amount: f64,
    size: f64,
    offset: (f64, f64),
    quality: u32,
) -> Result<Surface> {
    // The source turns the other way from the slider's sign.
    let amount = -amount;
    let twist = amount * amount * amount.signum();
    let inv_size = 1.0 / size;
    let (w, h) = (src.width() as f32, src.height() as f32);
    let hw = w / 2.0 + w / 2.0 * offset.0 as f32;
    let hh = h / 2.0 + h / 2.0 * offset.1 as f32;
    let inv_max_radius = 1.0 / (w as f64 / 2.0).min(h as f64 / 2.0);
    let points = rgss_offsets(quality);
    by_rows(rect, cancel, |y, line| {
        let mut samples = Vec::with_capacity(points.len());
        let j = y as f32 - hh;
        for (i, out) in line.iter_mut().enumerate() {
            let ii = (rect.x + i as i32) as f32 - hw;
            samples.clear();
            for &(px, py) in &points {
                let (u, v) = (ii + px, j + py);
                let radius = ((u * u + v * v) as f64).sqrt();
                let mut theta = (v as f64).atan2(u as f64);
                let t = 1.0 - radius * inv_size * inv_max_radius;
                let t = if t < 0.0 { 0.0 } else { t * t * t };
                theta += t * twist / 100.0;
                let sx = hw + (radius * theta.cos()) as f32;
                let sy = hh + (radius * theta.sin()) as f32;
                samples.push(src.bilinear(sx, sy));
            }
            *out = average(&samples);
        }
    })
}

/// `TileEffect` (Tile Reflection): in coordinates turned by `rotation`
/// about the layer's centre, each axis is pushed by
/// `curvature² / 10 · tan(s · π / tile_size)`, which mirrors the
/// picture in every tile; samples wrap around the layer.
pub(super) fn tile_reflection(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    rotation: f64,
    tile_size: f64,
    curvature: f64,
    quality: u32,
) -> Result<Surface> {
    let angle = (-rotation).to_radians();
    let (sin, cos) = (angle.sin() as f32, angle.cos() as f32);
    let scale = (std::f64::consts::PI / tile_size) as f32;
    let intensity = (curvature * curvature / 10.0 * curvature.signum()) as f32;
    // The source samples one level finer than the slider says, except
    // at the lowest quality.
    let quality = if quality == 1 { 1 } else { quality + 1 };
    let points = rgss_offsets(quality);
    let (hw, hh) = (src.width() as f32 / 2.0, src.height() as f32 / 2.0);
    by_rows(rect, cancel, |y, line| {
        let mut samples = Vec::with_capacity(points.len());
        let j = y as f32 - hh;
        for (i, out) in line.iter_mut().enumerate() {
            let ii = (rect.x + i as i32) as f32 - hw;
            samples.clear();
            for &(px, py) in &points {
                let (u1, v1) = (ii + px, j - py);
                let s1 = cos * u1 + sin * v1;
                let t1 = -sin * u1 + cos * v1;
                let s2 = s1 + intensity * (s1 * scale).tan();
                let t2 = t1 + intensity * (t1 * scale).tan();
                let u2 = cos * s2 - sin * t2;
                let v2 = sin * s2 + cos * t2;
                samples.push(src.bilinear_wrapped(hw + u2, hh + v2));
            }
            *out = average(&samples);
        }
    })
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    /// A picture that depends only on the distance from `(w/2, h/2)`,
    /// the centre these effects turn about (pixel `x` sits at `x`).
    fn rings(w: u32, h: u32) -> Surface {
        let mut s = Surface::new(w, h).unwrap();
        for y in 0..h as i32 {
            for x in 0..w as i32 {
                let (u, v) = (x as f32 - w as f32 / 2.0, y as f32 - h as f32 / 2.0);
                let d = (u * u + v * v).sqrt();
                let c = ((d * 20.0) as u32 % 256) as u8;
                s.set(x, y, Rgba8::opaque(c, 255 - c, c / 2));
            }
        }
        s
    }

    /// `out` is symmetric under the half turn `(x, y) → (w − x, h − y)`
    /// within `radius` of the centre.
    fn half_turn_symmetric(out: &Surface, radius: f32, by: u8) -> bool {
        let (w, h) = (out.width() as i32, out.height() as i32);
        (1..h).all(|y| {
            (1..w).all(|x| {
                let (u, v) = (x as f32 - w as f32 / 2.0, y as f32 - h as f32 / 2.0);
                (u * u + v * v).sqrt() > radius || close(out.at(x, y), out.at(w - x, h - y), by)
            })
        })
    }

    #[test]
    fn pixelate_fills_cells_with_the_corner_average() {
        let s = checker(8, 8);
        let p = render(Effect::Pixelate { cell_size: 4 }, &s);
        // Corners of a 4-cell: (0,0) white, (3,0) black, (0,3) black, (3,3) white.
        assert_eq!(p.at(1, 2), Rgba8::opaque(128, 128, 128));
        assert_eq!(p.at(1, 2), p.at(3, 3));
    }

    #[test]
    fn bulge_is_identity_at_zero_and_keeps_the_half_turn() {
        let s = varied(31, 25);
        let zero = Effect::Bulge {
            amount: 0,
            offset_x: 0.0,
            offset_y: 0.0,
        };
        assert_eq!(render(zero, &s), s);
        let r = rings(40, 30);
        let out = render(
            Effect::Bulge {
                amount: 80,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            &r,
        );
        assert!(half_turn_symmetric(&out, 14.0, 1));
        assert_ne!(out, r);
        // Outside the circle the pixel stays.
        assert_eq!(out.at(0, 0), r.at(0, 0));
        // A positive bulge magnifies: the centre samples nearer to it.
        // At (25, 15), t = 1 − 5/15 and the sample is 1 − 0.8·t² of the way.
        let t = 1.0f32 - 5.0 / 15.0;
        let want = r.bilinear(20.0 + 5.0 * (1.0 - 0.8 * t * t), 15.0);
        assert_eq!(out.at(25, 15), want);
    }

    #[test]
    fn twist_is_identity_at_zero_and_keeps_the_half_turn() {
        let s = varied(31, 25);
        let zero = Effect::Twist {
            amount: 0.0,
            size: 1.0,
            offset_x: 0.0,
            offset_y: 0.0,
            quality: 1,
        };
        assert!(render(zero, &s)
            .pixels()
            .iter()
            .zip(s.pixels())
            .all(|(a, b)| close(*a, *b, 1)));
        // Each pixel takes the colour of the first of itself and its
        // half-turn partner, so the picture keeps the half turn.
        let v = varied(40, 40);
        let mut sym = v.clone();
        for y in 1..40 {
            for x in 1..40 {
                let (a, b) = (x, y).min((40 - x, 40 - y));
                sym.set(x, y, v.at(a, b));
            }
        }
        let out = render(
            Effect::Twist {
                amount: 45.0,
                size: 1.0,
                offset_x: 0.0,
                offset_y: 0.0,
                quality: 1,
            },
            &sym,
        );
        assert!(half_turn_symmetric(&out, 18.0, 1));
        assert_ne!(out, sym);
    }

    #[test]
    fn polar_inversion_swaps_inside_and_outside() {
        let s = varied(41, 41);
        let none = Effect::PolarInversion {
            amount: 0.0,
            offset_x: 0.0,
            offset_y: 0.0,
            edge_behavior: 0,
            quality: 1,
        };
        assert!(render(none, &s)
            .pixels()
            .iter()
            .zip(s.pixels())
            .all(|(a, b)| close(*a, *b, 1)));
        // Amount 1: a point at distance d samples distance R²/d (R the
        // selection's inner radius, 20.5 here), so the corners come from
        // inside the circle and the middle from outside it.
        let out = render(
            Effect::PolarInversion {
                amount: 1.0,
                offset_x: 0.0,
                offset_y: 0.0,
                edge_behavior: 2,
                quality: 1,
            },
            &s,
        );
        let at = |x: i32, y: i32| {
            let (u, v) = (x as f64 - 20.5, y as f64 - 20.5);
            let k = 20.5f64 * 20.5 / (u * u + v * v);
            ((20.5 + u * k) as f32, (20.5 + v * k) as f32)
        };
        let (cx, cy) = at(40, 40);
        assert!(close(out.at(40, 40), s.bilinear(cx, cy), 1));
        // (36, 20) samples beyond the right edge, which wraps.
        let (wx, wy) = at(36, 20);
        assert!(wx > 41.0);
        assert!(close(out.at(36, 20), s.bilinear_wrapped(wx, wy), 1));
    }

    #[test]
    fn edges_clamp_reflect_and_wrap() {
        assert_eq!(reflect(-3.0, 10.0), 3.0);
        assert_eq!(reflect(13.0, 10.0), 7.0);
        assert_eq!(reflect(23.0, 10.0), 3.0);
        let mut s = Surface::filled(4, 1, Rgba8::BLACK).unwrap();
        s.set(0, 0, Rgba8::WHITE);
        assert_eq!(warp_sample(&s, 4.0, 0.0, Edge::Wrap), Rgba8::WHITE);
        assert_eq!(warp_sample(&s, 7.0, 0.0, Edge::Clamp), Rgba8::BLACK);
        assert_eq!(warp_sample(&s, -1.0, 0.0, Edge::Clamp), Rgba8::WHITE);
        assert_eq!(
            warp_sample(&s, f32::NAN, 0.0, Edge::Wrap),
            Rgba8::TRANSPARENT
        );
    }

    #[test]
    fn dents_are_repeatable_and_vary_with_the_seed() {
        let s = varied(48, 40);
        let dents = |seed| Effect::Dents {
            scale: 25.0,
            refraction: 50.0,
            roughness: 10.0,
            tension: 10.0,
            quality: 2,
            seed,
        };
        let a = render(dents(3), &s);
        assert_eq!(a, render(dents(3), &s));
        assert_ne!(a, render(dents(4), &s));
        assert_ne!(a, s);
        let none = Effect::Dents {
            scale: 25.0,
            refraction: 0.0,
            roughness: 10.0,
            tension: 10.0,
            quality: 1,
            seed: 3,
        };
        assert_eq!(render(none, &s), s);
    }

    #[test]
    fn frosted_glass_is_repeatable_and_keeps_flat_colour() {
        let flat = Rgba8::new(30, 60, 90, 255);
        let s = Surface::filled(30, 20, flat).unwrap();
        let glass = |seed| Effect::FrostedGlass {
            max_scatter: 3.0,
            min_scatter: 0.0,
            samples: 2,
            seed,
        };
        assert!(all(&render(glass(1), &s), flat));
        let v = varied(30, 20);
        let a = render(glass(1), &v);
        assert_eq!(a, render(glass(1), &v));
        assert_ne!(a, render(glass(2), &v));
        let still = Effect::FrostedGlass {
            max_scatter: 0.0,
            min_scatter: 0.0,
            samples: 3,
            seed: 1,
        };
        assert_eq!(render(still, &v), v);
    }

    #[test]
    fn tile_reflection_is_identity_without_curvature() {
        let s = varied(32, 24);
        let flat = Effect::TileReflection {
            rotation: 0.0,
            tile_size: 40.0,
            curvature: 0.0,
            quality: 1,
        };
        assert_eq!(render(flat, &s), s);
        let tiled = Effect::TileReflection {
            rotation: 30.0,
            tile_size: 8.0,
            curvature: 8.0,
            quality: 2,
        };
        let out = render(tiled, &s);
        assert_ne!(out, s);
        // Every tile is the same picture: the result repeats with the
        // tiles' period along the turned axes only, but a flat colour
        // stays flat everywhere.
        let f = Surface::filled(32, 24, Rgba8::opaque(7, 8, 9)).unwrap();
        assert!(all(&render(tiled, &f), Rgba8::opaque(7, 8, 9)));
    }
}
