//! Files and the clipboard's pictures. Reading, writing and encoding run
//! on the bridge's worker threads (these functions are async in Dart),
//! so a big picture never freezes the window.

use std::path::{Path, PathBuf};

use flutter_rust_bridge::frb;
use paintbox_core as pb;

use crate::api::image::PaintImage;
use crate::api::types::{FileKind, PaintError, PaintResult};

/// The format of a path by its extension, if Paintbox writes it.
#[frb(sync)]
pub fn file_kind(path: String) -> Option<FileKind> {
    let format = pb::FileFormat::from_path(Path::new(&path)).ok()?;
    Some(FileKind {
        extension: format.extension().to_owned(),
        layered: format.is_layered(),
        lossy: format == pb::FileFormat::Jpeg,
    })
}

/// Every extension Paintbox opens and saves, the layered one first.
#[frb(sync)]
pub fn file_extensions() -> Vec<String> {
    pb::FileFormat::ALL
        .iter()
        .map(|f| f.extension().to_owned())
        .collect()
}

#[frb(sync)]
pub fn default_jpeg_quality() -> u8 {
    pb::files::DEFAULT_JPEG_QUALITY
}

/// Opens an image file: OpenRaster with its layers, any other format as
/// one Background layer.
pub fn open_image(path: String) -> PaintResult<PaintImage> {
    let doc = pb::files::open(Path::new(&path))?;
    Ok(PaintImage::wrap(doc))
}

/// The layers of an image as they were when it was taken, for writing
/// on a worker while the image goes on changing.
#[frb(opaque)]
pub struct ImageSnapshot {
    pub(crate) doc: pb::Document,
}

/// Writes a snapshot by the extension of `path`: `.ora` with its layers,
/// a flat format as the flattened picture (JPEG with `jpeg_quality`).
/// The bytes go to `<path>.part` first and replace the file only when
/// whole.
pub fn write_snapshot(snapshot: &ImageSnapshot, path: String, jpeg_quality: u8) -> PaintResult<()> {
    let path = PathBuf::from(path);
    let format = pb::FileFormat::from_path(&path)?;
    let bytes = pb::files::write_document_with(&snapshot.doc, format, jpeg_quality)?;
    let mut part = path.clone().into_os_string();
    part.push(".part");
    let part = PathBuf::from(part);
    std::fs::write(&part, bytes).map_err(pb::Error::from)?;
    std::fs::rename(&part, &path).map_err(|e| {
        let _ = std::fs::remove_file(&part);
        PaintError::from(pb::Error::from(e))
    })
}

/// A picture read from a file, for Layers > Import From File.
#[frb(opaque)]
pub struct Picture {
    pub(crate) surface: pb::Surface,
}

impl Picture {
    #[frb(sync, getter)]
    pub fn width(&self) -> u32 {
        self.surface.width()
    }

    #[frb(sync, getter)]
    pub fn height(&self) -> u32 {
        self.surface.height()
    }
}

pub fn read_picture(path: String) -> PaintResult<Picture> {
    let path = Path::new(&path);
    let hint = pb::FileFormat::from_path(path).ok();
    let bytes = std::fs::read(path).map_err(pb::Error::from)?;
    let surface = match hint {
        // An OpenRaster file imports as its flattened picture.
        Some(f) if f.is_layered() => pb::files::read_document(&bytes, f)?.flatten_image(),
        _ => pb::files::decode_image(&bytes, hint)?,
    };
    Ok(Picture { surface })
}

/// Pixels on the clipboard and where they were copied from.
#[frb(opaque)]
pub struct ClipImage {
    pub(crate) clip: pb::Clip,
}

impl ClipImage {
    #[frb(sync, getter)]
    pub fn width(&self) -> u32 {
        self.clip.surface.width()
    }

    #[frb(sync, getter)]
    pub fn height(&self) -> u32 {
        self.clip.surface.height()
    }
}

/// A picture another program put on the system clipboard (PNG or any
/// format the core reads): placed at `(0, 0)`.
pub fn decode_clip(bytes: Vec<u8>) -> PaintResult<ClipImage> {
    let surface = pb::files::decode_image(&bytes, Some(pb::FileFormat::Png))?;
    Ok(ClipImage {
        clip: pb::Clip::from_surface(surface),
    })
}

/// The clip as PNG bytes for the system clipboard.
pub fn encode_clip_png(clip: &ClipImage) -> PaintResult<Vec<u8>> {
    Ok(pb::files::encode_image(
        &clip.clip.surface,
        pb::FileFormat::Png,
    )?)
}
