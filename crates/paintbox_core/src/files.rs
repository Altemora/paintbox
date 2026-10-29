//! Files: OpenRaster (`.ora`) keeps layers; PNG, JPEG, BMP, TGA and
//! WebP are flat pictures. A flat file opens as one Background layer;
//! saving flat stores the composite of the visible layers.

use std::io::{Cursor, Read, Write};
use std::path::Path;

use image::{ImageFormat, RgbaImage};
use zip::write::SimpleFileOptions;
use zip::{CompressionMethod, ZipArchive, ZipWriter};

use crate::blend::BlendMode;
use crate::color::Rgba8;
use crate::document::Document;
use crate::error::{Error, Result};
use crate::image_ops::{resample, Resampling};
use crate::layer::{Layer, LayerProperties};
use crate::surface::{Surface, MAX_PIXELS, MAX_SIDE};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum FileFormat {
    OpenRaster,
    Png,
    Jpeg,
    Bmp,
    Tga,
    WebP,
}

impl FileFormat {
    pub const ALL: [FileFormat; 6] = [
        FileFormat::OpenRaster,
        FileFormat::Png,
        FileFormat::Jpeg,
        FileFormat::Bmp,
        FileFormat::Tga,
        FileFormat::WebP,
    ];

    pub fn from_extension(extension: &str) -> Option<FileFormat> {
        match extension.to_ascii_lowercase().as_str() {
            "ora" => Some(FileFormat::OpenRaster),
            "png" => Some(FileFormat::Png),
            "jpg" | "jpeg" | "jpe" => Some(FileFormat::Jpeg),
            "bmp" => Some(FileFormat::Bmp),
            "tga" => Some(FileFormat::Tga),
            "webp" => Some(FileFormat::WebP),
            _ => None,
        }
    }

    pub fn from_path(path: &Path) -> Result<FileFormat> {
        path.extension()
            .and_then(|e| e.to_str())
            .and_then(FileFormat::from_extension)
            .ok_or_else(|| {
                Error::InvalidParameter(format!("unknown file type: {}", path.display()))
            })
    }

    pub fn extension(self) -> &'static str {
        match self {
            FileFormat::OpenRaster => "ora",
            FileFormat::Png => "png",
            FileFormat::Jpeg => "jpg",
            FileFormat::Bmp => "bmp",
            FileFormat::Tga => "tga",
            FileFormat::WebP => "webp",
        }
    }

    /// Whether the format keeps layers.
    pub fn is_layered(self) -> bool {
        self == FileFormat::OpenRaster
    }

    fn image_format(self) -> Option<ImageFormat> {
        match self {
            FileFormat::OpenRaster => None,
            FileFormat::Png => Some(ImageFormat::Png),
            FileFormat::Jpeg => Some(ImageFormat::Jpeg),
            FileFormat::Bmp => Some(ImageFormat::Bmp),
            FileFormat::Tga => Some(ImageFormat::Tga),
            FileFormat::WebP => Some(ImageFormat::WebP),
        }
    }
}

/// A picture from bytes in any flat format (guessed from the content,
/// then from `hint`).
pub fn decode_image(bytes: &[u8], hint: Option<FileFormat>) -> Result<Surface> {
    let decode = |e: image::ImageError| Error::Decode(e.to_string());
    let mut reader = image::ImageReader::new(Cursor::new(bytes))
        .with_guessed_format()
        .map_err(|e| Error::Decode(e.to_string()))?;
    if reader.format().is_none() {
        if let Some(format) = hint.and_then(FileFormat::image_format) {
            reader.set_format(format);
        }
    }
    // Refuse pictures past the surface budget before decoding them.
    let mut limits = image::Limits::default();
    limits.max_image_width = Some(MAX_SIDE);
    limits.max_image_height = Some(MAX_SIDE);
    limits.max_alloc = Some(MAX_PIXELS * 4 * 2);
    reader.limits(limits);
    let decoded = reader.decode().map_err(decode)?;
    let rgba = decoded.to_rgba8();
    Surface::from_rgba8(rgba.width(), rgba.height(), rgba.as_raw())
}

/// A picture as bytes of a flat format. JPEG has no alpha, so the
/// picture is laid over white first, as Paint.NET does; quality is 95.
pub fn encode_image(surface: &Surface, format: FileFormat) -> Result<Vec<u8>> {
    encode_image_with(surface, format, DEFAULT_JPEG_QUALITY)
}

