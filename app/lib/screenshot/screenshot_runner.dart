import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:editor_ui/editor_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

/// Plays the screenshot scenes one after another through the editor's
/// own events (the path a user's input takes), saves
/// `<target>-<scene>.png` for each and quits.
///
/// - `empty`: the blank image as the program starts;
/// - `layers`: an OpenRaster file of six layers (a night landscape made
///   with the core's own tools and effects), opened as File > Open opens
///   it, the Colors window as Less, with an elliptical selection drawn
///   by the pointer around the moon;
/// - `effect`: the Gaussian Blur dialog previewing on that selection.
class ScreenshotRunner {
  ScreenshotRunner({
    required this.target,
    this.scene,
    this.theme = ThemeChoice.dark,
    this.accent = AccentChoice.blue,
    this.language = 'en',
  });

  static const scenes = [
    'empty',
    'layers',
    'effect',
    'text',
    'lines',
    'transform',
    'effects',
    'compact',
    'strips',
  ];

  /// The scenes played on the layered file.
  static const _onLayers = {
    'effect',
    'text',
    'lines',
    'transform',
    'effects',
    'compact',
    'strips',
  };

  final String target;
  final String? scene;

  /// The look of the pictures, apart from the user's settings:
  /// `--theme=`, `--accent=` and `--language=` on the command line.
  final ThemeChoice theme;
  final AccentChoice accent;
  final String language;

  void start(EditorBloc bloc, GlobalKey boundary) =>
      unawaited(_play(bloc, boundary));

  Future<void> _play(EditorBloc bloc, GlobalKey boundary) async {
    try {
      final chosen = scene == null ? scenes : [scene!];
      await _settle(const Duration(milliseconds: 1500));
      for (final name in scenes) {
        final wanted = chosen.contains(name);
        switch (name) {
          case 'empty':
            break;
          case 'layers':
            if (!wanted && !chosen.any(_onLayers.contains)) {
              continue;
            }
            await _layers(bloc);
          case 'effect':
            if (!wanted) {
              continue;
            }
            bloc
              ..add(const CommandInvokedEvent('effect:gaussian_blur'))
              ..add(const PreviewParamChangedEvent('radius', [6]));
            await _settle(const Duration(milliseconds: 1500));
          case 'text':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            await _text(bloc);
          case 'lines':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            await _lines(bloc);
          case 'transform':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            await _transform(bloc);
          case 'effects':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            // One picture per effect, each previewed on the whole image.
            bloc.add(const CommandInvokedEvent('deselect'));
            for (final group in PaintCatalog.effectMenu) {
              for (final id in group.ids) {
                bloc.add(CommandInvokedEvent(id));
                await _settle(const Duration(milliseconds: 1800));
                await _capture(boundary, 'effect-${id.split(':').last}');
                bloc.add(const PreviewEndedEvent(ok: false));
                await _settle(const Duration(milliseconds: 300));
              }
            }
            continue;
          case 'compact':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            // Colors is Less since the layered file; the Text tool's
            // settings in the bar.
            bloc.add(const ToolSelectedEvent(Tool.text));
            await _settle(const Duration(milliseconds: 600));
          case 'strips':
            if (!wanted) {
              continue;
            }
            await _end(bloc);
            // The tool bar of each kind of tool, one picture each.
            for (final tool in const [
              Tool.rectangleSelect,
              Tool.magicWand,
              Tool.paintbrush,
              Tool.gradient,
              Tool.rectangle,
              Tool.lineCurve,
              Tool.text,
              Tool.colorPicker,
            ]) {
              bloc.add(ToolSelectedEvent(tool));
              final ready = bloc.state;
              if (tool == Tool.rectangleSelect && ready is EditorReady) {
                // With the fixed ratio's fields and swap shown.
                bloc.add(
                  ToolSettingsChangedEvent(
                    ready.toolSettings.copyWith(
                      selectDraw: SelectDraw.fixedRatio,
                    ),
                  ),
                );
              }
              await _settle(const Duration(milliseconds: 400));
              await _capture(boundary, 'strip-${tool.name}');
            }
            continue;
        }
        if (wanted) {
          // The pointer leaves the canvas, so the floating windows are
          // opaque and show their true colours.
          bloc.add(const CanvasPointerExitedEvent());
          await _settle(const Duration(milliseconds: 400));
          await _capture(boundary, name);
        }
      }
    } on Object catch (error, stackTrace) {
      AppLog.error(error, stackTrace, where: 'ScreenshotRunner');
      exit(1);
    }
    exit(0);
  }

