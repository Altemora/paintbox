import 'dart:ui' show Offset, Size;

import 'package:paint_logic/paint_logic.dart';

/// Every user action of the editor window. Scripted automation would
/// send the same events.
sealed class EditorEvent {
  const EditorEvent();
}

/// Opens the first image (or the files given on the command line).
final class EditorStartedEvent extends EditorEvent {
  const EditorStartedEvent({this.paths = const []});

  final List<String> paths;
}

/// A menu item, a tool bar or panel button, or its keys: a command id of
/// the core (`undo`, `adjust:levels`, `toggle_tools`).
final class CommandInvokedEvent extends EditorEvent {
  const CommandInvokedEvent(this.id);

  final String id;
}

/// A key went down, named as the core names keys (`Z`, `Delete`,
/// `Equals`, `F4`, `ArrowLeft`); [letter] is the character it types, for
/// tool letters and `[`, `]`.
final class KeyPressedEvent extends EditorEvent {
  const KeyPressedEvent({
    required this.key,
    required this.ctrl,
    required this.shift,
    required this.alt,
    this.letter,
  });

  final String key;
  final String? letter;
  final bool ctrl;
  final bool shift;
  final bool alt;
}

/// Characters typed while the Text tool has a caret.
final class TextTypedEvent extends EditorEvent {
  const TextTypedEvent(this.text);

  final String text;
}

/// An editing key of the text being typed; Ctrl goes by words.
final class TextKeyPressedEvent extends EditorEvent {
  const TextKeyPressedEvent(this.key, {required this.ctrl});

  final TextKey key;
  final bool ctrl;
}

final class ModifiersChangedEvent extends EditorEvent {
  const ModifiersChangedEvent({
    required this.ctrl,
    required this.shift,
    required this.alt,
  });

  final bool ctrl;
  final bool shift;
  final bool alt;
}

/// Space held or let go: the temporary Pan.
final class SpaceHeldEvent extends EditorEvent {
  const SpaceHeldEvent(this.held);

  final bool held;
}

enum CanvasButton { primary, secondary, middle }

/// Pointer events over the canvas area, in its logical pixels.
final class CanvasPointerDownEvent extends EditorEvent {
  const CanvasPointerDownEvent({
    required this.position,
    required this.button,
    required this.ctrl,
    required this.shift,
    required this.alt,
  });

  final Offset position;
  final CanvasButton button;
  final bool ctrl;
  final bool shift;
  final bool alt;
}

final class CanvasPointerMovedEvent extends EditorEvent {
  const CanvasPointerMovedEvent(this.position);

  final Offset position;
}

final class CanvasPointerUpEvent extends EditorEvent {
  const CanvasPointerUpEvent({
    required this.position,
    required this.button,
    required this.ctrl,
    required this.shift,
    required this.alt,
  });

  final Offset position;
  final CanvasButton button;
  final bool ctrl;
  final bool shift;
  final bool alt;
}

final class CanvasPointerExitedEvent extends EditorEvent {
  const CanvasPointerExitedEvent();
}

/// The wheel: scrolls, Shift sideways, Ctrl zooms about the pointer.
final class CanvasWheelEvent extends EditorEvent {
  const CanvasWheelEvent({
    required this.position,
    required this.delta,
    required this.ctrl,
    required this.shift,
    this.alt = false,
  });

  final Offset position;
  final Offset delta;
  final bool ctrl;
  final bool shift;
  final bool alt;
}

/// The canvas area's size and the display's scale.
final class ViewportChangedEvent extends EditorEvent {
  const ViewportChangedEvent(this.size, this.pixelRatio);

  final Size size;
  final double pixelRatio;
}

/// The canvas of an image was built and needs every tile.
final class CanvasAttachedEvent extends EditorEvent {
  const CanvasAttachedEvent(this.imageId);

  final int imageId;
}

final class ToolSelectedEvent extends EditorEvent {
  const ToolSelectedEvent(this.tool);

  final Tool tool;
}

final class ToolSettingsChangedEvent extends EditorEvent {
  const ToolSettingsChangedEvent(this.settings);

  final ToolSettings settings;
}

final class ColorsChangedEvent extends EditorEvent {
  const ColorsChangedEvent(this.colors);

  final UserColors colors;
}

/// Which of the two colours the Colors window edits (C).
final class EditedColorChosenEvent extends EditorEvent {
  const EditedColorChosenEvent({required this.secondary});

  final bool secondary;
}

final class TabSelectedEvent extends EditorEvent {
  const TabSelectedEvent(this.imageId);

  final int imageId;
}

final class TabCloseRequestedEvent extends EditorEvent {
  const TabCloseRequestedEvent(this.imageId);

  final int imageId;
}

/// The answer to "save changes?": save, discard, or (null) keep the image.
final class CloseAnsweredEvent extends EditorEvent {
  const CloseAnsweredEvent(this.imageId, {required this.save});

  final int imageId;
  final bool? save;
}

/// The window's close button or File > Exit.
final class ExitRequestedEvent extends EditorEvent {
  const ExitRequestedEvent();
}

final class OpenPathsEvent extends EditorEvent {
  const OpenPathsEvent(this.paths, {this.dropped = false});

  final List<String> paths;

