//! Straight (not premultiplied) RGBA8, as Paint.NET's `ColorBgra`: the
//! blend formulas and adjustments of the source work on these values
//! unchanged, and PNG and OpenRaster store them as they are.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Hash, Serialize, Deserialize)]
pub struct Rgba8 {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Rgba8 {
    pub const TRANSPARENT: Rgba8 = Rgba8::new(0, 0, 0, 0);
    pub const BLACK: Rgba8 = Rgba8::new(0, 0, 0, 255);
    pub const WHITE: Rgba8 = Rgba8::new(255, 255, 255, 255);
    /// What Erase Selection and Crop leave behind in Paint.NET.
    pub const CLEARED: Rgba8 = Rgba8::new(255, 255, 255, 0);

    pub const fn new(r: u8, g: u8, b: u8, a: u8) -> Self {
        Self { r, g, b, a }
    }

    pub const fn opaque(r: u8, g: u8, b: u8) -> Self {
        Self::new(r, g, b, 255)
    }

    pub const fn with_alpha(self, a: u8) -> Self {
        Self::new(self.r, self.g, self.b, a)
    }

    /// Luma as Paint.NET's `GetIntensityByte`.
    pub fn intensity(self) -> u8 {
        ((7471 * self.b as u32 + 38470 * self.g as u32 + 19595 * self.r as u32) >> 16) as u8
    }

    /// `AARRGGBB` as in Paint.NET palette files.
    pub fn to_argb_hex(self) -> String {
        format!("{:02X}{:02X}{:02X}{:02X}", self.a, self.r, self.g, self.b)
    }

