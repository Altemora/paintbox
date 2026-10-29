//! The tools of the Tools window, their keys and the shared tool bar
//! settings. Keys are lower-case letters, so any shell maps its own key
//! codes to them.

use serde::{Deserialize, Serialize};

use crate::image_ops::Resampling;
use crate::mask::CombineMode;
use crate::select::MagicWandSettings;
use crate::stroke::{DashStyle, LineCap};
use crate::tools::{
    BrushSettings, FillSettings, FloodMode, GradientKind, GradientSettings, RecolorSettings,
    ShapeDraw, ShapeSettings, StrokeTool, MAX_BRUSH_WIDTH,
};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Tool {
    RectangleSelect,
    MoveSelectedPixels,
    LassoSelect,
    MoveSelection,
    EllipseSelect,
    Zoom,
    MagicWand,
    Pan,
    PaintBucket,
    Gradient,
    Paintbrush,
    Eraser,
    Pencil,
    ColorPicker,
    CloneStamp,
    Recolor,
    Text,
    LineCurve,
    Rectangle,
    RoundedRectangle,
    Ellipse,
    FreeformShape,
}

impl Tool {
    /// In the order of the Tools window (two per row).
    pub const ALL: [Tool; 22] = [
        Tool::RectangleSelect,
        Tool::MoveSelectedPixels,
        Tool::LassoSelect,
        Tool::MoveSelection,
        Tool::EllipseSelect,
        Tool::Zoom,
        Tool::MagicWand,
        Tool::Pan,
        Tool::PaintBucket,
        Tool::Gradient,
        Tool::Paintbrush,
        Tool::Eraser,
        Tool::Pencil,
        Tool::ColorPicker,
        Tool::CloneStamp,
        Tool::Recolor,
        Tool::Text,
        Tool::LineCurve,
        Tool::Rectangle,
        Tool::RoundedRectangle,
        Tool::Ellipse,
        Tool::FreeformShape,
    ];

