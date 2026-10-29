//! Selection tools and the Edit menu's selection commands. Each change
//! of the selection is one history step.

use serde::{Deserialize, Serialize};

use crate::color::{lerp, Rgba8};
use crate::document::{Document, EditKind};
use crate::error::{Error, Result};
use crate::geom::PointF;
use crate::mask::{CombineMode, Mask};
use crate::selection::{self, Selection};
use crate::tools::{flood_stencil, FloodMode};

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub struct MagicWandSettings {
    pub mode: FloodMode,
    /// 0 – 1, typically 0.5.
    pub tolerance: f32,
}

impl Default for MagicWandSettings {
    fn default() -> Self {
        Self {
            mode: FloodMode::Local,
            tolerance: 0.5,
        }
    }
}

impl Document {
    /// Inside an open edit (`begin_edit`) the shape joins the selection
    /// the edit started from, so a drag in Union or Xor mode previews
    /// live and `commit_edit` records one step.
    fn combine_selection(&mut self, name: &str, shape: Mask, mode: CombineMode) -> Result<()> {
        if matches!(self.edit.as_ref().map(|e| &e.kind), Some(EditKind::Plain)) {
            self.restore_edit();
            self.selection.combine(&shape, mode);
            self.bump();
            return Ok(());
        }
        self.finish_pending()?;
        let before = self.selection.clone();
        self.selection.combine(&shape, mode);
        self.record_selection(name, before);
        self.bump();
        Ok(())
    }

    /// Rectangle Select from a drag (`geom::drag_box` makes it square
    /// for Shift).
    pub fn select_rectangle(&mut self, a: PointF, b: PointF, mode: CombineMode) -> Result<()> {
        let shape = selection::rectangle_mask(self.bounds(), a, b);
        self.combine_selection("Rectangle Select", shape, mode)
    }

    pub fn select_ellipse(&mut self, a: PointF, b: PointF, mode: CombineMode) -> Result<()> {
        let shape = selection::ellipse_mask(self.bounds(), a, b);
        self.combine_selection("Ellipse Select", shape, mode)
    }

    /// Lasso Select: the traced points, closed by a straight edge.
    pub fn select_lasso(&mut self, points: &[PointF], mode: CombineMode) -> Result<()> {
        if points.len() < 3 {
            return Err(Error::InvalidParameter("a lasso needs three points".into()));
        }
        let shape = selection::lasso_mask(self.bounds(), points);
        self.combine_selection("Lasso Select", shape, mode)
    }

    /// Magic Wand click on the active layer; `shift` swaps Local and
    /// Global.
    pub fn magic_wand(
        &mut self,
        at: PointF,
        settings: &MagicWandSettings,
        mode: CombineMode,
        shift: bool,
    ) -> Result<()> {
        if !(0.0..=1.0).contains(&settings.tolerance) {
            return Err(Error::InvalidParameter("tolerance is outside 0..=1".into()));
        }
        let contiguous = (settings.mode == FloodMode::Local) != shift;
        let everywhere = Selection::none(self.bounds());
        let shape = flood_stencil(
            &self.layers[self.active].surface,
            at.pixel(),
            settings.tolerance,
            contiguous,
            &everywhere,
        );
        self.combine_selection("Magic Wand", shape, mode)
    }

    /// Select All (Ctrl+A).
    pub fn select_all(&mut self) -> Result<()> {
        self.finish_pending()?;
        let before = self.selection.clone();
        self.selection = Selection::all(self.bounds());
        self.record_selection("Select All", before);
        self.bump();
        Ok(())
    }

    /// Deselect (Ctrl+D, Esc, Enter); nothing without a selection.
    pub fn deselect(&mut self) -> Result<()> {
        self.finish_pending()?;
        let before = self.selection.clone();
        self.selection = Selection::none(self.bounds());
        self.record_selection("Deselect", before);
        self.bump();
        Ok(())
    }

    /// Invert Selection (Ctrl+I); nothing without a selection.
    pub fn invert_selection(&mut self) -> Result<()> {
        self.finish_pending()?;
        if !self.selection.is_active() {
            return Ok(());
        }
        let before = self.selection.clone();
        self.selection.invert();
        self.record_selection("Invert Selection", before);
        self.bump();
        Ok(())
    }

    /// Erase Selection (Delete): the selected pixels become
    /// `(255, 255, 255, 0)` and the selection goes, in one step.
    pub fn erase_selection(&mut self) -> Result<()> {
        self.erase_selection_named("Erase Selection")
    }