/// Paint.NET's JPEG default.
pub const DEFAULT_JPEG_QUALITY: u8 = 95;

/// [`encode_image`] with the JPEG quality (1 – 100) the save dialog
/// asked for; other formats ignore it.
pub fn encode_image_with(
    surface: &Surface,
    format: FileFormat,
    jpeg_quality: u8,
) -> Result<Vec<u8>> {
    let image_format = format
        .image_format()
        .ok_or_else(|| Error::Encode("OpenRaster is not a flat format".into()))?;
    let rgba = RgbaImage::from_raw(surface.width(), surface.height(), surface.to_rgba8())
        .ok_or_else(|| Error::Encode("picture size does not match its pixels".into()))?;
    let mut out = Cursor::new(Vec::new());
    if format == FileFormat::Jpeg {
        let flat: Vec<u8> = surface
            .pixels()
            .iter()
            .flat_map(|&p| {
                let p = crate::blend::over(Rgba8::WHITE, p);
                [p.r, p.g, p.b]
            })
            .collect();
        image::codecs::jpeg::JpegEncoder::new_with_quality(&mut out, jpeg_quality.clamp(1, 100))
            .encode(
                &flat,
                surface.width(),
                surface.height(),
                image::ExtendedColorType::Rgb8,
            )
            .map_err(|e| Error::Encode(e.to_string()))?;
    } else {
        rgba.write_to(&mut out, image_format)
            .map_err(|e| Error::Encode(e.to_string()))?;
    }
    Ok(out.into_inner())
}

/// Opens bytes of `format` as a document.
pub fn read_document(bytes: &[u8], format: FileFormat) -> Result<Document> {
    if format.is_layered() {
        return read_ora(bytes);
    }
    let surface = decode_image(bytes, Some(format))?;
    let mut properties = LayerProperties::named("Background");
    properties.is_background = true;
    Document::with_layers(
        surface.width(),
        surface.height(),
        vec![Layer::from_surface(properties, surface)],
        "Open Image",
    )
}

/// Saves a document as `format`; flat formats store the composite.
pub fn write_document(document: &Document, format: FileFormat) -> Result<Vec<u8>> {
    write_document_with(document, format, DEFAULT_JPEG_QUALITY)
}

/// [`write_document`] with a JPEG quality.
pub fn write_document_with(
    document: &Document,
    format: FileFormat,
    jpeg_quality: u8,
) -> Result<Vec<u8>> {
    if format.is_layered() {
        return write_ora(document);
    }
    encode_image_with(&document.flatten_image(), format, jpeg_quality)
}

pub fn open(path: &Path) -> Result<Document> {
    let format = FileFormat::from_path(path)?;
    let bytes = std::fs::read(path)?;
    read_document(&bytes, format)
}

pub fn save(document: &Document, path: &Path) -> Result<()> {
    let format = FileFormat::from_path(path)?;
    let bytes = write_document(document, format)?;
    std::fs::write(path, bytes)?;
    Ok(())
}

// ---- OpenRaster --------------------------------------------------------

const MIMETYPE: &str = "image/openraster";
const THUMBNAIL_SIDE: u32 = 256;

fn composite_op(mode: BlendMode) -> &'static str {
    match mode {
        BlendMode::Normal => "svg:src-over",
        BlendMode::Multiply => "svg:multiply",
        BlendMode::Additive => "svg:plus",
        BlendMode::ColorBurn => "svg:color-burn",
        BlendMode::ColorDodge => "svg:color-dodge",
        BlendMode::Overlay => "svg:overlay",
        BlendMode::Difference => "svg:difference",
        BlendMode::Lighten => "svg:lighten",
        BlendMode::Darken => "svg:darken",
        BlendMode::Screen => "svg:screen",
        // No SVG equivalent; svg:xor is Porter-Duff XOR, not bitwise.
        BlendMode::Reflect => "paintbox:reflect",
        BlendMode::Glow => "paintbox:glow",
        BlendMode::Negation => "paintbox:negation",
        BlendMode::Xor => "paintbox:xor",
    }
}

fn blend_mode_of(op: &str) -> BlendMode {
    BlendMode::ALL
        .into_iter()
        .find(|&m| composite_op(m) == op)
        .unwrap_or(BlendMode::Normal)
}

fn escape(text: &str) -> String {
    text.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
}

