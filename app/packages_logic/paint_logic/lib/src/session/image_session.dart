import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/paint_call.dart';
import 'package:paint_logic/src/paint_catalog.dart';
import 'package:paint_logic/src/session/image_change.dart';

/// An open image as the screen reads it. The core's session keeps what
/// was last seen, so one [takeChange] says what moved and reads only
/// that; the bloc does not piece the image's state together from calls
/// of its own.
final class ImageSession {
  const ImageSession(this.image);

  final PaintImage image;

  /// Tiles of the canvas, in image pixels.
  static const tileSize = 256;

  /// What moved since the last call; [reset] reports everything (the
  /// image was opened or shown again). Throws a `Failure`.
  ImageChange takeChange({bool reset = false}) => PaintCall.run(() {
    final changes = image.takeChanges(reset: reset);
    final stamp = changes.stamp;
    final dirty = changes.dirty;
    final tiles = changes.resized
        ? image.compositeTiles(
            area: PaintRect(
              x: 0,
              y: 0,
              width: stamp.width,
              height: stamp.height,
            ),
            tile: tileSize,
          )
        : dirty == null
        ? const <PixelBlock>[]
        : image.compositeTiles(area: dirty, tile: tileSize);
    return ImageChange(
      stamp: stamp,
      tiles: tiles,
      resetTiles: changes.resized,
      colors: image.colors(),
      overlay: image.overlay(),
      layers: changes.layers ? image.layers() : null,
      history: changes.history ? image.historyNames() : null,
      outline: changes.selection ? image.selectionOutline() : null,
      available: changes.availability ? _available() : null,
    );
  });

  Set<String> _available() => {
    for (final id in _commandIds)
      if (image.canRun(id: id)) id,
  };

  static final List<String> _commandIds = [
    for (final id in PaintCatalog.commands.keys) id,
    // The Effects menu is not among the commands with keys.
    for (final g in PaintCatalog.effectMenu) ...g.ids,
  ];
}
