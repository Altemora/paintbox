//! The Effects menu, ported from Paint.NET 3.36's effects. An effect
//! renders a rectangle of the layer from the whole layer (it reads
//! neighbours outside the rectangle); the document blends the result in
//! by the selection's coverage.
//!
//! Effects with a centre (Bulge, Twist, the zoom and radial blurs, the
//! fractals, Clouds) centre on the whole layer, as the source does; the
//! warps of the source's `WarpEffectBase` (Dents, Polar Inversion)
//! centre on the selection's bounds and size their radius by them.

mod artistic;
mod blurs;
mod distort;
mod local;
mod noise;
mod photo;
mod render;
mod stylize;

use std::sync::atomic::{AtomicBool, Ordering};

use serde::{Deserialize, Serialize};

use crate::color::{lerp, Rgba8};
use crate::document::Document;
use crate::error::{invalid, Error, Result};
use crate::geom::Rect;
use crate::parallel::for_rows;
use crate::surface::Surface;

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum Effect {
    /// Radius 0 ..= 200 (default 2).
    GaussianBlur { radius: u32 },
    /// Angle −180 ..= 180 (25), distance 1 ..= 200 (10), centred (yes).
    MotionBlur {
        angle: f64,
        distance: u32,
        centered: bool,
    },
    /// Amount 1 ..= 20 (2).
    Sharpen { amount: u32 },
    /// Intensity 0 ..= 100 (64), colour saturation 0 ..= 400 (100),
    /// coverage 0 ..= 100 (100); the seed makes the noise repeatable.
    AddNoise {
        intensity: u32,
        saturation: u32,
        coverage: f64,
        seed: u64,
    },
    /// Radius 1 ..= 200 (10), percentile 0 ..= 100 (50).
    Median { radius: u32, percentile: u32 },
    /// Cell size 1 ..= 100 (2).
    Pixelate { cell_size: u32 },
    /// Brush size 1 ..= 8 (3), coarseness 3 ..= 255 (50).
    OilPainting { brush_size: u32, coarseness: u32 },
    /// Angle −180 ..= 180 (0).
    Emboss { angle: f64 },
    /// Angle −180 ..= 180 (45).
    EdgeDetect { angle: f64 },
    /// Thickness 1 ..= 200 (3), intensity 0 ..= 100 (50).
    Outline { thickness: u32, intensity: u32 },
    /// Ink outline 0 ..= 99 (50), coloring 0 ..= 100 (50).
    InkSketch { ink_outline: u32, coloring: u32 },
    /// Pencil tip size 1 ..= 20 (2), colour range −20 ..= 20 (0).
    PencilSketch { tip_size: u32, color_range: i32 },
    /// Fragments 2 ..= 50 (4), distance 0 ..= 100 (8), rotation
    /// 0 ..= 360 (0).
    Fragment {
        fragments: u32,
        distance: u32,
        rotation: f64,
    },
    /// Angle 0 ..= 360 (2), centre offset −2 ..= 2 of the half-size
    /// (0, 0), quality 1 ..= 5 (2).
    RadialBlur {
        angle: f64,
        offset_x: f64,
        offset_y: f64,
        quality: u32,
    },
    /// Radius 1 ..= 100 (6), threshold 1 ..= 100 (15).
    SurfaceBlur { radius: u32, threshold: u32 },
    /// Radius 1 ..= 200 (4).
    Unfocus { radius: u32 },
    /// Amount 0 ..= 100 (10), centre offset −2 ..= 2 (0, 0).
    ZoomBlur {
        amount: u32,
        offset_x: f64,
        offset_y: f64,
    },
    /// Amount −200 ..= 100 (45), centre offset −1 ..= 1 (0, 0).
    Bulge {
        amount: i32,
        offset_x: f64,
        offset_y: f64,
    },
    /// Scale 1 ..= 200 (25), refraction 0 ..= 200 (50), roughness
    /// 0 ..= 100 (10), tension 0 ..= 100 (10), quality 1 ..= 5 (2).
    Dents {
        scale: f64,
        refraction: f64,
        roughness: f64,
        tension: f64,
        quality: u32,
        seed: u64,
    },
    /// Scatter radii 0 ..= 200 (maximum 3, minimum 0), samples 1 ..= 8
    /// (2). The source scatters at random each time; here by the seed.
    FrostedGlass {
        max_scatter: f64,
        min_scatter: f64,
        samples: u32,
        seed: u64,
    },
    /// Amount −4 ..= 4 (1), centre offset −2 ..= 2 (0, 0), edge
    /// behaviour 0 clamp, 1 reflect, 2 wrap (2), quality 1 ..= 5 (2).
    PolarInversion {
        amount: f64,
        offset_x: f64,
        offset_y: f64,
        edge_behavior: u32,
        quality: u32,
    },
    /// Rotation −180 ..= 180 (30), tile size 1 ..= 800 (40), curvature
    /// −100 ..= 100 (8), quality 1 ..= 5 (2).
    TileReflection {
        rotation: f64,
        tile_size: f64,
        curvature: f64,
        quality: u32,
    },
    /// Amount −200 ..= 200 (30), size 0.01 ..= 2 (1), centre offset
    /// −2 ..= 2 (0, 0), quality 1 ..= 5 (2).
    Twist {
        amount: f64,
        size: f64,
        offset_x: f64,
        offset_y: f64,
        quality: u32,
    },
    /// Radius 0 ..= 200 (10), strength 0 ..= 1 (0.4).
    ReduceNoise { radius: u32, strength: f64 },
    /// Radius 1 ..= 20 (6), brightness and contrast −100 ..= 100 (10, 10).
    Glow {
        radius: u32,
        brightness: i32,
        contrast: i32,
    },
    /// Tolerance 0 ..= 100 (70), saturation percentage 0 ..= 100 (90).
    RedEyeRemoval { tolerance: u32, saturation: u32 },
    /// Softness 0 ..= 10 (5), lighting −20 ..= 20 (0), warmth 0 ..= 20
    /// (10).
    SoftenPortrait {
        softness: u32,
        lighting: i32,
        warmth: u32,
    },
    /// Scale 2 ..= 1000 (250), power 0 ..= 1 (0.5; the dialog's
    /// "Roughness"), blend mode an index into [`BlendMode::ALL`]
    /// (0, Normal).
    ///
    /// The source draws the noise from the primary to the secondary
    /// colour; an effect does not see the user's colours, so this one
    /// draws black to white (Paint.NET's default colours) and the blend
    /// mode puts it over the layer.
    ///
    /// [`BlendMode::ALL`]: crate::blend::BlendMode::ALL
    Clouds {
        scale: u32,
        power: f64,
        blend_mode: u32,
        seed: u64,
    },
    /// Factor 1 ..= 10 (4), zoom 0.1 ..= 50 (1), angle −180 ..= 180 (0),
    /// quality 1 ..= 5 (2).
    JuliaFractal {
        factor: f64,
        zoom: f64,
        angle: f64,
        quality: u32,
    },
    /// Factor 1 ..= 10 (1), zoom 0 ..= 100 (10), angle −180 ..= 180 (0),
    /// quality 1 ..= 5 (2), invert colours (no).
    MandelbrotFractal {
        factor: u32,
        zoom: f64,
        angle: f64,
        quality: u32,
        invert_colors: bool,
    },
    /// Angle −180 ..= 180 (45).
    Relief { angle: f64 },
}

