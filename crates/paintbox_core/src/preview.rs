//! Dialogs that preview on the image while open: Layer Properties, the
//! adjustments and the effects, with no UI toolkit. Adjustments are fast
//! and preview on the calling thread inside an open edit; effects render
//! on a worker thread from a copy of the layer and are blended in when
//! they arrive, so a slow effect never freezes the shell and Cancel
//! answers at once (the worker stops at its next row).
//!
//! A shell keeps one [`Preview`], changes its parameters as the dialog's
//! controls move, calls [`Preview::update`] every frame (or after each
//! change and each wake) and ends it with [`Preview::end`].

use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc;
use std::sync::{Arc, Mutex};

use crate::adjust::Adjustment;
use crate::document::Document;
use crate::effects::Effect;
use crate::error::{Error, Result};
use crate::geom::Rect;
use crate::layer::LayerProperties;
use crate::surface::Surface;

/// Called from the worker thread when a render is in, so the shell can
/// schedule a frame (a UI toolkit's repaint request).
pub type Wake = Arc<dyn Fn() + Send + Sync>;

/// A render on the worker thread.
struct Job {
    effect: Effect,
    cancel: Arc<AtomicBool>,
    /// In a mutex only so a preview is `Sync` (a shell may keep it in a
    /// shared object); it is polled from one thread.
    rx: Mutex<mpsc::Receiver<Result<Surface>>>,
}

pub struct EffectPreview {
    pub effect: Effect,
    source: Arc<Surface>,
    rect: Rect,
    job: Option<Job>,
    /// The parameters whose result is on the image.
    shown: Option<Effect>,
    /// OK was pressed before the last render arrived.
    pub finishing: bool,
    /// Ctrl+F: no parameters to show, only the progress.
    pub repeat: bool,
    wake: Wake,
}

pub enum Preview {
    LayerProperties {
        index: usize,
        props: LayerProperties,
        shown: LayerProperties,
    },
    Adjust {
        adjustment: Adjustment,
        shown: Option<Adjustment>,
    },
    Effect(EffectPreview),
}

/// How a preview dialog ended.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Ended {
    Ok,
    Cancel,
}

/// What one [`Preview::update`] did.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct Progress {
    /// The image changed: redraw.
    pub changed: bool,
    /// An effect whose OK waited for its render is in: end with OK.
    pub finished: bool,
}

impl Preview {
    pub fn layer_properties(doc: &Document, index: usize) -> Result<Preview> {
        let props = doc.layer(index)?.properties.clone();
        Ok(Preview::LayerProperties {
            index,
            shown: props.clone(),
            props,
        })
    }

    pub fn adjust(doc: &mut Document, adjustment: Adjustment) -> Result<Preview> {
        doc.begin_edit(adjustment.name())?;
        Ok(Preview::Adjust {
            adjustment,
            shown: None,
        })
    }

    /// `repeat` is Ctrl+F: the dialog only waits for the render and ends.
    pub fn effect(doc: &mut Document, effect: Effect, repeat: bool, wake: Wake) -> Result<Preview> {
        // Taken before the edit opens: then the layer is its own original
        // and the copy needs no tile lookups.
        let (source, rect) = doc.effect_source();
        doc.begin_edit(effect.name())?;
        Ok(Preview::Effect(EffectPreview {
            effect,
            source: Arc::new(source),
            rect,
            job: None,
            shown: None,
            finishing: repeat,
            repeat,
            wake,
        }))
    }

