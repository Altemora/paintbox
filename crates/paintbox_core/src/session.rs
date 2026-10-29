//! One open image as a shell holds it: the document with its gesture
//! controller, the previewing dialog, the button held on the picture and
//! the state last saved. A shell (the Flutter program, or any other front
//! end) keeps a [`Session`] and only translates its types to its calls,
//! so a press during a dialog, the other button of a drag, Enter with
//! nothing live and the like behave the same in every shell.
//!
//! The active tool and the tool bar's settings belong to the shell (the
//! program has one for all its images), so they come with the calls
//! that need them. What several images share — the effect Ctrl+F
//! repeats, the clipboard — is the shell's too: calls take it and say
//! what to remember ([`Session::take_applied_effect`]).

use crate::adjust::{Adjustment, Curves};
use crate::clipboard::Clip;
use crate::command::{Command, EffectKind};
use crate::document::{Button, Document, UserColors};
use crate::effects::Effect;
use crate::error::{invalid, Error, Result};
use crate::geom::{PointF, Rect};
use crate::gesture::{Controller, Mods, Outcome, Overlay, Pointer};
use crate::image_ops::{Anchor, Resampling};
use crate::layer::LayerProperties;
use crate::params::{params_of, with_param, Param};
use crate::preview::{Ended, Preview, Wake};
use crate::surface::Surface;
use crate::tool::{Tool, ToolSettings};
use crate::typing::TextKey;

/// A dialog that previews on the image.
#[derive(Debug, Clone, PartialEq)]
pub enum Dialog {
    LayerProperties,
    Adjust(Adjustment),
    Effect(Effect),
}

impl Dialog {
    /// The dialog a command id opens (`layer_properties`, `adjust:levels`,
    /// `effect:gaussian_blur`) with its default values; an effect opens
    /// with the values it was last applied with, as Paint.NET's dialogs
    /// do.
    pub fn for_id(id: &str, last_effect: Option<&Effect>) -> Option<Dialog> {
        if id == "layer_properties" {
            return Some(Dialog::LayerProperties);
        }
        match Command::from_id(id)? {
            Command::Adjust(kind) => Some(Dialog::Adjust(kind.default_adjustment())),
            Command::Effect(kind) => Some(Dialog::Effect(
                last_effect
                    .filter(|e| EffectKind::of(e) == kind)
                    .copied()
                    .unwrap_or_else(|| kind.default_effect()),
            )),
            _ => None,
        }
    }
}

/// The open dialog as its controls show it.
#[derive(Debug, Clone, PartialEq)]
pub struct DialogInfo {
    /// `layer_properties`, `adjust:levels`, `effect:gaussian_blur`.
    pub id: String,
    pub title: &'static str,
    pub params: Vec<Param>,
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

/// What one [`Session::poll_dialog`] found.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct DialogPoll {
    pub open: bool,
    /// The image changed: draw it again.
    pub changed: bool,
    pub rendering: bool,
}

/// The cheap facts a shell compares after every call, to read the dearer
/// ones (layers, history, the outline) only when they moved.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Stamp {
    pub revision: u64,
    pub width: u32,
    pub height: u32,
    pub history_position: usize,
    pub history_length: usize,
    pub can_undo: bool,
    pub can_redo: bool,
    pub selection_stamp: u64,
    pub has_selection: bool,
    /// The selected pixels' bounds; empty with nothing selected.
    pub selection_bounds: Rect,
    pub active_layer: usize,
    pub layer_count: usize,
    pub is_editing: bool,
    pub is_pressed: bool,
    pub is_modified: bool,
    pub has_dialog: bool,
    /// The Text tool has a caret: keys go to [`Session::type_text`] and
    /// [`Session::text_key`].
    pub is_typing: bool,
    /// Changes with every step made, undone or redone, and with steps
    /// dropped under the history's memory limit: the History list can
    /// change while its length and position stay.
    pub state_id: u64,
    pub evicted: usize,
}

/// What moved since the shell last asked ([`Session::take_changes`]).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Changes {
    pub stamp: Stamp,
    /// Pixels to draw again; the whole canvas after a resize or a reset.
    pub dirty: Option<Rect>,
    /// The canvas changed size (or nothing was seen before): draw it all.
    pub resized: bool,
    pub layers: bool,
    pub history: bool,
    pub selection: bool,
    /// Something commands depend on moved (the selection, layers,
    /// history, an open edit or dialog): ask [`Session::can_run`] again.
    pub availability: bool,
}

pub struct Session {
    doc: Document,
    controller: Controller,
    dialog: Option<Preview>,
    /// The button held since the last press: the picker samples while
    /// held, the other button moves a shape.
    held: Option<Button>,
    /// `state_id` when opened or last saved.
    saved: u64,
    /// The effect a dialog applied since the shell last asked.
    applied: Option<Effect>,
    seen: Option<Stamp>,
}

impl Session {
    pub fn new(doc: Document) -> Self {
        let saved = doc.state_id();
        Self {
            doc,
            controller: Controller::default(),
            dialog: None,
            held: None,
            saved,
            applied: None,
            seen: None,
        }
    }

    pub fn document(&self) -> &Document {
        &self.doc
    }

