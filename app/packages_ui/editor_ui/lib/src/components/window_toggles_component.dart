import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/accent_color.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/color_editor_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:editor_ui/src/widgets/tool_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The top right corner, as in Paint.NET: the floating windows shown or
/// hidden (F5 - F8), the settings (theme, accent colour, language) and
/// help.
class WindowTogglesComponent extends StatelessWidget {
  const WindowTogglesComponent({super.key});

  /// The custom accent from the colour wheel; OK chooses it.
  static Future<void> _chooseCustom(
    BuildContext context,
    EditorBloc bloc,
    EditorReady state,
  ) async {
    final words = AppLocalizations.of(context);
    var color = ColorRgba8(AccentChoice.custom.color(state.customAccent)).rgba8;
    final chosen = await AppDialogs.show<Rgba8>(
      context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AppDialogs.card(
          context,
          title: words.accentCustomTitle,
          width: 320,
          body: Center(
            child: ColorEditorWidget(
              color: color,
              expanded: false,
              showOpacity: false,
              onChanged: (next) => setState(
                () => color = Rgba8(r: next.r, g: next.g, b: next.b, a: 255),
              ),
              labels: ColorEditorLabels(
                hue: words.colorsHue,
                saturation: words.colorsSat,
                value: words.colorsValue,
                red: words.colorsRed,
                green: words.colorsGreen,
                blue: words.colorsBlue,
                alpha: 'A',
                hex: '#',
                opacity: words.layerOpacity,
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(words.cancel),
            ),
            FilledButton(
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(color),
              child: Text(words.ok),
            ),
          ],
        ),
      ),
    );
    if (chosen != null) {
      bloc.add(
        AccentChosenEvent(AccentChoice.custom, custom: chosen.color.toARGB32()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.panels != b.panels ||
          a.theme != b.theme ||
          a.accent != b.accent ||
          a.customAccent != b.customAccent ||
          a.language != b.language,
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
                SubmenuButton(
                  leadingIcon: const Icon(Icons.contrast_rounded, size: 16),
                  menuChildren: [
                    for (final (choice, label) in [
                      (ThemeChoice.system, words.themeSystem),
                      (ThemeChoice.dark, words.themeDark),
                      (ThemeChoice.light, words.themeLight),
                    ])
                      MenuItemButton(
                        leadingIcon: _Check(shown: state.theme == choice),
                        onPressed: () => bloc.add(ThemeChosenEvent(choice)),
                        child: Text(label),
                      ),
                  ],
                  child: Text(words.menuTheme),
                ),
                SubmenuButton(
                  leadingIcon: const Icon(Icons.palette_outlined, size: 16),
                  menuChildren: [
                    for (final choice in AccentChoice.values)
                      MenuItemButton(
                        leadingIcon: _Check(shown: state.accent == choice),
                        trailingIcon: _Swatch(
                          color: choice.color(state.customAccent),
                        ),
                        onPressed: choice == AccentChoice.custom
                            ? () => _chooseCustom(context, bloc, state)
                            : () => bloc.add(AccentChosenEvent(choice)),
                        child: Text(words.accentName(choice.name)),
                      ),
                  ],
                  child: Text(words.menuAccent),
                ),
                SubmenuButton(
                  leadingIcon: const Icon(Icons.translate_rounded, size: 16),
                  menuChildren: [
                    MenuItemButton(
                      leadingIcon: _Check(shown: state.language == null),
                      onPressed: () =>
                          bloc.add(const LanguageChosenEvent(null)),
                      child: Text(words.languageSystem),
                    ),
                    for (final MapEntry(key: code, value: name)
                        in AppLanguages.names.entries)
                      MenuItemButton(
                        leadingIcon: _Check(shown: state.language == code),
                        onPressed: () => bloc.add(LanguageChosenEvent(code)),
                        child: Text(name),
                      ),
                  ],
                  child: Text(words.menuLanguage),
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

/// The tick before the chosen item of a settings list.
class _Check extends StatelessWidget {
  const _Check({required this.shown});

  final bool shown;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 16,
    child: shown ? const Icon(Icons.check_rounded, size: 14) : null,
  );
}

/// The accent's colour after its name.
class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: context.tokens.hairlineStrong),
    ),
  );
}
