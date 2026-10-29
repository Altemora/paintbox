//! Th        let current = self.lift_offset().unwrap_or((0, 0)); painting tools as operations on the document, with the
//! parameters of Paint.NET's tool bar. Strokes (Pencil, Paintbrush,
//! Eraser, Clone Stamp, Recolor) run as begin / to / end; the rest are
//! single calls that, inside [`Document::begin_edit`], redraw from the
//! originals so a shell can preview a drag.

use serde::{Deserialize, Serialize};

use crate::blend::over;
use crate::color::{blend_toward, lerp, mul255, Rgba8};
use crate::document::{Button, Document, EditKind};
use crate::error::{invalid, Error, Result};
use crate::geom::{sane_offset, PointF, Rect};
use crate::image_ops::Resampling;
use crate::mask::Mask;
use crate::raster::{self, BrushTip};
use crate::selection::Selection;
use crate::stroke::{DashStyle, LineCap};
use crate::surface::Surface;

/// Paint.NET's brush width range.
pub const MAX_BRUSH_WIDTH: f32 = 500.0;

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct BrushSettings {
    /// 1 – 500 pixels.
    pub width: f32,
    pub antialias: bool,
    pub alpha_blending: bool,
    /// 0 – 1; 1 is a hard rim (Paint.NET 3.36 has only that).
    pub hardness: f32,
}

impl Default for BrushSettings {
    fn default() -> Self {
        Self {
            width: 2.0,
            antialias: true,
            alpha_blending: true,
            hardness: 1.0,
        }
    }
}

impl BrushSettings {
    fn validate(&self) -> Result<()> {
        if !(1.0..=MAX_BRUSH_WIDTH).contains(&self.width) {
            return Err(invalid(format!(
                "brush width {} is outside 1..=500",
                self.width
            )));
        }
        if !(0.0..=1.0).contains(&self.hardness) {
            return Err(invalid("hardness is outside 0..=1"));
        }
        Ok(())
    }

