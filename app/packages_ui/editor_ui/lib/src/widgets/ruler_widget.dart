import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:paint_logic/paint_logic.dart';

/// A ruler along the canvas in pixels of the image: numbered ticks a
/// readable distance apart at any zoom, and a mark where the pointer is.
class RulerWidget extends StatelessWidget {
  const RulerWidget({
    required this.view,
    required this.vertical,
    this.pointer,
    super.key,
  });

  final CanvasView view;
  final bool vertical;

  /// The pointer's place in pixels of the image, or null off the canvas.
  final double? pointer;

  /// The numbers' type; the rulers' corner names the unit in it.
  static TextStyle labelStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .labelSmall!
      .copyWith(
        color: context.tokens.muted,
        fontSize: 9,
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _RulerPainter(
          view: view,
          vertical: vertical,
          pointer: pointer,
          tick: tokens.muted,
          mark: tokens.handle,
          label: labelStyle(context),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.view,
    required this.vertical,
    required this.pointer,
    required this.tick,
    required this.mark,
    required this.label,
  });

  final CanvasView view;
  final bool vertical;
  final double? pointer;
  final Color tick;
  final Color mark;
  final TextStyle label;

  /// Numbered ticks at least this many logical pixels apart.
  static const double _spacing = 64;
  static const List<int> _steps = [1, 2, 5];

  /// The image step between numbered ticks: 1, 2, 5, 10, 20, 50…
  double get _step {
    final want = _spacing / view.scale;
    var power = 1.0;
    while (true) {
      for (final s in _steps) {
        if (s * power >= want) {
          return s * power;
        }
      }
      power *= 10;
    }
  }

  double _screen(double v) => vertical
      ? view.toScreen(Offset(0, v)).dy
      : view.toScreen(Offset(v, 0)).dx;

  @override
  void paint(Canvas canvas, Size size) {
    final length = vertical ? size.height : size.width;
    final depth = vertical ? size.width : size.height;
    final from = vertical
        ? view.toImage(Offset.zero).dy
        : view.toImage(Offset.zero).dx;
    final to = vertical
        ? view.toImage(Offset(0, length)).dy
        : view.toImage(Offset(length, 0)).dx;
    final step = _step;
    final minor = step / (step >= 10 && (step / 10) * view.scale >= 6 ? 10 : 5);
    final line = Paint()
      ..color = tick.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    final start = (from / minor).floor() * minor;
    for (var v = start; v <= to; v += minor) {
      final p = _screen(v).roundToDouble() + 0.5;
      final major = (v / step).roundToDouble() * step == v;
      final h = major ? depth : depth * 0.3;
      canvas.drawLine(
        vertical ? Offset(depth - h, p) : Offset(p, depth - h),
        vertical ? Offset(depth, p) : Offset(p, depth),
        line,
      );
      if (major) {
        _label(canvas, v, p, depth);
      }
    }
    final at = pointer;
    if (at != null) {
      final p = _screen(at);
      canvas.drawLine(
        vertical ? Offset(0, p) : Offset(p, 0),
        vertical ? Offset(depth, p) : Offset(p, depth),
        Paint()
          ..color = mark
          ..strokeWidth = 1,
      );
    }
  }

  void _label(Canvas canvas, double v, double p, double depth) {
    final text = TextPainter(
      text: TextSpan(text: v.round().toString(), style: label),
      textDirection: TextDirection.ltr,
    )..layout();
    if (vertical) {
      // Read from below, as rulers along the left edge are.
      canvas
        ..save()
        ..translate(1, p + 2 + text.width)
        ..rotate(-math.pi / 2);
      text.paint(canvas, Offset.zero);
      canvas.restore();
    } else {
      text.paint(canvas, Offset(p + 2, -1));
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.view != view || old.pointer != pointer || old.tick != tick;
}
