import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:paint_logic/paint_logic.dart';

/// The Curves dialog's editor: Luminosity or RGB (with the channel being
/// edited), the curve the core draws through the control points. A drag
/// moves a point, a drag on empty space adds one, a right click removes
/// one (the two ends stay).
class CurvesEditorWidget extends StatefulWidget {
  const CurvesEditorWidget({
    required this.curves,
    required this.onChanged,
    required this.luminosityLabel,
    super.key,
  });

  final PaintCurves curves;
  final ValueChanged<PaintCurves> onChanged;
  final String luminosityLabel;

  @override
  State<CurvesEditorWidget> createState() => _CurvesEditorWidgetState();
}

enum _Channel { red, green, blue }

class _CurvesEditorWidgetState extends State<CurvesEditorWidget> {
  static const double _size = 220;
  static const double _reach = 8;

  _Channel _channel = _Channel.red;
  int? _dragging;

  List<(int, int)> get _points => switch ((widget.curves.mode, _channel)) {
    (CurveMode.luminosity, _) => widget.curves.luminosity,
    (CurveMode.rgb, _Channel.red) => widget.curves.red,
    (CurveMode.rgb, _Channel.green) => widget.curves.green,
    (CurveMode.rgb, _Channel.blue) => widget.curves.blue,
  };

  void _emit(List<(int, int)> points, {CurveMode? mode}) {
    final c = widget.curves;
    final lum = c.mode == CurveMode.luminosity;
    widget.onChanged(
      PaintCurves(
        mode: mode ?? c.mode,
        luminosity: lum && mode == null ? points : c.luminosity,
        red: !lum && _channel == _Channel.red && mode == null ? points : c.red,
        green: !lum && _channel == _Channel.green && mode == null
            ? points
            : c.green,
        blue: !lum && _channel == _Channel.blue && mode == null
            ? points
            : c.blue,
      ),
    );
  }

  static (int, int) _value(Offset at) => (
    (at.dx / _size * 255).round().clamp(0, 255),
    (255 - at.dy / _size * 255).round().clamp(0, 255),
  );

  static Offset _screen((int, int) p) =>
      Offset(p.$1 / 255 * _size, (255 - p.$2) / 255 * _size);

  int? _near(Offset at) {
    final points = _points;
    for (var i = 0; i < points.length; i++) {
      if ((_screen(points[i]) - at).distance <= _reach) {
        return i;
      }
    }
    return null;
  }

  void _start(Offset at) {
    final hit = _near(at);
    if (hit != null) {
      _dragging = hit;
      return;
    }
    final v = _value(at);
    final points = [..._points];
    if (points.any((p) => p.$1 == v.$1)) {
      return;
    }
    final index = points.indexWhere((p) => p.$1 > v.$1);
    final at0 = index < 0 ? points.length : index;
    points.insert(at0, v);
    _dragging = at0;
    _emit(points);
  }

  void _move(Offset at) {
    final i = _dragging;
    if (i == null) {
      return;
    }
    final points = [..._points];
    var (x, y) = _value(at);
    // The ends keep their place on the input axis; the others stay
    // between their neighbours.
    if (i == 0 || i == points.length - 1) {
      x = points[i].$1;
    } else {
      x = x.clamp(points[i - 1].$1 + 1, points[i + 1].$1 - 1);
    }
    points[i] = (x, y);
    _emit(points);
  }

  void _remove(Offset at) {
    final hit = _near(at);
    final points = [..._points];
    if (hit == null || hit == 0 || hit == points.length - 1) {
      return;
    }
    points.removeAt(hit);
    _emit(points);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final rgb = widget.curves.mode == CurveMode.rgb;
    final colors = {
      _Channel.red: const Color(0xFFE5484D),
      _Channel.green: const Color(0xFF46A758),
      _Channel.blue: const Color(0xFF3E83F7),
    };
    final shown = <(List<(int, int)>, Color, bool)>[
      if (!rgb)
        (
          widget.curves.luminosity,
          Theme.of(context).colorScheme.onSurface,
          true,
        )
      else ...[
        (widget.curves.red, colors[_Channel.red]!, _channel == _Channel.red),
        (
          widget.curves.green,
          colors[_Channel.green]!,
          _channel == _Channel.green,
        ),
        (widget.curves.blue, colors[_Channel.blue]!, _channel == _Channel.blue),
      ],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<CurveMode>(
          segments: [
            ButtonSegment(
              value: CurveMode.luminosity,
              label: Text(widget.luminosityLabel),
            ),
            const ButtonSegment(value: CurveMode.rgb, label: Text('RGB')),
          ],
          selected: {widget.curves.mode},
          onSelectionChanged: (s) => _emit(_points, mode: s.first),
        ),
        AnimatedSize(
          duration: Motion.normal,
          child: rgb
              ? Padding(
                  padding: const EdgeInsets.only(top: Space.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (final c in _Channel.values)
                        GlassTap(
                          selected: c == _channel,
                          radius: Radii.pill,
                          onTap: () => setState(() => _channel = c),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.sm,
                            vertical: Space.xxs,
                          ),
                          child: GlowDot(color: colors[c]!, glow: false),
                        ),
                    ],
                  ),
                )
              : const SizedBox(width: _size),
        ),
        const SizedBox(height: Space.xs),
        GestureDetector(
          onPanStart: (d) => _start(d.localPosition),
          onPanUpdate: (d) => _move(d.localPosition),
          onPanEnd: (_) => _dragging = null,
          onSecondaryTapUp: (d) => _remove(d.localPosition),
          child: CustomPaint(
            size: const Size.square(_size),
            painter: _CurvesPainter(
              curves: [
                for (final (points, color, active) in shown)
                  (curveTable(points: points), points, color, active),
              ],
              grid: tokens.hairlineStrong,
              background: tokens.glass,
            ),
          ),
        ),
      ],
    );
  }
}

class _CurvesPainter extends CustomPainter {
  _CurvesPainter({
    required this.curves,
    required this.grid,
    required this.background,
  });

  final List<(List<int>, List<(int, int)>, Color, bool)> curves;
  final Color grid;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = grid
      ..strokeWidth = 1;
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    for (var i = 1; i < 4; i++) {
      final t = size.width * i / 4;
      canvas
        ..drawLine(Offset(t, 0), Offset(t, size.height), line)
        ..drawLine(Offset(0, t), Offset(size.width, t), line);
    }
    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), line);
    for (final (table, points, color, active) in curves) {
      final path = Path();
      for (var x = 0; x < table.length; x++) {
        final p = Offset(
          x / 255 * size.width,
          (255 - table[x]) / 255 * size.height,
        );
        x == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = active ? 2 : 1
          ..color = active ? color : color.withValues(alpha: 0.45),
      );
      if (!active) {
        continue;
      }
      for (final (x, y) in points) {
        final p = Offset(x / 255 * size.width, (255 - y) / 255 * size.height);
        canvas
          ..drawCircle(p, 5, Paint()..color = Colors.white)
          ..drawCircle(p, 3.5, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_CurvesPainter old) => true;
}
