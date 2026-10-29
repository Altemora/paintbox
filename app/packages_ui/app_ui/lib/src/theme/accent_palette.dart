import 'package:flutter/material.dart';

/// The accents the settings offer and the rules that keep any accent,
/// a custom one included, readable on both themes.
abstract final class AccentPalette {
  static const Color blue = Color(0xFF5B8DEF);
  static const Color green = Color(0xFF3FAE7A);
  static const Color amber = Color(0xFFE8A33A);
  static const Color purple = Color(0xFF9A6CF0);
  static const Color red = Color(0xFFE5534B);
  static const Color gray = Color(0xFF8C9199);

  /// WCAG contrast ratio of two opaque colours, 1 to 21.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (la > lb ? la + 0.05 : lb + 0.05) /
        (la > lb ? lb + 0.05 : la + 0.05);
  }

  /// [color] moved toward white over a dark [surface] (toward black over a
  /// light one) in small steps until it reaches [ratio] against it.
  static Color readable(Color color, Color surface, [double ratio = 3]) {
    final target = surface.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;
    var result = color.withValues(alpha: 1);
    for (var t = 0.08; contrast(result, surface) < ratio && t <= 1; t += 0.08) {
      result = Color.lerp(color.withValues(alpha: 1), target, t)!;
    }
    return result;
  }

  /// Black or white, whichever reads better on [accent]: text on a filled
  /// button, a check on a selected box.
  static Color onAccent(Color accent) =>
      contrast(accent, Colors.white) >=
          contrast(accent, const Color(0xFF0F1117))
      ? Colors.white
      : const Color(0xFF0F1117);
}