    fn tip(&self) -> BrushTip {
        BrushTip {
            width: self.width,
            hardness: self.hardness,
            antialias: self.antialias,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct RecolorSettings {
    pub width: f32,
    pub antialias: bool,
    /// 0 – 1, typically 0.5.
    pub tolerance: f32,
}

impl Default for RecolorSettings {
    fn default() -> Self {
        Self {
            width: 2.0,
            antialias: true,
            tolerance: 0.5,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum StrokeTool {
    Pencil { alpha_blending: bool },
    Paintbrush(BrushSettings),
    Eraser(BrushSettings),
    CloneStamp(BrushSettings),
    Recolor(RecolorSettings),
}

impl StrokeTool {
    pub fn name(&self) -> &'static str {
        match self {
            StrokeTool::Pencil { .. } => "Pencil",
            StrokeTool::Paintbrush(_) => "Paintbrush",
            StrokeTool::Eraser(_) => "Eraser",
            StrokeTool::CloneStamp(_) => "Clone Stamp",
            StrokeTool::Recolor(_) => "Recolor",
        }
    }
}

/// Where Clone Stamp copies from (Ctrl+click), kept between strokes.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct CloneSource {
    pub layer: usize,
    pub point: PointF,
}

pub(crate) struct Stroke {
    tool: StrokeTool,
    mask: Mask,
    last: PointF,
    color: Rgba8,
    other: Rgba8,
    clone: Option<(CloneSource, (i32, i32))>,
}

impl Stroke {
    /// The clone source moved along with the stroke, so the next stroke
    /// continues from where this one stopped.
    pub(crate) fn advanced_clone_source(&self) -> Option<CloneSource> {
        self.clone.map(|(source, (dx, dy))| CloneSource {
            layer: source.layer,
            point: PointF::new(self.last.x + dx as f32, self.last.y + dy as f32),
        })
    }
}

/// Recolor's distance: `ceil(sqrt((dR² + dG² + dB²) / 3))`, no alpha.
pub fn color_difference(a: Rgba8, b: Rgba8) -> u32 {
    let d = |x: u8, y: u8| (x as i32 - y as i32).pow(2);
    let sum = (d(a.r, b.r) + d(a.g, b.g) + d(a.b, b.b)) / 3;
    (sum as f64).sqrt().ceil() as u32
}

impl Document {
    // ---- strokes -----------------------------------------------------

    /// Ctrl+click with Clone Stamp.
    pub fn set_clone_source(&mut self, at: PointF) {
        self.clone_source = Some(CloneSource {
            layer: self.active,
            point: at,
        });
    }

    pub fn clone_source(&self) -> Option<CloneSource> {
        self.clone_source
    }

    /// Presses the button for a stroke at `at`. Returns whether a stroke
    /// started: Clone Stamp with the right button or without a source,
    /// and Recolor with equal colours, do nothing, as in Paint.NET, and
    /// the shell can show why.
    pub fn begin_stroke(&mut self, tool: StrokeTool, button: Button, at: PointF) -> Result<bool> {
        let at = at.sanitized();
        match &tool {
            StrokeTool::Pencil { .. } => {}
            StrokeTool::Paintbrush(s) | StrokeTool::Eraser(s) | StrokeTool::CloneStamp(s) => {
                s.validate()?
            }
            StrokeTool::Recolor(s) => {
                BrushSettings {
                    width: s.width,
                    ..BrushSettings::default()
                }
                .validate()?;
                if !(0.0..=1.0).contains(&s.tolerance) {
                    return Err(invalid("tolerance is outside 0..=1"));
                }
            }
        }
        self.finish_pending()?;
        let (color, other) = self.colors.for_button(button);
        let clone = match tool {
            StrokeTool::CloneStamp(_) => {
                let source = match (button, self.clone_source) {
                    (Button::Primary, Some(source)) if source.layer < self.layers.len() => source,
                    _ => return Ok(false),
                };
                let offset = (
                    (source.point.x - at.x).round() as i32,
                    (source.point.y - at.y).round() as i32,
                );
                Some((source, offset))
            }
            StrokeTool::Recolor(_) if color == other => return Ok(false),
            _ => None,
        };
        let stroke = Stroke {
            tool,
            mask: Mask::new(self.bounds()),
            last: at,
            color,
            other,
            clone,
        };
        self.open_edit(tool.name(), EditKind::Stroke(Box::new(stroke)))?;
        self.stroke_segment(at, at)?;
        Ok(true)
    }

    /// Drags the stroke to `to`.
    pub fn stroke_to(&mut self, to: PointF) -> Result<()> {
        let Some(from) = self.stroke_last() else {
            return Ok(());
        };
        self.stroke_segment(from, to.sanitized())
    }

    /// Releases the button: the stroke becomes one history step.
    pub fn end_stroke(&mut self) -> Result<()> {
        if self.stroke_last().is_some() {
            self.commit_edit()?;
        }
        Ok(())
    }

    fn stroke_last(&self) -> Option<PointF> {
        match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Stroke(stroke)) => Some(stroke.last),
            _ => None,
        }
    }

    fn stroke_segment(&mut self, from: PointF, to: PointF) -> Result<()> {
        let Some(edit) = self.edit.as_mut() else {
            return Ok(());
        };
        let EditKind::Stroke(mut stroke) = std::mem::replace(&mut edit.kind, EditKind::Plain)
        else {
            return Ok(());
        };
        let result = self.paint_stroke(&mut stroke, from, to);
        stroke.last = to;
        if let Some(edit) = self.edit.as_mut() {
            edit.kind = EditKind::Stroke(stroke);
        }
        result
    }

    fn paint_stroke(&mut self, stroke: &mut Stroke, from: PointF, to: PointF) -> Result<()> {
        let rect = match &stroke.tool {
            StrokeTool::Pencil { .. } => {
                raster::pencil_line(&mut stroke.mask, from.pixel(), to.pixel())
            }
            StrokeTool::Paintbrush(s) | StrokeTool::Eraser(s) | StrokeTool::CloneStamp(s) => {
                s.tip().stamp_segment(&mut stroke.mask, from, to)
            }
            StrokeTool::Recolor(s) => BrushTip {
                width: s.width,
                hardness: 1.0,
                antialias: s.antialias,
            }
            .stamp_segment(&mut stroke.mask, from, to),
        };
        let mask = &stroke.mask;
        let coverage = |x: i32, y: i32| mask.get(x, y);
        let (color, other) = (stroke.color, stroke.other);
        match stroke.tool {
            StrokeTool::Pencil { alpha_blending } => {
                self.paint_region(rect, coverage, |o, _, _, _| {
                    if alpha_blending {
                        over(o, color)
                    } else {
                        color
                    }
                })
            }
            StrokeTool::Paintbrush(s) => self.paint_region(rect, coverage, |o, c, _, _| {
                if s.alpha_blending {
                    over(o, color.with_alpha(mul255(color.a as u32, c as u32) as u8))
                } else {
                    lerp(o, color, c)
                }
            }),
            StrokeTool::Eraser(_) => self.paint_region(rect, coverage, |o, c, _, _| {
                let strength = mul255(c as u32, color.a as u32);
                o.with_alpha(mul255(o.a as u32, 255 - strength) as u8)
            }),
            StrokeTool::CloneStamp(_) => {
                let Some((source, (dx, dy))) = stroke.clone else {
                    return Ok(());
                };
                let sample = self.clone_sample(source.layer, rect.translate(dx, dy));
                let a = self.colors.primary.a as f32 / 255.0;
                let opacity = (a.powi(4) * 255.0).round() as u32;
                self.paint_region(rect, coverage, |o, c, x, y| {
                    let s = sample
                        .as_ref()
                        .and_then(|(surface, origin)| {
                            surface.get(x + dx - origin.0, y + dy - origin.1)
                        })
                        .unwrap_or(Rgba8::TRANSPARENT);
                    let alpha = mul255(s.a as u32, mul255(c as u32, opacity));
                    over(o, s.with_alpha(alpha as u8))
                })
            }
            StrokeTool::Recolor(s) => {
                let tolerance = ((s.tolerance * 256.0) as u32).min(color_difference(color, other));
                self.paint_region(rect, coverage, |o, c, _, _| {
                    if color_difference(o, other) > tolerance {
                        return o;
                    }
                    let shift = |v: u8, to: u8, from: u8| {
                        (v as i32 + to as i32 - from as i32).clamp(0, 255) as u8
                    };
                    let shifted = Rgba8::new(
                        shift(o.r, color.r, other.r),
                        shift(o.g, color.g, other.g),
                        shift(o.b, color.b, other.b),
                        o.a,
                    );
                    lerp(o, shifted, c)
                })
            }
        }
    }

    /// The source pixels Clone Stamp needs for `rect`: the source
    /// layer as it was before this stroke.
    fn clone_sample(&self, layer: usize, rect: Rect) -> Option<(Surface, (i32, i32))> {
        let rect = rect.intersect(self.bounds());
        if rect.is_empty() {
            return None;
        }
        let surface = &self.layers.get(layer)?.surface;
        let mut out = surface.crop(rect);
        if let Some(edit) = self.edit.as_ref().filter(|e| e.layer == layer) {
            for y in rect.y..rect.bottom() {
                for x in rect.x..rect.right() {
                    out.set(x - rect.x, y - rect.y, edit.backup.original(surface, x, y));
                }
            }
        }
        Some((out, (rect.x, rect.y)))
    }

    // ---- Color Picker ------------------------------------------------

    /// The active layer's pixel under `at`.
    pub fn pick_color(&self, at: PointF) -> Option<Rgba8> {
        let (x, y) = at.pixel();
        self.layers[self.active].surface.get(x, y)
    }

    /// Color Picker click: the pixel into the primary (left) or
    /// secondary (right) colour. Returns the picked colour.
    pub fn pick_color_into(&mut self, at: PointF, button: Button) -> Option<Rgba8> {
        let color = self.pick_color(at)?;
        match button {
            Button::Primary => self.colors.primary = color,
            Button::Secondary => self.colors.secondary = color,
        }
        self.bump();
        Some(color)
    }

    // ---- Paint Bucket ------------------------------------------------

    /// Paint Bucket click; `shift` swaps Local and Global as in the
    /// source. A click outside the selection does nothing.
    pub fn fill(
        &mut self,
        at: PointF,
        settings: &FillSettings,
        button: Button,
        shift: bool,
    ) -> Result<()> {
        settings.validate()?;
        let (x, y) = at.pixel();
        if self.selection.coverage(x, y) == 0 {
            return Ok(());
        }
        let contiguous = (settings.mode == FloodMode::Local) != shift;
        let (color, _) = self.colors.for_button(button);
        let blending = settings.alpha_blending;
        let tolerance = settings.tolerance;
        self.run_edit("Paint Bucket", move |doc| {
            // Inside a preview the layer is back to its originals here, so
            // the flood sees them and not the previous preview.
            let layer = doc.edit_layer();
            let stencil = flood_stencil(
                &doc.layers[layer].surface,
                (x, y),
                tolerance,
                contiguous,
                &doc.selection,
            );
            let rect = stencil.bounds();
            doc.paint_region(
                rect,
                |x, y| stencil.get(x, y),
                |o, c, _, _| {
                    if blending {
                        over(o, color.with_alpha(mul255(color.a as u32, c as u32) as u8))
                    } else {
                        lerp(o, color, c)
                    }
                },
            )
        })
    }

    // ---- Gradient ------------------------------------------------------

    /// Gradient from `start` to `end`: left button from primary to
    /// secondary, right the other way.
    pub fn gradient(
        &mut self,
        start: PointF,
        end: PointF,
        settings: &GradientSettings,
        button: Button,
    ) -> Result<()> {
        let (from, to) = self.colors.for_button(button);
        let shape = GradientShape::new(settings.kind, start, end);
        let colors: Vec<Rgba8> = (0..=255u8).map(|t| blend_toward(from, to, t)).collect();
        // The source's alpha-only range: start alpha to 255 − end alpha.
        let (alpha_from, alpha_to) = (from.a as i32, 255 - to.a as i32);
        let alphas: Vec<u8> = (0..=255i32)
            .map(|t| (alpha_from + (alpha_to - alpha_from) * t / 255) as u8)
            .collect();
        let settings = *settings;
        let opaque = from.a == 255 && to.a == 255;
        self.run_edit("Gradient", move |doc| {
            doc.paint_region(
                doc.bounds(),
                |_, _| 255,
                |o, c, x, y| {
                    let t = (shape.t(x as f32, y as f32) * 255.0) as usize;
                    let value = if settings.transparency {
                        let a = alphas[t];
                        if settings.alpha_blending {
                            o.with_alpha(mul255(o.a as u32, a as u32) as u8)
                        } else {
                            o.with_alpha(a)
                        }
                    } else if settings.alpha_blending && !opaque {
                        over(o, colors[t])
                    } else {
                        colors[t]
                    };
                    if c == 255 {
                        value
                    } else {
                        lerp(o, value, c)
                    }
                },
            )
        })
    }

    // ---- shapes --------------------------------------------------------

    /// Line / Curve, Rectangle, Rounded Rectangle, Ellipse, Freeform
    /// Shape. Left: outline in the primary, interior in the secondary;
    /// right swaps them; an interior-only shape fills with the primary.
    pub fn draw_shape(
        &mut self,
        shape: &Shape,
        settings: &ShapeSettings,
        button: Button,
    ) -> Result<()> {
        if !(1.0..=MAX_BRUSH_WIDTH).contains(&settings.width) {
            return Err(invalid("shape width is outside 1..=500"));
        }
        let (mut outline_color, mut interior_color) = self.colors.for_button(button);
        let draw = if matches!(shape, Shape::Line { .. }) {
            ShapeDraw::Outline
        } else {
            settings.draw
        };
        if draw == ShapeDraw::Interior {
            std::mem::swap(&mut outline_color, &mut interior_color);
        }
        let canvas = self.bounds();
        let (outline, interior) = shape_masks(shape, settings, draw, canvas)?;
        let rect = outline
            .as_ref()
            .map_or(Rect::default(), Mask::rect)
            .union(interior.as_ref().map_or(Rect::default(), Mask::rect));
        let blending = settings.alpha_blending;
        let put = move |o: Rgba8, color: Rgba8, c: u8| {
            if blending {
                over(o, color.with_alpha(mul255(color.a as u32, c as u32) as u8))
            } else {
                lerp(o, color, c)
            }
        };
        self.run_edit(shape.name(), move |doc| {
            let selection_bounds = doc.selection.bounds();
            doc.paint_region_raw(rect.intersect(selection_bounds), |o, selected, x, y| {
                let mut p = o;
                if let Some(m) = &interior {
                    let c = mul255(m.get(x, y) as u32, selected as u32) as u8;
                    if c > 0 {
                        p = put(p, interior_color, c);
                    }
                }
                if let Some(m) = &outline {
                    let c = mul255(m.get(x, y) as u32, selected as u32) as u8;
                    if c > 0 {
                        p = put(p, outline_color, c);
                    }
                }
                p
            })
        })
    }

    // ---- Move Selected Pixels / Move Selection --------------------

    /// Starts Move Selected Pixels: lifts the selected pixels of the
    /// active layer (the whole layer without a selection). Without
    /// `copy` (Ctrl) the place they leave becomes the secondary colour
    /// with alpha 0.
    pub fn lift_selection(&mut self, copy: bool) -> Result<()> {
        self.finish_pending()?;
        let bounds = self.selection.bounds();
        if bounds.is_empty() {
            return Err(Error::NoSelection);
        }
        let surface = &self.layers[self.active].surface;
        let mut floating = surface.crop(bounds);
        for y in bounds.y..bounds.bottom() {
            for x in bounds.x..bounds.right() {
                let c = self.selection.coverage(x, y);
                let p = surface.at(x, y);
                floating.set(
                    x - bounds.x,
                    y - bounds.y,
                    p.with_alpha(mul255(p.a as u32, c as u32) as u8),
                );
            }
        }
        let base = if self.selection.is_active() {
            self.selection.clone()
        } else {
            Selection::all(self.bounds())
        };
        let lift = Lift {
            floating,
            origin: (bounds.x, bounds.y),
            offset: (0, 0),
            turn: 0.0,
            scale: (1.0, 1.0),
            resampling: Resampling::Bilinear,
            base,
            erase: !copy,
            vacate: self.colors.secondary.with_alpha(0),
        };
        self.open_edit("Move Selected Pixels", EditKind::Lift(Box::new(lift)))?;
        self.render_lift()
    }

    /// Paste (Ctrl+V): the clip becomes lifted pixels on the active
    /// layer, at its place if it fits the canvas, else centred.
    pub fn paste(&mut self, clip: &crate::clipboard::Clip) -> Result<()> {
        self.finish_pending()?;
        let size = clip.surface.bounds();
        let (clip_x, clip_y) = (sane_offset(clip.x), sane_offset(clip.y));
        let placed = size.translate(clip_x, clip_y);
        let origin = if self.bounds().intersect(placed) == placed {
            (clip_x, clip_y)
        } else {
            (
                (self.width as i32 - size.width as i32) / 2,
                (self.height as i32 - size.height as i32) / 2,
            )
        };
        let mut shape = Mask::new(self.bounds());
        for y in 0..size.height as i32 {
            for x in 0..size.width as i32 {
                if clip.surface.at(x, y).a > 0 {
                    shape.set(x + origin.0, y + origin.1, 255);
                }
            }
        }
        let lift = Lift {
            floating: clip.surface.clone(),
            origin,
            offset: (0, 0),
            turn: 0.0,
            scale: (1.0, 1.0),
            resampling: Resampling::Bilinear,
            base: Selection::from_mask(shape),
            erase: false,
            vacate: Rgba8::CLEARED,
        };
        self.open_edit("Paste", EditKind::Lift(Box::new(lift)))?;
        self.render_lift()
    }

    /// Whether pixels are lifted (Move Selected Pixels or a paste).
    pub fn is_lifted(&self) -> bool {
        matches!(self.edit.as_ref().map(|e| &e.kind), Some(EditKind::Lift(_)))
    }

    /// Where the lifted pixels stand from where they were lifted, while
    /// they are lifted.
    pub fn lift_offset(&self) -> Option<(i32, i32)> {
        match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Lift(lift)) => Some(lift.offset),
            _ => None,
        }
    }

