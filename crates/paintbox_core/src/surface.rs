//! A rectangle of straight RGBA8 pixels: a layer's content, a lifted
//! fragment, a clipboard picture, a composite.

use crate::color::Rgba8;
use crate::error::{Error, Result};
use crate::geom::Rect;

/// The largest side accepted; keeps coordinates well inside `i32`.
pub const MAX_SIDE: u32 = 65_535;

/// The most pixels one surface may hold (512 MiB of RGBA): a file that
/// claims more is refused instead of exhausting memory.
pub const MAX_PIXELS: u64 = 1 << 27;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Surface {
    width: u32,
    height: u32,
    pixels: Vec<Rgba8>,
}

impl Surface {
    /// A transparent surface.
    pub fn new(width: u32, height: u32) -> Result<Self> {
        Self::filled(width, height, Rgba8::TRANSPARENT)
    }

    pub fn filled(width: u32, height: u32, color: Rgba8) -> Result<Self> {
        check_size(width, height)?;
        Ok(Self {
            width,
            height,
            pixels: try_buffer(width as usize * height as usize, color)?,
        })
    }

    /// From tightly packed straight RGBA bytes, row by row.
    pub fn from_rgba8(width: u32, height: u32, bytes: &[u8]) -> Result<Self> {
        check_size(width, height)?;
        if bytes.len() != width as usize * height as usize * 4 {
            return Err(Error::InvalidParameter(format!(
                "{} bytes do not make a {width}x{height} RGBA picture",
                bytes.len()
            )));
        }
        let pixels = bytes
            .as_chunks::<4>()
            .0
            .iter()
            .map(|p| Rgba8::new(p[0], p[1], p[2], p[3]))
            .collect();
        Ok(Self {
            width,
            height,
            pixels,
        })
    }

    pub(crate) fn from_pixels(width: u32, height: u32, pixels: Vec<Rgba8>) -> Self {
        debug_assert_eq!(pixels.len(), width as usize * height as usize);
        Self {
            width,
            height,
            pixels,
        }
    }

    pub fn width(&self) -> u32 {
        self.width
    }

    pub fn height(&self) -> u32 {
        self.height
    }

    pub fn bounds(&self) -> Rect {
        Rect::of_size(self.width, self.height)
    }

    pub fn pixels(&self) -> &[Rgba8] {
        &self.pixels
    }

    pub fn pixels_mut(&mut self) -> &mut [Rgba8] {
        &mut self.pixels
    }

    /// Straight RGBA bytes of the whole surface.
    pub fn to_rgba8(&self) -> Vec<u8> {
        self.rgba8_of(self.bounds())
    }

    /// Straight RGBA bytes of `rect` clipped to the surface, row by row;
    /// what a shell uploads into its texture for a dirty rectangle.
    pub fn rgba8_of(&self, rect: Rect) -> Vec<u8> {
        let rect = rect.intersect(self.bounds());
        let mut out = Vec::with_capacity(rect.area() as usize * 4);
        for y in rect.y..rect.bottom() {
            for p in &self.row(y)[rect.x as usize..rect.right() as usize] {
                out.extend_from_slice(&[p.r, p.g, p.b, p.a]);
            }
        }
        out
    }

    #[inline]
    pub(crate) fn index(&self, x: i32, y: i32) -> usize {
        y as usize * self.width as usize + x as usize
    }

    pub fn get(&self, x: i32, y: i32) -> Option<Rgba8> {
        if x < 0 || y < 0 || x >= self.width as i32 || y >= self.height as i32 {
            return None;
        }
        Some(self.pixels[self.index(x, y)])
    }

    /// The pixel with coordinates clamped to the edge.
    #[inline]
    pub(crate) fn at_clamped(&self, x: i32, y: i32) -> Rgba8 {
        let x = x.clamp(0, self.width as i32 - 1);
        let y = y.clamp(0, self.height as i32 - 1);
        self.pixels[self.index(x, y)]
    }

    #[inline]
    pub(crate) fn at(&self, x: i32, y: i32) -> Rgba8 {
        self.pixels[self.index(x, y)]
    }

    pub fn set(&mut self, x: i32, y: i32, color: Rgba8) {
        if x >= 0 && y >= 0 && x < self.width as i32 && y < self.height as i32 {
            let i = self.index(x, y);
            self.pixels[i] = color;
        }
    }

    #[inline]
    pub(crate) fn row(&self, y: i32) -> &[Rgba8] {
        let w = self.width as usize;
        &self.pixels[y as usize * w..(y as usize + 1) * w]
    }

