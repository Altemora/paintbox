//! Pointer gestures of the document tools turned into core calls, with
//! no UI toolkit in sight: a shell feeds presses, moves and releases in
//! image coordinates, then [`Controller::flush`] once a frame redraws
//! previews (selection drags, shapes, live gradient and curve, moves).
//! Strokes go to the core on every move so no pointer sample is lost.

use crate::document::{Button, Document, UserColors};
use crate::error::Result;
use crate::geom::{constrain_angle, drag_box, PointF, Rect};
use crate::image_ops::Resampling;
use crate::mask::CombineMode;
use crate::tool::{PickerAfter, SelectDraw, Tool, ToolSettings};
use crate::tools::{Curve, LiftTransform, Shape, HANDLE_SIDES};
use crate::typing::{LiveText, TextKey};

#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Mods {
    pub ctrl: bool,
    pub alt: bool,
    pub shift: bool,
}

#[derive(Debug, Clone, Copy)]
pub struct Pointer {
    pub pos: PointF,
    pub button: Button,
    pub mods: Mods,
    /// Seconds, for the quick-click rule of selections.
    pub time: f64,
}

/// What the app should do after a gesture.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Outcome {
    Nothing,
    SwitchTool(Tool),
    PreviousTool,
}

/// A selection drag shorter than this deselects, as a click does.
const QUICK_CLICK: f64 = 0.05;
const ROUNDED_RADIUS: f32 = 10.0;

struct SelectDrag {
    tool: Tool,
    mode: CombineMode,
    button: Button,
    start: PointF,
    end: PointF,
    points: Vec<PointF>,
    started: f64,
    moved: bool,
    mods: Mods,
    /// The other button held: the whole shape follows it.
    other: Option<PointF>,
}

struct ShapeDrag {
    tool: Tool,
    button: Button,
    start: PointF,
    end: PointF,
    points: Vec<PointF>,
    moved: bool,
    shift: bool,
    other: Option<PointF>,
}

/// A gradient after (and while) it is drawn: two handles.
struct LiveGradient {
    points: [PointF; 2],
    button: Button,
    drag: Option<usize>,
    creating: bool,
    shift: bool,
    other: Option<PointF>,
    last: PointF,
}

/// A line after it is drawn: its ends and two control points.
struct LiveLine {
    points: [PointF; 4],
    curve: Curve,
    button: Button,
    drag: Option<usize>,
    creating: bool,
    shift: bool,
    other: Option<PointF>,
    /// The pointer, for re-applying Shift when it changes alone.
    last: PointF,
}

/// What a Move Selected Pixels drag does: the left button moves, the
/// right turns about the centre (Shift: by 15°), a handle scales with
/// the opposite side fixed (Shift: in proportion).
#[derive(Clone, Copy)]
enum MoveMode {
    Translate,
    Turn { centre: PointF },
    Scale { side: (f32, f32), half: (f32, f32) },
}

#[derive(Clone, Copy)]
struct MoveDrag {
    press: PointF,
    base: LiftTransform,
    /// Where the drag has the pixels; the document follows at `flush`.
    now: LiftTransform,
    mode: MoveMode,
    shift: bool,
    last: PointF,
    resampling: Resampling,
    centre_at_press: PointF,
}

impl MoveDrag {
    fn follow(&mut self, pos: PointF) {
        self.last = pos;
        let b = self.base;
        match self.mode {
            MoveMode::Translate => {
                self.now.offset = add(b.offset, offset(self.press, pos));
            }
            MoveMode::Turn { centre } => {
                let angle = |p: PointF| (p.y - centre.y).atan2(p.x - centre.x);
                let mut turn = b.turn + angle(pos) - angle(self.press);
                if self.shift {
                    let step = std::f32::consts::PI / 12.0;
                    turn = (turn / step).round() * step;
                }
                self.now.turn = turn;
            }
            MoveMode::Scale { side, half } => {
                let (sin, cos) = b.turn.sin_cos();
                let centre = self.press_centre();
                let (dx, dy) = (pos.x - centre.x, pos.y - centre.y);
                // The pointer in the fragment's own frame, about its centre.
                let l = (dx * cos + dy * sin, -dx * sin + dy * cos);
                let anchor = (-side.0 * half.0 * b.scale.0, -side.1 * half.1 * b.scale.1);
                let axis = |s: f32, l: f32, a: f32, h: f32, old: f32| {
                    if s == 0.0 {
                        old
                    } else {
                        (l - a) * s / (2.0 * h)
                    }
                };
                let mut sx = axis(side.0, l.0, anchor.0, half.0, b.scale.0);
                let mut sy = axis(side.1, l.1, anchor.1, half.1, b.scale.1);
                if self.shift && side.0 != 0.0 && side.1 != 0.0 {
                    let k = (sx / b.scale.0).abs().max((sy / b.scale.1).abs());
                    sx = b.scale.0.abs() * k * sx.signum();
                    sy = b.scale.1.abs() * k * sy.signum();
                }
                // The opposite side stays: the centre moves half the growth.
                let cx = if side.0 == 0.0 {
                    0.0
                } else {
                    anchor.0 + side.0 * sx * half.0
                };
                let cy = if side.1 == 0.0 {
                    0.0
                } else {
                    anchor.1 + side.1 * sy * half.1
                };
                let (wx, wy) = (cx * cos - cy * sin, cx * sin + cy * cos);
                self.now.scale = (sx, sy);
                self.now.offset = add(b.offset, (wx.round() as i32, wy.round() as i32));
            }
        }
    }

    /// The fragment's centre on the image when the drag began.
    fn press_centre(&self) -> PointF {
        match self.mode {
            MoveMode::Turn { centre } => centre,
            _ => self.centre_at_press,
        }
    }
}