    /// The document for calls the session does not wrap (reads, steps
    /// a shell adds of its own). A change made here that the
    /// controller should see needs [`Session::sync`].
    pub fn document_mut(&mut self) -> &mut Document {
        &mut self.doc
    }

    /// Takes a new document in place of this one (a restarted history):
    /// the dialog is cancelled, live gestures dropped, the new state is
    /// the saved one.
    pub fn replace_document(&mut self, doc: Document) {
        self.cancel_dialog();
        self.doc = doc;
        self.controller = Controller::default();
        self.held = None;
        self.saved = self.doc.state_id();
        self.seen = None;
    }

    /// Tells the controller the document changed under it.
    pub fn sync(&mut self) {
        self.controller.sync(&self.doc);
    }

    // ---- state -------------------------------------------------------------

    pub fn stamp(&self) -> Stamp {
        let selection = self.doc.selection();
        let has_dialog = self.dialog.is_some();
        Stamp {
            revision: self.doc.revision(),
            width: self.doc.width(),
            height: self.doc.height(),
            history_position: self.doc.history_position(),
            history_length: self.doc.history_names().len(),
            can_undo: self.doc.can_undo() && !has_dialog,
            can_redo: self.doc.can_redo() && !has_dialog,
            selection_stamp: selection.stamp(),
            has_selection: selection.is_active(),
            selection_bounds: if selection.is_active() {
                selection.bounds()
            } else {
                Rect::default()
            },
            active_layer: self.doc.active_layer_index(),
            layer_count: self.doc.layers().len(),
            is_editing: self.doc.is_editing(),
            is_pressed: self.held.is_some(),
            is_modified: self.is_modified(),
            has_dialog,
            is_typing: self.controller.is_typing(),
            state_id: self.doc.state_id(),
            evicted: self.doc.history_evicted(),
        }
    }

    /// What moved since the last call: the dirty area and which panels
    /// to read again.
    pub fn take_changes(&mut self) -> Changes {
        let stamp = self.stamp();
        let dirty = self.doc.take_dirty();
        let old = self.seen.replace(stamp);
        let Some(old) = old else {
            return Changes {
                stamp,
                dirty: Some(self.doc.bounds()),
                resized: true,
                layers: true,
                history: true,
                selection: true,
                availability: true,
            };
        };
        let resized = old.width != stamp.width || old.height != stamp.height;
        let history = old.history_length != stamp.history_length
            || old.history_position != stamp.history_position
            || old.state_id != stamp.state_id
            || old.evicted != stamp.evicted;
        let layers = old.revision != stamp.revision || old.layer_count != stamp.layer_count;
        let selection = old.selection_stamp != stamp.selection_stamp;
        let availability = history
            || old.has_selection != stamp.has_selection
            || old.can_undo != stamp.can_undo
            || old.can_redo != stamp.can_redo
            || old.layer_count != stamp.layer_count
            || old.active_layer != stamp.active_layer
            || old.is_editing != stamp.is_editing
            || old.has_dialog != stamp.has_dialog
            || old.is_typing != stamp.is_typing;
        Changes {
            stamp,
            dirty: if resized {
                Some(self.doc.bounds())
            } else {
                dirty
            },
            resized,
            layers,
            history,
            selection,
            availability,
        }
    }

    /// The next [`Session::take_changes`] reports everything, as after
    /// opening (a tab shown again).
    pub fn forget_seen(&mut self) {
        self.seen = None;
    }

    pub fn is_modified(&self) -> bool {
        self.doc.is_modified_since(self.saved)
    }

    pub fn state_id(&self) -> u64 {
        self.doc.state_id()
    }

    /// The image as it is now counts as saved.
    pub fn mark_saved(&mut self) {
        self.saved = self.doc.state_id();
    }

    /// The state a save began in counts as saved (taken with
    /// [`Session::state_id`]; drawing went on while it was written).
    pub fn mark_saved_at(&mut self, state_id: u64) {
        self.saved = state_id;
    }

    pub fn is_pressed(&self) -> bool {
        self.held.is_some()
    }

    pub fn has_dialog(&self) -> bool {
        self.dialog.is_some()
    }

    // ---- gestures ----------------------------------------------------------

    /// A button pressed over the picture. A dialog holds the picture; the
    /// other button during a drag moves the whole shape.
    pub fn press(
        &mut self,
        tool: Tool,
        settings: &ToolSettings,
        pointer: Pointer,
    ) -> Result<Outcome> {
        if self.dialog.is_some() {
            return Ok(Outcome::Nothing);
        }
        if let Some(held) = self.held {
            if held != pointer.button {
                self.controller.other_button(true, pointer.pos);
                return Ok(Outcome::Nothing);
            }
        }
        self.held = Some(pointer.button);
        let outcome = self
            .controller
            .press(&mut self.doc, tool, settings, pointer)?;
        self.controller.flush(&mut self.doc, settings)?;
        Ok(outcome)
    }

    /// The pointer moved, with a button held or hovering.
    pub fn move_to(&mut self, settings: &ToolSettings, at: PointF) -> Result<()> {
        if self.dialog.is_some() {
            return Ok(());
        }
        self.controller.motion(&mut self.doc, at)?;
        if let Some(held) = self.held {
            self.controller.picker_motion(&mut self.doc, at, held);
        }
        self.controller.flush(&mut self.doc, settings)
    }

