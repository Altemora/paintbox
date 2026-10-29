import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:editor_ui/editor_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

import 'bridge_loader.dart';

class _FakeFiles implements FileDialogService {
  String? saveAs;
  List<String> open = const [];

  @override
  Future<List<String>> openImages({String? directory}) async => open;

  @override
  Future<String?> openPicture({String? directory}) async => null;

  @override
  Future<String?> saveImage({
    required String suggestedName,
    String? directory,
  }) async => saveAs;
}

void main() {
  setUpAll(BridgeLoader.load);

  late EditorBloc bloc;
  late EventBusService bus;
  late _FakeFiles files;
  late List<ActionEvent> actions;
  late StreamSubscription<ActionEvent> listening;
  late Directory dir;
  late ClipboardRepository clipboard;

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 30));

  EditorReady ready() => bloc.state as EditorReady;

  Future<void> key(
    String key, {
    String? letter,
    bool ctrl = false,
    bool shift = false,
  }) async {
    bloc.add(
      KeyPressedEvent(
        key: key,
        letter: letter,
        ctrl: ctrl,
        shift: shift,
        alt: false,
      ),
    );
    await settle();
  }

  /// A drag in image pixels, through the canvas's own events.
  Future<void> drag(
    Offset from,
    Offset to, {
    CanvasButton button = CanvasButton.primary,
  }) async {
    final view = ready().view!;
    bloc.add(
      CanvasPointerDownEvent(
        position: view.toScreen(from),
        button: button,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    for (var i = 1; i <= 8; i++) {
      bloc.add(
        CanvasPointerMovedEvent(view.toScreen(Offset.lerp(from, to, i / 8)!)),
      );
    }
    // Longer than the 50 ms a selection takes for a click.
    await Future<void>.delayed(const Duration(milliseconds: 70));
    bloc.add(
      CanvasPointerUpEvent(
        position: view.toScreen(to),
        button: button,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    await settle();
  }

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('paintbox-bloc');
    bus = EventBusService();
    files = _FakeFiles();
    actions = [];
    listening = bus.actions.listen(actions.add);
    bloc =
        EditorBloc(
            images: ImagesRepository(),
            settings: SettingsRepository(null),
            clipboard: clipboard = ClipboardRepository(
              MemoryClipboardService(),
            ),
            files: files,
            eventBus: bus,
            scheduleFrame: Timer.run,
          )
          ..add(const ViewportChangedEvent(Size(1000, 800), 1))
          ..add(const EditorStartedEvent());
    await settle();
  });

  tearDown(() async {
    await bloc.close();
    await listening.cancel();
    await bus.dispose();
    dir.deleteSync(recursive: true);
  });

  test('starts with one untitled 800 × 600 image', () {
    final s = ready();
    expect(s.tabs, hasLength(1));
    expect(s.tabs.single.title.untitledNumber, 1);
    expect(s.image?.width, 800);
    expect(s.image?.height, 600);
    expect(s.image?.history, ['New Image']);
    expect(s.tool, Tool.paintbrush);
    expect(actions.whereType<CanvasTilesAction>(), isNotEmpty);
  });

  test('the accent and the language are chosen and kept', () async {
    bloc.add(const AccentChosenEvent(AccentChoice.green));
    await settle();
    expect(ready().accent, AccentChoice.green);
    bloc
      ..add(const AccentChosenEvent(AccentChoice.custom, custom: 0xFF123456))
      ..add(const LanguageChosenEvent('de'));
    await settle();
    expect(ready().accent, AccentChoice.custom);
    expect(ready().customAccent, 0xFF123456);
    expect(ready().language, 'de');
    bloc
      ..add(const AccentChosenEvent(AccentChoice.red))
      ..add(const LanguageChosenEvent(null));
    await settle();
    // The custom colour stays for the next time it is chosen.
    expect(ready().customAccent, 0xFF123456);
    expect(ready().language, isNull);
  });

  test('a stroke is a step; Ctrl+Z undoes it, Ctrl+Y redoes it', () async {
    await drag(const Offset(100, 100), const Offset(300, 200));
    expect(ready().image?.history, ['New Image', 'Paintbrush']);
    expect(ready().activeTab?.isModified, isTrue);
    expect(ready().canUndo, isTrue);
    await key('Z', ctrl: true);
    expect(ready().image?.historyPosition, 0);
    expect(ready().activeTab?.isModified, isFalse);
    await key('Y', ctrl: true);
    expect(ready().image?.historyPosition, 1);
  });

  test('tool letters choose and cycle tools', () async {
    await key('S', letter: 's');
    expect(ready().tool, Tool.rectangleSelect);
    await key('S', letter: 's');
    expect(ready().tool, Tool.lassoSelect);
    await key('O', letter: 'o');
    expect(ready().tool, Tool.lineCurve);
    await key('B', letter: 'b');
    expect(ready().tool, Tool.paintbrush);
  });

  test('Text types at the caret; Esc keeps it as one step', () async {
    await key('T', letter: 't');
    expect(ready().tool, Tool.text);
    await drag(const Offset(50, 50), const Offset(50, 50));
    expect(ready().isTyping, isTrue);
    expect(ready().image?.guide, hasLength(2));
    bloc
      ..add(const TextTypedEvent('Привіт'))
      ..add(const TextKeyPressedEvent(TextKey.enter, ctrl: false))
      ..add(const TextTypedEvent('ok'));
    await settle();
    expect(ready().image?.stamp.isEditing, isTrue);
    await key('Escape');
    expect(ready().isTyping, isFalse);
    expect(ready().image?.history, ['New Image', 'Text']);
  });

  test('Line / Curve: , . / cycle the ends and the dash', () async {
    await key('O', letter: 'o');
    await key('Comma', letter: ',');
    await key('Period', letter: '.');
    await key('Slash', letter: '/');
    final s = ready().toolSettings;
    expect(s.lineStart, LineCap.arrow);
    expect(s.dash, DashStyle.dash);
    expect(s.lineEnd, LineCap.arrow);
  });

  test('[ and ] change the width; X swaps the colours', () async {
    final width = ready().toolSettings.width;
    await key(']', letter: ']');
    expect(ready().toolSettings.width, width + 1);
    await key('[', letter: '[', ctrl: true);
    expect(ready().toolSettings.width, 1);
    final colors = ready().colors;
    await key('X', letter: 'x');
    expect(ready().colors.primary, colors.secondary);
    expect(ready().colors.secondary, colors.primary);
  });

  test('a key of a command with nothing to act on does nothing', () async {
    await key('Delete');
    expect(ready().image?.history, ['New Image']);
    expect(ready().canRun('erase_selection'), isFalse);
    await key('A', ctrl: true);
    expect(ready().image?.hasSelection, isTrue);
    expect(ready().image?.outline.isEmpty, isFalse);
    expect(ready().canRun('erase_selection'), isTrue);
    await key('Delete');
    expect(ready().image?.history.last, 'Erase Selection');
  });

  test('a selection drag selects; Esc deselects', () async {
    await key('S', letter: 's');
    await drag(const Offset(10, 10), const Offset(110, 60));
    final bounds = ready().image!.stamp.selectionBounds;
    expect(bounds.width, 100);
    expect(bounds.height, 50);
    await key('Escape');
    expect(ready().image?.hasSelection, isFalse);
  });

  test('a previewing dialog holds the keys; Esc cancels it', () async {
    bloc.add(const CommandInvokedEvent('effect:gaussian_blur'));
    await settle();
    expect(ready().preview?.id, 'effect:gaussian_blur');
    expect(ready().canRun('undo'), isFalse);
    await key('B', letter: 'b');
    await key('Escape');
    expect(ready().preview, isNull);
    expect(ready().image?.history, ['New Image']);
  });

  test('an adjustment previews and OK makes it one step', () async {
    bloc
      ..add(const CommandInvokedEvent('adjust:brightness_contrast'))
      ..add(const PreviewParamChangedEvent('brightness', [-40]));
    await settle();
    expect(ready().preview?.params.first.values, [-40]);
    bloc.add(const PreviewEndedEvent(ok: true));
    await settle();
    expect(ready().preview, isNull);
    expect(ready().image?.history.last, 'Brightness / Contrast');
  });

  test('layers: add, hide, merge', () async {
    bloc.add(const CommandInvokedEvent('add_layer'));
    await settle();
    expect(ready().image?.layers, hasLength(2));
    expect(ready().image?.activeLayer, 1);
    bloc.add(const LayerVisibilityToggledEvent(1));
    await settle();
    expect(ready().image?.layers[1].properties.visible, isFalse);
    // Hiding the active layer made the one below active.
    expect(ready().image?.activeLayer, 0);
    bloc
      ..add(const LayerVisibilityToggledEvent(1))
      ..add(const LayerSelectedEvent(1));
    await settle();
    bloc.add(const CommandInvokedEvent('merge_layer_down'));
    await settle();
    expect(ready().image?.layers, hasLength(1));
  });

  test(
    'Save As writes the file, the tab is saved, the file is recent',
    () async {
      await drag(const Offset(50, 50), const Offset(60, 90));
      files.saveAs = p.join(dir.path, 'painted.ora');
      bloc.add(const CommandInvokedEvent('save_as'));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(File(files.saveAs!).existsSync(), isTrue);
      expect(ready().activeTab?.isModified, isFalse);
      expect(ready().activeTab?.title.fileName, 'painted.ora');
      expect(ready().recentFiles.first, files.saveAs);
      expect(actions.whereType<ImageSavedAction>(), hasLength(1));
    },
  );

  test(
    'dropped files open as new images; from temp they are untitled',
    () async {
      final maker = ImagesRepository();
      final paths = [
        for (final name in ['a.png', 'b.png']) p.join(dir.path, name),
      ];
      for (final path in paths) {
        final blank = maker.createBlank(
          width: 20,
          height: 10,
          background: const Rgba8(r: 9, g: 9, b: 9, a: 255),
          colors: ready().colors,
        );
        await maker.save(blank.id, path, jpegQuality: 90);
        maker.close(blank.id);
      }
      // A browser's picture lands in the temporary folder, as the test's do.
      bloc.add(OpenPathsEvent(paths, dropped: true));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(ready().tabs, hasLength(3));
      expect(ready().tabs.skip(1).map((t) => t.title.fileName), [null, null]);
      expect(ready().recentFiles, isEmpty);
      expect(ready().image?.width, 20);
      // Chosen with File > Open (or from Recent), the file keeps its path.
      bloc.add(OpenPathsEvent([paths.first]));
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(ready().tabs, hasLength(4));
      expect(ready().tabs.last.title.fileName, 'a.png');
      expect(ready().recentFiles, [paths.first]);
    },
  );

  test('a tab and a layer dragged to another place', () async {
    bloc.add(const NewImageConfirmedEvent(30, 20));
    await settle();
    final ids = [for (final t in ready().tabs) t.id];
    bloc.add(TabMovedEvent(ids.last, 0));
    await settle();
    expect([for (final t in ready().tabs) t.id], ids.reversed);
    bloc
      ..add(const CommandInvokedEvent('add_layer'))
      ..add(const CommandInvokedEvent('add_layer'));
    await settle();
    bloc.add(const LayerMovedEvent(2, 0));
    await settle();
    expect(
      [for (final l in ready().image!.layers) l.properties.name],
      ['Layer 3', 'Background', 'Layer 2'],
    );
    expect(ready().image?.activeLayer, 0);
    expect(ready().image?.history.last, 'Move Layer Down');
  });

  test('a flat format with layers asks first, then flattens', () async {
    bloc.add(const CommandInvokedEvent('add_layer'));
    await settle();
    files.saveAs = p.join(dir.path, 'flat.png');
    bloc.add(const CommandInvokedEvent('save_as'));
    await settle();
    final ask = actions.whereType<AskSaveOptionsAction>().single;
    expect(ask.flatten, isTrue);
    expect(ask.jpegQuality, isNull);
    bloc.add(
      SaveConfirmedEvent(imageId: ask.imageId, path: ask.path, jpegQuality: 95),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(File(ask.path).existsSync(), isTrue);
    expect(ready().image?.layers, hasLength(1));
    expect(ready().image?.history.last, 'Flatten');
  });

  test('closing a changed image asks; not saving closes it', () async {
    await drag(const Offset(5, 5), const Offset(50, 50));
    final id = ready().activeId!;
    bloc.add(TabCloseRequestedEvent(id));
    await settle();
    expect(actions.whereType<AskCloseAction>().single.imageId, id);
    expect(ready().tabs, hasLength(1));
    bloc.add(CloseAnsweredEvent(id, save: false));
    await settle();
    expect(ready().tabs, isEmpty);
    expect(ready().image, isNull);
  });

  test('copy and paste into a new layer lift the pixels', () async {
    await key('A', ctrl: true);
    await key('C', ctrl: true);
    await key('V', ctrl: true, shift: true);
    expect(ready().image?.layers, hasLength(2));
    expect(ready().tool, Tool.moveSelectedPixels);
    await key('Enter');
    expect(ready().image?.hasSelection, isFalse);
  });

  test('a paste larger than the canvas offers to expand it', () async {
    final wide = PaintImage.blank(
      width: 1000,
      height: 100,
      background: const Rgba8(r: 200, g: 10, b: 10, a: 255),
      colors: ready().colors,
    );
    wide.run(id: 'select_all');
    await clipboard.put(wide.copy()!);
    wide.dispose();
    bloc.add(const CommandInvokedEvent('paste'));
    await settle();
    expect(actions.whereType<AskExpandCanvasAction>(), hasLength(1));
    bloc.add(const ExpandAnsweredEvent(expand: true));
    await settle();
    expect(ready().image?.width, 1000);
    expect(ready().image?.height, 600);
    expect(ready().tool, Tool.moveSelectedPixels);
  });

  test('Space and the right button scroll toward the pointer', () async {
    bloc.add(const CommandInvokedEvent('zoom_in'));
    bloc.add(const CommandInvokedEvent('zoom_in'));
    await settle();
    final before = ready().view!.center;
    bloc
      ..add(const SpaceHeldEvent(true))
      ..add(
        const CanvasPointerDownEvent(
          position: Offset(950, 400),
          button: CanvasButton.secondary,
          ctrl: false,
          shift: false,
          alt: false,
        ),
      );
    await Future<void>.delayed(const Duration(milliseconds: 120));
    bloc.add(
      const CanvasPointerUpEvent(
        position: Offset(950, 400),
        button: CanvasButton.secondary,
        ctrl: false,
        shift: false,
        alt: false,
      ),
    );
    await settle();
    expect(ready().view!.center.dx, greaterThan(before.dx));
    expect(ready().panning, isFalse);
  });

  test('the Curves dialog takes points and previews them', () async {
    bloc.add(const CommandInvokedEvent('adjust:curves'));
    await settle();
    final curves = ready().preview!.curves!;
    expect(curves.luminosity, [(0, 0), (255, 255)]);
    bloc.add(
      CurvesChangedEvent(
        PaintCurves(
          mode: curves.mode,
          // White stays white unless the top end moves.
          luminosity: const [(0, 0), (128, 60), (255, 200)],
          red: curves.red,
          green: curves.green,
          blue: curves.blue,
        ),
      ),
    );
    await settle();
    expect(ready().preview!.curves!.luminosity, hasLength(3));
    bloc.add(const PreviewEndedEvent(ok: true));
    await settle();
    expect(ready().image?.history.last, 'Curves');
  });

  test('the middle button mid-stroke leaves no button held', () async {
    final view = ready().view!;
    CanvasPointerDownEvent down(CanvasButton b) => CanvasPointerDownEvent(
      position: view.toScreen(const Offset(100, 100)),
      button: b,
      ctrl: false,
      shift: false,
      alt: false,
    );
    CanvasPointerUpEvent up(CanvasButton b) => CanvasPointerUpEvent(
      position: view.toScreen(const Offset(200, 100)),
      button: b,
      ctrl: false,
      shift: false,
      alt: false,
    );
    bloc
      ..add(down(CanvasButton.secondary))
      ..add(CanvasPointerMovedEvent(view.toScreen(const Offset(200, 100))))
      ..add(down(CanvasButton.middle))
      ..add(up(CanvasButton.secondary))
      ..add(up(CanvasButton.middle));
    await settle();
    final steps = ready().image!.history.length;
    expect(ready().image!.stamp.isPressed, isFalse);
    bloc.add(CanvasPointerMovedEvent(view.toScreen(const Offset(300, 300))));
    await settle();
    expect(ready().image!.history.length, steps);
    expect(ready().panning, isFalse);
  });

  test('zoom steps and the Zoom tool', () async {
    bloc.add(const CommandInvokedEvent('zoom_in'));
    await settle();
    expect(ready().view?.zoom, 2);
    bloc.add(const CommandInvokedEvent('actual_size'));
    await settle();
    expect(ready().view?.zoom, 1);
    await key('Z', letter: 'z');
    expect(ready().tool, Tool.zoom);
    await drag(const Offset(400, 300), const Offset(400, 300));
    expect(ready().view?.zoom, 2);
    await drag(
      const Offset(400, 300),
      const Offset(400, 300),
      button: CanvasButton.secondary,
    );
    expect(ready().view?.zoom, 1);
  });
}
