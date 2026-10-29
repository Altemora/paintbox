//! An open image: the core's [`pb::Session`] (the document with its
//! gesture controller, a previewing dialog, the held button and the
//! saved state). The bridge only translates: the active tool and the
//! tool bar's settings belong to the program, so they come with every
//! call that needs them, and the effect Ctrl+F repeats is the program's.
//! Calls are synchronous: each is a few milliseconds of the core's work,
//! and the order of pointer events must hold.

use std::sync::{Arc, Mutex};

use flutter_rust_bridge::frb;
use paintbox_core as pb;

use crate::api::files::{ClipImage, ImageSnapshot, Picture};
use crate::api::types::{
    Anchor, Curves, DialogParam, GestureOutcome, ImageChanges, ImageStamp, LayerProperties,
    OverlayInfo, PaintError, PaintResult, ParamKind, PixelBlock, PreviewInfo, PreviewPoll, Rect,
    Resampling, Rgba8, TextKey, Tool, ToolSettings, UserColors,
};
use crate::frb_generated::StreamSink;

/// The effect Ctrl+F repeats: one for the program, as in Paint.NET.
static LAST_EFFECT: Mutex<Option<pb::Effect>> = Mutex::new(None);

/// Where effect workers say a render is in.
static WAKES: Mutex<Option<StreamSink<u32>>> = Mutex::new(None);

/// A tick every time an effect's render arrives on any image: the shell
/// then polls the open dialog instead of polling every frame.
pub fn preview_wakes(sink: StreamSink<u32>) {
    if let Ok(mut wakes) = WAKES.lock() {
        *wakes = Some(sink);
    }
}

fn wake() -> pb::Wake {
    Arc::new(|| {
        if let Ok(wakes) = WAKES.lock() {
            if let Some(sink) = wakes.as_ref() {
                // A closed stream only means the shell stopped listening.
                let _ = sink.add(0);
            }
        }
    })
}

/// How far a lifted fragment or the selection outline moved.
pub struct MoveOffset {
    pub dx: i32,
    pub dy: i32,
}

#[frb(opaque)]
pub struct PaintImage {
    session: pb::Session,
}

impl PaintImage {
    pub(crate) fn wrap(doc: pb::Document) -> Self {
        Self {
            session: pb::Session::new(doc),
        }
    }

    /// A new image filled with `background`, painting with `colors`.
    #[frb(sync)]
    pub fn blank(
        width: u32,
        height: u32,
        background: Rgba8,
        colors: UserColors,
    ) -> PaintResult<PaintImage> {
        let mut doc = pb::Document::new(width, height, background)?;
        doc.set_colors(colors);
        Ok(Self::wrap(doc))
    }

    /// Paste into New Image: an image the clip's size.
    #[frb(sync)]
    pub fn from_clip(clip: &ClipImage, colors: UserColors) -> PaintResult<PaintImage> {
        let mut doc = pb::Document::from_clip(&clip.clip)?;
        doc.set_colors(colors);
        Ok(Self::wrap(doc))
    }

    // ---- state ----------------------------------------------------------

    #[frb(sync)]
    pub fn stamp(&self) -> ImageStamp {
        stamp_of(self.session.stamp())
    }

    /// What moved since the last call: the area to draw again and which
    /// panels to read again. `reset` reports everything (a tab shown).
    #[frb(sync)]
    pub fn take_changes(&mut self, reset: bool) -> ImageChanges {
        if reset {
            self.session.forget_seen();
        }
        let c = self.session.take_changes();
        ImageChanges {
            stamp: stamp_of(c.stamp),
            dirty: c.dirty,
            resized: c.resized,
            layers: c.layers,
            history: c.history,
            selection: c.selection,
            availability: c.availability,
        }
    }

