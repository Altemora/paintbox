//! A raster layer: pixels the size of the canvas and the properties
//! the Layer Properties dialog edits.

use serde::{Deserialize, Serialize};

use crate::blend::BlendMode;
use crate::color::Rgba8;
use crate::error::Result;
use crate::surface::Surface;

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct LayerProperties {
    pub name: String,
    pub visible: bool,
    /// 0 – 255; scales the layer's alpha before blending.
    pub opacity: u8,
    pub blend_mode: BlendMode,
    /// The Background flag: Canvas Size fills new area of this layer
    /// with the secondary colour instead of transparency.
    pub is_background: bool,
}

impl LayerProperties {
    pub fn named(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            visible: true,
            opacity: 255,
            blend_mode: BlendMode::Normal,
            is_background: false,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Layer {
    pub properties: LayerProperties,
    pub(crate) surface: Surface,
}

impl Layer {
    pub fn transparent(name: impl Into<String>, width: u32, height: u32) -> Result<Self> {
        Ok(Self {
            properties: LayerProperties::named(name),
            surface: Surface::new(width, height)?,
        })
    }

    /// The first layer of a new image: opaque, filled, flagged.
    pub fn background(width: u32, height: u32, color: Rgba8) -> Result<Self> {
        let mut properties = LayerProperties::named("Background");
        properties.is_background = true;
        Ok(Self {
            properties,
            surface: Surface::filled(width, height, color)?,
        })
    }

    pub fn from_surface(properties: LayerProperties, surface: Surface) -> Self {
        Self {
            properties,
            surface,
        }
    }

    pub fn surface(&self) -> &Surface {
        &self.surface
    }
}