    pub fn release(&mut self, settings: &ToolSettings, pointer: Pointer) -> Result<Outcome> {
        if self.dialog.is_some() {
            return Ok(Outcome::Nothing);
        }
        match self.held {
            None => return Ok(Outcome::Nothing),
            Some(held) if held != pointer.button => {
                self.controller.other_button(false, pointer.pos);
                return Ok(Outcome::Nothing);
            }
            Some(_) => {}
        }
        self.held = None;
        let outcome = self.controller.release(&mut self.doc, settings, pointer)?;
        self.controller.flush(&mut self.doc, settings)?;
        Ok(outcome)
    }

    /// Modifiers changed mid-drag: squares, circles and 15° steps follow
    /// at once.
    pub fn set_modifiers(&mut self, settings: &ToolSettings, mods: Mods) -> Result<()> {
        if self.dialog.is_some() {
            return Ok(());
        }
        self.controller.modifiers(mods);
        self.controller.flush(&mut self.doc, settings)
    }

    /// Redraws what is live (a gradient, a shape) with new settings.
    pub fn flush(&mut self, settings: &ToolSettings) -> Result<()> {
        self.controller.flush(&mut self.doc, settings)
    }

    /// Enter: finishes a live gradient or curve, else ends any move and
    /// deselects. False when there was nothing to do.
    pub fn enter(&mut self) -> Result<bool> {
        if self.dialog.is_some() || self.held.is_some() {
            return Ok(false);
        }
        let done = self.controller.enter(&mut self.doc)?;
        self.or_deselect(done)
    }

    /// Esc: cancels a live gradient or curve, else ends any move and
    /// deselects.
    pub fn escape(&mut self) -> Result<bool> {
        if self.dialog.is_some() || self.held.is_some() {
            return Ok(false);
        }
        let done = self.controller.escape(&mut self.doc)?;
        self.or_deselect(done)
    }

    /// The arrow keys in the move tools: by `(dx, dy)` pixels.
    pub fn nudge(&mut self, tool: Tool, dx: i32, dy: i32) -> Result<bool> {
        if self.dialog.is_some() || self.held.is_some() {
            return Ok(false);
        }
        quiet(
            self.controller
                .nudge(&mut self.doc, tool, dx, dy)
                .map(|()| true),
        )
    }

    /// Text typed at the caret (a character, or a pasted string).
    pub fn type_text(&mut self, settings: &ToolSettings, text: &str) -> Result<bool> {
        if self.dialog.is_some() {
            return Ok(false);
        }
        self.controller.type_text(&mut self.doc, settings, text)
    }

    /// A key of the text being typed (Enter, Backspace, arrows...).
    pub fn text_key(&mut self, settings: &ToolSettings, key: TextKey, ctrl: bool) -> Result<bool> {
        if self.dialog.is_some() {
            return Ok(false);
        }
        self.controller.text_key(&mut self.doc, settings, key, ctrl)
    }

    /// Whatever is live (a gradient, a curve, lifted pixels) becomes a
    /// step: before a tool change, a command, a save.
    pub fn finish(&mut self) -> Result<()> {
        self.held = None;
        self.controller.finish(&mut self.doc)
    }

    /// Handles and guides over the picture: the live gesture's, or the
    /// lifted pixels' eight handles (drag one to scale, the right button
    /// turns).
    pub fn overlay(&self) -> Overlay {
        let overlay = self.controller.overlay();
        if overlay.handles.is_empty() && self.doc.is_lifted() {
            return Overlay {
                handles: self.doc.lift_handles(),
                guide: Vec::new(),
            };
        }
        overlay
    }

    /// How near a handle a press must be, in pixels of the picture (the
    /// shell keeps it a few screen pixels at any zoom).
    pub fn set_handle_radius(&mut self, radius: f32) {
        if radius.is_finite() && radius > 0.0 {
            self.controller.handle_radius = radius;
        }
    }

    /// The move in progress, by which the outline is drawn shifted.
    pub fn move_offset(&self) -> Option<(i32, i32)> {
        self.controller.move_offset(&self.doc)
    }

    /// The marching ants: edges between pixels as `x0, y0, x1, y1`
    /// quadruples, each horizontal or vertical; none without a selection.
    pub fn selection_outline(&self) -> Vec<i32> {
        if !self.doc.selection().is_active() {
            return Vec::new();
        }
        self.doc
            .selection()
            .outline()
            .iter()
            .flat_map(|&(x0, y0, x1, y1)| [x0, y0, x1, y1])
            .collect()
    }

    // ---- colours and layers ------------------------------------------------

    /// New colours; a live gradient or shape redraws with them.
    pub fn set_colors(&mut self, colors: UserColors, settings: &ToolSettings) -> Result<()> {
        self.doc.set_colors(colors);
        self.controller.flush(&mut self.doc, settings)
    }

    pub fn set_active_layer(&mut self, index: usize) -> Result<bool> {
        self.unless_dialog(|s| s.doc.set_active_layer(index))
    }