    /// The composited picture of every `tile`-sized tile touching `area`,
    /// premultiplied, in one pass.
    #[frb(sync)]
    pub fn composite_tiles(&self, area: Rect, tile: u32) -> Vec<PixelBlock> {
        self.session
            .document()
            .composite_tiles(area, tile.clamp(16, 4096), true)
            .into_iter()
            .map(|t| PixelBlock {
                x: t.rect.x,
                y: t.rect.y,
                width: t.rect.width,
                height: t.rect.height,
                pixels: t.pixels,
            })
            .collect()
    }

    /// The layers as they are, for writing on a worker.
    #[frb(sync)]
    pub fn snapshot(&self) -> PaintResult<ImageSnapshot> {
        let doc = self.session.document();
        let layers = doc.layers().to_vec();
        let doc = pb::Document::with_layers(doc.width(), doc.height(), layers, "Save")?;
        Ok(ImageSnapshot { doc })
    }

    /// The image as it is now counts as saved.
    #[frb(sync)]
    pub fn mark_saved(&mut self) {
        self.session.mark_saved();
    }

    /// Marks a state the image was saved in (taken with
    /// [`Self::state_id`] when the save began).
    #[frb(sync)]
    pub fn mark_saved_at(&mut self, state_id: u64) {
        self.session.mark_saved_at(state_id);
    }

    #[frb(sync)]
    pub fn state_id(&self) -> u64 {
        self.session.state_id()
    }

    // ---- gestures -------------------------------------------------------

    /// A button pressed over the picture at `(x, y)` in its pixels;
    /// `secondary` is the right button, `time` in seconds.
    #[frb(sync)]
    #[allow(clippy::too_many_arguments)]
    pub fn press(
        &mut self,
        tool: Tool,
        settings: ToolSettings,
        x: f32,
        y: f32,
        secondary: bool,
        ctrl: bool,
        alt: bool,
        shift: bool,
        time: f64,
    ) -> PaintResult<GestureOutcome> {
        let pointer = pointer(x, y, secondary, ctrl, alt, shift, time);
        Ok(outcome_of(self.session.press(tool, &settings, pointer)?))
    }

    /// The pointer moved (with a button held, or hovering).
    #[frb(sync)]
    pub fn move_to(&mut self, settings: ToolSettings, x: f32, y: f32) -> PaintResult<()> {
        Ok(self.session.move_to(&settings, pb::PointF::new(x, y))?)
    }

    #[frb(sync)]
    #[allow(clippy::too_many_arguments)]
    pub fn release(
        &mut self,
        settings: ToolSettings,
        x: f32,
        y: f32,
        secondary: bool,
        ctrl: bool,
        alt: bool,
        shift: bool,
        time: f64,
    ) -> PaintResult<GestureOutcome> {
        let pointer = pointer(x, y, secondary, ctrl, alt, shift, time);
        Ok(outcome_of(self.session.release(&settings, pointer)?))
    }

    /// Modifiers changed mid-drag: squares, circles and 15° steps follow
    /// at once.
    #[frb(sync)]
    pub fn set_modifiers(
        &mut self,
        settings: ToolSettings,
        ctrl: bool,
        alt: bool,
        shift: bool,
    ) -> PaintResult<()> {
        let mods = pb::Mods { ctrl, alt, shift };
        Ok(self.session.set_modifiers(&settings, mods)?)
    }

    /// Redraws what is live (a gradient, a shape) with new settings or
    /// colours.
    #[frb(sync)]
    pub fn flush(&mut self, settings: ToolSettings) -> PaintResult<()> {
        Ok(self.session.flush(&settings)?)
    }

    /// Enter: finishes a live gradient or curve, else ends any move and
    /// deselects. False when there was nothing to do.
    #[frb(sync)]
    pub fn enter(&mut self) -> PaintResult<bool> {
        Ok(self.session.enter()?)
    }

    /// Esc: cancels a live gradient or curve, else ends any move and
    /// deselects.
    #[frb(sync)]
    pub fn escape(&mut self) -> PaintResult<bool> {
        Ok(self.session.escape()?)
    }

