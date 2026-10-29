//! Timings on a 4096 × 4096 picture. Ignored by default; run with
//! `cargo test --release --test perf_4k -- --ignored --nocapture`.

use std::time::Instant;

use paintbox_core::*;

fn time(label: &str, f: impl FnOnce()) {
    let start = Instant::now();
    f();
    println!(
        "{label:<40} {:>8.1} ms",
        start.elapsed().as_secs_f64() * 1000.0
    );
}

#[test]
#[ignore]
fn timings_on_4k() {
    let mut doc = Document::new(4096, 4096, Rgba8::WHITE).unwrap();
    doc.add_layer().unwrap();
    doc.add_layer().unwrap();
    time("flatten 3 layers", || {
        doc.flatten_image();
    });
    time("composite a 256 px dirty rect", || {
        doc.composite_rgba8(Rect::new(1000, 1000, 256, 256));
    });
    time("brush stroke, 40 segments, width 30", || {
        let tool = StrokeTool::Paintbrush(BrushSettings {
            width: 30.0,
            ..BrushSettings::default()
        });
        doc.begin_stroke(tool, Button::Primary, PointF::new(100.0, 100.0))
            .unwrap();
        for i in 1..=40 {
            doc.stroke_to(PointF::new(
                100.0 + i as f32 * 50.0,
                100.0 + i as f32 * 20.0,
            ))
            .unwrap();
        }
        doc.end_stroke().unwrap();
    });
    time("linear gradient, full layer", || {
        doc.gradient(
            PointF::new(0.0, 0.0),
            PointF::new(4096.0, 4096.0),
            &GradientSettings::default(),
            Button::Primary,
        )
        .unwrap();
    });
    time("gaussian blur r=10, full layer", || {
        doc.apply_effect(&Effect::GaussianBlur { radius: 10 })
            .unwrap();
    });
    time("gaussian blur r=100, full layer", || {
        doc.apply_effect(&Effect::GaussianBlur { radius: 100 })
            .unwrap();
    });
    time("hue / saturation, full layer", || {
        doc.apply_adjustment(&Adjustment::HueSaturation {
            hue: 20,
            saturation: 120,
            lightness: 0,
        })
        .unwrap();
    });
    time("undo hue / saturation", || {
        doc.undo().unwrap();
    });
    time("median r=5, full layer", || {
        doc.apply_effect(&Effect::Median {
            radius: 5,
            percentile: 50,
        })
        .unwrap();
    });
    time("paint bucket, global", || {
        doc.fill(
            PointF::new(5.0, 5.0),
            &FillSettings::default(),
            Button::Secondary,
            true,
        )
        .unwrap();
    });
    println!("history holds {} MB", doc.history_bytes() / (1 << 20));
}

/// Every effect of the menu with its dialog's starting values, rendered
/// over a whole 4k layer (the render alone, as a preview runs it).
#[test]
#[ignore]
fn effects_on_4k() {
    let side = 4096u32;
    let mut bytes = Vec::with_capacity((side * side * 4) as usize);
    for y in 0..side {
        for x in 0..side {
            // A gradient with a finer pattern, so no effect sees a flat
            // picture and takes a shortcut.
            let v = (x ^ y) & 63;
            bytes.extend_from_slice(&[(x / 16) as u8, (y / 16) as u8, (v * 4) as u8, 255]);
        }
    }
    let surface = Surface::from_rgba8(side, side, &bytes).unwrap();
    for kind in EffectKind::ALL {
        let effect = kind.default_effect();
        time(&format!("{} (defaults)", effect.name()), || {
            effect.render(&surface, surface.bounds()).unwrap();
        });
    }
    // The slowest corners of the sliders.
    let heavy = [
        Effect::SurfaceBlur {
            radius: 100,
            threshold: 100,
        },
        Effect::Unfocus { radius: 200 },
        Effect::ReduceNoise {
            radius: 200,
            strength: 1.0,
        },
        Effect::RadialBlur {
            angle: 360.0,
            offset_x: 0.0,
            offset_y: 0.0,
            quality: 5,
        },
        Effect::Twist {
            amount: 200.0,
            size: 2.0,
            offset_x: 0.0,
            offset_y: 0.0,
            quality: 5,
        },
        Effect::MandelbrotFractal {
            factor: 1,
            zoom: 10.0,
            angle: 0.0,
            quality: 5,
            invert_colors: false,
        },
    ];
    for effect in heavy {
        time(&format!("{} (heaviest)", effect.name()), || {
            effect.render(&surface, surface.bounds()).unwrap();
        });
    }
}