enum State {
    Idle,
    Stroke,
    Select(SelectDrag),
    Shape(ShapeDrag),
    Gradient(LiveGradient),
    Line(LiveLine),
    MovePixels(MoveDrag),
    MoveSelection {
        press: PointF,
        base: (i32, i32),
    },
    Picker,
    /// Recolor with Ctrl held: picks while dragging.
    RecolorPick(Button),
    Text(Box<LiveText>),
}

/// Handles and guides to draw over the canvas.
#[derive(Debug, Default, Clone)]
pub struct Overlay {
    pub handles: Vec<PointF>,
    /// A thin guide (the gradient's direction, a curve's control polygon).
    pub guide: Vec<PointF>,
}

pub struct Controller {
    state: State,
    dirty: bool,
    drawn_with: Option<(ToolSettings, UserColors)>,
    move_selection_open: bool,
    selection_offset: (i32, i32),
    /// How near a handle a press must be, in image pixels.
    pub handle_radius: f32,
}

impl Default for Controller {
    fn default() -> Self {
        Self {
            state: State::Idle,
            dirty: false,
            drawn_with: None,
            move_selection_open: false,
            selection_offset: (0, 0),
            handle_radius: 5.0,
        }
    }
}

fn offset(from: PointF, to: PointF) -> (i32, i32) {
    (
        (to.x - from.x).round() as i32,
        (to.y - from.y).round() as i32,
    )
}

fn add(a: (i32, i32), b: (i32, i32)) -> (i32, i32) {
    (a.0.saturating_add(b.0), a.1.saturating_add(b.1))
}

impl Controller {
    /// Forgets gestures the document no longer has open (an undo, a
    /// command that committed the edit).
    pub fn sync(&mut self, doc: &Document) {
        if doc.is_editing() {
            return;
        }
        if matches!(&self.state, State::Text(t) if t.editing) {
            self.state = State::Idle;
        }
        if matches!(
            self.state,
            State::Gradient(_)
                | State::Line(_)
                | State::Select(_)
                | State::Shape(_)
                | State::MoveSelection { .. }
                | State::Stroke
        ) {
            self.state = State::Idle;
        }
        self.move_selection_open = false;
    }

    /// The move in progress, for drawing the outline shifted.
    /// None for turned or scaled pixels: their outline is not a shift of
    /// the one they were lifted with, so the shell reads it afresh.
    pub fn move_offset(&self, doc: &Document) -> Option<(i32, i32)> {
        let plain = |t: &LiftTransform| t.turn == 0.0 && t.scale == (1.0, 1.0);
        if let State::MovePixels(m) = &self.state {
            plain(&m.now).then_some(m.now.offset)
        } else if let Some(t) = doc.lift_transform() {
            plain(&t).then_some(t.offset)
        } else if self.move_selection_open && doc.is_editing() {
            Some(self.selection_offset)
        } else {
            None
        }
    }

    pub fn overlay(&self) -> Overlay {
        match &self.state {
            State::Gradient(g) => Overlay {
                handles: g.points.to_vec(),
                guide: g.points.to_vec(),
            },
            State::Line(l) if !l.creating || l.drag.is_none() => Overlay {
                handles: l.points.to_vec(),
                guide: if l.curve == Curve::Bezier {
                    l.points.to_vec()
                } else {
                    Vec::new()
                },
            },
            State::Text(t) => Overlay {
                handles: vec![t.handle()],
                guide: t.caret.map_or_else(Vec::new, |(a, b)| vec![a, b]),
            },
            _ => Overlay::default(),
        }
    }

    /// Whether the Text tool has a caret: keys type into it.
    pub fn is_typing(&self) -> bool {
        matches!(self.state, State::Text(_))
    }

    /// Typed characters at the caret (the first opens the edit, one step).
    pub fn type_text(
        &mut self,
        doc: &mut Document,
        settings: &ToolSettings,
        text: &str,
    ) -> Result<bool> {
        let State::Text(t) = &mut self.state else {
            return Ok(false);
        };
        let before = (t.lines.clone(), t.line, t.col);
        if !t.insert(text) {
            return Ok(false);
        }
        if !t.editing {
            doc.begin_edit(Tool::Text.name())?;
            t.editing = true;
        }
        self.redraw_text(doc, settings, before)?;
        Ok(true)
    }

    /// A key of the text being typed; false when not typing.
    pub fn text_key(
        &mut self,
        doc: &mut Document,
        settings: &ToolSettings,
        key: TextKey,
        ctrl: bool,
    ) -> Result<bool> {
        let State::Text(t) = &mut self.state else {
            return Ok(false);
        };
        let before = (t.lines.clone(), t.line, t.col);
        let changed = t.key(key, ctrl);
        if changed && !t.editing {
            doc.begin_edit(Tool::Text.name())?;
            t.editing = true;
        }
        self.redraw_text(doc, settings, before)?;
        Ok(true)
    }

    /// Draws the text after a change; when it cannot be drawn (too large)
    /// the change is taken back, so the text and the picture agree.
    fn redraw_text(
        &mut self,
        doc: &mut Document,
        settings: &ToolSettings,
        before: (Vec<String>, usize, usize),
    ) -> Result<()> {
        self.dirty = true;
        let drawn = self.flush(doc, settings);
        if drawn.is_err() {
            if let State::Text(t) = &mut self.state {
                (t.lines, t.line, t.col) = before;
                // The old text drew before, so it draws again.
                let _redrawn = t.draw(doc, settings);
            }
        }
        drawn
    }

    fn hit(&self, points: &[PointF], at: PointF) -> Option<usize> {
        points
            .iter()
            .enumerate()
            .map(|(i, p)| (i, p.distance(at)))
            .filter(|&(_, d)| d <= self.handle_radius)
            .min_by(|a, b| a.1.total_cmp(&b.1))
            .map(|(i, _)| i)
    }

    // ---- pointer -----------------------------------------------------

