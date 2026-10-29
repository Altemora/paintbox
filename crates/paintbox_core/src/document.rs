//! The document: canvas, layer stack, active layer, selection, user
//! colours and history. Every command a shell offers is a method here
//! (this file and the tool, selection, image and filter modules add
//! `impl Document` blocks); each finished command is one history step.

use serde::{Deserialize, Serialize};

use crate::blend::blend_row;
use crate::color::{mul255, Rgba8};
use crate::error::{Error, Result};
use crate::geom::Rect;
use crate::history::{CanvasState, Change, History, Step, TileBackup};
use crate::layer::{Layer, LayerProperties};
use crate::parallel::{for_rows, for_rows_with_work};
use crate::selection::Selection;
use crate::surface::{check_size, Surface};
use crate::tools::{Lift, Stroke};

/// Which mouse button a gesture uses: the left paints with the primary
/// colour, the right with the secondary.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Button {
    Primary,
    Secondary,
}

/// The two colours of the Colors window.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub struct UserColors {
    pub primary: Rgba8,
    pub secondary: Rgba8,
}

impl Default for UserColors {
    fn default() -> Self {
        Self {
            primary: Rgba8::BLACK,
            secondary: Rgba8::WHITE,
        }
    }
}

impl UserColors {
    /// X: swap the two.
    pub fn swap(&mut self) {
        std::mem::swap(&mut self.primary, &mut self.secondary);
    }

    /// The colour a button paints with, and the other one.
    pub fn for_button(&self, button: Button) -> (Rgba8, Rgba8) {
        match button {
            Button::Primary => (self.primary, self.secondary),
            Button::Secondary => (self.secondary, self.primary),
        }
    }
}

pub(crate) enum EditKind {
    /// Redrawn from the originals on every call (gradient, shapes,
    /// adjustments while their dialog is open).
    Plain,
    Stroke(Box<Stroke>),
    Lift(Box<Lift>),
    MoveSelection {
        base: Selection,
    },
}

/// An edit in progress on one layer: the originals of the tiles it has
/// touched and the selection it started from.
pub(crate) struct Edit {
    pub(crate) name: String,
    pub(crate) layer: usize,
    pub(crate) backup: TileBackup,
    pub(crate) selection_before: Selection,
    pub(crate) kind: EditKind,
}

pub struct Document {
    pub(crate) width: u32,
    pub(crate) height: u32,
    pub(crate) layers: Vec<Layer>,
    pub(crate) active: usize,
    pub(crate) selection: Selection,
    pub(crate) colors: UserColors,
    pub(crate) history: History,
    pub(crate) edit: Option<Edit>,
    pub(crate) dirty: Rect,
    pub(crate) revision: u64,
    pub(crate) clone_source: Option<crate::tools::CloneSource>,
    /// A layer whose properties the Layer Properties dialog is showing
    /// live, with the properties it had before.
    pub(crate) properties_preview: Option<(usize, LayerProperties)>,
}

impl Document {
    /// A new image as Paint.NET makes it: one opaque Background layer
    /// filled with `background`.
    pub fn new(width: u32, height: u32, background: Rgba8) -> Result<Self> {
        let layer = Layer::background(width, height, background)?;
        Ok(Self::from_layers(width, height, vec![layer], "New Image"))
    }

    /// A document over existing layers (files, paste into new image).
    /// Every layer must have the canvas size.
    pub fn with_layers(width: u32, height: u32, layers: Vec<Layer>, origin: &str) -> Result<Self> {
        check_size(width, height)?;
        if layers.is_empty() {
            return Err(Error::LastLayer);
        }
        if layers
            .iter()
            .any(|l| l.surface.width() != width || l.surface.height() != height)
        {
            return Err(Error::InvalidParameter(
                "every layer must have the canvas size".into(),
            ));
        }
        Ok(Self::from_layers(width, height, layers, origin))
    }

    /// The picture as it is with a fresh history named `origin`: the
    /// layers, the active layer, the selection and the colours stay. An
    /// open edit is committed first. For a shell that hands the picture
    /// on (the editor applying it to a texture) and starts over.
    pub fn restarted(&mut self, origin: &str) -> Result<Document> {
        if self.is_editing() {
            self.commit_edit()?;
        }
        let mut fresh = Self::from_layers(self.width, self.height, self.layers.clone(), origin);
        fresh.active = self.active;
        fresh.selection = self.selection.clone();
        fresh.colors = self.colors;
        fresh.revision = self.revision.wrapping_add(1);
        Ok(fresh)
    }

