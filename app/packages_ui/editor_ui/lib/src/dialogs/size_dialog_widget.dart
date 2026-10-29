import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paint_logic/paint_logic.dart';

/// What a size dialog answers.
final class SizeAnswer {
  const SizeAnswer(this.width, this.height, {this.resampling, this.anchor});

  final int width;
  final int height;
  final Resampling? resampling;
  final Anchor? anchor;
}

enum SizeDialogKind { newImage, resize, canvasSize }

/// File > New, Image > Resize and Image > Canvas Size: width and height
/// in pixels; Resize keeps the aspect ratio when asked and picks the
/// resampling, Canvas Size the anchor. A size past the core's budget is
/// told under the fields before OK.
class SizeDialogWidget extends StatefulWidget {
  const SizeDialogWidget({
    required this.kind,
    required this.width,
    required this.height,
    this.resampling = Resampling.bilinear,
    super.key,
  });

  /// The core's limit of one surface, 2^27 pixels.
  static const maxPixels = 1 << 27;

  final SizeDialogKind kind;
  final int width;
  final int height;
  final Resampling resampling;

  @override
  State<SizeDialogWidget> createState() => _SizeDialogWidgetState();
}

class _SizeDialogWidgetState extends State<SizeDialogWidget> {
  late final TextEditingController _w = TextEditingController(
    text: '${widget.width}',
  );
  late final TextEditingController _h = TextEditingController(
    text: '${widget.height}',
  );
  late Resampling _resampling = widget.resampling;
  Anchor _anchor = Anchor.center;
  bool _keepRatio = true;
  bool _syncing = false;

  @override
  void dispose() {
    _w.dispose();
    _h.dispose();
    super.dispose();
  }

  int? get _width => int.tryParse(_w.text);
  int? get _height => int.tryParse(_h.text);

  bool get _tooLarge {
    final w = _width ?? 0;
    final h = _height ?? 0;
    return w * h > SizeDialogWidget.maxPixels;
  }

  bool get _valid => (_width ?? 0) > 0 && (_height ?? 0) > 0 && !_tooLarge;

  void _linked(bool fromWidth) {
    if (_syncing || !_keepRatio || widget.kind != SizeDialogKind.resize) {
      setState(() {});
      return;
    }
    _syncing = true;
    if (fromWidth && _width != null) {
      _h.text =
          '${(_width! * widget.height / widget.width).round().clamp(1, 1 << 20)}';
    } else if (!fromWidth && _height != null) {
      _w.text =
          '${(_height! * widget.width / widget.height).round().clamp(1, 1 << 20)}';
    }
    _syncing = false;
    setState(() {});
  }

  void _ok() {
    if (!_valid) {
      return;
    }
    Navigator.of(context).pop(
      SizeAnswer(
        _width!,
        _height!,
        resampling: widget.kind == SizeDialogKind.resize ? _resampling : null,
        anchor: widget.kind == SizeDialogKind.canvasSize ? _anchor : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    Widget field(String label, TextEditingController c, bool fromWidth) => Row(
      children: [
        SizedBox(width: 96, child: Text(label)),
        SizedBox(
          width: 110,
          child: TextField(
            controller: c,
            autofocus: fromWidth,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _linked(fromWidth),
            onSubmitted: (_) => _ok(),
          ),
        ),
        const SizedBox(width: Space.xs),
        Text(words.pixels, style: text.bodySmall),
      ],
    );
    return AppDialogs.card(
      context,
      title: switch (widget.kind) {
        SizeDialogKind.newImage => words.newImageTitle,
        SizeDialogKind.resize => words.resizeTitle,
        SizeDialogKind.canvasSize => words.canvasSizeTitle,
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          field(words.width, _w, true),
          const SizedBox(height: Space.xs),
          field(words.height, _h, false),
          if (widget.kind == SizeDialogKind.resize) ...[
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _keepRatio,
              onChanged: (v) => setState(() => _keepRatio = v ?? true),
              title: Text(words.keepRatio),
            ),
            SegmentedButton<Resampling>(
              segments: [
                ButtonSegment(
                  value: Resampling.bilinear,
                  label: Text(words.resamplingBilinear),
                ),
                ButtonSegment(
                  value: Resampling.nearestNeighbor,
                  label: Text(words.resamplingNearest),
                ),
              ],
              selected: {_resampling},
              onSelectionChanged: (s) => setState(() => _resampling = s.first),
            ),
          ],
          if (widget.kind == SizeDialogKind.canvasSize) ...[
            const SizedBox(height: Space.sm),
            Text(words.anchor, style: text.labelMedium),
            const SizedBox(height: Space.xxs),
            SizedBox(
              width: 3 * 32 + 2 * Space.xxs,
              child: Wrap(
                spacing: Space.xxs,
                runSpacing: Space.xxs,
                children: [
                  for (final a in Anchor.values)
                    GlassTap(
                      selected: a == _anchor,
                      onTap: () => setState(() => _anchor = a),
                      child: SizedBox.square(
                        dimension: 32,
                        child: Icon(
                          a == _anchor ? Icons.circle : Icons.circle_outlined,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          AnimatedSize(
            duration: Motion.normal,
            child: _tooLarge
                ? Padding(
                    padding: const EdgeInsets.only(top: Space.xs),
                    child: Text(
                      words.sizeTooLarge(SizeDialogWidget.maxPixels ~/ 1000000),
                      style: text.bodySmall?.copyWith(
                        color: context.tokens.danger,
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(words.cancel),
        ),
        FilledButton(onPressed: _valid ? _ok : null, child: Text(words.ok)),
      ],
    );
  }
}
