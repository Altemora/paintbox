import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:paint_logic/paint_logic.dart';

/// The composited image as GPU images of 256-pixel tiles. Only the tiles
/// the core reports changed are made anew; an old tile stays on screen
/// until its replacement is decoded, so painting never flickers.
class CanvasTiles extends ChangeNotifier {
  final Map<int, ui.Image> _images = {};
  final Map<int, ui.Rect> _rects = {};
  final Map<int, int> _shown = {};
  int _counter = 0;
  int _generation = 0;
  int? _imageId;
  bool _disposed = false;

  Iterable<(ui.Rect, ui.Image)> get tiles sync* {
    for (final entry in _images.entries) {
      yield (_rects[entry.key]!, entry.value);
    }
  }

  void apply(int imageId, List<PixelBlock> blocks, {required bool reset}) {
    if (imageId != _imageId) {
      // Another image: nothing of the old one may show under it.
      _clear();
      _imageId = imageId;
    } else if (reset) {
      _generation++;
      final keep = {for (final b in blocks) _key(b.x, b.y)};
      for (final key in _images.keys.toList()) {
        if (!keep.contains(key)) {
          _images.remove(key)?.dispose();
          _rects.remove(key);
        }
      }
      _shown.clear();
    }
    final generation = _generation;
    for (final block in blocks) {
      final key = _key(block.x, block.y);
      final version = ++_counter;
      final rect = ui.Rect.fromLTWH(
        block.x.toDouble(),
        block.y.toDouble(),
        block.width.toDouble(),
        block.height.toDouble(),
      );
      ui.decodeImageFromPixels(
        block.pixels,
        block.width,
        block.height,
        ui.PixelFormat.rgba8888,
        (image) {
          // Any decode newer than the tile on screen is shown: during a
          // fast drag a newer request is nearly always on its way, and
          // waiting for the newest would leave the tile behind the brush.
          if (_disposed ||
              generation != _generation ||
              version <= (_shown[key] ?? 0)) {
            image.dispose();
            return;
          }
          _shown[key] = version;
          _images[key]?.dispose();
          _images[key] = image;
          _rects[key] = rect;
          notifyListeners();
        },
      );
    }
    notifyListeners();
  }

  void _clear() {
    _generation++;
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _rects.clear();
    _shown.clear();
  }

  static int _key(int x, int y) => (y << 20) | x;

  @override
  void dispose() {
    _disposed = true;
    _clear();
    super.dispose();
  }
}
