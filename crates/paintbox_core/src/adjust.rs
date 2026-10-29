//! The Adjustments menu, ported from Paint.NET's `UnaryPixelOps` and
//! adjustment effects. Each works pixel by pixel on the active layer
//! inside the selection and is one history step.

use serde::{Deserialize, Serialize};

use crate::color::{clamp_u8, from_hsv, lerp, to_hsv, Rgba8};
use crate::document::Document;
use crate::error::{invalid, Result};
use crate::selection::Selection;
use crate::surface::Surface;

/// Levels: per channel (r, g, b) input range, output range and gamma.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct Levels {
    pub input_low: [u8; 3],
    pub input_high: [u8; 3],
    pub output_low: [u8; 3],
    pub output_high: [u8; 3],
    /// 0.1 – 10; above 1 darkens the midtones.
    pub gamma: [f32; 3],
}

impl Default for Levels {
    fn default() -> Self {
        Self {
            input_low: [0; 3],
            input_high: [255; 3],
            output_low: [0; 3],
            output_high: [255; 3],
            gamma: [1.0; 3],
        }
    }
}

impl Levels {
    fn validate(&self) -> Result<()> {
        for i in 0..3 {
            if self.input_low[i] >= self.input_high[i] || self.output_low[i] > self.output_high[i] {
                return Err(invalid("levels need low below high"));
            }
            if !(0.1..=10.0).contains(&self.gamma[i]) {
                return Err(invalid("levels gamma is outside 0.1..=10"));
            }
        }
        Ok(())
    }

    /// `UnaryPixelOps.Level.Apply` for one channel value.
    fn map(&self, channel: usize, value: u8) -> u8 {
        let (lo, hi) = (
            self.input_low[channel] as f64,
            self.input_high[channel] as f64,
        );
        let (olo, ohi) = (
            self.output_low[channel] as f64,
            self.output_high[channel] as f64,
        );
        let v = value as f64 - lo;
        if v < 0.0 {
            self.output_low[channel]
        } else if value as f64 >= hi {
            self.output_high[channel]
        } else {
            (olo + (ohi - olo) * (v / (hi - lo)).powf(self.gamma[channel] as f64)).clamp(0.0, 255.0)
                as u8
        }
    }

    fn tables(&self) -> [[u8; 256]; 3] {
        let mut t = [[0u8; 256]; 3];
        for (channel, table) in t.iter_mut().enumerate() {
            for (v, out) in table.iter_mut().enumerate() {
                *out = self.map(channel, v as u8);
            }
        }
        t
    }