    pub fn title(&self) -> &'static str {
        match self {
            Preview::LayerProperties { .. } => "Layer Properties",
            Preview::Adjust { adjustment, .. } => adjustment.name(),
            Preview::Effect(e) => e.effect.name(),
        }
    }

    pub fn is_rendering(&self) -> bool {
        matches!(self, Preview::Effect(e) if e.job.is_some())
    }

    /// Brings the image up to date with the dialog's parameters.
    pub fn update(&mut self, doc: &mut Document) -> Result<Progress> {
        let mut progress = Progress::default();
        match self {
            Preview::LayerProperties {
                index,
                props,
                shown,
            } => {
                if props != shown {
                    doc.preview_layer_properties(*index, props.clone())?;
                    *shown = props.clone();
                    progress.changed = true;
                }
            }
            Preview::Adjust { adjustment, shown } => {
                if shown.as_ref() != Some(adjustment) {
                    *shown = Some(adjustment.clone());
                    doc.apply_adjustment(adjustment)?;
                    progress.changed = true;
                }
            }
            Preview::Effect(e) => return e.update(doc),
        }
        Ok(progress)
    }

    /// OK pressed: whether the dialog can end now. An effect still
    /// rendering keeps the dialog open and ends by itself when the
    /// render is in ([`Progress::finished`]).
    pub fn press_ok(&mut self) -> bool {
        match self {
            Preview::Effect(e) if !e.is_done() => {
                e.finishing = true;
                false
            }
            _ => true,
        }
    }

    pub fn end(self, doc: &mut Document, ended: Ended) -> Result<()> {
        match (self, ended) {
            (Preview::LayerProperties { index, props, .. }, Ended::Ok) => {
                doc.set_layer_properties(index, props)
            }
            (Preview::LayerProperties { .. }, Ended::Cancel) => {
                doc.cancel_layer_properties_preview();
                Ok(())
            }
            (Preview::Adjust { adjustment, shown }, Ended::Ok) => {
                if shown.as_ref() != Some(&adjustment) {
                    doc.apply_adjustment(&adjustment)?;
                }
                doc.commit_edit().map(drop)
            }
            (_, Ended::Cancel) => {
                doc.cancel_edit();
                Ok(())
            }
            (Preview::Effect(_), Ended::Ok) => doc.commit_edit().map(drop),
        }
    }
}

impl EffectPreview {
    /// The result of the current parameters is on the image.
    pub fn is_done(&self) -> bool {
        self.job.is_none() && self.shown == Some(self.effect)
    }

    fn update(&mut self, doc: &mut Document) -> Result<Progress> {
        let mut progress = Progress::default();
        if let Some(job) = &self.job {
            // Parameters moved on: the running render is stale, stop it.
            if job.effect != self.effect {
                job.cancel.store(true, Ordering::Relaxed);
            }
            let received = job
                .rx
                .lock()
                .map_or(Err(mpsc::TryRecvError::Disconnected), |rx| rx.try_recv());
            match received {
                Ok(result) => {
                    let effect = job.effect;
                    self.job = None;
                    match result {
                        Ok(surface) => {
                            doc.apply_rendered(effect.name(), self.rect, &surface)?;
                            self.shown = Some(effect);
                            progress.changed = true;
                        }
                        Err(Error::Cancelled) => {}
                        Err(e) => return Err(e),
                    }
                }
                Err(mpsc::TryRecvError::Empty) => {}
                // The worker died (a panic in the render): stop, do not retry.
                Err(mpsc::TryRecvError::Disconnected) => {
                    self.job = None;
                    return Err(crate::error::invalid(format!(
                        "{} failed to render",
                        self.effect.name()
                    )));
                }
            }
        }
        if self.job.is_none() && self.shown != Some(self.effect) {
            // One render at a time: parameters changed meanwhile render
            // once this one is in or cancelled.
            let (tx, rx) = mpsc::channel();
            let cancel = Arc::new(AtomicBool::new(false));
            let (source, rect, effect, wake, flag) = (
                self.source.clone(),
                self.rect,
                self.effect,
                self.wake.clone(),
                cancel.clone(),
            );
            std::thread::spawn(move || {
                let _ = tx.send(effect.render_cancellable(&source, rect, &flag));
                wake();
            });
            self.job = Some(Job {
                effect,
                cancel,
                rx: Mutex::new(rx),
            });
        }
        progress.finished = self.finishing && self.is_done();
        Ok(progress)
    }
}

impl Drop for EffectPreview {
    fn drop(&mut self) {
        if let Some(job) = &self.job {
            job.cancel.store(true, Ordering::Relaxed);
        }
    }
}