    pub fn name(self) -> &'static str {
        match self {
            Tool::RectangleSelect => "Rectangle Select",
            Tool::MoveSelectedPixels => "Move Selected Pixels",
            Tool::LassoSelect => "Lasso Select",
            Tool::MoveSelection => "Move Selection",
            Tool::EllipseSelect => "Ellipse Select",
            Tool::Zoom => "Zoom",
            Tool::MagicWand => "Magic Wand",
            Tool::Pan => "Pan",
            Tool::PaintBucket => "Paint Bucket",
            Tool::Gradient => "Gradient",
            Tool::Paintbrush => "Paintbrush",
            Tool::Eraser => "Eraser",
            Tool::Pencil => "Pencil",
            Tool::ColorPicker => "Color Picker",
            Tool::CloneStamp => "Clone Stamp",
            Tool::Recolor => "Recolor",
            Tool::Text => "Text",
            Tool::LineCurve => "Line / Curve",
            Tool::Rectangle => "Rectangle",
            Tool::RoundedRectangle => "Rounded Rectangle",
            Tool::Ellipse => "Ellipse",
            Tool::FreeformShape => "Freeform Shape",
        }
    }

    /// The letter that selects the tool (several tools share one).
    pub fn key(self) -> char {
        match self {
            Tool::RectangleSelect | Tool::LassoSelect | Tool::EllipseSelect | Tool::MagicWand => {
                's'
            }
            Tool::MoveSelectedPixels | Tool::MoveSelection => 'm',
            Tool::Zoom => 'z',
            Tool::Pan => 'h',
            Tool::PaintBucket => 'f',
            Tool::Gradient => 'g',
            Tool::Paintbrush => 'b',
            Tool::Eraser => 'e',
            Tool::Pencil => 'p',
            Tool::ColorPicker => 'k',
            Tool::CloneStamp => 'l',
            Tool::Recolor => 'r',
            Tool::Text => 't',
            Tool::LineCurve
            | Tool::Rectangle
            | Tool::RoundedRectangle
            | Tool::Ellipse
            | Tool::FreeformShape => 'o',
        }
    }

    /// The status bar hint.
    pub fn hint(self) -> &'static str {
        match self {
            Tool::RectangleSelect => {
                "Click and drag to draw a rectangular selection. Hold Shift for a square."
            }
            Tool::MoveSelectedPixels => {
                "Drag the selection to move it. Hold Ctrl to leave a copy. Arrow keys nudge."
            }
            Tool::LassoSelect => "Click and drag to draw the outline of a selection.",
            Tool::MoveSelection => "Drag the selection outline to move it. The pixels stay.",
            Tool::EllipseSelect => {
                "Click and drag to draw an elliptical selection. Hold Shift for a circle."
            }
            Tool::Zoom => {
                "Left click to zoom in, right click to zoom out, drag a rectangle to zoom to it."
            }
            Tool::MagicWand => "Click to select an area of similar color. Shift selects globally.",
            Tool::Pan => "Drag to move the view.",
            Tool::PaintBucket => {
                "Left click fills with the primary color, right click with the secondary."
            }
            Tool::Gradient => {
                "Drag to draw a gradient. Drag the handles to adjust it, Enter to finish."
            }
            Tool::Paintbrush => {
                "Left button paints with the primary color, right with the secondary."
            }
            Tool::Eraser => "Drag to erase to transparency.",
            Tool::Pencil => "Draws one-pixel lines without antialiasing.",
            Tool::ColorPicker => "Left click sets the primary color, right click the secondary.",
            Tool::CloneStamp => "Ctrl+click to set the source, then drag to paint from it.",
            Tool::Recolor => {
                "Replaces the secondary color with the primary where you paint. Ctrl+click picks."
            }
            Tool::Text => "Click to place the cursor, then type. Drag the handle or with the right button to move it.",
            Tool::LineCurve => "Drag to draw a line. Drag the handles to bend it, Enter to finish.",
            Tool::Rectangle => "Drag to draw a rectangle. Hold Shift for a square.",
            Tool::RoundedRectangle => "Drag to draw a rounded rectangle. Hold Shift for a square.",
            Tool::Ellipse => "Drag to draw an ellipse. Hold Shift for a circle.",
            Tool::FreeformShape => "Drag to draw a closed freeform shape.",
        }
    }

    /// A stable snake_case name for shells and scripts.
    pub fn id(self) -> &'static str {
        match self {
            Tool::RectangleSelect => "rectangle_select",
            Tool::MoveSelectedPixels => "move_selected_pixels",
            Tool::LassoSelect => "lasso_select",
            Tool::MoveSelection => "move_selection",
            Tool::EllipseSelect => "ellipse_select",
            Tool::Zoom => "zoom",
            Tool::MagicWand => "magic_wand",
            Tool::Pan => "pan",
            Tool::PaintBucket => "paint_bucket",
            Tool::Gradient => "gradient",
            Tool::Paintbrush => "paintbrush",
            Tool::Eraser => "eraser",
            Tool::Pencil => "pencil",
            Tool::ColorPicker => "color_picker",
            Tool::CloneStamp => "clone_stamp",
            Tool::Recolor => "recolor",
            Tool::Text => "text",
            Tool::LineCurve => "line_curve",
            Tool::Rectangle => "rectangle",
            Tool::RoundedRectangle => "rounded_rectangle",
            Tool::Ellipse => "ellipse",
            Tool::FreeformShape => "freeform_shape",
        }
    }

    pub fn from_id(id: &str) -> Option<Tool> {
        Tool::ALL.iter().copied().find(|t| t.id() == id)
    }

    pub fn is_available(self) -> bool {
        true
    }

    pub fn is_selection(self) -> bool {
        matches!(
            self,
            Tool::RectangleSelect | Tool::LassoSelect | Tool::EllipseSelect | Tool::MagicWand
        )
    }

    /// The tools sharing a key, in the order the key cycles them.
    pub fn with_key(key: char) -> Vec<Tool> {
        let key = key.to_ascii_lowercase();
        Tool::ALL
            .iter()
            .copied()
            .filter(|t| t.key() == key && t.is_available())
            .collect()
    }
}

/// Pressing a tool key: within two seconds the same key moves to the
/// next tool with it (Shift: the previous); later it starts over.
#[derive(Debug, Default)]
pub struct KeyCycle {
    last: Option<(char, f64)>,
}

