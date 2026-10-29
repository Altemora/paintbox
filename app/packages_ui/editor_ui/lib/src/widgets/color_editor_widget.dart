import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint_logic/paint_logic.dart';

/// Between the core's colour and Flutter's.
extension Rgba8Color on Rgba8 {
  Color get color => Color.fromARGB(a, r, g, b);

  String get hex => [
    r,
    g,
    b,
    a,
  ].map((c) => c.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
}

extension ColorRgba8 on Color {
  Rgba8 get rgba8 => Rgba8(
    r: (r * 255).round(),
    g: (g * 255).round(),
    b: (b * 255).round(),
    a: (a * 255).round(),
  );
}

/// The Colors window's editor of one colour. Compact, as Paint.NET's Less:
/// the hue and saturation wheel, the opacity under it and the hex code,
/// no wider than the wheel. Expanded: RGB, hex, HSV and opacity beside it. Everything shown is given; every change goes out.
class ColorEditorWidget extends StatelessWidget {
  const ColorEditorWidget({
    required this.color,
    required this.onChanged,
    required this.expanded,
    required this.labels,
    this.leading,
    this.showOpacity = true,
    super.key,
  });

  final Rgba8 color;
  final ValueChanged<Rgba8> onChanged;
  final bool expanded;
  final ColorEditorLabels labels;

  /// Above the wheel: the two colours and their buttons.
  final Widget? leading;

  /// False where the colour is always opaque (the accent): the compact
  /// editor then has no opacity slider.
  final bool showOpacity;

  /// The compact editor's width: everything under the wheel fits it.
  static const double wheelSize = _WheelWidget.size;

  @override
  Widget build(BuildContext context) {
    final hsv = HSVColor.fromColor(color.color.withAlpha(255));
    void setHsv(HSVColor next) =>
        onChanged(next.toColor().withAlpha(color.a).rgba8);
    Widget slider(
      String label,
      double value,
      double max,
      List<Color> track,
      ValueChanged<double> changed,
    ) => _ChannelSlider(
      label: label,
      value: value,
      max: max,
      track: track,
      onChanged: changed,
    );
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: Space.xxs),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: context.tokens.muted),
      ),
    );
    final wheel = _WheelWidget(
      hsv: hsv,
      onChanged: (h, s) => setHsv(hsv.withHue(h).withSaturation(s)),
    );
    final value = slider(labels.value, hsv.value * 100, 100, [
      Colors.black,
      hsv.withValue(1).toColor(),
    ], (v) => setHsv(hsv.withValue(v / 100)));
    final alphaTrack = [color.color.withAlpha(0), color.color.withAlpha(255)];
    void setAlpha(double v) =>
        onChanged(Rgba8(r: color.r, g: color.g, b: color.b, a: v.round()));
    final alpha = _ChannelSlider(
      label: labels.alpha,
      value: color.a.toDouble(),
      max: 255,
      track: alphaTrack,
      onChanged: setAlpha,
      checker: true,
    );
    final hex = _HexField(
      label: labels.hex,
      hex: color.hex,
      onSubmitted: (text) {
        final parsed = _parseHex(text);
        if (parsed != null) {
          onChanged(parsed);
        }
      },
    );
    if (!expanded) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?leading,
          wheel,
          const SizedBox(height: Space.xxs),
          if (showOpacity)
            _ChannelSlider(
              label: labels.opacity,
              value: color.a.toDouble(),
              max: 255,
              track: alphaTrack,
              onChanged: setAlpha,
              compact: true,
              checker: true,
            ),
          hex,
        ],
      );
    }
    // As Paint.NET lays it out: the wheel on the left, RGB, hex, HSV and
    // the opacity on the right.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [?leading, wheel],
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading('RGB'),
              slider(
                labels.red,
                color.r.toDouble(),
                255,
                [
                  Color.fromARGB(255, 0, color.g, color.b),
                  Color.fromARGB(255, 255, color.g, color.b),
                ],
                (v) => onChanged(
                  Rgba8(r: v.round(), g: color.g, b: color.b, a: color.a),
                ),
              ),
              slider(
                labels.green,
                color.g.toDouble(),
                255,
                [
                  Color.fromARGB(255, color.r, 0, color.b),
                  Color.fromARGB(255, color.r, 255, color.b),
                ],
                (v) => onChanged(
                  Rgba8(r: color.r, g: v.round(), b: color.b, a: color.a),
                ),
              ),
              slider(
                labels.blue,
                color.b.toDouble(),
                255,
                [
                  Color.fromARGB(255, color.r, color.g, 0),
                  Color.fromARGB(255, color.r, color.g, 255),
                ],
                (v) => onChanged(
                  Rgba8(r: color.r, g: color.g, b: v.round(), a: color.a),
                ),
              ),
              hex,
              heading('HSV'),
              slider(labels.hue, hsv.hue, 360, [
                for (var h = 0; h <= 360; h += 60)
                  HSVColor.fromAHSV(1, h.toDouble(), 1, 1).toColor(),
              ], (v) => setHsv(hsv.withHue(v.clamp(0, 359.99)))),
              slider(labels.saturation, hsv.saturation * 100, 100, [
                hsv.withSaturation(0).toColor(),
                hsv.withSaturation(1).toColor(),
              ], (v) => setHsv(hsv.withSaturation(v / 100))),
              value,
              heading(labels.opacity),
              alpha,
            ],
          ),
        ),
      ],
    );
  }

  /// `RRGGBB` or `RRGGBBAA`, with or without `#`.
  static Rgba8? _parseHex(String text) {
    final t = text.trim().replaceFirst('#', '');
    if (t.length != 6 && t.length != 8) {
      return null;
    }
    final v = int.tryParse(t, radix: 16);
    if (v == null) {
      return null;
    }
    final rgba = t.length == 6 ? (v << 8) | 0xFF : v;
    return Rgba8(
      r: (rgba >> 24) & 0xFF,
      g: (rgba >> 16) & 0xFF,
      b: (rgba >> 8) & 0xFF,
      a: rgba & 0xFF,
    );
  }
}

