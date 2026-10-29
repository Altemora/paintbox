import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/pixel_block_image_widget.dart';
import 'package:editor_ui/src/widgets/reorder_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The Layers window: the layers top first with a thumbnail and the
/// visibility box; a click makes one active, a double click opens its
/// properties, a drag moves it to another place (one history step).
/// Buttons for the layer commands.
class LayersPanelComponent extends StatelessWidget {
  const LayersPanelComponent({super.key});

  static const _height = 6 * ControlSize.row;

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.image?.layers != b.image?.layers ||
          a.image?.activeLayer != b.image?.activeLayer ||
          a.image?.available != b.image?.available ||
          a.hasPreview != b.hasPreview,
      builder: (context, state) {
        final ready = state is EditorReady ? state : null;
        final rows = ready?.image?.layers ?? const <LayerRow>[];
        final active = ready?.image?.activeLayer ?? 0;
        final locked = ready?.hasPreview ?? false;
        VoidCallback? command(String id) => ready != null && ready.canRun(id)
            ? () => bloc.add(CommandInvokedEvent(id))
            : null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _height,
              child: ReorderListWidget(
                axis: Axis.vertical,
                itemCount: rows.length,
                itemExtent: ControlSize.row + Space.xs,
                enabled: !locked,
                onMove: (from, at) {
                  // The list is top first; the core counts bottom up.
                  bloc.add(
                    LayerMovedEvent(
                      rows.length - 1 - from,
                      rows.length - 1 - at,
                    ),
                  );
                },
                itemBuilder: (context, i) {
                  // Top first, as Paint.NET lists them.
                  final index = rows.length - 1 - i;
                  final row = rows[index];
                  final props = row.properties;
                  return GlassTap(
                    selected: index == active,
                    // A layer is chosen on the press, as in Paint.NET, not
                    // after the double-click wait.
                    onTapDown: locked
                        ? null
                        : () => bloc.add(LayerSelectedEvent(index)),
                    onDoubleTap: locked
                        ? null
                        : () => bloc.add(LayerPropertiesRequestedEvent(index)),
                    padding: const EdgeInsets.symmetric(horizontal: Space.xxs),
                    child: Row(
                      children: [
                        PixelBlockImageWidget(
                          block: row.thumbnail,
                          size: const Size(30, 30),
                        ),
                        const SizedBox(width: Space.xs),
                        Expanded(
                          child: Text(
                            props.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(
                              fontStyle: props.isBackground
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                        // A quiet eye, not a filled box louder than the name.
                        BarButtonWidget(
                          tooltip: words.layerVisible,
                          size: ControlSize.field,
                          onPressed: locked
                              ? null
                              : () => bloc.add(
                                  LayerVisibilityToggledEvent(index),
                                ),
                          child: Icon(
                            props.visible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: Space.xxs),
            const Hairline(),
            const SizedBox(height: Space.xxs),
            Wrap(
              spacing: Space.xxs,
              children: [
                for (final (id, icon) in const [
                  ('add_layer', Icons.add_box_outlined),
                  ('delete_layer', Icons.delete_outline),
                  ('duplicate_layer', Icons.copy_outlined),
                  ('merge_layer_down', Icons.vertical_align_bottom_outlined),
                  ('move_layer_up', Icons.arrow_upward_outlined),
                  ('move_layer_down', Icons.arrow_downward_outlined),
                  ('layer_properties', Icons.tune_outlined),
                ])
                  BarButtonWidget(
                    tooltip: _tooltip(words, id),
                    onPressed: command(id),
                    child: Icon(icon),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _tooltip(AppLocalizations words, String id) {
    final keys = PaintCatalog.shortcut(id);
    final label = words.command(id).replaceAll('…', '');
    return keys.isEmpty ? label : '$label ($keys)';
  }
}