fn unescape(text: &str) -> String {
    text.replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&apos;", "'")
        .replace("&amp;", "&")
}

/// The document as an OpenRaster zip: `mimetype` first and stored,
/// `stack.xml` (layers top first), a PNG per layer, the merged image
/// and a thumbnail.
pub fn write_ora(document: &Document) -> Result<Vec<u8>> {
    let zip_error = |e: zip::result::ZipError| Error::Encode(e.to_string());
    let mut zip = ZipWriter::new(Cursor::new(Vec::new()));
    let stored = SimpleFileOptions::default().compression_method(CompressionMethod::Stored);
    let deflated = SimpleFileOptions::default().compression_method(CompressionMethod::Deflated);
    zip.start_file("mimetype", stored).map_err(zip_error)?;
    zip.write_all(MIMETYPE.as_bytes())?;

    let mut stack = format!(
        "<?xml version='1.0' encoding='UTF-8'?>\n<image version=\"0.0.3\" w=\"{}\" h=\"{}\" xmlns:paintbox=\"urn:paintbox\">\n <stack>\n",
        document.width(),
        document.height()
    );
    for (index, layer) in document.layers().iter().enumerate().rev() {
        let p = &layer.properties;
        stack.push_str(&format!(
            "  <layer name=\"{}\" src=\"data/layer{index}.png\" x=\"0\" y=\"0\" opacity=\"{:.4}\" visibility=\"{}\" composite-op=\"{}\"{}{} />\n",
            escape(&p.name),
            p.opacity as f64 / 255.0,
            if p.visible { "visible" } else { "hidden" },
            composite_op(p.blend_mode),
            if index == document.active_layer_index() { " selected=\"true\"" } else { "" },
            if p.is_background { " paintbox:background=\"true\"" } else { "" },
        ));
    }
    stack.push_str(" </stack>\n</image>\n");
    zip.start_file("stack.xml", deflated).map_err(zip_error)?;
    zip.write_all(stack.as_bytes())?;

    // PNG is already compressed; deflating it again only costs time.
    for (index, layer) in document.layers().iter().enumerate() {
        zip.start_file(format!("data/layer{index}.png"), stored)
            .map_err(zip_error)?;
        zip.write_all(&encode_image(&layer.surface, FileFormat::Png)?)?;
    }
    let merged = document.flatten_image();
    zip.start_file("mergedimage.png", stored)
        .map_err(zip_error)?;
    zip.write_all(&encode_image(&merged, FileFormat::Png)?)?;
    let scale = (THUMBNAIL_SIDE as f32 / merged.width().max(merged.height()) as f32).min(1.0);
    let thumbnail = resample(
        &merged,
        ((merged.width() as f32 * scale) as u32).max(1),
        ((merged.height() as f32 * scale) as u32).max(1),
        Resampling::Bilinear,
    )?;
    zip.start_file("Thumbnails/thumbnail.png", stored)
        .map_err(zip_error)?;
    zip.write_all(&encode_image(&thumbnail, FileFormat::Png)?)?;
    let out = zip.finish().map_err(zip_error)?;
    Ok(out.into_inner())
}

/// Attributes of every `<tag ...>` in `xml`, in document order.
fn tags(xml: &str, tag: &str) -> Vec<Vec<(String, String)>> {
    let open = format!("<{tag}");
    let mut out = Vec::new();
    let mut rest = xml;
    while let Some(start) = rest.find(&open) {
        let after = &rest[start + open.len()..];
        if !after.starts_with(|c: char| c.is_whitespace() || c == '/' || c == '>') {
            rest = after;
            continue;
        }
        let end = tag_end(after);
        out.push(attributes(&after[..end]));
        rest = &after[end..];
    }
    out
}

/// Where a tag closes: the first `>` outside quoted attribute values
/// (a `>` inside a value is legal XML).
fn tag_end(text: &str) -> usize {
    let mut quote = None;
    for (i, c) in text.char_indices() {
        match (quote, c) {
            (None, '"' | '\'') => quote = Some(c),
            (Some(q), _) if c == q => quote = None,
            (None, '>') => return i,
            _ => {}
        }
    }
    text.len()
}

