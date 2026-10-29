import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/components/canvas_area_component.dart';
import 'package:editor_ui/src/components/canvas_component.dart';
import 'package:editor_ui/src/components/colors_panel_component.dart';
import 'package:editor_ui/src/components/command_bar_component.dart';
import 'package:editor_ui/src/components/editor_actions_component.dart';
import 'package:editor_ui/src/components/history_panel_component.dart';
import 'package:editor_ui/src/components/image_tabs_component.dart';
import 'package:editor_ui/src/components/layers_panel_component.dart';
import 'package:editor_ui/src/components/menu_bar_component.dart';
import 'package:editor_ui/src/components/preview_dialog_component.dart';
import 'package:editor_ui/src/components/status_bar_component.dart';
import 'package:editor_ui/src/components/tool_bar_component.dart';
import 'package:editor_ui/src/components/tools_panel_component.dart';
import 'package:editor_ui/src/components/window_toggles_component.dart';
import 'package:editor_ui/src/widgets/floating_panel_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The editor window's layout: the menu bar, the tool bar and the tabs
/// on top, the canvas with the floating windows, the status bar. It
/// owns the keyboard: keys are named the core's way and go to the bloc,
/// which decides what they do. Files dropped on the window open.
class EditorShellComponent extends StatefulWidget {
  const EditorShellComponent({super.key});

  @override
  State<EditorShellComponent> createState() => _EditorShellComponentState();
}

class _EditorShellComponentState extends State<EditorShellComponent> {
  /// History and Layers share a width, their edges in one line.
  static const _rightWidth = 240.0;

  final FocusNode _focus = FocusNode(debugLabel: 'editor');
  bool _dropping = false;

