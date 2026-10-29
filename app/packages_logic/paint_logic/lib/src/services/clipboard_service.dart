import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';

/// The system clipboard's pictures, as PNG (or any format the core
/// reads) bytes.
abstract class ClipboardService {
  Future<Uint8List?> readImage();

  Future<void> writeImage(Uint8List png);
}

/// The clipboard through `pasteboard`. Writing pictures is not supported
/// on Linux by the plugin; reading is.
class SystemClipboardService implements ClipboardService {
  @override
  Future<Uint8List?> readImage() async {
    try {
      return await Pasteboard.image;
    } on PlatformException catch (error, stackTrace) {
      throw StorageFailure(
        reason: 'cannot read the clipboard',
        origin: error,
        originStackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> writeImage(Uint8List png) async {
    try {
      await Pasteboard.writeImage(png);
    } on PlatformException catch (error, stackTrace) {
      throw StorageFailure(
        reason: 'cannot write the clipboard',
        origin: error,
        originStackTrace: stackTrace,
      );
    }
  }
}

/// A clipboard of this process only, for tests and screenshot scenes.
class MemoryClipboardService implements ClipboardService {
  Uint8List? _image;

  @override
  Future<Uint8List?> readImage() async => _image;

  @override
  Future<void> writeImage(Uint8List png) async => _image = png;
}
