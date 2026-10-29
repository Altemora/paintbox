import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/models/clipboard_content.dart';
import 'package:paint_logic/src/paint_call.dart';
import 'package:paint_logic/src/services/clipboard_service.dart';

/// Copy puts the picture on the system clipboard and keeps its own copy
/// with the place it came from; Paste takes that copy back while the
/// system clipboard still holds it (so it lands where it was), and any
/// other program's picture at the top-left corner.
class ClipboardRepository {
  ClipboardRepository(this._service);

  final ClipboardService _service;
  ClipboardContent? _own;

  Future<void> put(ClipImage clip) async {
    final png = await PaintCall.runAsync(() => encodeClipPng(clip: clip));
    _own?.clip.dispose();
    _own = ClipboardContent(clip: clip, png: png);
    await _service.writeImage(png);
  }

  /// The picture to paste, or null when the clipboard holds none.
  Future<ClipImage?> take() async {
    Uint8List? bytes;
    try {
      bytes = await _service.readImage();
    } on Failure catch (failure) {
      // An unreadable system clipboard still leaves our own copy.
      AppLog.failure(failure, where: 'ClipboardRepository.take');
    }
    final own = _own;
    if (own != null && (bytes == null || listEquals(bytes, own.png))) {
      return own.clip;
    }
    if (bytes == null || bytes.isEmpty) {
      return null;
    }
    return PaintCall.runAsync(() => decodeClip(bytes: bytes!));
  }

  /// Whether [clip] is the kept copy (not to be disposed after a paste).
  bool isOwn(ClipImage clip) => identical(_own?.clip, clip);
}