/// A dialog parameter's range as Paint.NET's sliders set it: `(name,
/// min, max)`. Parameters not listed (a seed, a flag) have no range;
/// Levels' per-channel arrays are listed by their field.
pub type ParamRange = (&'static str, f64, f64);

impl Effect {
    pub fn ranges(&self) -> &'static [ParamRange] {
        match self {
            Effect::GaussianBlur { .. } => &[("radius", 0.0, 200.0)],
            Effect::MotionBlur { .. } => &[("angle", -180.0, 180.0), ("distance", 1.0, 200.0)],
            Effect::Sharpen { .. } => &[("amount", 1.0, 20.0)],
            Effect::AddNoise { .. } => &[
                ("intensity", 0.0, 100.0),
                ("saturation", 0.0, 400.0),
                ("coverage", 0.0, 100.0),
            ],
            Effect::Median { .. } => &[("radius", 1.0, 200.0), ("percentile", 0.0, 100.0)],
            Effect::Pixelate { .. } => &[("cell_size", 1.0, 100.0)],
            Effect::OilPainting { .. } => &[("brush_size", 1.0, 8.0), ("coarseness", 3.0, 255.0)],
            Effect::Emboss { .. } | Effect::EdgeDetect { .. } => &[("angle", -180.0, 180.0)],
            Effect::Outline { .. } => &[("thickness", 1.0, 200.0), ("intensity", 0.0, 100.0)],
            Effect::InkSketch { .. } => &[("ink_outline", 0.0, 99.0), ("coloring", 0.0, 100.0)],
            Effect::PencilSketch { .. } => &[("tip_size", 1.0, 20.0), ("color_range", -20.0, 20.0)],
            Effect::Fragment { .. } => &[
                ("fragments", 2.0, 50.0),
                ("distance", 0.0, 100.0),
                ("rotation", 0.0, 360.0),
            ],
            Effect::RadialBlur { .. } => &[
                ("angle", 0.0, 360.0),
                ("offset_x", -2.0, 2.0),
                ("offset_y", -2.0, 2.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::SurfaceBlur { .. } => &[("radius", 1.0, 100.0), ("threshold", 1.0, 100.0)],
            Effect::Unfocus { .. } => &[("radius", 1.0, 200.0)],
            Effect::ZoomBlur { .. } => &[
                ("amount", 0.0, 100.0),
                ("offset_x", -2.0, 2.0),
                ("offset_y", -2.0, 2.0),
            ],
            Effect::Bulge { .. } => &[
                ("amount", -200.0, 100.0),
                ("offset_x", -1.0, 1.0),
                ("offset_y", -1.0, 1.0),
            ],
            Effect::Dents { .. } => &[
                ("scale", 1.0, 200.0),
                ("refraction", 0.0, 200.0),
                ("roughness", 0.0, 100.0),
                ("tension", 0.0, 100.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::FrostedGlass { .. } => &[
                ("max_scatter", 0.0, 200.0),
                ("min_scatter", 0.0, 200.0),
                ("samples", 1.0, 8.0),
            ],
            Effect::PolarInversion { .. } => &[
                ("amount", -4.0, 4.0),
                ("offset_x", -2.0, 2.0),
                ("offset_y", -2.0, 2.0),
                ("edge_behavior", 0.0, 2.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::TileReflection { .. } => &[
                ("rotation", -180.0, 180.0),
                ("tile_size", 1.0, 800.0),
                ("curvature", -100.0, 100.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::Twist { .. } => &[
                ("amount", -200.0, 200.0),
                ("size", 0.01, 2.0),
                ("offset_x", -2.0, 2.0),
                ("offset_y", -2.0, 2.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::ReduceNoise { .. } => &[("radius", 0.0, 200.0), ("strength", 0.0, 1.0)],
            Effect::Glow { .. } => &[
                ("radius", 1.0, 20.0),
                ("brightness", -100.0, 100.0),
                ("contrast", -100.0, 100.0),
            ],
            Effect::RedEyeRemoval { .. } => {
                &[("tolerance", 0.0, 100.0), ("saturation", 0.0, 100.0)]
            }
            Effect::SoftenPortrait { .. } => &[
                ("softness", 0.0, 10.0),
                ("lighting", -20.0, 20.0),
                ("warmth", 0.0, 20.0),
            ],
            // The blend mode is an index into `BlendMode::ALL`.
            Effect::Clouds { .. } => &[
                ("scale", 2.0, 1000.0),
                ("power", 0.0, 1.0),
                ("blend_mode", 0.0, 13.0),
            ],
            Effect::JuliaFractal { .. } => &[
                ("factor", 1.0, 10.0),
                ("zoom", 0.1, 50.0),
                ("angle", -180.0, 180.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::MandelbrotFractal { .. } => &[
                ("factor", 1.0, 10.0),
                ("zoom", 0.0, 100.0),
                ("angle", -180.0, 180.0),
                ("quality", 1.0, 5.0),
            ],
            Effect::Relief { .. } => &[("angle", -180.0, 180.0)],
        }
    }
}

impl Adjustment {
    pub fn ranges(&self) -> &'static [ParamRange] {
        match self {
            Adjustment::BrightnessContrast { .. } => {
                &[("brightness", -100.0, 100.0), ("contrast", -100.0, 100.0)]
            }
            Adjustment::HueSaturation { .. } => &[
                ("hue", -180.0, 180.0),
                ("saturation", 0.0, 200.0),
                ("lightness", -100.0, 100.0),
            ],
            Adjustment::Posterize { .. } => &[
                ("red", 2.0, 64.0),
                ("green", 2.0, 64.0),
                ("blue", 2.0, 64.0),
            ],
            Adjustment::Levels(_) => &[
                ("input_low", 0.0, 254.0),
                ("input_high", 1.0, 255.0),
                ("output_low", 0.0, 255.0),
                ("output_high", 0.0, 255.0),
                ("gamma", 0.1, 10.0),
            ],
            _ => &[],
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::color::Rgba8;
    use crate::geom::PointF;
    use crate::mask::CombineMode;

    fn doc() -> Document {
        let mut doc = Document::new(32, 32, Rgba8::opaque(200, 100, 50)).unwrap();
        doc.select_rectangle(
            PointF::new(0.0, 0.0),
            PointF::new(16.0, 32.0),
            CombineMode::Replace,
        )
        .unwrap();
        doc
    }

    fn no_wake() -> Wake {
        Arc::new(|| {})
    }

    #[test]
    fn an_adjustment_previews_and_records_one_step_on_ok() {
        let mut doc = doc();
        let mut f = Preview::adjust(&mut doc, Adjustment::InvertColors).unwrap();
        assert!(f.update(&mut doc).unwrap().changed);
        assert_eq!(
            doc.layers()[0].surface().get(1, 1),
            Some(Rgba8::opaque(55, 155, 205))
        );
        assert_eq!(
            doc.layers()[0].surface().get(20, 1),
            Some(Rgba8::opaque(200, 100, 50))
        );
        assert!(!f.update(&mut doc).unwrap().changed);
        f.end(&mut doc, Ended::Ok).unwrap();
        assert_eq!(doc.history_names().last().unwrap(), "Invert Colors");
        assert_eq!(doc.history_names().len(), 3);
    }

    #[test]
    fn cancel_puts_the_pixels_back() {
        let mut doc = doc();
        let mut f = Preview::adjust(&mut doc, Adjustment::Sepia).unwrap();
        f.update(&mut doc).unwrap();
        f.end(&mut doc, Ended::Cancel).unwrap();
        assert_eq!(
            doc.layers()[0].surface().get(1, 1),
            Some(Rgba8::opaque(200, 100, 50))
        );
        assert_eq!(doc.history_names().len(), 2);
    }

    #[test]
    fn an_effect_renders_on_a_worker_and_lands_on_ok() {
        let mut doc = doc();
        let mut f =
            Preview::effect(&mut doc, Effect::Emboss { angle: 0.0 }, false, no_wake()).unwrap();
        let started = std::time::Instant::now();
        while !matches!(&f, Preview::Effect(e) if e.is_done()) {
            f.update(&mut doc).unwrap();
            assert!(started.elapsed().as_secs() < 10);
            std::thread::sleep(std::time::Duration::from_millis(2));
        }
        assert_eq!(
            doc.layers()[0].surface().get(8, 8),
            Some(Rgba8::opaque(128, 128, 128))
        );
        // A changed parameter renders again; the old result stays meanwhile.
        if let Preview::Effect(e) = &mut f {
            e.effect = Effect::Emboss { angle: 90.0 };
            assert!(!e.is_done());
        }
        assert!(!f.press_ok());
        let started = std::time::Instant::now();
        while !f.update(&mut doc).unwrap().finished {
            assert!(started.elapsed().as_secs() < 10);
            std::thread::sleep(std::time::Duration::from_millis(2));
        }
        f.end(&mut doc, Ended::Ok).unwrap();
        assert_eq!(doc.history_names().len(), 3);
    }

    #[test]
    fn a_cancelled_render_stops_early() {
        let big = Surface::new(2048, 2048).unwrap();
        let flag = AtomicBool::new(true);
        let effect = Effect::Median {
            radius: 100,
            percentile: 50,
        };
        assert_eq!(
            effect.render_cancellable(&big, big.bounds(), &flag).err(),
            Some(Error::Cancelled)
        );
        let blur = Effect::GaussianBlur { radius: 50 };
        assert_eq!(
            blur.render_cancellable(&big, big.bounds(), &flag).err(),
            Some(Error::Cancelled)
        );
    }

    #[test]
    fn layer_properties_preview_then_one_step() {
        let mut doc = doc();
        let mut f = Preview::layer_properties(&doc, 0).unwrap();
        if let Preview::LayerProperties { props, .. } = &mut f {
            props.opacity = 40;
            props.name = "Paper".into();
        }
        f.update(&mut doc).unwrap();
        assert_eq!(doc.layers()[0].properties.opacity, 40);
        f.end(&mut doc, Ended::Ok).unwrap();
        assert_eq!(doc.layers()[0].properties.name, "Paper");
        doc.undo().unwrap();
        assert_eq!(doc.layers()[0].properties.opacity, 255);
    }
}