    /// Places the lifted pixels at `(dx, dy)` from where they were
    /// lifted; the selection follows.
    pub fn move_lifted(&mut self, dx: i32, dy: i32) -> Result<()> {
        match self.edit.as_mut().map(|e| &mut e.kind) {
            Some(EditKind::Lift(lift)) => lift.offset = (sane_offset(dx), sane_offset(dy)),
            _ => return Err(Error::NothingLifted),
        }
        self.render_lift()
    }

    /// How the lifted pixels stand, while they are lifted.
    pub fn lift_transform(&self) -> Option<LiftTransform> {
        match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Lift(lift)) => Some(LiftTransform {
                offset: lift.offset,
                turn: lift.turn,
                scale: lift.scale,
            }),
            _ => None,
        }
    }

    /// The lifted pixels' handles (see [`HANDLE_SIDES`]); none when
    /// nothing is lifted.
    pub fn lift_handles(&self) -> Vec<PointF> {
        match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Lift(lift)) => lift.handles(),
            _ => Vec::new(),
        }
    }

    /// The lifted fragment's centre on the image now and its size as
    /// lifted.
    pub fn lift_frame(&self) -> Option<(PointF, (f32, f32))> {
        match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Lift(lift)) => Some((
                lift.place(PointF::default()),
                (lift.floating.width() as f32, lift.floating.height() as f32),
            )),
            _ => None,
        }
    }

    /// Moves, turns and scales the lifted pixels (shown nearest neighbour;
    /// `resampling` applies when they land).
    pub fn transform_lifted(&mut self, t: LiftTransform, resampling: Resampling) -> Result<()> {
        if !(t.turn.is_finite() && t.scale.0.is_finite() && t.scale.1.is_finite()) {
            return Err(invalid("the transform is not a number"));
        }
        match self.edit.as_mut().map(|e| &mut e.kind) {
            Some(EditKind::Lift(lift)) => {
                lift.offset = (sane_offset(t.offset.0), sane_offset(t.offset.1));
                lift.turn = t.turn % std::f32::consts::TAU;
                // At least a pixel across, at most a sane size; a negative
                // scale (a handle dragged across) mirrors.
                let fit = |s: f32, n: u32| {
                    let min = 1.0 / n.max(1) as f32;
                    s.abs().clamp(min, MAX_LIFT_SCALE).copysign(s)
                };
                lift.scale = (
                    fit(t.scale.0, lift.floating.width()),
                    fit(t.scale.1, lift.floating.height()),
                );
                lift.resampling = resampling;
            }
            _ => return Err(Error::NothingLifted),
        }
        self.render_lift()
    }

    /// The arrow keys: moves lifted pixels by a step (lifting the
    /// selection first if nothing is lifted).
    pub fn nudge_lifted(&mut self, dx: i32, dy: i32) -> Result<()> {
        if !self.is_lifted() {
            self.lift_selection(false)?;
        }
        let current = match self.edit.as_ref().map(|e| &e.kind) {
            Some(EditKind::Lift(lift)) => lift.offset,
            _ => (0, 0),
        };
        self.move_lifted(current.0 + dx, current.1 + dy)
    }

    /// Enter or a tool change: drops the lifted pixels, one step; a turned
    /// or scaled fragment is resampled as it lands.
    pub fn finish_move(&mut self) -> Result<()> {
        if self.is_lifted() {
            self.render_lift_with(true)?;
            self.commit_edit()?;
        }
        Ok(())
    }

    fn render_lift(&mut self) -> Result<()> {
        self.render_lift_with(false)
    }

    fn render_lift_with(&mut self, landing: bool) -> Result<()> {
        let plain = matches!(
            self.edit.as_ref().map(|e| &e.kind),
            Some(EditKind::Lift(lift)) if lift.is_plain()
        );
        if !plain {
            return self.render_transformed(landing);
        }
        let Some(edit) = self.edit.as_mut() else {
            return Err(Error::NothingLifted);
        };
        let EditKind::Lift(lift) = std::mem::replace(&mut edit.kind, EditKind::Plain) else {
            return Err(Error::NothingLifted);
        };
        self.restore_edit();
        let (fx, fy) = (lift.origin.0 + lift.offset.0, lift.origin.1 + lift.offset.1);
        let placed = lift.floating.bounds().translate(fx, fy);
        let base_bounds = lift.base.bounds();
        let rect = placed.union(if lift.erase {
            base_bounds
        } else {
            Rect::default()
        });
        let result = self.paint_region_raw(rect, |o, _, x, y| {
            let mut p = o;
            if lift.erase {
                let c = lift.base.coverage(x, y);
                if c == 255 {
                    p = lift.vacate;
                } else if c > 0 {
                    p = p.with_alpha(mul255(p.a as u32, 255 - c as u32) as u8);
                }
            }
            match lift.floating.get(x - fx, y - fy) {
                Some(f) if f.a > 0 => over(p, f),
                _ => p,
            }
        });
        self.selection = lift.base.translated(lift.offset.0, lift.offset.1);
        if let Some(edit) = self.edit.as_mut() {
            edit.kind = EditKind::Lift(lift);
        }
        result
    }

    /// A turned or scaled fragment: every pixel of its box on the image is
    /// sampled back from the fragment (nearest while it moves); the
    /// selection is the base sampled the same way.
    fn render_transformed(&mut self, landing: bool) -> Result<()> {
        let Some(edit) = self.edit.as_mut() else {
            return Err(Error::NothingLifted);
        };
        let EditKind::Lift(lift) = std::mem::replace(&mut edit.kind, EditKind::Plain) else {
            return Err(Error::NothingLifted);
        };
        self.restore_edit();
        let mut placed = Rect::default();
        for p in lift.handles() {
            placed = placed.union(Rect::covering(p.x, p.y, p.x, p.y));
        }
        let placed = placed.intersect(self.bounds());
        let smooth = landing && lift.resampling == Resampling::Bilinear;
        let (w, h) = (lift.floating.width() as f32, lift.floating.height() as f32);
        let inside = |q: PointF| q.x >= 0.0 && q.y >= 0.0 && q.x < w && q.y < h;
        let sample = |x: i32, y: i32| -> Option<Rgba8> {
            let q = lift.source_of(PointF::new(x as f32 + 0.5, y as f32 + 0.5));
            if !inside(q) {
                return None;
            }
            Some(if smooth {
                lift.floating.bilinear(q.x - 0.5, q.y - 0.5)
            } else {
                lift.floating.at(q.x as i32, q.y as i32)
            })
        };
        let rect = placed.union(if lift.erase {
            lift.base.bounds()
        } else {
            Rect::default()
        });
        let result = self.paint_region_raw(rect, |o, _, x, y| {
            let mut p = o;
            if lift.erase {
                let c = lift.base.coverage(x, y);
                if c == 255 {
                    p = lift.vacate;
                } else if c > 0 {
                    p = p.with_alpha(mul255(p.a as u32, 255 - c as u32) as u8);
                }
            }
            match sample(x, y) {
                Some(f) if f.a > 0 => over(p, f),
                _ => p,
            }
        });
        // While it moves, the selection covers only the fragment (nothing
        // else reads it before it lands); landed, it spans the canvas again.
        let mut shape = Mask::new(if landing { self.bounds() } else { placed });
        let (ox, oy) = lift.origin;
        for y in placed.y..placed.bottom() {
            for x in placed.x..placed.right() {
                let q = lift.source_of(PointF::new(x as f32 + 0.5, y as f32 + 0.5));
                if inside(q) {
                    let c = lift.base.coverage(ox + q.x as i32, oy + q.y as i32);
                    if c > 0 {
                        shape.set(x, y, c);
                    }
                }
            }
        }
        self.selection = Selection::from_mask(shape);
        if let Some(edit) = self.edit.as_mut() {
            edit.kind = EditKind::Lift(lift);
        }
        result
    }

    /// Starts Move Selection: the outline moves, pixels stay.
    pub fn begin_move_selection(&mut self) -> Result<()> {
        self.finish_pending()?;
        if !self.selection.is_active() {
            return Err(Error::NoSelection);
        }
        let base = self.selection.clone();
        self.open_edit("Move Selection", EditKind::MoveSelection { base })
    }

    /// Places the outline at `(dx, dy)` from where the move started;
    /// [`Document::commit_edit`] ends it.
    pub fn move_selection_to(&mut self, dx: i32, dy: i32) -> Result<()> {
        let Some(EditKind::MoveSelection { base }) = self.edit.as_ref().map(|e| &e.kind) else {
            return Err(Error::NoEdit);
        };
        self.selection = base.translated(sane_offset(dx), sane_offset(dy));
        self.bump();
        Ok(())
    }
}

