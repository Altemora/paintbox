import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:path/path.dart' as p;

/// The menu bar: File, Edit, View, Image, Layers, Adjustments, Effects.
/// As in Paint.NET 5 the windows and help are buttons in the corner
/// ([WindowTogglesComponent]) and the tabs switch by Ctrl+Tab. Items run
/// the same commands as their keys; an item with nothing to act on is
/// disabled. The keys themselves are handled by the page, so the menus
/// only show them.
class MenuBarComponent extends StatelessWidget {
  const MenuBarComponent({super.key});

  static const _separator = '-';

  static const _file = [
    'new',
    'open',
    'recent',
    'close',
    'save',
    'save_as',
    _separator,
    'exit',
  ];
  static const _edit = [
    'undo', 'redo', _separator, //
    'cut', 'copy', 'paste', 'paste_into_new_layer', 'paste_into_new_image',
    _separator,
    'erase_selection', 'fill_selection', 'invert_selection', 'select_all',
    'deselect',
  ];
  static const _view = [
    'zoom_in', 'zoom_out', 'zoom_to_window', 'zoom_to_selection', //
    'actual_size', _separator, 'pixel_grid', 'rulers', 'theme',
  ];
  static const _image = [
    'crop_to_selection', 'resize', 'canvas_size', _separator, //
    'flip_horizontal', 'flip_vertical', _separator,
    'rotate90_cw', 'rotate90_ccw', 'rotate180', _separator, 'flatten',
  ];
  static const _layers = [
    'add_layer', 'delete_layer', 'duplicate_layer', 'merge_layer_down', //
    'import_from_file', _separator,
    'flip_layer_horizontal', 'flip_layer_vertical', _separator,
    'move_layer_up', 'move_layer_down', _separator, 'layer_properties',
  ];

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final bloc = context.read<EditorBloc>();
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.image?.available != b.image?.available ||
          a.hasImage != b.hasImage ||
          a.tabs.length != b.tabs.length ||
          a.panels != b.panels ||
          a.pixelGrid != b.pixelGrid ||
          a.rulers != b.rulers ||
          a.recentFiles != b.recentFiles ||
          a.theme != b.theme ||
          a.hasPreview != b.hasPreview,
      builder: (context, state) {
        if (state is! EditorReady) {
          return const SizedBox(height: ControlSize.bar);
        }
        Widget item(String id) {
          final shortcut = PaintCatalog.shortcut(id);
          final checked = switch (id) {
            'toggle_tools' => state.panels.tools,
            'toggle_history' => state.panels.history,
            'toggle_layers' => state.panels.layers,
            'toggle_colors' => state.panels.colors,
            'pixel_grid' => state.pixelGrid,
            'rulers' => state.rulers,
            _ => null,
          };
          return MenuItemButton(
            onPressed: state.canRun(id)
                ? () => bloc.add(CommandInvokedEvent(id))
                : null,
            leadingIcon: SizedBox(
              width: 16,
              child: checked == true
                  ? const Icon(Icons.check_rounded, size: 14)
                  : null,
            ),
            trailingIcon: shortcut.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: Space.lg),
                    child: Text(
                      shortcut,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: context.tokens.muted),
                    ),
                  ),
            child: Text(words.command(id)),
          );
        }

        List<Widget> items(List<String> ids) => [
          for (final id in ids)
            switch (id) {
              _separator => const Padding(
                padding: EdgeInsets.symmetric(vertical: Space.xxs),
                child: Hairline(),
              ),
              'recent' => SubmenuButton(
                leadingIcon: const SizedBox(width: 16),
                menuChildren: state.recentFiles.isEmpty
                    ? [MenuItemButton(child: Text(words.menuRecentEmpty))]
                    : [
                        for (final path in state.recentFiles)
                          MenuItemButton(
                            onPressed: () => bloc.add(OpenPathsEvent([path])),
                            child: Tooltip(
                              message: path,
                              child: Text(p.basename(path)),
                            ),
                          ),
                      ],
                child: Text(words.menuOpenRecent),
              ),
              'theme' => SubmenuButton(
                leadingIcon: const SizedBox(width: 16),
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
                child: Text(words.menuTheme),
              ),
              _ => item(id),
            },
        ];

        // The bar's items as tall as an icon button (the theme's compact
        // density would take 8 off); the drop-down rows stay dense.
        SubmenuButton menu(String label, List<Widget> children) =>
            SubmenuButton(
              style: const ButtonStyle(
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: WidgetStatePropertyAll<Size>(
                  Size(0, ControlSize.button),
                ),
              ),
              menuChildren: children,
              child: Text(label),
            );

        return SizedBox(
          height: ControlSize.bar,
          child: Padding(
            padding: EdgeInsets.zero,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MenuBar(
                children: [
                  menu(words.menuFile, items(_file)),
                  menu(words.menuEdit, items(_edit)),
                  menu(words.menuView, items(_view)),
                  menu(words.menuImage, items(_image)),
                  menu(words.menuLayers, items(_layers)),
                  menu(words.menuAdjustments, [
                    for (final f in PaintCatalog.adjustments) item(f.id),
                  ]),
                  menu(words.menuEffects, [
                    item('repeat_effect'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: Space.xxs),
                      child: Hairline(),
                    ),
                    for (final group in PaintCatalog.effectMenu)
                      SubmenuButton(
                        leadingIcon: const SizedBox(width: 16),
                        menuChildren: [for (final id in group.ids) item(id)],
                        child: Text(words.effects(group.name)),
                      ),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