    /// A layer dragged to another place in the Layers window: one step.
    pub fn move_layer_to(&mut self, from: usize, to: usize) -> Result<bool> {
        self.unless_dialog(|s| s.doc.move_layer_to(from, to).map(drop))
    }

    /// Layer Properties and the visibility box: one step.
    pub fn set_layer_properties(&mut self, index: usize, props: LayerProperties) -> Result<bool> {
        self.unless_dialog(|s| s.doc.set_layer_properties(index, props))
    }

    /// Layers > Import From File: the picture as a new layer named `name`.
    pub fn import_layer(&mut self, name: &str, picture: &Surface) -> Result<bool> {
        self.unless_dialog(|s| s.doc.import_layer(name, picture).map(drop))
    }

    pub fn resize_image(&mut self, width: u32, height: u32, method: Resampling) -> Result<bool> {
        self.unless_dialog(|s| s.doc.resize_image(width, height, method))
    }

    pub fn resize_canvas(&mut self, width: u32, height: u32, anchor: Anchor) -> Result<bool> {
        self.unless_dialog(|s| s.doc.resize_canvas(width, height, anchor))
    }

    /// Walks the history to an entry, as clicking it in History does.
    pub fn jump_to(&mut self, position: usize) -> Result<bool> {
        self.unless_dialog(|s| s.doc.jump_to(position))
    }

    // ---- commands ----------------------------------------------------------

    /// Whether a command of the image has something to act on now.
    /// Commands of the program (files, the view, windows) answer as the
    /// document does; Paste depends on the clipboard the shell holds and
    /// Repeat on `last_effect`.
    pub fn can_run(&self, command: Command, last_effect: Option<&Effect>) -> bool {
        if self.dialog.is_some() {
            return false;
        }
        match command {
            Command::RepeatEffect => last_effect.is_some(),
            Command::Adjust(_) | Command::Effect(_) | Command::LayerProperties => true,
            other => self.doc.can_run(other),
        }
    }

    /// Runs a command of the image (Undo, Select All, Add New Layer...);
    /// false when it had nothing to act on. A live gesture becomes a
    /// step first; Undo and Redo step over it.
    pub fn run(&mut self, command: Command) -> Result<bool> {
        if !command.is_document_command() {
            return Err(invalid(format!("no image command {}", command.id())));
        }
        if !self.can_run(command, None) {
            return Ok(false);
        }
        if !matches!(command, Command::Undo | Command::Redo) {
            self.finish()?;
        }
        let result = quiet(self.doc.run(command));
        self.sync();
        result
    }

    /// Copy: the active layer inside the selection; none without one.
    pub fn copy(&mut self) -> Result<Option<Clip>> {
        if self.dialog.is_some() || !self.doc.selection().is_active() {
            return Ok(None);
        }
        self.finish()?;
        clip_or_none(self.doc.copy())
    }

    pub fn cut(&mut self) -> Result<Option<Clip>> {
        if self.dialog.is_some() || !self.doc.selection().is_active() {
            return Ok(None);
        }
        self.finish()?;
        let clip = clip_or_none(self.doc.cut());
        self.sync();
        clip
    }

    /// Paste (or Paste into New Layer): the clip becomes lifted pixels of
    /// Move Selected Pixels, which the outcome switches to.
    pub fn paste(&mut self, clip: &Clip, new_layer: bool) -> Result<Outcome> {
        if self.dialog.is_some() {
            return Ok(Outcome::Nothing);
        }
        self.finish()?;
        if new_layer {
            self.doc.paste_into_new_layer(clip)?;
        } else {
            self.doc.paste(clip)?;
        }
        self.sync();
        Ok(Outcome::SwitchTool(Tool::MoveSelectedPixels))
    }

    /// An adjustment or effect at once, with no dialog (a script's call,
    /// Ctrl+F where the shell renders on its own thread).
    pub fn apply_effect(&mut self, effect: &Effect) -> Result<bool> {
        let applied = self.unless_dialog(|s| s.doc.apply_effect(effect))?;
        if applied {
            self.applied = Some(*effect);
        }
        Ok(applied)
    }

    pub fn apply_adjustment(&mut self, adjustment: &Adjustment) -> Result<bool> {
        self.unless_dialog(|s| s.doc.apply_adjustment(adjustment))
    }

    // ---- previewing dialogs ------------------------------------------------

    /// Opens a dialog that previews on the image. An adjustment applied
    /// at once (Invert Colors...) is applied and no dialog opens: then
    /// false. `wake` is called from the worker when an effect's render is
    /// in.
    pub fn open_dialog(&mut self, dialog: Dialog, wake: Wake) -> Result<bool> {
        if self.dialog.is_some() {
            return Err(invalid("a preview dialog is already open"));
        }
        self.finish()?;
        let preview = match dialog {
            Dialog::LayerProperties => {
                Preview::layer_properties(&self.doc, self.doc.active_layer_index())?
            }
            Dialog::Adjust(adjustment) if adjustment.is_immediate() => {
                let applied = self.doc.apply_adjustment(&adjustment);
                self.sync();
                return applied.map(|()| false);
            }
            Dialog::Adjust(adjustment) => Preview::adjust(&mut self.doc, adjustment)?,
            Dialog::Effect(effect) => Preview::effect(&mut self.doc, effect, false, wake)?,
        };
        self.dialog = Some(preview);
        self.poll().map(|_| true)
    }

