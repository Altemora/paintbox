import 'dart:typed_data';
import 'dart:ui' show Offset, Rect;

import 'package:equatable/equatable.dart';
import 'package:paint_logic/paint_logic.dart';

/// How an image is called: by its file, or untitled with a number.
final class ImageTitle extends Equatable {
  const ImageTitle({this.fileName, this.untitledNumber});

  final String? fileName;
  final int? untitledNumber;

  @override
  List<Object?> get props => [fileName, untitledNumber];
}

/// One tab of the image strip.
final class ImageTab extends Equatable {
  const ImageTab({
    required this.id,
    required this.title,
    required this.isModified,
    this.thumbnail,
  });

  final int id;
  final ImageTitle title;
  final bool isModified;
  final PixelBlock? thumbnail;

  @override
  List<Object?> get props => [id, title, isModified, thumbnail];
}

/// A row of the Layers window.
final class LayerRow extends Equatable {
  const LayerRow({required this.properties, this.thumbnail});

  final LayerProperties properties;
  final PixelBlock? thumbnail;

  @override
  List<Object?> get props => [properties, thumbnail];
}

/// The marching ants: edges between pixels as `x0, y0, x1, y1`
/// quadruples, drawn shifted by the move in progress.
final class SelectionOutline extends Equatable {
  const SelectionOutline({
    required this.stamp,
    required this.segments,
    this.offset = Offset.zero,
  });

  static final empty = SelectionOutline(
    stamp: BigInt.zero,
    segments: Int32List(0),
  );

  final BigInt stamp;
  final Int32List segments;
  final Offset offset;

  bool get isEmpty => segments.isEmpty;

  @override
  List<Object?> get props => [stamp, segments.length, offset];
}

/// What the screen shows of the active image.
final class ImageDetails extends Equatable {
  const ImageDetails({
    required this.id,
    required this.stamp,
    required this.layers,
    required this.history,
    required this.outline,
    required this.handles,
    required this.guide,
    required this.available,
  });

  final int id;
  final ImageStamp stamp;

  /// Bottom first, as the core keeps them.
  final List<LayerRow> layers;
  final List<String> history;
  final SelectionOutline outline;
  final List<PointF> handles;
  final List<PointF> guide;

  /// Command ids of the image that have something to act on now.
  final Set<String> available;

  int get width => stamp.width;
  int get height => stamp.height;
  int get activeLayer => stamp.activeLayer;
  int get historyPosition => stamp.historyPosition;
  bool get hasSelection => stamp.hasSelection;

  ImageDetails copyWith({
    ImageStamp? stamp,
    List<LayerRow>? layers,
    List<String>? history,
    SelectionOutline? outline,
    List<PointF>? handles,
    List<PointF>? guide,
    Set<String>? available,
  }) => ImageDetails(
    id: id,
    stamp: stamp ?? this.stamp,
    layers: layers ?? this.layers,
    history: history ?? this.history,
    outline: outline ?? this.outline,
    handles: handles ?? this.handles,
    guide: guide ?? this.guide,
    available: available ?? this.available,
  );

  @override
  List<Object?> get props => [
    id,
    stamp,
    layers,
    history,
    outline,
    handles,
    guide,
    available,
  ];
}

sealed class EditorState extends Equatable {
  const EditorState();

  @override
  List<Object?> get props => [];
}

/// Everything is closed after Exit; the window goes.
final class EditorClosed extends EditorState {
  const EditorClosed();
}

final class EditorReady extends EditorState {
  const EditorReady({
    required this.tabs,
    required this.tool,
    required this.previousTool,
    required this.toolSettings,
    required this.colors,
    required this.palette,
    required this.panels,
    required this.theme,
    required this.recentFiles,
    this.activeId,
    this.image,
    this.view,
    this.editsSecondary = false,
    this.pointer,
    this.zoomBox,
    this.preview,
    this.busy,
    this.saving = false,
    this.temporaryPan = false,
    this.panning = false,
    this.pixelGrid = false,
    this.rulers = true,
  });

  final List<ImageTab> tabs;
  final int? activeId;
  final ImageDetails? image;
  final CanvasView? view;
  final Tool tool;
  final Tool previousTool;
  final ToolSettings toolSettings;

  /// The active image's colours (the next image's when none is open).
  final UserColors colors;
  final bool editsSecondary;
  final List<Rgba8> palette;
  final Panels panels;
  final ThemeChoice theme;
  final List<String> recentFiles;

