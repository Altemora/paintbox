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
/// - `layers`: an OpenRaster file with two layers, opened as File > Open
///   opens it, with an elliptical selection drawn by the pointer;
/// - `effect`: the Gaussian Blur dialog previewing on that image.
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
            // Colors as Less, the Text tool's settings in the bar.
            bloc
              ..add(const ColorsMoreToggledEvent())
              ..add(const ToolSelectedEvent(Tool.text));
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
    await _drag(bloc, const ui.Offset(60, 40), const ui.Offset(60, 40));
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
    final path = await _makeLayeredFile();
    bloc.add(OpenPathsEvent([path]));
    await _settle(const Duration(milliseconds: 1200));
    final ready = bloc.state;
    if (ready is! EditorReady || ready.view == null) {
      throw StateError('the image did not open');
    }
    final view = ready.view!;
    bloc.add(const ToolSelectedEvent(Tool.ellipseSelect));
    final from = view.toScreen(const ui.Offset(150, 110));
    final to = view.toScreen(const ui.Offset(470, 330));
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

  /// Two layers made with the core's own tools: a gradient background
  /// and, above it, strokes and a filled ellipse on a transparent layer.
  static Future<String> _makeLayeredFile() async {
    final image = PaintImage.blank(
      width: 640,
      height: 440,
      background: const Rgba8(r: 255, g: 255, b: 255, a: 255),
      colors: const UserColors(
        primary: Rgba8(r: 47, g: 84, b: 160, a: 255),
        secondary: Rgba8(r: 234, g: 196, b: 120, a: 255),
      ),
    );
    final settings = defaultToolSettings().copyWith(width: 14);
    void drag(Tool tool, List<(double, double)> points, {bool right = false}) {
      final (x0, y0) = points.first;
      image.press(
        tool: tool,
        settings: settings,
        x: x0,
        y: y0,
        secondary: right,
        ctrl: false,
        alt: false,
        shift: false,
        time: 0,
      );
      for (final (x, y) in points.skip(1)) {
        image.moveTo(settings: settings, x: x, y: y);
      }
      final (x1, y1) = points.last;
      image
        ..release(
          settings: settings,
          x: x1,
          y: y1,
          secondary: right,
          ctrl: false,
          alt: false,
          shift: false,
          time: 1,
        )
        ..finish();
    }

    drag(Tool.gradient, [(0, 0), (320, 220), (640, 440)]);
    image.run(id: 'add_layer');
    image.setColors(
      colors: const UserColors(
        primary: Rgba8(r: 214, g: 64, b: 92, a: 255),
        secondary: Rgba8(r: 250, g: 250, b: 250, a: 220),
      ),
      settings: settings,
    );
    drag(Tool.paintbrush, [
      for (var i = 0; i <= 40; i++) (60.0 + i * 13, 340 - 120 * _wave(i / 40)),
    ]);
    drag(Tool.ellipse, [(380, 60), (560, 200)], right: true);
    final path = p.join(Directory.systemTemp.path, 'paintbox-two-layers.ora');
    final snapshot = image.snapshot();
    await writeSnapshot(snapshot: snapshot, path: path, jpegQuality: 95);
    snapshot.dispose();
    image.dispose();
    return path;
  }

  static double _wave(double t) =>
      0.5 - 0.5 * (t * 2 - 1) * (t * 2 - 1) * 2 + t;

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