pub const CYCLE_SECONDS: f64 = 2.0;

impl KeyCycle {
    /// The tool a key press selects, if the key belongs to tools; `now`
    /// in seconds.
    pub fn press(&mut self, key: char, shift: bool, now: f64, current: Tool) -> Option<Tool> {
        let key = key.to_ascii_lowercase();
        let tools = Tool::with_key(key);
        if tools.is_empty() {
            return None;
        }
        let recent = matches!(self.last, Some((k, t)) if k == key && now - t <= CYCLE_SECONDS);
        self.last = Some((key, now));
        let position = tools.iter().position(|&t| t == current);
        // After a pause the list starts over: from the first tool, or with
        // Shift from the last.
        let next = match (recent, position) {
            (true, Some(i)) if shift => tools[(i + tools.len() - 1) % tools.len()],
            (true, Some(i)) => tools[(i + 1) % tools.len()],
            _ if shift => tools[tools.len() - 1],
            _ => tools[0],
        };
        Some(next)
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum SelectDraw {
    #[default]
    Normal,
    FixedRatio,
    FixedSize,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Serialize, Deserialize)]
pub enum PickerAfter {
    #[default]
    Stay,
    PreviousTool,
    Pencil,
}

/// Text sizes above this are refused as nonsense.
pub const MAX_FONT_SIZE: f32 = 2000.0;

/// Text's alignment about the point clicked.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Default, Hash, Serialize, Deserialize)]
pub enum TextAlign {
    #[default]
    Left,
    Center,
    Right,
}

/// The tool bar's settings, shared between tools as in Paint.NET. Fields
/// missing in stored settings take their defaults.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(default)]
pub struct ToolSettings {
    pub width: f32,
    pub antialias: bool,
    pub alpha_blending: bool,
    pub hardness: f32,
    /// 0 – 1.
    pub tolerance: f32,
    pub flood_mode: FloodMode,
    pub selection_mode: CombineMode,
    pub select_draw: SelectDraw,
    pub fixed: (f32, f32),
    pub resampling: Resampling,
    pub gradient: GradientKind,
    pub gradient_transparency: bool,
    pub shape_draw: ShapeDraw,
    pub picker_after: PickerAfter,
    /// Line / Curve's ends and dash.
    pub line_start: LineCap,
    pub line_end: LineCap,
    pub dash: DashStyle,
    /// Text's font by family name; empty is the built-in one.
    pub font: String,
    /// In points, as Paint.NET's font box (96 pixels to the inch).
    pub font_size: f32,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub strikeout: bool,
    pub text_align: TextAlign,
}

impl Default for ToolSettings {
    fn default() -> Self {
        Self {
            width: 2.0,
            antialias: true,
            alpha_blending: true,
            hardness: 1.0,
            tolerance: 0.5,
            flood_mode: FloodMode::Local,
            selection_mode: CombineMode::Replace,
            select_draw: SelectDraw::Normal,
            fixed: (4.0, 3.0),
            resampling: Resampling::Bilinear,
            gradient: GradientKind::Linear,
            gradient_transparency: false,
            shape_draw: ShapeDraw::Outline,
            picker_after: PickerAfter::Stay,
            line_start: LineCap::Flat,
            line_end: LineCap::Flat,
            dash: DashStyle::Solid,
            font: String::new(),
            font_size: 12.0,
            bold: false,
            italic: false,
            underline: false,
            strikeout: false,
            text_align: TextAlign::Left,
        }
    }
}

impl ToolSettings {
    pub fn brush(&self) -> BrushSettings {
        BrushSettings {
            width: self.width,
            antialias: self.antialias,
            alpha_blending: self.alpha_blending,
            hardness: self.hardness,
        }
    }

    /// The stroke a tool paints, if it paints by strokes.
    pub fn stroke(&self, tool: Tool) -> Option<StrokeTool> {
        Some(match tool {
            Tool::Pencil => StrokeTool::Pencil {
                alpha_blending: self.alpha_blending,
            },
            Tool::Paintbrush => StrokeTool::Paintbrush(self.brush()),
            Tool::Eraser => StrokeTool::Eraser(self.brush()),
            Tool::CloneStamp => StrokeTool::CloneStamp(self.brush()),
            Tool::Recolor => StrokeTool::Recolor(RecolorSettings {
                width: self.width,
                antialias: self.antialias,
                tolerance: self.tolerance,
            }),
            _ => return None,
        })
    }

