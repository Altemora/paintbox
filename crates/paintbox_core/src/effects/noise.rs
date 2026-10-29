//! Noise: Add Noise (Median and Reduce Noise slide a histogram and live
//! in `local`).

use std::sync::atomic::AtomicBool;

use super::{by_rows, Rng};
use crate::color::{clamp_u8, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// Normal noise of deviation `intensity² / 64`, its colour
/// spread around its own luma by `saturation` percent, on `coverage`
/// (0 – 1) of the pixels.
pub(super) fn add_noise(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    intensity: u32,
    saturation: u32,
    coverage: f64,
    seed: u64,
) -> Result<Surface> {
    let dev = (intensity * intensity / 4) as i64;
    let sat = (saturation * 4096 / 100) as i64;
    by_rows(rect, cancel, |y, line| {
        let mut rng = Rng::for_row(seed, y);
        for (i, o) in line.iter_mut().enumerate() {
            let p = src.at(rect.x + i as i32, y);
            if rng.unit() > coverage {
                *o = p;
                continue;
            }
            let (r, g, b) = (rng.normal(), rng.normal(), rng.normal());
            let lum = (4899 * r + 9618 * g + 1867 * b) >> 14;
            let tint = |c: i64| lum + (((c - lum) * sat) >> 12);
            let noisy =
                |s: u8, c: i64| clamp_u8((s as i64 + ((tint(c) * dev + 32768) >> 16)) as i32);
            *o = Rgba8::new(noisy(p.r, r), noisy(p.g, g), noisy(p.b, b), p.a);
        }
    })
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    #[test]
    fn add_noise_is_repeatable_and_respects_coverage() {
        let s = Surface::filled(64, 64, Rgba8::opaque(128, 128, 128)).unwrap();
        let fx = Effect::AddNoise {
            intensity: 64,
            saturation: 100,
            coverage: 100.0,
            seed: 7,
        };
        let a = render(fx, &s);
        assert_eq!(a, render(fx, &s));
        assert!(a.pixels().iter().filter(|p| p.r != 128).count() > 3000);
        let none = render(
            Effect::AddNoise {
                intensity: 64,
                saturation: 100,
                coverage: 0.0,
                seed: 7,
            },
            &s,
        );
        assert_eq!(none, s);
    }
}
