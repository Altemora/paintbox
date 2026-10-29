//! The Image menu: Crop to Selection, Resize, Canvas Size, flips,
//! rotations, Flatten. These change the whole canvas, so each step
//! keeps the document before and after.

use serde::{Deserialize, Serialize};

use crate::color::{lerp, Rgba8};
use crate::document::Document;
use crate::error::{Error, Result};
use crate::geom::Rect;
use crate::history::CanvasState;
use crate::layer::{Layer, LayerProperties};
use crate::parallel::for_rows;
use crate::selection::Selection;
use crate::surface::{check_size, Surface};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum Resampling {
    NearestNeighbor,
    /// Bilinear when enlarging, area averaging when shrinking.
    #[default]
    Bilinear,
}

/// Where the old picture sits on a new canvas (Canvas Size).
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum Anchor {
    TopLeft,
    Top,
    TopRight,
    Left,
    #[default]
    Center,
    Right,
    BottomLeft,
    Bottom,
    BottomRight,
}

impl Anchor {
    fn offset(self, old: (u32, u32), new: (u32, u32)) -> (i32, i32) {
        let dx = new.0 as i32 - old.0 as i32;
        let dy = new.1 as i32 - old.1 as i32;
        let (fx, fy) = match self {
            Anchor::TopLeft => (0, 0),
            Anchor::Top => (1, 0),
            Anchor::TopRight => (2, 0),
            Anchor::Left => (0, 1),
            Anchor::Center => (1, 1),
            Anchor::Right => (2, 1),
            Anchor::BottomLeft => (0, 2),
            Anchor::Bottom => (1, 2),
            Anchor::BottomRight => (2, 2),
        };
        (dx * fx / 2, dy * fy / 2)
    }
}

/// `src` resampled to `width × height`, alpha-weighted.
pub fn resample(src: &Surface, width: u32, height: u32, method: Resampling) -> Result<Surface> {
    check_size(width, height)?;
    let mut out = Surface::new(width, height)?;
    let sx = src.width() as f32 / width as f32;
    let sy = src.height() as f32 / height as f32;
    for_rows(out.pixels_mut(), width as usize, |y, line| {
        for (x, pixel) in line.iter_mut().enumerate() {
            let cx = (x as f32 + 0.5) * sx;
            let cy = (y as f32 + 0.5) * sy;
            *pixel = match method {
                Resampling::NearestNeighbor => src.at_clamped(cx as i32, cy as i32),
                Resampling::Bilinear if sx > 1.0 || sy > 1.0 => {
                    area_average(src, cx, cy, sx.max(1.0), sy.max(1.0))
                }
                Resampling::Bilinear => src.bilinear(cx - 0.5, cy - 0.5),
            };
        }
    });
    Ok(out)
}

fn area_average(src: &Surface, cx: f32, cy: f32, w: f32, h: f32) -> Rgba8 {
    let x0 = (cx - w * 0.5).floor().max(0.0) as i32;
    let x1 = ((cx + w * 0.5).ceil() as i32).min(src.width() as i32);
    let y0 = (cy - h * 0.5).floor().max(0.0) as i32;
    let y1 = ((cy + h * 0.5).ceil() as i32).min(src.height() as i32);
    let mut sums = [0u64; 4];
    let mut count = 0u64;
    for y in y0..y1 {
        for x in x0..x1 {
            let c = src.at(x, y);
            let a = c.a as u64;
            sums[0] += c.r as u64 * a;
            sums[1] += c.g as u64 * a;
            sums[2] += c.b as u64 * a;
            sums[3] += a;
            count += 1;
        }
    }
    crate::color::weighted(sums, count)
}

impl Document {
    fn canvas_with(&self, width: u32, height: u32, layers: Vec<Layer>) -> CanvasState {
        CanvasState {
            width,
            height,
            layers,
            selection: Selection::none(Rect::of_size(width, height)).snapshot(),
        }
    }

    fn map_layers(&self, f: impl Fn(&Layer) -> Result<Surface>) -> Result<Vec<Layer>> {
        self.layers
            .iter()
            .map(|l| Ok(Layer::from_surface(l.properties.clone(), f(l)?)))
            .collect()
    }

    /// Crop to Selection (Ctrl+Shift+X): every layer cut to the
    /// selection's bounds; outside its shape pixels become
    /// `(255, 255, 255, 0)`.
    pub fn crop_to_selection(&mut self) -> Result<()> {
        self.finish_pending()?;
        let bounds = self.selection.bounds();
        if !self.selection.is_active() || bounds.is_empty() {
            return Err(Error::NoSelection);
        }
        let selection = &self.selection;
        let layers = self.map_layers(|l| {
            let mut s = l.surface.crop(bounds);
            for y in 0..bounds.height as i32 {
                for x in 0..bounds.width as i32 {
                    let c = selection.coverage(x + bounds.x, y + bounds.y);
                    if c < 255 {
                        s.set(x, y, lerp(s.at(x, y), Rgba8::CLEARED, 255 - c));
                    }
                }
            }
            Ok(s)
        })?;
        let state = self.canvas_with(bounds.width, bounds.height, layers);
        self.replace_canvas("Crop to Selection", state);
        Ok(())
    }

    /// Resize (Ctrl+R): every layer resampled.
    pub fn resize_image(&mut self, width: u32, height: u32, method: Resampling) -> Result<()> {
        self.finish_pending()?;
        let layers = self.map_layers(|l| resample(&l.surface, width, height, method))?;
        let state = self.canvas_with(width, height, layers);
        self.replace_canvas("Resize", state);
        Ok(())
    }

