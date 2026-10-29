import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:paint_bridge/src/rust/frb_generated.dart';

/// Loads the Rust library once per process: the copy cargokit bundled
/// with the app, or a library built by cargo (tests pass its path).
abstract final class PaintBridge {
  static bool _loaded = false;

  static Future<void> load({String? libraryPath}) async {
    if (_loaded) {
      return;
    }
    await RustLib.init(
      externalLibrary: libraryPath == null
          ? null
          : ExternalLibrary.open(libraryPath),
    );
    _loaded = true;
  }
}