pub(crate) struct Lift {
    floating: Surface,
    origin: (i32, i32),
    offset: (i32, i32),
    /// Rotation about the fragment's centre, radians, clockwise on screen.
    turn: f32,
    /// Scale along the fragment's own axes (before the turn).
    scale: (f32, f32),
    /// How a turned or scaled fragment is resampled when it lands; while
    /// it moves, nearest neighbour.
    resampling: Resampling,
    base: Selection,
    erase: bool,
    vacate: Rgba8,
}

/// Where lifted pixels stand: moved, turned about their centre and
/// scaled along their own axes.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct LiftTransform {
    pub offset: (i32, i32),
    pub turn: f32,
    pub scale: (f32, f32),
}

/// Larger than this many times its own size a fragment is not scaled.
const MAX_LIFT_SCALE: f32 = 64.0;

/// The handles' sides of the box, as [`Document::lift_handles`] orders
/// them: corners and edge middles clockwise from the top-left.
pub const HANDLE_SIDES: [(f32, f32); 8] = [
    (-1.0, -1.0),
    (0.0, -1.0),
    (1.0, -1.0),
    (1.0, 0.0),
    (1.0, 1.0),
    (0.0, 1.0),
    (-1.0, 1.0),
    (-1.0, 0.0),
];

impl Lift {
    fn is_plain(&self) -> bool {
        self.turn == 0.0 && self.scale == (1.0, 1.0)
    }