    fn from_layers(width: u32, height: u32, layers: Vec<Layer>, origin: &str) -> Self {
        let canvas = Rect::of_size(width, height);
        let active = layers.len() - 1;
        Self {
            width,
            height,
            layers,
            active,
            selection: Selection::none(canvas),
            colors: UserColors::default(),
            history: History::new(origin),
            edit: None,
            dirty: canvas,
            revision: 0,
            clone_source: None,
            properties_preview: None,
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

    /// Bottom first.
    pub fn layers(&self) -> &[Layer] {
        &self.layers
    }

    pub fn layer(&self, index: usize) -> Result<&Layer> {
        self.layers.get(index).ok_or(Error::LayerIndex(index))
    }

    pub fn active_layer_index(&self) -> usize {
        self.active
    }

    /// Picking a layer in the Layers window; not a history step.
    pub fn set_active_layer(&mut self, index: usize) -> Result<()> {
        self.layer(index)?;
        self.finish_pending()?;
        self.active = index;
        self.bump();
        Ok(())
    }

    pub fn selection(&self) -> &Selection {
        &self.selection
    }

    pub fn colors(&self) -> UserColors {
        self.colors
    }

    /// Colours are not history (as in Paint.NET).
    pub fn set_colors(&mut self, colors: UserColors) {
        self.colors = colors;
        self.bump();
    }

    pub fn swap_colors(&mut self) {
        self.colors.swap();
        self.bump();
    }

    /// Grows on every change of pixels, layers, selection, colours or
    /// history; a shell refreshes its panels when it moves.
    pub fn revision(&self) -> u64 {
        self.revision
    }

    pub(crate) fn bump(&mut self) {
        self.revision = self.revision.wrapping_add(1);
    }

    pub(crate) fn mark_dirty(&mut self, rect: Rect) {
        self.dirty = self.dirty.union(rect.intersect(self.bounds()));
        self.bump();
    }

    /// The area whose composite changed since the last call, if any.
    pub fn take_dirty(&mut self) -> Option<Rect> {
        let dirty = std::mem::take(&mut self.dirty);
        (!dirty.is_empty()).then_some(dirty)
    }

    // ---- composition ----------------------------------------------

    fn composite_into(&self, rect: Rect, out: &mut [Rgba8]) {
        let visible: Vec<&Layer> = self
            .layers
            .iter()
            .filter(|l| l.properties.visible && l.properties.opacity > 0)
            .collect();
        let x0 = rect.x as usize;
        let x1 = rect.right() as usize;
        for_rows(out, rect.width as usize, |row, line| {
            let y = rect.y + row as i32;
            for layer in &visible {
                let source = &layer.surface.row(y)[x0..x1];
                blend_row(
                    line,
                    source,
                    layer.properties.blend_mode,
                    layer.properties.opacity,
                );
            }
        });
    }

    /// The visible layers blended over transparency within `rect`, as
    /// straight RGBA bytes row by row; what a shell uploads for a dirty
    /// rectangle. Empty when `rect` misses the canvas.
    pub fn composite_rgba8(&self, rect: Rect) -> Vec<u8> {
        let rect = rect.intersect(self.bounds());
        let mut out = vec![0u8; rect.area() as usize * 4];
        // The rectangle is clipped above, so the sizes always agree.
        let _ = self.composite_into_rgba8(rect, &mut out);
        out
    }

    /// The same into a buffer the shell owns (a texture upload, an
    /// engine's byte array): `rect` must lie inside the canvas and `out` hold
    /// `rect.area() * 4` bytes.
    pub fn composite_into_rgba8(&self, rect: Rect, out: &mut [u8]) -> Result<()> {
        if rect.intersect(self.bounds()) != rect || out.len() != rect.area() as usize * 4 {
            return Err(Error::InvalidParameter(
                "the rectangle must lie inside the canvas and match the buffer".into(),
            ));
        }
        let visible: Vec<&Layer> = self
            .layers
            .iter()
            .filter(|l| l.properties.visible && l.properties.opacity > 0)
            .collect();
        let (x0, x1) = (rect.x as usize, rect.right() as usize);
        for_rows(out, rect.width as usize * 4, |row, bytes| {
            let y = rect.y + row as i32;
            let mut line = vec![Rgba8::TRANSPARENT; rect.width as usize];
            for layer in &visible {
                let source = &layer.surface.row(y)[x0..x1];
                blend_row(
                    &mut line,
                    source,
                    layer.properties.blend_mode,
                    layer.properties.opacity,
                );
            }
            for (p, b) in line.iter().zip(bytes.as_chunks_mut::<4>().0.iter_mut()) {
                *b = [p.r, p.g, p.b, p.a];
            }
        });
        Ok(())
    }

    /// The whole image flattened: plain saving, Copy Merged, thumbnails.
    pub fn flatten_image(&self) -> Surface {
        let rect = self.bounds();
        let mut out = vec![Rgba8::TRANSPARENT; rect.area() as usize];
        self.composite_into(rect, &mut out);
        Surface::from_pixels(self.width, self.height, out)
    }

    // ---- edits --------------------------------------------------------

    pub fn is_editing(&self) -> bool {
        self.edit.is_some()
    }

    /// Opens an edit of the active layer that later calls redraw from
    /// the originals: drag a gradient or shape, or preview an
    /// adjustment, then [`Document::commit_edit`] or
    /// [`Document::cancel_edit`].
    pub fn begin_edit(&mut self, name: &str) -> Result<()> {
        self.open_edit(name, EditKind::Plain)
    }

    pub(crate) fn open_edit(&mut self, name: &str, kind: EditKind) -> Result<()> {
        if self.edit.is_some() {
            return Err(Error::EditInProgress);
        }
        self.edit = Some(Edit {
            name: name.to_owned(),
            layer: self.active,
            backup: TileBackup::new(self.width, self.height),
            selection_before: self.selection.clone(),
            kind,
        });
        Ok(())
    }

    /// Ends the edit as one history step. Returns whether anything
    /// changed (an edit that changed nothing records no step).
    pub fn commit_edit(&mut self) -> Result<bool> {
        if let Some(EditKind::Stroke(stroke)) = self.edit.as_ref().map(|e| &e.kind) {
            if let Some(source) = stroke.advanced_clone_source() {
                self.clone_source = Some(source);
            }
        }
        let edit = self.edit.take().ok_or(Error::NoEdit)?;
        let mut changes = Vec::new();
        if let Some(patch) = edit
            .backup
            .into_patch(edit.layer, &self.layers[edit.layer].surface)
        {
            changes.push(Change::Pixels(patch));
        }
        if self.selection != edit.selection_before {
            changes.push(Change::Selection {
                before: edit.selection_before.snapshot(),
                after: self.selection.snapshot(),
            });
        }
        if changes.is_empty() {
            return Ok(false);
        }
        self.push_step(&edit.name, changes, self.active);
        Ok(true)
    }

    /// Ends the edit, putting back pixels and selection.
    pub fn cancel_edit(&mut self) {
        if let Some(edit) = self.edit.take() {
            let area = edit.backup.restore(&mut self.layers[edit.layer].surface);
            self.selection = edit.selection_before;
            self.mark_dirty(area);
        }
    }

    /// Commits whatever edit is open: called before every command that
    /// is not part of it.
    pub(crate) fn finish_pending(&mut self) -> Result<()> {
        self.cancel_layer_properties_preview();
        // Lifted pixels land (resampled, the selection whole) as they do
        // on Enter.
        if self.is_lifted() {
            return self.finish_move();
        }
        if self.edit.is_some() {
            self.commit_edit()?;
        }
        Ok(())
    }

    /// Runs `draw` as an edit: inside an open plain edit it redraws
    /// from the originals (a preview); otherwise it is its own step.
    pub(crate) fn run_edit(
        &mut self,
        name: &str,
        draw: impl FnOnce(&mut Self) -> Result<()>,
    ) -> Result<()> {
        if matches!(self.edit.as_ref().map(|e| &e.kind), Some(EditKind::Plain)) {
            self.restore_edit();
            return draw(self);
        }
        self.finish_pending()?;
        self.open_edit(name, EditKind::Plain)?;
        match draw(self) {
            Ok(()) => self.commit_edit().map(|_| ()),
            Err(error) => {
                self.cancel_edit();
                Err(error)
            }
        }
    }

    /// Puts the open edit's layer and selection back to how they were,
    /// keeping the edit open.
    pub(crate) fn restore_edit(&mut self) {
        if let Some(edit) = &self.edit {
            let area = edit.backup.restore(&mut self.layers[edit.layer].surface);
            self.selection = edit.selection_before.clone();
            self.mark_dirty(area);
        }
    }

    pub(crate) fn edit_layer(&self) -> usize {
        self.edit.as_ref().map_or(self.active, |e| e.layer)
    }

    /// Repaints `rect` of the edit's layer: every pixel is `paint(orig,
    /// coverage, x, y)` where `orig` is the pixel before the edit and
    /// `coverage` is `coverage(x, y)` times the selection; pixels with no
    /// coverage get their original back. Calls are idempotent, so a
    /// growing stroke mask can be applied again over a larger area.
    pub(crate) fn paint_region(
        &mut self,
        rect: Rect,
        coverage: impl Fn(i32, i32) -> u8 + Sync,
        paint: impl Fn(Rgba8, u8, i32, i32) -> Rgba8 + Sync,
    ) -> Result<()> {
        let rect = rect.intersect(self.selection.bounds());
        self.paint_region_raw(rect, |original, selected, x, y| {
            let c = mul255(coverage(x, y) as u32, selected as u32) as u8;
            if c == 0 {
                original
            } else {
                paint(original, c, x, y)
            }
        })
    }

    /// The general form: `paint(orig, selection coverage, x, y)` for
    /// every pixel of `rect`, which is not clipped to the selection.
    pub(crate) fn paint_region_raw(
        &mut self,
        rect: Rect,
        paint: impl Fn(Rgba8, u8, i32, i32) -> Rgba8 + Sync,
    ) -> Result<()> {
        let rect = rect.intersect(self.bounds());
        if rect.is_empty() {
            return Ok(());
        }
        let edit = self.edit.as_mut().ok_or(Error::NoEdit)?;
        let layer = &mut self.layers[edit.layer];
        edit.backup.touch(&layer.surface, rect);
        let backup = &edit.backup;
        let selection = &self.selection;
        let width = layer.surface.width() as usize;
        let rows = &mut layer.surface.pixels_mut()
            [rect.y as usize * width..rect.bottom() as usize * width];
        for_rows_with_work(rows, width, rect.area() as usize, |row, line| {
            let y = rect.y + row as i32;
            for x in rect.x..rect.right() {
                let pixel = &mut line[x as usize];
                let original = backup.original_or(x, y, *pixel);
                *pixel = paint(original, selection.coverage(x, y), x, y);
            }
        });
        self.mark_dirty(rect);
        Ok(())
    }

    // ---- history --------------------------------------------------------

    pub(crate) fn push_step(&mut self, name: &str, changes: Vec<Change>, active_before: usize) {
        self.history.push(Step {
            name: name.to_owned(),
            changes,
            active_before,
            active_after: self.active,
            id: 0,
        });
        self.bump();
    }

    /// Records a selection change made directly (selection tools and
    /// commands) as a step, if it changed anything.
    pub(crate) fn record_selection(&mut self, name: &str, before: Selection) {
        if before != self.selection {
            let change = Change::Selection {
                before: before.snapshot(),
                after: self.selection.snapshot(),
            };
            self.push_step(name, vec![change], self.active);
        }
    }

    /// Entry names for the History window; entry 0 is the origin.
    pub fn history_names(&self) -> Vec<String> {
        self.history.names()
    }

    /// Identifies what the history has produced: equal values mean the
    /// same applied steps (a shell compares it with the value at save
    /// time to tell unsaved changes; undo back to it is "saved" again).
    pub fn state_id(&self) -> u64 {
        self.history.state_id()
    }

    /// Whether the image differs from the state `saved` (a
    /// [`Document::state_id`] taken at a save): an undo back to it is
    /// unmodified again; an open edit counts as a change.
    pub fn is_modified_since(&self, saved: u64) -> bool {
        self.state_id() != saved || self.is_editing()
    }

    /// A small picture of a layer for a Layers panel, at most `max`
    /// pixels on its longer side, sampled (not averaged) so even a 4k
    /// layer costs a few thousand reads. Straight RGBA, no chequer.
    pub fn layer_thumbnail(&self, index: usize, max: u32) -> Result<Surface> {
        let surface = self.layer(index)?.surface();
        let (w, h) = (self.width as f32, self.height as f32);
        let max = max.clamp(1, 1024) as f32;
        let scale = (max / w).min(max / h);
        let tw = ((w * scale).round() as u32).clamp(1, max as u32);
        let th = ((h * scale).round() as u32).clamp(1, max as u32);
        let mut out = Surface::new(tw, th)?;
        for y in 0..th {
            for x in 0..tw {
                let sx = ((x as f32 + 0.5) / scale) as i32;
                let sy = ((y as f32 + 0.5) / scale) as i32;
                out.set(x as i32, y as i32, surface.get(sx, sy).unwrap_or_default());
            }
        }
        Ok(out)
    }

    /// A small picture of the whole image (a tab, a recent file), at most
    /// `max` pixels on its longer side: only the sampled rows are
    /// composited, so a 4k image costs a few hundred thousand pixels,
    /// not sixteen million. Straight RGBA, no chequer.
    pub fn thumbnail(&self, max: u32) -> Result<Surface> {
        let (w, h) = (self.width as f32, self.height as f32);
        let max = max.clamp(1, 1024) as f32;
        let scale = (max / w).min(max / h);
        let tw = ((w * scale).round() as u32).clamp(1, max as u32);
        let th = ((h * scale).round() as u32).clamp(1, max as u32);
        let mut out = Surface::new(tw, th)?;
        for y in 0..th {
            let sy = (((y as f32 + 0.5) / scale) as i32).min(self.height as i32 - 1);
            let row = self.composite_rgba8(Rect::new(0, sy, self.width, 1));
            for x in 0..tw {
                let sx = (((x as f32 + 0.5) / scale) as usize).min(self.width as usize - 1);
                if let Some(p) = row.get(sx * 4..sx * 4 + 4) {
                    out.set(x as i32, y as i32, Rgba8::new(p[0], p[1], p[2], p[3]));
                }
            }
        }
        Ok(out)
    }

    /// The current History entry (0 — the origin, nothing applied).
    pub fn history_position(&self) -> usize {
        self.history.position()
    }

    pub fn can_undo(&self) -> bool {
        self.edit.is_some() || self.history.can_undo()
    }

    pub fn can_redo(&self) -> bool {
        self.edit.is_none() && self.history.can_redo()
    }

    /// Memory the history holds, for a status read-out.
    pub fn history_bytes(&self) -> usize {
        self.history.bytes()
    }

    /// The memory the history may hold before its oldest steps are
    /// dropped ([`DEFAULT_HISTORY_LIMIT`] unless set).
    pub fn history_limit(&self) -> usize {
        self.history.limit()
    }

    pub fn set_history_limit(&mut self, bytes: usize) {
        self.history.set_limit(bytes);
    }

    /// How many of the oldest steps the limit has dropped.
    pub fn history_evicted(&self) -> usize {
        self.history.evicted()
    }

    /// Ctrl+Z. An open edit is committed first, so undo removes it (Esc
    /// on a live gradient). Returns whether a step was undone.
    pub fn undo(&mut self) -> Result<bool> {
        self.step_history(true)
    }

    /// Ctrl+Y.
    pub fn redo(&mut self) -> Result<bool> {
        self.step_history(false)
    }

    fn step_history(&mut self, undo: bool) -> Result<bool> {
        self.finish_pending()?;
        // The history is taken out while its step is applied, so the step
        // is read in place rather than copied (a canvas step holds whole
        // layer stacks).
        let mut history = std::mem::replace(&mut self.history, History::new(""));
        let step = if undo {
            history.undo_step()
        } else {
            history.redo_step()
        };
        let applied = step.is_some();
        if let Some(step) = step {
            if undo {
                for change in step.changes.iter().rev() {
                    self.apply_change(change, true);
                }
            } else {
                for change in &step.changes {
                    self.apply_change(change, false);
                }
            }
            let active = if undo {
                step.active_before
            } else {
                step.active_after
            };
            self.active = active.min(self.layers.len() - 1);
        }
        self.history = history;
        self.bump();
        Ok(applied)
    }

    /// Clicking an entry in the History window.
    pub fn jump_to(&mut self, position: usize) -> Result<()> {
        self.finish_pending()?;
        if position >= self.history.names().len() {
            return Err(Error::InvalidParameter(format!(
                "no history entry {position}"
            )));
        }
        while self.history.position() > position {
            self.undo()?;
        }
        while self.history.position() < position {
            self.redo()?;
        }
        Ok(())
    }

    fn apply_change(&mut self, change: &Change, undo: bool) {
        match change {
            Change::Pixels(patch) => {
                let area = patch.apply(&mut self.layers[patch.layer].surface, undo);
                self.mark_dirty(area);
            }
            Change::Selection { before, after } => {
                self.selection = if undo { before } else { after }.restore();
            }
            Change::LayerInserted { index, layer } => {
                if undo {
                    self.layers.remove(*index);
                } else {
                    self.layers.insert(*index, layer.clone());
                }
                self.mark_dirty(self.bounds());
            }
            Change::LayerRemoved { index, layer } => {
                if undo {
                    self.layers.insert(*index, layer.clone());
                } else {
                    self.layers.remove(*index);
                }
                self.mark_dirty(self.bounds());
            }
            Change::LayerMoved { from, to } => {
                let (from, to) = if undo { (*to, *from) } else { (*from, *to) };
                let layer = self.layers.remove(from);
                self.layers.insert(to, layer);
                self.mark_dirty(self.bounds());
            }
            Change::LayerProperties {
                index,
                before,
                after,
            } => {
                self.layers[*index].properties = if undo { before } else { after }.clone();
                self.mark_dirty(self.bounds());
            }
            Change::Canvas { before, after } => {
                let state = if undo { before } else { after };
                self.width = state.width;
                self.height = state.height;
                self.layers = state.layers.clone();
                self.selection = state.selection.restore();
                self.dirty = Rect::default();
                self.mark_dirty(self.bounds());
            }
        }
    }

    // ---- canvas-wide commands -------------------------------------

    pub(crate) fn canvas_state(&self) -> CanvasState {
        CanvasState {
            width: self.width,
            height: self.height,
            layers: self.layers.clone(),
            selection: self.selection.snapshot(),
        }
    }

    /// Replaces size, layers and selection at once as one step.
    pub(crate) fn replace_canvas(&mut self, name: &str, after: CanvasState) {
        let before = self.canvas_state();
        let active_before = self.active;
        self.width = after.width;
        self.height = after.height;
        self.layers = after.layers.clone();
        self.selection = after.selection.restore();
        self.active = self.active.min(self.layers.len() - 1);
        self.dirty = Rect::default();
        self.mark_dirty(self.bounds());
        let change = Change::Canvas {
            before: Box::new(before),
            after: Box::new(after),
        };
        self.push_step(name, vec![change], active_before);
    }

    // ---- layer commands ---------------------------------------------

    /// Add New Layer (Ctrl+Shift+N): transparent, above the active one,
    /// named "Layer N" with N one more than the count.
    pub fn add_layer(&mut self) -> Result<usize> {
        let name = format!("Layer {}", self.layers.len() + 1);
        let layer = Layer::transparent(name, self.width, self.height)?;
        self.insert_layer("Add New Layer", layer)
    }

    /// Import From File: the picture as a new layer at the top-left;
    /// whatever exceeds the canvas is cut off (offer Canvas Size first).
    pub fn import_layer(&mut self, name: &str, picture: &Surface) -> Result<usize> {
        let mut surface = Surface::new(self.width, self.height)?;
        surface.paste(picture, 0, 0);
        let layer = Layer::from_surface(LayerProperties::named(name), surface);
        self.insert_layer("Import From File", layer)
    }

    fn insert_layer(&mut self, name: &str, layer: Layer) -> Result<usize> {
        self.finish_pending()?;
        let before = self.active;
        let index = self.active + 1;
        self.layers.insert(index, layer.clone());
        self.active = index;
        self.mark_dirty(self.bounds());
        self.push_step(name, vec![Change::LayerInserted { index, layer }], before);
        Ok(index)
    }

    /// Delete Layer (Ctrl+Shift+Delete); the last layer stays.
    pub fn delete_layer(&mut self) -> Result<()> {
        self.finish_pending()?;
        if self.layers.len() == 1 {
            return Err(Error::LastLayer);
        }
        let before = self.active;
        let index = self.active;
        let layer = self.layers.remove(index);
        self.active = index.saturating_sub(1);
        if self.clone_source.is_some_and(|s| s.layer == index) {
            self.clone_source = None;
        }
        self.mark_dirty(self.bounds());
        self.push_step(
            "Delete Layer",
            vec![Change::LayerRemoved { index, layer }],
            before,
        );
        Ok(())
    }

    /// Duplicate Layer (Ctrl+Shift+D): same name and properties, no
    /// Background flag.
    pub fn duplicate_layer(&mut self) -> Result<usize> {
        let mut layer = self.layers[self.active].clone();
        layer.properties.is_background = false;
        self.insert_layer("Duplicate Layer", layer)
    }

    /// Merge Layer Down (Ctrl+M): the active layer blended into the one
    /// below with its mode and opacity; the lower keeps its properties.
    pub fn merge_layer_down(&mut self) -> Result<()> {
        self.finish_pending()?;
        if self.active == 0 {
            return Err(Error::NoLayerBelow);
        }
        let before = self.active;
        let upper_index = self.active;
        let lower_index = upper_index - 1;
        let upper = self.layers[upper_index].clone();
        let mut backup = TileBackup::new(self.width, self.height);
        backup.touch(&self.layers[lower_index].surface, self.bounds());
        let lower = &mut self.layers[lower_index].surface;
        let width = self.width as usize;
        for_rows(lower.pixels_mut(), width, |y, line| {
            blend_row(
                line,
                upper.surface.row(y as i32),
                upper.properties.blend_mode,
                upper.properties.opacity,
            );
        });
        let mut changes = Vec::new();
        if upper.properties.visible {
            if let Some(patch) = backup.into_patch(lower_index, &self.layers[lower_index].surface) {
                changes.push(Change::Pixels(patch));
            }
        } else {
            backup.restore(&mut self.layers[lower_index].surface);
        }
        self.layers.remove(upper_index);
        changes.push(Change::LayerRemoved {
            index: upper_index,
            layer: upper,
        });
        self.active = lower_index;
        self.mark_dirty(self.bounds());
        self.push_step("Merge Layer Down", changes, before);
        Ok(())
    }

    /// Move Layer Up (`up`) or Down in the stack; the layer stays
    /// active. Returns false at the end of the stack.
    pub fn move_layer(&mut self, up: bool) -> Result<bool> {
        let from = self.active;
        let to = if up { from + 1 } else { from.wrapping_sub(1) };
        if to >= self.layers.len() {
            return Ok(false);
        }
        self.move_layer_to(from, to)
    }

    /// A layer dragged in the Layers window from `from` to `to` (indices
    /// bottom up): one step named by the direction, the moved layer active.
    pub fn move_layer_to(&mut self, from: usize, to: usize) -> Result<bool> {
        self.layer(from)?;
        self.layer(to)?;
        if from == to {
            return Ok(false);
        }
        self.finish_pending()?;
        let before = self.active;
        let layer = self.layers.remove(from);
        self.layers.insert(to, layer);
        self.active = to;
        self.mark_dirty(self.bounds());
        let name = if to > from {
            "Move Layer Up"
        } else {
            "Move Layer Down"
        };
        self.push_step(name, vec![Change::LayerMoved { from, to }], before);
        Ok(true)
    }

    /// The Layer Properties dialog while it is open: shows `properties`
    /// on the layer without a history step. [`Document::set_layer_properties`]
    /// on OK records one step from the properties before the dialog;
    /// Cancel is [`Document::cancel_layer_properties_preview`].
    pub fn preview_layer_properties(
        &mut self,
        index: usize,
        properties: LayerProperties,
    ) -> Result<()> {
        self.layer(index)?;
        if self
            .properties_preview
            .as_ref()
            .is_some_and(|(i, _)| *i != index)
        {
            self.cancel_layer_properties_preview();
        }
        if self.properties_preview.is_none() {
            self.properties_preview = Some((index, self.layers[index].properties.clone()));
        }
        self.layers[index].properties = properties;
        self.mark_dirty(self.bounds());
        Ok(())
    }

    /// Puts back the properties a preview replaced.
    pub fn cancel_layer_properties_preview(&mut self) {
        if let Some((index, properties)) = self.properties_preview.take() {
            if let Some(layer) = self.layers.get_mut(index) {
                layer.properties = properties;
            }
            self.mark_dirty(self.bounds());
        }
    }

    /// Layer Properties (F4) and the visibility box: one step. Hiding
    /// the active layer makes the nearest visible layer active.
    pub fn set_layer_properties(
        &mut self,
        index: usize,
        properties: LayerProperties,
    ) -> Result<()> {
        self.finish_pending()?;
        let before = self.layer(index)?.properties.clone();
        if before == properties {
            return Ok(());
        }
        let active_before = self.active;
        self.layers[index].properties = properties.clone();
        if index == self.active && !properties.visible {
            if let Some(nearest) = self.nearest_visible(index) {
                self.active = nearest;
            }
        }
        self.mark_dirty(self.bounds());
        let name = if before.visible != properties.visible && {
            let mut p = before.clone();
            p.visible = properties.visible;
            p == properties
        } {
            if properties.visible {
                "Layer Shown"
            } else {
                "Layer Hidden"
            }
        } else {
            "Layer Properties"
        };
        let change = Change::LayerProperties {
            index,
            before,
            after: properties,
        };
        self.push_step(name, vec![change], active_before);
        Ok(())
    }

    fn nearest_visible(&self, index: usize) -> Option<usize> {
        (1..self.layers.len()).find_map(|d| {
            [index.checked_sub(d), Some(index + d)]
                .into_iter()
                .flatten()
                .find(|&i| i < self.layers.len() && self.layers[i].properties.visible)
        })
    }

    /// Layers > Flip Horizontal / Vertical on the active layer.
    pub fn flip_layer(&mut self, horizontal: bool) -> Result<()> {
        let name = if horizontal {
            "Flip Layer Horizontal"
        } else {
            "Flip Layer Vertical"
        };
        self.finish_pending()?;
        self.open_edit(name, EditKind::Plain)?;
        let bounds = self.bounds();
        if let Some(edit) = self.edit.as_mut() {
            let surface = &mut self.layers[edit.layer].surface;
            edit.backup.touch(surface, bounds);
            if horizontal {
                surface.flip_horizontal();
            } else {
                surface.flip_vertical();
            }
        }
        self.mark_dirty(bounds);
        self.commit_edit().map(|_| ())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::blend::BlendMode;

    fn doc() -> Document {
        Document::new(100, 80, Rgba8::WHITE).unwrap()
    }

    #[test]
    fn the_thumbnail_is_the_composite_sampled() {
        let mut doc = doc();
        doc.add_layer().unwrap();
        let mut props = doc.layer(1).unwrap().properties.clone();
        props.visible = false;
        doc.set_layer_properties(1, props).unwrap();
        let thumb = doc.thumbnail(10).unwrap();
        assert_eq!((thumb.width(), thumb.height()), (10, 8));
        assert_eq!(thumb.get(5, 4), Some(Rgba8::WHITE));
    }

    #[test]
    fn a_restarted_picture_keeps_its_layers_and_selection() {
        let mut doc = doc();
        doc.add_layer().unwrap();
        doc.select_all().unwrap();
        let fresh = doc.restarted("Open Image").unwrap();
        assert_eq!(fresh.layers().len(), 2);
        assert_eq!(fresh.active_layer_index(), 1);
        assert!(fresh.selection().is_active());
        assert_eq!(fresh.history_names(), ["Open Image"]);
    }

    fn pixel(doc: &Document, x: i32, y: i32) -> Rgba8 {
        let bytes = doc.composite_rgba8(Rect::new(x, y, 1, 1));
        Rgba8::new(bytes[0], bytes[1], bytes[2], bytes[3])
    }

    #[test]
    fn a_new_image_is_one_white_background_layer() {
        let d = doc();
        assert_eq!(d.layers().len(), 1);
        assert_eq!(d.layers()[0].properties.name, "Background");
        assert!(d.layers()[0].properties.is_background);
        assert_eq!(pixel(&d, 5, 5), Rgba8::WHITE);
        assert_eq!(d.history_names(), ["New Image"]);
        assert!(!d.can_undo());
    }

    #[test]
    fn layer_commands_undo_and_redo() {
        let mut d = doc();
        assert_eq!(d.add_layer().unwrap(), 1);
        assert_eq!(d.layers()[1].properties.name, "Layer 2");
        d.duplicate_layer().unwrap();
        assert_eq!(d.layers()[2].properties.name, "Layer 2");
        assert!(d.move_layer(false).unwrap());
        assert_eq!(d.active_layer_index(), 1);
        d.delete_layer().unwrap();
        assert_eq!(d.layers().len(), 2);
        assert_eq!(d.history_names().len(), 5);
        d.jump_to(0).unwrap();
        assert_eq!(d.layers().len(), 1);
        d.jump_to(4).unwrap();
        assert_eq!(d.layers().len(), 2);
        assert_eq!(d.active_layer_index(), 0);
        assert!(d.delete_layer().is_ok());
        assert_eq!(d.delete_layer(), Err(Error::LastLayer));
    }

    #[test]
    fn a_dragged_layer_moves_in_one_step_and_back() {
        let mut d = doc();
        d.add_layer().unwrap();
        d.add_layer().unwrap();
        let names = |d: &Document| -> Vec<String> {
            d.layers()
                .iter()
                .map(|l| l.properties.name.clone())
                .collect()
        };
        assert_eq!(names(&d), ["Background", "Layer 2", "Layer 3"]);
        assert!(d.move_layer_to(2, 0).unwrap());
        assert_eq!(names(&d), ["Layer 3", "Background", "Layer 2"]);
        assert_eq!(d.active_layer_index(), 0);
        assert_eq!(d.history_names().last().unwrap(), "Move Layer Down");
        assert!(!d.move_layer_to(1, 1).unwrap());
        assert!(d.move_layer_to(9, 0).is_err());
        d.undo().unwrap();
        assert_eq!(names(&d), ["Background", "Layer 2", "Layer 3"]);
        assert_eq!(d.active_layer_index(), 2);
        d.redo().unwrap();
        assert_eq!(names(&d), ["Layer 3", "Background", "Layer 2"]);
    }

    #[test]
    fn layer_properties_change_the_composite_and_hiding_moves_focus() {
        let mut d = doc();
        d.add_layer().unwrap();
        d.layers[1].surface.fill(Rgba8::opaque(0, 0, 255));
        assert_eq!(pixel(&d, 1, 1), Rgba8::opaque(0, 0, 255));
        let mut p = d.layers()[1].properties.clone();
        p.opacity = 128;
        p.blend_mode = BlendMode::Normal;
        d.set_layer_properties(1, p.clone()).unwrap();
        assert_eq!(pixel(&d, 1, 1), Rgba8::opaque(127, 127, 255));
        p.visible = false;
        d.set_layer_properties(1, p).unwrap();
        assert_eq!(d.active_layer_index(), 0);
        assert_eq!(d.history_names().last().unwrap(), "Layer Hidden");
        assert_eq!(pixel(&d, 1, 1), Rgba8::WHITE);
        d.undo().unwrap();
        assert_eq!(d.active_layer_index(), 1);
    }

    #[test]
    fn merge_down_blends_with_the_upper_mode_and_undoes() {
        let mut d = doc();
        d.add_layer().unwrap();
        d.layers[1].surface.fill(Rgba8::opaque(100, 200, 50));
        d.layers[1].properties.blend_mode = BlendMode::Multiply;
        d.layers[0].surface.fill(Rgba8::opaque(255, 128, 0));
        let expected = pixel(&d, 3, 3);
        d.merge_layer_down().unwrap();
        assert_eq!(d.layers().len(), 1);
        assert_eq!(pixel(&d, 3, 3), expected);
        d.undo().unwrap();
        assert_eq!(d.layers().len(), 2);
        assert_eq!(d.layers()[0].surface.at(3, 3), Rgba8::opaque(255, 128, 0));
        assert_eq!(d.merge_layer_down().map(|_| d.layers().len()), Ok(1));
        assert_eq!(d.merge_layer_down(), Err(Error::NoLayerBelow));
    }

    #[test]
    fn dirty_rect_collects_changes() {
        let mut d = doc();
        assert_eq!(d.take_dirty(), Some(d.bounds()));
        assert_eq!(d.take_dirty(), None);
        d.flip_layer(true).unwrap();
        assert_eq!(d.take_dirty(), Some(d.bounds()));
        // A white layer flipped is unchanged, so no step was recorded.
        assert_eq!(d.history_names().len(), 1);
    }

    #[test]
    fn colours_swap_and_belong_to_buttons() {
        let mut d = doc();
        d.swap_colors();
        assert_eq!(d.colors().primary, Rgba8::WHITE);
        assert_eq!(d.colors().for_button(Button::Secondary).0, Rgba8::BLACK);
    }
}
