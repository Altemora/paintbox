import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The command bar under the menus, Paint.NET's: files, the clipboard,
/// crop and deselect, undo and redo, the pixel grid and the rulers, in
/// groups split by hairlines.
class CommandBarComponent extends StatelessWidget {
  const CommandBarComponent({super.key});

  static const _groups = [
    [
      ('new', Icons.note_add_outlined),
      ('open', Icons.folder_open_outlined),
      ('save', Icons.save_outlined),
    ],
    [
      ('cut', Icons.content_cut_outlined),
      ('copy', Icons.content_copy_outlined),
      ('paste', Icons.content_paste_outlined),
      ('crop_to_selection', Icons.crop_outlined),
      ('deselect', Icons.deselect_outlined),
    ],
    [('undo', Icons.undo_outlined), ('redo', Icons.redo_outlined)],
    [
      ('pixel_grid', Icons.grid_4x4_outlined),
      ('rulers', Icons.straighten_outlined),
    ],
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
          a.hasPreview != b.hasPreview ||
          a.busy != b.busy ||
          a.pixelGrid != b.pixelGrid ||
          a.rulers != b.rulers,
      builder: (context, state) {
        final ready = state is EditorReady ? state : null;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, group) in _groups.indexed) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Space.xxs,
                    vertical: Space.xs,
                  ),
                  child: Hairline(vertical: true),
                ),
              for (final (id, icon) in group)
                BarButtonWidget(
                  tooltip: _tooltip(words, id),
                  selected: switch (id) {
                    'pixel_grid' => ready?.pixelGrid ?? false,
                    'rulers' => ready?.rulers ?? false,
                    _ => false,
                  },
                  onPressed: ready != null && ready.canRun(id)
                      ? () => bloc.add(CommandInvokedEvent(id))
                      : null,
                  child: Icon(icon),
                ),
            ],
          ],
        );
      },
    );
  }

  static String _tooltip(AppLocalizations words, String id) {
    final label = words.command(id).replaceAll('…', '');
    final keys = PaintCatalog.shortcut(id);
    return keys.isEmpty ? label : '$label ($keys)';
  }
}
