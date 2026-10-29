//! The Text tool's live text, as Paint.NET's `TextTool`: a click places
//! the caret, typing opens the edit (one step, "Text"), Enter breaks the
//! line, Esc or a click elsewhere commits. The right button or the
//! handle at the text's corner drags it while typing; settings and
//! colours changed meanwhile redraw it.

use crate::blend::over;
use crate::color::lerp;
use crate::color::{mul255, Rgba8};
use crate::document::Document;
use crate::error::Result;
use crate::geom::{PointF, Rect};
use crate::mask::Mask;
use crate::text::{layout, TextStyle};
use crate::tool::ToolSettings;

/// A key the text takes while typing.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TextKey {
    Backspace,
    Delete,
    Enter,
    Left,
    Right,
    Up,
    Down,
    Home,
    End,
}

pub(crate) struct LiveText {
    pub origin: PointF,
    pub lines: Vec<String>,
    pub line: usize,
    /// Characters, not bytes.
    pub col: usize,
    /// The document's edit is open (something was typed).
    pub editing: bool,
    /// A drag moving the text: where it was pressed and the origin then.
    pub drag: Option<(PointF, PointF)>,
    /// The caret and the text's extent, as last laid out.
    pub caret: Option<(PointF, PointF)>,
    pub extent: Rect,
    /// Where each line's characters stand, for a click into the text.
    pub layout: Option<crate::text::TextLayout>,
}

impl LiveText {
    pub fn at(origin: PointF) -> LiveText {
        LiveText {
            origin,
            lines: vec![String::new()],
            line: 0,
            col: 0,
            editing: false,
            drag: None,
            caret: None,
            extent: Rect::default(),
            layout: None,
        }
    }

    /// The handle that drags the text: its top-left corner.
    pub fn handle(&self) -> PointF {
        if self.extent.is_empty() {
            self.origin
        } else {
            PointF::new(self.extent.x as f32, self.extent.y as f32)
        }
    }

    /// Whether a press at `at` lands in the text (to move the caret).
    pub fn contains(&self, at: PointF, slack: f32) -> bool {
        let r = self.extent;
        !r.is_empty()
            && at.x >= r.x as f32 - slack
            && at.x <= r.right() as f32 + slack
            && at.y >= r.y as f32 - slack
            && at.y <= r.bottom() as f32 + slack
    }

    fn chars(&self) -> usize {
        self.lines[self.line].chars().count()
    }

    fn byte(&self, line: usize, col: usize) -> usize {
        self.lines[line]
            .char_indices()
            .nth(col)
            .map_or(self.lines[line].len(), |(i, _)| i)
    }

    /// Types `text` at the caret; control characters are left out.
    pub fn insert(&mut self, text: &str) -> bool {
        let mut typed = false;
        for c in text.chars().filter(|c| !c.is_control()) {
            let at = self.byte(self.line, self.col);
            self.lines[self.line].insert(at, c);
            self.col += 1;
            typed = true;
        }
        typed
    }

    /// A key; `ctrl` makes Left and Right go by words, Home and End to the
    /// whole text's ends, Backspace and Delete take a word. Returns
    /// whether the text changed (not only the caret).
    pub fn key(&mut self, key: TextKey, ctrl: bool) -> bool {
        match key {
            TextKey::Enter => {
                let at = self.byte(self.line, self.col);
                let rest = self.lines[self.line].split_off(at);
                self.line += 1;
                self.lines.insert(self.line, rest);
                self.col = 0;
                true
            }
            TextKey::Backspace => {
                if self.col == 0 {
                    if self.line == 0 {
                        return false;
                    }
                    let rest = self.lines.remove(self.line);
                    self.line -= 1;
                    self.col = self.chars();
                    self.lines[self.line].push_str(&rest);
                    return true;
                }
                let from = if ctrl { self.word_left() } else { self.col - 1 };
                let (a, b) = (self.byte(self.line, from), self.byte(self.line, self.col));
                self.lines[self.line].replace_range(a..b, "");
                self.col = from;
                true
            }
            TextKey::Delete => {
                if self.col == self.chars() {
                    if self.line + 1 >= self.lines.len() {
                        return false;
                    }
                    let next = self.lines.remove(self.line + 1);
                    self.lines[self.line].push_str(&next);
                    return true;
                }
                let to = if ctrl {
                    self.word_right()
                } else {
                    self.col + 1
                };
                let (a, b) = (self.byte(self.line, self.col), self.byte(self.line, to));
                self.lines[self.line].replace_range(a..b, "");
                true
            }
            TextKey::Left => {
                if self.col > 0 {
                    self.col = if ctrl { self.word_left() } else { self.col - 1 };
                } else if self.line > 0 {
                    self.line -= 1;
                    self.col = self.chars();
                }
                false
            }
            TextKey::Right => {
                if self.col < self.chars() {
                    self.col = if ctrl {
                        self.word_right()
                    } else {
                        self.col + 1
                    };
                } else if self.line + 1 < self.lines.len() {
                    self.line += 1;
                    self.col = 0;
                }
                false
            }
            TextKey::Up | TextKey::Down => {
                let target = if key == TextKey::Up {
                    self.line.checked_sub(1)
                } else {
                    Some(self.line + 1).filter(|&l| l < self.lines.len())
                };
                if let Some(target) = target {
                    // Keep the caret's x, as an editor does.
                    let x = self.caret.map(|c| c.0.x);
                    self.line = target;
                    self.col = match (x, &self.layout) {
                        (Some(x), Some(l)) => {
                            let y = l.caret(target, 0).map_or(0.0, |c| c.0.y + 1.0);
                            l.position_at(PointF::new(x, y)).1
                        }
                        _ => self.col,
                    }
                    .min(self.chars());
                }
                false
            }
            TextKey::Home => {
                if ctrl {
                    self.line = 0;
                }
                self.col = 0;
                false
            }
            TextKey::End => {
                if ctrl {
                    self.line = self.lines.len() - 1;
                }
                self.col = self.chars();
                false
            }
        }
    }