impl Effect {
    pub fn name(&self) -> &'static str {
        match self {
            Effect::GaussianBlur { .. } => "Gaussian Blur",
            Effect::MotionBlur { .. } => "Motion Blur",
            Effect::Sharpen { .. } => "Sharpen",
            Effect::AddNoise { .. } => "Add Noise",
            Effect::Median { .. } => "Median",
            Effect::Pixelate { .. } => "Pixelate",
            Effect::OilPainting { .. } => "Oil Painting",
            Effect::Emboss { .. } => "Emboss",
            Effect::EdgeDetect { .. } => "Edge Detect",
            Effect::Outline { .. } => "Outline",
            Effect::InkSketch { .. } => "Ink Sketch",
            Effect::PencilSketch { .. } => "Pencil Sketch",
            Effect::Fragment { .. } => "Fragment",
            Effect::RadialBlur { .. } => "Radial Blur",
            Effect::SurfaceBlur { .. } => "Surface Blur",
            Effect::Unfocus { .. } => "Unfocus",
            Effect::ZoomBlur { .. } => "Zoom Blur",
            Effect::Bulge { .. } => "Bulge",
            Effect::Dents { .. } => "Dents",
            Effect::FrostedGlass { .. } => "Frosted Glass",
            Effect::PolarInversion { .. } => "Polar Inversion",
            Effect::TileReflection { .. } => "Tile Reflection",
            Effect::Twist { .. } => "Twist",
            Effect::ReduceNoise { .. } => "Reduce Noise",
            Effect::Glow { .. } => "Glow",
            Effect::RedEyeRemoval { .. } => "Red Eye Removal",
            Effect::SoftenPortrait { .. } => "Soften Portrait",
            Effect::Clouds { .. } => "Clouds",
            Effect::JuliaFractal { .. } => "Julia Fractal",
            Effect::MandelbrotFractal { .. } => "Mandelbrot Fractal",
            Effect::Relief { .. } => "Relief",
        }
    }

    /// Every parameter inside its slider's range ([`Effect::ranges`]),
    /// so the dialog's limits and the renderer's cannot drift apart.
    fn validate(&self) -> Result<()> {
        let fields = crate::params::fields_of(self).unwrap_or_default();
        for &(name, lo, hi) in self.ranges() {
            // Not a number is written as null and fails here too.
            match fields.get(name).and_then(serde_json::Value::as_f64) {
                Some(v) if (lo..=hi).contains(&v) => {}
                Some(v) => return Err(invalid(format!("{name} {v} is outside {lo}..={hi}"))),
                None => return Err(invalid(format!("{name} is not a number"))),
            }
        }
        Ok(())
    }

    /// The effect of `src` over `rect` (clipped to `src`), as a surface
    /// the size of the clipped rectangle.
    pub fn render(&self, src: &Surface, rect: Rect) -> Result<Surface> {
        self.render_cancellable(src, rect, &AtomicBool::new(false))
    }

    /// [`Effect::render`] that stops early with [`Error::Cancelled`] once
    /// `cancel` is set (checked every row), so a dialog closed mid-render
    /// frees its worker at once.
    pub fn render_cancellable(
        &self,
        src: &Surface,
        rect: Rect,
        cancel: &AtomicBool,
    ) -> Result<Surface> {
        self.validate()?;
        let rect = rect.intersect(src.bounds());
        if rect.is_empty() {
            return Surface::new(rect.width.max(1), rect.height.max(1));
        }
        let c = cancel;
        match *self {
            Effect::GaussianBlur { radius } => {
                blurs::tent_blur(src, rect, radius as usize, c).ok_or(Error::Cancelled)
            }
            Effect::MotionBlur {
                angle,
                distance,
                centered,
            } => blurs::motion(src, rect, c, angle, distance, centered),
            Effect::Sharpen { amount } => local::sharpen(src, rect, c, amount),
            Effect::AddNoise {
                intensity,
                saturation,
                coverage,
                seed,
            } => noise::add_noise(src, rect, c, intensity, saturation, coverage / 100.0, seed),
            Effect::Median { radius, percentile } => {
                local::median(src, rect, c, radius, percentile)
            }
            Effect::Pixelate { cell_size } => distort::pixelate(src, rect, c, cell_size),
            Effect::OilPainting {
                brush_size,
                coarseness,
            } => artistic::oil_painting(src, rect, c, brush_size, coarseness),
            Effect::Emboss { angle } => stylize::emboss(src, rect, c, angle),
            Effect::EdgeDetect { angle } => stylize::edge_detect(src, rect, c, angle),
            Effect::Outline {
                thickness,
                intensity,
            } => local::outline(src, rect, c, thickness, intensity),
            Effect::InkSketch {
                ink_outline,
                coloring,
            } => artistic::ink_sketch(src, rect, c, ink_outline, coloring),
            Effect::PencilSketch {
                tip_size,
                color_range,
            } => artistic::pencil_sketch(src, rect, c, tip_size, color_range),
            Effect::Fragment {
                fragments,
                distance,
                rotation,
            } => blurs::fragment(src, rect, c, fragments, distance, rotation),
            Effect::RadialBlur {
                angle,
                offset_x,
                offset_y,
                quality,
            } => blurs::radial(src, rect, c, angle, (offset_x, offset_y), quality),
            Effect::SurfaceBlur { radius, threshold } => {
                local::surface_blur(src, rect, c, radius, threshold)
            }
            Effect::Unfocus { radius } => local::unfocus(src, rect, c, radius),
            Effect::ZoomBlur {
                amount,
                offset_x,
                offset_y,
            } => blurs::zoom(src, rect, c, amount, (offset_x, offset_y)),
            Effect::Bulge {
                amount,
                offset_x,
                offset_y,
            } => distort::bulge(src, rect, c, amount, (offset_x, offset_y)),
            Effect::Dents {
                scale,
                refraction,
                roughness,
                tension,
                quality,
                seed,
            } => {
                let dents = distort::Dents {
                    scale,
                    refraction,
                    roughness,
                    tension,
                    seed: seed_byte(seed),
                };
                distort::dents(src, rect, c, dents, quality)
            }
            Effect::FrostedGlass {
                max_scatter,
                min_scatter,
                samples,
                seed,
            } => distort::frosted_glass(src, rect, c, (min_scatter, max_scatter), samples, seed),
            Effect::PolarInversion {
                amount,
                offset_x,
                offset_y,
                edge_behavior,
                quality,
            } => {
                let edge = [
                    distort::Edge::Clamp,
                    distort::Edge::Reflect,
                    distort::Edge::Wrap,
                ][edge_behavior as usize];
                distort::polar_inversion(src, rect, c, amount, (offset_x, offset_y), edge, quality)
            }
            Effect::TileReflection {
                rotation,
                tile_size,
                curvature,
                quality,
            } => distort::tile_reflection(src, rect, c, rotation, tile_size, curvature, quality),
            Effect::Twist {
                amount,
                size,
                offset_x,
                offset_y,
                quality,
            } => distort::twist(src, rect, c, amount, size, (offset_x, offset_y), quality),
            Effect::ReduceNoise { radius, strength } => {
                local::reduce_noise(src, rect, c, radius, strength)
            }
            Effect::Glow {
                radius,
                brightness,
                contrast,
            } => photo::glow(src, rect, c, radius, brightness, contrast),
            Effect::RedEyeRemoval {
                tolerance,
                saturation,
            } => photo::red_eye_removal(src, rect, c, tolerance, saturation),
            Effect::SoftenPortrait {
                softness,
                lighting,
                warmth,
            } => photo::soften_portrait(src, rect, c, softness, lighting, warmth),
            Effect::Clouds {
                scale,
                power,
                blend_mode,
                seed,
            } => {
                let mode = crate::blend::BlendMode::ALL[blend_mode as usize];
                render::clouds(src, rect, c, scale, power, mode, seed_byte(seed))
            }
            Effect::JuliaFractal {
                factor,
                zoom,
                angle,
                quality,
            } => render::julia(src, rect, c, factor, zoom, angle, quality),
            Effect::MandelbrotFractal {
                factor,
                zoom,
                angle,
                quality,
                invert_colors,
            } => render::mandelbrot(src, rect, c, factor, zoom, angle, quality, invert_colors),
            Effect::Relief { angle } => stylize::relief(src, rect, c, angle),
        }
    }
}

