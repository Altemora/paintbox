import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The status bar, as Paint.NET's: the tool's hint (or the file being
/// read or written) on the left; the selection, the image's size, the
/// pointer, the units and the zoom with its slider on the right.
class StatusBarComponent extends StatelessWidget {
  const StatusBarComponent({super.key});

  static final double _logMin = math.log(CanvasView.minZoom);
  static final double _logMax = math.log(CanvasView.maxZoom);

  /// The slider runs over the zoom's logarithm: each step of it is the
  /// same factor, as the wheel's are.
  static double _toSlider(double zoom) =>
      ((math.log(zoom) - _logMin) / (_logMax - _logMin)).clamp(0.0, 1.0);

  static double _fromSlider(double t) =>
      math.exp(_logMin + t * (_logMax - _logMin));

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final tokens = context.tokens;
    final bloc = context.read<EditorBloc>();
    // Figures of one width, so the numbers do not jitter as they change.
    final text = Theme.of(context).textTheme.bodySmall
        ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final muted = text?.copyWith(color: tokens.muted);
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.tool != b.tool ||
          a.pointer != b.pointer ||
          a.busy != b.busy ||
          a.saving != b.saving ||
          a.view?.zoom != b.view?.zoom ||
          a.image?.stamp.selectionBounds != b.image?.stamp.selectionBounds ||
          a.image?.stamp.width != b.image?.stamp.width ||
          a.image?.stamp.height != b.image?.stamp.height ||
          a.preview?.rendering != b.preview?.rendering,
      builder: (context, state) {
        if (state is! EditorReady) {
          return const SizedBox(height: ControlSize.statusBar);
        }
        final image = state.image;
        final pointer = state.pointer;
        final busy = state.busy;
        final view = state.view;
        final bounds = image?.stamp.selectionBounds;
        final rendering = state.preview?.rendering ?? false;
        // Cells keep their width whether they have a value or not.
        Widget cell(IconData icon, String? value, double width) => SizedBox(
          width: width,
          child: value == null
              ? null
              : Row(
                  children: [
                    Icon(icon, size: 14, color: tokens.muted),
                    const SizedBox(width: Space.xxs),
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: text,
                      ),
                    ),
                  ],
                ),
        );
        Widget zoomButton(String id, IconData icon) => IconButton(
          tooltip: words.command(id),
          iconSize: 14,
          visualDensity: VisualDensity.compact,
          onPressed: view == null
              ? null
              : () => bloc.add(CommandInvokedEvent(id)),
          icon: Icon(icon),
        );
        return SizedBox(
          height: ControlSize.statusBar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Space.xs),
            child: Row(
              children: [
                if (busy != null || rendering) ...[
                  const SizedBox.square(
                    dimension: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.6),
                  ),
                  const SizedBox(width: Space.xs),
                ],
                Expanded(
                  child: Text(
                    busy != null
                        ? (state.saving
                              ? words.statusSaving(busy)
                              : words.statusOpening(busy))
                        : rendering
                        ? words.rendering
                        : words.hint(state.tool),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ),
                cell(
                  Icons.highlight_alt_rounded,
                  image != null && image.hasSelection && bounds != null
                      ? words.statusSelection(bounds.width, bounds.height)
                      : null,
                  104,
                ),
                cell(
                  Icons.aspect_ratio_rounded,
                  image == null
                      ? null
                      : words.statusSelection(image.width, image.height),
                  104,
                ),
                cell(
                  Icons.near_me_outlined,
                  pointer == null
                      ? null
                      : words.statusPointer(
                          pointer.dx.floor(),
                          pointer.dy.floor(),
                        ),
                  96,
                ),
                SizedBox(
                  width: Space.xl,
                  child: Text(words.unitsPixels, style: muted),
                ),
                SizedBox(
                  width: Space.xxl,
                  child: Text(
                    view == null
                        ? ''
                        : words.statusZoom(_percent(view.percent)),
                    textAlign: TextAlign.end,
                    style: text,
                  ),
                ),
                zoomButton('zoom_out', Icons.zoom_out_rounded),
                SizedBox(
                  width: 120,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                    ),
                    child: Slider(
                      value: view == null ? 0.5 : _toSlider(view.zoom),
                      onChanged: view == null
                          ? null
                          : (t) => bloc.add(ZoomSetEvent(_fromSlider(t))),
                    ),
                  ),
                ),
                zoomButton('zoom_in', Icons.zoom_in_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _percent(double percent) =>
      percent >= 10 ? percent.round().toString() : percent.toStringAsFixed(1);
}