    pub fn press(
        &mut self,
        doc: &mut Document,
        tool: Tool,
        settings: &ToolSettings,
        p: Pointer,
    ) -> Result<Outcome> {
        let pos = p.pos;
        match tool {
            Tool::Paintbrush | Tool::Eraser | Tool::Pencil => {
                self.begin_stroke(doc, tool, settings, p)?
            }
            Tool::CloneStamp => {
                // Only the left button, and Ctrl alone sets the source.
                if p.button == Button::Primary {
                    if p.mods.ctrl && !p.mods.alt && !p.mods.shift {
                        doc.set_clone_source(pos);
                    } else {
                        self.begin_stroke(doc, tool, settings, p)?;
                    }
                }
            }
            Tool::Recolor => {
                if p.mods.ctrl {
                    pick_keeping_alpha(doc, pos, p.button);
                    self.state = State::RecolorPick(p.button);
                } else {
                    self.begin_stroke(doc, tool, settings, p)?;
                }
            }
            Tool::RectangleSelect | Tool::EllipseSelect | Tool::LassoSelect => {
                doc.begin_edit(tool.name())?;
                self.state = State::Select(SelectDrag {
                    tool,
                    // Fixed at the press, as in the source: Ctrl or Alt
                    // pressed later does not change it.
                    mode: CombineMode::for_gesture(
                        settings.selection_mode,
                        p.button,
                        p.mods.ctrl,
                        p.mods.alt,
                    ),
                    button: p.button,
                    start: pos,
                    end: pos,
                    points: vec![pos],
                    started: p.time,
                    moved: false,
                    mods: p.mods,
                    other: None,
                });
                if tool == Tool::RectangleSelect && settings.select_draw == SelectDraw::FixedSize {
                    self.dirty = true;
                }
            }
            Tool::MagicWand => {
                let mode = CombineMode::for_gesture(
                    settings.selection_mode,
                    p.button,
                    p.mods.ctrl,
                    p.mods.alt,
                );
                doc.magic_wand(pos, &settings.wand(), mode, p.mods.shift)?;
            }
            Tool::PaintBucket => doc.fill(pos, &settings.fill(), p.button, p.mods.shift)?,
            Tool::ColorPicker => {
                doc.pick_color_into(pos, p.button);
                self.state = State::Picker;
            }
            Tool::Gradient => {
                let live = match &self.state {
                    State::Gradient(g) => Some(g.points),
                    _ => None,
                };
                if let Some(points) = live {
                    let hit = self.hit(&points, pos);
                    if let (Some(i), State::Gradient(g)) = (hit, &mut self.state) {
                        g.drag = Some(i);
                        g.shift = p.mods.shift;
                        if p.button == Button::Secondary {
                            // A right press on a handle swaps the colours.
                            g.button = match g.button {
                                Button::Primary => Button::Secondary,
                                Button::Secondary => Button::Primary,
                            };
                            self.dirty = true;
                        }
                        return Ok(Outcome::Nothing);
                    }
                    doc.commit_edit()?;
                }
                doc.begin_edit("Gradient")?;
                self.state = State::Gradient(LiveGradient {
                    points: [pos, pos],
                    button: p.button,
                    drag: Some(1),
                    creating: true,
                    shift: p.mods.shift,
                    other: None,
                    last: pos,
                });
                // A click without a drag paints too: the whole area takes
                // the end value.
                self.dirty = true;
            }
            Tool::LineCurve => {
                let live = match &self.state {
                    State::Line(l) => Some(l.points),
                    _ => None,
                };
                if let Some(points) = live {
                    let hit = self.hit(&points, pos);
                    if let (Some(i), State::Line(l)) = (hit, &mut self.state) {
                        l.drag = Some(i);
                        l.shift = p.mods.shift;
                        if l.curve == Curve::Straight {
                            // The first bend fixes the kind: left a spline, right a Bézier.
                            l.curve = if p.button == Button::Primary {
                                Curve::Spline
                            } else {
                                Curve::Bezier
                            };
                        }
                        return Ok(Outcome::Nothing);
                    }
                    doc.commit_edit()?;
                }
                doc.begin_edit(Tool::LineCurve.name())?;
                self.state = State::Line(LiveLine {
                    points: [pos; 4],
                    curve: Curve::Straight,
                    button: p.button,
                    drag: Some(3),
                    creating: true,
                    shift: p.mods.shift,
                    other: None,
                    last: pos,
                });
            }
            Tool::Rectangle | Tool::RoundedRectangle | Tool::Ellipse | Tool::FreeformShape => {
                doc.begin_edit(tool.name())?;
                self.state = State::Shape(ShapeDrag {
                    tool,
                    button: p.button,
                    start: pos,
                    end: pos,
                    points: vec![pos],
                    moved: false,
                    shift: p.mods.shift,
                    other: None,
                });
            }
            Tool::MoveSelectedPixels => {
                // A handle is grabbed only on pixels already lifted.
                let grabbed = if p.button == Button::Primary {
                    self.hit(&doc.lift_handles(), pos)
                } else {
                    None
                };
                self.lift(doc, p.mods.ctrl)?;
                let base = doc.lift_transform().unwrap_or(LiftTransform {
                    offset: (0, 0),
                    turn: 0.0,
                    scale: (1.0, 1.0),
                });
                let (centre, size) = doc.lift_frame().unwrap_or((pos, (1.0, 1.0)));
                let mode = match (p.button, grabbed) {
                    (Button::Secondary, _) => MoveMode::Turn { centre },
                    (_, Some(i)) => MoveMode::Scale {
                        side: HANDLE_SIDES[i],
                        half: (size.0 / 2.0, size.1 / 2.0),
                    },
                    _ => MoveMode::Translate,
                };
                self.state = State::MovePixels(MoveDrag {
                    press: pos,
                    base,
                    now: base,
                    mode,
                    shift: p.mods.shift,
                    last: pos,
                    resampling: settings.resampling,
                    centre_at_press: centre,
                });
            }
            Tool::MoveSelection => {
                if p.button != Button::Primary {
                    return Ok(Outcome::Nothing);
                }
                self.open_move_selection(doc)?;
                self.state = State::MoveSelection {
                    press: pos,
                    base: self.selection_offset,
                };
            }
            Tool::Text => self.press_text(doc, settings, p)?,
            Tool::Zoom | Tool::Pan => {}
        }
        Ok(Outcome::Nothing)
    }

