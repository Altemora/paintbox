import 'package:flutter/material.dart';

/// The ambient backdrop the window sits on: a deep base with two soft
/// accent-tinted blooms. Glass reads as glass only over something.
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final bloomA = scheme.primary.withValues(alpha: isDark ? 0.16 : 0.18);
    final bloomB = scheme.tertiary.withValues(alpha: isDark ? 0.12 : 0.14);
    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surface),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -220,
            top: -180,
            child: _Bloom(color: bloomA, size: 720),
          ),
          Positioned(
            right: -260,
            bottom: -240,
            child: _Bloom(color: bloomB, size: 820),
          ),
          child,
        ],
      ),
    );
  }
}

class _Bloom extends StatelessWidget {
  const _Bloom({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}