    /// The arrow keys in the move tools: by `(dx, dy)` pixels.
    #[frb(sync)]
    pub fn nudge(&mut self, tool: Tool, dx: i32, dy: i32) -> PaintResult<bool> {
        Ok(self.session.nudge(tool, dx, dy)?)
    }

    /// Characters typed at the Text tool's caret; false when not typing.
    #[frb(sync)]
    pub fn type_text(&mut self, settings: ToolSettings, text: String) -> PaintResult<bool> {
        Ok(self.session.type_text(&settings, &text)?)
    }

    /// A key of the text being typed; false when not typing.
    #[frb(sync)]
    pub fn text_key(
        &mut self,
        settings: ToolSettings,
        key: TextKey,
        ctrl: bool,
    ) -> PaintResult<bool> {
        Ok(self.session.text_key(&settings, key, ctrl)?)
    }

    /// Whatever is live (a gradient, a curve, lifted pixels) becomes a
    /// step: before a tool change, a command, a save.
    #[frb(sync)]
    pub fn finish(&mut self) -> PaintResult<()> {
        Ok(self.session.finish()?)
    }

    #[frb(sync)]
    pub fn overlay(&self) -> OverlayInfo {
        let overlay = self.session.overlay();
        OverlayInfo {
            handles: overlay.handles,
            guide: overlay.guide,
        }
    }

    /// How near a handle a press must be, in pixels of the picture (the
    /// shell keeps it a few screen pixels at any zoom).
    #[frb(sync)]
    pub fn set_handle_radius(&mut self, radius: f32) {
        self.session.set_handle_radius(radius);
    }

    /// The move in progress, by which the outline is drawn shifted.
    #[frb(sync)]
    pub fn move_offset(&self) -> Option<MoveOffset> {
        self.session
            .move_offset()
            .map(|(dx, dy)| MoveOffset { dx, dy })
    }

    // ---- selection ------------------------------------------------------

    /// The marching ants: edges between pixels as `x0, y0, x1, y1`
    /// quadruples, each horizontal or vertical.
    #[frb(sync)]
    pub fn selection_outline(&self) -> Vec<i32> {
        self.session.selection_outline()
    }

    // ---- colours --------------------------------------------------------

    #[frb(sync)]
    pub fn colors(&self) -> UserColors {
        self.session.document().colors()
    }

    /// New colours; a live gradient or shape redraws with them.
    #[frb(sync)]
    pub fn set_colors(&mut self, colors: UserColors, settings: ToolSettings) -> PaintResult<()> {
        Ok(self.session.set_colors(colors, &settings)?)
    }

    // ---- layers ---------------------------------------------------------

    /// The layers bottom first.
    #[frb(sync)]
    pub fn layers(&self) -> Vec<LayerProperties> {
        self.session
            .document()
            .layers()
            .iter()
            .map(|l| l.properties.clone())
            .collect()
    }

    #[frb(sync)]
    pub fn set_active_layer(&mut self, index: u32) -> PaintResult<bool> {
        Ok(self.session.set_active_layer(index as usize)?)
    }

    /// A layer dragged from `from` to `to` (indices bottom up).
    #[frb(sync)]
    pub fn move_layer(&mut self, from: u32, to: u32) -> PaintResult<bool> {
        Ok(self.session.move_layer_to(from as usize, to as usize)?)
    }

    /// A layer's thumbnail, at most `max` pixels on its longer side.
    #[frb(sync)]
    pub fn layer_thumbnail(&self, index: u32, max: u32) -> PaintResult<PixelBlock> {
        let surface = self
            .session
            .document()
            .layer_thumbnail(index as usize, max.clamp(1, 1024))?;
        Ok(block_of(&surface))
    }

    /// The flattened picture as a thumbnail, for the image tabs.
    #[frb(sync)]
    pub fn thumbnail(&self, max: u32) -> PaintResult<PixelBlock> {
        Ok(block_of(&self.session.document().thumbnail(max)?))
    }