fn attributes(text: &str) -> Vec<(String, String)> {
    let mut out = Vec::new();
    let mut rest = text;
    while let Some(eq) = rest.find('=') {
        let name = rest[..eq].trim().trim_start_matches('/').trim().to_owned();
        let value_part = rest[eq + 1..].trim_start();
        let Some(quote) = value_part
            .chars()
            .next()
            .filter(|c| *c == '"' || *c == '\'')
        else {
            break;
        };
        let Some(close) = value_part[1..].find(quote) else {
            break;
        };
        out.push((name, unescape(&value_part[1..1 + close])));
        rest = &value_part[close + 2..];
    }
    out
}

fn attribute<'a>(attrs: &'a [(String, String)], name: &str) -> Option<&'a str> {
    attrs
        .iter()
        .find(|(n, _)| n == name)
        .map(|(_, v)| v.as_str())
}

/// Reads an OpenRaster file. Nested stacks (groups) are read as a flat
/// list of their layers; group properties are ignored.
pub fn read_ora(bytes: &[u8]) -> Result<Document> {
    let ora = |m: String| Error::OpenRaster(m);
    let mut archive = ZipArchive::new(Cursor::new(bytes)).map_err(|e| ora(e.to_string()))?;
    let mut read_entry = |name: &str| -> Result<Vec<u8>> {
        let entry = archive
            .by_name(name)
            .map_err(|_| ora(format!("missing {name}")))?;
        // A compressed PNG never outgrows its raw pixels; a bigger entry
        // is a zip bomb.
        let limit = MAX_PIXELS * 4 + (1 << 20);
        if entry.size() > limit {
            return Err(ora(format!("{name} is too large")));
        }
        let mut data = Vec::new();
        entry.take(limit).read_to_end(&mut data)?;
        Ok(data)
    };
    let stack = String::from_utf8(read_entry("stack.xml")?)
        .map_err(|_| ora("stack.xml is not UTF-8".into()))?;
    let image = tags(&stack, "image")
        .into_iter()
        .next()
        .ok_or_else(|| ora("stack.xml has no <image>".into()))?;
    let size = |name: &str| -> Result<u32> {
        attribute(&image, name)
            .and_then(|v| v.trim().parse().ok())
            .ok_or_else(|| ora(format!("<image> has no valid {name}")))
    };
    let (width, height) = (size("w")?, size("h")?);
    let mut layers = Vec::new();
    let mut active = None;
    for attrs in tags(&stack, "layer").into_iter().rev() {
        let src = attribute(&attrs, "src").ok_or_else(|| ora("a layer has no src".into()))?;
        let picture = decode_image(&read_entry(src)?, Some(FileFormat::Png))?;
        let number =
            |name: &str| attribute(&attrs, name).and_then(|v| v.trim().parse::<f64>().ok());
        let mut surface = Surface::new(width, height)?;
        surface.paste(
            &picture,
            number("x").unwrap_or(0.0) as i32,
            number("y").unwrap_or(0.0) as i32,
        );
        let opacity = (number("opacity").unwrap_or(1.0).clamp(0.0, 1.0) * 255.0).round() as u8;
        let properties = LayerProperties {
            name: attribute(&attrs, "name").unwrap_or("Layer").to_owned(),
            visible: attribute(&attrs, "visibility") != Some("hidden"),
            opacity,
            blend_mode: blend_mode_of(attribute(&attrs, "composite-op").unwrap_or("svg:src-over")),
            is_background: attribute(&attrs, "paintbox:background") == Some("true"),
        };
        if attribute(&attrs, "selected") == Some("true") {
            active = Some(layers.len());
        }
        layers.push(Layer::from_surface(properties, surface));
    }
    if layers.is_empty() {
        return Err(ora("the stack has no layers".into()));
    }
    let mut document = Document::with_layers(width, height, layers, "Open Image")?;
    if let Some(index) = active {
        document.active = index;
    }
    Ok(document)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sample() -> Document {
        let mut d = Document::new(20, 10, Rgba8::WHITE).unwrap();
        d.add_layer().unwrap();
        d.layers[1].surface.set(3, 4, Rgba8::new(10, 20, 30, 40));
        let mut p = d.layers()[1].properties.clone();
        p.name = "Ink & \"quotes\" <here>".into();
        p.opacity = 128;
        p.blend_mode = BlendMode::Xor;
        p.visible = false;
        d.set_layer_properties(1, p).unwrap();
        d.add_layer().unwrap();
        let mut p = d.layers()[2].properties.clone();
        p.blend_mode = BlendMode::ColorDodge;
        d.set_layer_properties(2, p).unwrap();
        d.set_active_layer(1).unwrap();
        d
    }

    #[test]
    fn openraster_round_trips_layers_and_properties() {
        let d = sample();
        let bytes = write_ora(&d).unwrap();
        assert_eq!(&bytes[30..38], b"mimetype");
        let back = read_ora(&bytes).unwrap();
        assert_eq!((back.width(), back.height()), (20, 10));
        assert_eq!(back.layers().len(), 3);
        for (a, b) in d.layers().iter().zip(back.layers()) {
            assert_eq!(a.properties, b.properties);
            assert_eq!(a.surface, b.surface);
        }
        assert_eq!(back.active_layer_index(), 1);
        assert_eq!(back.history_names(), ["Open Image"]);
    }

    #[test]
    fn foreign_stacks_with_offsets_and_groups_are_read() {
        let mut zip = ZipWriter::new(Cursor::new(Vec::new()));
        let options = SimpleFileOptions::default().compression_method(CompressionMethod::Stored);
        zip.start_file("mimetype", options).unwrap();
        zip.write_all(MIMETYPE.as_bytes()).unwrap();
        zip.start_file("stack.xml", options).unwrap();
        zip.write_all(
            br#"<image w='8' h='6'><stack><stack opacity="0.5"><layer src="a.png" x="2" y="1" name='Top' composite-op="svg:multiply"/></stack><layer src="b.png" name="Bottom"/></stack></image>"#,
        )
        .unwrap();
        let red = Surface::filled(2, 2, Rgba8::opaque(255, 0, 0)).unwrap();
        zip.start_file("a.png", options).unwrap();
        zip.write_all(&encode_image(&red, FileFormat::Png).unwrap())
            .unwrap();
        zip.start_file("b.png", options).unwrap();
        zip.write_all(
            &encode_image(
                &Surface::filled(8, 6, Rgba8::WHITE).unwrap(),
                FileFormat::Png,
            )
            .unwrap(),
        )
        .unwrap();
        let bytes = zip.finish().unwrap().into_inner();
        let d = read_ora(&bytes).unwrap();
        assert_eq!(d.layers()[0].properties.name, "Bottom");
        assert_eq!(d.layers()[1].properties.blend_mode, BlendMode::Multiply);
        assert_eq!(d.layers()[1].surface().at(2, 1), Rgba8::opaque(255, 0, 0));
        assert_eq!(d.layers()[1].surface().at(0, 0), Rgba8::TRANSPARENT);
        assert!(read_ora(b"not a zip").is_err());
    }

    #[test]
    fn flat_formats_round_trip() {
        let mut s = Surface::filled(5, 4, Rgba8::new(10, 200, 30, 255)).unwrap();
        s.set(1, 1, Rgba8::new(1, 2, 3, 77));
        for format in [FileFormat::Png, FileFormat::Tga, FileFormat::WebP] {
            let back = decode_image(&encode_image(&s, format).unwrap(), Some(format)).unwrap();
            assert_eq!(back, s, "{format:?}");
        }
        let bmp = decode_image(
            &encode_image(&s, FileFormat::Bmp).unwrap(),
            Some(FileFormat::Bmp),
        )
        .unwrap();
        assert_eq!(bmp.at(0, 0), Rgba8::new(10, 200, 30, 255));
        let jpg = decode_image(&encode_image(&s, FileFormat::Jpeg).unwrap(), None).unwrap();
        assert_eq!(jpg.at(4, 3).a, 255);
        assert!(jpg.at(4, 3).g.abs_diff(200) < 8);
        let d =
            read_document(&encode_image(&s, FileFormat::Png).unwrap(), FileFormat::Png).unwrap();
        assert!(d.layers()[0].properties.is_background);
        assert_eq!(FileFormat::from_extension("JPEG"), Some(FileFormat::Jpeg));
        assert!(decode_image(b"garbage", None).is_err());
    }

    #[test]
    fn files_open_and_save_by_extension() {
        let dir = std::env::temp_dir().join(format!("paintbox-test-{}", std::process::id()));
        std::fs::create_dir_all(&dir).unwrap();
        let path = dir.join("picture.ora");
        save(&sample(), &path).unwrap();
        assert_eq!(open(&path).unwrap().layers().len(), 3);
        assert!(save(&sample(), &dir.join("picture.xyz")).is_err());
        std::fs::remove_dir_all(&dir).ok();
    }
}