    fn word_left(&self) -> usize {
        let chars: Vec<char> = self.lines[self.line].chars().collect();
        let mut i = self.col;
        while i > 0 && chars[i - 1].is_whitespace() {
            i -= 1;
        }
        while i > 0 && !chars[i - 1].is_whitespace() {
            i -= 1;
        }
        i
    }

    fn word_right(&self) -> usize {
        let chars: Vec<char> = self.lines[self.line].chars().collect();
        let mut i = self.col;
        while i < chars.len() && !chars[i].is_whitespace() {
            i += 1;
        }
        while i < chars.len() && chars[i].is_whitespace() {
            i += 1;
        }
        i
    }

    /// Lays the text out with `settings` and, once something was typed,
    /// paints it in the primary colour from the edit's originals.
    pub fn draw(&mut self, doc: &mut Document, settings: &ToolSettings) -> Result<()> {
        let style = TextStyle::of(settings);
        let set = layout(&self.lines, self.origin, &style, doc.bounds())?;
        self.caret = set.caret(self.line, self.col);
        self.extent = set.bounds();
        if self.editing {
            doc.draw_text(&set.coverage, settings.alpha_blending)?;
        }
        self.layout = Some(set);
        Ok(())
    }
}

impl Document {
    /// Paints text coverage in the primary colour inside the open edit,
    /// from the originals, within the selection.
    pub(crate) fn draw_text(&mut self, coverage: &Mask, alpha_blending: bool) -> Result<()> {
        let color: Rgba8 = self.colors().primary;
        self.restore_edit();
        let rect = coverage.rect();
        self.paint_region(
            rect,
            |x, y| coverage.get(x, y),
            move |o, c, _, _| {
                if alpha_blending {
                    over(o, color.with_alpha(mul255(color.a as u32, c as u32) as u8))
                } else {
                    lerp(o, color, c)
                }
            },
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn text(lines: &[&str], line: usize, col: usize) -> LiveText {
        LiveText {
            lines: lines.iter().map(|s| s.to_string()).collect(),
            line,
            col,
            ..LiveText::at(PointF::default())
        }
    }

    #[test]
    fn typing_and_line_breaks() {
        let mut t = LiveText::at(PointF::default());
        assert!(t.insert("Привіт\u{8}"));
        assert_eq!(t.lines, ["Привіт"]);
        t.key(TextKey::Left, false);
        t.key(TextKey::Left, false);
        t.key(TextKey::Enter, false);
        assert_eq!(t.lines, ["Прив", "іт"]);
        assert_eq!((t.line, t.col), (1, 0));
        t.key(TextKey::Backspace, false);
        assert_eq!(t.lines, ["Привіт"]);
        assert_eq!(t.col, 4);
        t.key(TextKey::Delete, false);
        assert_eq!(t.lines, ["Привт"]);
    }

    #[test]
    fn words_and_ends() {
        let mut t = text(&["one two  three"], 0, 14);
        t.key(TextKey::Left, true);
        assert_eq!(t.col, 9);
        t.key(TextKey::Backspace, true);
        assert_eq!(t.lines, ["one three"]);
        t.key(TextKey::Home, false);
        t.key(TextKey::Right, true);
        assert_eq!(t.col, 4);
        t.key(TextKey::Delete, true);
        assert_eq!(t.lines, ["one "]);
        let mut many = text(&["a", "bc"], 0, 0);
        many.key(TextKey::End, true);
        assert_eq!((many.line, many.col), (1, 2));
        many.key(TextKey::Right, false);
        assert_eq!((many.line, many.col), (1, 2));
        assert!(!many.key(TextKey::Delete, false));
    }
}