/// The rendered surface, unless the render was cancelled part way.
fn finished(out: Surface, cancel: &AtomicBool) -> Result<Surface> {
    if cancel.load(Ordering::Relaxed) {
        Err(Error::Cancelled)
    } else {
        Ok(out)
    }
}

/// A surface the size of `rect` filled row by row over threads:
/// `row(y, line)` writes image row `y` from `rect.x`. Rows not yet
/// started are skipped once `cancel` is set.
fn by_rows(
    rect: Rect,
    cancel: &AtomicBool,
    row: impl Fn(i32, &mut [Rgba8]) + Sync,
) -> Result<Surface> {
    let mut out = Surface::new(rect.width, rect.height)?;
    for_rows(out.pixels_mut(), rect.width as usize, |i, line| {
        if !cancel.load(Ordering::Relaxed) {
            row(rect.y + i as i32, line);
        }
    });
    finished(out, cancel)
}

/// [`by_rows`] one pixel at a time: `pixel(x, y)` in image coordinates.
fn by_pixels(
    rect: Rect,
    cancel: &AtomicBool,
    pixel: impl Fn(i32, i32) -> Rgba8 + Sync,
) -> Result<Surface> {
    by_rows(rect, cancel, |y, line| {
        for (i, out) in line.iter_mut().enumerate() {
            *out = pixel(rect.x + i as i32, y);
        }
    })
}