    /// Reads `AARRGGBB` or `RRGGBB`; six digits mean alpha 0, as the
    /// source parses them.
    pub fn from_argb_hex(text: &str) -> Option<Rgba8> {
        let text = text.trim().trim_start_matches('#');
        let value = u32::from_str_radix(text, 16).ok()?;
        match text.len() {
            8 => Some(Rgba8::new(
                (value >> 16) as u8,
                (value >> 8) as u8,
                value as u8,
                (value >> 24) as u8,
            )),
            6 => Some(Rgba8::new(
                (value >> 16) as u8,
                (value >> 8) as u8,
                value as u8,
                0,
            )),
            _ => None,
        }
    }
}

/// `a * b / 255` rounded, Paint.NET's `INT_SCALE`.
#[inline]
pub fn mul255(a: u32, b: u32) -> u32 {
    let r = a * b + 0x80;
    ((r >> 8) + r) >> 8
}

#[inline]
pub fn clamp_u8(value: i32) -> u8 {
    value.clamp(0, 255) as u8
}

/// `a + (b - a) * t / 255` per channel including alpha: masks and
/// coverage (a straight mix, not alpha-weighted).
pub fn lerp(a: Rgba8, b: Rgba8, t: u8) -> Rgba8 {
    let t = t as i32;
    let mix = |x: u8, y: u8| (x as i32 + ((y as i32 - x as i32) * t) / 255) as u8;
    Rgba8::new(mix(a.r, b.r), mix(a.g, b.g), mix(a.b, b.b), mix(a.a, b.a))
}

/// `ColorBgra.Blend(a, b, t)`: `t / 255` of the way from `a` to `b`,
/// the colour weighted by each side's alpha so a transparent end does
/// not darken the other (gradient colours).
pub fn blend_toward(a: Rgba8, b: Rgba8, t: u8) -> Rgba8 {
    let wa = mul255(255 - t as u32, a.a as u32);
    let wb = mul255(t as u32, b.a as u32);
    let total = wa + wb;
    if total == 0 {
        return Rgba8::TRANSPARENT;
    }
    let mix = |x: u8, y: u8| ((x as u32 * wa + y as u32 * wb) / total) as u8;
    Rgba8::new(mix(a.r, b.r), mix(a.g, b.g), mix(a.b, b.b), total as u8)
}

/// Alpha-weighted average, as `ColorBgra.Blend(colors, count)`:
/// transparent samples do not darken the colour.
pub fn average(colors: &[Rgba8]) -> Rgba8 {
    let mut sums = [0u64; 4];
    for c in colors {
        let a = c.a as u64;
        sums[0] += c.r as u64 * a;
        sums[1] += c.g as u64 * a;
        sums[2] += c.b as u64 * a;
        sums[3] += a;
    }
    weighted(sums, colors.len() as u64)
}

/// The colour from premultiplied sums `[r·a, g·a, b·a, a]` over `count`
/// equally weighted samples.
pub(crate) fn weighted(sums: [u64; 4], count: u64) -> Rgba8 {
    if count == 0 || sums[3] == 0 {
        return Rgba8::TRANSPARENT;
    }
    let a = sums[3];
    Rgba8::new(
        ((sums[0] + a / 2) / a).min(255) as u8,
        ((sums[1] + a / 2) / a).min(255) as u8,
        ((sums[2] + a / 2) / a).min(255) as u8,
        ((a + count / 2) / count).min(255) as u8,
    )
}

/// Hue in degrees `[0, 360)`, saturation and value in `[0, 1]`.
pub fn to_hsv(c: Rgba8) -> (f32, f32, f32) {
    let r = c.r as f32 / 255.0;
    let g = c.g as f32 / 255.0;
    let b = c.b as f32 / 255.0;
    let max = r.max(g).max(b);
    let min = r.min(g).min(b);
    let delta = max - min;
    let hue = if delta == 0.0 {
        0.0
    } else if max == r {
        60.0 * ((g - b) / delta).rem_euclid(6.0)
    } else if max == g {
        60.0 * ((b - r) / delta + 2.0)
    } else {
        60.0 * ((r - g) / delta + 4.0)
    };
    let saturation = if max == 0.0 { 0.0 } else { delta / max };
    (hue, saturation, max)
}

pub fn from_hsv(hue: f32, saturation: f32, value: f32, alpha: u8) -> Rgba8 {
    let h = hue.rem_euclid(360.0) / 60.0;
    let c = value * saturation;
    let x = c * (1.0 - (h % 2.0 - 1.0).abs());
    let (r, g, b) = match h as u32 {
        0 => (c, x, 0.0),
        1 => (x, c, 0.0),
        2 => (0.0, c, x),
        3 => (0.0, x, c),
        4 => (x, 0.0, c),
        _ => (c, 0.0, x),
    };
    let m = value - c;
    let to = |v: f32| ((v + m) * 255.0).round().clamp(0.0, 255.0) as u8;
    Rgba8::new(to(r), to(g), to(b), alpha)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn hex_round_trip_and_six_digits_mean_alpha_zero() {
        let c = Rgba8::new(0x12, 0x34, 0x56, 0x78);
        assert_eq!(c.to_argb_hex(), "78123456");
        assert_eq!(Rgba8::from_argb_hex("78123456"), Some(c));
        assert_eq!(
            Rgba8::from_argb_hex("123456"),
            Some(Rgba8::new(0x12, 0x34, 0x56, 0))
        );
        assert_eq!(Rgba8::from_argb_hex("xyz"), None);
    }

    #[test]
    fn intensity_matches_the_source_weights() {
        assert_eq!(Rgba8::WHITE.intensity(), 255);
        assert_eq!(Rgba8::opaque(255, 0, 0).intensity(), 76);
        assert_eq!(Rgba8::opaque(0, 255, 0).intensity(), 149);
    }

    #[test]
    fn hsv_round_trips() {
        for c in [
            Rgba8::opaque(200, 30, 90),
            Rgba8::opaque(10, 250, 40),
            Rgba8::opaque(1, 2, 3),
        ] {
            let (h, s, v) = to_hsv(c);
            assert_eq!(from_hsv(h, s, v, 255), c);
        }
    }

    #[test]
    fn average_ignores_transparent_colour() {
        let avg = average(&[Rgba8::opaque(200, 0, 0), Rgba8::new(0, 0, 255, 0)]);
        assert_eq!((avg.r, avg.b, avg.a), (200, 0, 128));
    }
}