    /// Ctrl+F: `effect` again, rendered on a worker; the dialog shows only
    /// the progress and ends by itself.
    pub fn repeat_effect(&mut self, effect: Effect, wake: Wake) -> Result<bool> {
        if self.dialog.is_some() {
            return Ok(false);
        }
        self.finish()?;
        self.dialog = Some(Preview::effect(&mut self.doc, effect, true, wake)?);
        self.poll().map(|_| true)
    }

    pub fn dialog(&self) -> Option<&Preview> {
        self.dialog.as_ref()
    }

    pub fn dialog_info(&self) -> Option<DialogInfo> {
        let preview = self.dialog.as_ref()?;
        let mut info = DialogInfo {
            id: String::new(),
            title: preview.title(),
            params: Vec::new(),
            layer: None,
            curves: None,
            rendering: preview.is_rendering(),
            finishing: false,
            repeat: false,
        };
        match preview {
            Preview::LayerProperties { props, .. } => {
                info.id = "layer_properties".to_owned();
                info.layer = Some(props.clone());
            }
            Preview::Adjust { adjustment, .. } => {
                info.id = adjustment.id();
                info.params = params_of(adjustment, adjustment.ranges());
                if let Adjustment::Curves(c) = adjustment {
                    info.curves = Some(c.clone());
                }
            }
            Preview::Effect(e) => {
                info.id = Command::Effect(EffectKind::of(&e.effect)).id();
                info.params = params_of(&e.effect, e.effect.ranges());
                info.finishing = e.finishing;
                info.repeat = e.repeat;
            }
        }
        Some(info)
    }

    /// Changes one parameter of the open dialog and previews it. Values
    /// the adjustment refuses (Levels with low above high) are put back
    /// and reported; the dialog stays.
    pub fn set_dialog_param(&mut self, name: &str, values: &[f64]) -> Result<()> {
        self.edit_dialog(|preview| match preview {
            Preview::LayerProperties { .. } => {
                Err(invalid("layer properties take set_dialog_layer"))
            }
            Preview::Adjust { adjustment, .. } => {
                *adjustment = with_param(&*adjustment, name, values)?;
                Ok(())
            }
            Preview::Effect(e) => {
                e.effect = with_param(&e.effect, name, values)?;
                Ok(())
            }
        })
    }

    /// The Curves dialog's points.
    pub fn set_dialog_curves(&mut self, curves: Curves) -> Result<()> {
        self.edit_dialog(|preview| match preview {
            Preview::Adjust {
                adjustment: adjustment @ Adjustment::Curves(_),
                ..
            } => {
                *adjustment = Adjustment::Curves(curves);
                Ok(())
            }
            _ => Err(invalid("no curves dialog is open")),
        })
    }

    /// Layer Properties' values while its dialog is open.
    pub fn set_dialog_layer(&mut self, props: LayerProperties) -> Result<()> {
        self.edit_dialog(|preview| match preview {
            Preview::LayerProperties { props: p, .. } => {
                *p = props;
                Ok(())
            }
            _ => Err(invalid("no layer properties dialog is open")),
        })
    }

    /// Changes the open dialog with `edit` and previews it. A change the
    /// adjustment refuses is put back and reported, the dialog stays;
    /// any other failure of the preview cancels the dialog.
    pub fn edit_dialog(&mut self, edit: impl FnOnce(&mut Preview) -> Result<()>) -> Result<()> {
        let Some(preview) = self.dialog.as_mut() else {
            return Err(invalid("no preview dialog is open"));
        };
        let old = match preview {
            Preview::Adjust { adjustment, .. } => Some(adjustment.clone()),
            _ => None,
        };
        edit(preview)?;
        let updated = preview.update(&mut self.doc);
        match updated {
            Err(Error::InvalidParameter(message)) if old.is_some() => {
                if let (Some(Preview::Adjust { adjustment, .. }), Some(old)) =
                    (self.dialog.as_mut(), old)
                {
                    *adjustment = old;
                }
                self.poll()?;
                Err(Error::InvalidParameter(message))
            }
            Err(e) => Err(self.cancel_on(e)),
            Ok(progress) => {
                if progress.finished {
                    self.end_finished()?;
                }
                Ok(())
            }
        }
    }

    /// Brings the image up to date with the dialog (an effect's render
    /// that arrived); an effect whose OK waited ends here. A failure
    /// cancels the dialog.
    pub fn poll_dialog(&mut self) -> Result<DialogPoll> {
        let changed = self.poll()?;
        Ok(DialogPoll {
            open: self.dialog.is_some(),
            changed,
            rendering: self.dialog.as_ref().is_some_and(Preview::is_rendering),
        })
    }

    /// OK (`ok` true) or Cancel. OK while an effect still renders keeps
    /// the dialog open until the render is in: then false. No dialog
    /// open: true, nothing to end.
    pub fn end_dialog(&mut self, ok: bool) -> Result<bool> {
        let Some(mut preview) = self.dialog.take() else {
            return Ok(true);
        };
        if ok && !preview.press_ok() {
            self.dialog = Some(preview);
            return Ok(false);
        }
        let effect = match (ok, &preview) {
            (true, Preview::Effect(e)) => Some(e.effect),
            _ => None,
        };
        let ended = if ok { Ended::Ok } else { Ended::Cancel };
        let result = preview.end(&mut self.doc, ended);
        self.sync();
        result?;
        // Only an effect that landed is the one Ctrl+F repeats.
        if effect.is_some() {
            self.applied = effect;
        }
        Ok(true)
    }

