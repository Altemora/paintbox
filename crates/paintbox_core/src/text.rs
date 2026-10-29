//! The Text tool's fonts and type: a built-in font (Manrope, SIL Open
//! Font License, `assets/fonts`) and the system's fonts by family name;
//! lines laid out and rasterised to coverage as Paint.NET's tool does
//! with GDI+: the size in points at 96 pixels to the inch, the point
//! clicked the top of the first line, left, centred or right of it.
//! Bold takes the family's bold face or the variable font's weight, else
//! is drawn twice a little apart; italic takes the italic face, else is
//! slanted. Underline and strikeout are bars under and through the
//! line.

use std::collections::BTreeMap;
use std::fs::File;
use std::io::{Read, Seek, SeekFrom};
use std::path::{Path, PathBuf};
use std::sync::{Arc, Mutex, OnceLock};

use ab_glyph::{Font, FontVec, GlyphId, VariableFont};
use ab_glyph_rasterizer::{point, Rasterizer};

use crate::error::{invalid, Error, Result};
use crate::geom::{PointF, Rect};
use crate::mask::Mask;
use crate::tool::{TextAlign, ToolSettings, MAX_FONT_SIZE};

/// The built-in font's family name, shown first in the font box.
pub const BUILT_IN: &str = "Manrope";

const BUILT_IN_DATA: &[u8] = include_bytes!("../assets/fonts/Manrope-Variable.ttf");

/// The slant of a synthesised italic, as GDI+'s (about 12°).
const SLANT: f32 = 0.21;

/// One glyph's box at most (2²⁶ pixels): larger is refused rather than
/// allocated.
const MAX_TEXT_AREA: u64 = 1 << 26;

/// One face file of a system family.
#[derive(Debug, Clone)]
struct FaceFile {
    path: PathBuf,
    index: u32,
    bold: bool,
    italic: bool,
}

/// The fonts a shell can offer: the built-in one first, then the system
/// families by name, sorted. Scanning reads only each file's name and
/// OS/2 tables, once per process.
pub fn font_names() -> Vec<String> {
    let mut names = vec![BUILT_IN.to_owned()];
    names.extend(
        system_fonts()
            .keys()
            .filter(|n| n.as_str() != BUILT_IN)
            .cloned(),
    );
    names
}

fn system_fonts() -> &'static BTreeMap<String, Vec<FaceFile>> {
    static FONTS: OnceLock<BTreeMap<String, Vec<FaceFile>>> = OnceLock::new();
    FONTS.get_or_init(|| {
        let mut out: BTreeMap<String, Vec<FaceFile>> = BTreeMap::new();
        for dir in font_dirs() {
            scan(&dir, 0, &mut out);
        }
        out
    })
}

fn font_dirs() -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    let home = std::env::var_os("HOME")
        .or_else(|| std::env::var_os("USERPROFILE"))
        .map(PathBuf::from);
    if cfg!(windows) {
        let windir = std::env::var_os("WINDIR").map_or_else(|| "C:\\Windows".into(), PathBuf::from);
        dirs.push(windir.join("Fonts"));
        if let Some(local) = std::env::var_os("LOCALAPPDATA") {
            dirs.push(PathBuf::from(local).join("Microsoft\\Windows\\Fonts"));
        }
    } else if cfg!(target_os = "macos") {
        dirs.push("/System/Library/Fonts".into());
        dirs.push("/Library/Fonts".into());
        if let Some(home) = &home {
            dirs.push(home.join("Library/Fonts"));
        }
    } else {
        dirs.push("/usr/share/fonts".into());
        dirs.push("/usr/local/share/fonts".into());
        if let Some(home) = &home {
            dirs.push(home.join(".fonts"));
            dirs.push(home.join(".local/share/fonts"));
        }
    }
    dirs
}

