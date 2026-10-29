//! A session as a shell drives it, through the public API only.

use paintbox_core::files::{read_document, write_document};
use paintbox_core::*;

#[test]
fn a_shell_session_paints_selects_adjusts_saves_and_undoes() {
    let mut doc = Document::new(256, 192, Rgba8::WHITE).unwrap();
    assert_eq!(doc.take_dirty(), Some(doc.bounds()));

    doc.add_layer().unwrap();
    assert_eq!(doc.take_dirty(), Some(doc.bounds()));
    doc.begin_stroke(
        StrokeTool::Paintbrush(BrushSettings::default()),
        Button::Primary,
        PointF::new(10.0, 10.0),
    )
    .unwrap();
    doc.stroke_to(PointF::new(100.0, 50.0)).unwrap();
    doc.end_stroke().unwrap();
    let dirty = doc.take_dirty().unwrap();
    assert!(dirty.width < 120 && dirty.height < 60, "{dirty:?}");
    assert_eq!(doc.composite_rgba8(dirty).len(), dirty.area() as usize * 4);

    doc.begin_edit("Gradient").unwrap();
    for x in [50.0, 120.0, 200.0] {
        doc.gradient(
            PointF::new(0.0, 0.0),
            PointF::new(x, 0.0),
            &GradientSettings {
                transparency: true,
                ..GradientSettings::default()
            },
            Button::Primary,
        )
        .unwrap();
    }
    doc.commit_edit().unwrap();

    doc.select_ellipse(
        PointF::new(20.0, 20.0),
        PointF::new(120.0, 120.0),
        CombineMode::Replace,
    )
    .unwrap();
    doc.apply_effect(&Effect::GaussianBlur { radius: 4 })
        .unwrap();
    // The layer is black ink fading out: hue would change nothing, and an
    // adjustment that changes nothing records no step.
    doc.apply_adjustment(&Adjustment::InvertColors).unwrap();
    let clip = doc.copy().unwrap();
    doc.paste_into_new_layer(&clip).unwrap();
    doc.nudge_lifted(10, 0).unwrap();
    doc.finish_move().unwrap();

    let names = doc.history_names();
    assert_eq!(
        names,
        [
            "New Image",
            "Add New Layer",
            "Paintbrush",
            "Gradient",
            "Ellipse Select",
            "Gaussian Blur",
            "Invert Colors",
            "Add New Layer",
            "Paste",
        ]
    );

    let saved = write_document(&doc, FileFormat::OpenRaster).unwrap();
    let reopened = read_document(&saved, FileFormat::OpenRaster).unwrap();
    assert_eq!(reopened.layers().len(), doc.layers().len());
    assert_eq!(reopened.flatten_image(), doc.flatten_image());

    let flat_before = doc.flatten_image();
    doc.jump_to(0).unwrap();
    assert_eq!(doc.layers().len(), 1);
    assert_eq!(
        doc.flatten_image(),
        Surface::filled(256, 192, Rgba8::WHITE).unwrap()
    );
    doc.jump_to(names.len() - 1).unwrap();
    assert_eq!(doc.flatten_image(), flat_before);
    assert!(!doc.can_redo());
}

#[test]
fn failures_are_values_not_panics() {
    assert!(Document::new(0, 10, Rgba8::WHITE).is_err());
    let mut doc = Document::new(10, 10, Rgba8::WHITE).unwrap();
    assert_eq!(doc.delete_layer(), Err(Error::LastLayer));
    assert_eq!(doc.merge_layer_down(), Err(Error::NoLayerBelow));
    assert!(doc.layer(5).is_err());
    assert!(doc.move_lifted(1, 1).is_err());
    assert!(doc.commit_edit().is_err());
    assert!(doc
        .begin_stroke(
            StrokeTool::Paintbrush(BrushSettings {
                width: 0.0,
                ..BrushSettings::default()
            }),
            Button::Primary,
            PointF::new(1.0, 1.0),
        )
        .is_err());
    assert!(doc
        .apply_effect(&Effect::Median {
            radius: 0,
            percentile: 50
        })
        .is_err());
    assert!(doc.copy().is_err());
    assert!(doc.crop_to_selection().is_err());
    assert_eq!(doc.undo(), Ok(false));
    assert_eq!(doc.history_names(), ["New Image"]);
    // Paint far outside the canvas: nothing happens, nothing breaks.
    doc.begin_stroke(
        StrokeTool::Pencil {
            alpha_blending: true,
        },
        Button::Primary,
        PointF::new(-500.0, -500.0),
    )
    .unwrap();
    doc.stroke_to(PointF::new(-400.0, 9000.0)).unwrap();
    doc.end_stroke().unwrap();
    doc.fill(
        PointF::new(50.0, 50.0),
        &FillSettings::default(),
        Button::Primary,
        false,
    )
    .unwrap();
    assert_eq!(doc.pick_color(PointF::new(99.0, 0.0)), None);
}

