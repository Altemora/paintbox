import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:core/core.dart';
import 'package:editor_ui/src/bloc/editor_actions.dart';
import 'package:editor_ui/src/bloc/editor_event.dart';
import 'package:editor_ui/src/bloc/editor_state.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

export 'package:editor_ui/src/bloc/editor_actions.dart';
export 'package:editor_ui/src/bloc/editor_event.dart';
export 'package:editor_ui/src/bloc/editor_state.dart';

/// The editor window's state machine: the open images and the active
/// one, the tool with the tool bar's settings, the colours, the view,
/// the floating windows and the previewing dialog. Pointer gestures, keys
/// and commands go to the core through the active image; after each, the
/// changed tiles go to the canvas as [CanvasTilesAction] and the state
/// takes what moved (layers, history, the selection outline, handles).
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  EditorBloc({
    required this._images,
    required SettingsRepository settings,
    required this._clipboard,
    required this._files,
    required this._eventBus,
    Stream<int>? previewWakes,
    void Function(void Function() callback)? scheduleFrame,
  }) : _settings = settings,
       _scheduleFrame = scheduleFrame ?? _nextFrame,
       super(_initial(settings.getSettingsSync())) {
    on<EditorStartedEvent>(_onStarted);
    on<CommandInvokedEvent>(_onCommand);
    on<KeyPressedEvent>(_onKey);
    on<ModifiersChangedEvent>(_onModifiers);
    on<TextTypedEvent>((event, emit) {
      final settings = _ready?.toolSettings;
      if (settings != null) {
        _withImage(
          emit,
          (i) => i.typeText(settings: settings, text: event.text),
        );
      }
    });
    on<TextKeyPressedEvent>((event, emit) {
      final settings = _ready?.toolSettings;
      if (settings != null) {
        _withImage(
          emit,
          (i) =>
              i.textKey(settings: settings, key: event.key, ctrl: event.ctrl),
        );
      }
    });
    on<SpaceHeldEvent>(_onSpace);
    on<CanvasPointerDownEvent>(_onPointerDown);
    on<CanvasPointerMovedEvent>(_onPointerMoved);
    on<CanvasPointerUpEvent>(_onPointerUp);
    on<CanvasPointerExitedEvent>(_onPointerExited);
    on<CanvasWheelEvent>(_onWheel);
    on<CanvasPanZoomEvent>(_onPanZoom);
    on<ViewportChangedEvent>(_onViewport);
    on<CanvasAttachedEvent>(_onCanvasAttached);
    on<ToolSelectedEvent>((event, emit) => _selectTool(emit, event.tool));
    on<ToolSettingsChangedEvent>(_onToolSettings);
    on<ColorsChangedEvent>((event, emit) => _setColors(emit, event.colors));
    on<EditedColorChosenEvent>(
      (event, emit) =>
          _emitReady(emit, (s) => s.copyWith(editsSecondary: event.secondary)),
    );
    on<TabSelectedEvent>((event, emit) => _activate(emit, event.imageId));
    on<TabCloseRequestedEvent>((event, emit) => _close(emit, event.imageId));
    on<TabMovedEvent>(_onTabMoved);
    on<LayerMovedEvent>(
      (event, emit) =>
          _withImage(emit, (i) => i.moveLayer(from: event.from, to: event.to)),
    );
    on<PanelMovedEvent>((event, emit) {
      final ready = _ready;
      if (ready != null) {
        _setPanels(emit, ready.panels.withPlace(event.panel, event.offset));
      }
    });
    on<CloseAnsweredEvent>(_onCloseAnswered);
    on<ExitRequestedEvent>(_onExit);
    on<OpenPathsEvent>((event, emit) {
      // One file at a time: a drop or a recent file waits for no one.
      if (_ready?.canRun('open') ?? false) {
        return _openPaths(emit, event.paths, dropped: event.dropped);
      }
    });
    on<SaveConfirmedEvent>(_onSaveConfirmed);
    on<SaveCancelledEvent>((event, emit) => _exiting = false);
    on<NewImageConfirmedEvent>(_onNewImage);
    on<ResizeConfirmedEvent>(_onResize);
    on<CanvasSizeConfirmedEvent>(_onCanvasSize);
    on<LayerSelectedEvent>(_onLayerSelected);
    on<LayerVisibilityToggledEvent>(_onLayerVisibility);
    on<LayerPropertiesRequestedEvent>(_onLayerProperties);
    on<HistoryJumpedEvent>(
      (event, emit) =>
          _withImage(emit, (i) => i.jumpTo(position: event.position)),
    );
    on<PreviewParamChangedEvent>(_onPreviewParam);
    on<LayerPreviewChangedEvent>(_onLayerPreview);
    on<PreviewEndedEvent>(_onPreviewEnded);
    on<PreviewWokeEvent>(_onPreviewWoke);
    on<ThemeChosenEvent>(_onTheme);
    on<ColorsMoreToggledEvent>(_onColorsMore);
    on<ThumbnailsDueEvent>(_onThumbnailsDue);
    on<ExpandAnsweredEvent>(_onExpandAnswered);
    on<AutoScrollTickedEvent>(_onAutoScroll);
    on<CurvesChangedEvent>(_onCurves);
    on<CanvasFrameEvent>(_onFrame);
    on<ZoomSetEvent>((event, emit) {
      final view = _ready?.view;
      if (view != null) {
        _setView(emit, view.zoomAbout(event.zoom, view.viewportCenter));
      }
    });
    _wakes = previewWakes?.listen((_) => add(const PreviewWokeEvent()));
  }

  static const _defaultSize = (800, 600);
  static const _layerThumb = 40;
  static const _tabThumb = 96;
  static const _thumbDelay = Duration(milliseconds: 350);

  /// A Zoom tool box narrower than this, in image pixels, is a click.
  static const _zoomBoxMin = 10.0;

  /// How near a handle a press must be, in logical screen pixels.
  static const _handleReach = 6.0;

  final ImagesRepository _images;
  final SettingsRepository _settings;
  final ClipboardRepository _clipboard;
  final FileDialogService _files;
  final EventBusService _eventBus;
  final void Function(void Function() callback) _scheduleFrame;
  bool _frameAsked = false;
  final ToolKeys _toolKeys = ToolKeys.create();
  final Stopwatch _clock = Stopwatch()..start();
  final Map<int, CanvasView> _views = {};
  StreamSubscription<int>? _wakes;
  Timer? _thumbTimer;
  _Drag? _drag;
  _Pending? _pending;
  bool _pressed = false;
  bool _exiting = false;
  Size _viewport = const Size(1, 1);
  double _pixelRatio = 1;

  static EditorReady _initial(AppSettings settings) => EditorReady(
    tabs: const [],
    tool: settings.tool,
    // Starting on the Color Picker, "previous tool" still goes somewhere.
    previousTool: settings.tool == Tool.colorPicker
        ? Tool.paintbrush
        : settings.tool,
    toolSettings: settings.toolSettings,
    colors: const UserColors(
      primary: Rgba8(r: 0, g: 0, b: 0, a: 255),
      secondary: Rgba8(r: 255, g: 255, b: 255, a: 255),
    ),
    palette: defaultPalette(),
    panels: settings.panels,
    theme: settings.theme,
    rulers: settings.rulers,
    recentFiles: settings.recentFiles,
  );

  static void _nextFrame(void Function() callback) {
    SchedulerBinding.instance
      ..scheduleFrameCallback((_) => callback())
      ..scheduleFrame();
  }

  double get _now => _clock.elapsedMicroseconds / 1e6;

  EditorReady? get _ready => switch (state) {
    final EditorReady ready => ready,
    EditorClosed() => null,
  };

  OpenImage? get _active {
    final id = _ready?.activeId;
    return id == null ? null : _images.byId(id);
  }

  @override
  Future<void> close() async {
    _thumbTimer?.cancel();
    _clearDrag();
    _pending?.dispose(_clipboard);
    await _wakes?.cancel();
    _toolKeys.dispose();
    return super.close();
  }

  // ---- start, images, tabs ----------------------------------------------

  Future<void> _onStarted(
    EditorStartedEvent event,
    Emitter<EditorState> emit,
  ) async {
    if (event.paths.isEmpty) {
      _newImage(emit, _defaultSize.$1, _defaultSize.$2);
      return;
    }
    await _openPaths(emit, event.paths);
    if (_ready?.tabs.isEmpty ?? false) {
      _newImage(emit, _defaultSize.$1, _defaultSize.$2);
    }
  }

  void _onNewImage(NewImageConfirmedEvent event, Emitter<EditorState> emit) =>
      _newImage(emit, event.width, event.height);

  void _newImage(Emitter<EditorState> emit, int width, int height) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    try {
      final open = _images.createBlank(
        width: width,
        height: height,
        background: const Rgba8(r: 255, g: 255, b: 255, a: 255),
        colors: ready.colors,
      );
      _addTab(emit, open);
    } on Failure catch (failure) {
      _fail(failure, 'new');
    }
  }

  Future<void> _openPaths(
    Emitter<EditorState> emit,
    List<String> paths, {
    bool dropped = false,
  }) async {
    for (final path in paths) {
      final copy = dropped && p.isWithin(Directory.systemTemp.path, path);
      final ready = _ready;
      if (ready == null) {
        return;
      }
      final already = _images.byPath(path);
      if (already != null) {
        _activate(emit, already.id);
        continue;
      }
      emit(ready.copyWith(busy: () => p.basename(path), saving: false));
      try {
        final open = await _images.open(path, ready.colors, keepPath: !copy);
        _emitReady(emit, (s) => s.copyWith(busy: () => null));
        _addTab(emit, open);
        if (!copy) {
          _remember(emit, path);
        }
      } on Failure catch (failure) {
        _emitReady(emit, (s) => s.copyWith(busy: () => null));
        _fail(failure, 'open');
      }
    }
  }

  void _onTabMoved(TabMovedEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    final tabs = [...ready.tabs];
    final from = tabs.indexWhere((t) => t.id == event.imageId);
    if (from < 0) {
      return;
    }
    final tab = tabs.removeAt(from);
    final to = event.index.clamp(0, tabs.length);
    tabs.insert(to, tab);
    _images.move(event.imageId, to);
    emit(ready.copyWith(tabs: tabs));
  }

  void _addTab(Emitter<EditorState> emit, OpenImage open) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    emit(ready.copyWith(tabs: [...ready.tabs, _tabOf(open, null)]));
    _activate(emit, open.id);
  }

  ImageTab _tabOf(OpenImage open, PixelBlock? thumbnail) => ImageTab(
    id: open.id,
    title: _titleOf(open),
    isModified: _safe(() => open.image.stamp().isModified) ?? false,
    thumbnail: thumbnail,
  );

  static ImageTitle _titleOf(OpenImage open) => ImageTitle(
    fileName: open.path == null ? null : p.basename(open.path!),
    untitledNumber: open.untitledNumber,
  );

  void _activate(Emitter<EditorState> emit, int id) {
    final ready = _ready;
    final open = _images.byId(id);
    if (ready == null || open == null) {
      return;
    }
    if (ready.activeId == id && ready.image != null) {
      return;
    }
    if (ready.activeId != id) {
      // Whatever is live on the image left becomes a step.
      _try(() => _active?.image.finish(), 'finish');
      _pressed = false;
      _clearDrag();
    }
    final colors = _safe(open.image.colors) ?? ready.colors;
    final view = _viewFor(open);
    emit(
      ready.copyWith(
        activeId: () => id,
        image: () => null,
        view: () => view,
        colors: colors,
        pointer: () => null,
        zoomBox: () => null,
        preview: () => _safe<PreviewInfo?>(open.image.preview),
      ),
    );
    _syncHandleRadius(view);
    _refresh(emit, reset: true);
    _scheduleThumbnails();
  }

  CanvasView _viewFor(OpenImage open) {
    final stamp = _safe(open.image.stamp);
    final width = stamp?.width ?? 1;
    final height = stamp?.height ?? 1;
    final known = _views[open.id];
    if (known != null) {
      return known.withViewport(_viewport, _pixelRatio).clamped(width, height);
    }
    final fresh = CanvasView.centered(
      width,
      height,
    ).withViewport(_viewport, _pixelRatio);
    final fitted = fresh.fit(width, height);
    // A large image opens fitted to the window, a small one at 100%.
    final view = fitted.zoom < fresh.zoom ? fitted : fresh;
    if (_viewport.width > 1) {
      _views[open.id] = view;
    }
    return view;
  }

  void _close(Emitter<EditorState> emit, int id) {
    final open = _images.byId(id);
    if (open == null) {
      return;
    }
    final modified = _safe(() => open.image.stamp().isModified) ?? false;
    if (modified) {
      _activate(emit, id);
      _eventBus.add(AskCloseAction(id, _titleOf(open)));
      return;
    }
    _dispose(emit, id);
  }

  Future<void> _onCloseAnswered(
    CloseAnsweredEvent event,
    Emitter<EditorState> emit,
  ) async {
    switch (event.save) {
      case null:
        _exiting = false;
      case false:
        _dispose(emit, event.imageId);
      case true:
        await _save(emit, event.imageId, saveAs: false, closeAfter: true);
    }
  }

  void _dispose(Emitter<EditorState> emit, int id) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    final index = ready.tabs.indexWhere((t) => t.id == id);
    _try(() => _images.byId(id)?.image.finish(), 'finish');
    _images.close(id);
    _views.remove(id);
    final tabs = [...ready.tabs]..removeWhere((t) => t.id == id);
    if (ready.activeId != id) {
      // A tab in the background: the active image stays as it is.
      emit(ready.copyWith(tabs: tabs));
    } else {
      final next = tabs.isEmpty
          ? null
          : tabs[math.min(math.max(index, 0), tabs.length - 1)].id;
      _pressed = false;
      _clearDrag();
      emit(
        ready.copyWith(
          tabs: tabs,
          activeId: () => next,
          image: () => null,
          view: () => null,
          preview: () => null,
          pointer: () => null,
        ),
      );
      if (next != null) {
        _activate(emit, next);
      }
    }
    if (_exiting) {
      _continueExit(emit);
    }
  }

  void _onExit(ExitRequestedEvent event, Emitter<EditorState> emit) {
    if (_ready?.hasPreview ?? false) {
      _try(() => _active?.image.endPreview(ok: false), 'exit');
      _emitReady(emit, (s) => s.copyWith(preview: () => null));
    }
    _exiting = true;
    _continueExit(emit);
  }

  void _continueExit(Emitter<EditorState> emit) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    final images = _images.images;
    if (images.isEmpty) {
      _exiting = false;
      unawaited(_settings.flush());
      emit(const EditorClosed());
      _eventBus.add(const ExitConfirmedAction());
      return;
    }
    // One question at a time; each answer comes back here.
    _close(emit, images.first.id);
  }

  void _remember(Emitter<EditorState> emit, String path) {
    final settings = _settings.getSettingsSync();
    final updated = settings
        .withRecent(path)
        .copyWith(lastDirectory: p.dirname(path));
    _settings.update(updated);
    _emitReady(emit, (s) => s.copyWith(recentFiles: updated.recentFiles));
  }

  // ---- saving -----------------------------------------------------------

  Future<void> _save(
    Emitter<EditorState> emit,
    int id, {
    required bool saveAs,
    bool closeAfter = false,
  }) async {
    final open = _images.byId(id);
    final ready = _ready;
    if (open == null || ready == null) {
      return;
    }
    _try(open.image.finish, 'save');
    var path = open.path;
    if (saveAs || path == null || fileKind(path: path) == null) {
      final title = _titleOf(open);
      final stem = title.fileName == null
          ? 'Untitled ${title.untitledNumber ?? 1}'
          : p.basenameWithoutExtension(title.fileName!);
      path = await _files.saveImage(
        suggestedName: '$stem.ora',
        directory: _settings.getSettingsSync().lastDirectory,
      );
    }
    if (path == null) {
      _exiting = false;
      return;
    }
    final kind = fileKind(path: path);
    if (kind == null) {
      _fail(
        const PaintFailure(code: 'io', reason: 'no format for this name'),
        'save',
      );
      _exiting = false;
      return;
    }
    final layers = _safe(() => open.image.stamp().layerCount) ?? 1;
    final flatten = !kind.layered && layers > 1;
    final quality = _settings.getSettingsSync().jpegQuality;
    if (flatten || kind.lossy) {
      _eventBus.add(
        AskSaveOptionsAction(
          imageId: id,
          path: path,
          flatten: flatten,
          jpegQuality: kind.lossy ? quality : null,
          closeAfter: closeAfter,
        ),
      );
      return;
    }
    await _write(emit, id, path, quality, closeAfter: closeAfter);
  }

  Future<void> _onSaveConfirmed(
    SaveConfirmedEvent event,
    Emitter<EditorState> emit,
  ) async {
    final open = _images.byId(event.imageId);
    if (open == null) {
      return;
    }
    final kind = fileKind(path: event.path);
    final layers = _safe(() => open.image.stamp().layerCount) ?? 1;
    if (kind != null && !kind.layered && layers > 1) {
      // As Paint.NET does: the layers become one step History can undo.
      _try(() => open.image.run(id: 'flatten'), 'flatten');
      if (_ready?.activeId == open.id) {
        _refresh(emit);
      }
    }
    if (kind?.lossy ?? false) {
      _settings.update(
        _settings.getSettingsSync().copyWith(jpegQuality: event.jpegQuality),
      );
    }
    await _write(
      emit,
      event.imageId,
      event.path,
      event.jpegQuality,
      closeAfter: event.closeAfter,
    );
  }

  Future<void> _write(
    Emitter<EditorState> emit,
    int id,
    String path,
    int quality, {
    required bool closeAfter,
  }) async {
    _emitReady(
      emit,
      (s) => s.copyWith(busy: () => p.basename(path), saving: true),
    );
    try {
      final saved = await _images.save(id, path, jpegQuality: quality);
      _emitReady(
        emit,
        (s) => s.copyWith(
          busy: () => null,
          tabs: [
            for (final tab in s.tabs)
              tab.id == id ? _tabOf(saved, tab.thumbnail) : tab,
          ],
        ),
      );
      _remember(emit, path);
      _eventBus.add(ImageSavedAction(_titleOf(saved)));
      if (closeAfter) {
        _dispose(emit, id);
      } else if (_ready?.activeId == id) {
        _refresh(emit);
      }
    } on Failure catch (failure) {
      _exiting = false;
      _emitReady(emit, (s) => s.copyWith(busy: () => null));
      _fail(failure, 'save');
    }
  }

  // ---- commands ---------------------------------------------------------

  Future<void> _onCommand(
    CommandInvokedEvent event,
    Emitter<EditorState> emit,
  ) => _run(emit, event.id);

  Future<void> _run(Emitter<EditorState> emit, String id) async {
    final ready = _ready;
    if (ready == null || !ready.canRun(id)) {
      return;
    }
    final open = _active;
    switch (id) {
      case 'new':
        final size = _active == null
            ? _defaultSize
            : (ready.image?.width ?? 800, ready.image?.height ?? 600);
        _eventBus.add(AskNewImageAction(size.$1, size.$2));
      case 'open':
        final paths = await _files.openImages(
          directory: _settings.getSettingsSync().lastDirectory,
        );
        await _openPaths(emit, paths);
      case 'close':
        if (open != null) {
          _close(emit, open.id);
        }
      case 'save' || 'save_as':
        if (open != null) {
          await _save(emit, open.id, saveAs: id == 'save_as');
        }
      case 'exit':
        add(const ExitRequestedEvent());
      case 'copy' || 'cut':
        await _copy(emit, cut: id == 'cut');
      case 'paste' || 'paste_into_new_layer':
        await _paste(emit, newLayer: id == 'paste_into_new_layer');
      case 'paste_into_new_image':
        await _pasteIntoNewImage(emit);
      case 'zoom_in' || 'zoom_out':
        final view = ready.view;
        if (view != null) {
          _setView(
            emit,
            view.zoomAbout(
              id == 'zoom_in' ? view.stepIn : view.stepOut,
              view.viewportCenter,
            ),
          );
        }
      case 'zoom_to_window':
        final image = ready.image;
        if (image != null && ready.view != null) {
          _setView(emit, ready.view!.fit(image.width, image.height));
        }
      case 'zoom_to_selection':
        final image = ready.image;
        if (image != null && ready.view != null && image.hasSelection) {
          final b = image.stamp.selectionBounds;
          _setView(
            emit,
            ready.view!.zoomTo(
              Offset(b.x.toDouble(), b.y.toDouble()),
              Offset((b.x + b.width).toDouble(), (b.y + b.height).toDouble()),
            ),
          );
        }
      case 'actual_size':
        final view = ready.view;
        if (view != null) {
          _setView(emit, view.zoomAbout(1, view.viewportCenter));
        }
      case 'pixel_grid':
        emit(ready.copyWith(pixelGrid: !ready.pixelGrid));
      case 'rulers':
        _settings.update(
          _settings.getSettingsSync().copyWith(rulers: !ready.rulers),
        );
        emit(ready.copyWith(rulers: !ready.rulers));
      case 'resize':
        final image = ready.image;
        if (image != null) {
          _eventBus.add(
            AskResizeAction(
              image.width,
              image.height,
              ready.toolSettings.resampling,
            ),
          );
        }
      case 'canvas_size':
        final image = ready.image;
        if (image != null) {
          _eventBus.add(AskCanvasSizeAction(image.width, image.height));
        }
      case 'import_from_file':
        await _import(emit);
      case 'layer_properties':
        _openPreview(emit, 'layer_properties');
      case 'repeat_effect':
        _withImage(emit, (i) => i.repeatEffect());
        _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
      case 'toggle_tools':
        _setPanels(emit, ready.panels.withTools(!ready.panels.tools));
      case 'toggle_history':
        _setPanels(emit, ready.panels.withHistory(!ready.panels.history));
      case 'toggle_layers':
        _setPanels(emit, ready.panels.withLayers(!ready.panels.layers));
      case 'toggle_colors':
        _setPanels(emit, ready.panels.withColors(!ready.panels.colors));
      case 'next_image' || 'previous_image':
        final index = ready.tabs.indexWhere((t) => t.id == ready.activeId);
        final step = id == 'next_image' ? 1 : -1;
        final next = ready.tabs[(index + step) % ready.tabs.length];
        _activate(emit, next.id);
      case 'help':
        _eventBus.add(const ShowHelpAction());
      case final String other
          when other.startsWith('adjust:') || other.startsWith('effect:'):
        _openPreview(emit, other);
      default:
        _withImage(emit, (i) => i.run(id: id));
    }
  }

  void _setPanels(Emitter<EditorState> emit, Panels panels) {
    _settings.update(_settings.getSettingsSync().copyWith(panels: panels));
    _emitReady(emit, (s) => s.copyWith(panels: panels));
  }

  void _setView(Emitter<EditorState> emit, CanvasView view) {
    final ready = _ready;
    final image = ready?.image;
    if (ready == null || image == null) {
      return;
    }
    final clamped = view.clamped(image.width, image.height);
    _views[image.id] = clamped;
    _syncHandleRadius(clamped);
    emit(ready.copyWith(view: () => clamped));
  }

  void _syncHandleRadius(CanvasView view) {
    final radius = _handleReach / view.scale;
    _safe(() => _active?.image.setHandleRadius(radius: radius));
  }

  void _onColorsMore(ColorsMoreToggledEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    if (ready != null) {
      _setPanels(
        emit,
        ready.panels.copyWith(colorsMore: !ready.panels.colorsMore),
      );
    }
  }

  void _onTheme(ThemeChosenEvent event, Emitter<EditorState> emit) {
    _settings.update(_settings.getSettingsSync().copyWith(theme: event.theme));
    _emitReady(emit, (s) => s.copyWith(theme: event.theme));
  }

  Future<void> _copy(Emitter<EditorState> emit, {required bool cut}) async {
    final open = _active;
    if (open == null) {
      return;
    }
    try {
      final clip = PaintCall.run(
        () => cut ? open.image.cut() : open.image.copy(),
      );
      _refresh(emit);
      if (clip != null) {
        await _clipboard.put(clip);
      }
    } on Failure catch (failure) {
      _fail(failure, cut ? 'cut' : 'copy');
    }
  }

  Future<void> _paste(
    Emitter<EditorState> emit, {
    required bool newLayer,
  }) async {
    try {
      final clip = await _clipboard.take();
      final image = _ready?.image;
      if (clip == null || image == null) {
        return;
      }
      final pending = _PendingPaste(clip, newLayer: newLayer);
      if (clip.width > image.width || clip.height > image.height) {
        // As Paint.NET does: a fragment larger than the canvas offers to
        // expand it first.
        _pending?.dispose(_clipboard);
        _pending = pending;
        _eventBus.add(const AskExpandCanvasAction());
        return;
      }
      _finishPending(emit, pending, expand: false);
    } on Failure catch (failure) {
      _fail(failure, 'paste');
    }
  }

  void _onExpandAnswered(ExpandAnsweredEvent event, Emitter<EditorState> emit) {
    final pending = _pending;
    _pending = null;
    if (pending == null) {
      return;
    }
    final expand = event.expand;
    if (expand == null) {
      pending.dispose(_clipboard);
      return;
    }
    _finishPending(emit, pending, expand: expand);
  }

  /// Pastes or imports what waited, growing the canvas to hold it first
  /// when [expand] (from the top-left corner, the rest transparent).
  void _finishPending(
    Emitter<EditorState> emit,
    _Pending pending, {
    required bool expand,
  }) {
    final open = _active;
    if (open == null) {
      pending.dispose(_clipboard);
      return;
    }
    try {
      if (expand) {
        final stamp = PaintCall.run(open.image.stamp);
        PaintCall.run(
          () => open.image.resizeCanvas(
            width: math.max(stamp.width, pending.width),
            height: math.max(stamp.height, pending.height),
            anchor: Anchor.topLeft,
          ),
        );
      }
      switch (pending) {
        case _PendingPaste(:final clip, :final newLayer):
          final outcome = PaintCall.run(
            () => open.image.paste(clip: clip, newLayer: newLayer),
          );
          _applyOutcome(emit, outcome);
        case _PendingImport(:final picture, :final name):
          PaintCall.run(
            () => open.image.importLayer(name: name, picture: picture),
          );
      }
    } on Failure catch (failure) {
      _fail(failure, 'paste');
    } finally {
      pending.dispose(_clipboard);
    }
    _refresh(emit);
    _scrollToSelection(emit);
    _scheduleThumbnails();
  }

  /// A pasted fragment out of sight brings the view to it.
  void _scrollToSelection(Emitter<EditorState> emit) {
    final ready = _ready;
    final image = ready?.image;
    final view = ready?.view;
    if (image == null || view == null || !image.hasSelection) {
      return;
    }
    final b = image.stamp.selectionBounds;
    final screen = Rect.fromPoints(
      view.toScreen(Offset(b.x.toDouble(), b.y.toDouble())),
      view.toScreen(
        Offset((b.x + b.width).toDouble(), (b.y + b.height).toDouble()),
      ),
    );
    final area = Offset.zero & view.viewport;
    if (!area.overlaps(screen)) {
      _setView(
        emit,
        CanvasView(
          zoom: view.zoom,
          center: Offset(b.x + b.width / 2, b.y + b.height / 2),
          viewport: view.viewport,
          pixelRatio: view.pixelRatio,
        ),
      );
    }
  }

  Future<void> _pasteIntoNewImage(Emitter<EditorState> emit) async {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    try {
      final clip = await _clipboard.take();
      if (clip == null) {
        return;
      }
      final open = _images.fromClip(clip, ready.colors);
      if (!_clipboard.isOwn(clip)) {
        clip.dispose();
      }
      _addTab(emit, open);
    } on Failure catch (failure) {
      _fail(failure, 'paste_into_new_image');
    }
  }

  Future<void> _import(Emitter<EditorState> emit) async {
    final path = await _files.openPicture(
      directory: _settings.getSettingsSync().lastDirectory,
    );
    final open = _active;
    if (path == null || open == null) {
      return;
    }
    try {
      final picture = await PaintCall.runAsync(() => readPicture(path: path));
      final pending = _PendingImport(
        picture,
        name: p.basenameWithoutExtension(path),
      );
      final image = _ready?.image;
      if (image != null &&
          (picture.width > image.width || picture.height > image.height)) {
        _pending?.dispose(_clipboard);
        _pending = pending;
        _eventBus.add(const AskExpandCanvasAction());
        return;
      }
      _finishPending(emit, pending, expand: false);
    } on Failure catch (failure) {
      _fail(failure, 'import');
    }
  }

  void _onResize(ResizeConfirmedEvent event, Emitter<EditorState> emit) =>
      _withImage(
        emit,
        (i) => i.resizeImage(
          width: event.width,
          height: event.height,
          resampling: event.resampling,
        ),
      );

  void _onCanvasSize(
    CanvasSizeConfirmedEvent event,
    Emitter<EditorState> emit,
  ) => _withImage(
    emit,
    (i) => i.resizeCanvas(
      width: event.width,
      height: event.height,
      anchor: event.anchor,
    ),
  );

  // ---- keys -------------------------------------------------------------

  Future<void> _onKey(KeyPressedEvent event, Emitter<EditorState> emit) async {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    if (ready.hasPreview) {
      // A previewing dialog holds the keys: Enter is OK, Esc Cancel.
      if (event.key == 'Enter') {
        _endPreview(emit, ok: true);
      } else if (event.key == 'Escape') {
        _endPreview(emit, ok: false);
      }
      return;
    }
    final command = commandForKey(
      ctrl: event.ctrl,
      shift: event.shift,
      alt: event.alt,
      key: event.key,
    );
    if (command != null) {
      // A key of a command with nothing to act on does nothing at all,
      // and does not finish what is live.
      if (ready.canRun(command)) {
        await _run(emit, command);
      }
      return;
    }
    if (event.alt) {
      return;
    }
    final letter = event.letter;
    if (letter == '[' || letter == ']') {
      _setToolSettings(
        emit,
        stepToolWidth(
          settings: ready.toolSettings,
          grow: letter == ']',
          ctrl: event.ctrl,
        ),
      );
      return;
    }
    if (event.ctrl) {
      _nudge(emit, event.key, 10);
      return;
    }
    switch (event.key) {
      case 'Enter':
        _withImage(emit, (i) => i.enter());
        return;
      case 'Escape':
        _withImage(emit, (i) => i.escape());
        return;
      case 'X':
        if (!event.shift) {
          _setColors(
            emit,
            UserColors(
              primary: ready.colors.secondary,
              secondary: ready.colors.primary,
            ),
          );
          return;
        }
      case 'C':
        if (!event.shift) {
          emit(ready.copyWith(editsSecondary: !ready.editsSecondary));
          return;
        }
    }
    if (_nudge(emit, event.key, 1)) {
      return;
    }
    // Line / Curve: , . / cycle the start, the dash and the end.
    if (ready.tool == Tool.lineCurve && letter != null && !event.shift) {
      final cycled = cycleLineSetting(
        settings: ready.toolSettings,
        key: letter,
      );
      if (cycled != null) {
        _setToolSettings(emit, cycled);
        return;
      }
    }
    // No tool letters while any button is down, the view's drags too.
    if (letter != null && letter.length == 1 && !_pressed && _drag == null) {
      final tool = _toolKeys.press(
        letter: letter.toLowerCase(),
        shift: event.shift,
        now: _now,
        current: ready.tool,
      );
      if (tool != null) {
        _selectTool(emit, tool);
      }
    }
  }

  /// The arrow keys in the move tools; true when it was an arrow.
  bool _nudge(Emitter<EditorState> emit, String key, int step) {
    final (dx, dy) = switch (key) {
      'ArrowLeft' => (-step, 0),
      'ArrowRight' => (step, 0),
      'ArrowUp' => (0, -step),
      'ArrowDown' => (0, step),
      _ => (0, 0),
    };
    if (dx == 0 && dy == 0) {
      return false;
    }
    final tool = _ready?.tool;
    if (tool == Tool.moveSelectedPixels || tool == Tool.moveSelection) {
      _withImage(emit, (i) => i.nudge(tool: tool!, dx: dx, dy: dy));
    }
    return true;
  }

  void _onModifiers(ModifiersChangedEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    if (ready == null || !_pressed) {
      return;
    }
    _withImage(
      emit,
      (i) => i.setModifiers(
        settings: ready.toolSettings,
        ctrl: event.ctrl,
        alt: event.alt,
        shift: event.shift,
      ),
    );
  }

  /// Space pans only when no button is down, as in the source.
  void _onSpace(SpaceHeldEvent event, Emitter<EditorState> emit) {
    if (event.held && (_pressed || _drag != null)) {
      return;
    }
    _emitReady(emit, (s) => s.copyWith(temporaryPan: event.held));
  }

  // ---- tools and colours -----------------------------------------------

  void _selectTool(Emitter<EditorState> emit, Tool tool) {
    final ready = _ready;
    if (ready == null || ready.hasPreview || tool == ready.tool) {
      return;
    }
    if (!PaintCatalog.tool(tool).available) {
      _eventBus.add(ToolUnavailableAction(tool));
      return;
    }
    // A tool change finishes what is live, as in Paint.NET.
    _withImage(emit, (i) => i.finish());
    _pressed = false;
    _settings.update(_settings.getSettingsSync().copyWith(tool: tool));
    _emitReady(emit, (s) => s.copyWith(tool: tool, previousTool: s.tool));
  }

  /// A gesture's word on the tool: the picker's switch, a paste riding
  /// on Move Selected Pixels. What is live stays live.
  void _applyOutcome(Emitter<EditorState> emit, GestureOutcome outcome) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    final to = outcome.previousTool ? ready.previousTool : outcome.switchTo;
    if (to == null || to == ready.tool) {
      return;
    }
    _settings.update(_settings.getSettingsSync().copyWith(tool: to));
    emit(ready.copyWith(tool: to, previousTool: ready.tool));
  }

  void _onToolSettings(
    ToolSettingsChangedEvent event,
    Emitter<EditorState> emit,
  ) => _setToolSettings(emit, sanitizeToolSettings(settings: event.settings));

  void _setToolSettings(Emitter<EditorState> emit, ToolSettings settings) {
    _settings.update(
      _settings.getSettingsSync().copyWith(toolSettings: settings),
    );
    _emitReady(emit, (s) => s.copyWith(toolSettings: settings));
    _withImage(emit, (i) => i.flush(settings: settings));
  }

  void _setColors(Emitter<EditorState> emit, UserColors colors) {
    final ready = _ready;
    if (ready == null) {
      return;
    }
    emit(ready.copyWith(colors: colors));
    _withImage(
      emit,
      (i) => i.setColors(colors: colors, settings: ready.toolSettings),
    );
  }

  // ---- layers and dialogs ----------------------------------------------

  void _onLayerSelected(LayerSelectedEvent event, Emitter<EditorState> emit) =>
      _withImage(emit, (i) => i.setActiveLayer(index: event.index));

  void _onLayerVisibility(
    LayerVisibilityToggledEvent event,
    Emitter<EditorState> emit,
  ) {
    final rows = _ready?.image?.layers;
    if (rows == null || event.index >= rows.length) {
      return;
    }
    final p = rows[event.index].properties;
    _withImage(
      emit,
      (i) => i.setLayerProperties(
        index: event.index,
        properties: LayerProperties(
          name: p.name,
          visible: !p.visible,
          opacity: p.opacity,
          blendMode: p.blendMode,
          isBackground: p.isBackground,
        ),
      ),
    );
  }

  void _onLayerProperties(
    LayerPropertiesRequestedEvent event,
    Emitter<EditorState> emit,
  ) {
    _withImage(emit, (i) => i.setActiveLayer(index: event.index));
    _openPreview(emit, 'layer_properties');
  }

  void _openPreview(Emitter<EditorState> emit, String id) {
    _withImage(emit, (i) => i.openPreview(id: id));
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
  }

  PreviewInfo? _previewInfo() =>
      _safe<PreviewInfo?>(() => _active?.image.preview());

  void _onPreviewParam(
    PreviewParamChangedEvent event,
    Emitter<EditorState> emit,
  ) {
    _withImage(
      emit,
      (i) => i.setPreviewParam(name: event.name, values: event.values),
    );
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
  }

  void _onCurves(CurvesChangedEvent event, Emitter<EditorState> emit) {
    _withImage(emit, (i) => i.setPreviewCurves(curves: event.curves));
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
  }

  void _onLayerPreview(
    LayerPreviewChangedEvent event,
    Emitter<EditorState> emit,
  ) {
    _withImage(emit, (i) => i.setLayerPreview(properties: event.properties));
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
  }

  void _onPreviewEnded(PreviewEndedEvent event, Emitter<EditorState> emit) =>
      _endPreview(emit, ok: event.ok);

  void _endPreview(Emitter<EditorState> emit, {required bool ok}) {
    _withImage(emit, (i) => i.endPreview(ok: ok));
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
    _scheduleThumbnails();
  }

  void _onPreviewWoke(PreviewWokeEvent event, Emitter<EditorState> emit) {
    if (!(_ready?.hasPreview ?? false)) {
      return;
    }
    _withImage(emit, (i) => i.pollPreview());
    _emitReady(emit, (s) => s.copyWith(preview: _previewInfo));
    if (_ready?.preview == null) {
      _scheduleThumbnails();
    }
  }

  // ---- the canvas -------------------------------------------------------

  void _onViewport(ViewportChangedEvent event, Emitter<EditorState> emit) {
    final first = _viewport.width <= 1;
    _viewport = event.size;
    _pixelRatio = event.pixelRatio;
    final open = _active;
    if (open == null) {
      return;
    }
    if (first) {
      _views.remove(open.id);
    }
    final view = _viewFor(open);
    _views[open.id] = view;
    _syncHandleRadius(view);
    _emitReady(emit, (s) => s.copyWith(view: () => view));
  }

  void _onCanvasAttached(CanvasAttachedEvent event, Emitter<EditorState> emit) {
    if (event.imageId == _ready?.activeId) {
      _refresh(emit, reset: true);
    }
  }

  void _onPointerDown(CanvasPointerDownEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    final open = _active;
    final view = ready?.view;
    if (ready == null || open == null || view == null || ready.hasPreview) {
      return;
    }
    final at = view.toImage(event.position);
    final drag = _drag;
    if (drag is _ZoomDrag) {
      // The other button moves the Zoom tool's box, as in the source.
      drag.mover = event.position;
      return;
    }
    if (drag != null) {
      return;
    }
    // While a tool's button is held, the middle button and Space do not
    // take the gesture over: the other button is the core's, to move the
    // shape with.
    if (!_pressed) {
      if (ready.temporaryPan && event.button == CanvasButton.secondary) {
        final auto = _AutoScrollDrag(event.position, event.button);
        auto.timer = Timer.periodic(
          const Duration(milliseconds: 16),
          (_) => add(const AutoScrollTickedEvent()),
        );
        _drag = auto;
        emit(ready.copyWith(panning: true));
        return;
      }
      if (event.button == CanvasButton.middle ||
          ready.temporaryPan ||
          ready.tool == Tool.pan) {
        _drag = _PanDrag(event.position, event.button);
        emit(ready.copyWith(panning: true));
        return;
      }
      if (ready.tool == Tool.zoom) {
        _drag = _ZoomDrag(at, event.position, event.button);
        return;
      }
    }
    if (event.button == CanvasButton.middle) {
      return;
    }
    final secondary = event.button == CanvasButton.secondary;
    final outcome = _withImage(
      emit,
      (i) => i.press(
        tool: ready.tool,
        settings: ready.toolSettings,
        x: at.dx,
        y: at.dy,
        secondary: secondary,
        ctrl: event.ctrl,
        alt: event.alt,
        shift: event.shift,
        time: _now,
      ),
    );
    _syncPressed();
    if (outcome != null) {
      _applyOutcome(emit, outcome);
    }
  }

  /// Whether the core holds a button: the one source of the shell's
  /// "pressed", read after every press and release.
  void _syncPressed() {
    _pressed = _safe<bool?>(() => _active?.image.stamp().isPressed) ?? false;
  }

  void _onPointerMoved(
    CanvasPointerMovedEvent event,
    Emitter<EditorState> emit,
  ) {
    final ready = _ready;
    final view = ready?.view;
    if (ready == null || view == null) {
      return;
    }
    final at = view.toImage(event.position);
    switch (_drag) {
      case final _PanDrag pan:
        final delta = event.position - pan.last;
        pan.last = event.position;
        _setView(emit, view.scrollBy(delta));
        return;
      case final _AutoScrollDrag auto:
        auto.pointer = event.position;
        return;
      case final _ZoomDrag zoom:
        final mover = zoom.mover;
        if (mover != null) {
          final shift = view.toImage(event.position) - view.toImage(mover);
          zoom
            ..start += shift
            ..end += shift
            ..mover = event.position;
        } else {
          zoom.end = at;
          // The box shows once the pointer left the press by 10 pixels.
          zoom.moved =
              zoom.moved || (event.position - zoom.screenStart).distance > 10;
        }
        _emitReady(
          emit,
          (s) => s.copyWith(
            zoomBox: () => zoom.moved ? _zoomBox(zoom) : null,
            pointer: () => at,
          ),
        );
        return;
      case null:
        break;
    }
    if (_pressed && !ready.hasPreview) {
      // The core paints at once; the screen takes the change once a
      // frame, however fast the mouse reports.
      _try(
        () => _active?.image.moveTo(
          settings: ready.toolSettings,
          x: at.dx,
          y: at.dy,
        ),
        'move',
      );
      _askFrame();
    }
    final old = _ready?.pointer;
    if (old == null ||
        old.dx.floor() != at.dx.floor() ||
        old.dy.floor() != at.dy.floor()) {
      _emitReady(emit, (s) => s.copyWith(pointer: () => at));
    }
  }

  /// The Zoom tool's box, cut to the image.
  Rect _zoomBox(_ZoomDrag zoom) {
    final image = _ready?.image;
    final box = Rect.fromPoints(zoom.start, zoom.end);
    if (image == null) {
      return box;
    }
    final bounds = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final cut = box.intersect(bounds);
    return cut.isEmpty ? box : cut;
  }

  void _onPointerUp(CanvasPointerUpEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    final view = ready?.view;
    if (ready == null || view == null) {
      return;
    }
    final at = view.toImage(event.position);
    // A view drag ends only with its own button.
    switch (_drag) {
      case final _PanDrag pan when pan.button == event.button:
        _drag = null;
        emit(ready.copyWith(panning: false));
        return;
      case final _AutoScrollDrag auto when auto.button == event.button:
        _clearDrag();
        emit(ready.copyWith(panning: false));
        return;
      case final _ZoomDrag zoom when zoom.button == event.button:
        _drag = null;
        if (zoom.mover == null) {
          zoom.end = at;
        }
        _zoomRelease(emit, zoom);
        return;
      case final _ZoomDrag zoom:
        zoom.mover = null;
        return;
      case _PanDrag() || _AutoScrollDrag() || null:
        break;
    }
    if (!_pressed || event.button == CanvasButton.middle) {
      return;
    }
    final secondary = event.button == CanvasButton.secondary;
    final outcome = _withImage(
      emit,
      (i) => i.release(
        settings: ready.toolSettings,
        x: at.dx,
        y: at.dy,
        secondary: secondary,
        ctrl: event.ctrl,
        alt: event.alt,
        shift: event.shift,
        time: _now,
      ),
    );
    _syncPressed();
    if (outcome != null) {
      _applyOutcome(emit, outcome);
    }
    _scheduleThumbnails();
  }

  void _onAutoScroll(AutoScrollTickedEvent event, Emitter<EditorState> emit) {
    final drag = _drag;
    final view = _ready?.view;
    if (drag is! _AutoScrollDrag || view == null) {
      return;
    }
    // A tenth of the distance from the centre per tick.
    final pull = (drag.pointer - view.viewportCenter) * 0.1;
    _setView(emit, view.scrollBy(-pull));
  }

  /// The Zoom tool, as the source's: a box whose diagonal is 10 pixels of
  /// the image or more zooms to it; else a left click zooms in and a
  /// right click out, both centring the clicked point.
  void _zoomRelease(Emitter<EditorState> emit, _ZoomDrag zoom) {
    final ready = _ready;
    final view = ready?.view;
    if (ready == null || view == null) {
      return;
    }
    emit(ready.copyWith(zoomBox: () => null));
    final box = _zoomBox(zoom);
    if (zoom.button == CanvasButton.primary &&
        zoom.moved &&
        Offset(box.width, box.height).distance >= _zoomBoxMin) {
      _setView(emit, view.zoomTo(box.topLeft, box.bottomRight));
      return;
    }
    final zoomed = view.zoomAbout(
      zoom.button == CanvasButton.secondary ? view.stepOut : view.stepIn,
      zoom.screenStart,
    );
    _setView(
      emit,
      CanvasView(
        zoom: zoomed.zoom,
        center: zoom.start,
        viewport: zoomed.viewport,
        pixelRatio: zoomed.pixelRatio,
      ),
    );
  }

  void _onPointerExited(
    CanvasPointerExitedEvent event,
    Emitter<EditorState> emit,
  ) => _emitReady(emit, (s) => s.copyWith(pointer: () => null));

  void _onWheel(CanvasWheelEvent event, Emitter<EditorState> emit) {
    final view = _ready?.view;
    if (view == null) {
      return;
    }
    // One notch of the wheel is 100 physical pixels on Windows (three
    // lines), whatever the display's scale.
    final notches = -event.delta.dy * _pixelRatio / 100;
    if (event.ctrl && !event.shift && !event.alt) {
      // Smooth zoom about the pointer, not by steps.
      final factor = math.pow(CanvasView.wheelFactor, notches).toDouble();
      _setView(emit, view.zoomAbout(view.zoom * factor, event.position));
      return;
    }
    // A notch scrolls 120 pixels of the screen.
    final step = CanvasView.wheelStep / _pixelRatio;
    final dx = -event.delta.dx * _pixelRatio / 100 * step;
    final dy = notches * step;
    // Shift scrolls sideways; some systems already turn it into dx.
    final delta = event.shift ? Offset(dy != 0 ? dy : dx, 0) : Offset(dx, dy);
    _setView(emit, view.scrollBy(delta));
  }

  /// A touchpad's two fingers: they scroll, and a pinch zooms about them.
  void _onPanZoom(CanvasPanZoomEvent event, Emitter<EditorState> emit) {
    final view = _ready?.view;
    if (view == null) {
      return;
    }
    var next = view.scrollBy(event.pan);
    if (event.scale != 1) {
      next = next.zoomAbout(next.zoom * event.scale, event.position);
    }
    _setView(emit, next);
  }

  // ---- refreshing ---------------------------------------------------------

  /// Runs [call] on the active image; a failure is logged and told, and
  /// the screen takes what changed either way.
  T? _withImage<T>(Emitter<EditorState> emit, T Function(PaintImage) call) {
    final open = _active;
    if (open == null) {
      return null;
    }
    T? result;
    try {
      result = PaintCall.run(() => call(open.image));
    } on Failure catch (failure) {
      _fail(failure, 'image');
    }
    _refresh(emit);
    return result;
  }

  void _refresh(Emitter<EditorState> emit, {bool reset = false}) {
    final ready = _ready;
    final open = _active;
    if (ready == null || open == null) {
      return;
    }
    try {
      final old = ready.image?.id == open.id ? ready.image : null;
      final change = open.session.takeChange(reset: reset || old == null);
      final stamp = change.stamp;
      if (change.resetTiles || change.tiles.isNotEmpty) {
        _eventBus.add(
          CanvasTilesAction(
            imageId: open.id,
            blocks: change.tiles,
            reset: change.resetTiles,
          ),
        );
      }
      final details = _details(open.id, change, old);
      final tabs = [
        for (final tab in ready.tabs)
          tab.id == open.id && tab.isModified != stamp.isModified
              ? ImageTab(
                  id: tab.id,
                  title: tab.title,
                  isModified: stamp.isModified,
                  thumbnail: tab.thumbnail,
                )
              : tab,
      ];
      var view = ready.view;
      final resized =
          old != null &&
          (old.width != stamp.width || old.height != stamp.height);
      if (resized && view != null) {
        view = view.clamped(stamp.width, stamp.height);
        _views[open.id] = view;
      }
      if (old != null && old.stamp.revision != stamp.revision) {
        _scheduleThumbnails();
      }
      emit(
        ready.copyWith(
          image: () => details,
          tabs: tabs,
          view: () => view,
          colors: change.colors,
        ),
      );
    } on Failure catch (failure) {
      _fail(failure, 'refresh');
    }
  }

  /// The screen's view of the image: what [change] did not report keeps
  /// its old value (and the same lists, so panels need not rebuild).
  static ImageDetails _details(int id, ImageChange change, ImageDetails? old) {
    // The core moves the selection with the pixels, so its outline is
    // drawn where it is, unshifted.
    final outline = change.outline;
    final kept = old?.outline;
    final shown = SelectionOutline(
      stamp: outline != null || kept == null
          ? change.stamp.selectionStamp
          : kept.stamp,
      segments: outline ?? kept?.segments ?? SelectionOutline.empty.segments,
    );
    final overlay = change.overlay;
    return ImageDetails(
      id: id,
      stamp: change.stamp,
      layers: _layerRows(change.layers, old?.layers),
      history: change.history ?? old?.history ?? const [],
      outline: shown,
      handles: old != null && listEquals(old.handles, overlay.handles)
          ? old.handles
          : overlay.handles,
      guide: old != null && listEquals(old.guide, overlay.guide)
          ? old.guide
          : overlay.guide,
      available: change.available ?? old?.available ?? const {},
    );
  }

  /// The layer rows, keeping the thumbnails until the next quiet moment.
  static List<LayerRow> _layerRows(
    List<LayerProperties>? layers,
    List<LayerRow>? old,
  ) {
    if (layers == null) {
      return old ?? const [];
    }
    if (old != null &&
        listEquals([for (final r in old) r.properties], layers)) {
      return old;
    }
    return [
      for (var i = 0; i < layers.length; i++)
        LayerRow(
          properties: layers[i],
          thumbnail: old != null && old.length == layers.length
              ? old[i].thumbnail
              : null,
        ),
    ];
  }

  void _scheduleThumbnails() {
    _thumbTimer?.cancel();
    _thumbTimer = Timer(_thumbDelay, () {
      if (!isClosed) {
        add(const ThumbnailsDueEvent());
      }
    });
  }

  void _onThumbnailsDue(ThumbnailsDueEvent event, Emitter<EditorState> emit) {
    final ready = _ready;
    final open = _active;
    final details = ready?.image;
    if (ready == null || open == null || details == null || _pressed) {
      return;
    }
    try {
      final rows = [
        for (var i = 0; i < details.layers.length; i++)
          LayerRow(
            properties: details.layers[i].properties,
            thumbnail: PaintCall.run(
              () => open.image.layerThumbnail(index: i, max: _layerThumb),
            ),
          ),
      ];
      final thumb = PaintCall.run(() => open.image.thumbnail(max: _tabThumb));
      emit(
        ready.copyWith(
          image: () => details.copyWith(layers: rows),
          tabs: [
            for (final tab in ready.tabs)
              tab.id == open.id
                  ? ImageTab(
                      id: tab.id,
                      title: tab.title,
                      isModified: tab.isModified,
                      thumbnail: thumb,
                    )
                  : tab,
          ],
        ),
      );
    } on Failure catch (failure) {
      _fail(failure, 'thumbnails');
    }
  }

  // ---- helpers ------------------------------------------------------------

  void _emitReady(
    Emitter<EditorState> emit,
    EditorReady Function(EditorReady current) update,
  ) {
    if (state case final EditorReady current) {
      emit(update(current));
    }
  }

  void _fail(Failure failure, String where) {
    AppLog.failure(failure, where: 'EditorBloc.$where');
    _eventBus.add(ShowFailureAction(failure));
  }

  /// A change the user asked for: a failure is logged and told.
  T? _try<T>(T Function() call, String where) {
    try {
      return PaintCall.run(call);
    } on Failure catch (failure) {
      _fail(failure, where);
      return null;
    }
  }

  /// One refresh at the next frame for the moves of this frame.
  void _askFrame() {
    if (_frameAsked) {
      return;
    }
    _frameAsked = true;
    _scheduleFrame(() {
      if (!isClosed) {
        add(const CanvasFrameEvent());
      }
    });
  }

  void _onFrame(CanvasFrameEvent event, Emitter<EditorState> emit) {
    _frameAsked = false;
    _refresh(emit);
  }

  /// Ends a view drag of the editor's own (an auto-scroll stops ticking).
  void _clearDrag() {
    if (_drag case final _AutoScrollDrag auto) {
      auto.timer?.cancel();
    }
    _drag = null;
  }

  /// A read the screen can do without: a failure is logged, not told.
  T? _safe<T>(T Function() call) {
    try {
      return PaintCall.run(call);
    } on Failure catch (failure) {
      AppLog.failure(failure, where: 'EditorBloc.read');
      return null;
    }
  }
}