fn scan(dir: &Path, depth: u32, out: &mut BTreeMap<String, Vec<FaceFile>>) {
    let Ok(entries) = std::fs::read_dir(dir) else {
        return;
    };
    for entry in entries.flatten() {
        let path = entry.path();
        if path.is_dir() {
            if depth < 4 {
                scan(&path, depth + 1, out);
            }
            continue;
        }
        let ext = path
            .extension()
            .and_then(|e| e.to_str())
            .map(str::to_ascii_lowercase);
        if !matches!(ext.as_deref(), Some("ttf" | "otf" | "ttc" | "otc")) {
            continue;
        }
        // A broken file is skipped: the font box simply lacks it.
        let _ = read_faces(&path, out);
    }
}

/// The family and style of every face in a font file, from its table
/// directory, `name` and `OS/2` tables only.
fn read_faces(path: &Path, out: &mut BTreeMap<String, Vec<FaceFile>>) -> std::io::Result<()> {
    let mut file = File::open(path)?;
    let mut head = [0u8; 12];
    file.read_exact(&mut head)?;
    let offsets: Vec<u32> = if &head[..4] == b"ttcf" {
        let count = u32::from_be_bytes([head[8], head[9], head[10], head[11]]).min(64);
        let mut raw = vec![0u8; count as usize * 4];
        file.read_exact(&mut raw)?;
        raw.as_chunks::<4>()
            .0
            .iter()
            .map(|c| u32::from_be_bytes([c[0], c[1], c[2], c[3]]))
            .collect()
    } else {
        vec![0]
    };
    for (index, &offset) in offsets.iter().enumerate() {
        // A broken face hides only itself, not the rest of a collection.
        let Ok(Some((family, bold, italic))) = face_names(&mut file, offset) else {
            continue;
        };
        out.entry(family).or_default().push(FaceFile {
            path: path.to_owned(),
            index: index as u32,
            bold,
            italic,
        });
    }
    Ok(())
}

fn face_names(file: &mut File, offset: u32) -> std::io::Result<Option<(String, bool, bool)>> {
    file.seek(SeekFrom::Start(offset as u64))?;
    let mut dir = [0u8; 12];
    file.read_exact(&mut dir)?;
    let tables = u16::from_be_bytes([dir[4], dir[5]]).min(256) as usize;
    let mut records = vec![0u8; tables * 16];
    file.read_exact(&mut records)?;
    let mut find = |tag: &[u8; 4]| -> std::io::Result<Option<Vec<u8>>> {
        for r in records.as_chunks::<16>().0 {
            if &r[..4] == tag {
                let at = u32::from_be_bytes([r[8], r[9], r[10], r[11]]);
                let len = u32::from_be_bytes([r[12], r[13], r[14], r[15]]).min(1 << 20);
                file.seek(SeekFrom::Start(at as u64))?;
                let mut data = vec![0u8; len as usize];
                file.read_exact(&mut data)?;
                return Ok(Some(data));
            }
        }
        Ok(None)
    };
    let (Some(name), os2) = (find(b"name")?, find(b"OS/2")?) else {
        return Ok(None);
    };
    let Some(names) = ttf_parser::name::Table::parse(&name) else {
        return Ok(None);
    };
    let pick = |id: u16| {
        names
            .names
            .into_iter()
            .filter(|n| n.name_id == id && n.is_unicode())
            .find_map(|n| n.to_string())
    };
    let Some(family) = pick(ttf_parser::name_id::TYPOGRAPHIC_FAMILY)
        .or_else(|| pick(ttf_parser::name_id::FAMILY))
        .filter(|f| !f.trim().is_empty())
    else {
        return Ok(None);
    };
    let (bold, italic) = os2
        .as_deref()
        .and_then(ttf_parser::os2::Table::parse)
        .map_or((false, false), |t| {
            (t.is_bold(), t.style() != ttf_parser::Style::Normal)
        });
    Ok(Some((family, bold, italic)))
}

/// A font ready to draw: the face, and what the face lacks of the style
/// asked for (drawn by hand).
struct Face {
    font: FontVec,
    fake_bold: bool,
    fake_italic: bool,
}

