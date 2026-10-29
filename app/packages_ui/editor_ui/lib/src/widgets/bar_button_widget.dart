import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// A square button of the panels and the tool bar: an icon on glass that
/// lights up on hover, accent-tinted when [selected].
class BarButtonWidget extends StatelessWidget {
  const BarButtonWidget({
    required this.child,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.size = ControlSize.button,
    this.iconSize = ControlSize.icon,
    super.key,
  });

  final Widget child;

  /// Null where a parent already names the control.
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: GlassTap(
        tooltip: tooltip,
        selected: selected,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(
                size: iconSize,
                color: selected
                    ? context.tokens.onAccentSoft
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