    /// Cancels the open dialog, if any; its pixels go back.
    pub fn cancel_dialog(&mut self) {
        if let Some(preview) = self.dialog.take() {
            // Cancelling only restores originals; nothing to report.
            let _cancelled = preview.end(&mut self.doc, Ended::Cancel);
            self.sync();
        }
    }

    /// The effect a dialog (or [`Session::apply_effect`]) applied since
    /// the last call: the shell remembers it for Ctrl+F.
    pub fn take_applied_effect(&mut self) -> Option<Effect> {
        self.applied.take()
    }
}

impl Session {
    fn unless_dialog(&mut self, change: impl FnOnce(&mut Self) -> Result<()>) -> Result<bool> {
        if self.dialog.is_some() {
            return Ok(false);
        }
        self.finish()?;
        let result = change(self);
        self.sync();
        result.map(|()| true)
    }

    fn or_deselect(&mut self, done: bool) -> Result<bool> {
        if done {
            return Ok(true);
        }
        if self.doc.selection().is_active() {
            self.doc.deselect()?;
            return Ok(true);
        }
        Ok(false)
    }

    /// A failed update cancels the dialog: its pixels go back and the
    /// update's failure is the one to tell.
    fn cancel_on(&mut self, error: Error) -> Error {
        self.cancel_dialog();
        error
    }

    /// Updates the open dialog; true when the image changed.
    fn poll(&mut self) -> Result<bool> {
        let Some(preview) = self.dialog.as_mut() else {
            return Ok(false);
        };
        match preview.update(&mut self.doc) {
            Ok(progress) => {
                if progress.finished {
                    self.end_finished()?;
                }
                Ok(progress.changed || progress.finished)
            }
            Err(e) => Err(self.cancel_on(e)),
        }
    }

    fn end_finished(&mut self) -> Result<()> {
        if let Some(preview) = self.dialog.take() {
            if let Preview::Effect(e) = &preview {
                self.applied = Some(e.effect);
            }
            preview.end(&mut self.doc, Ended::Ok)?;
            self.sync();
        }
        Ok(())
    }
}

/// Paint.NET's commands with nothing to act on simply do nothing.
fn quiet(result: Result<bool>) -> Result<bool> {
    match result {
        Err(Error::NoSelection | Error::NothingLifted | Error::NoEdit) => Ok(false),
        other => other,
    }
}