/// Loaded faces by family and style, so typing does not reread files.
fn load(family: &str, bold: bool, italic: bool) -> Result<Arc<Face>> {
    type Cache = Mutex<BTreeMap<(String, bool, bool), Arc<Face>>>;
    static CACHE: OnceLock<Cache> = OnceLock::new();
    let key = (family.to_owned(), bold, italic);
    let cache = CACHE.get_or_init(Default::default);
    if let Some(face) = cache.lock().ok().and_then(|c| c.get(&key).cloned()) {
        return Ok(face);
    }
    let face = Arc::new(open_face(family, bold, italic)?);
    if let Ok(mut c) = cache.lock() {
        c.insert(key, face.clone());
    }
    Ok(face)
}

fn open_face(family: &str, bold: bool, italic: bool) -> Result<Face> {
    let system = (!family.is_empty() && family != BUILT_IN)
        .then(|| system_fonts().get(family))
        .flatten();
    let Some(files) = system else {
        let mut font = FontVec::try_from_vec(BUILT_IN_DATA.to_vec())
            .map_err(|_| invalid("the built-in font does not load"))?;
        // Manrope's default instance is ExtraLight (200); regular is 400.
        let heavier = weigh(&mut font, bold);
        return Ok(Face {
            font,
            fake_bold: bold && !heavier,
            fake_italic: italic,
        });
    };
    // The closest face: style first, then any.
    let score = |f: &FaceFile| (f.bold == bold) as u8 * 2 + (f.italic == italic) as u8;
    let best = files
        .iter()
        .max_by_key(|f| score(f))
        .ok_or_else(|| invalid(format!("no font {family}")))?;
    let data = std::fs::read(&best.path).map_err(Error::from)?;
    let mut font = FontVec::try_from_vec_and_index(data, best.index)
        .map_err(|_| invalid(format!("the font {family} does not load")))?;
    let heavier = !best.bold && weigh(&mut font, bold);
    Ok(Face {
        font,
        fake_bold: bold && !best.bold && !heavier,
        fake_italic: italic && !best.italic,
    })
}

/// A variable font at the regular or bold weight; true when it has the
/// axis and the bold weight was set.
fn weigh(font: &mut FontVec, bold: bool) -> bool {
    font.set_variation(b"wght", if bold { 700.0 } else { 400.0 }) && bold
}

/// How text is set: Text's part of the tool bar.
#[derive(Debug, Clone, PartialEq)]
pub struct TextStyle {
    pub font: String,
    /// Points.
    pub size: f32,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub strikeout: bool,
    pub align: TextAlign,
    pub antialias: bool,
}

impl TextStyle {
    pub fn of(settings: &ToolSettings) -> TextStyle {
        TextStyle {
            font: settings.font.clone(),
            size: settings.font_size,
            bold: settings.bold,
            italic: settings.italic,
            underline: settings.underline,
            strikeout: settings.strikeout,
            align: settings.text_align,
            antialias: settings.antialias,
        }
    }

    fn pixels(&self) -> f32 {
        self.size * 96.0 / 72.0
    }
}

/// Lines set at a point: their coverage and where the caret goes.
pub struct TextLayout {
    pub coverage: Mask,
    /// The top-left of each line and its height.
    line_tops: Vec<(f32, f32)>,
    /// For each line, the x of the caret before each character and after
    /// the last.
    carets: Vec<Vec<f32>>,
    line_height: f32,
}

impl TextLayout {
    /// The caret's top and bottom before character `col` of `line`.
    pub fn caret(&self, line: usize, col: usize) -> Option<(PointF, PointF)> {
        let xs = self.carets.get(line)?;
        let x = *xs.get(col).or(xs.last())?;
        let (top, _) = *self.line_tops.get(line)?;
        Some((PointF::new(x, top), PointF::new(x, top + self.line_height)))
    }

    /// The line and character nearest to `at`, for a click into the text.
    pub fn position_at(&self, at: PointF) -> (usize, usize) {
        if self.carets.is_empty() {
            return (0, 0);
        }
        let line = (((at.y - self.line_tops.first().map_or(0.0, |t| t.0)) / self.line_height)
            .floor()
            .max(0.0) as usize)
            .min(self.carets.len().saturating_sub(1));
        let xs = &self.carets[line];
        let col = xs
            .iter()
            .enumerate()
            .min_by(|a, b| (a.1 - at.x).abs().total_cmp(&(b.1 - at.x).abs()))
            .map_or(0, |(i, _)| i);
        (line, col)
    }

