import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The History window: the steps, the current one lit, undone ones
/// faded; a click walks there. Buttons: to the start, Undo, Redo, to the
/// end.
class HistoryPanelComponent extends StatelessWidget {
  const HistoryPanelComponent({super.key});

  /// Six steps: a fixed height, so nothing jumps as steps come.
  static const _height = 6 * ControlSize.row;

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final bloc = context.read<EditorBloc>();
    return BlocSelector<
      EditorBloc,
      EditorState,
      (List<String>, int, bool, bool, bool)
    >(
      selector: (state) => switch (state) {
        EditorReady(:final image?) => (
          image.history,
          image.historyPosition,
          state.hasPreview,
          state.canUndo,
          state.canRedo,
        ),
        _ => (const [], 0, false, false, false),
      },
      builder: (context, data) {
        // The same answers the menu and the keys have.
        final (steps, position, locked, canUndo, canRedo) = data;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _height,
              child: ListView.builder(
                reverse: false,
                itemCount: steps.length,
                itemExtent: ControlSize.row,
                itemBuilder: (context, i) => GlassTap(
                  selected: i == position,
                  onTap: locked ? null : () => bloc.add(HistoryJumpedEvent(i)),
                  padding: const EdgeInsets.symmetric(horizontal: Space.xs),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      words.historyStep(steps[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: i > position ? tokens.muted : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Space.xxs),
            const Hairline(),
            const SizedBox(height: Space.xxs),
            Row(
              spacing: Space.xxs,
              children: [
                BarButtonWidget(
                  tooltip: words.historyFirst,
                  onPressed: canUndo
                      ? () => bloc.add(const HistoryJumpedEvent(0))
                      : null,
                  child: const Icon(Icons.first_page_outlined),
                ),
                BarButtonWidget(
                  tooltip: '${words.historyUndo} (Ctrl+Z)',
                  onPressed: canUndo
                      ? () => bloc.add(const CommandInvokedEvent('undo'))
                      : null,
                  child: const Icon(Icons.undo_outlined),
                ),
                BarButtonWidget(
                  tooltip: '${words.historyRedo} (Ctrl+Y)',
                  onPressed: canRedo
                      ? () => bloc.add(const CommandInvokedEvent('redo'))
                      : null,
                  child: const Icon(Icons.redo_outlined),
                ),
                BarButtonWidget(
                  tooltip: words.historyLast,
                  onPressed: canRedo
                      ? () => bloc.add(HistoryJumpedEvent(steps.length - 1))
                      : null,
                  child: const Icon(Icons.last_page_outlined),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