    /// Text: the right button or the handle drags the live text, a click
    /// in it moves the caret, a click elsewhere commits it and starts anew.
    fn press_text(
        &mut self,
        doc: &mut Document,
        settings: &ToolSettings,
        p: Pointer,
    ) -> Result<()> {
        let radius = self.handle_radius;
        if let State::Text(t) = &mut self.state {
            if p.button == Button::Secondary || t.handle().distance(p.pos) <= radius {
                t.drag = Some((p.pos, t.origin));
                return Ok(());
            }
            if t.contains(p.pos, radius) {
                if let Some(l) = &t.layout {
                    (t.line, t.col) = l.position_at(p.pos);
                }
                self.dirty = true;
                return self.flush(doc, settings);
            }
        }
        if p.button != Button::Primary {
            return Ok(());
        }
        self.finish(doc)?;
        self.state = State::Text(Box::new(LiveText::at(p.pos)));
        self.dirty = true;
        self.flush(doc, settings)
    }

    fn begin_stroke(
        &mut self,
        doc: &mut Document,
        tool: Tool,
        settings: &ToolSettings,
        p: Pointer,
    ) -> Result<()> {
        if let Some(stroke) = settings.stroke(tool) {
            if doc.begin_stroke(stroke, p.button, p.pos)? {
                self.state = State::Stroke;
            }
        }
        Ok(())
    }

    /// Lifts the selected pixels unless already lifted (Ctrl copies;
    /// it counts only here, at the lift). Without a selection the whole
    /// canvas is selected first, a step of its own as in the source.
    fn lift(&mut self, doc: &mut Document, copy: bool) -> Result<()> {
        if !doc.is_lifted() {
            if !doc.selection().is_active() {
                doc.select_all()?;
            }
            doc.lift_selection(copy)?;
        }
        Ok(())
    }

    fn open_move_selection(&mut self, doc: &mut Document) -> Result<()> {
        if !(self.move_selection_open && doc.is_editing()) {
            if !doc.selection().is_active() {
                doc.select_all()?;
            }
            doc.begin_move_selection()?;
            self.move_selection_open = true;
            self.selection_offset = (0, 0);
        }
        Ok(())
    }

    pub fn motion(&mut self, doc: &mut Document, pos: PointF) -> Result<()> {
        // The other button held: the whole shape follows the pointer.
        let moved_by = |other: &mut Option<PointF>| {
            other.map(|last| {
                *other = Some(pos);
                (pos.x - last.x, pos.y - last.y)
            })
        };
        let shift = |q: &mut PointF, (dx, dy): (f32, f32)| *q = PointF::new(q.x + dx, q.y + dy);
        match &mut self.state {
            State::Stroke => doc.stroke_to(pos)?,
            State::Select(s) => {
                if let Some(d) = moved_by(&mut s.other) {
                    shift(&mut s.start, d);
                    shift(&mut s.end, d);
                    s.points.iter_mut().for_each(|q| shift(q, d));
                } else {
                    s.end = pos;
                    if s.tool == Tool::LassoSelect && s.points.last() != Some(&pos) {
                        s.points.push(pos);
                    }
                }
                s.moved = true;
                self.dirty = true;
            }
            State::Shape(s) => {
                if let Some(d) = moved_by(&mut s.other) {
                    shift(&mut s.start, d);
                    shift(&mut s.end, d);
                    s.points.iter_mut().for_each(|q| shift(q, d));
                } else {
                    s.end = pos;
                    if s.tool == Tool::FreeformShape && s.points.last() != Some(&pos) {
                        s.points.push(pos);
                    }
                }
                s.moved |= s.start.distance(s.end) >= 1.0;
                self.dirty = true;
            }
            State::Gradient(g) => {
                if let Some(d) = moved_by(&mut g.other) {
                    g.points.iter_mut().for_each(|q| shift(q, d));
                    self.dirty = true;
                } else if let Some(i) = g.drag {
                    g.last = pos;
                    let other = g.points[1 - i];
                    g.points[i] = if g.shift {
                        constrain_angle(other, pos)
                    } else {
                        pos
                    };
                    self.dirty = true;
                }
            }
            State::Line(l) => {
                if let Some(d) = moved_by(&mut l.other) {
                    l.points.iter_mut().for_each(|q| shift(q, d));
                    self.dirty = true;
                } else if let Some(i) = l.drag {
                    l.last = pos;
                    if l.creating {
                        let end = if l.shift {
                            constrain_angle(l.points[0], pos)
                        } else {
                            pos
                        };
                        let start = l.points[0];
                        l.points = [
                            start,
                            start.lerp(end, 1.0 / 3.0),
                            start.lerp(end, 2.0 / 3.0),
                            end,
                        ];
                    } else {
                        l.points[i] = pos;
                    }
                    self.dirty = true;
                }
            }
            State::MovePixels(m) => {
                m.follow(pos);
                self.dirty = true;
            }
            State::MoveSelection { press, base } => {
                self.selection_offset = add(*base, offset(*press, pos));
                self.dirty = true;
            }
            State::RecolorPick(button) => pick_keeping_alpha(doc, pos, *button),
            State::Text(t) => {
                if let Some((press, from)) = t.drag {
                    t.origin = PointF::new(from.x + pos.x - press.x, from.y + pos.y - press.y);
                    self.dirty = true;
                }
            }
            // The picker samples in `picker_motion`, which knows the button.
            State::Picker | State::Idle => {}
        }
        Ok(())
    }