  /// A Space let go while the window was away is never heard: the window
  /// losing focus ends the temporary Pan.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onInactive: () =>
          context.read<EditorBloc>().add(const SpaceHeldEvent(false)),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// A text field keeps its keys.
  static bool get _typing =>
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorStateOfType<EditableTextState>() !=
      null;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final bloc = context.read<EditorBloc>();
    final keys = HardwareKeyboard.instance;
    final key = event.logicalKey;
    if (_modifiers.contains(key)) {
      bloc.add(
        ModifiersChangedEvent(
          ctrl: keys.isControlPressed || keys.isMetaPressed,
          shift: keys.isShiftPressed,
          alt: keys.isAltPressed,
        ),
      );
      return KeyEventResult.ignored;
    }
    if (_typing) {
      return KeyEventResult.ignored;
    }
    final state = bloc.state;
    if (state is EditorReady && state.isTyping && _typeText(bloc, event)) {
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent || event is KeyUpEvent) {
        bloc.add(SpaceHeldEvent(event is KeyDownEvent));
      }
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }
    // The key as labelled when it is Latin (AZERTY and QWERTZ keep their
    // letters), else by its place on a US layout (a Cyrillic layout still
    // has S where S is).
    final place = KeyPlaces.of(event.physicalKey);
    final name = KeyNames.of(key) ?? place;
    if (name == null) {
      return KeyEventResult.ignored;
    }
    final repeat = event is KeyRepeatEvent;
    // The arrows, the brackets and commands with Ctrl repeat; a held
    // letter does not cycle the tools.
    final ctrl = keys.isControlPressed || keys.isMetaPressed;
    if (repeat &&
        !ctrl &&
        !name.startsWith('Arrow') &&
        name != '[' &&
        name != ']') {
      return KeyEventResult.handled;
    }
    bloc.add(
      KeyPressedEvent(
        key: name,
        letter: KeyNames.letter(key) ?? KeyPlaces.letter(event.physicalKey),
        ctrl: ctrl,
        shift: keys.isShiftPressed,
        alt: keys.isAltPressed,
      ),
    );
    return KeyEventResult.handled;
  }

  /// The Text tool's caret takes characters and editing keys (Esc and
  /// commands with Ctrl go on as usual); true when it took the key.
  static bool _typeText(EditorBloc bloc, KeyEvent event) {
    if (event is KeyUpEvent) {
      return false;
    }
    final keys = HardwareKeyboard.instance;
    final ctrl = keys.isControlPressed || keys.isMetaPressed;
    final textKey = switch (event.logicalKey) {
      LogicalKeyboardKey.backspace => TextKey.backspace,
      LogicalKeyboardKey.delete => TextKey.delete,
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.numpadEnter => TextKey.enter,
      LogicalKeyboardKey.arrowLeft => TextKey.left,
      LogicalKeyboardKey.arrowRight => TextKey.right,
      LogicalKeyboardKey.arrowUp => TextKey.up,
      LogicalKeyboardKey.arrowDown => TextKey.down,
      LogicalKeyboardKey.home => TextKey.home,
      LogicalKeyboardKey.end => TextKey.end,
      _ => null,
    };
    if (textKey != null) {
      bloc.add(TextKeyPressedEvent(textKey, ctrl: ctrl));
      return true;
    }
    final character = event.character;
    // Ctrl or Alt alone are commands; both together are AltGr, which
    // types. On macOS Option alone types too (é, ™).
    final option =
        defaultTargetPlatform == TargetPlatform.macOS &&
        keys.isAltPressed &&
        !ctrl;
    if (ctrl != keys.isAltPressed && !option) {
      return false;
    }
    if (character == null ||
        character.isEmpty ||
        character.codeUnitAt(0) < 32) {
      return false;
    }
    bloc.add(TextTypedEvent(character));
    return true;
  }

  static final _modifiers = {
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
    LogicalKeyboardKey.metaLeft,
    LogicalKeyboardKey.metaRight,
  };

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return EditorActionsComponent(
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Listener(
          // A click anywhere outside a field gives the keys back to the
          // editor.
          onPointerDown: (_) {
            // After the event: a field left by this click lets go of the
            // focus in its own handler, which runs after this one.
            unawaited(
              Future.microtask(() {
                if (mounted && !_typing) {
                  _focus.requestFocus();
                }
              }),
            );
          },
          child: DropTarget(
            onDragEntered: (_) => setState(() => _dropping = true),
            onDragExited: (_) => setState(() => _dropping = false),
            onDragDone: (details) {
              setState(() => _dropping = false);
              // As Paint.NET: folders are left out, each file a new image.
              final paths = [
                for (final f in details.files)
                  if (f is! DropItemDirectory) f.path,
              ];
              if (paths.isNotEmpty) {
                bloc.add(OpenPathsEvent(paths, dropped: true));
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const GlassPanel(
                  radius: 0,
                  border: false,
                  child: Column(
                    children: [
                      // As Paint.NET 5: the menus over the commands; beside
                      // them the open images, two rows high; in the corner
                      // the windows and settings. Then the tool's settings.
                      SizedBox(
                        height: 2 * ControlSize.bar + 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Space.xs,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: ControlSize.bar,
                                    child: MenuBarComponent(),
                                  ),
                                  SizedBox(
                                    height: ControlSize.bar + 1,
                                    child: Center(child: CommandBarComponent()),
                                  ),
                                ],
                              ),
                            ),
                            Hairline(vertical: true, indent: Space.xs),
                            Expanded(child: ImageTabsComponent()),
                            // The corner's buttons in one row with the menus.
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Space.xs,
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: SizedBox(
                                  height: ControlSize.bar,
                                  child: Center(
                                    child: WindowTogglesComponent(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Hairline(),
                      ToolBarComponent(),
                    ],
                  ),
                ),
                const Hairline(),
                Expanded(
                  child: CanvasAreaComponent(
                    child: Stack(
                      children: [
                        const Positioned.fill(child: CanvasComponent()),
                        BlocBuilder<EditorBloc, EditorState>(
                          buildWhen: (a, b) =>
                              a is! EditorReady ||
                              b is! EditorReady ||
                              a.panels != b.panels ||
                              a.pointerOnCanvas != b.pointerOnCanvas,
                          builder: (context, state) {
                            final panels = state is EditorReady
                                ? state.panels
                                : const Panels(
                                    tools: false,
                                    history: false,
                                    layers: false,
                                    colors: false,
                                  );
                            final dimmed =
                                state is EditorReady && state.pointerOnCanvas;
                            void hide(String id) =>
                                bloc.add(CommandInvokedEvent(id));
                            return Stack(
                              children: [
                                if (panels.tools)
                                  FloatingPanelWidget(
                                    title: words.panelTools,
                                    alignment: Alignment.topLeft,
                                    dimmed: dimmed,
                                    hideTooltip: '${words.panelHide} (F5)',
                                    onHide: () => hide('toggle_tools'),
                                    offset: panels.placeOf('tools'),
                                    onMoved: (at) =>
                                        bloc.add(PanelMovedEvent('tools', at)),
                                    child: const ToolsPanelComponent(),
                                  ),
                                if (panels.colors)
                                  FloatingPanelWidget(
                                    title: words.panelColors,
                                    alignment: Alignment.bottomLeft,
                                    dimmed: dimmed,
                                    hideTooltip: '${words.panelHide} (F8)',
                                    onHide: () => hide('toggle_colors'),
                                    offset: panels.placeOf('colors'),
                                    onMoved: (at) =>
                                        bloc.add(PanelMovedEvent('colors', at)),
                                    child: const ColorsPanelComponent(),
                                  ),
                                if (panels.history)
                                  FloatingPanelWidget(
                                    title: words.panelHistory,
                                    alignment: Alignment.topRight,
                                    width: _rightWidth,
                                    dimmed: dimmed,
                                    hideTooltip: '${words.panelHide} (F6)',
                                    onHide: () => hide('toggle_history'),
                                    offset: panels.placeOf('history'),
                                    onMoved: (at) => bloc.add(
                                      PanelMovedEvent('history', at),
                                    ),
                                    child: const HistoryPanelComponent(),
                                  ),
                                if (panels.layers)
                                  FloatingPanelWidget(
                                    title: words.panelLayers,
                                    alignment: Alignment.bottomRight,
                                    width: _rightWidth,
                                    dimmed: dimmed,
                                    hideTooltip: '${words.panelHide} (F7)',
                                    onHide: () => hide('toggle_layers'),
                                    offset: panels.placeOf('layers'),
                                    onMoved: (at) =>
                                        bloc.add(PanelMovedEvent('layers', at)),
                                    child: const LayersPanelComponent(),
                                  ),
                              ],
                            );
                          },
                        ),
                        const Positioned.fill(child: PreviewDialogComponent()),
                        if (_dropping)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: ColoredBox(
                                color: context.tokens.accentSoft,
                                child: Center(
                                  child: GlassPanel(
                                    strong: true,
                                    shadow: true,
                                    padding: const EdgeInsets.all(Space.md),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: Space.xxs,
                                      children: [
                                        const Icon(Icons.file_open_outlined),
                                        Text(
                                          words.dropHere,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          words.dropHint,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: context.tokens.muted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const Hairline(),
                const GlassPanel(
                  radius: 0,
                  border: false,
                  child: StatusBarComponent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Flutter's keys under the toolkit-neutral names the core's shortcuts use.
abstract final class KeyNames {
  static final Map<LogicalKeyboardKey, String> _named = {
    LogicalKeyboardKey.delete: 'Delete',
    LogicalKeyboardKey.backspace: 'Backspace',
    LogicalKeyboardKey.insert: 'Insert',
    LogicalKeyboardKey.tab: 'Tab',
    LogicalKeyboardKey.enter: 'Enter',
    LogicalKeyboardKey.numpadEnter: 'Enter',
    LogicalKeyboardKey.escape: 'Escape',
    LogicalKeyboardKey.arrowLeft: 'ArrowLeft',
    LogicalKeyboardKey.arrowRight: 'ArrowRight',
    LogicalKeyboardKey.arrowUp: 'ArrowUp',
    LogicalKeyboardKey.arrowDown: 'ArrowDown',
    LogicalKeyboardKey.equal: 'Equals',
    LogicalKeyboardKey.numpadAdd: 'Plus',
    LogicalKeyboardKey.add: 'Plus',
    LogicalKeyboardKey.minus: 'Minus',
    LogicalKeyboardKey.numpadSubtract: 'Minus',
    LogicalKeyboardKey.bracketLeft: '[',
    LogicalKeyboardKey.bracketRight: ']',
    for (var i = 0; i < 12; i++)
      LogicalKeyboardKey(LogicalKeyboardKey.f1.keyId + i): 'F${i + 1}',
  };

  static String? of(LogicalKeyboardKey key) {
    final named = _named[key];
    if (named != null) {
      return named;
    }
    final label = key.keyLabel;
    if (label.length == 1) {
      final c = label.toUpperCase();
      if (RegExp('[A-Z0-9]').hasMatch(c)) {
        return c;
      }
    }
    return null;
  }

  /// The tool letter or bracket a key is labelled with, when Latin; else
  /// the place decides ([KeyPlaces.letter]).
  /// US layout, so the letters work with any keyboard language.
  static String? letter(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.bracketLeft) {
      return '[';
    }
    if (key == LogicalKeyboardKey.bracketRight) {
      return ']';
    }
    final label = key.keyLabel;
    if (label.length == 1 && RegExp('[A-Za-z]').hasMatch(label)) {
      return label.toLowerCase();
    }
    return null;
  }
}

/// Letter and digit keys by their place, for keyboards in other
/// languages (a Cyrillic layout still has S where S is).
abstract final class KeyPlaces {
  static final Map<PhysicalKeyboardKey, String> _places = {
    for (final (i, key) in const [
      PhysicalKeyboardKey.keyA,
      PhysicalKeyboardKey.keyB,
      PhysicalKeyboardKey.keyC, //
      PhysicalKeyboardKey.keyD,
      PhysicalKeyboardKey.keyE,
      PhysicalKeyboardKey.keyF,
      PhysicalKeyboardKey.keyG,
      PhysicalKeyboardKey.keyH,
      PhysicalKeyboardKey.keyI,
      PhysicalKeyboardKey.keyJ,
      PhysicalKeyboardKey.keyK,
      PhysicalKeyboardKey.keyL,
      PhysicalKeyboardKey.keyM,
      PhysicalKeyboardKey.keyN,
      PhysicalKeyboardKey.keyO,
      PhysicalKeyboardKey.keyP,
      PhysicalKeyboardKey.keyQ,
      PhysicalKeyboardKey.keyR,
      PhysicalKeyboardKey.keyS,
      PhysicalKeyboardKey.keyT,
      PhysicalKeyboardKey.keyU,
      PhysicalKeyboardKey.keyV,
      PhysicalKeyboardKey.keyW,
      PhysicalKeyboardKey.keyX,
      PhysicalKeyboardKey.keyY, PhysicalKeyboardKey.keyZ,
    ].indexed)
      key: String.fromCharCode(0x41 + i),
    for (final (i, key) in const [
      PhysicalKeyboardKey.digit0,
      PhysicalKeyboardKey.digit1,
      PhysicalKeyboardKey.digit2, //
      PhysicalKeyboardKey.digit3,
      PhysicalKeyboardKey.digit4,
      PhysicalKeyboardKey.digit5,
      PhysicalKeyboardKey.digit6,
      PhysicalKeyboardKey.digit7,
      PhysicalKeyboardKey.digit8,
      PhysicalKeyboardKey.digit9,
    ].indexed)
      key: '$i',
    PhysicalKeyboardKey.bracketLeft: '[',
    PhysicalKeyboardKey.bracketRight: ']',
  };

  static String? of(PhysicalKeyboardKey key) => _places[key];

  /// The tool letter or bracket at this place, lower-case.
  static String? letter(PhysicalKeyboardKey key) {
    final place = _places[key];
    if (place == null || RegExp('[0-9]').hasMatch(place)) {
      return null;
    }
    return place.toLowerCase();
  }
}
