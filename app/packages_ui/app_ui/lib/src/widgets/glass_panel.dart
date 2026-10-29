import 'dart:ui' show ImageFilter;

import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// A translucent surface with a hairline border: every panel, bar,
/// dialog and popover of the app.
///
/// [blur] costs GPU time, so it is for surfaces over moving content only
/// (the floating windows over the canvas); static bars rely on the tint.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.radius = Radii.xs,
    this.padding,
    this.strong = false,
    this.blur = false,
    this.border = true,
    this.glow = false,
    this.shadow = false,
    this.color,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  /// The stronger fill, for surfaces that float above others.
  final bool strong;
  final bool blur;
  final bool border;

  /// A soft accent glow behind the panel: one element per screen.
  final bool glow;

  /// The floating shadow of a window over the canvas.
  final bool shadow;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final shape = BorderRadius.circular(radius);
    var fill = color ?? (strong ? tokens.glassStrong : tokens.glass);
    if (glow || shadow) {
      // A shadow behind a translucent fill shows through and tints it;
      // a floating panel gets an opaque base.
      fill = Color.alphaBlend(fill, Theme.of(context).colorScheme.surface);
    }
    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: shape,
        border: border ? Border.all(color: tokens.hairline) : null,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    content = ClipRRect(
      borderRadius: shape,
      child: blur
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: tokens.blur,
                sigmaY: tokens.blur,
              ),
              child: content,
            )
          : content,
    );
    if (glow || shadow) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            if (glow)
              BoxShadow(color: tokens.glow, blurRadius: 40, spreadRadius: -8),
            BoxShadow(
              color: tokens.shadow,
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: content,
      );
    }
    return content;
  }
}
