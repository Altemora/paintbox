//! Cut, Copy and Paste as values: the core hands out and takes a
//! [`Clip`]; putting it on the system clipboard is the shell's job.

use crate::color::mul255;
use crate::document::Document;
use crate::error::{Error, Result};
use crate::layer::Layer;
use crate::surface::Surface;

/// Pixels copied from a layer and where they came from.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Clip {
    pub surface: Surface,
    pub x: i32,
    pub y: i32,
}

impl Clip {
    /// A picture from another program: placed at `(0, 0)`.
    pub fn from_surface(surface: Surface) -> Self {
        Self {
            surface,
            x: 0,
            y: 0,
        }
    }
}

impl Document {
    /// Copy (Ctrl+C): the active layer inside the selection's bounds,
    /// transparent outside its shape.
    pub fn copy(&self) -> Result<Clip> {
        if !self.selection.is_active() {
            return Err(Error::NoSelection);
        }
        let bounds = self.selection.bounds();
        if bounds.is_empty() {
            return Err(Error::NoSelection);
        }
        let mut surface = self.layers[self.active].surface.crop(bounds);
        for y in 0..bounds.height as i32 {
            for x in 0..bounds.width as i32 {
                let c = self.selection.coverage(x + bounds.x, y + bounds.y);
                let p = surface.at(x, y);
                surface.set(x, y, p.with_alpha(mul255(p.a as u32, c as u32) as u8));
            }
        }
        Ok(Clip {
            surface,
            x: bounds.x,
            y: bounds.y,
        })
    }

    /// Cut (Ctrl+X): Copy, then Erase Selection.
    pub fn cut(&mut self) -> Result<Clip> {
        self.finish_pending()?;
        let clip = self.copy()?;
        self.erase_selection_named("Cut")?;
        Ok(clip)
    }

    /// Paste into New Layer (Ctrl+Shift+V).
    pub fn paste_into_new_layer(&mut self, clip: &Clip) -> Result<()> {
        self.add_layer()?;
        self.paste(clip)
    }

    /// Paste into New Image (Ctrl+Alt+V): a document the clip's size.
    pub fn from_clip(clip: &Clip) -> Result<Document> {
        let mut properties = crate::layer::LayerProperties::named("Background");
        properties.is_background = true;
        let layer = Layer::from_surface(properties, clip.surface.clone());
        Document::with_layers(
            clip.surface.width(),
            clip.surface.height(),
            vec![layer],
            "Paste into New Image",
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::geom::{PointF, Rect};
    use crate::{CombineMode, Rgba8};

    #[test]
    fn copy_cut_and_paste_round_trip() {
        let mut d = Document::new(30, 20, Rgba8::WHITE).unwrap();
        assert_eq!(d.copy(), Err(Error::NoSelection));
        d.layers[0].surface.set(3, 3, Rgba8::opaque(9, 9, 9));
        d.select_ellipse(
            PointF::new(2.0, 2.0),
            PointF::new(6.0, 6.0),
            CombineMode::Replace,
        )
        .unwrap();
        let clip = d.cut().unwrap();
        assert_eq!((clip.x, clip.y), (2, 2));
        assert_eq!(clip.surface.at(1, 1), Rgba8::opaque(9, 9, 9));
        assert_eq!(clip.surface.at(0, 0).a, 0);
        assert_eq!(d.layers()[0].surface().at(3, 3), Rgba8::CLEARED);
        d.paste(&clip).unwrap();
        d.move_lifted(10, 0).unwrap();
        d.finish_move().unwrap();
        assert_eq!(d.layers()[0].surface().at(13, 3), Rgba8::opaque(9, 9, 9));
        assert_eq!(d.selection().bounds().x, 12);
        let names = d.history_names();
        assert_eq!(&names[names.len() - 2..], ["Cut", "Paste"]);
    }

    #[test]
    fn a_clip_that_does_not_fit_is_centred_and_new_image_takes_its_size() {
        let mut d = Document::new(30, 20, Rgba8::WHITE).unwrap();
        let clip = Clip {
            surface: Surface::filled(10, 10, Rgba8::BLACK).unwrap(),
            x: 25,
            y: 0,
        };
        d.paste_into_new_layer(&clip).unwrap();
        d.finish_move().unwrap();
        assert_eq!(d.layers().len(), 2);
        assert_eq!(d.selection().bounds(), Rect::new(10, 5, 10, 10));
        let image = Document::from_clip(&clip).unwrap();
        assert_eq!((image.width(), image.height()), (10, 10));
    }
}
