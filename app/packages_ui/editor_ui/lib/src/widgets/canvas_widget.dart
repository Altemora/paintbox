import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/widgets/canvas_tiles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint_logic/paint_logic.dart';

/// A mouse button over the canvas.
enum CanvasMouse { primary, secondary, middle }

/// Modifiers held at a pointer event.
typedef CanvasMods = ({bool ctrl, bool shift, bool alt});

/// The image in its view: the workspace around it, the checkerboard under
/// transparency, the tiles (pixels stay sharp when enlarged), the pixel
/// grid, the marching ants, the handles of what is live and the Zoom
/// tool's box. Every pointer event goes out through the callbacks in the
/// area's logical pixels.
class CanvasWidget extends StatefulWidget {
  const CanvasWidget({
    required this.tiles,
    required this.view,
    required this.imageWidth,
    required this.imageHeight,
    required this.outline,
    required this.outlineStamp,
    required this.outlineOffset,
    required this.handles,
    required this.guide,
    required this.cursor,
    required this.onViewport,
    required this.onDown,
    required this.onMove,
    required this.onUp,
    required this.onExit,
    required this.onWheel,
    required this.onPanZoom,
    this.zoomBox,
    this.pixelGrid = false,
    super.key,
  });

  final CanvasTiles tiles;
  final CanvasView view;
  final int imageWidth;
  final int imageHeight;
  final Int32List outline;
  final BigInt outlineStamp;
  final Offset outlineOffset;
  final List<PointF> handles;
  final List<PointF> guide;
  final Rect? zoomBox;
  final bool pixelGrid;
  final MouseCursor cursor;
  final void Function(Size size, double pixelRatio) onViewport;
  final void Function(Offset position, CanvasMouse button, CanvasMods mods)
  onDown;
  final void Function(Offset position) onMove;
  final void Function(Offset position, CanvasMouse button, CanvasMods mods)
  onUp;
  final VoidCallback onExit;
  final void Function(Offset position, Offset delta, CanvasMods mods) onWheel;

  /// Two fingers on a touchpad: the pan and the scale since the last call.
  final void Function(Offset position, Offset pan, double scale) onPanZoom;

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ants = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  final _OutlinePath _path = _OutlinePath();
  ui.Image? _checker;
  int _buttons = 0;
  double _scale = 1;
  (Size, double)? _reported;

  @override
  void initState() {
    super.initState();
    _checker = _makeChecker();
    _syncAnts();
  }

  @override
  void didUpdateWidget(CanvasWidget old) {
    super.didUpdateWidget(old);
    _syncAnts();
  }

  void _syncAnts() {
    final animate = widget.outline.isNotEmpty;
    if (animate && !_ants.isAnimating) {
      _ants.repeat();
    } else if (!animate && _ants.isAnimating) {
      _ants.stop();
    }
  }

