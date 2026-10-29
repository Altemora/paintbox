//! Undo and redo. A step keeps only what changed: pixel edits as the
//! 64 × 64 tiles that differ (before and after), selections cropped to
//! their bounds, layers that were added or removed, properties. The
//! whole document is copied only by canvas-wide commands (resize,
//! crop, rotate), as Paint.NET does.

use crate::color::Rgba8;
use crate::geom::Rect;
use crate::layer::{Layer, LayerProperties};
use crate::selection::SelectionSnapshot;
use crate::surface::Surface;

pub(crate) const TILE: u32 = 64;
const TILE_SHIFT: u32 = 6;

/// The originals of the tiles an edit has touched so far, so the edit
/// can be previewed again from scratch, cancelled, or turned into a
/// step holding only the tiles that really changed.
#[derive(Debug, Clone)]
pub(crate) struct TileBackup {
    columns: u32,
    rows: u32,
    width: u32,
    height: u32,
    tiles: Vec<Option<Box<[Rgba8]>>>,
}

impl TileBackup {
    pub(crate) fn new(width: u32, height: u32) -> Self {
        let columns = width.div_ceil(TILE);
        let rows = height.div_ceil(TILE);
        Self {
            columns,
            rows,
            width,
            height,
            tiles: vec![None; (columns * rows) as usize],
        }
    }

    fn tile_rect(&self, column: u32, row: u32) -> Rect {
        let x = column * TILE;
        let y = row * TILE;
        Rect::new(
            x as i32,
            y as i32,
            TILE.min(self.width - x),
            TILE.min(self.height - y),
        )
    }

    /// Saves the original of every tile `rect` meets, once.
    pub(crate) fn touch(&mut self, surface: &Surface, rect: Rect) {
        let rect = rect.intersect(surface.bounds());
        if rect.is_empty() {
            return;
        }
        let c0 = rect.x as u32 >> TILE_SHIFT;
        let c1 = (rect.right() as u32 - 1) >> TILE_SHIFT;
        let r0 = rect.y as u32 >> TILE_SHIFT;
        let r1 = (rect.bottom() as u32 - 1) >> TILE_SHIFT;
        for row in r0..=r1 {
            for column in c0..=c1 {
                let i = (row * self.columns + column) as usize;
                if self.tiles[i].is_none() {
                    let pixels = surface.crop(self.tile_rect(column, row)).pixels().to_vec();
                    self.tiles[i] = Some(pixels.into_boxed_slice());
                }
            }
        }
    }

    /// The pixel as it was before the edit.
    #[inline]
    pub(crate) fn original(&self, surface: &Surface, x: i32, y: i32) -> Rgba8 {
        self.original_or(x, y, surface.at(x, y))
    }

    /// The pixel before the edit, or `current` if its tile was never
    /// touched (then it has not changed).
    #[inline]
    pub(crate) fn original_or(&self, x: i32, y: i32, current: Rgba8) -> Rgba8 {
        let column = x as u32 >> TILE_SHIFT;
        let row = y as u32 >> TILE_SHIFT;
        match &self.tiles[(row * self.columns + column) as usize] {
            Some(tile) => {
                let tw = TILE.min(self.width - column * TILE);
                tile[((y as u32 - row * TILE) * tw + (x as u32 - column * TILE)) as usize]
            }
            None => current,
        }
    }

    /// Puts every saved tile back; returns the area restored.
    pub(crate) fn restore(&self, surface: &mut Surface) -> Rect {
        let mut area = Rect::default();
        for row in 0..self.rows {
            for column in 0..self.columns {
                if let Some(tile) = &self.tiles[(row * self.columns + column) as usize] {
                    let rect = self.tile_rect(column, row);
                    surface.write_rect(rect, tile);
                    area = area.union(rect);
                }
            }
        }
        area
    }

    /// The touched tiles that differ from their originals.
    pub(crate) fn into_patch(self, layer: usize, surface: &Surface) -> Option<PixelPatch> {
        let mut tiles = Vec::new();
        let columns = self.columns;
        for (i, saved) in self.tiles.iter().enumerate() {
            let Some(before) = saved else {
                continue;
            };
            let rect = self.tile_rect(i as u32 % columns, i as u32 / columns);
            let after = surface.crop(rect).pixels().to_vec();
            if after[..] != before[..] {
                tiles.push((rect, i, after));
            }
        }
        let mut saved = self.tiles;
        let tiles: Vec<TilePatch> = tiles
            .into_iter()
            .filter_map(|(rect, i, after)| {
                let before = saved[i].take()?.into_vec();
                Some(TilePatch {
                    rect,
                    before,
                    after,
                })
            })
            .collect();
        (!tiles.is_empty()).then_some(PixelPatch { layer, tiles })
    }
}

#[derive(Debug, Clone)]
pub(crate) struct TilePatch {
    rect: Rect,
    before: Vec<Rgba8>,
    after: Vec<Rgba8>,
}