    /// Layer Properties and the visibility box: one step.
    #[frb(sync)]
    pub fn set_layer_properties(
        &mut self,
        index: u32,
        properties: LayerProperties,
    ) -> PaintResult<bool> {
        Ok(self
            .session
            .set_layer_properties(index as usize, properties)?)
    }

    /// Layers > Import From File: the picture as a new layer named
    /// `name` at the top-left.
    #[frb(sync)]
    pub fn import_layer(&mut self, name: String, picture: &Picture) -> PaintResult<bool> {
        Ok(self.session.import_layer(&name, &picture.surface)?)
    }

    // ---- commands -------------------------------------------------------

    /// Whether a command of the image has something to act on now.
    /// Commands of the program (files, the view, windows) answer false;
    /// Paste depends on the clipboard the shell holds.
    #[frb(sync)]
    pub fn can_run(&self, id: String) -> bool {
        use pb::Command::*;
        let Some(command) = pb::Command::from_id(&id) else {
            return false;
        };
        let of_image = command.is_document_command()
            || matches!(
                command,
                Copy | Cut
                    | RepeatEffect
                    | Adjust(_)
                    | Effect(_)
                    | LayerProperties
                    | Resize
                    | CanvasSize
                    | ImportFromFile
            );
        of_image && self.session.can_run(command, last_effect().as_ref())
    }

    /// Runs a command of the image (Undo, Select All, Add New Layer,
    /// Flatten...); false when it had nothing to act on.
    #[frb(sync)]
    pub fn run(&mut self, id: String) -> PaintResult<bool> {
        let command = pb::Command::from_id(&id)
            .ok_or_else(|| PaintError::invalid(format!("no image command {id}")))?;
        Ok(self.session.run(command)?)
    }

    /// Copy: the active layer inside the selection; none without one.
    #[frb(sync)]
    pub fn copy(&mut self) -> PaintResult<Option<ClipImage>> {
        Ok(self.session.copy()?.map(|clip| ClipImage { clip }))
    }

    #[frb(sync)]
    pub fn cut(&mut self) -> PaintResult<Option<ClipImage>> {
        Ok(self.session.cut()?.map(|clip| ClipImage { clip }))
    }

    /// Paste (or Paste into New Layer): the clip becomes lifted pixels
    /// of Move Selected Pixels, which the shell switches to.
    #[frb(sync)]
    pub fn paste(&mut self, clip: &ClipImage, new_layer: bool) -> PaintResult<GestureOutcome> {
        Ok(outcome_of(self.session.paste(&clip.clip, new_layer)?))
    }

    #[frb(sync)]
    pub fn resize_image(
        &mut self,
        width: u32,
        height: u32,
        resampling: Resampling,
    ) -> PaintResult<bool> {
        Ok(self.session.resize_image(width, height, resampling)?)
    }

    #[frb(sync)]
    pub fn resize_canvas(&mut self, width: u32, height: u32, anchor: Anchor) -> PaintResult<bool> {
        Ok(self.session.resize_canvas(width, height, anchor)?)
    }

    // ---- history --------------------------------------------------------

    /// The History window's entries, the first being how the image began.
    #[frb(sync)]
    pub fn history_names(&self) -> Vec<String> {
        self.session.document().history_names()
    }

    /// Walks the history to an entry, as clicking it in History does.
    #[frb(sync)]
    pub fn jump_to(&mut self, position: u32) -> PaintResult<bool> {
        Ok(self.session.jump_to(position as usize)?)
    }

    // ---- previewing dialogs ---------------------------------------------

    /// Opens a dialog that previews on the image: `layer_properties`, an
    /// `adjust:` or an `effect:` id with its default values (an effect
    /// with the values it was last applied with). An adjustment applied
    /// at once (Invert Colors...) is applied and no dialog opens: then
    /// false.
    #[frb(sync)]
    pub fn open_preview(&mut self, id: String) -> PaintResult<bool> {
        let dialog = pb::Dialog::for_id(&id, last_effect().as_ref())
            .ok_or_else(|| PaintError::invalid(format!("no preview dialog {id}")))?;
        let opened = self.session.open_dialog(dialog, wake());
        self.remember_applied();
        Ok(opened?)
    }

