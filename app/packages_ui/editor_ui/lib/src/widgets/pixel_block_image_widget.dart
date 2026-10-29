import 'dart:ui' as ui;

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:paint_logic/paint_logic.dart';

/// A thumbnail from the core's premultiplied pixels, over a small
/// checkerboard, fitted into [size].
class PixelBlockImageWidget extends StatefulWidget {
  const PixelBlockImageWidget({
    required this.block,
    required this.size,
    super.key,
  });

  final PixelBlock? block;
  final Size size;

  @override
  State<PixelBlockImageWidget> createState() => _PixelBlockImageWidgetState();
}

class _PixelBlockImageWidgetState extends State<PixelBlockImageWidget> {
  ui.Image? _image;
  PixelBlock? _decoding;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(PixelBlockImageWidget old) {
    super.didUpdateWidget(old);
    if (!identical(old.block, widget.block)) {
      _decode();
    }
  }

  void _decode() {
    final block = widget.block;
    _decoding = block;
    if (block == null) {
      return;
    }
    ui.decodeImageFromPixels(
      block.pixels,
      block.width,
      block.height,
      ui.PixelFormat.rgba8888,
      (image) {
        if (!mounted || !identical(_decoding, block)) {
          image.dispose();
          return;
        }
        setState(() {
          _image?.dispose();
          _image = image;
        });
      },
    );
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
    size: widget.size,
    child: CustomPaint(
      painter: _ThumbPainter(_image, context.tokens.hairlineStrong),
    ),
  );
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.image, this.border);

  final ui.Image? image;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final image = this.image;
    if (image == null) {
      return;
    }
    final scale = (size.width / image.width).clamp(
      0.0,
      size.height / image.height,
    );
    final w = image.width * scale;
    final h = image.height * scale;
    final dst = Rect.fromLTWH(
      (size.width - w) / 2,
      (size.height - h) / 2,
      w,
      h,
    );
    canvas
      ..save()
      ..clipRect(dst);
    const cell = 4.0;
    final dark = Paint()..color = const Color(0xFFCCCCCC);
    canvas.drawRect(dst, Paint()..color = const Color(0xFFFFFFFF));
    for (var y = 0; y * cell < h; y++) {
      for (var x = y % 2; x * cell < w; x += 2) {
        canvas.drawRect(
          Rect.fromLTWH(dst.left + x * cell, dst.top + y * cell, cell, cell),
          dark,
        );
      }
    }
    canvas
      ..drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dst,
        Paint()..filterQuality = FilterQuality.medium,
      )
      ..restore()
      ..drawRect(
        dst,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = border,
      );
  }

  @override
  bool shouldRepaint(_ThumbPainter old) => old.image != image;
}