    pub fn fill(&self) -> FillSettings {
        FillSettings {
            mode: self.flood_mode,
            tolerance: self.tolerance,
            antialias: self.antialias,
            alpha_blending: self.alpha_blending,
        }
    }

    pub fn wand(&self) -> MagicWandSettings {
        MagicWandSettings {
            mode: self.flood_mode,
            tolerance: self.tolerance,
        }
    }

    pub fn gradient(&self) -> GradientSettings {
        GradientSettings {
            kind: self.gradient,
            transparency: self.gradient_transparency,
            alpha_blending: self.alpha_blending,
        }
    }

    pub fn shape(&self) -> ShapeSettings {
        ShapeSettings {
            draw: self.shape_draw,
            width: self.width,
            antialias: self.antialias,
            alpha_blending: self.alpha_blending,
            line_start: self.line_start,
            line_end: self.line_end,
            dash: self.dash,
        }
    }

    /// Settings read back from storage, kept in their ranges.
    pub fn sanitized(mut self) -> Self {
        let d = Self::default();
        let ok =
            |v: f32, lo: f32, hi: f32, def: f32| if v.is_finite() { v.clamp(lo, hi) } else { def };
        self.width = ok(self.width, 1.0, MAX_BRUSH_WIDTH, d.width);
        self.hardness = ok(self.hardness, 0.0, 1.0, d.hardness);
        self.tolerance = ok(self.tolerance, 0.0, 1.0, d.tolerance);
        self.font_size = ok(self.font_size, 1.0, MAX_FONT_SIZE, d.font_size);
        self.fixed = (
            ok(self.fixed.0, 1.0, 65535.0, d.fixed.0),
            ok(self.fixed.1, 1.0, 65535.0, d.fixed.1),
        );
        self
    }

    /// Line / Curve's keys: `,` the start, `.` the dash, `/` the end,
    /// each to the next in the bar. False for any other key.
    pub fn cycle_line(&mut self, key: char) -> bool {
        match key {
            ',' => self.line_start = self.line_start.next(),
            '.' => self.dash = self.dash.next(),
            '/' => self.line_end = self.line_end.next(),
            _ => return false,
        }
        true
    }

    /// `[` and `]`: one pixel, five with Ctrl.
    pub fn step_width(&mut self, grow: bool, ctrl: bool) {
        let step = if ctrl { 5.0 } else { 1.0 };
        let width = if grow {
            self.width + step
        } else {
            self.width - step
        };
        self.width = width.clamp(1.0, MAX_BRUSH_WIDTH);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn s_cycles_within_two_seconds_and_restarts_after() {
        let mut cycle = KeyCycle::default();
        let mut tool = Tool::Paintbrush;
        tool = cycle.press('s', false, 0.0, tool).unwrap();
        assert_eq!(tool, Tool::RectangleSelect);
        tool = cycle.press('s', false, 1.0, tool).unwrap();
        assert_eq!(tool, Tool::LassoSelect);
        tool = cycle.press('s', false, 2.5, tool).unwrap();
        assert_eq!(tool, Tool::EllipseSelect);
        tool = cycle.press('s', true, 3.0, tool).unwrap();
        assert_eq!(tool, Tool::LassoSelect);
        tool = cycle.press('s', false, 10.0, tool).unwrap();
        assert_eq!(tool, Tool::RectangleSelect);
        assert_eq!(cycle.press('t', false, 11.0, tool), Some(Tool::Text));
        assert_eq!(cycle.press('s', true, 20.0, tool), Some(Tool::MagicWand));
    }

    #[test]
    fn width_steps_stay_in_range() {
        let mut s = ToolSettings::default();
        s.step_width(false, true);
        assert_eq!(s.width, 1.0);
        s.step_width(true, false);
        assert_eq!(s.width, 2.0);
    }
}