    /// `Level.AutoFromLoMdHi`: the input range from the 0.5% and 99.5%
    /// percentiles, the gamma that maps the mean to the middle.
    pub fn auto(histogram: &[[u64; 256]; 3]) -> Levels {
        let mut levels = Levels::default();
        for (c, h) in histogram.iter().enumerate() {
            let total: u64 = h.iter().sum();
            if total == 0 {
                continue;
            }
            let percentile = |fraction: f64| {
                let mut integral = 0u64;
                for (j, &count) in h.iter().enumerate() {
                    integral += count;
                    if integral as f64 > total as f64 * fraction {
                        return j as u8;
                    }
                }
                255
            };
            let mean = h
                .iter()
                .enumerate()
                .map(|(j, &n)| j as f64 * n as f64)
                .sum::<f64>()
                / total as f64;
            let lo = percentile(0.005);
            let hi = percentile(0.995);
            let md = (mean + 0.5) as u8;
            if lo < hi {
                levels.input_low[c] = lo;
                levels.input_high[c] = hi;
            }
            levels.gamma[c] = if lo < md && md < hi {
                let ratio = (md - lo) as f64 / (hi - lo) as f64;
                (0.5f64.ln() / ratio.ln()).clamp(0.1, 10.0) as f32
            } else {
                1.0
            };
        }
        levels
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum CurveMode {
    #[default]
    Luminosity,
    Rgb,
}

/// Curves: control points `(input, output)` per curve. Luminosity mode
/// uses `luminosity`; RGB mode uses `red`, `green`, `blue`.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Curves {
    pub mode: CurveMode,
    pub luminosity: Vec<(u8, u8)>,
    pub red: Vec<(u8, u8)>,
    pub green: Vec<(u8, u8)>,
    pub blue: Vec<(u8, u8)>,
}

impl Default for Curves {
    fn default() -> Self {
        let identity = vec![(0, 0), (255, 255)];
        Self {
            mode: CurveMode::Luminosity,
            luminosity: identity.clone(),
            red: identity.clone(),
            green: identity.clone(),
            blue: identity,
        }
    }
}

/// The natural cubic spline of `SplineInterpolator` sampled at 0..=255.
pub fn spline_table(points: &[(u8, u8)]) -> Result<[u8; 256]> {
    let mut points: Vec<(f64, f64)> = points.iter().map(|&(x, y)| (x as f64, y as f64)).collect();
    // `SortedList` keeps the last point given for an x.
    points.reverse();
    points.sort_by(|a, b| a.0.total_cmp(&b.0));
    points.dedup_by(|a, b| a.0 == b.0);
    if points.len() < 2 {
        return Err(invalid("a curve needs two points"));
    }
    let n = points.len();
    let mut y2 = vec![0f64; n];
    let mut u = vec![0f64; n];
    for i in 1..n - 1 {
        let (x0, x1, x2) = (points[i - 1].0, points[i].0, points[i + 1].0);
        let (v0, v1, v2) = (points[i - 1].1, points[i].1, points[i + 1].1);
        let wx = x2 - x0;
        let sig = (x1 - x0) / wx;
        let p = sig * y2[i - 1] + 2.0;
        y2[i] = (sig - 1.0) / p;
        let ddydx = (v2 - v1) / (x2 - x1) - (v1 - v0) / (x1 - x0);
        u[i] = (6.0 * ddydx / wx - sig * u[i - 1]) / p;
    }
    for i in (0..n - 1).rev() {
        y2[i] = y2[i] * y2[i + 1] + u[i];
    }
    let mut table = [0u8; 256];
    for (x, out) in table.iter_mut().enumerate() {
        let x = x as f64;
        let mut hi = points.iter().position(|p| p.0 > x).unwrap_or(n - 1).max(1);
        if x >= points[n - 1].0 {
            hi = n - 1;
        }
        let lo = hi - 1;
        let h = points[hi].0 - points[lo].0;
        let a = (points[hi].0 - x) / h;
        let b = (x - points[lo].0) / h;
        let y = a * points[lo].1
            + b * points[hi].1
            + ((a * a * a - a) * y2[lo] + (b * b * b - b) * y2[hi]) * (h * h) / 6.0;
        // `Utility.ClampToByte(double)` truncates.
        *out = y.clamp(0.0, 255.0) as u8;
    }
    Ok(table)
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Adjustment {
    AutoLevel,
    BlackAndWhite,
    /// Both −100 ..= 100.
    BrightnessContrast {
        brightness: i32,
        contrast: i32,
    },
    Curves(Curves),
    /// Hue −180 ..= 180, saturation 0 ..= 200 (100 unchanged), lightness
    /// −100 ..= 100.
    HueSaturation {
        hue: i32,
        saturation: i32,
        lightness: i32,
    },
    InvertColors,
    Levels(Levels),
    /// 2 ..= 64 levels per channel.
    Posterize {
        red: u32,
        green: u32,
        blue: u32,
    },
    Sepia,
}

impl Adjustment {
    pub fn name(&self) -> &'static str {
        match self {
            Adjustment::AutoLevel => "Auto-Level",
            Adjustment::BlackAndWhite => "Black and White",
            Adjustment::BrightnessContrast { .. } => "Brightness / Contrast",
            Adjustment::Curves(_) => "Curves",
            Adjustment::HueSaturation { .. } => "Hue / Saturation",
            Adjustment::InvertColors => "Invert Colors",
            Adjustment::Levels(_) => "Levels",
            Adjustment::Posterize { .. } => "Posterize",
            Adjustment::Sepia => "Sepia",
        }
    }

    /// The per-pixel function for this adjustment of `src` (Auto-Level
    /// reads the histogram of the selected pixels).
    pub fn pixel_op(&self, src: &Surface, selection: &Selection) -> Result<PixelOp> {
        Ok(match self {
            Adjustment::AutoLevel => {
                let mut histogram = [[0u64; 256]; 3];
                let bounds = selection.bounds();
                for y in bounds.y..bounds.bottom() {
                    for x in bounds.x..bounds.right() {
                        if selection.coverage(x, y) > 0 {
                            let p = src.at(x, y);
                            histogram[0][p.r as usize] += 1;
                            histogram[1][p.g as usize] += 1;
                            histogram[2][p.b as usize] += 1;
                        }
                    }
                }
                PixelOp::Tables(Levels::auto(&histogram).tables())
            }
            Adjustment::BlackAndWhite => PixelOp::Gray,
            Adjustment::BrightnessContrast {
                brightness,
                contrast,
            } => {
                if !(-100..=100).contains(brightness) || !(-100..=100).contains(contrast) {
                    return Err(invalid("brightness and contrast are outside -100..=100"));
                }
                PixelOp::BrightnessContrast(brightness_contrast_table(*brightness, *contrast))
            }
            Adjustment::Curves(curves) => match curves.mode {
                CurveMode::Luminosity => PixelOp::Luminosity(spline_table(&curves.luminosity)?),
                CurveMode::Rgb => PixelOp::Tables([
                    spline_table(&curves.red)?,
                    spline_table(&curves.green)?,
                    spline_table(&curves.blue)?,
                ]),
            },
            Adjustment::HueSaturation {
                hue,
                saturation,
                lightness,
            } => {
                if !(-180..=180).contains(hue)
                    || !(0..=200).contains(saturation)
                    || !(-100..=100).contains(lightness)
                {
                    return Err(invalid("hue / saturation values are out of range"));
                }
                PixelOp::HueSaturation {
                    hue: *hue,
                    factor: saturation * 1024 / 100,
                    lightness: *lightness,
                }
            }
            Adjustment::InvertColors => PixelOp::Invert,
            Adjustment::Levels(levels) => {
                levels.validate()?;
                PixelOp::Tables(levels.tables())
            }
            Adjustment::Posterize { red, green, blue } => {
                for n in [red, green, blue] {
                    if !(2..=64).contains(n) {
                        return Err(invalid("posterize levels are outside 2..=64"));
                    }
                }
                PixelOp::Tables([
                    posterize_table(*red),
                    posterize_table(*green),
                    posterize_table(*blue),
                ])
            }
            Adjustment::Sepia => {
                let levels = Levels {
                    gamma: [0.8, 1.0, 1.2],
                    ..Levels::default()
                };
                PixelOp::Sepia(levels.tables())
            }
        })
    }
}

/// A prepared adjustment, applied to one pixel at a time.
pub enum PixelOp {
    Gray,
    Invert,
    Tables([[u8; 256]; 3]),
    Luminosity([u8; 256]),
    BrightnessContrast(BrightnessContrastTable),
    HueSaturation {
        hue: i32,
        factor: i32,
        lightness: i32,
    },
    Sepia([[u8; 256]; 3]),
}

impl PixelOp {
    pub fn apply(&self, p: Rgba8) -> Rgba8 {
        match self {
            PixelOp::Gray => {
                let i = p.intensity();
                Rgba8::new(i, i, i, p.a)
            }
            PixelOp::Invert => Rgba8::new(255 - p.r, 255 - p.g, 255 - p.b, p.a),
            PixelOp::Tables(t) => Rgba8::new(
                t[0][p.r as usize],
                t[1][p.g as usize],
                t[2][p.b as usize],
                p.a,
            ),
            PixelOp::Luminosity(t) => {
                let lumi = p.intensity();
                let diff = t[lumi as usize] as i32 - lumi as i32;
                Rgba8::new(
                    clamp_u8(p.r as i32 + diff),
                    clamp_u8(p.g as i32 + diff),
                    clamp_u8(p.b as i32 + diff),
                    p.a,
                )
            }
            PixelOp::BrightnessContrast(table) => table.apply(p),
            PixelOp::HueSaturation {
                hue,
                factor,
                lightness,
            } => {
                let i = p.intensity() as i32;
                let sat = |c: u8| clamp_u8((i * 1024 + (c as i32 - i) * factor) >> 10);
                let s = Rgba8::new(sat(p.r), sat(p.g), sat(p.b), p.a);
                let (h, sv, v) = to_hsv(s);
                let mut out = from_hsv(h + *hue as f32, sv, v, p.a);
                if *lightness != 0 {
                    let target = if *lightness > 0 {
                        Rgba8::WHITE
                    } else {
                        Rgba8::BLACK
                    };
                    let amount = (lightness.unsigned_abs() * 255 / 100) as u8;
                    out = lerp(out, target.with_alpha(p.a), amount);
                }
                out.with_alpha(p.a)
            }
            PixelOp::Sepia(t) => {
                let i = p.intensity() as usize;
                Rgba8::new(t[0][i], t[1][i], t[2][i], p.a)
            }
        }
    }
}

/// `BrightnessAndContrastAdjustment`'s table: the shift of a channel
/// depends on the pixel's intensity.
pub struct BrightnessContrastTable {
    threshold: Option<i32>,
    table: Vec<u8>,
}

impl BrightnessContrastTable {
    pub(crate) fn apply(&self, p: Rgba8) -> Rgba8 {
        let i = p.intensity() as usize;
        if let Some(brightness) = self.threshold {
            let v = if i as i32 + brightness < 128 { 0 } else { 255 };
            return Rgba8::new(v, v, v, p.a);
        }
        let row = &self.table[i * 256..(i + 1) * 256];
        Rgba8::new(row[p.r as usize], row[p.g as usize], row[p.b as usize], p.a)
    }
}

pub(crate) fn brightness_contrast_table(brightness: i32, contrast: i32) -> BrightnessContrastTable {
    let (multiply, divide) = match contrast {
        c if c < 0 => (c + 100, 100),
        c if c > 0 => (100, 100 - c),
        _ => (1, 1),
    };
    if divide == 0 {
        return BrightnessContrastTable {
            threshold: Some(brightness),
            table: Vec::new(),
        };
    }
    let mut table = vec![0u8; 65536];
    for intensity in 0..256i32 {
        let shift = if divide == 100 {
            (intensity - 127) * multiply / divide + 127 - intensity + brightness
        } else {
            (intensity - 127 + brightness) * multiply / divide + 127 - intensity
        };
        for col in 0..256i32 {
            table[(intensity * 256 + col) as usize] = clamp_u8(col + shift);
        }
    }
    BrightnessContrastTable {
        threshold: None,
        table,
    }
}

/// `PosterizeAdjustment.CalcLevels`.
fn posterize_table(count: u32) -> [u8; 256] {
    let count = count as usize;
    let mut steps = vec![0u8; count];
    for (i, step) in steps.iter_mut().enumerate().skip(1) {
        *step = (255 * i / (count - 1)) as u8;
    }
    let mut table = [0u8; 256];
    let (mut j, mut k) = (0usize, 0usize);
    for out in table.iter_mut() {
        *out = steps[j.min(count - 1)];
        k += count;
        if k > 255 {
            k -= 255;
            j += 1;
        }
    }
    table
}

impl Document {
    /// Applies an adjustment to the active layer inside the selection.
    /// Inside an open edit it previews (redraws from the originals).
    pub fn apply_adjustment(&mut self, adjustment: &Adjustment) -> Result<()> {
        self.run_edit(adjustment.name(), |doc| {
            let layer = doc.edit_layer();
            let op = adjustment.pixel_op(&doc.layers[layer].surface, &doc.selection)?;
            let rect = doc.selection.bounds();
            doc.paint_region(
                rect,
                |_, _| 255,
                |o, c, _, _| {
                    let value = op.apply(o);
                    if c == 255 {
                        value
                    } else {
                        lerp(o, value, c)
                    }
                },
            )
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::geom::Rect;

    fn op(adjustment: Adjustment, p: Rgba8) -> Rgba8 {
        let s = Surface::filled(1, 1, p).unwrap();
        let sel = Selection::none(Rect::of_size(1, 1));
        adjustment.pixel_op(&s, &sel).unwrap().apply(p)
    }

    const P: Rgba8 = Rgba8::new(200, 100, 30, 77);

    #[test]
    fn invert_black_and_white_and_sepia() {
        assert_eq!(
            op(Adjustment::InvertColors, P),
            Rgba8::new(55, 155, 225, 77)
        );
        let i = P.intensity();
        assert_eq!(op(Adjustment::BlackAndWhite, P), Rgba8::new(i, i, i, 77));
        let sepia = op(Adjustment::Sepia, P);
        assert!(
            sepia.r > i && sepia.g.abs_diff(i) <= 1 && sepia.b < i,
            "{sepia:?}"
        );
        assert_eq!(sepia.a, 77);
    }

    #[test]
    fn brightness_contrast_follows_the_table() {
        assert_eq!(
            op(
                Adjustment::BrightnessContrast {
                    brightness: 0,
                    contrast: 0
                },
                P
            ),
            P
        );
        let bright = op(
            Adjustment::BrightnessContrast {
                brightness: 20,
                contrast: 0,
            },
            P,
        );
        assert_eq!(bright, Rgba8::new(220, 120, 50, 77));
        let i = P.intensity() as i32;
        let shift = (i - 127) * 100 / 50 + 127 - i;
        let contrast = op(
            Adjustment::BrightnessContrast {
                brightness: 0,
                contrast: 50,
            },
            P,
        );
        assert_eq!(contrast.r, clamp_u8(200 + shift));
        let threshold = op(
            Adjustment::BrightnessContrast {
                brightness: 0,
                contrast: 100,
            },
            P,
        );
        assert_eq!(threshold, Rgba8::new(0, 0, 0, 77));
    }

    #[test]
    fn hue_saturation_rotates_and_desaturates() {
        let red = Rgba8::opaque(255, 0, 0);
        let green = op(
            Adjustment::HueSaturation {
                hue: 120,
                saturation: 100,
                lightness: 0,
            },
            red,
        );
        assert_eq!(green, Rgba8::opaque(0, 255, 0));
        let gray = op(
            Adjustment::HueSaturation {
                hue: 0,
                saturation: 0,
                lightness: 0,
            },
            P,
        );
        assert_eq!((gray.r, gray.g), (gray.g, gray.b));
        let white = op(
            Adjustment::HueSaturation {
                hue: 0,
                saturation: 100,
                lightness: 100,
            },
            red,
        );
        assert_eq!(white, Rgba8::WHITE);
    }

    #[test]
    fn levels_and_auto_level() {
        let levels = Levels {
            input_low: [50; 3],
            input_high: [150; 3],
            ..Levels::default()
        };
        let out = op(Adjustment::Levels(levels), Rgba8::opaque(100, 40, 200));
        assert_eq!(out, Rgba8::opaque(127, 0, 255));
        let mut histogram = [[0u64; 256]; 3];
        for h in &mut histogram {
            h[50] = 100;
            h[150] = 100;
        }
        let auto = Levels::auto(&histogram);
        assert_eq!(auto.input_low[0], 50);
        assert_eq!(auto.input_high[0], 150);
        assert!((auto.gamma[0] - 1.0).abs() < 0.03, "{}", auto.gamma[0]);
        assert!(Adjustment::Levels(Levels {
            gamma: [20.0; 3],
            ..Levels::default()
        })
        .pixel_op(
            &Surface::new(1, 1).unwrap(),
            &Selection::none(Rect::of_size(1, 1))
        )
        .is_err());
    }

    #[test]
    fn posterize_uses_the_source_steps() {
        let table = posterize_table(2);
        assert_eq!(
            (table[0], table[127], table[128], table[255]),
            (0, 0, 255, 255)
        );
        let table = posterize_table(16);
        assert_eq!(table[0], 0);
        assert_eq!(table[255], 255);
        assert_eq!(table[16], 17);
    }

    #[test]
    fn curves_pass_through_their_points() {
        let t = spline_table(&[(0, 0), (128, 200), (255, 255)]).unwrap();
        assert_eq!(t[0], 0);
        assert_eq!(t[128], 200);
        assert_eq!(t[255], 255);
        let identity = spline_table(&[(0, 0), (255, 255)]).unwrap();
        assert!(identity.iter().enumerate().all(|(i, &v)| v as usize == i));
        let lum = Curves {
            luminosity: vec![(0, 0), (255, 128)],
            ..Curves::default()
        };
        let out = op(Adjustment::Curves(lum), Rgba8::WHITE);
        assert_eq!(out, Rgba8::opaque(128, 128, 128));
        assert!(spline_table(&[(3, 3)]).is_err());
    }

    #[test]
    fn an_adjustment_is_one_step_inside_the_selection() {
        let mut d = Document::new(10, 10, Rgba8::WHITE).unwrap();
        d.select_rectangle(
            crate::PointF::new(0.0, 0.0),
            crate::PointF::new(5.0, 10.0),
            crate::CombineMode::Replace,
        )
        .unwrap();
        d.apply_adjustment(&Adjustment::InvertColors).unwrap();
        assert_eq!(d.layers()[0].surface().at(2, 2), Rgba8::BLACK);
        assert_eq!(d.layers()[0].surface().at(7, 2), Rgba8::WHITE);
        assert_eq!(d.history_names().last().unwrap(), "Invert Colors");
    }
}