    fn half(&self) -> (f32, f32) {
        (
            self.floating.width() as f32 / 2.0,
            self.floating.height() as f32 / 2.0,
        )
    }

    /// The fragment's centre where it was lifted.
    fn centre(&self) -> PointF {
        let (hw, hh) = self.half();
        PointF::new(self.origin.0 as f32 + hw, self.origin.1 as f32 + hh)
    }

    /// The image point of a point given relative to the fragment's centre
    /// in its own (unscaled, unturned) frame.
    fn place(&self, local: PointF) -> PointF {
        let c = self.centre();
        let (sin, cos) = self.turn.sin_cos();
        let (x, y) = (local.x * self.scale.0, local.y * self.scale.1);
        PointF::new(
            c.x + self.offset.0 as f32 + x * cos - y * sin,
            c.y + self.offset.1 as f32 + x * sin + y * cos,
        )
    }

    /// The inverse: an image point to the fragment's pixel coordinates.
    fn source_of(&self, p: PointF) -> PointF {
        let c = self.centre();
        let (sin, cos) = self.turn.sin_cos();
        let dx = p.x - c.x - self.offset.0 as f32;
        let dy = p.y - c.y - self.offset.1 as f32;
        let (x, y) = (dx * cos + dy * sin, -dx * sin + dy * cos);
        let (hw, hh) = self.half();
        PointF::new(x / self.scale.0 + hw, y / self.scale.1 + hh)
    }

    fn handles(&self) -> Vec<PointF> {
        let (hw, hh) = self.half();
        HANDLE_SIDES
            .iter()
            .map(|&(sx, sy)| self.place(PointF::new(sx * hw, sy * hh)))
            .collect()
    }
}

// ---- flood fill -------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum FloodMode {
    /// Only the connected area.
    #[default]
    Local,
    /// Every matching pixel of the layer.
    Global,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct FillSettings {
    pub mode: FloodMode,
    /// 0 – 1, typically 0.5.
    pub tolerance: f32,
    pub antialias: bool,
    pub alpha_blending: bool,
}

impl Default for FillSettings {
    fn default() -> Self {
        Self {
            mode: FloodMode::Local,
            tolerance: 0.5,
            antialias: true,
            alpha_blending: true,
        }
    }
}

impl FillSettings {
    pub(crate) fn validate(&self) -> Result<()> {
        if !(0.0..=1.0).contains(&self.tolerance) {
            return Err(invalid("tolerance is outside 0..=1"));
        }
        Ok(())
    }
}

/// `FloodToolBase.CheckColor`: whether `b` is close to the sample `a`.
#[inline]
pub(crate) fn within_tolerance(a: Rgba8, b: Rgba8, tolerance: i64) -> bool {
    let term = |x: u8, y: u8| {
        let diff = x as i64 - y as i64;
        (1 + diff * diff) * a.a as i64 / 256
    };
    let da = a.a as i64 - b.a as i64;
    let sum = term(a.r, b.r) + term(a.g, b.g) + term(a.b, b.b) + da * da;
    sum <= tolerance * tolerance * 4
}

/// The pixels a Paint Bucket or Magic Wand click reaches: contiguous
/// (scanline flood) or global, inside the selection. Hard-edged.
pub(crate) fn flood_stencil(
    surface: &Surface,
    start: (i32, i32),
    tolerance: f32,
    contiguous: bool,
    limit: &Selection,
) -> Mask {
    let mut stencil = Mask::new(surface.bounds());
    let Some(sample) = surface.get(start.0, start.1) else {
        return stencil;
    };
    let tolerance = (tolerance * tolerance * 256.0) as i64;
    let matches = |x: i32, y: i32| {
        limit.coverage(x, y) > 0 && within_tolerance(sample, surface.at(x, y), tolerance)
    };
    if !contiguous {
        for y in 0..surface.height() as i32 {
            for x in 0..surface.width() as i32 {
                if matches(x, y) {
                    stencil.set(x, y, 255);
                }
            }
        }
        return stencil;
    }
    let width = surface.width() as i32;
    let height = surface.height() as i32;
    let mut stack = vec![start];
    while let Some((x, y)) = stack.pop() {
        if stencil.get(x, y) != 0 || !matches(x, y) {
            continue;
        }
        let mut left = x;
        while left > 0 && stencil.get(left - 1, y) == 0 && matches(left - 1, y) {
            left -= 1;
        }
        let mut right = x;
        while right + 1 < width && stencil.get(right + 1, y) == 0 && matches(right + 1, y) {
            right += 1;
        }
        for sx in left..=right {
            stencil.set(sx, y, 255);
        }
        for ny in [y - 1, y + 1] {
            if ny < 0 || ny >= height {
                continue;
            }
            let mut sx = left;
            while sx <= right {
                if stencil.get(sx, ny) == 0 && matches(sx, ny) {
                    stack.push((sx, ny));
                    while sx <= right && matches(sx, ny) {
                        sx += 1;
                    }
                }
                sx += 1;
            }
        }
    }
    stencil
}

// ---- gradient -----------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum GradientKind {
    #[default]
    Linear,
    LinearReflected,
    Diamond,
    Radial,
    Conical,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct GradientSettings {
    pub kind: GradientKind,
    /// Transparency mode: only the layer's alpha changes.
    pub transparency: bool,
    pub alpha_blending: bool,
}

impl Default for GradientSettings {
    fn default() -> Self {
        Self {
            kind: GradientKind::Linear,
            transparency: false,
            alpha_blending: true,
        }
    }
}