    /// Ctrl+F: the last effect again, rendered on a worker; the dialog
    /// shows only the progress and ends by itself. False without one.
    #[frb(sync)]
    pub fn repeat_effect(&mut self) -> PaintResult<bool> {
        let Some(effect) = last_effect() else {
            return Ok(false);
        };
        let repeated = self.session.repeat_effect(effect, wake());
        self.remember_applied();
        Ok(repeated?)
    }

    #[frb(sync)]
    pub fn preview(&self) -> Option<PreviewInfo> {
        let info = self.session.dialog_info()?;
        Some(PreviewInfo {
            id: info.id,
            title: info.title.to_owned(),
            params: info.params.into_iter().map(param_of).collect(),
            layer: info.layer,
            curves: info.curves,
            rendering: info.rendering,
            finishing: info.finishing,
            repeat: info.repeat,
        })
    }

    /// Changes one parameter of the open dialog (one value, or one per
    /// channel) and previews it. Values the adjustment refuses (Levels
    /// with low above high) are put back and reported; the dialog stays.
    #[frb(sync)]
    pub fn set_preview_param(&mut self, name: String, values: Vec<f64>) -> PaintResult<()> {
        let set = self.session.set_dialog_param(&name, &values);
        self.remember_applied();
        Ok(set?)
    }

    /// The Curves dialog's points; points the adjustment refuses are
    /// put back and reported, the dialog stays.
    #[frb(sync)]
    pub fn set_preview_curves(&mut self, curves: Curves) -> PaintResult<()> {
        Ok(self.session.set_dialog_curves(curves)?)
    }

    /// Layer Properties' values while its dialog is open.
    #[frb(sync)]
    pub fn set_layer_preview(&mut self, properties: LayerProperties) -> PaintResult<()> {
        Ok(self.session.set_dialog_layer(properties)?)
    }

    /// Brings the image up to date with the dialog (an effect's render
    /// that arrived); an effect whose OK waited ends here. A failure
    /// cancels the dialog.
    #[frb(sync)]
    pub fn poll_preview(&mut self) -> PaintResult<PreviewPoll> {
        let poll = self.session.poll_dialog();
        self.remember_applied();
        let poll = poll?;
        Ok(PreviewPoll {
            open: poll.open,
            changed: poll.changed,
            rendering: poll.rendering,
        })
    }

    /// OK (`ok` true) or Cancel. OK while an effect still renders keeps
    /// the dialog open until the render is in: then false.
    #[frb(sync)]
    pub fn end_preview(&mut self, ok: bool) -> PaintResult<bool> {
        let ended = self.session.end_dialog(ok);
        self.remember_applied();
        Ok(ended?)
    }
}

impl PaintImage {
    fn remember_applied(&mut self) {
        if let Some(effect) = self.session.take_applied_effect() {
            if let Ok(mut last) = LAST_EFFECT.lock() {
                *last = Some(effect);
            }
        }
    }
}

fn stamp_of(s: pb::Stamp) -> ImageStamp {
    ImageStamp {
        revision: s.revision,
        width: s.width,
        height: s.height,
        history_position: s.history_position as u32,
        history_length: s.history_length as u32,
        can_undo: s.can_undo,
        can_redo: s.can_redo,
        selection_stamp: s.selection_stamp,
        has_selection: s.has_selection,
        selection_bounds: s.selection_bounds,
        active_layer: s.active_layer as u32,
        layer_count: s.layer_count as u32,
        is_editing: s.is_editing,
        is_pressed: s.is_pressed,
        is_modified: s.is_modified,
        has_preview: s.has_dialog,
        is_typing: s.is_typing,
    }
}

