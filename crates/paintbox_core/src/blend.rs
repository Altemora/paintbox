//! Layer blend modes, ported from Paint.NET's `UserBlendOps` (macro
//! `BLEND` in `UserBlendOps.Generated.H.cs`) in straight alpha with the
//! same integer rounding.

use serde::{Deserialize, Serialize};

use crate::color::{mul255, Rgba8};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Default, Serialize, Deserialize)]
pub enum BlendMode {
    #[default]
    Normal,
    Multiply,
    Additive,
    ColorBurn,
    ColorDodge,
    Reflect,
    Glow,
    Overlay,
    Difference,
    Negation,
    Lighten,
    Darken,
    Screen,
    Xor,
}

impl BlendMode {
    /// In the order of Paint.NET's Layer Properties list.
    pub const ALL: [BlendMode; 14] = [
        BlendMode::Normal,
        BlendMode::Multiply,
        BlendMode::Additive,
        BlendMode::ColorBurn,
        BlendMode::ColorDodge,
        BlendMode::Reflect,
        BlendMode::Glow,
        BlendMode::Overlay,
        BlendMode::Difference,
        BlendMode::Negation,
        BlendMode::Lighten,
        BlendMode::Darken,
        BlendMode::Screen,
        BlendMode::Xor,
    ];

    /// The English display name.
    pub fn name(self) -> &'static str {
        match self {
            BlendMode::Normal => "Normal",
            BlendMode::Multiply => "Multiply",
            BlendMode::Additive => "Additive",
            BlendMode::ColorBurn => "Color Burn",
            BlendMode::ColorDodge => "Color Dodge",
            BlendMode::Reflect => "Reflect",
            BlendMode::Glow => "Glow",
            BlendMode::Overlay => "Overlay",
            BlendMode::Difference => "Difference",
            BlendMode::Negation => "Negation",
            BlendMode::Lighten => "Lighten",
            BlendMode::Darken => "Darken",
            BlendMode::Screen => "Screen",
            BlendMode::Xor => "Xor",
        }
    }

    /// The channel function `F(A, B)`: `a` the lower pixel, `b` the
    /// layer's.
    #[inline]
    pub fn channel(self, a: u32, b: u32) -> u32 {
        match self {
            BlendMode::Normal => b,
            BlendMode::Multiply => mul255(a, b),
            BlendMode::Additive => (a + b).min(255),
            BlendMode::ColorBurn => {
                // B = 0 burns to black.
                ((255 - a) * 255)
                    .checked_div(b)
                    .map_or(0, |q| 255u32.saturating_sub(q))
            }
            BlendMode::ColorDodge => dodge(a, b),
            BlendMode::Reflect => reflect(a, b),
            BlendMode::Glow => reflect(b, a),
            BlendMode::Overlay => {
                if a < 128 {
                    mul255(2 * a, b)
                } else {
                    255 - mul255(2 * (255 - a), 255 - b)
                }
            }
            BlendMode::Difference => a.abs_diff(b),
            BlendMode::Negation => 255 - (255i32 - a as i32 - b as i32).unsigned_abs(),
            BlendMode::Lighten => a.max(b),
            BlendMode::Darken => a.min(b),
            BlendMode::Screen => a + b - mul255(b, a),
            BlendMode::Xor => a ^ b,
        }
    }
}

#[inline]
fn dodge(a: u32, b: u32) -> u32 {
    if b == 255 {
        255
    } else {
        (a * 255 / (255 - b)).min(255)
    }
}

#[inline]
fn reflect(a: u32, b: u32) -> u32 {
    if b == 255 {
        255
    } else {
        (a * a / (255 - b)).min(255)
    }
}

/// `top` over `bottom` with `mode`, the top's alpha scaled by
/// `opacity` first.
#[inline]
pub fn blend(bottom: Rgba8, top: Rgba8, mode: BlendMode, opacity: u8) -> Rgba8 {
    let lhs_a = bottom.a as u32;
    let rhs_a = if opacity == 255 {
        top.a as u32
    } else {
        mul255(top.a as u32, opacity as u32)
    };
    if rhs_a == 0 {
        // Nothing over nothing is transparent black, as the source.
        return if lhs_a == 0 {
            Rgba8::TRANSPARENT
        } else {
            bottom
        };
    }
    if rhs_a == 255 && mode == BlendMode::Normal {
        return top.with_alpha(255);
    }
    let y = mul255(lhs_a, 255 - rhs_a);
    let total = y + rhs_a;
    if total == 0 {
        return Rgba8::TRANSPARENT;
    }
    let x = mul255(lhs_a, rhs_a);
    let z = rhs_a - x;
    let mix = |l: u8, r: u8| {
        let f = mode.channel(l as u32, r as u32);
        ((l as u32 * y + r as u32 * z + f * x) / total) as u8
    };
    Rgba8::new(
        mix(bottom.r, top.r),
        mix(bottom.g, top.g),
        mix(bottom.b, top.b),
        total as u8,
    )
}

/// Normal blending with full opacity: what tools use with Alpha
/// Blending on.
#[inline]
pub fn over(bottom: Rgba8, top: Rgba8) -> Rgba8 {
    blend(bottom, top, BlendMode::Normal, 255)
}

