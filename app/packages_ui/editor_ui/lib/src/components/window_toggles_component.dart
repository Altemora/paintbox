import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/tool_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The top right corner, as in Paint.NET: the floating windows shown or
/// hidden (F5 - F8), the settings (the theme) and help.
class WindowTogglesComponent extends StatelessWidget {
  const WindowTogglesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.panels != b.panels ||
          a.theme != b.theme,
      builder: (context, state) {
        if (state is! EditorReady) {
          return const SizedBox.shrink();
        }
        final panels = state.panels;
        // Apart by a step, so the lit ones do not merge into one bar.
        Widget toggle(String id, bool shown, Widget icon) => Padding(
          padding: const EdgeInsets.only(left: Space.xxs),
          child: BarButtonWidget(
            tooltip: '${words.command(id)} (${PaintCatalog.shortcut(id)})',
            selected: shown,
            onPressed: () => bloc.add(CommandInvokedEvent(id)),
            child: icon,
          ),
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            toggle(
              'toggle_tools',
              panels.tools,
              const ToolIconWidget(tool: Tool.paintbrush, size: 16),
            ),
            toggle(
              'toggle_history',
              panels.history,
              const Icon(Icons.history_outlined),
            ),
            toggle(
              'toggle_layers',
              panels.layers,
              const Icon(Icons.layers_outlined),
            ),
            toggle(
              'toggle_colors',
              panels.colors,
              const Icon(Icons.palette_outlined),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Space.xxs,
                vertical: Space.xs,
              ),
              child: Hairline(vertical: true),
            ),
            MenuAnchor(
              menuChildren: [
                for (final (choice, label) in [
                  (ThemeChoice.system, words.themeSystem),
                  (ThemeChoice.dark, words.themeDark),
                  (ThemeChoice.light, words.themeLight),
                ])
                  MenuItemButton(
                    leadingIcon: SizedBox(
                      width: 16,
                      child: state.theme == choice
                          ? const Icon(Icons.check_rounded, size: 14)
                          : null,
                    ),
                    onPressed: () => bloc.add(ThemeChosenEvent(choice)),
                    child: Text(label),
                  ),
              ],
              builder: (context, controller, _) => BarButtonWidget(
                tooltip: words.menuSettings,
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                child: const Icon(Icons.settings_outlined),
              ),
            ),
            BarButtonWidget(
              tooltip: '${words.command('help')} (F1)',
              onPressed: () => bloc.add(const CommandInvokedEvent('help')),
              child: const Icon(Icons.help_outline),
            ),
          ],
        );
      },
    );
  }
}