    /// The area the text covers (with its underline), for the handle.
    pub fn bounds(&self) -> Rect {
        self.coverage.rect()
    }
}

/// Sets `lines` at `origin` (the top of the first line; left, centre or
/// right of it by the alignment), clipped to `canvas`.
pub fn layout(
    lines: &[String],
    origin: PointF,
    style: &TextStyle,
    canvas: Rect,
) -> Result<TextLayout> {
    if !style.size.is_finite() || !(1.0..=MAX_FONT_SIZE).contains(&style.size) {
        return Err(invalid("the font size is outside 1..=2000"));
    }
    let face = load(&style.font, style.bold, style.italic)?;
    let font = &face.font;
    let px = style.pixels();
    let upem = font.units_per_em().unwrap_or(1000.0);
    let scale = px / upem;
    let ascent = font.ascent_unscaled() * scale;
    let descent = font.descent_unscaled() * scale;
    let line_height = (ascent - descent + font.line_gap_unscaled() * scale).max(1.0);
    let embolden = if face.fake_bold {
        (px / 24.0).max(1.0)
    } else {
        0.0
    };
    let slant = if face.fake_italic { SLANT } else { 0.0 };

    let mut glyphs: Vec<(GlyphId, f32, f32)> = Vec::new();
    let mut carets = Vec::with_capacity(lines.len());
    let mut line_tops = Vec::with_capacity(lines.len());
    let mut bars: Vec<(f32, f32, f32, f32)> = Vec::new();
    for (i, line) in lines.iter().enumerate() {
        let top = origin.y + i as f32 * line_height;
        let mut xs = vec![0.0f32];
        let mut x = 0.0;
        let mut prev: Option<GlyphId> = None;
        let mut placed = Vec::new();
        for c in line.chars() {
            let id = font.glyph_id(c);
            if let Some(p) = prev {
                x += font.kern_unscaled(p, id) * scale;
            }
            placed.push((id, x));
            x += font.h_advance_unscaled(id) * scale + embolden;
            xs.push(x);
            prev = Some(id);
        }
        let width = x;
        let left = match style.align {
            TextAlign::Left => origin.x,
            TextAlign::Center => origin.x - width / 2.0,
            TextAlign::Right => origin.x - width,
        };
        let baseline = top + ascent;
        for (id, gx) in placed {
            glyphs.push((id, left + gx, baseline));
        }
        if width > 0.0 {
            let thick = (px / 16.0).max(1.0);
            if style.underline {
                bars.push((left, baseline + thick, width, thick));
            }
            if style.strikeout {
                bars.push((left, baseline - ascent * 0.3, width, thick));
            }
        }
        carets.push(xs.iter().map(|v| left + v).collect());
        line_tops.push((top, line_height));
    }

    // Each glyph is rasterised over its own box and only where it meets
    // the canvas, so time and memory follow what is visible.
    let mut boxes = Vec::with_capacity(glyphs.len());
    for &(id, gx, base) in &glyphs {
        if let Some(o) = font.outline(id) {
            // ab_glyph keeps the top in `min.y` (font units, y up).
            let (b, t) = (
                o.bounds.max.y.min(o.bounds.min.y),
                o.bounds.max.y.max(o.bounds.min.y),
            );
            let (low, high) = (b * scale, t * scale);
            // The slant moves a point right by its height over the baseline.
            let x0 = gx + o.bounds.min.x * scale + low.min(0.0) * slant;
            let x1 = gx + o.bounds.max.x * scale + embolden + high.max(0.0) * slant;
            let r = Rect::covering(x0 - 1.0, base - high - 1.0, x1 + 1.0, base - low + 1.0);
            boxes.push((o, gx, base, r));
        }
    }
    let mut extent = Rect::default();
    for (.., r) in &boxes {
        extent = extent.union(*r);
    }
    for &(x, y, w, h) in &bars {
        extent = extent.union(Rect::covering(x, y, x + w, y + h));
    }
    let area = extent.intersect(canvas);
    let mut coverage = Mask::new(area);
    let aa = style.antialias;
    let passes: &[f32] = if embolden > 0.0 {
        &[0.0, embolden]
    } else {
        &[0.0]
    };
    for (outline, gx, base, r) in &boxes {
        let seen = r.intersect(canvas);
        if seen.is_empty() {
            continue;
        }
        if r.area() > MAX_TEXT_AREA {
            return Err(invalid("a glyph is too large to draw"));
        }
        let (ox, oy) = (r.x as f32, r.y as f32);
        let (rw, rh) = (r.width as f32, r.height as f32);
        let mut raster = Rasterizer::new(r.width as usize, r.height as usize);
        // The rasteriser wants every point inside its box.
        let inside = |x: f32, y: f32| point(x.clamp(0.0, rw), y.clamp(0.0, rh));
        for &shift in passes {
            // Font units are y up; the slant leans the top right.
            let map = |p: ab_glyph::Point| {
                let y = p.y * scale;
                inside(gx + shift + p.x * scale + y * slant - ox, base - y - oy)
            };
            for curve in &outline.curves {
                match *curve {
                    ab_glyph::OutlineCurve::Line(a, b) => raster.draw_line(map(a), map(b)),
                    ab_glyph::OutlineCurve::Quad(a, b, c) => {
                        raster.draw_quad(map(a), map(b), map(c))
                    }
                    ab_glyph::OutlineCurve::Cubic(a, b, c, d) => {
                        raster.draw_cubic(map(a), map(b), map(c), map(d))
                    }
                }
            }
        }
        put(&raster, *r, seen, aa, &mut coverage);
    }
    for &(x, y, w, h) in &bars {
        // A bar is a rectangle: rasterise only its visible part.
        let r = Rect::covering(x, y, x + w, y + h).intersect(canvas.inflate(1));
        if r.is_empty() {
            continue;
        }
        let (x0, x1) = (x.max(r.x as f32), (x + w).min(r.right() as f32));
        let (y0, y1) = (y.max(r.y as f32), (y + h).min(r.bottom() as f32));
        let mut raster = Rasterizer::new(r.width as usize, r.height as usize);
        let (ox, oy) = (r.x as f32, r.y as f32);
        let corners = [
            point(x0 - ox, y0 - oy),
            point(x1 - ox, y0 - oy),
            point(x1 - ox, y1 - oy),
            point(x0 - ox, y1 - oy),
        ];
        for k in 0..4 {
            raster.draw_line(corners[k], corners[(k + 1) % 4]);
        }
        put(&raster, r, r.intersect(canvas), aa, &mut coverage);
    }
    Ok(TextLayout {
        coverage,
        line_tops,
        carets,
        line_height,
    })
}