pub(crate) fn blend_row(bottom: &mut [Rgba8], top: &[Rgba8], mode: BlendMode, opacity: u8) {
    if opacity == 0 {
        return;
    }
    for (b, t) in bottom.iter_mut().zip(top) {
        *b = blend(*b, *t, mode, opacity);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The W3C separable compositing formula in floats, which the
    /// source's integer `BLEND` approximates.
    fn reference(bottom: Rgba8, top: Rgba8, f: impl Fn(f64, f64) -> f64) -> Rgba8 {
        let ab = bottom.a as f64 / 255.0;
        let at = top.a as f64 / 255.0;
        let a = at + ab * (1.0 - at);
        let ch = |cb: u8, ct: u8| {
            let (cb, ct) = (cb as f64 / 255.0, ct as f64 / 255.0);
            let mixed = (1.0 - ab) * at * ct + ab * (1.0 - at) * cb + ab * at * f(cb, ct);
            (mixed / a * 255.0).round() as u8
        };
        Rgba8::new(
            ch(bottom.r, top.r),
            ch(bottom.g, top.g),
            ch(bottom.b, top.b),
            (a * 255.0).round() as u8,
        )
    }

    fn close(a: Rgba8, b: Rgba8) -> bool {
        [(a.r, b.r), (a.g, b.g), (a.b, b.b), (a.a, b.a)]
            .iter()
            .all(|(x, y)| x.abs_diff(*y) <= 2)
    }

    const BOTTOM: Rgba8 = Rgba8::new(200, 100, 30, 180);
    const TOP: Rgba8 = Rgba8::new(60, 220, 140, 150);

    #[test]
    fn separable_modes_match_the_float_formula() {
        type Case = (BlendMode, fn(f64, f64) -> f64);
        let cases: [Case; 9] = [
            (BlendMode::Normal, |_, b| b),
            (BlendMode::Multiply, |a, b| a * b),
            (BlendMode::Additive, |a, b| (a + b).min(1.0)),
            (BlendMode::Screen, |a, b| a + b - a * b),
            (BlendMode::Lighten, |a, b| a.max(b)),
            (BlendMode::Darken, |a, b| a.min(b)),
            (BlendMode::Difference, |a, b| (a - b).abs()),
            (BlendMode::Negation, |a, b| 1.0 - (1.0 - a - b).abs()),
            (BlendMode::Overlay, |a, b| {
                if a < 0.5 {
                    2.0 * a * b
                } else {
                    1.0 - 2.0 * (1.0 - a) * (1.0 - b)
                }
            }),
        ];
        for (mode, f) in cases {
            let got = blend(BOTTOM, TOP, mode, 255);
            let want = reference(BOTTOM, TOP, f);
            assert!(close(got, want), "{mode:?}: {got:?} vs {want:?}");
        }
    }

    #[test]
    fn division_modes_follow_the_source() {
        assert_eq!(BlendMode::ColorBurn.channel(100, 0), 0);
        assert_eq!(
            BlendMode::ColorBurn.channel(100, 200),
            255 - 155 * 255 / 200
        );
        assert_eq!(BlendMode::ColorBurn.channel(0, 50), 0);
        assert_eq!(BlendMode::ColorDodge.channel(100, 255), 255);
        assert_eq!(BlendMode::ColorDodge.channel(100, 100), 100 * 255 / 155);
        assert_eq!(BlendMode::Reflect.channel(100, 100), 10000 / 155);
        assert_eq!(
            BlendMode::Glow.channel(100, 50),
            BlendMode::Reflect.channel(50, 100)
        );
        assert_eq!(BlendMode::Xor.channel(0b1100, 0b1010), 0b0110);
    }

    #[test]
    fn opaque_normal_replaces_and_transparent_top_keeps() {
        assert_eq!(
            blend(BOTTOM, Rgba8::opaque(1, 2, 3), BlendMode::Normal, 255),
            Rgba8::opaque(1, 2, 3)
        );
        assert_eq!(
            blend(BOTTOM, TOP.with_alpha(0), BlendMode::Multiply, 255),
            BOTTOM
        );
        assert_eq!(blend(BOTTOM, TOP, BlendMode::Screen, 0), BOTTOM);
    }

    #[test]
    fn over_transparent_gives_the_top_and_opacity_scales_alpha() {
        let got = blend(Rgba8::TRANSPARENT, TOP, BlendMode::Multiply, 255);
        assert_eq!(got, TOP);
        let half = blend(
            Rgba8::TRANSPARENT,
            Rgba8::opaque(10, 20, 30),
            BlendMode::Normal,
            128,
        );
        assert_eq!(half, Rgba8::new(10, 20, 30, 128));
    }

    #[test]
    fn multiply_on_opaque_white_is_identity() {
        let got = blend(
            Rgba8::WHITE,
            Rgba8::opaque(10, 120, 250),
            BlendMode::Multiply,
            255,
        );
        assert_eq!(got, Rgba8::opaque(10, 120, 250));
    }
}
