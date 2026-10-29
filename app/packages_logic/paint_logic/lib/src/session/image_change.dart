import 'dart:typed_data';

import 'package:paint_bridge/paint_bridge.dart';

/// What moved on an image since the screen last asked, read from the
/// core in one go: the tiles to draw again and, only when they moved,
/// the dearer facts (layers, history, the outline, which commands can
/// run). A `null` part did not move.
final class ImageChange {
  const ImageChange({
    required this.stamp,
    required this.tiles,
    required this.resetTiles,
    required this.colors,
    required this.overlay,
    this.layers,
    this.history,
    this.outline,
    this.available,
  });

  final ImageStamp stamp;

  /// Premultiplied tiles touching what changed; all of them when
  /// [resetTiles] (opened, shown again, resized).
  final List<PixelBlock> tiles;
  final bool resetTiles;
  final UserColors colors;
  final OverlayInfo overlay;

  /// Bottom first.
  final List<LayerProperties>? layers;
  final List<String>? history;

  /// Edges between pixels as `x0, y0, x1, y1` quadruples.
  final Int32List? outline;

  /// Command ids of the image that have something to act on now.
  final Set<String>? available;
}