  /// Dropped on the window rather than chosen: a file from the system's
  /// temporary folder (a browser's picture) opens untitled.
  final bool dropped;
}

/// A tab dragged to [index] of the strip.
final class TabMovedEvent extends EditorEvent {
  const TabMovedEvent(this.imageId, this.index);

  final int imageId;
  final int index;
}

/// The answers of the save questions: the quality of a JPEG; flattening
/// was agreed when asked.
final class SaveConfirmedEvent extends EditorEvent {
  const SaveConfirmedEvent({
    required this.imageId,
    required this.path,
    required this.jpegQuality,
    this.closeAfter = false,
  });

  final int imageId;
  final String path;
  final int jpegQuality;
  final bool closeAfter;
}

/// A save question was cancelled: an exit or a close waiting on it stops.
final class SaveCancelledEvent extends EditorEvent {
  const SaveCancelledEvent();
}

final class NewImageConfirmedEvent extends EditorEvent {
  const NewImageConfirmedEvent(this.width, this.height);

  final int width;
  final int height;
}

final class ResizeConfirmedEvent extends EditorEvent {
  const ResizeConfirmedEvent(this.width, this.height, this.resampling);

  final int width;
  final int height;
  final Resampling resampling;
}

final class CanvasSizeConfirmedEvent extends EditorEvent {
  const CanvasSizeConfirmedEvent(this.width, this.height, this.anchor);

  final int width;
  final int height;
  final Anchor anchor;
}

/// A layer dragged in the Layers window, by the core's indices (bottom
/// up).
final class LayerMovedEvent extends EditorEvent {
  const LayerMovedEvent(this.from, this.to);

  final int from;
  final int to;
}

/// A floating window let go after a drag by its title: its offset from
/// its corner, remembered.
final class PanelMovedEvent extends EditorEvent {
  const PanelMovedEvent(this.panel, this.offset);

  final String panel;
  final Offset offset;
}

final class LayerSelectedEvent extends EditorEvent {
  const LayerSelectedEvent(this.index);

  final int index;
}

final class LayerVisibilityToggledEvent extends EditorEvent {
  const LayerVisibilityToggledEvent(this.index);

  final int index;
}

/// Double-click on a layer: its properties.
final class LayerPropertiesRequestedEvent extends EditorEvent {
  const LayerPropertiesRequestedEvent(this.index);

  final int index;
}

final class HistoryJumpedEvent extends EditorEvent {
  const HistoryJumpedEvent(this.position);

  final int position;
}

final class PreviewParamChangedEvent extends EditorEvent {
  const PreviewParamChangedEvent(this.name, this.values);

  final String name;
  final List<double> values;
}

final class LayerPreviewChangedEvent extends EditorEvent {
  const LayerPreviewChangedEvent(this.properties);

  final LayerProperties properties;
}

final class PreviewEndedEvent extends EditorEvent {
  const PreviewEndedEvent({required this.ok});

  final bool ok;
}

/// An effect's render arrived on a worker.
final class PreviewWokeEvent extends EditorEvent {
  const PreviewWokeEvent();
}

/// Colors between More and Less, remembered.
final class ColorsMoreToggledEvent extends EditorEvent {
  const ColorsMoreToggledEvent();
}

final class ThemeChosenEvent extends EditorEvent {
  const ThemeChosenEvent(this.theme);

  final ThemeChoice theme;
}

/// An accent of the set, or [AccentChoice.custom] with its ARGB.
final class AccentChosenEvent extends EditorEvent {
  const AccentChosenEvent(this.accent, {this.custom});

  final AccentChoice accent;

  /// The custom colour; null keeps the one chosen before.
  final int? custom;
}

/// The interface language by its code; null follows the system.
final class LanguageChosenEvent extends EditorEvent {
  const LanguageChosenEvent(this.language);

  final String? language;
}

/// The thumbnails' quiet moment after painting.
final class ThumbnailsDueEvent extends EditorEvent {
  const ThumbnailsDueEvent();
}

/// The answer to "expand the canvas?" for a paste or an import larger
/// than it: expand, keep it, or (null) give up.
final class ExpandAnsweredEvent extends EditorEvent {
  const ExpandAnsweredEvent({required this.expand});

  final bool? expand;
}

/// A tick of the auto-scroll of Space + the right button.
final class AutoScrollTickedEvent extends EditorEvent {
  const AutoScrollTickedEvent();
}

final class CurvesChangedEvent extends EditorEvent {
  const CurvesChangedEvent(this.curves);

  final PaintCurves curves;
}

/// A frame is coming: what the pointer's moves changed is shown once.
final class CanvasFrameEvent extends EditorEvent {
  const CanvasFrameEvent();
}

/// The status bar's zoom slider: this zoom about the view's centre.
final class ZoomSetEvent extends EditorEvent {
  const ZoomSetEvent(this.zoom);

  final double zoom;
}

/// Two fingers on a touchpad: [pan] in logical pixels and [scale]
/// since the last update, about [position].
final class CanvasPanZoomEvent extends EditorEvent {
  const CanvasPanZoomEvent({
    required this.position,
    required this.pan,
    required this.scale,
  });

  final Offset position;
  final Offset pan;
  final double scale;
}