/// `GradientRenderers`: the parameter `t` in `[0, 1]` for a point.
#[derive(Debug, Clone, Copy)]
struct GradientShape {
    kind: GradientKind,
    start: PointF,
    dtdx: f32,
    dtdy: f32,
    inv_distance: f32,
    cone_offset: f32,
    degenerate: bool,
}

impl GradientShape {
    fn new(kind: GradientKind, start: PointF, end: PointF) -> Self {
        let (start, end) = (start.sanitized(), end.sanitized());
        let (vx, vy) = (end.x - start.x, end.y - start.y);
        let mag_sq = vx * vx + vy * vy;
        let degenerate = mag_sq == 0.0;
        let mut shape = Self {
            kind,
            start,
            dtdx: if degenerate { 0.0 } else { vx / mag_sq },
            dtdy: if degenerate { 0.0 } else { vy / mag_sq },
            inv_distance: if degenerate { 0.0 } else { 1.0 / mag_sq.sqrt() },
            cone_offset: 0.0,
            degenerate,
        };
        if kind == GradientKind::Conical {
            shape.cone_offset = -shape.unbounded(end.x.trunc(), end.y.trunc());
        }
        shape
    }

    fn unbounded(&self, x: f32, y: f32) -> f32 {
        let dx = x - self.start.x;
        let dy = y - self.start.y;
        match self.kind {
            GradientKind::Linear | GradientKind::LinearReflected => dx * self.dtdx + dy * self.dtdy,
            GradientKind::Diamond => {
                let t1 = dx * self.dtdx + dy * self.dtdy;
                let t2 = dx * self.dtdy - dy * self.dtdx;
                t1.abs() + t2.abs()
            }
            GradientKind::Radial => (dx * dx + dy * dy).sqrt() * self.inv_distance,
            GradientKind::Conical => dy.atan2(dx) / std::f32::consts::PI + self.cone_offset,
        }
    }

    fn t(&self, x: f32, y: f32) -> f32 {
        if self.degenerate {
            return 1.0;
        }
        let t = self.unbounded(x, y);
        match self.kind {
            GradientKind::LinearReflected => t.abs().clamp(0.0, 1.0),
            GradientKind::Conical => {
                let t = if t > 1.0 {
                    t - 2.0
                } else if t < -1.0 {
                    t + 2.0
                } else {
                    t
                };
                t.abs().clamp(0.0, 1.0)
            }
            _ => t.clamp(0.0, 1.0),
        }
    }
}

// ---- shapes ---------------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum ShapeDraw {
    #[default]
    Outline,
    Interior,
    Both,
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct ShapeSettings {
    pub draw: ShapeDraw,
    pub width: f32,
    pub antialias: bool,
    pub alpha_blending: bool,
    pub line_start: LineCap,
    pub line_end: LineCap,
    pub dash: DashStyle,
}

