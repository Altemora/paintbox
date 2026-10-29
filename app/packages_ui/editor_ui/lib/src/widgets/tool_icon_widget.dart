import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:paint_logic/paint_logic.dart';

/// Paintbox's own tool icons: thin line glyphs drawn on a 24 × 24 grid,
/// one per tool of the core, coloured by kind as Paint.NET's are
/// ([IconHues]): selections and moves blue, painting tools by their paint.
class ToolIconWidget extends StatelessWidget {
  const ToolIconWidget({
    required this.tool,
    super.key,
    this.size = 18,
    this.color,
  });

  final Tool tool;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _ToolGlyphPainter(
      tool,
      color ?? IconTheme.of(context).color ?? Colors.white,
      context.hues,
    ),
  );
}

class _ToolGlyphPainter extends CustomPainter {
  _ToolGlyphPainter(this.tool, this.color, this.hues);

  final Tool tool;
  final Color color;
  final IconHues hues;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint solid(Color c, [double alpha = 1]) =>
        Paint()..color = c.withValues(alpha: alpha);
    final line = stroke(color);
    // A selection's area, lightly filled as Paint.NET's are.
    final area = solid(hues.blue, 0.22);
    final blue = stroke(hues.blue);
    final shape = solid(hues.violet, 0.45);
    switch (tool) {
      case Tool.rectangleSelect:
        const box = Rect.fromLTRB(4, 5, 20, 19);
        canvas.drawRect(box, area);
        _dashed(canvas, Path()..addRect(box), blue);
      case Tool.moveSelectedPixels:
        canvas.drawRect(const Rect.fromLTRB(9, 9, 15, 15), solid(hues.blue));
        _cross(canvas, blue);
      case Tool.lassoSelect:
        final loop = Path()
          ..moveTo(12, 4)
          ..cubicTo(20, 4, 22, 12, 15, 14)
          ..cubicTo(9, 16, 3, 13, 4, 8)
          ..cubicTo(5, 5, 8, 4, 12, 4);
        canvas.drawPath(loop, area);
        _dashed(canvas, loop, blue);
        canvas.drawPath(
          Path()
            ..moveTo(8, 15)
            ..quadraticBezierTo(6, 19, 9, 21),
          line,
        );
      case Tool.moveSelection:
        _dashed(
          canvas,
          Path()..addRect(const Rect.fromLTRB(8, 8, 16, 16)),
          blue,
        );
        _cross(canvas, blue);
      case Tool.ellipseSelect:
        const oval = Rect.fromLTRB(3, 6, 21, 18);
        canvas.drawOval(oval, area);
        _dashed(canvas, Path()..addOval(oval), blue);
      case Tool.zoom:
        canvas
          ..drawCircle(const Offset(10, 10), 6, area)
          ..drawCircle(const Offset(10, 10), 6, line)
          ..drawLine(const Offset(14.5, 14.5), const Offset(20, 20), line)
          ..drawLine(const Offset(7.5, 10), const Offset(12.5, 10), line)
          ..drawLine(const Offset(10, 7.5), const Offset(10, 12.5), line);
      case Tool.magicWand:
        canvas.drawLine(const Offset(4, 20), const Offset(14, 10), line);
        _star(canvas, const Offset(17, 7), 4, solid(hues.yellow));
      case Tool.pan:
        final palm = Path()
          ..moveTo(7, 13)
          ..lineTo(7, 7)
          ..moveTo(10, 12)
          ..lineTo(10, 5)
          ..moveTo(13, 12)
          ..lineTo(13, 5.5)
          ..moveTo(16, 12.5)
          ..lineTo(16, 7.5)
          ..moveTo(7, 13)
          ..cubicTo(7, 18, 9, 21, 13, 21)
          ..cubicTo(17, 21, 19, 18, 19, 14)
          ..lineTo(19, 11)
          ..moveTo(16, 12.5)
          ..lineTo(19, 11);
        canvas.drawPath(palm, stroke(hues.orange));
      case Tool.paintBucket:
        canvas
          ..save()
          ..translate(11, 12)
          ..rotate(-math.pi / 4)
          // The paint inside, in the bucket's hue.
          ..drawRect(const Rect.fromLTRB(-5, 0, 5, 5), solid(hues.green, 0.7))
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTRB(-5, -5, 5, 5),
              const Radius.circular(1.5),
            ),
            line,
          )
          ..restore()
          ..drawPath(
            Path()
              ..moveTo(19, 14)
              ..quadraticBezierTo(21.5, 17.5, 19, 19)
              ..quadraticBezierTo(16.5, 17.5, 19, 14),
            solid(hues.green),
          );
      case Tool.gradient:
        final box = const Rect.fromLTRB(4, 4, 20, 20);
        canvas
          ..drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(2.5)),
            Paint()
              ..shader = LinearGradient(
                colors: [hues.violet, hues.violet.withValues(alpha: 0)],
              ).createShader(box),
          )
          ..drawRRect(
            RRect.fromRectAndRadius(box, const Radius.circular(2.5)),
            line,
          );
      case Tool.paintbrush:
        canvas
          ..drawLine(const Offset(20, 4), const Offset(11, 13), line)
          ..drawPath(
            Path()
              ..moveTo(10, 12)
              ..cubicTo(13, 13, 13, 16, 10.5, 18)
              ..cubicTo(8, 20, 4.5, 20, 4, 20)
              ..cubicTo(4.5, 18, 5, 14, 7, 12.5)
              ..cubicTo(8, 11.8, 9, 11.8, 10, 12),
            solid(hues.orange),
          );
      case Tool.eraser:
        canvas
          ..save()
          ..translate(12, 12)
          ..rotate(-math.pi / 4)
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTRB(-8, -4, 8, 4),
              const Radius.circular(1.5),
            ),
            line,
          )
          ..drawRect(const Rect.fromLTRB(-8, -4, -2, 4), solid(hues.red))
          ..restore()
          ..drawLine(const Offset(9, 20), const Offset(20, 20), line);
      case Tool.pencil:
        final body = Path()
          ..moveTo(5, 19)
          ..lineTo(6, 15)
          ..lineTo(16, 5)
          ..lineTo(19, 8)
          ..lineTo(9, 18)
          ..close();
        canvas
          ..drawPath(body, solid(hues.yellow, 0.85))
          ..drawPath(body, line)
          ..drawLine(const Offset(14, 7), const Offset(17, 10), line)
          ..drawCircle(const Offset(5.5, 18.5), 1.2, solid(color));
      case Tool.colorPicker:
        canvas
          ..drawLine(const Offset(5, 19), const Offset(13, 11), line)
          ..drawLine(const Offset(11, 9), const Offset(15, 13), line)
          ..drawCircle(const Offset(17, 7), 3, solid(hues.cyan))
          ..drawCircle(const Offset(5, 19), 1.4, solid(hues.cyan));
      case Tool.cloneStamp:
        canvas
          ..drawCircle(const Offset(12, 6), 2.8, solid(hues.orange))
          ..drawCircle(const Offset(12, 6), 2.8, line)
          ..drawLine(const Offset(12, 9), const Offset(12, 13), line)
          ..drawRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTRB(5, 13, 19, 17),
              const Radius.circular(1.5),
            ),
            line,
          )
          ..drawLine(const Offset(5, 20), const Offset(19, 20), line);
      case Tool.recolor:
        canvas
          ..drawArc(
            const Rect.fromLTRB(4, 4, 18, 18),
            -math.pi * 0.9,
            math.pi * 1.5,
            false,
            line,
          )
          ..drawPath(
            Path()
              ..moveTo(4, 7.5)
              ..lineTo(5.2, 10.6)
              ..lineTo(8.3, 9.2),
            line,
          )
          ..drawCircle(const Offset(18, 18), 3, solid(hues.red));
      case Tool.text:
        canvas
          ..drawLine(const Offset(5, 5), const Offset(19, 5), line)
          ..drawLine(const Offset(12, 5), const Offset(12, 20), line)
          ..drawLine(const Offset(9, 20), const Offset(15, 20), line);
      case Tool.lineCurve:
        canvas
          ..drawPath(
            Path()
              ..moveTo(4, 18)
              ..cubicTo(9, 2, 15, 22, 20, 6),
            line,
          )
          ..drawCircle(const Offset(4, 18), 1.8, solid(hues.violet))
          ..drawCircle(const Offset(20, 6), 1.8, solid(hues.violet));
      case Tool.rectangle:
        const box = Rect.fromLTRB(4, 6, 20, 18);
        canvas
          ..drawRect(box, shape)
          ..drawRect(box, line);
      case Tool.roundedRectangle:
        final box = RRect.fromRectAndRadius(
          const Rect.fromLTRB(4, 6, 20, 18),
          const Radius.circular(4),
        );
        canvas
          ..drawRRect(box, shape)
          ..drawRRect(box, line);
      case Tool.ellipse:
        const oval = Rect.fromLTRB(3, 6, 21, 18);
        canvas
          ..drawOval(oval, shape)
          ..drawOval(oval, line);
      case Tool.freeformShape:
        final blob = Path()
          ..moveTo(6, 8)
          ..cubicTo(9, 2, 18, 4, 19, 9)
          ..cubicTo(20, 14, 15, 13, 16, 18)
          ..cubicTo(17, 22, 7, 21, 5, 16)
          ..cubicTo(3, 12, 4, 11, 6, 8)
          ..close();
        canvas
          ..drawPath(blob, shape)
          ..drawPath(blob, line);
    }
  }

  /// Four arrows from the centre: the move tools.
  static void _cross(Canvas canvas, Paint line) {
    const c = Offset(12, 12);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final tip = c + dir * 9;
      final side = Offset(-dir.dy, dir.dx);
      canvas
        ..drawLine(c + dir * 4, tip, line)
        ..drawLine(tip, tip - dir * 2.5 + side * 2.5, line)
        ..drawLine(tip, tip - dir * 2.5 - side * 2.5, line);
    }
  }

  static void _dashed(Canvas canvas, Path path, Paint line) {
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 2.6, metric.length)),
          line,
        );
        d += 4.4;
      }
    }
  }

  static void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final star = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final radius = i.isEven ? r : r * 0.38;
      final p = c + Offset(math.cos(a), math.sin(a)) * radius;
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(star..close(), paint);
  }

  @override
  bool shouldRepaint(_ToolGlyphPainter old) =>
      old.tool != tool || old.color != color || old.hues != hues;
}