/// A drag the editor handles itself instead of the core.
sealed class _Drag {}

final class _PanDrag extends _Drag {
  _PanDrag(this.last, this.button);

  Offset last;
  final CanvasButton button;
}

final class _ZoomDrag extends _Drag {
  _ZoomDrag(this.start, this.screenStart, this.button) : end = start;

  Offset start;
  Offset end;
  final Offset screenStart;
  final CanvasButton button;
  bool moved = false;

  /// Where the other button, held, moves the box from.
  Offset? mover;
}

/// Space + the right button: the view drifts toward the pointer while
/// held, faster the farther it is from the centre.
final class _AutoScrollDrag extends _Drag {
  _AutoScrollDrag(this.pointer, this.button);

  final CanvasButton button;

  Offset pointer;
  Timer? timer;
}

/// A paste or an import waiting for the answer about the canvas size.
sealed class _Pending {
  int get width;
  int get height;

  void dispose(ClipboardRepository clipboard);
}

final class _PendingPaste extends _Pending {
  _PendingPaste(this.clip, {required this.newLayer});

  final ClipImage clip;
  final bool newLayer;

  @override
  int get width => clip.width;

  @override
  int get height => clip.height;

  @override
  void dispose(ClipboardRepository clipboard) {
    if (!clipboard.isOwn(clip)) {
      clip.dispose();
    }
  }
}

final class _PendingImport extends _Pending {
  _PendingImport(this.picture, {required this.name});

  final Picture picture;
  final String name;

  @override
  int get width => picture.width;

  @override
  int get height => picture.height;

  @override
  void dispose(ClipboardRepository clipboard) => picture.dispose();
}