  /// The pointer over the image, in its pixels; null off the canvas.
  final Offset? pointer;

  /// The Zoom tool's box being drawn, in image pixels.
  final Rect? zoomBox;
  final PreviewInfo? preview;

  /// The file being opened or saved.
  final String? busy;

  /// [busy] is being written, not read.
  final bool saving;

  /// Space held: the canvas drags the view.
  final bool temporaryPan;

  /// A drag is moving the view now.
  final bool panning;
  final bool pixelGrid;

  /// Rulers along the canvas (View > Rulers).
  final bool rulers;

  ImageTab? get activeTab {
    for (final tab in tabs) {
      if (tab.id == activeId) {
        return tab;
      }
    }
    return null;
  }

  bool get hasImage => image != null;

  bool get hasPreview => preview != null;

  /// The Text tool has a caret: keys type into it.
  bool get isTyping => image?.stamp.isTyping ?? false;

  bool get pointerOnCanvas => pointer != null;

  bool get canUndo => image?.stamp.canUndo ?? false;

  bool get canRedo => image?.stamp.canRedo ?? false;

  /// Whether a command can run now: the image's from the core, the
  /// program's by what is open.
  bool canRun(String id) {
    if (hasPreview) {
      return false;
    }
    // One file at a time: nothing else is read, written or closed while
    // a file is.
    if (busy != null &&
        const {'open', 'save', 'save_as', 'close', 'exit'}.contains(id)) {
      return false;
    }
    switch (id) {
      case 'new' || 'open' || 'exit' || 'help':
      case 'toggle_tools' || 'toggle_history' || 'toggle_layers':
      case 'toggle_colors' || 'paste_into_new_image':
        return true;
      case 'close' || 'save' || 'save_as' || 'zoom_in' || 'zoom_out':
      case 'zoom_to_window' || 'actual_size' || 'pixel_grid' || 'paste':
      case 'rulers':
      case 'paste_into_new_layer':
        return hasImage;
      case 'zoom_to_selection':
        return image?.hasSelection ?? false;
      case 'next_image' || 'previous_image':
        return tabs.length > 1;
    }
    return image?.available.contains(id) ?? false;
  }

  EditorReady copyWith({
    List<ImageTab>? tabs,
    int? Function()? activeId,
    ImageDetails? Function()? image,
    CanvasView? Function()? view,
    Tool? tool,
    Tool? previousTool,
    ToolSettings? toolSettings,
    UserColors? colors,
    bool? editsSecondary,
    List<Rgba8>? palette,
    Panels? panels,
    ThemeChoice? theme,
    List<String>? recentFiles,
    Offset? Function()? pointer,
    Rect? Function()? zoomBox,
    PreviewInfo? Function()? preview,
    String? Function()? busy,
    bool? saving,
    bool? temporaryPan,
    bool? panning,
    bool? pixelGrid,
    bool? rulers,
  }) => EditorReady(
    tabs: tabs ?? this.tabs,
    activeId: activeId == null ? this.activeId : activeId(),
    image: image == null ? this.image : image(),
    view: view == null ? this.view : view(),
    tool: tool ?? this.tool,
    previousTool: previousTool ?? this.previousTool,
    toolSettings: toolSettings ?? this.toolSettings,
    colors: colors ?? this.colors,
    editsSecondary: editsSecondary ?? this.editsSecondary,
    palette: palette ?? this.palette,
    panels: panels ?? this.panels,
    theme: theme ?? this.theme,
    recentFiles: recentFiles ?? this.recentFiles,
    pointer: pointer == null ? this.pointer : pointer(),
    zoomBox: zoomBox == null ? this.zoomBox : zoomBox(),
    preview: preview == null ? this.preview : preview(),
    busy: busy == null ? this.busy : busy(),
    saving: saving ?? this.saving,
    temporaryPan: temporaryPan ?? this.temporaryPan,
    panning: panning ?? this.panning,
    pixelGrid: pixelGrid ?? this.pixelGrid,
    rulers: rulers ?? this.rulers,
  );

  @override
  List<Object?> get props => [
    tabs,
    activeId,
    image,
    view,
    tool,
    previousTool,
    toolSettings,
    colors,
    editsSecondary,
    palette,
    panels,
    theme,
    recentFiles,
    pointer,
    zoomBox,
    preview,
    busy,
    saving,
    temporaryPan,
    panning,
    pixelGrid,
    rulers,
  ];
}
