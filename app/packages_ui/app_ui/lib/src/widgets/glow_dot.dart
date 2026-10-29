import 'package:flutter/material.dart';

/// A small coloured dot for a status (an unsaved image, a busy render).
class GlowDot extends StatelessWidget {
  const GlowDot({
    required this.color,
    super.key,
    this.size = 8,
    this.glow = true,
  });

  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: glow
          ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)]
          : null,
    ),
  );
}
