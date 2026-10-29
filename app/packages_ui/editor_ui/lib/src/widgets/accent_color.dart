import 'package:app_ui/app_ui.dart';
import 'package:flutter/painting.dart';
import 'package:paint_logic/paint_logic.dart';

/// The colour of a remembered accent choice.
extension AccentColor on AccentChoice {
  Color color(int customArgb) => switch (this) {
    AccentChoice.blue => AccentPalette.blue,
    AccentChoice.green => AccentPalette.green,
    AccentChoice.amber => AccentPalette.amber,
    AccentChoice.purple => AccentPalette.purple,
    AccentChoice.red => AccentPalette.red,
    AccentChoice.gray => AccentPalette.gray,
    AccentChoice.custom => Color(customArgb),
  };
}