    /// Picker drags sample with the pressed button.
    pub fn picker_motion(&mut self, doc: &mut Document, pos: PointF, button: Button) {
        if matches!(self.state, State::Picker) {
            doc.pick_color_into(pos, button);
        }
    }

    /// The other mouse button during a selection, shape, gradient or
    /// line drag moves the whole shape while it is held.
    pub fn other_button(&mut self, pressed: bool, pos: PointF) {
        let other = pressed.then_some(pos);
        match &mut self.state {
            State::Select(s) => s.other = other,
            State::Shape(s) => s.other = other,
            State::Gradient(g) if g.drag.is_some() => g.other = other,
            State::Line(l) if l.drag.is_some() => l.other = other,
            _ => {}
        }
    }

    /// Shift pressed or released mid-drag: squares, circles and 15°
    /// steps follow at once. (Ctrl and Alt fix the selection mode only
    /// at the press.)
    pub fn modifiers(&mut self, mods: Mods) {
        match &mut self.state {
            State::Select(s) if s.mods.shift != mods.shift => {
                s.mods = mods;
                self.dirty = true;
            }
            State::Shape(s) if s.shift != mods.shift => {
                s.shift = mods.shift;
                self.dirty = true;
            }
            State::Gradient(g) if g.drag.is_some() && g.shift != mods.shift => {
                g.shift = mods.shift;
                let i = g.drag.unwrap_or(1);
                let other = g.points[1 - i];
                g.points[i] = if g.shift {
                    constrain_angle(other, g.last)
                } else {
                    g.last
                };
                self.dirty = true;
            }
            State::MovePixels(m) if m.shift != mods.shift => {
                m.shift = mods.shift;
                let last = m.last;
                m.follow(last);
                self.dirty = true;
            }
            State::Line(l) if l.creating && l.shift != mods.shift => {
                l.shift = mods.shift;
                let end = if l.shift {
                    constrain_angle(l.points[0], l.last)
                } else {
                    l.last
                };
                let start = l.points[0];
                l.points = [
                    start,
                    start.lerp(end, 1.0 / 3.0),
                    start.lerp(end, 2.0 / 3.0),
                    end,
                ];
                self.dirty = true;
            }
            _ => {}
        }
    }

    pub fn release(
        &mut self,
        doc: &mut Document,
        settings: &ToolSettings,
        p: Pointer,
    ) -> Result<Outcome> {
        if p.button != Button::Primary
            && matches!(
                self.state,
                State::Select(SelectDrag {
                    button: Button::Primary,
                    ..
                })
            )
        {
            return Ok(Outcome::Nothing);
        }
        match std::mem::replace(&mut self.state, State::Idle) {
            State::Stroke => doc.end_stroke()?,
            State::Select(s) => {
                let mode = s.mode;
                let fixed = s.tool == Tool::RectangleSelect
                    && settings.select_draw == SelectDraw::FixedSize;
                // Too quick a drag counts as a click only in Replace mode.
                let quick =
                    !s.moved || (mode == CombineMode::Replace && p.time - s.started < QUICK_CLICK);
                let outside = select_bounds(&s, settings)
                    .intersect(doc.bounds())
                    .is_empty();
                if (quick && !fixed) || outside {
                    doc.cancel_edit();
                    // In Replace mode a click, or a shape clipped away,
                    // leaves nothing selected.
                    if mode == CombineMode::Replace && doc.selection().is_active() {
                        doc.deselect()?;
                    }
                } else {
                    apply_select(doc, &s, settings)?;
                    doc.commit_edit()?;
                }
            }
            State::Shape(s) => {
                if s.moved {
                    draw_shape(doc, &s, settings)?;
                    doc.commit_edit()?;
                } else {
                    doc.cancel_edit();
                }
            }
            State::Gradient(mut g) => {
                self.flush_gradient(doc, &g, settings)?;
                g.drag = None;
                g.other = None;
                g.creating = false;
                self.state = State::Gradient(g);
            }
            State::Line(mut l) => {
                if l.creating && l.points[0].distance(l.points[3]) < 0.5 {
                    doc.cancel_edit();
                } else {
                    draw_line(doc, &l, settings)?;
                    l.drag = None;
                    l.creating = false;
                    self.state = State::Line(l);
                }
            }
            State::MovePixels(m) => doc.transform_lifted(m.now, m.resampling)?,
            State::MoveSelection { .. } => {
                doc.move_selection_to(self.selection_offset.0, self.selection_offset.1)?;
                doc.commit_edit()?;
                self.move_selection_open = false;
            }
            State::Picker => {
                return Ok(match settings.picker_after {
                    PickerAfter::Stay => Outcome::Nothing,
                    PickerAfter::PreviousTool => Outcome::PreviousTool,
                    PickerAfter::Pencil => Outcome::SwitchTool(Tool::Pencil),
                });
            }
            State::Text(mut t) => {
                t.drag = None;
                self.state = State::Text(t);
                return Ok(Outcome::Nothing);
            }
            State::Idle | State::RecolorPick(_) => {}
        }
        self.dirty = false;
        Ok(Outcome::Nothing)
    }

    /// Redraws the preview once per frame if the gesture or the tool
    /// bar changed since the last draw.
    pub fn flush(&mut self, doc: &mut Document, settings: &ToolSettings) -> Result<()> {
        let colors = doc.colors();
        // A colour change (X, the palette, the picker) redraws a live
        // gradient or curve too.
        let settings_changed =
            !matches!(&self.drawn_with, Some((s, c)) if s == settings && *c == colors);
        if !self.dirty && !settings_changed {
            return Ok(());
        }
        self.dirty = false;
        if settings_changed {
            self.drawn_with = Some((settings.clone(), colors));
        }
        match &self.state {
            State::Select(s) if s.moved || settings.select_draw == SelectDraw::FixedSize => {
                apply_select(doc, s, settings)?
            }
            State::Shape(s) if s.moved => draw_shape(doc, s, settings)?,
            State::Gradient(g) => self.flush_gradient(doc, g, settings)?,
            State::Line(l) if l.points[0] != l.points[3] || !l.creating => {
                draw_line(doc, l, settings)?
            }
            State::MovePixels(m) => doc.transform_lifted(m.now, m.resampling)?,
            State::MoveSelection { .. } => {
                doc.move_selection_to(self.selection_offset.0, self.selection_offset.1)?
            }
            State::Text(_) => {
                if let State::Text(t) = &mut self.state {
                    t.draw(doc, settings)?;
                }
            }
            _ => {}
        }
        Ok(())
    }

