import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/tool_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The Tools window: the core's tools two per row; the hint is the name
/// and the key.
class ToolsPanelComponent extends StatelessWidget {
  const ToolsPanelComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final tools = PaintCatalog.tools;
    return BlocSelector<EditorBloc, EditorState, Tool?>(
      selector: (state) => state is EditorReady ? state.tool : null,
      // Two buttons per row, as in Paint.NET; the window is as wide as
      // this or its title, whichever is wider.
      builder: (context, active) => Center(
        child: SizedBox(
          width: 2 * ControlSize.button + Space.xxs,
          child: Wrap(
            spacing: Space.xxs,
            runSpacing: 0,
            children: [
              for (final info in tools)
                BarButtonWidget(
                  tooltip:
                      '${words.tool(info.tool)} (${info.key.toUpperCase()})',
                  selected: info.tool == active,
                  onPressed: info.available
                      ? () => context.read<EditorBloc>().add(
                          ToolSelectedEvent(info.tool),
                        )
                      : null,
                  child: ToolIconWidget(tool: info.tool),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