/// `surface` (a render of `rect`) changed in place pixel by pixel:
/// `f(x, y, p)` in image coordinates. The second pass of the effects
/// the source builds from a blur and pixel operations.
fn map_pixels(
    mut surface: Surface,
    rect: Rect,
    cancel: &AtomicBool,
    f: impl Fn(i32, i32, Rgba8) -> Rgba8 + Sync,
) -> Result<Surface> {
    for_rows(surface.pixels_mut(), rect.width as usize, |i, line| {
        if cancel.load(Ordering::Relaxed) {
            return;
        }
        let y = rect.y + i as i32;
        for (j, p) in line.iter_mut().enumerate() {
            *p = f(rect.x + j as i32, y, *p);
        }
    });
    finished(surface, cancel)
}

/// `Utility.GetRgssOffsets`: `quality²` sub-pixel offsets spread over
/// the pixel (rotated-grid supersampling), the centre alone at 1.
fn rgss_offsets(quality: u32) -> Vec<(f32, f32)> {
    let count = quality * quality;
    if count == 1 {
        return vec![(0.0, 0.0)];
    }
    (0..count)
        .map(|i| {
            let y = (i + 1) as f64 / (count + 1) as f64;
            let x = y * quality as f64;
            ((x.fract() - 0.5) as f32, (y - 0.5) as f32)
        })
        .collect()
}

