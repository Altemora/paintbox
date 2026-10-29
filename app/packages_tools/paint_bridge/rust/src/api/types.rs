//! The core's plain values as Dart sees them: mirrors (the core keeps
//! its own types, the bridge generates Dart classes and enums for them)
//! and the few records the bridge adds.

use flutter_rust_bridge::frb;
pub use paintbox_core::{
    Anchor, BlendMode, CombineMode, CurveMode, Curves, DashStyle, FloodMode, GradientKind,
    LayerProperties, LineCap, PickerAfter, PointF, Rect, Resampling, Rgba8, SelectDraw, ShapeDraw,
    TextAlign, TextKey, Tool, ToolSettings, UserColors,
};

#[frb(mirror(Rgba8))]
pub struct _Rgba8 {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

#[frb(mirror(Rect))]
pub struct _Rect {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
}

#[frb(mirror(PointF))]
pub struct _PointF {
    pub x: f32,
    pub y: f32,
}

#[frb(mirror(UserColors))]
pub struct _UserColors {
    pub primary: Rgba8,
    pub secondary: Rgba8,
}

#[frb(mirror(LayerProperties))]
pub struct _LayerProperties {
    pub name: String,
    pub visible: bool,
    pub opacity: u8,
    pub blend_mode: BlendMode,
    pub is_background: bool,
}

#[frb(mirror(ToolSettings))]
pub struct _ToolSettings {
    pub width: f32,
    pub antialias: bool,
    pub alpha_blending: bool,
    pub hardness: f32,
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
    pub line_start: LineCap,
    pub line_end: LineCap,
    pub dash: DashStyle,
    pub font: String,
    pub font_size: f32,
    pub bold: bool,
    pub italic: bool,
    pub underline: bool,
    pub strikeout: bool,
    pub text_align: TextAlign,
}

#[frb(mirror(LineCap))]
pub enum _LineCap {
    Flat,
    Arrow,
    ArrowFilled,
    Rounded,
}

#[frb(mirror(DashStyle))]
pub enum _DashStyle {
    Solid,
    Dash,
    DashDot,
    DashDotDot,
    Dot,
}

#[frb(mirror(TextAlign))]
pub enum _TextAlign {
    Left,
    Center,
    Right,
}

#[frb(mirror(TextKey))]
pub enum _TextKey {
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

#[frb(mirror(Tool))]
pub enum _Tool {
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

#[frb(mirror(BlendMode))]
pub enum _BlendMode {
    Normal,
    Multiply,
    Additive,
    ColorBurn,
    ColorDodge,
    Reflect,
    Glow,
    Overlay,
    Difference,
    Negation,
    Lighten,
    Darken,
    Screen,
    Xor,
}

#[frb(mirror(FloodMode))]
pub enum _FloodMode {
    Local,
    Global,
}

#[frb(mirror(CombineMode))]
pub enum _CombineMode {
    Replace,
    Union,
    Exclude,
    Xor,
    Intersect,
}

#[frb(mirror(SelectDraw))]
pub enum _SelectDraw {
    Normal,
    FixedRatio,
    FixedSize,
}

#[frb(mirror(Resampling))]
pub enum _Resampling {
    NearestNeighbor,
    Bilinear,
}

#[frb(mirror(GradientKind))]
pub enum _GradientKind {
    Linear,
    LinearReflected,
    Diamond,
    Radial,
    Conical,
}

#[frb(mirror(ShapeDraw))]
pub enum _ShapeDraw {
    Outline,
    Interior,
    Both,
}

#[frb(mirror(PickerAfter))]
pub enum _PickerAfter {
    Stay,
    PreviousTool,
    Pencil,
}

#[frb(mirror(Anchor))]
pub enum _Anchor {
    TopLeft,
    Top,
    TopRight,
    Left,
    Center,
    Right,
    BottomLeft,
    Bottom,
    BottomRight,
}

/// A failure of the core: its stable code (`no_selection`, `decode`...)
/// and its message. Dart turns it into a `Failure`.
#[derive(Debug, Clone)]
pub struct PaintError {
    pub code: String,
    pub message: String,
}

impl From<paintbox_core::Error> for PaintError {
    fn from(error: paintbox_core::Error) -> Self {
        Self {
            code: error.code().to_owned(),
            message: error.to_string(),
        }
    }
}

impl PaintError {
    pub(crate) fn invalid(message: impl Into<String>) -> Self {
        Self {
            code: "invalid_parameter".to_owned(),
            message: message.into(),
        }
    }
}

pub type PaintResult<T> = Result<T, PaintError>;

/// Pixels of a rectangle, premultiplied RGBA8 row by row: what
/// `ui.decodeImageFromPixels` takes as `rgba8888`.
pub struct PixelBlock {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
    pub pixels: Vec<u8>,
}

/// What a pointer gesture asks the shell to do with the tool.
pub struct GestureOutcome {
    /// The Color Picker's "after click" switch, or a paste riding on
    /// Move Selected Pixels.
    pub switch_to: Option<Tool>,
    pub previous_tool: bool,
}

/// Handles and guides to draw over the picture, in its pixels.
pub struct OverlayInfo {
    pub handles: Vec<PointF>,
    pub guide: Vec<PointF>,
}

/// The cheap facts the screen compares after every call, to read the
/// dearer ones (layers, history, the outline) only when they moved.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ImageStamp {
    pub revision: u64,
    pub width: u32,
    pub height: u32,
    pub history_position: u32,
    pub history_length: u32,
    pub can_undo: bool,
    pub can_redo: bool,
    pub selection_stamp: u64,
    pub has_selection: bool,
    pub selection_bounds: Rect,
    pub active_layer: u32,
    pub layer_count: u32,
    pub is_editing: bool,
    pub is_pressed: bool,
    pub is_modified: bool,
    pub has_preview: bool,
    /// The Text tool has a caret: keys type into it.
    pub is_typing: bool,
}

/// What moved since the screen last asked: the area to draw again and
/// which panels to read again.
pub struct ImageChanges {
    pub stamp: ImageStamp,
    pub dirty: Option<Rect>,
    /// The canvas changed size, or everything is reported: draw it all.
    pub resized: bool,
    pub layers: bool,
    pub history: bool,
    pub selection: bool,
    /// Something commands depend on moved: ask `can_run` again.
    pub availability: bool,
}

pub struct ToolInfo {
    pub tool: Tool,
    pub name: String,
    /// The letter that selects it.
    pub key: String,
    pub hint: String,
    pub available: bool,
}

pub struct CommandInfo {
    /// Stable snake_case id: `undo`, `adjust:levels`, `effect:gaussian_blur`.
    pub id: String,
    pub label: String,
    /// The menu's shortcut text, `Ctrl+Shift+N`.
    pub shortcut: String,
}

pub struct EffectGroup {
    pub name: String,
    pub ids: Vec<String>,
}

pub struct FilterInfo {
    pub id: String,
    pub name: String,
    /// False for those applied at once (Invert Colors, Sepia...).
    pub dialog: bool,
}

pub enum ParamKind {
    Integer,
    Real,
    Flag,
    /// A random seed: no slider, a Reseed button.
    Seed,
}

/// One control of a previewing dialog: a number (or one per channel,
/// as Levels has), its range and its kind.
pub struct DialogParam {
    pub name: String,
    pub values: Vec<f64>,
    pub min: f64,
    pub max: f64,
    pub kind: ParamKind,
}

/// The open previewing dialog.
pub struct PreviewInfo {
    /// `layer_properties`, `adjust:levels`, `effect:gaussian_blur`.
    pub id: String,
    pub title: String,
    pub params: Vec<DialogParam>,
    /// Layer Properties' values.
    pub layer: Option<LayerProperties>,
    /// The Curves dialog's points.
    pub curves: Option<Curves>,
    pub rendering: bool,
    /// OK was pressed and the dialog waits for the last render.
    pub finishing: bool,
    /// Ctrl+F: no parameters, only the progress.
    pub repeat: bool,
}

pub struct PreviewPoll {
    pub open: bool,
    pub changed: bool,
    pub rendering: bool,
}

/// A flat or layered file format by its extension.
pub struct FileKind {
    pub extension: String,
    pub layered: bool,
    /// JPEG: the save dialog asks for a quality.
    pub lossy: bool,
}

#[frb(mirror(CurveMode))]
pub enum _CurveMode {
    Luminosity,
    Rgb,
}

#[frb(mirror(Curves))]
pub struct _Curves {
    pub mode: CurveMode,
    pub luminosity: Vec<(u8, u8)>,
    pub red: Vec<(u8, u8)>,
    pub green: Vec<(u8, u8)>,
    pub blue: Vec<(u8, u8)>,
}