/// A raster laid over the coverage where `seen`, the larger value kept
/// where glyphs overlap.
fn put(raster: &Rasterizer, at: Rect, seen: Rect, aa: bool, coverage: &mut Mask) {
    raster.for_each_pixel_2d(|x, y, c| {
        // Overlapping passes of a fake bold add up past one.
        let c = c.abs().min(1.0);
        let v = if aa {
            (c * 255.0).round() as u8
        } else if c >= 0.5 {
            255
        } else {
            0
        };
        let (px, py) = (at.x + x as i32, at.y + y as i32);
        if v > coverage.get(px, py) && seen.contains(px, py) {
            coverage.set(px, py, v);
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    fn style() -> TextStyle {
        TextStyle {
            font: String::new(),
            size: 24.0,
            bold: false,
            italic: false,
            underline: false,
            strikeout: false,
            align: TextAlign::Left,
            antialias: true,
        }
    }

    fn inked(m: &Mask) -> u32 {
        let r = m.rect();
        let mut n = 0;
        for y in r.y..r.bottom() {
            for x in r.x..r.right() {
                n += m.get(x, y) as u32;
            }
        }
        n
    }

    fn set(text: &str, s: &TextStyle) -> TextLayout {
        let lines: Vec<String> = text.split('\n').map(str::to_owned).collect();
        layout(
            &lines,
            PointF::new(100.0, 20.0),
            s,
            Rect::new(0, 0, 400, 200),
        )
        .unwrap()
    }

    #[test]
    fn the_built_in_font_draws_latin_and_cyrillic() {
        let latin = set("Hello", &style());
        let cyrillic = set("Привіт", &style());
        assert!(inked(&latin.coverage) > 0);
        assert!(inked(&cyrillic.coverage) > 0);
        // 24 pt is 32 px: the text sits below the point clicked.
        let r = latin.bounds();
        assert!(r.y >= 20 && r.y < 40, "{r:?}");
        assert!(r.x >= 99);
        assert_eq!(font_names()[0], BUILT_IN);
    }

    #[test]
    fn alignment_puts_the_point_left_centre_or_right() {
        let left = set("Wide text", &style()).bounds();
        let centre = set(
            "Wide text",
            &TextStyle {
                align: TextAlign::Center,
                ..style()
            },
        )
        .bounds();
        let right = set(
            "Wide text",
            &TextStyle {
                align: TextAlign::Right,
                ..style()
            },
        )
        .bounds();
        assert!(left.x >= 99);
        assert!(right.right() <= 102);
        let mid = centre.x + centre.width as i32 / 2;
        assert!((mid - 100).abs() <= 3, "{centre:?}");
    }

    #[test]
    fn styles_change_the_ink() {
        let plain = inked(&set("Bold", &style()).coverage);
        let bold = inked(
            &set(
                "Bold",
                &TextStyle {
                    bold: true,
                    ..style()
                },
            )
            .coverage,
        );
        assert!(bold > plain * 11 / 10, "{bold} vs {plain}");
        let under = set(
            "Under",
            &TextStyle {
                underline: true,
                ..style()
            },
        );
        assert!(under.bounds().bottom() > set("Under", &style()).bounds().bottom());
        let italic = set(
            "l",
            &TextStyle {
                italic: true,
                ..style()
            },
        );
        let upright = set("l", &style());
        assert!(
            italic.bounds().width > upright.bounds().width,
            "{:?} {:?}",
            italic.bounds(),
            upright.bounds()
        );
    }

    #[test]
    fn large_text_draws_only_what_the_canvas_shows() {
        let many: Vec<String> = (0..60).map(|i| format!("Line {i} of text")).collect();
        let big = TextStyle {
            size: 200.0,
            ..style()
        };
        let set = layout(
            &many,
            PointF::new(10.0, 10.0),
            &big,
            Rect::new(0, 0, 800, 600),
        )
        .unwrap();
        assert!(set.bounds().width <= 800 && set.bounds().height <= 600);
        assert!(inked(&set.coverage) > 0);
        let none = layout(&[], PointF::default(), &style(), Rect::new(0, 0, 9, 9)).unwrap();
        assert_eq!(none.position_at(PointF::new(3.0, 3.0)), (0, 0));
    }

    #[test]
    fn carets_and_lines() {
        let two = set("ab\nc", &style());
        let (top, bottom) = two.caret(1, 0).unwrap();
        let (first, _) = two.caret(0, 0).unwrap();
        assert_eq!(first.x, 100.0);
        assert!(top.y > first.y);
        assert!(bottom.y > top.y);
        let (end, _) = two.caret(0, 2).unwrap();
        assert!(end.x > 100.0);
        assert_eq!(
            two.position_at(PointF::new(end.x + 1.0, first.y + 1.0)),
            (0, 2)
        );
        assert_eq!(two.position_at(PointF::new(99.0, top.y + 2.0)), (1, 0));
        let hard = set(
            "x",
            &TextStyle {
                antialias: false,
                ..style()
            },
        );
        let r = hard.bounds();
        for y in r.y..r.bottom() {
            for x in r.x..r.right() {
                assert!(matches!(hard.coverage.get(x, y), 0 | 255));
            }
        }
        assert!(layout(
            &[],
            PointF::default(),
            &TextStyle {
                size: 0.0,
                ..style()
            },
            Rect::new(0, 0, 9, 9)
        )
        .is_err());
    }
}