#[test]
fn hostile_input_does_not_panic_or_hang() {
    let mut doc = Document::new(64, 48, Rgba8::WHITE).unwrap();
    assert!(doc
        .composite_rgba8(Rect::new(i32::MAX, 0, 10, 10))
        .is_empty());
    assert_eq!(
        doc.layers()[0]
            .surface()
            .crop(Rect::new(i32::MAX - 2, 0, 10, 10))
            .pixels()
            .len(),
        0
    );
    let mut empty = Surface::new(4, 4).unwrap().crop(Rect::default());
    empty.flip_horizontal();
    let started = std::time::Instant::now();
    for (a, b) in [
        (PointF::new(1.0, 1.0), PointF::new(f32::INFINITY, 1.0)),
        (
            PointF::new(f32::NAN, 1.0),
            PointF::new(5.0, f32::NEG_INFINITY),
        ),
        (PointF::new(-1.0e9, -1.0e9), PointF::new(1.0e9, 1.0e9)),
    ] {
        for tool in [
            StrokeTool::Pencil {
                alpha_blending: true,
            },
            StrokeTool::Paintbrush(BrushSettings::default()),
        ] {
            doc.begin_stroke(tool, Button::Primary, a).unwrap();
            doc.stroke_to(b).unwrap();
            doc.end_stroke().unwrap();
        }
        doc.select_rectangle(a, b, CombineMode::Union).unwrap();
        doc.gradient(a, b, &GradientSettings::default(), Button::Primary)
            .unwrap();
        doc.draw_shape(
            &Shape::Ellipse { a, b },
            &ShapeSettings::default(),
            Button::Primary,
        )
        .unwrap();
    }
    assert!(started.elapsed().as_secs() < 5, "{:?}", started.elapsed());
    doc.select_rectangle(
        PointF::new(0.0, 0.0),
        PointF::new(4.0, 4.0),
        CombineMode::Replace,
    )
    .unwrap();
    doc.lift_selection(false).unwrap();
    doc.move_lifted(i32::MAX, i32::MIN).unwrap();
    doc.finish_move().unwrap();
    let clip = Clip {
        surface: Surface::filled(2, 2, Rgba8::BLACK).unwrap(),
        x: i32::MAX - 1,
        y: 0,
    };
    doc.paste(&clip).unwrap();
    doc.finish_move().unwrap();
    assert!(Document::new(60_000, 60_000, Rgba8::WHITE).is_err());
    assert!(doc
        .resize_image(65_535, 65_535, Resampling::NearestNeighbor)
        .is_err());
}

#[test]
fn an_openraster_claiming_a_huge_canvas_is_refused() {
    use std::io::Write;
    let mut zip = zip::ZipWriter::new(std::io::Cursor::new(Vec::new()));
    let options = zip::write::SimpleFileOptions::default();
    zip.start_file("mimetype", options).unwrap();
    zip.write_all(b"image/openraster").unwrap();
    zip.start_file("stack.xml", options).unwrap();
    zip.write_all(
        br#"<image w="65535" h="65535"><stack><layer src="a.png" name="a > b"/></stack></image>"#,
    )
    .unwrap();
    zip.start_file("a.png", options).unwrap();
    let pixel = Surface::filled(1, 1, Rgba8::BLACK).unwrap();
    zip.write_all(&files::encode_image(&pixel, FileFormat::Png).unwrap())
        .unwrap();
    let bytes = zip.finish().unwrap().into_inner();
    assert_eq!(
        files::read_ora(&bytes).err().map(|e| e.code()),
        Some("invalid_size")
    );
}

