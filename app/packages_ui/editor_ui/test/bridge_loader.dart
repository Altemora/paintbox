import 'dart:io';

import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

/// Tests run on the bridge cargo built at the repository root (`cargo
/// build -p paintbox_bridge`): the real core, not a stand-in.
abstract final class BridgeLoader {
  static Future<void> load() {
    final name = Platform.isWindows
        ? 'paintbox_bridge.dll'
        : Platform.isMacOS
        ? 'libpaintbox_bridge.dylib'
        : 'libpaintbox_bridge.so';
    final target = p.normalize(
      p.join(Directory.current.path, '..', '..', '..', 'target'),
    );
    final release = File(p.join(target, 'release', name));
    final debug = File(p.join(target, 'debug', name));
    final library = debug.existsSync() ? debug : release;
    return PaintBridge.load(libraryPath: library.path);
  }
}
