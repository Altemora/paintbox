//! Artistic: Ink Sketch, Oil Painting, Pencil Sketch.

use std::sync::atomic::AtomicBool;

use super::photo::{blurred_and_adjusted, glow, gray};
use super::{by_rows, map_pixels};
use crate::blend::{blend, BlendMode};
use crate::color::{clamp_u8, Rgba8};
use crate::error::Result;
use crate::geom::Rect;
use crate::surface::Surface;

/// In the square `2·size + 1` the pixels go into `coarseness + 1` bins
/// by intensity; the result is the average colour of the fullest bin.
pub(super) fn oil_painting(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    brush_size: u32,
    coarseness: u32,
) -> Result<Surface> {
    let size = brush_size as i32;
    let bins = coarseness as usize + 1;
    let (w, h) = (src.width() as i32, src.height() as i32);
    by_rows(rect, cancel, |y, line| {
        let mut count = vec![0u32; bins];
        let mut sums = vec![[0u32; 4]; bins];
        let (top, bottom) = ((y - size).max(0), (y + size + 1).min(h));
        for (i, out) in line.iter_mut().enumerate() {
            let x = rect.x + i as i32;
            count.fill(0);
            sums.fill([0; 4]);
            for sy in top..bottom {
                for sx in (x - size).max(0)..(x + size + 1).min(w) {
                    let p = src.at(sx, sy);
                    let bin = crate::color::mul255(p.intensity() as u32, coarseness) as usize;
                    count[bin] += 1;
                    let s = &mut sums[bin];
                    s[0] += p.r as u32;
                    s[1] += p.g as u32;
                    s[2] += p.b as u32;
                    s[3] += p.a as u32;
                }
            }
            let (mut best, mut most) = (0, 0);
            for (bin, &n) in count.iter().enumerate() {
                if n > most {
                    best = bin;
                    most = n;
                }
            }
            let s = sums[best];
            let most = most.max(1);
            *out = Rgba8::new(
                (s[0] / most) as u8,
                (s[1] / most) as u8,
                (s[2] / most) as u8,
                (s[3] / most) as u8,
            );
        }
    })
}

/// `InkSketchEffect`'s edge kernel: a sharp centre against a dark
/// surround, a little heavier below.
const INK_KERNEL: [[i32; 5]; 5] = [
    [-1, -1, -1, -1, -1],
    [-1, -1, -1, -1, -1],
    [-1, -1, 30, -1, -1],
    [-1, -1, -1, -1, -1],
    [-1, -1, -5, -1, -1],
];

/// `InkSketchEffect`: Glow (radius 6, brightness and contrast
/// `−(coloring − 50)·2`) for the colour, darkened by black ink where the
/// edge kernel's grey falls to `ink_outline` percent or below.
pub(super) fn ink_sketch(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    ink_outline: u32,
    coloring: u32,
) -> Result<Surface> {
    let tone = -(coloring as i32 - 50) * 2;
    let colour = glow(src, rect, cancel, 6, tone, tone)?;
    let threshold = (ink_outline * 255 / 100) as u8;
    let (w, h) = (src.width() as i32, src.height() as i32);
    map_pixels(colour, rect, cancel, |x, y, c| {
        let mut sums = [0i32; 3];
        for (j, row) in INK_KERNEL.iter().enumerate() {
            let sy = y + j as i32 - 2;
            if sy < 0 || sy >= h {
                continue;
            }
            for (i, &k) in row.iter().enumerate() {
                let sx = x + i as i32 - 2;
                if sx >= 0 && sx < w {
                    let p = src.at(sx, sy);
                    sums[0] += p.r as i32 * k;
                    sums[1] += p.g as i32 * k;
                    sums[2] += p.b as i32 * k;
                }
            }
        }
        let edge = gray(Rgba8::opaque(
            clamp_u8(sums[0]),
            clamp_u8(sums[1]),
            clamp_u8(sums[2]),
        ));
        let ink = if edge.r > threshold {
            Rgba8::WHITE
        } else {
            Rgba8::BLACK
        };
        blend(ink, c, BlendMode::Darken, 255)
    })
}

/// `PencilSketchEffect`: the layer blurred by the tip size, through
/// Brightness / Contrast (`range`, `−range`), inverted and grey,
/// colour-dodged onto the grey layer: flat areas go white, edges stay.
pub(super) fn pencil_sketch(
    src: &Surface,
    rect: Rect,
    cancel: &AtomicBool,
    tip_size: u32,
    color_range: i32,
) -> Result<Surface> {
    let (blurred, adjust) =
        blurred_and_adjusted(src, rect, cancel, tip_size, color_range, -color_range)?;
    map_pixels(blurred, rect, cancel, |x, y, p| {
        let p = adjust(p);
        let inverted = gray(Rgba8::new(255 - p.r, 255 - p.g, 255 - p.b, p.a));
        blend(gray(src.at(x, y)), inverted, BlendMode::ColorDodge, 255)
    })
}

#[cfg(test)]
mod tests {
    use super::super::testing::*;
    use super::super::Effect;
    use super::*;

    #[test]
    fn oil_painting_keeps_flat_colour_and_picks_the_majority() {
        let mut s = Surface::filled(7, 7, Rgba8::opaque(200, 10, 10)).unwrap();
        s.set(3, 3, Rgba8::opaque(0, 0, 250));
        let o = render(
            Effect::OilPainting {
                brush_size: 2,
                coarseness: 50,
            },
            &s,
        );
        assert_eq!(o.at(3, 3), Rgba8::opaque(200, 10, 10));
    }

    #[test]
    fn ink_sketch_inks_dark_flats_and_glows_light_ones() {
        let sketch = Effect::InkSketch {
            ink_outline: 50,
            coloring: 50,
        };
        // Grey 100: the kernel sums to 2, so the edge grey is 200, above
        // 127: no ink, and the glow (screen of 100 on 100) is 161.
        let light = Surface::filled(12, 12, Rgba8::opaque(100, 100, 100)).unwrap();
        assert_eq!(
            render(sketch, &light).at(6, 6),
            Rgba8::opaque(161, 161, 161)
        );
        // Grey 50: the edge grey is 100, inked black.
        let dark = Surface::filled(12, 12, Rgba8::opaque(50, 50, 50)).unwrap();
        assert_eq!(render(sketch, &dark).at(6, 6), Rgba8::BLACK);
    }

    #[test]
    fn pencil_sketch_whitens_flats_and_draws_edges() {
        let sketch = Effect::PencilSketch {
            tip_size: 2,
            color_range: 0,
        };
        // Flat v: dodge of v by 255 − v is v·255 / v = white.
        let flat = Surface::filled(10, 10, Rgba8::opaque(90, 90, 90)).unwrap();
        assert!(all(&render(sketch, &flat), Rgba8::WHITE));
        let mut edge = Surface::filled(20, 10, Rgba8::opaque(200, 200, 200)).unwrap();
        for y in 0..10 {
            for x in 10..20 {
                edge.set(x, y, Rgba8::opaque(40, 40, 40));
            }
        }
        let out = render(sketch, &edge);
        assert_eq!(out.at(2, 5), Rgba8::WHITE);
        assert!(out.at(10, 5).r < 200, "{:?}", out.at(10, 5));
    }
}