    pub fn fill(&mut self, color: Rgba8) {
        self.pixels.fill(color);
    }

    /// A copy of `rect` clipped to the surface.
    pub fn crop(&self, rect: Rect) -> Surface {
        let rect = rect.intersect(self.bounds());
        let mut pixels = Vec::with_capacity(rect.area() as usize);
        for y in rect.y..rect.bottom() {
            pixels.extend_from_slice(&self.row(y)[rect.x as usize..rect.right() as usize]);
        }
        Surface::from_pixels(rect.width, rect.height, pixels)
    }

    /// Writes `pixels` (rows of `rect.width`) into `rect`, which lies
    /// inside the surface (history tiles).
    pub(crate) fn write_rect(&mut self, rect: Rect, pixels: &[Rgba8]) {
        let w = rect.width as usize;
        for (row, line) in pixels.chunks_exact(w.max(1)).enumerate() {
            let start = self.index(rect.x, rect.y + row as i32);
            self.pixels[start..start + w].copy_from_slice(line);
        }
    }

    /// Writes `src` with its top-left corner at `(x, y)`, replacing
    /// pixels; whatever falls outside is dropped.
    pub fn paste(&mut self, src: &Surface, x: i32, y: i32) {
        let target = src.bounds().translate(x, y).intersect(self.bounds());
        for ty in target.y..target.bottom() {
            let sx = (target.x - x) as usize;
            let line = &src.row(ty - y)[sx..sx + target.width as usize];
            let start = self.index(target.x, ty);
            self.pixels[start..start + target.width as usize].copy_from_slice(line);
        }
    }

    /// A bilinear sample at a pixel-centre coordinate (`(0, 0)` is the
    /// centre of the first pixel), alpha-weighted like the source's
    /// `GetBilinearSample`. Coordinates are clamped to the edge.
    pub fn bilinear(&self, x: f32, y: f32) -> Rgba8 {
        // Far outside is the edge anyway; clamping first keeps `x0 + 1` in
        // range for any input.
        let x = if x.is_finite() {
            x.clamp(-1.0, self.width as f32)
        } else {
            0.0
        };
        let y = if y.is_finite() {
            y.clamp(-1.0, self.height as f32)
        } else {
            0.0
        };
        let x0 = x.floor();
        let y0 = y.floor();
        let fx = x - x0;
        let fy = y - y0;
        let (x0, y0) = (x0 as i32, y0 as i32);
        bilinear_mix([
            (self.at_clamped(x0, y0), (1.0 - fx) * (1.0 - fy)),
            (self.at_clamped(x0 + 1, y0), fx * (1.0 - fy)),
            (self.at_clamped(x0, y0 + 1), (1.0 - fx) * fy),
            (self.at_clamped(x0 + 1, y0 + 1), fx * fy),
        ])
    }

    /// [`Surface::bilinear`] on the picture tiled without end, as the
    /// source's `GetBilinearSampleWrapped`: the right neighbour of the
    /// last column is the first. Not a number gives transparent.
    pub fn bilinear_wrapped(&self, x: f32, y: f32) -> Rgba8 {
        if !x.is_finite() || !y.is_finite() {
            return Rgba8::TRANSPARENT;
        }
        let (w, h) = (self.width as i64, self.height as i64);
        let (x0, y0) = (x.floor(), y.floor());
        let (fx, fy) = (x - x0, y - y0);
        let left = (x0 as i64).rem_euclid(w) as i32;
        let top = (y0 as i64).rem_euclid(h) as i32;
        let right = (left + 1) % w as i32;
        let bottom = (top + 1) % h as i32;
        bilinear_mix([
            (self.at(left, top), (1.0 - fx) * (1.0 - fy)),
            (self.at(right, top), fx * (1.0 - fy)),
            (self.at(left, bottom), (1.0 - fx) * fy),
            (self.at(right, bottom), fx * fy),
        ])
    }

    pub fn flip_horizontal(&mut self) {
        let w = self.width as usize;
        if w == 0 {
            return;
        }
        for row in self.pixels.chunks_exact_mut(w) {
            row.reverse();
        }
    }

    pub fn flip_vertical(&mut self) {
        let w = self.width as usize;
        let h = self.height as usize;
        for y in 0..h / 2 {
            let (top, bottom) = self.pixels.split_at_mut((h - 1 - y) * w);
            top[y * w..(y + 1) * w].swap_with_slice(&mut bottom[..w]);
        }
    }

