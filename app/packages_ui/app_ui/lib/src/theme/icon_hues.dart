import 'package:flutter/material.dart';

/// The hues of the tool icons. Paint.NET colours its tools by kind
/// (selections and moves blue, the wand's spark yellow, the eraser
/// pink), which finds a tool faster than its shape alone; each theme has
/// its own shade of every hue, light enough on dark glass and deep
/// enough on light.
class IconHues extends ThemeExtension<IconHues> {
  const IconHues({
    required this.blue,
    required this.cyan,
    required this.green,
    required this.yellow,
    required this.orange,
    required this.red,
    required this.violet,
  });

  factory IconHues.dark() => const IconHues(
    blue: Color(0xFF5B9CFF),
    cyan: Color(0xFF4FCFDF),
    green: Color(0xFF5BD38A),
    yellow: Color(0xFFF5CF4A),
    orange: Color(0xFFF29A4A),
    red: Color(0xFFF2677A),
    violet: Color(0xFFB18CFF),
  );

  factory IconHues.light() => const IconHues(
    blue: Color(0xFF2F6FDB),
    cyan: Color(0xFF1597A8),
    green: Color(0xFF2E9E5B),
    yellow: Color(0xFF9E7800),
    orange: Color(0xFFD9731F),
    red: Color(0xFFD14257),
    violet: Color(0xFF7D57D6),
  );

  /// Selections, moves and the zoom lens.
  final Color blue;

  /// The colour picker.
  final Color cyan;

  /// The paint bucket.
  final Color green;

  /// The magic wand's spark and the pencil.
  final Color yellow;

  /// The brush's paint, the hand, the stamp.
  final Color orange;

  /// The eraser and recolour.
  final Color red;

  /// The gradient, lines and shapes.
  final Color violet;

  @override
  IconHues copyWith({
    Color? blue,
    Color? cyan,
    Color? green,
    Color? yellow,
    Color? orange,
    Color? red,
    Color? violet,
  }) => IconHues(
    blue: blue ?? this.blue,
    cyan: cyan ?? this.cyan,
    green: green ?? this.green,
    yellow: yellow ?? this.yellow,
    orange: orange ?? this.orange,
    red: red ?? this.red,
    violet: violet ?? this.violet,
  );

  @override
  IconHues lerp(ThemeExtension<IconHues>? other, double t) {
    if (other is! IconHues) {
      return this;
    }
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return IconHues(
      blue: c(blue, other.blue),
      cyan: c(cyan, other.cyan),
      green: c(green, other.green),
      yellow: c(yellow, other.yellow),
      orange: c(orange, other.orange),
      red: c(red, other.red),
      violet: c(violet, other.violet),
    );
  }
}

extension IconHuesContext on BuildContext {
  IconHues get hues =>
      Theme.of(this).extension<IconHues>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? IconHues.dark()
          : IconHues.light());
}