/// `Utility.ClampToByte(double)`: truncated, cut to 0 ..= 255; a
/// float-to-int cast in Rust saturates the same way, and not a number
/// gives 0.
fn clamp_byte(v: f64) -> u8 {
    v as u8
}

/// The source's noise takes a byte seed (0 ..= 255, which here give the
/// source's pictures); larger seeds fold all their bytes in, so each
/// Reseed changes the picture.
fn seed_byte(seed: u64) -> u8 {
    seed.to_le_bytes().iter().fold(0, |a, b| a ^ b)
}

/// SplitMix64: a small seeded generator so noise can be repeated.
struct Rng(u64);

impl Rng {
    /// A generator for row `y`: seeded per row so threads give the same
    /// picture as one.
    fn for_row(seed: u64, y: i32) -> Rng {
        Rng(seed ^ (y as u64).wrapping_mul(0xD6E8_FEB8_6659_FD93))
    }

    fn next(&mut self) -> u64 {
        self.0 = self.0.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.0;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }

    fn unit(&mut self) -> f64 {
        (self.next() >> 11) as f64 / (1u64 << 53) as f64
    }

    /// A standard normal value scaled by 4096 and cut at ±8σ, as the
    /// source's lookup table.
    fn normal(&mut self) -> i64 {
        let u1 = self.unit().max(f64::MIN_POSITIVE);
        let u2 = self.unit();
        let n = (-2.0 * u1.ln()).sqrt() * (std::f64::consts::TAU * u2).cos();
        (n.clamp(-8.0, 8.0) * 4096.0) as i64
    }
}

