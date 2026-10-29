import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:equatable/equatable.dart';

/// How an image sits in the canvas area: the zoom (1 is one physical
/// pixel of the screen per pixel of the image, at any display scale) and
/// the image point at the area's centre. Screen positions are logical
/// pixels of the canvas area.
final class CanvasView extends Equatable {
  const CanvasView({
    required this.zoom,
    required this.center,
    this.viewport = const Size(1, 1),
    this.pixelRatio = 1,
  });

  /// Centred, at 100%.
  factory CanvasView.centered(int width, int height) =>
      CanvasView(zoom: 1, center: Offset(width / 2, height / 2));

  /// Zoom In and Zoom Out go through these, in percent.
  static const List<double> steps = [
    1, 2, 3, 4, 5, 6, 8, 12, 16, 25, 33, 50, 66, 100, 200, 300, 400, //
    500, 600, 700, 800, 1200, 1600, 2400, 3200,
  ];

  static const double minZoom = 0.01;
  static const double maxZoom = 32;

  /// One notch of Ctrl+wheel.
  static const double wheelFactor = 1.12;

  /// One notch of the wheel scrolls this many logical pixels.
  static const double wheelStep = 120;

  final double zoom;
  final Offset center;
  final Size viewport;
  final double pixelRatio;

  /// Logical pixels per image pixel.
  double get scale => zoom / pixelRatio;

  double get percent => zoom * 100;

  Offset get _origin {
    final x = viewport.width / 2 - center.dx * scale;
    final y = viewport.height / 2 - center.dy * scale;
    // The image starts on a physical pixel, so 100% is pixel for pixel.
    double snap(double v) => (v * pixelRatio).roundToDouble() / pixelRatio;
    return Offset(snap(x), snap(y));
  }

  Offset toScreen(Offset image) => _origin + image * scale;

  Offset toImage(Offset screen) => (screen - _origin) / scale;

  Rect imageRect(int width, int height) => Rect.fromPoints(
    toScreen(Offset.zero),
    toScreen(Offset(width.toDouble(), height.toDouble())),
  );

  CanvasView withViewport(Size viewport, double pixelRatio) => CanvasView(
    zoom: zoom,
    center: center,
    viewport: viewport,
    pixelRatio: pixelRatio,
  );

  /// [zoom] with the image point under [anchor] staying under it.
  CanvasView zoomAbout(double zoom, Offset anchor) {
    final z = zoom.clamp(minZoom, maxZoom);
    final fixed = toImage(anchor);
    final s = z / pixelRatio;
    final c = Offset(viewport.width / 2, viewport.height / 2);
    return CanvasView(
      zoom: z,
      center: fixed - (anchor - c) / s,
      viewport: viewport,
      pixelRatio: pixelRatio,
    );
  }

  /// The next step above the zoom.
  double get stepIn =>
      steps.firstWhere((s) => s > percent + 0.01, orElse: () => steps.last) /
      100;

  double get stepOut =>
      steps.lastWhere((s) => s < percent - 0.01, orElse: () => steps.first) /
      100;

  Offset get viewportCenter => Offset(viewport.width / 2, viewport.height / 2);

  /// The whole image in the area with a margin (Zoom to Window).
  CanvasView fit(int width, int height, {double margin = 24}) {
    final w = math.max(1, viewport.width - margin * 2);
    final h = math.max(1, viewport.height - margin * 2);
    final z = math
        .min(w * pixelRatio / width, h * pixelRatio / height)
        .clamp(minZoom, maxZoom);
    return CanvasView(
      zoom: z,
      center: Offset(width / 2, height / 2),
      viewport: viewport,
      pixelRatio: pixelRatio,
    );
  }

  /// The rectangle between two image points filling the area (the Zoom
  /// tool's box, Zoom to Selection).
  CanvasView zoomTo(Offset a, Offset b) {
    final w = math.max(1, (b.dx - a.dx).abs());
    final h = math.max(1, (b.dy - a.dy).abs());
    final z = math
        .min(viewport.width * pixelRatio / w, viewport.height * pixelRatio / h)
        .clamp(minZoom, maxZoom);
    return CanvasView(
      zoom: z,
      center: Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2),
      viewport: viewport,
      pixelRatio: pixelRatio,
    );
  }

  /// The view moved by [delta] logical pixels of the screen (a drag, the
  /// wheel).
  CanvasView scrollBy(Offset delta) => CanvasView(
    zoom: zoom,
    center: center - delta / scale,
    viewport: viewport,
    pixelRatio: pixelRatio,
  );

  /// Keeps the image in the area: a smaller image stays centred, a larger
  /// one cannot leave a gap past its edge.
  CanvasView clamped(int width, int height) {
    final halfW = viewport.width / 2 / scale;
    final halfH = viewport.height / 2 / scale;
    double axis(double c, double half, int size) =>
        size <= half * 2 ? size / 2 : c.clamp(half, size - half);
    return CanvasView(
      zoom: zoom,
      center: Offset(
        axis(center.dx, halfW, width),
        axis(center.dy, halfH, height),
      ),
      viewport: viewport,
      pixelRatio: pixelRatio,
    );
  }

  @override
  List<Object?> get props => [zoom, center, viewport, pixelRatio];
}