    pub(crate) fn erase_selection_named(&mut self, name: &str) -> Result<()> {
        self.finish_pending()?;
        if !self.selection.is_active() {
            return Ok(());
        }
        let rect = self.selection.bounds();
        self.run_edit(name, |doc| {
            doc.paint_region(rect, |_, _| 255, |o, c, _, _| lerp(o, Rgba8::CLEARED, c))?;
            doc.selection = Selection::none(doc.bounds());
            Ok(())
        })
    }

    /// Fill Selection (Backspace): the selected pixels replaced by the
    /// primary colour.
    pub fn fill_selection(&mut self) -> Result<()> {
        self.finish_pending()?;
        if !self.selection.is_active() {
            return Ok(());
        }
        let rect = self.selection.bounds();
        let color = self.colors.primary;
        self.run_edit("Fill Selection", |doc| {
            doc.paint_region(rect, |_, _| 255, |o, c, _, _| lerp(o, color, c))
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::geom::Rect;

    fn doc() -> Document {
        Document::new(40, 30, Rgba8::WHITE).unwrap()
    }

    fn p(x: f32, y: f32) -> PointF {
        PointF::new(x, y)
    }

    #[test]
    fn rectangle_select_combines_by_mode() {
        let mut d = doc();
        d.select_rectangle(p(0.0, 0.0), p(10.0, 10.0), CombineMode::Replace)
            .unwrap();
        d.select_rectangle(p(5.0, 0.0), p(20.0, 10.0), CombineMode::Union)
            .unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(0, 0, 20, 10));
        d.select_rectangle(p(0.0, 0.0), p(10.0, 10.0), CombineMode::Exclude)
            .unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(10, 0, 10, 10));
        d.select_rectangle(p(15.0, 0.0), p(30.0, 10.0), CombineMode::Xor)
            .unwrap();
        assert_eq!(d.selection().coverage(16, 5), 0);
        assert_eq!(d.selection().coverage(25, 5), 255);
        d.select_rectangle(p(0.0, 0.0), p(12.0, 10.0), CombineMode::Intersect)
            .unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(10, 0, 2, 10));
        assert_eq!(d.history_names().len(), 6);
        d.undo().unwrap();
        assert_eq!(d.selection().coverage(25, 5), 255);
    }

    #[test]
    fn ellipse_and_lasso_have_hard_edges() {
        let mut d = doc();
        d.select_ellipse(p(0.0, 0.0), p(20.0, 20.0), CombineMode::Replace)
            .unwrap();
        assert_eq!(d.selection().coverage(10, 10), 255);
        assert_eq!(d.selection().coverage(0, 0), 0);
        assert!(d
            .selection()
            .mask()
            .data()
            .iter()
            .all(|&v| v == 0 || v == 255));
        d.select_lasso(
            &[p(0.0, 0.0), p(20.0, 0.0), p(0.0, 20.0)],
            CombineMode::Replace,
        )
        .unwrap();
        assert_eq!(d.selection().coverage(2, 2), 255);
        assert_eq!(d.selection().coverage(15, 15), 0);
    }

    #[test]
    fn magic_wand_selects_similar_colour() {
        let mut d = doc();
        for x in 0..40 {
            d.layers[0].surface.set(x, 15, Rgba8::BLACK);
        }
        d.magic_wand(
            p(5.5, 5.5),
            &MagicWandSettings::default(),
            CombineMode::Replace,
            false,
        )
        .unwrap();
        assert_eq!(d.selection().bounds(), Rect::new(0, 0, 40, 15));
        d.magic_wand(
            p(5.5, 5.5),
            &MagicWandSettings::default(),
            CombineMode::Replace,
            true,
        )
        .unwrap();
        assert_eq!(d.selection().coverage(5, 20), 255);
        assert_eq!(d.selection().coverage(5, 15), 0);
    }

    #[test]
    fn commands_need_a_selection_and_erase_deselects() {
        let mut d = doc();
        d.invert_selection().unwrap();
        d.erase_selection().unwrap();
        d.fill_selection().unwrap();
        d.deselect().unwrap();
        assert_eq!(d.history_names().len(), 1);
        d.select_rectangle(p(0.0, 0.0), p(4.0, 4.0), CombineMode::Replace)
            .unwrap();
        d.fill_selection().unwrap();
        assert_eq!(d.layers()[0].surface().at(1, 1), Rgba8::BLACK);
        d.erase_selection().unwrap();
        assert_eq!(d.layers()[0].surface().at(1, 1), Rgba8::CLEARED);
        assert!(!d.selection().is_active());
        d.undo().unwrap();
        assert!(d.selection().is_active());
        assert_eq!(d.layers()[0].surface().at(1, 1), Rgba8::BLACK);
        d.select_all().unwrap();
        d.invert_selection().unwrap();
        assert!(d.selection().mask().is_blank());
        assert!(d.selection().is_active());
    }
}