    fn flush_gradient(
        &self,
        doc: &mut Document,
        g: &LiveGradient,
        settings: &ToolSettings,
    ) -> Result<()> {
        // Equal ends paint too: the whole area takes the end value.
        doc.gradient(g.points[0], g.points[1], &settings.gradient(), g.button)?;
        Ok(())
    }

    // ---- keys --------------------------------------------------------

    /// Enter: finishes a live gradient or curve. Returns whether it
    /// did (else Enter finishes any move and deselects, as Esc).
    pub fn enter(&mut self, doc: &mut Document) -> Result<bool> {
        match self.state {
            State::Gradient(_) | State::Line(_) => {
                self.state = State::Idle;
                doc.commit_edit()?;
                Ok(true)
            }
            // Typing, Enter belongs to the text (`text_key`), not here.
            State::Text(_) => Ok(true),
            _ => {
                self.finish(doc)?;
                Ok(false)
            }
        }
    }

    /// Esc: cancels a live gradient or curve. Returns whether it did
    /// (else Esc finishes any move and deselects).
    pub fn escape(&mut self, doc: &mut Document) -> Result<bool> {
        match self.state {
            State::Gradient(_) | State::Line(_) => {
                self.state = State::Idle;
                doc.cancel_edit();
                Ok(true)
            }
            // Esc keeps what was typed, as Paint.NET does.
            State::Text(_) => {
                self.finish(doc)?;
                Ok(true)
            }
            _ => {
                self.finish(doc)?;
                Ok(false)
            }
        }
    }

    /// Arrow keys in the move tools: 1 pixel, 10 with Ctrl.
    pub fn nudge(&mut self, doc: &mut Document, tool: Tool, dx: i32, dy: i32) -> Result<()> {
        match tool {
            Tool::MoveSelectedPixels => {
                if !doc.is_lifted() {
                    doc.lift_selection(false)?;
                }
                let (x, y) = add(doc.lift_offset().unwrap_or((0, 0)), (dx, dy));
                doc.move_lifted(x, y)
            }
            Tool::MoveSelection => {
                self.open_move_selection(doc)?;
                self.selection_offset = add(self.selection_offset, (dx, dy));
                doc.move_selection_to(self.selection_offset.0, self.selection_offset.1)
            }
            _ => Ok(()),
        }
    }

    /// A tool change or a command: whatever is live becomes a step.
    pub fn finish(&mut self, doc: &mut Document) -> Result<()> {
        match std::mem::replace(&mut self.state, State::Idle) {
            State::Stroke => doc.end_stroke()?,
            State::Gradient(_)
            | State::Line(_)
            | State::Select(_)
            | State::Shape(_)
            | State::MoveSelection { .. }
                if doc.is_editing() =>
            {
                doc.commit_edit()?;
            }
            State::Text(t) if t.editing && doc.is_editing() => {
                doc.commit_edit()?;
            }
            _ => {}
        }
        if doc.is_lifted() {
            doc.finish_move()?;
        }
        if self.move_selection_open && doc.is_editing() {
            doc.commit_edit()?;
        }
        self.move_selection_open = false;
        Ok(())
    }
}

/// The rectangle or ellipse box of a selection drag, with Shift and the
/// Recolor's Ctrl+click: the colour under the pointer, keeping the user
/// colour's own alpha as the source does.
fn pick_keeping_alpha(doc: &mut Document, at: PointF, button: Button) {
    if let Some(picked) = doc.pick_color(at) {
        let mut colors = doc.colors();
        let slot = match button {
            Button::Primary => &mut colors.primary,
            Button::Secondary => &mut colors.secondary,
        };
        *slot = picked.with_alpha(slot.a);
        doc.set_colors(colors);
    }
}

/// The rectangle box of a selection drag, with Shift and the Rectangle
/// Select's Fixed Ratio / Fixed Size draw modes; ellipses use Shift only.
fn select_box(s: &SelectDrag, settings: &ToolSettings) -> (PointF, PointF) {
    let (w, h) = settings.fixed;
    let draw = if s.tool == Tool::RectangleSelect {
        settings.select_draw
    } else {
        SelectDraw::Normal
    };
    match draw {
        SelectDraw::Normal => drag_box(s.start, s.end, s.mods.shift),
        SelectDraw::FixedRatio => {
            let (dx, dy) = (s.end.x - s.start.x, s.end.y - s.start.y);
            let ratio = w / h;
            let (mut bw, mut bh) = (dx.abs(), dy.abs());
            if bw > bh * ratio {
                bw = bh * ratio;
            } else {
                bh = bw / ratio;
            }
            (
                s.start,
                PointF::new(s.start.x + bw.copysign(dx), s.start.y + bh.copysign(dy)),
            )
        }
        SelectDraw::FixedSize => {
            let a = PointF::new(s.end.x.floor(), s.end.y.floor());
            (a, PointF::new(a.x + w.round(), a.y + h.round()))
        }
    }
}