#[derive(Debug, Clone)]
pub(crate) struct PixelPatch {
    pub(crate) layer: usize,
    tiles: Vec<TilePatch>,
}

impl PixelPatch {
    /// Writes the before (`undo`) or after pixels; returns the area.
    pub(crate) fn apply(&self, surface: &mut Surface, undo: bool) -> Rect {
        let mut area = Rect::default();
        for tile in &self.tiles {
            let pixels = if undo { &tile.before } else { &tile.after };
            surface.write_rect(tile.rect, pixels);
            area = area.union(tile.rect);
        }
        area
    }

    fn bytes(&self) -> usize {
        self.tiles
            .iter()
            .map(|t| (t.before.len() + t.after.len()) * 4)
            .sum()
    }
}

/// Everything canvas-wide commands replace at once.
#[derive(Debug, Clone)]
pub(crate) struct CanvasState {
    pub(crate) width: u32,
    pub(crate) height: u32,
    pub(crate) layers: Vec<Layer>,
    pub(crate) selection: SelectionSnapshot,
}

#[derive(Debug, Clone)]
pub(crate) enum Change {
    Pixels(PixelPatch),
    Selection {
        before: SelectionSnapshot,
        after: SelectionSnapshot,
    },
    LayerInserted {
        index: usize,
        layer: Layer,
    },
    LayerRemoved {
        index: usize,
        layer: Layer,
    },
    LayerMoved {
        from: usize,
        to: usize,
    },
    LayerProperties {
        index: usize,
        before: LayerProperties,
        after: LayerProperties,
    },
    Canvas {
        before: Box<CanvasState>,
        after: Box<CanvasState>,
    },
}

impl Change {
    fn bytes(&self) -> usize {
        match self {
            Change::Pixels(patch) => patch.bytes(),
            Change::Selection { before, after } => before.bytes() + after.bytes(),
            Change::LayerInserted { layer, .. } | Change::LayerRemoved { layer, .. } => {
                layer.surface.pixels().len() * 4
            }
            Change::LayerMoved { .. } | Change::LayerProperties { .. } => 0,
            Change::Canvas { before, after } => [before, after]
                .iter()
                .map(|s| {
                    s.layers
                        .iter()
                        .map(|l| l.surface.pixels().len() * 4)
                        .sum::<usize>()
                })
                .sum(),
        }
    }
}

#[derive(Debug, Clone)]
pub(crate) struct Step {
    pub(crate) name: String,
    pub(crate) changes: Vec<Change>,
    pub(crate) active_before: usize,
    pub(crate) active_after: usize,
    /// Unique within the document, set by `History::push`.
    pub(crate) id: u64,
}

/// The steps and how many of them are applied. Entry 0 is the
/// document's origin ("New Image", "Open Image"), which cannot be
/// undone.
#[derive(Debug, Clone)]
pub(crate) struct History {
    origin: String,
    steps: Vec<Step>,
    applied: usize,
    next_id: u64,
    /// What the steps hold, kept as they come and go.
    bytes: usize,
    limit: usize,
    evicted: usize,
    /// The id of the newest dropped step: what position 0 now stands for.
    base_id: u64,
}

/// The default history budget: 1 GiB, eight whole-layer steps of a
/// 4096 × 4096 image (each keeps 64 MiB before and 64 MiB after).
pub const DEFAULT_HISTORY_LIMIT: usize = 1 << 30;

fn step_bytes(step: &Step) -> usize {
    step.changes.iter().map(Change::bytes).sum()
}

impl History {
    pub(crate) fn new(origin: impl Into<String>) -> Self {
        Self {
            origin: origin.into(),
            steps: Vec::new(),
            applied: 0,
            next_id: 1,
            bytes: 0,
            limit: DEFAULT_HISTORY_LIMIT,
            evicted: 0,
            base_id: 0,
        }
    }

    /// Records a step and drops anything that had been undone.
    pub(crate) fn push(&mut self, mut step: Step) {
        step.id = self.next_id;
        self.next_id += 1;
        for undone in self.steps.drain(self.applied..) {
            self.bytes -= step_bytes(&undone);
        }
        self.bytes += step_bytes(&step);
        self.steps.push(step);
        self.applied = self.steps.len();
        self.evict();
    }

    pub(crate) fn can_undo(&self) -> bool {
        self.applied > 0
    }

    pub(crate) fn can_redo(&self) -> bool {
        self.applied < self.steps.len()
    }

    /// The step to undo next; the caller applies it.
    pub(crate) fn undo_step(&mut self) -> Option<&Step> {
        if self.applied == 0 {
            return None;
        }
        self.applied -= 1;
        self.steps.get(self.applied)
    }

    pub(crate) fn redo_step(&mut self) -> Option<&Step> {
        let step = self.steps.get(self.applied)?;
        self.applied += 1;
        Some(step)
    }