impl Document {
    /// Applies an effect to the active layer inside the selection.
    /// Inside an open edit it previews (redraws from the originals).
    /// This runs on the calling thread; for slow effects see
    /// [`Document::effect_source`] and [`Document::apply_rendered`].
    pub fn apply_effect(&mut self, effect: &Effect) -> Result<()> {
        self.run_edit(effect.name(), |doc| {
            let layer = doc.edit_layer();
            let rect = doc.selection.bounds();
            let result = effect.render(&doc.layers[layer].surface, rect)?;
            doc.blend_rendered(rect, &result)
        })
    }

    /// What a worker thread renders an effect from: a copy of the active
    /// layer as it is before any open preview, and the rectangle to
    /// render (the selection bounds). The shell then calls
    /// [`Document::apply_rendered`] with `effect.render(&source, rect)`.
    pub fn effect_source(&self) -> (Surface, Rect) {
        let layer = self.edit_layer();
        let surface = &self.layers[layer].surface;
        let mut source = surface.clone();
        if let Some(edit) = &self.edit {
            for y in 0..self.height as i32 {
                for x in 0..self.width as i32 {
                    source.set(x, y, edit.backup.original(surface, x, y));
                }
            }
        }
        (source, self.selection.bounds())
    }

    /// Blends a result rendered elsewhere (`result` covers `rect`) into
    /// the active layer by the selection: one step named `name`, or a
    /// preview inside an open edit.
    pub fn apply_rendered(&mut self, name: &str, rect: Rect, result: &Surface) -> Result<()> {
        if result.width() != rect.width || result.height() != rect.height {
            return Err(crate::error::invalid(
                "the result does not match its rectangle",
            ));
        }
        self.run_edit(name, |doc| doc.blend_rendered(rect, result))
    }

    fn blend_rendered(&mut self, rect: Rect, result: &Surface) -> Result<()> {
        self.paint_region(
            rect,
            |_, _| 255,
            |o, c, x, y| {
                let value = result.get(x - rect.x, y - rect.y).unwrap_or(o);
                if c == 255 {
                    value
                } else {
                    lerp(o, value, c)
                }
            },
        )
    }
}

/// Pictures and checks the effects' tests share.
#[cfg(test)]
pub(crate) mod testing {
    use super::*;

    pub fn checker(w: u32, h: u32) -> Surface {
        let mut s = Surface::new(w, h).unwrap();
        for y in 0..h as i32 {
            for x in 0..w as i32 {
                let v = if (x + y) % 2 == 0 { 255 } else { 0 };
                s.set(x, y, Rgba8::opaque(v, v, v));
            }
        }
        s
    }

    /// A picture with something different in every pixel.
    pub fn varied(w: u32, h: u32) -> Surface {
        let mut s = Surface::new(w, h).unwrap();
        for y in 0..h as i32 {
            for x in 0..w as i32 {
                let v = (x * 37 + y * 91 + x * y * 7) as u32;
                s.set(
                    x,
                    y,
                    Rgba8::new(v as u8, (v >> 3) as u8, (v * 5) as u8, 255),
                );
            }
        }
        s
    }

    pub fn close(a: Rgba8, b: Rgba8, by: u8) -> bool {
        [(a.r, b.r), (a.g, b.g), (a.b, b.b), (a.a, b.a)]
            .iter()
            .all(|(x, y)| x.abs_diff(*y) <= by)
    }

    pub fn render(effect: Effect, s: &Surface) -> Surface {
        effect.render(s, s.bounds()).unwrap()
    }

    /// Every pixel of `out` is `color`.
    pub fn all(out: &Surface, color: Rgba8) -> bool {
        out.pixels().iter().all(|&p| p == color)
    }
}

#[cfg(test)]
mod tests {
    use super::testing::*;
    use super::*;
    use crate::command::EffectKind;

    #[test]
    fn every_default_renders_and_ranges_name_real_fields() {
        let s = varied(24, 18);
        for kind in EffectKind::ALL {
            let effect = kind.default_effect();
            let fields = crate::params::fields_of(&effect).unwrap();
            for (name, lo, hi) in effect.ranges() {
                assert!(fields.contains_key(*name), "{}: {name}", effect.name());
                assert!(lo < hi);
            }
            let out = effect.render(&s, Rect::new(3, 2, 15, 11)).unwrap();
            assert_eq!((out.width(), out.height()), (15, 11), "{}", effect.name());
        }
    }