  /// Two squares of the checkerboard, 8 logical pixels each, fixed to the
  /// screen as Paint.NET's is.
  static ui.Image _makeChecker() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final light = Paint()..color = const Color(0xFFFFFFFF);
    final dark = Paint()..color = const Color(0xFFCCCCCC);
    canvas
      ..drawRect(const Rect.fromLTWH(0, 0, 16, 16), light)
      ..drawRect(const Rect.fromLTWH(8, 0, 8, 8), dark)
      ..drawRect(const Rect.fromLTWH(0, 8, 8, 8), dark);
    return recorder.endRecording().toImageSync(16, 16);
  }

  @override
  void dispose() {
    _ants.dispose();
    _checker?.dispose();
    super.dispose();
  }

  static CanvasMods _mods() {
    final keys = HardwareKeyboard.instance;
    return (
      ctrl: keys.isControlPressed || keys.isMetaPressed,
      shift: keys.isShiftPressed,
      alt: keys.isAltPressed,
    );
  }

  static const _masks = [
    (kPrimaryMouseButton, CanvasMouse.primary),
    (kSecondaryMouseButton, CanvasMouse.secondary),
    (kMiddleMouseButton, CanvasMouse.middle),
  ];

  /// Buttons pressed or let go since the last event: a second button
  /// pressed mid-drag arrives as a move with another mask.
  void _buttonsChanged(Offset at, int buttons) {
    final mods = _mods();
    for (final (mask, button) in _masks) {
      final was = _buttons & mask != 0;
      final now = buttons & mask != 0;
      if (now && !was) {
        widget.onDown(at, button, mods);
      } else if (was && !now) {
        widget.onUp(at, button, mods);
      }
    }
    _buttons = buttons;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final ratio = MediaQuery.devicePixelRatioOf(context);
        if (_reported != (size, ratio)) {
          // Moving to a monitor of another scale changes 100%.
          _reported = (size, ratio);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onViewport(size, ratio),
          );
        }
        return MouseRegion(
          cursor: widget.cursor,
          onExit: (_) => widget.onExit(),
          child: Listener(
            onPointerDown: (e) => _buttonsChanged(e.localPosition, e.buttons),
            onPointerMove: (e) {
              if (e.buttons != _buttons) {
                _buttonsChanged(e.localPosition, e.buttons);
              }
              widget.onMove(e.localPosition);
            },
            onPointerHover: (e) => widget.onMove(e.localPosition),
            onPointerUp: (e) => _buttonsChanged(e.localPosition, e.buttons),
            onPointerCancel: (e) => _buttonsChanged(e.localPosition, 0),
            onPointerPanZoomStart: (_) => _scale = 1,
            onPointerPanZoomUpdate: (e) {
              widget.onPanZoom(
                e.localPosition,
                e.localPanDelta,
                e.scale / _scale,
              );
              _scale = e.scale;
            },
            onPointerSignal: (signal) {
              if (signal is PointerScrollEvent) {
                widget.onWheel(
                  signal.localPosition,
                  signal.scrollDelta,
                  _mods(),
                );
              }
            },
            child: Stack(
              children: [
                for (final overlay in const [false, true])
                  RepaintBoundary(
                    child: CustomPaint(
                      size: size,
                      isComplex: !overlay,
                      painter: _CanvasPainter(
                        overlay: overlay,
                        outlineCache: _path,
                        tiles: widget.tiles,
                        ants: _ants,
                        checker: _checker!,
                        view: widget.view,
                        width: widget.imageWidth,
                        height: widget.imageHeight,
                        path: _path.of(widget.outlineStamp, widget.outline),
                        outlined: widget.outline.isNotEmpty,
                        outlineOffset: widget.outlineOffset,
                        handles: widget.handles,
                        guide: widget.guide,
                        zoomBox: widget.zoomBox,
                        pixelGrid: widget.pixelGrid,
                        workspace: tokens.workspace,
                        handle: tokens.handle,
                        hairline: tokens.hairlineStrong,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The ants' path in image pixels, made again only when the selection
/// changes.
class _OutlinePath {
  BigInt? _stamp;
  int _length = -1;
  Path _path = Path();

  CanvasView? _view;
  Offset? _offset;
  Path? _screen;

  /// The path on screen, made again only when the view, the move or the
  /// selection changed: the ants' animation only moves the stripes.
  Path screen(CanvasView view, Offset offset, Path Function() make) {
    if (_screen != null && view == _view && offset == _offset) {
      return _screen!;
    }
    _view = view;
    _offset = offset;
    return _screen = make();
  }

  Path of(BigInt stamp, Int32List segments) {
    if (stamp == _stamp && segments.length == _length) {
      return _path;
    }
    _stamp = stamp;
    _length = segments.length;
    _screen = null;
    final path = Path();
    for (var i = 0; i + 3 < segments.length; i += 4) {
      path
        ..moveTo(segments[i].toDouble(), segments[i + 1].toDouble())
        ..lineTo(segments[i + 2].toDouble(), segments[i + 3].toDouble());
    }
    return _path = path;
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({
    required this.overlay,
    required this.outlineCache,
    required this.tiles,
    required this.ants,
    required this.checker,
    required this.view,
    required this.width,
    required this.height,
    required this.path,
    required this.outlined,
    required this.outlineOffset,
    required this.handles,
    required this.guide,
    required this.zoomBox,
    required this.pixelGrid,
    required this.workspace,
    required this.handle,
    required this.hairline,
  }) : super(repaint: overlay ? ants : tiles);

  /// The ants, handles and boxes, over the image layer: they repaint
  /// with the ants' animation without repainting the tiles.
  final bool overlay;
  final _OutlinePath outlineCache;

  final CanvasTiles tiles;
  final Animation<double> ants;
  final ui.Image checker;
  final CanvasView view;
  final int width;
  final int height;
  final Path path;
  final bool outlined;
  final Offset outlineOffset;
  final List<PointF> handles;
  final List<PointF> guide;
  final Rect? zoomBox;
  final bool pixelGrid;
  final Color workspace;
  final Color handle;
  final Color hairline;

  double _snap(double v) =>
      (v * view.pixelRatio).roundToDouble() / view.pixelRatio;

  Offset _screen(double x, double y) => view.toScreen(Offset(x, y));

  @override
  void paint(Canvas canvas, Size size) {
    if (overlay) {
      _ants(canvas);
      _overlay(canvas);
      return;
    }
    canvas.drawRect(Offset.zero & size, Paint()..color = workspace);
    final image = view.imageRect(width, height);
    final shown = Rect.fromLTRB(
      _snap(image.left),
      _snap(image.top),
      _snap(image.right),
      _snap(image.bottom),
    );
    canvas.drawRect(
      shown,
      Paint()
        ..shader = ImageShader(
          checker,
          TileMode.repeated,
          TileMode.repeated,
          Matrix4.identity().storage,
        ),
    );
    // Enlarged pixels stay square; reduced ones are averaged.
    final paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = view.zoom >= 1
          ? FilterQuality.none
          : FilterQuality.medium;
    canvas
      ..save()
      ..clipRect(shown);
    for (final (rect, tile) in tiles.tiles) {
      final a = _screen(rect.left, rect.top);
      final b = _screen(rect.right, rect.bottom);
      final dst = Rect.fromLTRB(
        _snap(a.dx),
        _snap(a.dy),
        _snap(b.dx),
        _snap(b.dy),
      );
      if (!dst.overlaps(Offset.zero & size)) {
        continue;
      }
      canvas.drawImageRect(
        tile,
        Rect.fromLTWH(0, 0, rect.width, rect.height),
        dst,
        paint,
      );
    }
    canvas.restore();
    if (pixelGrid && view.zoom >= 4) {
      _grid(canvas, size, shown);
    }
  }

  void _grid(Canvas canvas, Size size, Rect shown) {
    final grid = Paint()
      ..color = hairline
      ..strokeWidth = 1 / view.pixelRatio;
    final from = view.toImage(Offset.zero);
    final to = view.toImage(Offset(size.width, size.height));
    final x0 = from.dx.floor().clamp(0, width);
    final x1 = to.dx.ceil().clamp(0, width);
    final y0 = from.dy.floor().clamp(0, height);
    final y1 = to.dy.ceil().clamp(0, height);
    for (var x = x0; x <= x1; x++) {
      final sx = _snap(_screen(x.toDouble(), 0).dx);
      canvas.drawLine(Offset(sx, shown.top), Offset(sx, shown.bottom), grid);
    }
    for (var y = y0; y <= y1; y++) {
      final sy = _snap(_screen(0, y.toDouble()).dy);
      canvas.drawLine(Offset(shown.left, sy), Offset(shown.right, sy), grid);
    }
  }

  void _ants(Canvas canvas) {
    if (!outlined) {
      return;
    }
    final screen = outlineCache.screen(view, outlineOffset, () {
      final origin = view.toScreen(outlineOffset);
      final matrix = Matrix4.identity()
        ..translateByDouble(
          _snap(origin.dx) + 0.5,
          _snap(origin.dy) + 0.5,
          0,
          1,
        )
        ..scaleByDouble(view.scale, view.scale, 1, 1);
      return path.transform(matrix.storage);
    });
    final phase = ants.value * 8;
    final stripes = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = ui.Gradient.linear(
        Offset(phase, 0),
        Offset(phase + 4, 4),
        const [
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
        const [0, 0.5, 0.5, 1],
        TileMode.repeated,
      );
    canvas.drawPath(screen, stripes);
  }

  void _overlay(Canvas canvas) {
    if (guide.length >= 2) {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = handle.withValues(alpha: 0.8);
      final p = Path()
        ..moveTo(
          _screen(guide[0].x, guide[0].y).dx,
          _screen(guide[0].x, guide[0].y).dy,
        );
      for (final g in guide.skip(1)) {
        final s = _screen(g.x, g.y);
        p.lineTo(s.dx, s.dy);
      }
      canvas.drawPath(p, line);
    }
    for (final h in handles) {
      final s = _screen(h.x, h.y);
      canvas
        ..drawCircle(s, 5, Paint()..color = const Color(0xFFFFFFFF))
        ..drawCircle(s, 3.5, Paint()..color = handle);
    }
    final box = zoomBox;
    if (box != null) {
      final r = Rect.fromPoints(
        _screen(box.left, box.top),
        _screen(box.right, box.bottom),
      );
      canvas
        ..drawRect(r, Paint()..color = handle.withValues(alpha: 0.12))
        ..drawRect(
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = handle,
        );
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.view != view ||
      old.width != width ||
      old.height != height ||
      !identical(old.path, path) ||
      old.outlineOffset != outlineOffset ||
      old.handles != handles ||
      old.guide != guide ||
      old.zoomBox != zoomBox ||
      old.pixelGrid != pixelGrid ||
      old.workspace != workspace;
}