  /// Closes what the scene before left open: a dialog, a live gesture.
  Future<void> _end(EditorBloc bloc) async {
    bloc.add(const PreviewEndedEvent(ok: false));
    await _settle(const Duration(milliseconds: 300));
  }

  ui.Offset _screen(EditorBloc bloc, ui.Offset image) {
    final ready = bloc.state;
    if (ready is! EditorReady || ready.view == null) {
      throw StateError('no image on the canvas');
    }
    return ready.view!.toScreen(image);
  }

  /// A drag between two points of the image, as the pointer makes it.
  Future<void> _drag(
    EditorBloc bloc,
    ui.Offset fromImage,
    ui.Offset toImage, {
    CanvasButton button = CanvasButton.primary,
  }) async {
    final from = _screen(bloc, fromImage);
    final to = _screen(bloc, toImage);
    bloc.add(
      CanvasPointerDownEvent(
        position: from,
        button: button,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    for (var i = 1; i <= 12; i++) {
      bloc.add(CanvasPointerMovedEvent(ui.Offset.lerp(from, to, i / 12)!));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    bloc.add(
      CanvasPointerUpEvent(
        position: to,
        button: button,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    await _settle(const Duration(milliseconds: 300));
  }

  ToolSettings _settings(EditorBloc bloc) {
    final ready = bloc.state;
    return ready is EditorReady ? ready.toolSettings : defaultToolSettings();
  }

  /// Two lines of text typed at a click, the caret still in them.
  Future<void> _text(EditorBloc bloc) async {
    bloc
      ..add(const CommandInvokedEvent('deselect'))
      ..add(const ToolSelectedEvent(Tool.text))
      ..add(
        ToolSettingsChangedEvent(
          _settings(bloc).copyWith(fontSize: 36, bold: true),
        ),
      );
    await _settle(const Duration(milliseconds: 300));
    // On the hills, under the title the picture already has.
    await _drag(bloc, const ui.Offset(56, 330), const ui.Offset(56, 330));
    bloc
      ..add(const TextTypedEvent('Paintbox'))
      ..add(const TextKeyPressedEvent(TextKey.enter, ctrl: false))
      ..add(const TextTypedEvent('Текст і шрифти'));
    await _settle(const Duration(milliseconds: 900));
  }

  /// Lines with each end and dash, the last still live with its handles.
  Future<void> _lines(EditorBloc bloc) async {
    bloc
      ..add(const CommandInvokedEvent('deselect'))
      ..add(const ToolSelectedEvent(Tool.lineCurve));
    final ends = [
      (LineCap.flat, LineCap.arrowFilled, DashStyle.solid),
      (LineCap.arrow, LineCap.arrow, DashStyle.dash),
      (LineCap.rounded, LineCap.arrowFilled, DashStyle.dashDot),
      (LineCap.flat, LineCap.rounded, DashStyle.dot),
    ];
    for (var i = 0; i < ends.length; i++) {
      final (start, end, dash) = ends[i];
      bloc.add(
        ToolSettingsChangedEvent(
          _settings(bloc)
              .copyWith(width: 8, lineStart: start, lineEnd: end, dash: dash),
        ),
      );
      await _settle(const Duration(milliseconds: 100));
      final y = 70.0 + i * 90;
      await _drag(bloc, ui.Offset(80, y), ui.Offset(560, y + 40));
      if (i < ends.length - 1) {
        bloc.add(
          const KeyPressedEvent(
            key: 'Enter',
            ctrl: false,
            shift: false,
            alt: false,
          ),
        );
      }
    }
    await _settle(const Duration(milliseconds: 600));
  }

  /// A part of the picture lifted, turned with the right button and
  /// stretched by a handle, its eight handles showing.
  Future<void> _transform(EditorBloc bloc) async {
    bloc.add(const ToolSelectedEvent(Tool.rectangleSelect));
    await _drag(bloc, const ui.Offset(200, 120), const ui.Offset(420, 280));
    bloc.add(const ToolSelectedEvent(Tool.moveSelectedPixels));
    await _drag(
      bloc,
      const ui.Offset(520, 200),
      const ui.Offset(500, 300),
      button: CanvasButton.secondary,
    );
    final ready = bloc.state;
    final handles = ready is EditorReady ? ready.image?.handles : null;
    if (handles != null && handles.length == 8) {
      final h = handles[3];
      await _drag(bloc, ui.Offset(h.x, h.y), ui.Offset(h.x + 60, h.y + 20));
    }
    await _settle(const Duration(milliseconds: 600));
  }

  Future<void> _layers(EditorBloc bloc) async {
    final path = await _makeLayeredFile(language);
    bloc.add(OpenPathsEvent([path]));
    await _settle(const Duration(milliseconds: 1200));
    final ready = bloc.state;
    if (ready is! EditorReady || ready.view == null) {
      throw StateError('the image did not open');
    }
    final view = ready.view!;
    // Colors as Less: the picture, not the wheel, is what the shot is
    // about. An ellipse around the moon, for the effect to preview in.
    bloc
      ..add(const ColorsMoreToggledEvent())
      ..add(const ToolSelectedEvent(Tool.ellipseSelect));
    final from = view.toScreen(const ui.Offset(470, 30));
    final to = view.toScreen(const ui.Offset(790, 280));
    bloc.add(
      CanvasPointerDownEvent(
        position: from,
        button: CanvasButton.primary,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    for (var i = 1; i <= 12; i++) {
      bloc.add(CanvasPointerMovedEvent(ui.Offset.lerp(from, to, i / 12)!));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    bloc.add(
      CanvasPointerUpEvent(
        position: to,
        button: CanvasButton.primary,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    await _settle(const Duration(milliseconds: 900));
  }

  /// A night landscape of six layers made with the core's own tools and
  /// effects, so the picture shows what the program does: a sky
  /// gradient, a haze of Clouds screened over it, stars, a moon with a
  /// halo of a radial gradient, three ranges of hills as freeform
  /// shapes, and the title in the Text tool. The moon's layer is active
  /// (the effect scene blurs it). The layers are named in the language
  /// of the shot.
  static Future<String> _makeLayeredFile(String language) async {
    final names = switch (language) {
      'uk' => const ['Небо', 'Серпанок', 'Зорі', 'Місяць', 'Пагорби', 'Назва'],
      _ => const ['Sky', 'Haze', 'Stars', 'Moon', 'Hills', 'Title'],
    };
    const width = 800;
    const height = 500;
    const white = Rgba8(r: 255, g: 255, b: 255, a: 255);
    final image = PaintImage.blank(
      width: width,
      height: height,
      background: white,
      colors: const UserColors(primary: white, secondary: white),
    );
    var settings = defaultToolSettings();
    var layer = 0;

    void colors(Rgba8 primary, [Rgba8? secondary]) => image.setColors(
      colors: UserColors(primary: primary, secondary: secondary ?? primary),
      settings: settings,
    );
    void drag(Tool tool, List<(double, double)> points, {bool finish = true}) {
      final (x0, y0) = points.first;
      image.press(
        tool: tool,
        settings: settings,
        x: x0,
        y: y0,
        secondary: false,
        ctrl: false,
        alt: false,
        shift: false,
        time: 0,
      );
      for (final (x, y) in points.skip(1)) {
        image.moveTo(settings: settings, x: x, y: y);
      }
      final (x1, y1) = points.last;
      image.release(
        settings: settings,
        x: x1,
        y: y1,
        secondary: false,
        ctrl: false,
        alt: false,
        shift: false,
        time: 1,
      );
      if (finish) {
        image.finish();
      }
    }

    void name(
      String name, {
      BlendMode blend = BlendMode.normal,
      int opacity = 255,
    }) {
      image.setLayerProperties(
        index: layer,
        properties: LayerProperties(
          name: name,
          visible: true,
          opacity: opacity,
          blendMode: blend,
          isBackground: layer == 0,
        ),
      );
    }

    void addLayer() {
      image.run(id: 'add_layer');
      layer += 1;
    }

    // An effect through its dialog, as Effects > ... applies it: the
    // render runs on a worker, so the dialog is polled until it is in.
    Future<void> effect(String id, Map<String, double> params) async {
      if (!image.openPreview(id: id)) {
        throw StateError('no dialog for $id');
      }
      for (final MapEntry(:key, :value) in params.entries) {
        image.setPreviewParam(name: key, values: [value]);
      }
      for (var i = 0; i < 400; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 30));
        if (!image.pollPreview().rendering) {
          break;
        }
      }
      if (!image.endPreview(ok: true)) {
        for (var i = 0; i < 400; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          if (!image.pollPreview().open) {
            break;
          }
        }
      }
    }

    // The sky: night blue above, dusk plum at the horizon.
    colors(
      const Rgba8(r: 12, g: 20, b: 56, a: 255),
      const Rgba8(r: 118, g: 52, b: 104, a: 255),
    );
    settings = settings.copyWith(gradient: GradientKind.linear);
    drag(Tool.gradient, [(400, 0), (400, height.toDouble())]);
    name(names[0]);

    // A haze: Clouds, screened faintly over the sky.
    addLayer();
    await effect('effect:clouds', {'scale': 340, 'power': 0.6});
    name(names[1], blend: BlendMode.screen, opacity: 54);

    // Stars: small filled ellipses, scattered the same way every time.
    addLayer();
    settings = settings.copyWith(shapeDraw: ShapeDraw.interior, width: 1);
    var seed = 20261029;
    double next() {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      return seed / 0x7fffffff;
    }

    for (var i = 0; i < 110; i++) {
      final x = next() * width;
      final y = next() * 300;
      final size = 1.2 + next() * 2.6;
      final alpha = 120 + (next() * 135).round();
      colors(Rgba8(r: 255, g: 250, b: 236, a: alpha));
      drag(Tool.ellipse, [(x - size, y - size), (x + size, y + size)]);
    }
    name(names[2]);

    // The moon: a halo of a radial gradient fading to nothing, then the
    // disc.
    addLayer();
    colors(
      const Rgba8(r: 255, g: 234, b: 186, a: 150),
      const Rgba8(r: 255, g: 234, b: 186, a: 0),
    );
    settings = settings.copyWith(gradient: GradientKind.radial);
    drag(Tool.gradient, [(640, 150), (830, 150)]);
    colors(const Rgba8(r: 255, g: 246, b: 214, a: 255));
    drag(Tool.ellipse, [(598, 108), (682, 192)]);
    name(names[3]);

    // Three ranges of hills, nearer ones darker.
    addLayer();
    colors(const Rgba8(r: 58, g: 46, b: 96, a: 255));
    drag(Tool.freeformShape, [
      (0, 300),
      (80, 282),
      (170, 262),
      (260, 276),
      (340, 300),
      (430, 286),
      (520, 268),
      (610, 290),
      (700, 282),
      (800, 296),
      (800, 500),
      (0, 500),
    ]);
    colors(const Rgba8(r: 36, g: 32, b: 68, a: 255));
    drag(Tool.freeformShape, [
      (0, 346),
      (70, 332),
      (160, 318),
      (250, 334),
      (350, 352),
      (450, 330),
      (560, 316),
      (680, 338),
      (800, 330),
      (800, 500),
      (0, 500),
    ]);
    colors(const Rgba8(r: 20, g: 20, b: 42, a: 255));
    drag(Tool.freeformShape, [
      (0, 392),
      (90, 372),
      (200, 360),
      (300, 380),
      (420, 374),
      (540, 392),
      (660, 366),
      (760, 380),
      (800, 388),
      (800, 500),
      (0, 500),
    ]);
    name(names[4]);

    // The title: a click of the Text tool opens the caret, the typing
    // follows, and finishing commits it (a finish before the typing
    // would drop the caret instead).
    addLayer();
    colors(const Rgba8(r: 246, g: 240, b: 232, a: 255));
    settings = settings.copyWith(fontSize: 56, bold: true);
    drag(Tool.text, [(56, 44)], finish: false);
    if (!image.typeText(settings: settings, text: 'Paintbox')) {
      throw StateError('the Text tool did not take the title');
    }
    image.finish();
    name(names[5]);

    image.setActiveLayer(index: 3);
    final path = p.join(Directory.systemTemp.path, 'paintbox-night.ora');
    final snapshot = image.snapshot();
    await writeSnapshot(snapshot: snapshot, path: path, jpegQuality: 95);
    snapshot.dispose();
    image.dispose();
    return path;
  }

  Future<void> _capture(GlobalKey boundary, String name) async {
    await WidgetsBinding.instance.endOfFrame;
    final render = boundary.currentContext?.findRenderObject();
    if (render is! RenderRepaintBoundary) {
      throw StateError('nothing to capture');
    }
    final ratio =
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final image = await render.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final stem = target.endsWith('.png')
        ? target.substring(0, target.length - 4)
        : target;
    final file = File('$stem-$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    AppLog.startup('saved ${file.path}', where: 'ScreenshotRunner');
  }

  static Future<void> _settle(Duration time) async {
    await Future<void>.delayed(time);
    await WidgetsBinding.instance.endOfFrame;
  }
}