/// The words of the editor's controls, given by the component.
final class ColorEditorLabels {
  const ColorEditorLabels({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
    required this.hex,
    required this.opacity,
  });

  final String hue;
  final String saturation;
  final String value;
  final String red;
  final String green;
  final String blue;
  final String alpha;
  final String hex;
  final String opacity;
}

class _WheelWidget extends StatelessWidget {
  const _WheelWidget({required this.hsv, required this.onChanged});

  static const double size = 116;

  final HSVColor hsv;
  final void Function(double hue, double saturation) onChanged;

  void _pick(Offset at) {
    const c = Offset(size / 2, size / 2);
    final d = at - c;
    final hue = (math.atan2(d.dy, d.dx) * 180 / math.pi + 360) % 360;
    final saturation = (d.distance / (size / 2)).clamp(0.0, 1.0);
    onChanged(hue, saturation);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onPanDown: (d) => _pick(d.localPosition),
    onPanUpdate: (d) => _pick(d.localPosition),
    child: CustomPaint(
      size: const Size.square(size),
      painter: _WheelPainter(hsv),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = SweepGradient(
            colors: [
              for (var h = 0; h <= 360; h += 30)
                HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
            ],
          ).createShader(rect),
      )
      ..drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white, Colors.white.withAlpha(0)],
          ).createShader(rect),
      );
    final a = hsv.hue * math.pi / 180;
    final p = c + Offset(math.cos(a), math.sin(a)) * hsv.saturation * r;
    canvas
      ..drawCircle(
        p,
        5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white,
      )
      ..drawCircle(
        p,
        6.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.black54,
      );
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.hsv != hsv;
}

class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.track,
    required this.onChanged,
    this.compact = false,
    this.checker = false,
  });

  final String label;
  final double value;
  final double max;
  final List<Color> track;
  final ValueChanged<double> onChanged;

  /// The track alone, its name and value in the tooltip: under the
  /// compact wheel there is no room for them.
  final bool compact;

  /// Opacity: the colour fades over a checkerboard, as Paint.NET's does.
  final bool checker;

  /// The theme's thumb radius.
  static const double _thumb = 6;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.labelSmall;
    final row = SizedBox(
      height: 20,
      child: Row(
        children: [
          if (!compact) SizedBox(width: 16, child: Text(label, style: text)),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compact, the track spans the wheel's width and the thumb
                // stops at its ends; otherwise both are inset by the
                // thumb's halo.
                Container(
                  width: double.infinity,
                  height: 6,
                  margin: EdgeInsets.symmetric(
                    horizontal: compact ? 0 : Space.sm,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Radii.pill),
                    // A black-to-clear track would vanish on the dark glass.
                    border: Border.all(color: context.tokens.hairlineStrong),
                  ),
                  child: CustomPaint(
                    painter: _TrackPainter(
                      track,
                      checker: checker
                          ? (
                              context.tokens.checkerLight,
                              context.tokens.checkerDark,
                            )
                          : null,
                    ),
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    thumbColor: Colors.white,
                    padding: compact
                        ? const EdgeInsets.symmetric(horizontal: _thumb)
                        : null,
                  ),
                  child: Slider(
                    value: value.clamp(0, max),
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
          if (!compact)
            SizedBox(
              width: 30,
              child: Text(
                value.round().toString(),
                textAlign: TextAlign.end,
                style: text,
              ),
            ),
        ],
      ),
    );
    return compact
        ? Tooltip(message: '$label: ${value.round()}', child: row)
        : row;
  }
}

class _HexField extends StatefulWidget {
  const _HexField({
    required this.label,
    required this.hex,
    required this.onSubmitted,
  });

  final String label;
  final String hex;
  final ValueChanged<String> onSubmitted;

  @override
  State<_HexField> createState() => _HexFieldState();
}

class _HexFieldState extends State<_HexField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.hex,
  );
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(_HexField old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _controller.text != widget.hex) {
      _controller.text = widget.hex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 16,
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
      Expanded(
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          style: Theme.of(context).textTheme.bodySmall,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[#0-9a-fA-F]')),
            LengthLimitingTextInputFormatter(9),
          ],
          onSubmitted: widget.onSubmitted,
          onTapOutside: (_) {
            widget.onSubmitted(_controller.text);
            _focus.unfocus();
          },
        ),
      ),
    ],
  );
}

/// A slider's track: the gradient, over a checkerboard for opacity.
class _TrackPainter extends CustomPainter {
  _TrackPainter(this.colors, {this.checker});

  final List<Color> colors;
  final (Color, Color)? checker;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final cells = checker;
    if (cells != null) {
      canvas.drawRect(rect, Paint()..color = cells.$1);
      final cell = size.height / 2;
      final dark = Paint()..color = cells.$2;
      for (var x = 0; x * cell < size.width; x++) {
        canvas.drawRect(
          Rect.fromLTWH(x * cell, x.isEven ? 0 : cell, cell, cell),
          dark,
        );
      }
    }
    canvas.drawRect(
      rect,
      Paint()..shader = LinearGradient(colors: colors).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      !listEquals(old.colors, colors) || old.checker != checker;
}