fn clip_or_none(clip: Result<Clip>) -> Result<Option<Clip>> {
    match clip {
        Ok(clip) => Ok(Some(clip)),
        Err(Error::NoSelection) => Ok(None),
        Err(e) => Err(e),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::color::Rgba8;
    use std::sync::Arc;

    fn session() -> Session {
        Session::new(Document::new(64, 48, Rgba8::opaque(100, 120, 140)).unwrap())
    }

    fn at(x: f32, y: f32, button: Button) -> Pointer {
        Pointer {
            pos: PointF::new(x, y),
            button,
            mods: Mods::default(),
            time: 0.0,
        }
    }

    fn no_wake() -> Wake {
        Arc::new(|| {})
    }

    fn render(s: &mut Session) {
        for _ in 0..2000 {
            if !s.poll_dialog().unwrap().rendering {
                return;
            }
            std::thread::sleep(std::time::Duration::from_millis(1));
        }
        panic!("the render never came in");
    }

    #[test]
    fn a_stroke_is_one_step_and_marks_the_image_modified() {
        let mut s = session();
        let settings = ToolSettings::default();
        let first = s.take_changes();
        assert!(first.resized && first.layers && first.history);
        assert_eq!(first.dirty, Some(Rect::new(0, 0, 64, 48)));
        assert!(!s.is_modified());
        s.press(Tool::Paintbrush, &settings, at(5.0, 5.0, Button::Primary))
            .unwrap();
        assert!(s.is_pressed());
        s.move_to(&settings, PointF::new(30.0, 20.0)).unwrap();
        let moving = s.take_changes();
        assert!(moving.dirty.is_some() && !moving.resized);
        s.release(&settings, at(30.0, 20.0, Button::Primary))
            .unwrap();
        assert!(!s.is_pressed());
        let done = s.take_changes();
        assert!(done.history && done.availability);
        assert_eq!(done.stamp.history_length, 2);
        assert!(s.is_modified());
        s.mark_saved();
        assert!(!s.is_modified());
        let quiet = s.take_changes();
        assert!(!quiet.history && !quiet.layers && quiet.dirty.is_none());
    }

    #[test]
    fn the_other_button_does_not_end_the_drag() {
        let mut s = session();
        let settings = ToolSettings::default();
        s.press(Tool::Rectangle, &settings, at(5.0, 5.0, Button::Primary))
            .unwrap();
        s.move_to(&settings, PointF::new(20.0, 20.0)).unwrap();
        s.press(
            Tool::Rectangle,
            &settings,
            at(20.0, 20.0, Button::Secondary),
        )
        .unwrap();
        s.release(&settings, at(25.0, 25.0, Button::Secondary))
            .unwrap();
        assert!(s.is_pressed());
        s.release(&settings, at(25.0, 25.0, Button::Primary))
            .unwrap();
        assert!(!s.is_pressed());
        // A release with nothing held does nothing.
        assert_eq!(
            s.release(&settings, at(1.0, 1.0, Button::Primary)).unwrap(),
            Outcome::Nothing
        );
    }

    #[test]
    fn history_that_keeps_its_length_still_reports_a_change() {
        let mut s = session();
        s.run(Command::SelectAll).unwrap();
        let _ = s.take_changes();
        // Undo, then a new step: the same length and position.
        s.run(Command::Undo).unwrap();
        s.run(Command::InvertSelection).ok();
        s.run(Command::SelectAll).unwrap();
        let c = s.take_changes();
        assert!(c.history);
        let names = s.document().history_names();
        assert_eq!(names.len(), 2);
    }

    #[test]
    fn enter_with_nothing_live_deselects() {
        let mut s = session();
        assert!(!s.enter().unwrap());
        s.run(Command::SelectAll).unwrap();
        assert!(s.stamp().has_selection);
        assert!(s.escape().unwrap());
        assert!(!s.stamp().has_selection);
    }

    #[test]
    fn a_dialog_holds_the_picture_and_commands() {
        let mut s = session();
        let settings = ToolSettings::default();
        let dialog = Dialog::for_id("adjust:brightness_contrast", None).unwrap();
        assert!(s.open_dialog(dialog, no_wake()).unwrap());
        assert!(s.has_dialog());
        assert!(!s.can_run(Command::Undo, None));
        assert!(!s.stamp().can_undo);
        assert_eq!(
            s.press(Tool::Paintbrush, &settings, at(5.0, 5.0, Button::Primary))
                .unwrap(),
            Outcome::Nothing
        );
        assert!(!s.is_pressed());
        let info = s.dialog_info().unwrap();
        assert_eq!(info.id, "adjust:brightness_contrast");
        assert_eq!(info.params.len(), 2);
        s.set_dialog_param("brightness", &[40.0]).unwrap();
        assert!(s.set_dialog_param("nope", &[1.0]).is_err());
        assert!(s.has_dialog());
        assert!(s.end_dialog(true).unwrap());
        assert_eq!(
            s.document().history_names().last().unwrap(),
            "Brightness / Contrast"
        );
        // An adjustment with no dialog is applied at once.
        let invert = Dialog::for_id("adjust:invert_colors", None).unwrap();
        assert!(!s.open_dialog(invert, no_wake()).unwrap());
        assert!(!s.has_dialog());
    }

    #[test]
    fn refused_values_are_put_back_and_the_dialog_stays() {
        let mut s = session();
        s.open_dialog(Dialog::for_id("adjust:levels", None).unwrap(), no_wake())
            .unwrap();
        assert!(s
            .set_dialog_param("input_low", &[250.0, 250.0, 250.0])
            .is_ok());
        let refused = s.set_dialog_param("input_high", &[10.0, 10.0, 10.0]);
        assert!(refused.is_err());
        assert!(s.has_dialog());
        let high = s.dialog_info().unwrap().params;
        let high = high.iter().find(|p| p.name == "input_high").unwrap();
        assert_eq!(high.values, [255.0, 255.0, 255.0]);
        s.end_dialog(false).unwrap();
        assert!(!s.is_modified());
    }

    #[test]
    fn an_effect_renders_on_a_worker_and_is_remembered() {
        let mut s = session();
        let settings = ToolSettings::default();
        s.press(Tool::Paintbrush, &settings, at(5.0, 5.0, Button::Primary))
            .unwrap();
        s.release(&settings, at(40.0, 30.0, Button::Primary))
            .unwrap();
        s.run(Command::SelectAll).unwrap();
        let blur = Dialog::for_id("effect:gaussian_blur", None).unwrap();
        s.open_dialog(blur, no_wake()).unwrap();
        s.set_dialog_param("radius", &[5.0]).unwrap();
        // OK before the render is in waits.
        let ended = s.end_dialog(true).unwrap();
        if !ended {
            assert!(s.dialog_info().unwrap().finishing);
            render(&mut s);
        }
        assert!(!s.has_dialog());
        let effect = s.take_applied_effect().unwrap();
        assert_eq!(effect, Effect::GaussianBlur { radius: 5 });
        assert!(s.take_applied_effect().is_none());
        // The dialog opens again with the last values.
        let again = Dialog::for_id("effect:gaussian_blur", Some(&effect)).unwrap();
        assert_eq!(again, Dialog::Effect(Effect::GaussianBlur { radius: 5 }));
        assert!(s.can_run(Command::RepeatEffect, Some(&effect)));
        assert!(s.repeat_effect(effect, no_wake()).unwrap());
        render(&mut s);
        assert!(!s.has_dialog());
        assert_eq!(s.document().history_names().len(), 5);
    }

    #[test]
    fn text_types_as_one_step_and_esc_keeps_it() {
        let mut s = session();
        let settings = ToolSettings {
            font_size: 14.0,
            ..ToolSettings::default()
        };
        s.press(Tool::Text, &settings, at(4.0, 4.0, Button::Primary))
            .unwrap();
        s.release(&settings, at(4.0, 4.0, Button::Primary)).unwrap();
        assert!(s.stamp().is_typing);
        assert!(!s.stamp().is_editing);
        assert_eq!(s.overlay().guide.len(), 2);
        assert!(s.type_text(&settings, "Hi").unwrap());
        assert!(s.text_key(&settings, TextKey::Enter, false).unwrap());
        s.type_text(&settings, "ok").unwrap();
        assert!(s.stamp().is_editing);
        let before = s.overlay().handles[0];
        s.press(Tool::Text, &settings, at(30.0, 30.0, Button::Secondary))
            .unwrap();
        s.move_to(&settings, PointF::new(35.0, 32.0)).unwrap();
        s.release(&settings, at(35.0, 32.0, Button::Secondary))
            .unwrap();
        let after = s.overlay().handles[0];
        assert!(
            (after.x - before.x - 5.0).abs() < 1.5,
            "{before:?} {after:?}"
        );
        assert!(s.escape().unwrap());
        assert!(!s.stamp().is_typing);
        assert_eq!(s.document().history_names().last().unwrap(), "Text");
        assert_eq!(s.document().history_names().len(), 2);
        // A click and nothing typed leaves no step.
        s.press(Tool::Text, &settings, at(10.0, 10.0, Button::Primary))
            .unwrap();
        s.finish().unwrap();
        assert_eq!(s.document().history_names().len(), 2);
    }

    #[test]
    fn lifted_pixels_turn_with_the_right_button_and_scale_by_a_handle() {
        let mut s = session();
        let settings = ToolSettings::default();
        s.press(
            Tool::RectangleSelect,
            &settings,
            at(10.0, 10.0, Button::Primary),
        )
        .unwrap();
        s.move_to(&settings, PointF::new(30.0, 20.0)).unwrap();
        // Longer than a quick click, which would deselect.
        let later = Pointer {
            time: 1.0,
            ..at(30.0, 20.0, Button::Primary)
        };
        s.release(&settings, later).unwrap();
        // A 20 × 10 box turned a quarter: 10 × 20 about the same centre.
        let mv = Tool::MoveSelectedPixels;
        s.press(mv, &settings, at(40.0, 15.0, Button::Secondary))
            .unwrap();
        s.move_to(&settings, PointF::new(20.0, 35.0)).unwrap();
        s.release(&settings, at(20.0, 35.0, Button::Secondary))
            .unwrap();
        let t = s.document().lift_transform().unwrap();
        assert!((t.turn - std::f32::consts::FRAC_PI_2).abs() < 1e-3, "{t:?}");
        let b = s.stamp().selection_bounds;
        assert_eq!((b.x, b.y, b.width, b.height), (15, 5, 10, 20));
        assert_eq!(s.overlay().handles.len(), 8);
        // The bottom-middle handle (index 5) is on the left after a quarter
        // turn: dragging it 10 further left doubles the height.
        let handle = s.overlay().handles[5];
        s.press(mv, &settings, at(handle.x, handle.y, Button::Primary))
            .unwrap();
        s.move_to(&settings, PointF::new(handle.x - 10.0, handle.y))
            .unwrap();
        s.release(&settings, at(handle.x - 10.0, handle.y, Button::Primary))
            .unwrap();
        let t = s.document().lift_transform().unwrap();
        assert!((t.scale.1 - 2.0).abs() < 0.05, "{t:?}");
        assert!((t.scale.0 - 1.0).abs() < 1e-3);
        let b = s.stamp().selection_bounds;
        assert_eq!((b.x, b.width), (5, 20), "{b:?}");
        let xs: Vec<f32> = s.overlay().handles.iter().map(|h| h.x).collect();
        let min = xs.iter().copied().fold(f32::MAX, f32::min);
        assert!((min - b.x as f32).abs() <= 1.0, "{xs:?} {b:?}");
        s.finish().unwrap();
        assert_eq!(
            s.document().history_names().last().unwrap(),
            "Move Selected Pixels"
        );
    }

    #[test]
    fn paste_rides_on_move_selected_pixels() {
        let mut s = session();
        assert!(s.copy().unwrap().is_none());
        s.run(Command::SelectAll).unwrap();
        let clip = s.copy().unwrap().unwrap();
        assert_eq!(
            s.paste(&clip, true).unwrap(),
            Outcome::SwitchTool(Tool::MoveSelectedPixels)
        );
        assert_eq!(s.document().layers().len(), 2);
        assert!(s.run(Command::Open).is_err());
    }

    #[test]
    fn a_replaced_document_is_saved_and_seen_afresh() {
        let mut s = session();
        s.run(Command::AddLayer).unwrap();
        let _ = s.take_changes();
        let fresh = s.document_mut().restarted("Open Image").unwrap();
        s.replace_document(fresh);
        assert!(!s.is_modified());
        assert!(s.take_changes().resized);
        assert_eq!(s.document().history_names().len(), 1);
    }
}