#[test]
fn previews_record_one_step() {
    let mut doc = Document::new(32, 32, Rgba8::WHITE).unwrap();
    // A selection drag in Union mode previews against where it started.
    doc.select_rectangle(
        PointF::new(0.0, 0.0),
        PointF::new(4.0, 4.0),
        CombineMode::Replace,
    )
    .unwrap();
    doc.begin_edit("Rectangle Select").unwrap();
    for x in [10.0, 20.0, 12.0] {
        doc.select_rectangle(PointF::new(8.0, 8.0), PointF::new(x, x), CombineMode::Union)
            .unwrap();
    }
    doc.commit_edit().unwrap();
    assert_eq!(doc.selection().bounds(), Rect::new(0, 0, 12, 12));
    assert_eq!(doc.selection().coverage(15, 15), 0);
    assert_eq!(doc.history_names().len(), 3);

    // Layer Properties shown live, one step on OK, nothing on Cancel.
    let mut p = doc.layers()[0].properties.clone();
    p.opacity = 10;
    doc.preview_layer_properties(0, p.clone()).unwrap();
    p.opacity = 100;
    doc.preview_layer_properties(0, p.clone()).unwrap();
    doc.set_layer_properties(0, p).unwrap();
    assert_eq!(doc.history_names().len(), 4);
    doc.undo().unwrap();
    assert_eq!(doc.layers()[0].properties.opacity, 255);
    let mut q = doc.layers()[0].properties.clone();
    q.visible = false;
    doc.preview_layer_properties(0, q).unwrap();
    doc.cancel_layer_properties_preview();
    assert!(doc.layers()[0].properties.visible);

    // Paint Bucket previews flood the originals, not the last preview.
    let mut doc = Document::new(16, 1, Rgba8::WHITE).unwrap();
    doc.set_colors(UserColors {
        primary: Rgba8::opaque(128, 128, 128),
        secondary: Rgba8::WHITE,
    });
    let fill = FillSettings {
        tolerance: 0.0,
        ..FillSettings::default()
    };
    doc.begin_edit("Paint Bucket").unwrap();
    doc.fill(PointF::new(0.5, 0.5), &fill, Button::Primary, false)
        .unwrap();
    doc.fill(PointF::new(12.5, 0.5), &fill, Button::Primary, false)
        .unwrap();
    doc.commit_edit().unwrap();
    assert_eq!(
        doc.layers()[0].surface().get(0, 0),
        Some(Rgba8::opaque(128, 128, 128))
    );

    // An effect rendered by a worker and applied afterwards.
    let mut doc = Document::new(16, 16, Rgba8::WHITE).unwrap();
    let (source, rect) = doc.effect_source();
    let result = Effect::Emboss { angle: 0.0 }.render(&source, rect).unwrap();
    doc.apply_rendered("Emboss", rect, &result).unwrap();
    assert_eq!(
        doc.layers()[0].surface().get(8, 8),
        Some(Rgba8::opaque(128, 128, 128))
    );
    assert_eq!(doc.history_names().last().unwrap(), "Emboss");
}

#[test]
fn gradient_colours_are_alpha_weighted_like_the_source() {
    let mut doc = Document::new(3, 1, Rgba8::TRANSPARENT).unwrap();
    doc.set_colors(UserColors {
        primary: Rgba8::opaque(255, 0, 0),
        secondary: Rgba8::new(0, 0, 0, 0),
    });
    let settings = GradientSettings {
        alpha_blending: false,
        ..GradientSettings::default()
    };
    doc.gradient(
        PointF::new(0.0, 0.0),
        PointF::new(2.0, 0.0),
        &settings,
        Button::Primary,
    )
    .unwrap();
    // Halfway red stays red, only alpha falls: (255, 0, 0, 127) in the source.
    assert_eq!(
        doc.layers()[0].surface().get(1, 0),
        Some(Rgba8::new(255, 0, 0, 128))
    );
}
