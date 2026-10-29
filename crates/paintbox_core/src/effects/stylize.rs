//! Stylize: Emboss, Edge Detect and Relief, 3 × 3 kernels of
//! `cos(angle + k · 45°)` (Outline slides a histogram and lives in
//! `local`).

use std::sync::atomic::AtomicBool;

use super::by_pixels;
use crate::color::{clamp_u8, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// The kernel of Emboss, Edge Detect and Relief: `cos(angle + k · 45°)`
/// around a centre of 0.
fn direction_kernel(angle: f64) -> [[f64; 3]; 3] {
    let r = angle.to_radians();
    let dr = std::f64::consts::FRAC_PI_4;
    [
        [(r + dr).cos(), (r + 2.0 * dr).cos(), (r + 3.0 * dr).cos()],
        [r.cos(), 0.0, (r + 4.0 * dr).cos()],
        [(r - dr).cos(), (r - 2.0 * dr).cos(), (r - 3.0 * dr).cos()],
    ]
}

/// The kernel over the pixel's 3 × 3 neighbours inside the picture.
fn convolve(src: &Surface, x: i32, y: i32, k: &[[f64; 3]; 3], mut tap: impl FnMut(f64, Rgba8)) {
    let (w, h) = (src.width() as i32, src.height() as i32);
    for (fy, row) in k.iter().enumerate() {
        for (fx, &weight) in row.iter().enumerate() {
            let (sx, sy) = (x - 1 + fx as i32, y - 1 + fy as i32);
            if sx >= 0 && sy >= 0 && sx < w && sy < h {
                tap(weight, src.at(sx, sy));
            }
        }
    }
}

/// The kernel over intensity, plus 128: grey and opaque.
pub(super) fn emboss(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    angle: f64,
) -> Result<Surface> {
    let k = direction_kernel(angle);
    by_pixels(rect, cancel, |x, y| {
        let mut sum = 0.0;
        convolve(src, x, y, &k, |weight, p| {
            sum += weight * p.intensity() as f64
        });
        let v = clamp_u8(sum as i32 + 128);
        Rgba8::opaque(v, v, v)
    })
}

/// `ColorDifferenceEffect`: the kernel over each of red, green and blue,
/// truncated and opaque.
fn color_difference(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    k: [[f64; 3]; 3],
) -> Result<Surface> {
    by_pixels(rect, cancel, |x, y| {
        let mut sums = [0.0f64; 3];
        convolve(src, x, y, &k, |weight, p| {
            sums[0] += weight * p.r as f64;
            sums[1] += weight * p.g as f64;
            sums[2] += weight * p.b as f64;
        });
        Rgba8::opaque(
            clamp_u8(sums[0] as i32),
            clamp_u8(sums[1] as i32),
            clamp_u8(sums[2] as i32),
        )
    })
}

pub(super) fn edge_detect(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    angle: f64,
) -> Result<Surface> {
    color_difference(src, rect, cancel, direction_kernel(angle))
}

/// `ReliefEffect`: Edge Detect's kernel with the pixel itself kept
/// (centre 1), so the picture stays under its embossed edges.
pub(super) fn relief(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    angle: f64,
) -> Result<Surface> {
    let mut k = direction_kernel(angle);
    k[1][1] = 1.0;
    color_difference(src, rect, cancel, k)
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    #[test]
    fn emboss_and_edge_detect_of_flat_areas() {
        let s = Surface::filled(5, 5, Rgba8::opaque(90, 90, 90)).unwrap();
        let e = render(Effect::Emboss { angle: 0.0 }, &s);
        assert_eq!(e.at(2, 2), Rgba8::opaque(128, 128, 128));
        let d = render(Effect::EdgeDetect { angle: 45.0 }, &s);
        assert!(d.at(2, 2).r <= 1);
    }

    #[test]
    fn relief_keeps_flats_and_lights_edges_by_the_angle() {
        // The eight weights cancel out, so inside a flat area only the
        // centre's 1 is left (less a rounding step from the truncation).
        let flat = Rgba8::opaque(90, 120, 150);
        let s = Surface::filled(7, 7, flat).unwrap();
        let out = render(Effect::Relief { angle: 45.0 }, &s);
        assert!(close(out.at(3, 3), flat, 1));
        // A bright left half: at angle 0 the left column weighs
        // cos 45°, cos 0°, cos −45° and the right one the negatives.
        let mut edge = Surface::filled(8, 3, Rgba8::opaque(50, 50, 50)).unwrap();
        for y in 0..3 {
            for x in 0..4 {
                edge.set(x, y, Rgba8::opaque(150, 150, 150));
            }
        }
        let out = render(Effect::Relief { angle: 0.0 }, &edge);
        // At (4, 1): 150·2.414 (left column) + 50 (the pixel)
        // − 50·2.414 (right column) = 291 → 255.
        assert_eq!(out.at(4, 1).r, 255);
        // Inside the bright area the columns cancel: 150.
        assert!(close(out.at(1, 1), Rgba8::opaque(150, 150, 150), 1));
    }
}
