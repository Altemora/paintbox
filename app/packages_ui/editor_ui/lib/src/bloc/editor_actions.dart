import 'package:core/core.dart';
import 'package:editor_ui/src/bloc/editor_state.dart';
import 'package:paint_logic/paint_logic.dart';

/// One-shot outcomes of the editor; components word them or ask the
/// questions they stand for.
sealed class EditorAction extends ActionEvent {
  const EditorAction();
}

/// Pixels of an image changed: the canvas makes these tiles anew. A
/// [reset] drops every tile first (another size, another image). Pixels
/// are a feed for drawing, not screen state, so they travel here.
final class CanvasTilesAction extends EditorAction {
  const CanvasTilesAction({
    required this.imageId,
    required this.blocks,
    required this.reset,
  });

  final int imageId;
  final List<PixelBlock> blocks;
  final bool reset;
}

final class AskNewImageAction extends EditorAction {
  const AskNewImageAction(this.width, this.height);

  final int width;
  final int height;
}

final class AskResizeAction extends EditorAction {
  const AskResizeAction(this.width, this.height, this.resampling);

  final int width;
  final int height;
  final Resampling resampling;
}

final class AskCanvasSizeAction extends EditorAction {
  const AskCanvasSizeAction(this.width, this.height);

  final int width;
  final int height;
}

/// Saving to [path] needs answers first: whether to flatten the layers,
/// and the JPEG quality.
final class AskSaveOptionsAction extends EditorAction {
  const AskSaveOptionsAction({
    required this.imageId,
    required this.path,
    required this.flatten,
    required this.jpegQuality,
    required this.closeAfter,
  });

  final int imageId;
  final String path;
  final bool flatten;

  /// Null when the format has no quality.
  final int? jpegQuality;
  final bool closeAfter;
}

/// The image has unsaved changes; save, discard or keep it?
final class AskCloseAction extends EditorAction {
  const AskCloseAction(this.imageId, this.title);

  final int imageId;
  final ImageTitle title;
}

final class ImageSavedAction extends EditorAction {
  const ImageSavedAction(this.title);

  final ImageTitle title;
}

final class ToolUnavailableAction extends EditorAction {
  const ToolUnavailableAction(this.tool);

  final Tool tool;
}

final class ShowHelpAction extends EditorAction {
  const ShowHelpAction();
}

/// Everything is closed: the window may go.
final class ExitConfirmedAction extends EditorAction {
  const ExitConfirmedAction();
}

/// A paste or an import is larger than the canvas: expand it?
final class AskExpandCanvasAction extends EditorAction {
  const AskExpandCanvasAction();
}