    /// Canvas Size (Ctrl+Shift+R): no scaling; new area transparent, or
    /// the secondary colour in the Background layer.
    pub fn resize_canvas(&mut self, width: u32, height: u32, anchor: Anchor) -> Result<()> {
        self.finish_pending()?;
        check_size(width, height)?;
        let (dx, dy) = anchor.offset((self.width, self.height), (width, height));
        let secondary = self.colors.secondary;
        let layers = self.map_layers(|l| {
            let fill = if l.properties.is_background {
                secondary
            } else {
                Rgba8::TRANSPARENT
            };
            let mut s = Surface::filled(width, height, fill)?;
            s.paste(&l.surface, dx, dy);
            Ok(s)
        })?;
        let state = self.canvas_with(width, height, layers);
        self.replace_canvas("Canvas Size", state);
        Ok(())
    }

    /// Image > Flip Horizontal / Vertical: all layers.
    pub fn flip_image(&mut self, horizontal: bool) -> Result<()> {
        self.finish_pending()?;
        let layers = self.map_layers(|l| {
            let mut s = l.surface.clone();
            if horizontal {
                s.flip_horizontal();
            } else {
                s.flip_vertical();
            }
            Ok(s)
        })?;
        let state = self.canvas_with(self.width, self.height, layers);
        let name = if horizontal {
            "Flip Horizontal"
        } else {
            "Flip Vertical"
        };
        self.replace_canvas(name, state);
        Ok(())
    }

    /// Rotate 90° clockwise (`quarters = 1`, Ctrl+H), 180° (`2`, Ctrl+J)
    /// or 90° counter-clockwise (`3`, Ctrl+G).
    pub fn rotate_image(&mut self, quarters: u32) -> Result<()> {
        self.finish_pending()?;
        let quarters = quarters % 4;
        if quarters == 0 {
            return Ok(());
        }
        let layers = self.map_layers(|l| Ok(l.surface.rotated(quarters)))?;
        let (w, h) = if quarters == 2 {
            (self.width, self.height)
        } else {
            (self.height, self.width)
        };
        let state = self.canvas_with(w, h, layers);
        let name = match quarters {
            1 => "Rotate 90° Clockwise",
            2 => "Rotate 180°",
            _ => "Rotate 90° Counter-clockwise",
        };
        self.replace_canvas(name, state);
        Ok(())
    }

    /// Flatten (Ctrl+Shift+F): one Background layer with the composite.
    pub fn flatten(&mut self) -> Result<()> {
        self.finish_pending()?;
        if self.layers.len() == 1 {
            return Ok(());
        }
        let mut properties = LayerProperties::named("Background");
        properties.is_background = true;
        let layer = Layer::from_surface(properties, self.flatten_image());
        let mut state = self.canvas_state();
        state.layers = vec![layer];
        self.replace_canvas("Flatten", state);
        self.active = 0;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::geom::PointF;
    use crate::CombineMode;

    fn doc() -> Document {
        let mut d = Document::new(8, 6, Rgba8::WHITE).unwrap();
        d.layers[0].surface.set(0, 0, Rgba8::BLACK);
        d
    }

    #[test]
    fn crop_resize_and_canvas_size_change_the_canvas_and_undo() {
        let mut d = doc();
        d.select_rectangle(
            PointF::new(0.0, 0.0),
            PointF::new(4.0, 3.0),
            CombineMode::Replace,
        )
        .unwrap();
        d.crop_to_selection().unwrap();
        assert_eq!((d.width(), d.height()), (4, 3));
        assert!(!d.selection().is_active());
        d.resize_image(8, 6, Resampling::NearestNeighbor).unwrap();
        assert_eq!(d.layers()[0].surface().at(1, 1), Rgba8::BLACK);
        d.set_colors(crate::UserColors {
            primary: Rgba8::BLACK,
            secondary: Rgba8::opaque(0, 255, 0),
        });
        d.add_layer().unwrap();
        d.resize_canvas(10, 8, Anchor::BottomRight).unwrap();
        assert_eq!(d.layers()[0].surface().at(0, 0), Rgba8::opaque(0, 255, 0));
        assert_eq!(d.layers()[0].surface().at(2, 2), Rgba8::BLACK);
        assert_eq!(d.layers()[1].surface().at(0, 0), Rgba8::TRANSPARENT);
        d.jump_to(0).unwrap();
        assert_eq!((d.width(), d.height()), (8, 6));
        assert_eq!(d.layers().len(), 1);
    }

    #[test]
    fn rotations_and_flips_move_the_corner() {
        let mut d = doc();
        d.rotate_image(1).unwrap();
        assert_eq!((d.width(), d.height()), (6, 8));
        assert_eq!(d.layers()[0].surface().at(5, 0), Rgba8::BLACK);
        d.flip_image(true).unwrap();
        assert_eq!(d.layers()[0].surface().at(0, 0), Rgba8::BLACK);
        d.flip_image(false).unwrap();
        assert_eq!(d.layers()[0].surface().at(0, 7), Rgba8::BLACK);
    }

    #[test]
    fn shrinking_averages_and_flatten_keeps_the_look() {
        let mut s = Surface::filled(4, 4, Rgba8::WHITE).unwrap();
        s.set(0, 0, Rgba8::BLACK);
        s.set(1, 0, Rgba8::BLACK);
        let small = resample(&s, 2, 2, Resampling::Bilinear).unwrap();
        assert_eq!(small.at(0, 0), Rgba8::opaque(128, 128, 128));
        let mut d = doc();
        d.add_layer().unwrap();
        d.layers[1].surface.set(3, 3, Rgba8::opaque(1, 2, 3));
        let before = d.flatten_image();
        d.flatten().unwrap();
        assert_eq!(d.layers().len(), 1);
        assert_eq!(d.layers()[0].surface(), &before);
    }
}