fn select_bounds(s: &SelectDrag, settings: &ToolSettings) -> Rect {
    if s.tool == Tool::LassoSelect {
        let (mut x0, mut y0, mut x1, mut y1) = (f32::MAX, f32::MAX, f32::MIN, f32::MIN);
        for p in &s.points {
            x0 = x0.min(p.x);
            y0 = y0.min(p.y);
            x1 = x1.max(p.x);
            y1 = y1.max(p.y);
        }
        return Rect::covering(x0, y0, x1, y1);
    }
    let (a, b) = select_box(s, settings);
    Rect::covering(a.x.min(b.x), a.y.min(b.y), a.x.max(b.x), a.y.max(b.y))
}

fn apply_select(doc: &mut Document, s: &SelectDrag, settings: &ToolSettings) -> Result<()> {
    let mode = s.mode;
    match s.tool {
        Tool::RectangleSelect => {
            let (a, b) = select_box(s, settings);
            doc.select_rectangle(a, b, mode)
        }
        Tool::EllipseSelect => {
            let (a, b) = select_box(s, settings);
            doc.select_ellipse(a, b, mode)
        }
        Tool::LassoSelect if s.points.len() >= 3 => doc.select_lasso(&s.points, mode),
        _ => Ok(()),
    }
}

fn draw_shape(doc: &mut Document, s: &ShapeDrag, settings: &ToolSettings) -> Result<()> {
    let (a, b) = drag_box(s.start, s.end, s.shift);
    let shape = match s.tool {
        Tool::Rectangle => Shape::Rectangle { a, b },
        Tool::RoundedRectangle => Shape::RoundedRectangle {
            a,
            b,
            radius: ROUNDED_RADIUS,
        },
        Tool::Ellipse => Shape::Ellipse { a, b },
        Tool::FreeformShape if s.points.len() >= 3 => Shape::Freeform {
            points: s.points.clone(),
        },
        _ => return Ok(()),
    };
    doc.draw_shape(&shape, &settings.shape(), s.button)
}

