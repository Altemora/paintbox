import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/editor_ui.dart';
import 'package:editor_ui/src/components/canvas_component.dart';
import 'package:editor_ui/src/widgets/reorder_list_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ActionListener;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paint_logic/paint_logic.dart';

import 'bridge_loader.dart';

class _NoFiles implements FileDialogService {
  @override
  String allImagesLabel = 'Images';

  @override
  Future<List<String>> openImages({String? directory}) async => const [];

  @override
  Future<String?> openPicture({String? directory}) async => null;

  @override
  Future<String?> saveImage({
    required String suggestedName,
    String? directory,
  }) async => null;
}

void main() {
  setUpAll(() async {
    await BridgeLoader.load();
    injector
      ..registerSingleton<EventBusService>(EventBusService())
      ..registerSingleton<AppToastService>(AppToastService())
      ..registerSingleton<SettingsRepository>(SettingsRepository(null))
      ..registerSingleton<ImagesRepository>(ImagesRepository())
      ..registerSingleton<ClipboardRepository>(
        ClipboardRepository(MemoryClipboardService()),
      )
      ..registerSingleton<FileDialogService>(_NoFiles())
      ..registerSingleton<Stream<int>>(
        const Stream<int>.empty(),
        instanceName: 'previewWakes',
      );
  });

  Future<EditorBloc> pumpEditor(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late EditorBloc bloc;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('uk'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: AppToastLayerComponent(
          child: EditorPage(manageWindow: false, onBloc: (b) => bloc = b),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    return bloc;
  }

  testWidgets('the window shows the menus, the windows and the image', (
    tester,
  ) async {
    await pumpEditor(tester);
    expect(find.text('Файл'), findsOneWidget);
    expect(find.text('Ефекти'), findsOneWidget);
    expect(find.text('Інструменти'), findsOneWidget);
    expect(find.text('Історія'), findsOneWidget);
    expect(find.text('Шари'), findsWidgets);
    expect(find.text('Кольори'), findsOneWidget);
    expect(find.byTooltip('Без назви 1'), findsOneWidget);
    expect(find.text('Нове зображення'), findsOneWidget);
    expect(find.text('Background'), findsOneWidget);
    expect(find.text('800 × 600'), findsOneWidget);
  });

  testWidgets('a tool button makes the tool active in the tool bar', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    await tester.tap(find.byTooltip('Чарівна паличка (S)'));
    await tester.pump();
    expect(bloc.state, isA<EditorReady>());
    expect((bloc.state as EditorReady).tool, Tool.magicWand);
    expect(find.text('Допуск'), findsOneWidget);
    expect(find.text('Поширення'), findsOneWidget);
  });

  testWidgets('a few settings are icon buttons, the many are named', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    bloc.add(const ToolSelectedEvent(Tool.magicWand));
    await tester.pump();
    // Flood Mode is two icons with their names in the tooltips.
    await tester.tap(find.byTooltip('Усе зображення'));
    await tester.pump();
    expect(
      (bloc.state as EditorReady).toolSettings.floodMode,
      FloodMode.global,
    );
    bloc.add(const ToolSelectedEvent(Tool.text));
    await tester.pump();
    expect(find.text('Жирний'), findsNothing);
    await tester.tap(find.byTooltip('Жирний'));
    await tester.pump();
    expect((bloc.state as EditorReady).toolSettings.bold, isTrue);
    // The font stays a name in a menu.
    expect(find.text('Шрифт'), findsOneWidget);
  });

  testWidgets('Window and Help are buttons; Colors has a Less mode', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    expect(find.text('Вікно'), findsNothing);
    expect(find.text('Довідка'), findsNothing);
    expect(find.byTooltip('Довідка (F1)'), findsOneWidget);
    // A menu is as tall as the corner's buttons.
    expect(
      tester.getSize(find.widgetWithText(SubmenuButton, 'Файл')).height,
      ControlSize.button,
    );
    await tester.tap(find.byTooltip('Менше'));
    await tester.pumpAndSettle();
    expect((bloc.state as EditorReady).panels.colorsMore, isFalse);
    expect(find.byTooltip('Більше'), findsOneWidget);
    await tester.tap(find.byTooltip('Більше'));
    await tester.pumpAndSettle();
    expect((bloc.state as EditorReady).panels.colorsMore, isTrue);
  });

  testWidgets('F5 hides the Tools window and shows it again', (tester) async {
    await pumpEditor(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();
    expect(find.text('Інструменти'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();
    expect(find.text('Інструменти'), findsOneWidget);
  });

  testWidgets('Add Layer in the Layers window adds a row', (tester) async {
    await pumpEditor(tester);
    await tester.tap(find.byTooltip('Додати шар (Ctrl+Shift+N)'));
    await tester.pump();
    await tester.pump();
    expect(find.text('Layer 2'), findsOneWidget);
    expect(find.text('Додати шар'), findsOneWidget);
  });

  testWidgets('keys typed in a field stay in the field', (tester) async {
    final bloc = await pumpEditor(tester);
    final tool = (bloc.state as EditorReady).tool;
    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect((bloc.state as EditorReady).tool, tool);
    expect((bloc.state as EditorReady).image?.history, ['New Image']);
  });

  testWidgets('an effect opens its dialog over the canvas; Cancel closes it', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    bloc.add(const CommandInvokedEvent('effect:pixelate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Пікселізація'), findsOneWidget);
    expect(find.text('Розмір клітинки'), findsOneWidget);
    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();
    expect(find.text('Розмір клітинки'), findsNothing);
  });

  /// A mouse drag in steps, as a hand makes it.
  Future<void> dragBy(
    WidgetTester tester,
    Offset from,
    Offset by, {
    int buttons = kPrimaryMouseButton,
    bool marked = false,
  }) async {
    final gesture = await tester.startGesture(
      from,
      kind: PointerDeviceKind.mouse,
      buttons: buttons,
    );
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(by / 12);
      await tester.pump(const Duration(milliseconds: 16));
    }
    if (marked) {
      // Before letting go, a line shows where the item will go.
      expect(find.byKey(ReorderListWidget.markerKey), findsOneWidget);
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('a tab dragged along the strip changes the order', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    bloc.add(const NewImageConfirmedEvent(30, 20));
    await tester.pumpAndSettle();
    EditorReady state() => bloc.state as EditorReady;
    final ids = [for (final t in state().tabs) t.id];
    // Other tests share the images' numbering.
    String name(int i) => 'Без назви ${state().tabs[i].title.untitledNumber}';
    final first = tester.getCenter(find.byTooltip(name(0)));
    final second = tester.getCenter(find.byTooltip(name(1)));
    await dragBy(
      tester,
      second,
      Offset(first.dx - second.dx - 30, 0),
      marked: true,
    );
    expect([for (final t in state().tabs) t.id], ids.reversed);
    // The list after the tabs steps between them.
    await tester.tap(find.byTooltip('Відкриті зображення'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Наступне зображення'));
    await tester.pumpAndSettle();
    expect(state().activeId, ids.first);
  });

  testWidgets('a layer dragged in the Layers window moves in one step', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    await tester.tap(find.byTooltip('Додати шар (Ctrl+Shift+N)'));
    await tester.pumpAndSettle();
    EditorReady state() => bloc.state as EditorReady;
    expect(
      [for (final l in state().image!.layers) l.properties.name],
      ['Background', 'Layer 2'],
    );
    await dragBy(
      tester,
      tester.getCenter(find.text('Layer 2')),
      const Offset(0, 2 * (ControlSize.row + Space.xs)),
      marked: true,
    );
    expect(
      [for (final l in state().image!.layers) l.properties.name],
      ['Layer 2', 'Background'],
    );
    expect(state().image?.history.last, 'Move Layer Down');
  });

  testWidgets('a swatch dropped on the secondary colour becomes it', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    EditorReady state() => bloc.state as EditorReady;
    final red = state().palette[2];
    final swatch = find.byType(Draggable<Rgba8>).at(2);
    final target = find.byTooltip(
      'Додатковий колір: ним малює права кнопка миші',
    );
    final from = tester.getCenter(swatch);
    await dragBy(tester, from, tester.getCenter(target) - from);
    expect(state().colors.secondary, red);
    expect(state().colors.primary, isNot(red));
  });

  testWidgets('a window dragged by its title stays there, remembered', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    EditorReady state() => bloc.state as EditorReady;
    await dragBy(
      tester,
      tester.getCenter(find.text('Історія')),
      const Offset(-200, 120),
    );
    final place = state().panels.placeOf('history');
    expect(place.dx, lessThan(-150));
    expect(place.dy, greaterThan(80));
    expect(
      injector<SettingsRepository>().getSettingsSync().panels.placeOf(
        'history',
      ),
      place,
    );
  });

  testWidgets('the middle button and Space with a drag move the view', (
    tester,
  ) async {
    final bloc = await pumpEditor(tester);
    EditorReady state() => bloc.state as EditorReady;
    // Zoomed in, so there is somewhere to scroll to.
    bloc
      ..add(const CommandInvokedEvent('zoom_in'))
      ..add(const CommandInvokedEvent('zoom_in'));
    await tester.pumpAndSettle();
    final centre = tester.getCenter(find.byType(CanvasComponent));
    final before = state().view!.center;
    await dragBy(
      tester,
      centre,
      const Offset(60, 40),
      buttons: kMiddleMouseButton,
    );
    final middle = state().view!.center;
    expect(middle.dx, lessThan(before.dx));
    expect(middle.dy, lessThan(before.dy));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await dragBy(tester, centre, const Offset(60, 40));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(state().view!.center.dx, lessThan(middle.dx));
    // Neither drag painted.
    expect(state().image?.history, ['New Image']);
  });
}
