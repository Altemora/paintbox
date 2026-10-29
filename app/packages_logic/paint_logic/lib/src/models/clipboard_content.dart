import 'dart:typed_data';

import 'package:paint_bridge/paint_bridge.dart';

/// What this program last put on the system clipboard: the pixels with
/// their place, and the PNG bytes by which it recognises them there.
final class ClipboardContent {
  const ClipboardContent({required this.clip, required this.png});

  final ClipImage clip;
  final Uint8List png;
}