fn draw_line(doc: &mut Document, l: &LiveLine, settings: &ToolSettings) -> Result<()> {
    let points = match l.curve {
        Curve::Straight => vec![l.points[0], l.points[3]],
        _ => l.points.to_vec(),
    };
    doc.draw_shape(
        &Shape::Line {
            points,
            curve: l.curve,
        },
        &settings.shape(),
        l.button,
    )
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::color::Rgba8;

    fn doc() -> Document {
        Document::new(64, 64, Rgba8::WHITE).unwrap()
    }

    fn at(x: f32, y: f32, button: Button, time: f64) -> Pointer {
        Pointer {
            pos: PointF::new(x, y),
            button,
            mods: Mods::default(),
            time,
        }
    }

    fn drag(
        c: &mut Controller,
        doc: &mut Document,
        tool: Tool,
        s: &ToolSettings,
        from: (f32, f32),
        to: (f32, f32),
    ) {
        c.press(doc, tool, s, at(from.0, from.1, Button::Primary, 0.0))
            .unwrap();
        c.motion(doc, PointF::new(to.0, to.1)).unwrap();
        c.flush(doc, s).unwrap();
        c.release(doc, s, at(to.0, to.1, Button::Primary, 1.0))
            .unwrap();
    }

    #[test]
    fn a_rectangle_drag_selects_and_a_click_deselects() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::RectangleSelect,
            &s,
            (2.0, 2.0),
            (10.0, 6.0),
        );
        assert_eq!(doc.selection().bounds(), Rect::new(2, 2, 8, 4));
        c.press(
            &mut doc,
            Tool::RectangleSelect,
            &s,
            at(30.0, 30.0, Button::Primary, 2.0),
        )
        .unwrap();
        c.release(&mut doc, &s, at(30.0, 30.0, Button::Primary, 2.2))
            .unwrap();
        assert!(!doc.selection().is_active());
        assert_eq!(doc.history_names().last().unwrap(), "Deselect");
    }

    #[test]
    fn ctrl_at_the_press_adds_and_later_changes_nothing() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::RectangleSelect,
            &s,
            (0.0, 0.0),
            (4.0, 4.0),
        );
        let ctrl = Mods {
            ctrl: true,
            ..Mods::default()
        };
        let mut p = at(10.0, 10.0, Button::Primary, 3.0);
        p.mods = ctrl;
        c.press(&mut doc, Tool::RectangleSelect, &s, p).unwrap();
        c.motion(&mut doc, PointF::new(14.0, 14.0)).unwrap();
        c.modifiers(Mods::default());
        c.flush(&mut doc, &s).unwrap();
        c.release(&mut doc, &s, at(14.0, 14.0, Button::Primary, 4.0))
            .unwrap();
        assert_eq!(doc.selection().coverage(1, 1), 255);
        assert_eq!(doc.selection().coverage(12, 12), 255);
        assert_eq!(doc.history_names().len(), 3);
    }

    #[test]
    fn a_quick_add_drag_still_adds() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::RectangleSelect,
            &s,
            (0.0, 0.0),
            (4.0, 4.0),
        );
        let mut p = at(10.0, 10.0, Button::Primary, 5.0);
        p.mods.ctrl = true;
        c.press(&mut doc, Tool::RectangleSelect, &s, p).unwrap();
        c.motion(&mut doc, PointF::new(14.0, 14.0)).unwrap();
        c.release(&mut doc, &s, at(14.0, 14.0, Button::Primary, 5.01))
            .unwrap();
        assert_eq!(doc.selection().coverage(12, 12), 255);
    }

    #[test]
    fn a_gradient_click_fills_with_the_end_colour() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        doc.set_colors(UserColors {
            primary: Rgba8::WHITE,
            secondary: Rgba8::BLACK,
        });
        c.press(
            &mut doc,
            Tool::Gradient,
            &s,
            at(5.0, 5.0, Button::Primary, 0.0),
        )
        .unwrap();
        c.flush(&mut doc, &s).unwrap();
        c.release(&mut doc, &s, at(5.0, 5.0, Button::Primary, 0.1))
            .unwrap();
        assert!(c.enter(&mut doc).unwrap());
        assert_eq!(doc.history_names().last().unwrap(), "Gradient");
    }

    #[test]
    fn a_live_gradient_follows_the_colours() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::Gradient,
            &s,
            (0.0, 0.0),
            (63.0, 0.0),
        );
        let before = doc.layers()[0].surface().get(2, 2);
        doc.swap_colors();
        c.flush(&mut doc, &s).unwrap();
        assert_ne!(doc.layers()[0].surface().get(2, 2), before);
    }

    #[test]
    fn moving_without_a_selection_selects_all_first() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::MoveSelectedPixels,
            &s,
            (4.0, 4.0),
            (6.0, 4.0),
        );
        c.finish(&mut doc).unwrap();
        assert_eq!(
            doc.history_names()[1..],
            ["Select All", "Move Selected Pixels"]
        );
    }

    #[test]
    fn the_other_button_moves_the_whole_selection_shape() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        c.press(
            &mut doc,
            Tool::RectangleSelect,
            &s,
            at(0.0, 0.0, Button::Primary, 0.0),
        )
        .unwrap();
        c.motion(&mut doc, PointF::new(4.0, 4.0)).unwrap();
        c.other_button(true, PointF::new(4.0, 4.0));
        c.motion(&mut doc, PointF::new(14.0, 4.0)).unwrap();
        c.flush(&mut doc, &s).unwrap();
        c.release(&mut doc, &s, at(14.0, 4.0, Button::Primary, 1.0))
            .unwrap();
        assert_eq!(doc.selection().bounds(), Rect::new(10, 0, 4, 4));
    }

    #[test]
    fn a_gradient_stays_live_until_enter() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::Gradient,
            &s,
            (0.0, 0.0),
            (63.0, 0.0),
        );
        assert!(doc.is_editing());
        assert_eq!(c.overlay().handles.len(), 2);
        // Drag the end handle back to the middle.
        c.press(
            &mut doc,
            Tool::Gradient,
            &s,
            at(63.0, 0.5, Button::Primary, 2.0),
        )
        .unwrap();
        c.motion(&mut doc, PointF::new(32.0, 0.0)).unwrap();
        c.flush(&mut doc, &s).unwrap();
        c.release(&mut doc, &s, at(32.0, 0.0, Button::Primary, 3.0))
            .unwrap();
        assert_eq!(doc.layers()[0].surface().get(40, 10), Some(Rgba8::WHITE));
        assert!(c.enter(&mut doc).unwrap());
        assert_eq!(doc.history_names(), ["New Image", "Gradient"]);
    }

    #[test]
    fn escape_cancels_a_live_line() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::LineCurve,
            &s,
            (2.0, 2.0),
            (60.0, 60.0),
        );
        assert_eq!(c.overlay().handles.len(), 4);
        assert!(c.escape(&mut doc).unwrap());
        assert_eq!(doc.history_names(), ["New Image"]);
        assert_eq!(doc.layers()[0].surface().get(30, 30), Some(Rgba8::WHITE));
    }

    #[test]
    fn bending_a_line_with_the_right_button_makes_a_bezier() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::LineCurve,
            &s,
            (2.0, 32.0),
            (62.0, 32.0),
        );
        let handle = c.overlay().handles[1];
        c.press(
            &mut doc,
            Tool::LineCurve,
            &s,
            at(handle.x, handle.y, Button::Secondary, 2.0),
        )
        .unwrap();
        c.motion(&mut doc, PointF::new(handle.x, 5.0)).unwrap();
        c.flush(&mut doc, &s).unwrap();
        c.release(&mut doc, &s, at(handle.x, 5.0, Button::Secondary, 3.0))
            .unwrap();
        assert_eq!(c.overlay().guide.len(), 4);
        c.finish(&mut doc).unwrap();
        assert_eq!(doc.history_names().last().unwrap(), "Line / Curve");
    }

    #[test]
    fn moving_pixels_is_one_step_and_the_outline_follows() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        doc.select_rectangle(
            PointF::new(0.0, 0.0),
            PointF::new(8.0, 8.0),
            CombineMode::Replace,
        )
        .unwrap();
        drag(
            &mut c,
            &mut doc,
            Tool::MoveSelectedPixels,
            &s,
            (4.0, 4.0),
            (14.0, 4.0),
        );
        assert_eq!(c.move_offset(&doc), Some((10, 0)));
        c.nudge(&mut doc, Tool::MoveSelectedPixels, 0, 10).unwrap();
        assert_eq!(c.move_offset(&doc), Some((10, 10)));
        c.finish(&mut doc).unwrap();
        assert_eq!(doc.selection().bounds(), Rect::new(10, 10, 8, 8));
        assert_eq!(doc.history_names().last().unwrap(), "Move Selected Pixels");
        assert_eq!(doc.history_names().len(), 3);
    }

    #[test]
    fn the_picker_can_switch_back() {
        let (mut c, mut doc, mut s) = (Controller::default(), doc(), ToolSettings::default());
        doc.set_colors(UserColors::default());
        s.picker_after = PickerAfter::PreviousTool;
        c.press(
            &mut doc,
            Tool::ColorPicker,
            &s,
            at(1.0, 1.0, Button::Primary, 0.0),
        )
        .unwrap();
        let out = c
            .release(&mut doc, &s, at(1.0, 1.0, Button::Primary, 0.1))
            .unwrap();
        assert_eq!(out, Outcome::PreviousTool);
        assert_eq!(doc.colors().primary, Rgba8::WHITE);
    }

    #[test]
    fn an_undo_mid_live_gradient_resets_the_gesture() {
        let (mut c, mut doc, s) = (Controller::default(), doc(), ToolSettings::default());
        drag(
            &mut c,
            &mut doc,
            Tool::Gradient,
            &s,
            (0.0, 0.0),
            (63.0, 0.0),
        );
        doc.undo().unwrap();
        c.sync(&doc);
        assert!(c.overlay().handles.is_empty());
    }
}
