//! The composited picture cut into tiles, as a shell uploads it: the
//! Flutter program keeps 256 × 256 images.

use crate::document::Document;
use crate::geom::Rect;
use crate::surface::Surface;

/// One tile's pixels, RGBA8 row by row.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Tile {
    pub rect: Rect,
    pub pixels: Vec<u8>,
}

impl Document {
    /// The composited picture of every `tile`-sized tile touching `area`,
    /// in one pass. Straight RGBA as the core keeps it, or premultiplied
    /// (what Flutter's raw images take).
    pub fn composite_tiles(&self, area: Rect, tile: u32, premultiplied: bool) -> Vec<Tile> {
        let mut out = Vec::new();
        let tile = tile.clamp(1, 4096) as i32;
        let cut = area.intersect(self.bounds());
        if cut.is_empty() {
            return out;
        }
        // The area grown to whole tiles, so each tile's bytes are whole.
        let x0 = cut.x.div_euclid(tile) * tile;
        let y0 = cut.y.div_euclid(tile) * tile;
        let x1 = (cut.right() + tile - 1).div_euclid(tile) * tile;
        let y1 = (cut.bottom() + tile - 1).div_euclid(tile) * tile;
        let grown = Rect::from_edges(x0, y0, x1, y1).intersect(self.bounds());
        let mut bytes = self.composite_rgba8(grown);
        if premultiplied {
            premultiply(&mut bytes);
        }
        let row = grown.width as usize * 4;
        let mut ty = grown.y;
        while ty < grown.bottom() {
            let th = tile.min(grown.bottom() - ty);
            let mut tx = grown.x;
            while tx < grown.right() {
                let tw = tile.min(grown.right() - tx);
                let mut pixels = Vec::with_capacity(tw as usize * th as usize * 4);
                for y in ty..ty + th {
                    let start = (y - grown.y) as usize * row + (tx - grown.x) as usize * 4;
                    if let Some(line) = bytes.get(start..start + tw as usize * 4) {
                        pixels.extend_from_slice(line);
                    }
                }
                out.push(Tile {
                    rect: Rect::new(tx, ty, tw as u32, th as u32),
                    pixels,
                });
                tx += tile;
            }
            ty += tile;
        }
        out
    }
}

impl Surface {
    /// Premultiplied RGBA bytes of the whole surface, for a thumbnail.
    pub fn to_premultiplied_rgba8(&self) -> Vec<u8> {
        let mut bytes = self.to_rgba8();
        premultiply(&mut bytes);
        bytes
    }
}

/// Straight RGBA8 to premultiplied, rounding to nearest.
pub fn premultiply(bytes: &mut [u8]) {
    for px in bytes.as_chunks_mut::<4>().0 {
        let a = px[3] as u32;
        if a == 255 {
            continue;
        }
        for c in &mut px[..3] {
            *c = ((*c as u32 * a + 127) / 255) as u8;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::color::Rgba8;

    #[test]
    fn tiles_cover_the_area_grown_to_whole_tiles() {
        let doc = Document::new(100, 70, Rgba8::new(200, 100, 50, 128)).unwrap();
        let tiles = doc.composite_tiles(Rect::new(30, 10, 10, 10), 32, false);
        assert_eq!(tiles.len(), 2);
        assert_eq!(tiles[0].rect, Rect::new(0, 0, 32, 32));
        assert_eq!(tiles[1].rect, Rect::new(32, 0, 32, 32));
        assert_eq!(tiles[0].pixels.len(), 32 * 32 * 4);
        assert_eq!(&tiles[0].pixels[..4], &[200, 100, 50, 128]);
        let edge = doc.composite_tiles(Rect::new(90, 60, 50, 50), 32, true);
        let rects: Vec<_> = edge.iter().map(|t| t.rect).collect();
        assert_eq!(
            rects,
            [
                Rect::new(64, 32, 32, 32),
                Rect::new(96, 32, 4, 32),
                Rect::new(64, 64, 32, 6),
                Rect::new(96, 64, 4, 6),
            ]
        );
        assert_eq!(&edge[0].pixels[..4], &[100, 50, 25, 128]);
        assert!(doc
            .composite_tiles(Rect::new(200, 0, 5, 5), 32, false)
            .is_empty());
    }
}