    /// Rotated a quarter turn clockwise (`quarters = 1`), half (`2`) or
    /// a quarter counter-clockwise (`3`).
    pub fn rotated(&self, quarters: u32) -> Surface {
        let (w, h) = (self.width as i32, self.height as i32);
        match quarters % 4 {
            0 => self.clone(),
            2 => {
                let mut out = self.clone();
                out.pixels.reverse();
                out
            }
            q => {
                let mut pixels = Vec::with_capacity(self.pixels.len());
                for y in 0..w {
                    for x in 0..h {
                        let (sx, sy) = if q == 1 {
                            (y, h - 1 - x)
                        } else {
                            (w - 1 - y, x)
                        };
                        pixels.push(self.at(sx, sy));
                    }
                }
                Surface::from_pixels(self.height, self.width, pixels)
            }
        }
    }
}

/// Four corners with their weights, the colour weighted by alpha.
fn bilinear_mix(samples: [(Rgba8, f32); 4]) -> Rgba8 {
    let mut sums = [0f32; 4];
    for (c, w) in samples {
        let wa = w * c.a as f32;
        sums[0] += c.r as f32 * wa;
        sums[1] += c.g as f32 * wa;
        sums[2] += c.b as f32 * wa;
        sums[3] += wa;
    }
    if sums[3] <= 0.0 {
        return Rgba8::TRANSPARENT;
    }
    let to = |v: f32| v.round().clamp(0.0, 255.0) as u8;
    Rgba8::new(
        to(sums[0] / sums[3]),
        to(sums[1] / sums[3]),
        to(sums[2] / sums[3]),
        to(sums[3]),
    )
}

pub(crate) fn check_size(width: u32, height: u32) -> Result<()> {
    let too_big = width as u64 * height as u64 > MAX_PIXELS;
    if width == 0 || height == 0 || width > MAX_SIDE || height > MAX_SIDE || too_big {
        return Err(Error::InvalidSize { width, height });
    }
    Ok(())
}

/// A pixel buffer, or an error instead of the abort a failed `vec!`
/// would be.
pub(crate) fn try_buffer<T: Clone>(len: usize, value: T) -> Result<Vec<T>> {
    let mut buffer = Vec::new();
    buffer
        .try_reserve_exact(len)
        .map_err(|_| Error::OutOfMemory)?;
    buffer.resize(len, value);
    Ok(buffer)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn numbered(w: u32, h: u32) -> Surface {
        let pixels = (0..w * h).map(|i| Rgba8::new(i as u8, 0, 0, 255)).collect();
        Surface::from_pixels(w, h, pixels)
    }

    #[test]
    fn rejects_empty_and_huge_sizes() {
        assert!(Surface::new(0, 4).is_err());
        assert!(Surface::new(4, MAX_SIDE + 1).is_err());
        assert!(Surface::from_rgba8(2, 2, &[0; 15]).is_err());
    }

    #[test]
    fn crop_and_paste_round_trip() {
        let s = numbered(4, 3);
        let piece = s.crop(Rect::new(1, 1, 2, 2));
        assert_eq!(piece.at(0, 0).r, 5);
        let mut t = Surface::new(4, 3).unwrap();
        t.paste(&piece, 3, 2);
        assert_eq!(t.at(3, 2).r, 5);
        assert_eq!(t.at(0, 0), Rgba8::TRANSPARENT);
    }

    #[test]
    fn rotations_compose_and_flips_mirror() {
        let s = numbered(3, 2);
        let cw = s.rotated(1);
        assert_eq!((cw.width(), cw.height()), (2, 3));
        assert_eq!(cw.at(0, 0).r, 3);
        assert_eq!(cw.rotated(3), s);
        assert_eq!(s.rotated(1).rotated(1), s.rotated(2));
        let mut f = s.clone();
        f.flip_horizontal();
        assert_eq!(f.at(0, 0).r, 2);
        f.flip_vertical();
        assert_eq!(f.at(0, 0).r, 5);
    }

    #[test]
    fn bilinear_far_outside_is_the_edge() {
        let s = Surface::filled(4, 4, Rgba8::opaque(9, 8, 7)).unwrap();
        assert_eq!(s.bilinear(1e17, -1e17), Rgba8::opaque(9, 8, 7));
        assert_eq!(s.bilinear(f32::NAN, f32::INFINITY), Rgba8::opaque(9, 8, 7));
    }
}
