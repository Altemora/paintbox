import 'dart:io';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

import 'bridge_loader.dart';

void main() {
  setUpAll(BridgeLoader.load);

  group('CanvasView', () {
    const view = CanvasView(
      zoom: 1,
      center: Offset(50, 50),
      viewport: Size(200, 200),
    );

    test('screen and image are inverse', () {
      final v = view.zoomAbout(3, const Offset(40, 60));
      final at = v.toImage(const Offset(123, 77));
      final back = v.toScreen(at);
      expect(back.dx, closeTo(123, 1e-6));
      expect(back.dy, closeTo(77, 1e-6));
    });

    test('zoom about a point keeps it under the pointer', () {
      const anchor = Offset(30, 170);
      final before = view.toImage(anchor);
      final after = view.zoomAbout(4, anchor).toImage(anchor);
      expect(after.dx, closeTo(before.dx, 0.5));
      expect(after.dy, closeTo(before.dy, 0.5));
    });

    test('steps go through the table', () {
      expect(view.stepIn, 2);
      expect(view.stepOut, 0.66);
      expect(view.zoomAbout(32, Offset.zero).stepIn, 32);
    });

    test('100% is a physical pixel per image pixel', () {
      const hi = CanvasView(
        zoom: 1,
        center: Offset(50, 50),
        viewport: Size(200, 200),
        pixelRatio: 2,
      );
      expect(hi.scale, 0.5);
    });

    test('a small image stays centred when clamped', () {
      final moved = view.scrollBy(const Offset(500, 0)).clamped(100, 100);
      expect(moved.center, const Offset(50, 50));
    });

    test('fit puts the whole image in the area', () {
      final fitted = view.fit(1000, 500);
      final rect = fitted.imageRect(1000, 500);
      expect(rect.width, lessThanOrEqualTo(200));
      expect(rect.height, lessThanOrEqualTo(200));
    });
  });

  group('AppSettingsJsonMapper', () {
    test('settings come back as they were written', () {
      final settings = SettingsRepository.defaults()
          .copyWith(
            tool: Tool.magicWand,
            toolSettings: defaultToolSettings().copyWith(
              width: 17,
              floodMode: FloodMode.global,
              fixed: (16, 9),
            ),
            jpegQuality: 80,
            panels: const Panels(
              history: false,
              colorsMore: false,
              places: {'tools': Offset(12, -40)},
            ),
            theme: ThemeChoice.light,
            accent: AccentChoice.custom,
            customAccent: 0xFF12AB34,
            language: () => 'pl',
          )
          .withRecent('a.ora')
          .withRecent('b.png');
      final json = AppSettingsJsonMapper.encode(settings);
      final back = AppSettingsJsonMapper.decode(
        json,
        SettingsRepository.defaults(),
      );
      expect(back, settings);
      expect(back.recentFiles, ['b.png', 'a.ora']);
    });

    test('unknown or broken values fall back to the defaults', () {
      final defaults = SettingsRepository.defaults();
      final back = AppSettingsJsonMapper.decode({
        'tool': 'laser',
        'jpeg_quality': 900,
        'tool_settings': {'width': 100000, 'flood_mode': 'sideways'},
        'accent': 'neon',
        'language': '',
      }, defaults);
      expect(back.tool, defaults.tool);
      expect(back.jpegQuality, defaults.jpegQuality);
      expect(back.toolSettings.width, 500);
      expect(back.toolSettings.floodMode, FloodMode.local);
      expect(back.accent, AccentChoice.blue);
      expect(back.language, isNull);
    });

    test('the recent files keep eight, newest first, without repeats', () {
      var s = SettingsRepository.defaults();
      for (var i = 0; i < 10; i++) {
        s = s.withRecent('$i.png');
      }
      s = s.withRecent('5.png');
      expect(s.recentFiles.first, '5.png');
      expect(s.recentFiles.length, AppSettings.maxRecentFiles);
      expect(s.recentFiles.where((f) => f == '5.png').length, 1);
    });
  });

  group('ImagesRepository', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('paintbox-test'));
    tearDown(() => dir.deleteSync(recursive: true));

    const colors = UserColors(
      primary: Rgba8(r: 0, g: 0, b: 0, a: 255),
      secondary: Rgba8(r: 255, g: 255, b: 255, a: 255),
    );

    test(
      'a saved image opens again with its layers and active layer',
      () async {
        final repo = ImagesRepository();
        final blank = repo.createBlank(
          width: 32,
          height: 24,
          background: const Rgba8(r: 255, g: 255, b: 255, a: 255),
          colors: colors,
        );
        expect(blank.untitledNumber, 1);
        blank.image
          ..run(id: 'add_layer')
          ..setActiveLayer(index: 0);
        expect(blank.image.stamp().isModified, isTrue);
        final path = p.join(dir.path, 'two.ora');
        final saved = await repo.save(blank.id, path, jpegQuality: 95);
        expect(saved.path, path);
        expect(blank.image.stamp().isModified, isFalse);
        final opened = await repo.open(path, colors);
        expect(opened.image.layers().length, 2);
        // The Background was active when saved, and the file keeps that.
        expect(opened.image.stamp().activeLayer, 0);
        expect(repo.byPath(path)?.id, isNotNull);
        repo
          ..close(blank.id)
          ..close(opened.id);
        expect(repo.images, isEmpty);
      },
    );

    test('an unreadable file is a failure, not a crash', () async {
      final path = p.join(dir.path, 'broken.png');
      File(path).writeAsStringSync('not a picture');
      await expectLater(
        ImagesRepository().open(path, colors),
        throwsA(isA<PaintFailure>()),
      );
    });

    test('a missing file is a storage failure', () async {
      await expectLater(
        ImagesRepository().open(p.join(dir.path, 'none.png'), colors),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('ClipboardRepository', () {
    test('our own copy pastes where it came from', () async {
      final image = PaintImage.blank(
        width: 40,
        height: 30,
        background: const Rgba8(r: 10, g: 20, b: 30, a: 255),
        colors: const UserColors(
          primary: Rgba8(r: 0, g: 0, b: 0, a: 255),
          secondary: Rgba8(r: 255, g: 255, b: 255, a: 255),
        ),
      );
      image.run(id: 'select_all');
      final clip = image.copy();
      expect(clip, isNotNull);
      final service = MemoryClipboardService();
      final clipboard = ClipboardRepository(service);
      await clipboard.put(clip!);
      final taken = await clipboard.take();
      expect(identical(taken, clip), isTrue);
      expect(clipboard.isOwn(taken!), isTrue);
      // Another program's picture replaces ours.
      await service.writeImage(await encodeClipPng(clip: clip));
      final foreign = ClipboardRepository(service);
      final decoded = await foreign.take();
      expect(decoded?.width, 40);
      expect(foreign.isOwn(decoded!), isFalse);
    });
  });

  group('ImageSession', () {
    test('reads only what moved', () {
      final session = ImageSession(
        PaintImage.blank(
          width: 300,
          height: 40,
          background: const Rgba8(r: 10, g: 20, b: 30, a: 255),
          colors: const UserColors(
            primary: Rgba8(r: 0, g: 0, b: 0, a: 255),
            secondary: Rgba8(r: 255, g: 255, b: 255, a: 255),
          ),
        ),
      );
      final first = session.takeChange();
      expect(first.resetTiles, isTrue);
      expect(first.tiles, hasLength(2));
      expect(first.layers, hasLength(1));
      expect(first.history, ['New Image']);
      expect(first.available, contains('select_all'));
      expect(first.available, isNot(contains('deselect')));

      final quiet = session.takeChange();
      expect(quiet.tiles, isEmpty);
      expect(quiet.layers, isNull);
      expect(quiet.history, isNull);
      expect(quiet.outline, isNull);
      expect(quiet.available, isNull);

      session.image.run(id: 'select_all');
      final selected = session.takeChange();
      expect(selected.outline, isNotEmpty);
      expect(selected.history, ['New Image', 'Select All']);
      expect(selected.available, contains('deselect'));
      expect(selected.stamp.hasSelection, isTrue);

      session.image.run(id: 'add_layer');
      final layered = session.takeChange();
      expect(layered.layers, hasLength(2));
      expect(session.takeChange(reset: true).resetTiles, isTrue);
    });
  });
}
