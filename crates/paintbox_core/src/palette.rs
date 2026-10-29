//! The Colors window's palette: exactly 96 swatches, read and written in
//! Paint.NET's text format (`AARRGGBB` per line, `;` starts a comment).

use crate::color::Rgba8;
use crate::error::{Error, Result};

pub const PALETTE_SIZE: usize = 96;

/// The first 64 swatches of the source's default palette; the last 32
/// repeat the first 32 at half alpha.
const DEFAULT_RGB: [u32; 64] = [
    0x000000, 0x404040, 0xff0000, 0xff6a00, 0xffd800, 0xb6ff00, 0x4cff00, 0x00ff21, 0x00ff90,
    0x00ffff, 0x0094ff, 0x0026ff, 0x4800ff, 0xb200ff, 0xff00dc, 0xff006e, 0xffffff, 0x808080,
    0x7f0000, 0x7f3300, 0x7f6a00, 0x5b7f00, 0x267f00, 0x007f0e, 0x007f46, 0x007f7f, 0x004a7f,
    0x00137f, 0x21007f, 0x57007f, 0x7f006e, 0x7f0037, 0xa0a0a0, 0x303030, 0xff7f7f, 0xffb27f,
    0xffe97f, 0xdaff7f, 0xa5ff7f, 0x7fff8e, 0x7fffc5, 0x7fffff, 0x7fc9ff, 0x7f92ff, 0xa17fff,
    0xd67fff, 0xff7fed, 0xff7fb6, 0xc0c0c0, 0x606060, 0x7f3f3f, 0x7f593f, 0x7f743f, 0x6d7f3f,
    0x527f3f, 0x3f7f47, 0x3f7f62, 0x3f7f7f, 0x3f647f, 0x3f497f, 0x503f7f, 0x6b3f7f, 0x7f3f76,
    0x7f3f5b,
];

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Palette {
    colors: Vec<Rgba8>,
}

impl Default for Palette {
    fn default() -> Self {
        let rgb = |v: u32, a: u8| Rgba8::new((v >> 16) as u8, (v >> 8) as u8, v as u8, a);
        let colors = DEFAULT_RGB
            .iter()
            .map(|&v| rgb(v, 255))
            .chain(DEFAULT_RGB[..32].iter().map(|&v| rgb(v, 0x80)))
            .collect();
        Self { colors }
    }
}

impl Palette {
    pub fn colors(&self) -> &[Rgba8] {
        &self.colors
    }

    /// Replaces one swatch (saving the current colour into it).
    pub fn set(&mut self, index: usize, color: Rgba8) -> Result<()> {
        let slot = self
            .colors
            .get_mut(index)
            .ok_or_else(|| Error::Palette(format!("no swatch {index}")))?;
        *slot = color;
        Ok(())
    }

    /// Reads a palette file: missing swatches are white, extra lines are
    /// ignored, a line that is not a colour is an error.
    pub fn parse(text: &str) -> Result<Self> {
        let mut colors = Vec::with_capacity(PALETTE_SIZE);
        for (number, line) in text.lines().enumerate() {
            let line = line.split(';').next().unwrap_or("").trim();
            if line.is_empty() {
                continue;
            }
            let color = Rgba8::from_argb_hex(line).ok_or_else(|| {
                Error::Palette(format!("line {} is not a colour: {line}", number + 1))
            })?;
            if colors.len() < PALETTE_SIZE {
                colors.push(color);
            }
        }
        colors.resize(PALETTE_SIZE, Rgba8::WHITE);
        Ok(Self { colors })
    }

    pub fn to_text(&self) -> String {
        let mut text = String::from("; Paintbox palette: one colour per line as AARRGGBB.\n");
        for c in &self.colors {
            text.push_str(&c.to_argb_hex());
            text.push('\n');
        }
        text
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn default_has_96_swatches_like_the_source() {
        let p = Palette::default();
        assert_eq!(p.colors().len(), PALETTE_SIZE);
        assert_eq!(p.colors()[2], Rgba8::opaque(255, 0, 0));
        assert_eq!(p.colors()[66], Rgba8::new(255, 0, 0, 0x80));
    }

    #[test]
    fn parse_pads_comments_and_round_trips() {
        let p = Palette::parse("; comment\nFFFF0000 ; red\n\n80123456\n").unwrap();
        assert_eq!(p.colors()[0], Rgba8::opaque(255, 0, 0));
        assert_eq!(p.colors()[1], Rgba8::new(0x12, 0x34, 0x56, 0x80));
        assert_eq!(p.colors()[2], Rgba8::WHITE);
        assert_eq!(Palette::parse(&p.to_text()).unwrap(), p);
        assert!(Palette::parse("nope").is_err());
    }
}
