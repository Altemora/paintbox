import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// A row, button or tile that lights up on hover and press the way glass
/// does; `selected` tints it with the accent.
class GlassTap extends StatelessWidget {
  const GlassTap({
    required this.child,
    super.key,
    this.onTap,
    this.onSecondaryTap,
    this.onDoubleTap,
    this.onTapDown,
    this.radius = Radii.xxs,
    this.selected = false,
    this.padding,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onDoubleTap;

  /// At once on the press, before a double click could be told apart.
  final VoidCallback? onTapDown;
  final double radius;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final shape = BorderRadius.circular(radius);
    Widget tap = AnimatedContainer(
      duration: Motion.fast,
      curve: Motion.curve,
      decoration: BoxDecoration(
        color: selected ? tokens.accentSoft : Colors.transparent,
        borderRadius: shape,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onSecondaryTap: onSecondaryTap,
          onDoubleTap: onDoubleTap,
          onTapDown: onTapDown == null ? null : (_) => onTapDown!(),
          borderRadius: shape,
          hoverColor: tokens.glassHover,
          splashColor: tokens.glassHover,
          highlightColor: tokens.glass,
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
    if (tooltip != null) {
      tap = Tooltip(message: tooltip, child: tap);
    }
    return tap;
  }
}