    #[test]
    fn out_of_range_parameters_are_refused() {
        let s = Surface::new(4, 4).unwrap();
        let bad = [
            Effect::Pixelate { cell_size: 0 },
            Effect::InkSketch {
                ink_outline: 100,
                coloring: 50,
            },
            Effect::PencilSketch {
                tip_size: 2,
                color_range: 21,
            },
            Effect::Fragment {
                fragments: 1,
                distance: 8,
                rotation: 0.0,
            },
            Effect::RadialBlur {
                angle: 2.0,
                offset_x: 2.5,
                offset_y: 0.0,
                quality: 2,
            },
            Effect::SurfaceBlur {
                radius: 6,
                threshold: 0,
            },
            Effect::Unfocus { radius: 201 },
            Effect::ZoomBlur {
                amount: 101,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            Effect::Bulge {
                amount: 101,
                offset_x: 0.0,
                offset_y: 0.0,
            },
            Effect::Dents {
                scale: 0.5,
                refraction: 50.0,
                roughness: 10.0,
                tension: 10.0,
                quality: 2,
                seed: 0,
            },
            Effect::FrostedGlass {
                max_scatter: f64::NAN,
                min_scatter: 0.0,
                samples: 2,
                seed: 0,
            },
            Effect::PolarInversion {
                amount: 1.0,
                offset_x: 0.0,
                offset_y: 0.0,
                edge_behavior: 3,
                quality: 2,
            },
            Effect::TileReflection {
                rotation: 30.0,
                tile_size: 0.0,
                curvature: 8.0,
                quality: 2,
            },
            Effect::Twist {
                amount: 30.0,
                size: 0.0,
                offset_x: 0.0,
                offset_y: 0.0,
                quality: 2,
            },
            Effect::ReduceNoise {
                radius: 10,
                strength: 1.5,
            },
            Effect::Glow {
                radius: 0,
                brightness: 10,
                contrast: 10,
            },
            Effect::RedEyeRemoval {
                tolerance: 101,
                saturation: 90,
            },
            Effect::SoftenPortrait {
                softness: 11,
                lighting: 0,
                warmth: 10,
            },
            Effect::Clouds {
                scale: 250,
                power: 0.5,
                blend_mode: 14,
                seed: 0,
            },
            Effect::JuliaFractal {
                factor: 4.0,
                zoom: 0.0,
                angle: 0.0,
                quality: 2,
            },
            Effect::MandelbrotFractal {
                factor: 1,
                zoom: 10.0,
                angle: 0.0,
                quality: 6,
                invert_colors: false,
            },
            Effect::Relief { angle: 181.0 },
        ];
        for effect in bad {
            assert!(effect.render(&s, s.bounds()).is_err(), "{effect:?}");
        }
    }

    #[test]
    fn rgss_offsets_stay_inside_the_pixel() {
        assert_eq!(rgss_offsets(1), [(0.0, 0.0)]);
        let o = rgss_offsets(3);
        assert_eq!(o.len(), 9);
        assert!(o
            .iter()
            .all(|&(x, y)| (-0.5..0.5).contains(&x) && (-0.5..0.5).contains(&y)));
        // `y = 1/10`, `x = 3/10`, both minus a half.
        assert!((o[0].0 - -0.2).abs() < 1e-6 && (o[0].1 - -0.4).abs() < 1e-6);
    }

    #[test]
    fn seeds_fold_to_the_source_byte() {
        assert_eq!(seed_byte(0), 0);
        assert_eq!(seed_byte(200), 200);
        assert_ne!(seed_byte(256), seed_byte(0));
    }

    #[test]
    fn effects_apply_inside_the_selection_as_one_step() {
        let mut d = Document::new(16, 16, Rgba8::WHITE).unwrap();
        d.apply_effect(&Effect::Emboss { angle: 0.0 }).unwrap();
        assert_eq!(
            d.layers()[0].surface().at(8, 8),
            Rgba8::opaque(128, 128, 128)
        );
        assert_eq!(d.history_names().last().unwrap(), "Emboss");
    }
}