impl Default for ShapeSettings {
    fn default() -> Self {
        Self {
            draw: ShapeDraw::Outline,
            width: 2.0,
            antialias: true,
            alpha_blending: true,
            line_start: LineCap::Flat,
            line_end: LineCap::Flat,
            dash: DashStyle::Solid,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum Curve {
    #[default]
    Straight,
    /// A cardinal spline through the points (handles dragged with the
    /// left button).
    Spline,
    /// The points as Bézier controls (handles dragged with the right).
    Bezier,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Shape {
    /// Two points for a straight line; four control points for a curve.
    Line {
        points: Vec<PointF>,
        curve: Curve,
    },
    Rectangle {
        a: PointF,
        b: PointF,
    },
    RoundedRectangle {
        a: PointF,
        b: PointF,
        radius: f32,
    },
    Ellipse {
        a: PointF,
        b: PointF,
    },
    Freeform {
        points: Vec<PointF>,
    },
}

impl Shape {
    pub fn name(&self) -> &'static str {
        match self {
            Shape::Line { .. } => "Line / Curve",
            Shape::Rectangle { .. } => "Rectangle",
            Shape::RoundedRectangle { .. } => "Rounded Rectangle",
            Shape::Ellipse { .. } => "Ellipse",
            Shape::Freeform { .. } => "Freeform Shape",
        }
    }
}

type ShapeMasks = (Option<Mask>, Option<Mask>);

fn shape_masks(
    shape: &Shape,
    settings: &ShapeSettings,
    draw: ShapeDraw,
    canvas: Rect,
) -> Result<ShapeMasks> {
    let half = settings.width * 0.5;
    let aa = settings.antialias;
    let stroke_path = |path: &[PointF], closed: bool| {
        let tip = BrushTip {
            width: settings.width,
            hardness: 1.0,
            antialias: aa,
        };
        let mut bounds = Rect::default();
        for p in path {
            bounds = bounds.union(Rect::covering(p.x, p.y, p.x, p.y));
        }
        let mut mask = Mask::new(
            bounds
                .inflate(settings.width.ceil() as i32 + 2)
                .intersect(canvas),
        );
        for pair in path.windows(2) {
            tip.stamp_segment(&mut mask, pair[0], pair[1]);
        }
        if closed && path.len() > 2 {
            tip.stamp_segment(&mut mask, path[path.len() - 1], path[0]);
        }
        mask
    };
    let (path, a, b, convex) = match shape {
        Shape::Line { points, curve } => {
            if points.len() < 2 {
                return Err(invalid("a line needs two points"));
            }
            let path = match (curve, points.len()) {
                (Curve::Bezier, 4) => {
                    raster::bezier_path([points[0], points[1], points[2], points[3]])
                }
                (Curve::Spline, _) => raster::spline_path(points),
                _ => points.clone(),
            };
            let line = crate::stroke::stroke_line(
                &path,
                settings.width,
                settings.line_start,
                settings.line_end,
                settings.dash,
                aa,
                canvas,
            );
            return Ok((Some(line), None));
        }
        Shape::Freeform { points } => {
            if points.len() < 2 {
                return Err(invalid("a freeform shape needs two points"));
            }
            (points.clone(), PointF::default(), PointF::default(), false)
        }
        Shape::Rectangle { a, b } => (raster::rectangle_path(*a, *b), *a, *b, true),
        Shape::RoundedRectangle { a, b, radius } => (
            raster::rounded_rectangle_path(*a, *b, *radius),
            *a,
            *b,
            true,
        ),
        Shape::Ellipse { a, b } => (raster::ellipse_path(*a, *b), *a, *b, true),
    };
    let interior = matches!(draw, ShapeDraw::Interior | ShapeDraw::Both)
        .then(|| raster::fill_polygon_even_odd(std::slice::from_ref(&path), canvas, aa));
    let outline = matches!(draw, ShapeDraw::Outline | ShapeDraw::Both).then(|| {
        if !convex {
            return stroke_path(&path, true);
        }
        let outer = raster::offset_convex(&path, a, b, half);
        let inner = raster::offset_convex(&path, a, b, -half);
        let thin = (b.x - a.x).abs() <= settings.width || (b.y - a.y).abs() <= settings.width;
        if thin {
            raster::fill_polygon(&[outer], canvas, aa)
        } else {
            let mut inner = inner;
            inner.reverse();
            raster::fill_polygon(&[outer, inner], canvas, aa)
        }
    });
    Ok((outline, interior))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn doc() -> Document {
        Document::new(64, 48, Rgba8::WHITE).unwrap()
    }

    fn at(d: &Document, x: i32, y: i32) -> Rgba8 {
        d.layers()[d.active_layer_index()].surface().at(x, y)
    }

    fn p(x: f32, y: f32) -> PointF {
        PointF::new(x, y)
    }

    #[test]
    fn pencil_draws_one_pixel_lines_in_the_button_colour() {
        let mut d = doc();
        let tool = StrokeTool::Pencil {
            alpha_blending: true,
        };
        d.begin_stroke(tool, Button::Primary, p(2.5, 2.5)).unwrap();
        d.stroke_to(p(10.5, 2.5)).unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 6, 2), Rgba8::BLACK);
        assert_eq!(at(&d, 6, 3), Rgba8::WHITE);
        assert_eq!(d.history_names(), ["New Image", "Pencil"]);
        d.undo().unwrap();
        assert_eq!(at(&d, 6, 2), Rgba8::WHITE);
    }

    #[test]
    fn a_translucent_brush_stroke_has_no_beads_where_segments_meet() {
        let mut d = doc();
        d.set_colors(crate::UserColors {
            primary: Rgba8::new(0, 0, 0, 128),
            secondary: Rgba8::WHITE,
        });
        let tool = StrokeTool::Paintbrush(BrushSettings {
            width: 6.0,
            ..BrushSettings::default()
        });
        d.begin_stroke(tool, Button::Primary, p(5.0, 20.5)).unwrap();
        for x in [10.0, 15.0, 20.0, 25.0, 30.0] {
            d.stroke_to(p(x, 20.5)).unwrap();
        }
        d.end_stroke().unwrap();
        let mid = at(&d, 15, 20);
        assert_eq!(at(&d, 12, 20), mid);
        assert_eq!(at(&d, 20, 20), mid);
        assert!(mid.r > 120 && mid.r < 135, "{mid:?}");
    }

    #[test]
    fn right_button_paints_with_the_secondary_colour() {
        let mut d = doc();
        d.add_layer().unwrap();
        let tool = StrokeTool::Paintbrush(BrushSettings::default());
        d.begin_stroke(tool, Button::Secondary, p(10.5, 10.5))
            .unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 10, 10), Rgba8::WHITE);
    }

    #[test]
    fn eraser_lowers_alpha_and_keeps_colour() {
        let mut d = doc();
        let tool = StrokeTool::Eraser(BrushSettings {
            width: 4.0,
            antialias: false,
            ..BrushSettings::default()
        });
        d.begin_stroke(tool, Button::Primary, p(10.5, 10.5))
            .unwrap();
        d.stroke_to(p(20.5, 10.5)).unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 15, 10), Rgba8::new(255, 255, 255, 0));
        assert_eq!(at(&d, 15, 20), Rgba8::WHITE);
    }

    #[test]
    fn strokes_are_clipped_to_the_selection() {
        let mut d = doc();
        d.select_rectangle(p(0.0, 0.0), p(10.0, 48.0), crate::CombineMode::Replace)
            .unwrap();
        let tool = StrokeTool::Paintbrush(BrushSettings {
            width: 4.0,
            ..BrushSettings::default()
        });
        d.begin_stroke(tool, Button::Primary, p(2.5, 5.5)).unwrap();
        d.stroke_to(p(30.5, 5.5)).unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 5, 5), Rgba8::BLACK);
        assert_eq!(at(&d, 20, 5), Rgba8::WHITE);
    }

    #[test]
    fn clone_stamp_copies_from_the_source_and_needs_one() {
        let mut d = doc();
        d.layers[0].surface.set(5, 5, Rgba8::opaque(255, 0, 0));
        let tool = StrokeTool::CloneStamp(BrushSettings {
            width: 1.0,
            antialias: false,
            ..BrushSettings::default()
        });
        d.begin_stroke(tool, Button::Primary, p(30.5, 30.5))
            .unwrap();
        assert!(!d.is_editing());
        d.set_clone_source(p(5.5, 5.5));
        d.begin_stroke(tool, Button::Primary, p(30.5, 30.5))
            .unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 30, 30), Rgba8::opaque(255, 0, 0));
        let next = d.clone_source().unwrap().point;
        assert_eq!((next.x, next.y), (5.5, 5.5));
    }

    #[test]
    fn recolor_shifts_colours_near_the_secondary() {
        let mut d = doc();
        d.layers[0].surface.fill(Rgba8::opaque(250, 250, 250));
        d.layers[0].surface.set(20, 20, Rgba8::opaque(0, 0, 0));
        d.set_colors(crate::UserColors {
            primary: Rgba8::opaque(255, 0, 0),
            secondary: Rgba8::WHITE,
        });
        let tool = StrokeTool::Recolor(RecolorSettings {
            width: 30.0,
            antialias: false,
            tolerance: 0.5,
        });
        d.begin_stroke(tool, Button::Primary, p(20.5, 20.5))
            .unwrap();
        d.end_stroke().unwrap();
        assert_eq!(at(&d, 21, 21), Rgba8::opaque(250, 0, 0));
        assert_eq!(at(&d, 20, 20), Rgba8::opaque(0, 0, 0));
    }

    #[test]
    fn tolerance_matches_the_source_formula() {
        let t = |tol: f32| (tol * tol * 256.0) as i64;
        let a = Rgba8::opaque(100, 100, 100);
        assert!(within_tolerance(a, a, t(0.0)) || within_tolerance(a, a, 1));
        assert!(!within_tolerance(a, Rgba8::opaque(101, 100, 100), t(0.0)));
        assert!(within_tolerance(a, Rgba8::opaque(140, 100, 100), t(0.5)));
        // T = 64 at 50%: one channel 100 apart passes, three do not.
        assert!(within_tolerance(a, Rgba8::opaque(200, 100, 100), t(0.5)));
        assert!(!within_tolerance(a, Rgba8::opaque(255, 0, 255), t(0.5)));
        assert!(within_tolerance(a, Rgba8::opaque(255, 0, 255), t(1.0)));
    }

    #[test]
    fn bucket_fills_the_connected_area_or_globally_with_shift() {
        let mut d = doc();
        for y in 0..48 {
            d.layers[0].surface.set(30, y, Rgba8::BLACK);
        }
        d.layers[0].surface.set(50, 5, Rgba8::opaque(250, 250, 250));
        let red = Rgba8::opaque(255, 0, 0);
        d.set_colors(crate::UserColors {
            primary: red,
            secondary: Rgba8::WHITE,
        });
        let settings = FillSettings {
            tolerance: 0.1,
            ..FillSettings::default()
        };
        d.fill(p(5.5, 5.5), &settings, Button::Primary, false)
            .unwrap();
        assert_eq!(at(&d, 10, 40), red);
        assert_eq!(at(&d, 30, 10), Rgba8::BLACK);
        assert_eq!(at(&d, 40, 10), Rgba8::WHITE);
        d.undo().unwrap();
        d.fill(p(5.5, 5.5), &settings, Button::Primary, true)
            .unwrap();
        assert_eq!(at(&d, 40, 10), red);
        // 250 grey is outside 10% of white: a sum of 75 against 16.
        assert_eq!(at(&d, 50, 5), Rgba8::opaque(250, 250, 250));
        assert_eq!(at(&d, 30, 10), Rgba8::BLACK);
    }

    #[test]
    fn gradients_follow_the_source_parameters() {
        let lin = GradientShape::new(GradientKind::Linear, p(0.0, 0.0), p(10.0, 0.0));
        assert_eq!(lin.t(5.0, 3.0), 0.5);
        assert_eq!(lin.t(-5.0, 0.0), 0.0);
        let refl = GradientShape::new(GradientKind::LinearReflected, p(0.0, 0.0), p(10.0, 0.0));
        assert_eq!(refl.t(-5.0, 0.0), 0.5);
        let dia = GradientShape::new(GradientKind::Diamond, p(0.0, 0.0), p(10.0, 0.0));
        assert_eq!(dia.t(3.0, 2.0), 0.5);
        let rad = GradientShape::new(GradientKind::Radial, p(0.0, 0.0), p(10.0, 0.0));
        assert!((rad.t(3.0, 4.0) - 0.5).abs() < 1e-6);
        let cone = GradientShape::new(GradientKind::Conical, p(0.0, 0.0), p(10.0, 0.0));
        assert!(cone.t(10.0, 0.0).abs() < 1e-6);
        assert!((cone.t(-10.0, 0.001) - 1.0).abs() < 1e-3);
        assert!((cone.t(0.0, 10.0) - 0.5).abs() < 1e-6);
    }

    #[test]
    fn gradient_paints_colour_and_transparency_and_previews_in_an_edit() {
        let mut d = doc();
        let settings = GradientSettings::default();
        d.begin_edit("Gradient").unwrap();
        d.gradient(p(0.0, 0.0), p(32.0, 0.0), &settings, Button::Primary)
            .unwrap();
        d.gradient(p(0.0, 0.0), p(64.0, 0.0), &settings, Button::Primary)
            .unwrap();
        d.commit_edit().unwrap();
        assert_eq!(d.history_names().len(), 2);
        // Sampled at the integer pixel position, as the source.
        assert_eq!(at(&d, 0, 0).r, 0);
        let mid = at(&d, 32, 10).r;
        assert!((126..=130).contains(&mid), "{mid}");
        assert_eq!(at(&d, 63, 0).r, 251);
        let alpha = GradientSettings {
            transparency: true,
            ..GradientSettings::default()
        };
        d.gradient(p(0.0, 0.0), p(64.0, 0.0), &alpha, Button::Primary)
            .unwrap();
        // Primary alpha 255 to 255 − secondary alpha (0): fades out.
        assert_eq!(at(&d, 0, 0).a, 255);
        assert!(at(&d, 63, 0).a < 8);
    }

    #[test]
    fn shapes_draw_outline_and_interior_in_their_colours() {
        let mut d = doc();
        let red = Rgba8::opaque(255, 0, 0);
        d.set_colors(crate::UserColors {
            primary: Rgba8::BLACK,
            secondary: red,
        });
        let settings = ShapeSettings {
            draw: ShapeDraw::Both,
            width: 2.0,
            antialias: false,
            alpha_blending: true,
            ..ShapeSettings::default()
        };
        let shape = Shape::Rectangle {
            a: p(10.0, 10.0),
            b: p(30.0, 30.0),
        };
        d.draw_shape(&shape, &settings, Button::Primary).unwrap();
        assert_eq!(at(&d, 10, 20), Rgba8::BLACK);
        assert_eq!(at(&d, 9, 20), Rgba8::BLACK);
        assert_eq!(at(&d, 20, 20), red);
        assert_eq!(at(&d, 7, 20), Rgba8::WHITE);
        d.draw_shape(
            &Shape::Ellipse {
                a: p(40.0, 10.0),
                b: p(60.0, 30.0),
            },
            &ShapeSettings {
                draw: ShapeDraw::Interior,
                ..settings
            },
            Button::Primary,
        )
        .unwrap();
        assert_eq!(at(&d, 50, 20), Rgba8::BLACK);
        let line = Shape::Line {
            points: vec![p(0.0, 40.5), p(63.0, 40.5)],
            curve: Curve::Straight,
        };
        d.draw_shape(&line, &settings, Button::Secondary).unwrap();
        assert_eq!(at(&d, 30, 40), red);
        assert_eq!(d.history_names().len(), 4);
    }

    #[test]
    fn colour_picker_sets_the_button_colour() {
        let mut d = doc();
        d.layers[0].surface.set(3, 4, Rgba8::new(1, 2, 3, 4));
        assert_eq!(
            d.pick_color_into(p(3.5, 4.5), Button::Secondary),
            Some(Rgba8::new(1, 2, 3, 4))
        );
        assert_eq!(d.colors().secondary, Rgba8::new(1, 2, 3, 4));
        assert_eq!(d.pick_color(p(-1.0, 0.0)), None);
    }

    #[test]
    fn move_selected_pixels_lifts_moves_and_leaves_clearance() {
        let mut d = doc();
        d.layers[0].surface.set(5, 5, Rgba8::opaque(0, 0, 255));
        d.select_rectangle(p(5.0, 5.0), p(6.0, 6.0), crate::CombineMode::Replace)
            .unwrap();
        d.lift_selection(false).unwrap();
        d.move_lifted(10, 2).unwrap();
        d.move_lifted(20, 3).unwrap();
        d.finish_move().unwrap();
        assert_eq!(at(&d, 25, 8), Rgba8::opaque(0, 0, 255));
        assert_eq!(at(&d, 15, 7), Rgba8::WHITE);
        assert_eq!(at(&d, 5, 5), Rgba8::new(255, 255, 255, 0));
        assert_eq!(d.selection().bounds(), Rect::new(25, 8, 1, 1));
        assert_eq!(d.history_names().last().unwrap(), "Move Selected Pixels");
        d.undo().unwrap();
        assert_eq!(at(&d, 5, 5), Rgba8::opaque(0, 0, 255));
        assert_eq!(d.selection().bounds(), Rect::new(5, 5, 1, 1));
    }

    #[test]
    fn ctrl_move_copies_and_arrows_nudge() {
        let mut d = doc();
        d.layers[0].surface.set(5, 5, Rgba8::opaque(0, 0, 255));
        d.select_rectangle(p(5.0, 5.0), p(6.0, 6.0), crate::CombineMode::Replace)
            .unwrap();
        d.lift_selection(true).unwrap();
        d.nudge_lifted(1, 0).unwrap();
        d.nudge_lifted(1, 0).unwrap();
        d.finish_move().unwrap();
        assert_eq!(at(&d, 5, 5), Rgba8::opaque(0, 0, 255));
        assert_eq!(at(&d, 7, 5), Rgba8::opaque(0, 0, 255));
    }

    #[test]
    fn move_selection_moves_only_the_outline() {
        let mut d = doc();
        d.select_rectangle(p(0.0, 0.0), p(4.0, 4.0), crate::CombineMode::Replace)
            .unwrap();
        d.begin_move_selection().unwrap();
        d.move_selection_to(10, 10).unwrap();
        d.commit_edit().unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(10, 10, 4, 4));
        assert_eq!(at(&d, 1, 1), Rgba8::WHITE);
        d.undo().unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(0, 0, 4, 4));
    }
}