fn param_of(p: pb::Param) -> DialogParam {
    DialogParam {
        name: p.name,
        values: p.values,
        min: p.min,
        max: p.max,
        kind: match p.kind {
            pb::ParamKind::Integer => ParamKind::Integer,
            pb::ParamKind::Real => ParamKind::Real,
            pb::ParamKind::Flag => ParamKind::Flag,
            pb::ParamKind::Seed => ParamKind::Seed,
        },
    }
}

fn nothing() -> GestureOutcome {
    GestureOutcome {
        switch_to: None,
        previous_tool: false,
    }
}

fn outcome_of(outcome: pb::Outcome) -> GestureOutcome {
    match outcome {
        pb::Outcome::Nothing => nothing(),
        pb::Outcome::SwitchTool(tool) => GestureOutcome {
            switch_to: Some(tool),
            previous_tool: false,
        },
        pb::Outcome::PreviousTool => GestureOutcome {
            switch_to: None,
            previous_tool: true,
        },
    }
}

fn pointer(
    x: f32,
    y: f32,
    secondary: bool,
    ctrl: bool,
    alt: bool,
    shift: bool,
    time: f64,
) -> pb::Pointer {
    pb::Pointer {
        pos: pb::PointF::new(x, y),
        button: if secondary {
            pb::Button::Secondary
        } else {
            pb::Button::Primary
        },
        mods: pb::Mods { ctrl, alt, shift },
        time: if time.is_finite() { time } else { 0.0 },
    }
}

fn block_of(surface: &pb::Surface) -> PixelBlock {
    PixelBlock {
        x: 0,
        y: 0,
        width: surface.width(),
        height: surface.height(),
        pixels: surface.to_premultiplied_rgba8(),
    }
}

fn last_effect() -> Option<pb::Effect> {
    LAST_EFFECT.lock().ok().and_then(|e| *e)
}

#[cfg(test)]
mod tests {
    use super::*;

    /// The canvas's costs on a 4k image: `cargo test -p paintbox_bridge
    /// --release -- --ignored --nocapture`.
    #[test]
    #[ignore]
    fn costs_on_a_4k_image() {
        let colors = pb::UserColors::default();
        let mut image = PaintImage::blank(4096, 4096, pb::Rgba8::WHITE, colors).unwrap();
        image.session.document_mut().add_layer().unwrap();
        let all = pb::Rect::new(0, 0, 4096, 4096);
        let time = std::time::Instant::now();
        let tiles = image.composite_tiles(all, 256);
        println!(
            "full composite: {} tiles in {:?}",
            tiles.len(),
            time.elapsed()
        );
        let settings = pb::ToolSettings {
            width: 20.0,
            ..pb::ToolSettings::default()
        };
        image
            .press(
                pb::Tool::Paintbrush,
                settings.clone(),
                100.0,
                100.0,
                false,
                false,
                false,
                false,
                0.0,
            )
            .unwrap();
        let _ = image.take_changes(false);
        let time = std::time::Instant::now();
        let (mut painting, mut tiling) = (std::time::Duration::ZERO, std::time::Duration::ZERO);
        for i in 0..200 {
            let x = 100.0 + i as f32 * 15.0;
            let t = std::time::Instant::now();
            image
                .move_to(settings.clone(), x, 100.0 + (i % 40) as f32 * 3.0)
                .unwrap();
            painting += t.elapsed();
            let t = std::time::Instant::now();
            if let Some(dirty) = image.take_changes(false).dirty {
                let _ = image.composite_tiles(dirty, 256);
            }
            tiling += t.elapsed();
        }
        println!(
            "stroke: 200 moves, core {painting:?}, tiles {tiling:?}, all {:?}",
            time.elapsed()
        );
        let time = std::time::Instant::now();
        let _ = image.thumbnail(48).unwrap();
        println!("tab thumbnail: {:?}", time.elapsed());
        let time = std::time::Instant::now();
        let _ = image.selection_outline();
        image.session.document_mut().select_all().unwrap();
        let _ = image.selection_outline();
        println!("outline of select all: {:?}", time.elapsed());
    }
}
