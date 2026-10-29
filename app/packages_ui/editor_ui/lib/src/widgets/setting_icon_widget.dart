import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/widgets/setting_glyph.dart';
import 'package:flutter/material.dart';

/// One [SettingGlyph], as large as the icons around it. The part a setting
/// changes is in the accent when [selected] and muted otherwise, so the
/// chosen one of a row stands out; [mirrored] draws a line's start cap.
class SettingIconWidget extends StatelessWidget {
  const SettingIconWidget(
    this.glyph, {
    super.key,
    this.selected = false,
    this.mirrored = false,
  });

  final SettingGlyph glyph;
  final bool selected;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final icons = IconTheme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = icons.color ?? scheme.onSurface;
    return CustomPaint(
      size: Size.square(icons.size ?? ControlSize.icon),
      painter: _SettingGlyphPainter(
        glyph: glyph,
        mirrored: mirrored,
        color: color,
        tint: selected ? scheme.primary : color.withValues(alpha: 0.5),
        neutral: scheme.onSurface,
        checker: context.tokens.muted,
      ),
    );
  }
}

class _SettingGlyphPainter extends CustomPainter {
  _SettingGlyphPainter({
    required this.glyph,
    required this.mirrored,
    required this.color,
    required this.tint,
    required this.neutral,
    required this.checker,
  });

  final SettingGlyph glyph;
  final bool mirrored;

  /// Outlines, in the icon colour.
  final Color color;

  /// What the setting changes.
  final Color tint;

  /// A colour that stays put whatever the button's state: a gradient's
  /// other end.
  final Color neutral;
  final Color checker;

