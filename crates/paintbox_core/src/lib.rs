//! Paintbox core: the editing engine of a Paint.NET 3.x-style image
//! editor, with no UI toolkit, game or engine dependency. Behaviour and
//! the reasons behind it: `docs/behaviour.md`.
//!
//! # For a shell
//!
//! A shell (such as the Flutter program's bridge) holds a
//! [`Session`] per open image: the [`Document`] with its gesture
//! controller, the previewing dialog, the held button and the saved
//! state, so every shell behaves alike and only translates types. What it
//! wraps, a shell could also call on the document directly:
//!
//! - **Tools.** [`Controller`] turns presses, moves and releases of the
//!   active [`Tool`] with the tool bar's [`ToolSettings`] into the calls
//!   below, as Paint.NET's tools do; [`KeyCycle`] picks tools by letter.
//! - **Pointer gestures.** Strokes: [`Document::begin_stroke`],
//!   [`Document::stroke_to`], [`Document::end_stroke`]. Drags that redraw
//!   (gradient, shapes, adjustment previews): [`Document::begin_edit`],
//!   then the tool call on every move, then [`Document::commit_edit`] or
//!   [`Document::cancel_edit`]. Clicks (fill, magic wand, colour picker,
//!   selections) are single calls. Points are in image pixels, `(0.5,
//!   0.5)` the centre of the first pixel.
//! - **Commands.** [`Command`] names every menu item with its keys;
//!   [`Document::can_run`] and [`Document::run`] do those of the image.
//!   Menu items are methods (`add_layer`, `undo`,
//!   `crop_to_selection`, `apply_effect`, ...); each finished command is
//!   one history step, named for the History window.
//! - **Dialogs.** [`Preview`] keeps a previewing dialog's state (effects
//!   on a worker, cancellable). Layer Properties: [`Document::preview_layer_properties`]
//!   while open, [`Document::set_layer_properties`] on OK. Slow effects:
//!   render [`Effect::render`] on a worker from
//!   [`Document::effect_source`], then [`Document::apply_rendered`].
//! - **Drawing.** After changes, [`Session::take_changes`] (or
//!   [`Document::take_dirty`]) gives the area to re-upload and which
//!   panels moved; [`Document::composite_tiles`] cuts it into tiles,
//!   straight or premultiplied, and [`Document::composite_into_rgba8`]
//!   writes straight RGBA bytes into the shell's buffer.
//!   [`Document::revision`] grows on every change, for panels.
//! - **Failures.** Every fallible call returns [`Result`]; nothing
//!   panics across the API.
//!
//! Pixels are straight RGBA8, as in Paint.NET; the blend formulas are
//! the source's. The selection is a coverage mask; history keeps 64 × 64
//! tiles that changed.

pub mod adjust;
pub mod blend;
pub mod clipboard;
pub mod color;
pub mod command;
mod document;
pub mod effects;
pub mod error;
pub mod files;
pub mod geom;
pub mod gesture;
mod history;
pub mod image_ops;
pub mod layer;
pub mod mask;
pub mod palette;
mod parallel;
pub mod params;
pub mod preview;
pub mod raster;
pub mod select;
pub mod selection;
pub mod session;
pub mod stroke;
pub mod surface;
pub mod text;
pub mod tiles;
pub mod tool;
pub mod tools;
pub mod typing;

pub use adjust::{Adjustment, CurveMode, Curves, Levels};
pub use blend::BlendMode;
pub use clipboard::Clip;
pub use color::Rgba8;
pub use command::{AdjustmentKind, Command, EffectKind, Shortcut};
pub use document::{Button, Document, UserColors};
pub use effects::Effect;
pub use error::{Error, Result};
pub use files::FileFormat;
pub use geom::{PointF, Rect};
pub use gesture::{Controller, Mods, Outcome, Overlay, Pointer};
pub use history::DEFAULT_HISTORY_LIMIT;
pub use image_ops::{Anchor, Resampling};
pub use layer::{Layer, LayerProperties};
pub use mask::{CombineMode, Mask};
pub use palette::Palette;
pub use params::{Param, ParamKind};
pub use preview::{Ended, Preview, Progress, Wake};
pub use select::MagicWandSettings;
pub use selection::{Segment, Selection};
pub use session::{Changes, Dialog, DialogInfo, DialogPoll, Session, Stamp};
pub use stroke::{DashStyle, LineCap};
pub use surface::Surface;
pub use tiles::Tile;
pub use tool::{KeyCycle, PickerAfter, SelectDraw, TextAlign, Tool, ToolSettings};
pub use tools::{
    BrushSettings, CloneSource, Curve, FillSettings, FloodMode, GradientKind, GradientSettings,
    RecolorSettings, Shape, ShapeDraw, ShapeSettings, StrokeTool,
};
pub use typing::TextKey;
