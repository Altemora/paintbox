import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/src/bloc/editor_state.dart';
import 'package:paint_logic/paint_logic.dart';

/// The words of the core's ids: every one goes through the translations,
/// falling back to the core's English name when a translation is
/// missing.
extension PaintWords on AppLocalizations {
  static String _key(String id) => id.replaceAll(':', '_');

  String command(String id) {
    final text = commandLabel(_key(id));
    if (text.isNotEmpty) {
      return text;
    }
    return PaintCatalog.commands[id]?.label.replaceAll('...', '…') ?? id;
  }

  String dialog(String id) {
    final text = dialogTitle(_key(id));
    return text.isNotEmpty ? text : command(id).replaceAll('…', '');
  }

  String tool(Tool tool) {
    final text = toolName(PaintCatalog.toolId(tool));
    return text.isNotEmpty ? text : PaintCatalog.tool(tool).name;
  }

  String hint(Tool tool) {
    final text = toolHint(PaintCatalog.toolId(tool));
    return text.isNotEmpty ? text : PaintCatalog.tool(tool).hint;
  }

  String param(String name) {
    final text = paramName(name);
    return text.isNotEmpty ? text : name;
  }

  String blendMode(BlendMode mode) {
    final text = blendModeName(mode.name);
    return text.isNotEmpty ? text : mode.name;
  }

  String effects(String group) {
    final text = effectGroup(group.toLowerCase());
    return text.isNotEmpty ? text : group;
  }

  String title(ImageTitle title) =>
      title.fileName ?? untitledImage(title.untitledNumber ?? 1);

  /// A History step: the core names steps with its English names of
  /// tools and commands.
  String historyStep(String name) {
    switch (name) {
      case 'New Image':
        return historyNewImage;
      case 'Open Image':
        return historyOpenImage;
    }
    final id = PaintCatalog.idOfName(name);
    if (id == null) {
      return name;
    }
    if (id.startsWith('tool:')) {
      final text = toolName(id.substring(5));
      return text.isNotEmpty ? text : name;
    }
    return command(id.substring(8)).replaceAll('…', '');
  }

  String failure(Failure failure) => switch (failure) {
    PaintFailure(:final code) => failureCode(code),
    StorageFailure() => failureStorage,
    InvalidDataFailure() => failureInvalidData,
    _ => failureUnknown,
  };
}