  static const _a = Rect.fromLTRB(3, 3, 15, 15);
  static const _b = Rect.fromLTRB(9, 9, 21, 21);
  static const _box = Rect.fromLTRB(3, 4, 21, 20);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    if (mirrored) {
      canvas
        ..translate(24, 0)
        ..scale(-1, 1);
    }
    Paint stroke(Color c, [double width = 1.6]) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = stroke(color);
    final fill = Paint()..color = tint;
    switch (glyph) {
      case SettingGlyph.combineReplace:
        canvas
          ..drawRect(_b, fill)
          ..drawRect(_a, stroke(color.withValues(alpha: 0.45)))
          ..drawRect(_b, line);
      case SettingGlyph.combineUnion ||
          SettingGlyph.combineExclude ||
          SettingGlyph.combineXor ||
          SettingGlyph.combineIntersect:
        final a = Path()..addRect(_a);
        final b = Path()..addRect(_b);
        final op = switch (glyph) {
          SettingGlyph.combineUnion => PathOperation.union,
          SettingGlyph.combineExclude => PathOperation.difference,
          SettingGlyph.combineXor => PathOperation.xor,
          _ => PathOperation.intersect,
        };
        canvas
          ..drawPath(Path.combine(op, a, b), fill)
          ..drawRect(_a, line)
          ..drawRect(_b, line);
      case SettingGlyph.floodLocal || SettingGlyph.floodGlobal:
        // Two areas of one colour apart: local fills the one clicked.
        final left = RRect.fromRectXY(const Rect.fromLTRB(3, 5, 11, 19), 2, 2);
        final right = RRect.fromRectXY(
          const Rect.fromLTRB(14, 5, 21, 19),
          2,
          2,
        );
        canvas
          ..drawRRect(left, fill)
          ..drawRRect(left, line);
        if (glyph == SettingGlyph.floodGlobal) {
          canvas.drawRRect(right, fill);
        }
        canvas.drawRRect(right, line);
      // As Paint.NET draws shapes: the outline in one colour, the
      // interior in the other.
      case SettingGlyph.shapeOutline:
        canvas.drawRect(_box, stroke(tint, 2.6));
      case SettingGlyph.shapeInterior:
        canvas.drawRect(_box, Paint()..color = color.withValues(alpha: 0.4));
      case SettingGlyph.shapeBoth:
        canvas
          ..drawRect(_box, Paint()..color = color.withValues(alpha: 0.4))
          ..drawRect(_box, stroke(tint, 2.6));
      case SettingGlyph.antialiasOn:
        canvas.drawPath(
          Path()
            ..moveTo(4, 19)
            ..quadraticBezierTo(8, 6, 20, 5),
          stroke(color, 2.4),
        );
      case SettingGlyph.antialiasOff:
        // The same curve as whole pixels.
        for (final (x, y) in const [
          (4, 17),
          (6, 14),
          (8, 11),
          (10, 9),
          (12, 7),
          (15, 6),
          (18, 5),
        ]) {
          canvas.drawRect(
            Rect.fromLTWH(x.toDouble(), y.toDouble(), 2.6, 2.6),
            Paint()..color = color,
          );
        }
      case SettingGlyph.blendingOn:
        canvas
          ..drawCircle(const Offset(9, 10), 6, Paint()..color = color)
          ..drawRect(
            const Rect.fromLTRB(10, 10, 21, 21),
            Paint()..color = tint.withValues(alpha: 0.6),
          );
      case SettingGlyph.blendingOff:
        canvas
          ..drawCircle(const Offset(9, 10), 6, Paint()..color = color)
          ..drawRect(const Rect.fromLTRB(10, 10, 21, 21), fill);
      case SettingGlyph.gradientLinear ||
          SettingGlyph.gradientReflected ||
          SettingGlyph.gradientRadial ||
          SettingGlyph.gradientConical:
        final clear = tint.withValues(alpha: 0);
        final gradient = switch (glyph) {
          SettingGlyph.gradientLinear => LinearGradient(colors: [tint, clear]),
          SettingGlyph.gradientReflected => LinearGradient(
            colors: [clear, tint, clear],
          ),
          SettingGlyph.gradientRadial => RadialGradient(colors: [tint, clear]),
          _ => SweepGradient(colors: [tint, clear]),
        };
        canvas.drawRect(_box, Paint()..shader = gradient.createShader(_box));
        if (glyph == SettingGlyph.gradientConical) {
          // The seam where the sweep starts again.
          canvas.drawLine(const Offset(12, 12), const Offset(21, 12), line);
        }
        canvas.drawRect(_box, line);
      case SettingGlyph.gradientDiamond:
        canvas
          ..save()
          ..clipRect(_box);
        for (var i = 0; i < 3; i++) {
          final r = 10.0 - i * 3.5;
          canvas.drawPath(
            Path()
              ..moveTo(12, 12 - r)
              ..lineTo(12 + r, 12)
              ..lineTo(12, 12 + r)
              ..lineTo(12 - r, 12)
              ..close(),
            i == 2 ? fill : stroke(tint, 1.2),
          );
        }
        canvas
          ..restore()
          ..drawRect(_box, line);
      case SettingGlyph.gradientColor:
        canvas
          ..drawRect(
            _box,
            Paint()
              ..shader = LinearGradient(colors: [neutral, tint])
                  .createShader(_box),
          )
          ..drawRect(_box, line);
      case SettingGlyph.gradientTransparency:
        // A checkerboard showing through as the colour fades out.
        const cell = 3.0;
        final dark = Paint()..color = checker;
        for (var y = 0; y * cell < _box.height; y++) {
          for (var x = y % 2; x * cell < _box.width; x += 2) {
            canvas.drawRect(
              Rect.fromLTWH(
                _box.left + x * cell,
                _box.top + y * cell,
                cell,
                cell,
              ).intersect(_box),
              dark,
            );
          }
        }
        canvas
          ..drawRect(
            _box,
            Paint()
              ..shader = LinearGradient(
                colors: [tint, tint.withValues(alpha: 0)],
              ).createShader(_box),
          )
          ..drawRect(_box, line);
      // A cap: the line comes in thin from the far side and ends thick in
      // the cap at the near one, unlike the dash pictures' even bar.
      case SettingGlyph.capFlat ||
          SettingGlyph.capArrow ||
          SettingGlyph.capArrowFilled ||
          SettingGlyph.capRounded:
        canvas.drawLine(
          const Offset(2, 12),
          const Offset(9, 12),
          stroke(color.withValues(alpha: 0.5), 1.2),
        );
        switch (glyph) {
          case SettingGlyph.capFlat:
            canvas.drawRect(
              const Rect.fromLTRB(9, 9, 21, 15),
              Paint()..color = color,
            );
          case SettingGlyph.capRounded:
            canvas.drawRRect(
              RRect.fromRectXY(const Rect.fromLTRB(9, 9, 21, 15), 3, 3),
              Paint()..color = color,
            );
          case SettingGlyph.capArrow:
            canvas
              ..drawLine(const Offset(9, 12), const Offset(20, 12), line)
              ..drawPath(
                Path()
                  ..moveTo(14, 6)
                  ..lineTo(20, 12)
                  ..lineTo(14, 18),
                line,
              );
          default:
            canvas
              ..drawLine(const Offset(9, 12), const Offset(14, 12), line)
              ..drawPath(
                Path()
                  ..moveTo(13, 6)
                  ..lineTo(21, 12)
                  ..lineTo(13, 18)
                  ..close(),
                Paint()..color = color,
              );
        }
      case SettingGlyph.dashSolid ||
          SettingGlyph.dashDash ||
          SettingGlyph.dashDashDot ||
          SettingGlyph.dashDashDotDot ||
          SettingGlyph.dashDot:
        // Dash and gap lengths in line widths, as GDI+ has them.
        final pattern = switch (glyph) {
          SettingGlyph.dashSolid => const [18.0],
          SettingGlyph.dashDash => const [5.0, 2.0],
          SettingGlyph.dashDashDot => const [5.0, 2.0, 1.0, 2.0],
          SettingGlyph.dashDashDotDot => const [4.0, 1.5, 1.0, 1.5, 1.0, 1.5],
          _ => const [1.0, 2.0],
        };
        final dash = Paint()..color = color;
        var x = 3.0;
        var i = 0;
        while (x < 21) {
          final length = pattern[i % pattern.length];
          if (i.isEven) {
            canvas.drawRect(
              Rect.fromLTRB(x, 10.5, (x + length).clamp(0, 21), 13.5),
              dash,
            );
          }
          x += length;
          i++;
        }
    }
  }

  @override
  bool shouldRepaint(_SettingGlyphPainter old) =>
      old.glyph != glyph ||
      old.mirrored != mirrored ||
      old.color != color ||
      old.tint != tint ||
      old.neutral != neutral ||
      old.checker != checker;
}
