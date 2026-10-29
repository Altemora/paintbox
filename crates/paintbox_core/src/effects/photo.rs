//! Photo: Glow, Red Eye Removal, Soften Portrait (Sharpen slides a
//! histogram and lives in `local`). Glow and Soften Portrait are the
//! source's chains: a blur, Brightness / Contrast on it, then a blend
//! with the original.

use std::sync::atomic::AtomicBool;

use super::blurs::tent_blur;
use super::{by_pixels, clamp_byte, map_pixels};
use crate::adjust::brightness_contrast_table;
use crate::blend::{blend, BlendMode};
use crate::color::{clamp_u8, Rgba8};
use crate::error::{Error, Result};
use crate::geom::Rect;
use crate::surface::Surface;

/// The layer as Black and White does it (`UnaryPixelOps.Desaturate`).
pub(super) fn gray(p: Rgba8) -> Rgba8 {
    let i = p.intensity();
    Rgba8::new(i, i, i, p.a)
}

/// `rect` blurred by the Gaussian Blur effect, then through Brightness /
/// Contrast: the first half of Glow, Pencil Sketch, Soften Portrait.
pub(super) fn blurred_and_adjusted(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    brightness: i32,
    contrast: i32,
) -> Result<(Surface, impl Fn(Rgba8) -> Rgba8 + Sync)> {
    let blurred = tent_blur(src, rect, radius as usize, cancel).ok_or(Error::Cancelled)?;
    let table = brightness_contrast_table(brightness, contrast);
    Ok((blurred, move |p| table.apply(p)))
}

/// `GlowEffect`: the blurred, adjusted layer screened over the layer.
pub(super) fn glow(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    radius: u32,
    brightness: i32,
    contrast: i32,
) -> Result<Surface> {
    let (blurred, adjust) = blurred_and_adjusted(src, rect, cancel, radius, brightness, contrast)?;
    map_pixels(blurred, rect, cancel, |x, y, p| {
        blend(src.at(x, y), adjust(p), BlendMode::Screen, 255)
    })
}

/// `UnaryPixelOps.RedEyeRemove`: a saturated pixel whose red leads the
/// other channels by more than `tolerance` gets red equal to its
/// intensity times `saturation` percent.
pub(super) fn red_eye_removal(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    tolerance: u32,
    saturation: u32,
) -> Result<Surface> {
    let keep = saturation as f64 / 100.0;
    by_pixels(rect, cancel, |x, y| {
        let p = src.at(x, y);
        let (max, min) = (p.r.max(p.g).max(p.b), p.r.min(p.g).min(p.b));
        // HSV saturation 0 ..= 255, truncated as the source.
        let sat = if max == 0 || max == min {
            0
        } else {
            ((max - min) as f64 / max as f64 * 255.0) as i32
        };
        let lead = p.r as i32 - p.g.max(p.b) as i32;
        if lead > tolerance as i32 && sat > 100 {
            let intensity = (0.114 * p.b as f64 + 0.587 * p.g as f64 + 0.299 * p.r as f64) / 255.0;
            Rgba8::new(clamp_byte(255.0 * intensity * keep), p.g, p.b, p.a)
        } else {
            p
        }
    })
}

/// `SoftenPortraitEffect`: blurred by `3 · softness`, lit by
/// Brightness / Contrast (`lighting`, `−lighting / 2`), and overlaid
/// on the layer in grey warmed by `warmth` percent (more red, less
/// blue).
pub(super) fn soften_portrait(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    softness: u32,
    lighting: i32,
    warmth: u32,
) -> Result<Surface> {
    let (blurred, adjust) =
        blurred_and_adjusted(src, rect, cancel, softness * 3, lighting, -lighting / 2)?;
    let red = 1.0 + warmth as f32 / 100.0;
    let blue = 1.0 - warmth as f32 / 100.0;
    map_pixels(blurred, rect, cancel, |x, y, p| {
        let mut warm = gray(src.at(x, y));
        warm.r = clamp_u8((warm.r as f32 * red) as i32);
        warm.b = clamp_u8((warm.b as f32 * blue) as i32);
        blend(warm, adjust(p), BlendMode::Overlay, 255)
    })
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    #[test]
    fn glow_screens_the_blur_over_the_layer() {
        // Flat grey: the blur is the same grey, Brightness / Contrast
        // 0 / 0 keeps it, and screen of 100 over 100 is
        // 100 + 100 − 100·100/255 = 161.
        let s = Surface::filled(20, 20, Rgba8::opaque(100, 100, 100)).unwrap();
        let out = render(
            Effect::Glow {
                radius: 6,
                brightness: 0,
                contrast: 0,
            },
            &s,
        );
        assert!(all(&out, Rgba8::opaque(161, 161, 161)));
        // Glow never darkens.
        let v = varied(30, 20);
        let g = render(
            Effect::Glow {
                radius: 3,
                brightness: 10,
                contrast: 10,
            },
            &v,
        );
        assert!(g
            .pixels()
            .iter()
            .zip(v.pixels())
            .all(|(a, b)| a.r >= b.r && a.g >= b.g && a.b >= b.b));
    }

    #[test]
    fn red_eye_removal_touches_only_strong_red() {
        let mut s = Surface::filled(2, 1, Rgba8::opaque(200, 40, 30)).unwrap();
        s.set(1, 0, Rgba8::opaque(120, 100, 90));
        let out = render(
            Effect::RedEyeRemoval {
                tolerance: 70,
                saturation: 90,
            },
            &s,
        );
        // Red leads by 160 and saturation is 216: red becomes
        // 255 · (0.114·30 + 0.587·40 + 0.299·200)/255 · 0.9 = 78.
        assert_eq!(out.at(0, 0), Rgba8::opaque(78, 40, 30));
        assert_eq!(out.at(1, 0), Rgba8::opaque(120, 100, 90));
    }

    #[test]
    fn soften_portrait_of_flat_grey_at_zero() {
        // Softness 0 is no blur; lighting 0 no change; warmth 0 keeps the
        // grey: overlay of 128 on 128 is 255 − 254·127/255 = 128.
        let s = Surface::filled(8, 8, Rgba8::opaque(128, 128, 128)).unwrap();
        let out = render(
            Effect::SoftenPortrait {
                softness: 0,
                lighting: 0,
                warmth: 0,
            },
            &s,
        );
        assert!(all(&out, Rgba8::opaque(128, 128, 128)));
        // Warmth lifts red over blue.
        let warm = render(
            Effect::SoftenPortrait {
                softness: 5,
                lighting: 0,
                warmth: 20,
            },
            &s,
        );
        let p = warm.at(4, 4);
        assert!(p.r > p.g && p.g > p.b, "{p:?}");
    }
}