    /// Names for the History window: the origin, then every step.
    pub(crate) fn names(&self) -> Vec<String> {
        std::iter::once(self.origin.clone())
            .chain(self.steps.iter().map(|s| s.name.clone()))
            .collect()
    }

    /// The History window's current entry: 0 is the origin.
    pub(crate) fn position(&self) -> usize {
        self.applied
    }

    /// Identifies the state the applied steps produce: the id of the
    /// last applied step, 0 at the origin.
    pub(crate) fn state_id(&self) -> u64 {
        match self.applied {
            0 => self.base_id,
            n => self.steps[n - 1].id,
        }
    }

    pub(crate) fn bytes(&self) -> usize {
        self.bytes
    }

    pub(crate) fn limit(&self) -> usize {
        self.limit
    }

    pub(crate) fn set_limit(&mut self, limit: usize) {
        self.limit = limit;
        self.evict();
    }

    /// Drops the oldest steps while the history holds more than its
    /// limit; the newest step always stays, so the last action can be
    /// undone however large. The dropped steps become part of the
    /// origin: the History window starts after them.
    fn evict(&mut self) {
        let mut dropped = 0;
        while self.bytes > self.limit && dropped + 1 < self.applied {
            self.bytes -= step_bytes(&self.steps[dropped]);
            dropped += 1;
        }
        if dropped > 0 {
            self.base_id = self.steps[dropped - 1].id;
            self.steps.drain(..dropped);
            self.applied -= dropped;
            self.evicted += dropped;
        }
    }

    /// Steps dropped by the limit since the document began.
    pub(crate) fn evicted(&self) -> usize {
        self.evicted
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_patch_keeps_only_tiles_that_changed() {
        let mut surface = Surface::new(200, 100).unwrap();
        let mut backup = TileBackup::new(200, 100);
        backup.touch(&surface, Rect::new(0, 0, 200, 100));
        surface.set(130, 70, Rgba8::WHITE);
        assert_eq!(backup.original(&surface, 130, 70), Rgba8::TRANSPARENT);
        let patch = backup.into_patch(0, &surface).unwrap();
        assert_eq!(patch.tiles.len(), 1);
        assert_eq!(patch.tiles[0].rect, Rect::new(128, 64, 64, 36));
        let mut copy = surface.clone();
        patch.apply(&mut copy, true);
        assert_eq!(copy.at(130, 70), Rgba8::TRANSPARENT);
        patch.apply(&mut copy, false);
        assert_eq!(copy, surface);
    }

    #[test]
    fn restore_brings_back_the_originals() {
        let mut surface = Surface::filled(70, 70, Rgba8::BLACK).unwrap();
        let original = surface.clone();
        let mut backup = TileBackup::new(70, 70);
        backup.touch(&surface, Rect::new(60, 60, 5, 5));
        surface.set(62, 62, Rgba8::WHITE);
        // 60..65 crosses the tile edge at 64, so four tiles were saved.
        assert_eq!(backup.restore(&mut surface), Rect::of_size(70, 70));
        assert_eq!(surface, original);
    }

    #[test]
    fn the_limit_drops_the_oldest_steps_but_never_the_newest() {
        let step = |name: &str, pixels: usize| Step {
            name: name.into(),
            changes: vec![Change::LayerInserted {
                index: 0,

                layer: Layer::transparent("x", pixels as u32, 1).unwrap(),
            }],
            active_before: 0,
            active_after: 0,
            id: 0,
        };
        let mut history = History::new("New Image");
        history.set_limit(1000);
        history.push(step("a", 100));
        history.push(step("b", 100));
        assert_eq!(history.bytes(), 800);
        history.push(step("c", 100));
        assert_eq!(history.names(), ["New Image", "b", "c"]);
        assert_eq!(
            (history.bytes(), history.evicted(), history.position()),
            (800, 1, 2)
        );
        // A step larger than the whole budget still stays, alone.
        history.push(step("huge", 1000));
        assert_eq!(history.names(), ["New Image", "huge"]);
        // Position 0 is now the state after the dropped steps.
        let after_c = history.steps[0].id - 1;
        history.undo_step();
        assert_eq!(history.state_id(), after_c);
        assert_ne!(history.state_id(), 0);
        // Pushing after an undo releases the undone step's memory.
        history.push(step("d", 10));
        assert_eq!(history.bytes(), 40);
    }

    #[test]
    fn pushing_after_undo_drops_the_redo_branch() {
        let step = |name: &str| Step {
            name: name.into(),
            changes: Vec::new(),
            active_before: 0,
            active_after: 0,
            id: 0,
        };
        let mut history = History::new("New Image");
        history.push(step("a"));
        history.push(step("b"));
        assert_eq!(history.undo_step().unwrap().name, "b");
        assert!(history.can_redo());
        history.push(step("c"));
        assert!(!history.can_redo());
        assert_eq!(history.names(), ["New Image", "a", "c"]);
        assert_eq!(history.position(), 2);
    }
}
