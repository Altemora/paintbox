import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/components/editor_shell_component.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart' hide ActionListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:window_manager/window_manager.dart';

/// The editor window. Builds its bloc from the injector, starts it with
/// the files given at launch, keeps the window's title and close button
/// in step with it, and closes it.
class EditorPage extends StatefulWidget {
  const EditorPage({
    this.paths = const [],
    this.manageWindow = true,
    this.onBloc,
    super.key,
  });

  final List<String> paths;

  /// False in tests and screenshots: no window to talk to.
  final bool manageWindow;

  /// The bloc once built, for the screenshot scenes of the composition
  /// root, which drive it with the same events a user would.
  final ValueChanged<EditorBloc>? onBloc;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> with WindowListener {
  late final EditorBloc _bloc;
  String? _title;

  @override
  void initState() {
    super.initState();
    _bloc = EditorBloc(
      images: injector<ImagesRepository>(),
      settings: injector<SettingsRepository>(),
      clipboard: injector<ClipboardRepository>(),
      files: injector<FileDialogService>(),
      eventBus: injector<EventBusService>(),
      previewWakes: injector<Stream<int>>(instanceName: 'previewWakes'),
    )..add(EditorStartedEvent(paths: widget.paths));
    widget.onBloc?.call(_bloc);
    if (widget.manageWindow) {
      windowManager.addListener(this);
      unawaited(windowManager.setPreventClose(true));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    injector<FileDialogService>().allImagesLabel = AppLocalizations.of(context)
        .fileTypeImages;
  }

  @override
  void dispose() {
    if (widget.manageWindow) {
      windowManager.removeListener(this);
    }
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  void onWindowClose() => _bloc.add(const ExitRequestedEvent());

  void _syncTitle(BuildContext context, EditorState state) {
    if (!widget.manageWindow || state is! EditorReady) {
      return;
    }
    final words = AppLocalizations.of(context);
    final tab = state.activeTab;
    final title = tab == null
        ? words.appTitle
        : '${words.title(tab.title)}${tab.isModified ? ' *' : ''} — ${words.appTitle}';
    if (title != _title) {
      _title = title;
      unawaited(windowManager.setTitle(title));
    }
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _bloc,
    child: ActionListener<ExitConfirmedAction>(
      onAction: (context, _) async {
        if (widget.manageWindow) {
          await windowManager.setPreventClose(false);
          await windowManager.destroy();
        }
      },
      child: BlocListener<EditorBloc, EditorState>(
        listener: _syncTitle,
        child: const Material(
          type: MaterialType.transparency,
          child: EditorShellComponent(),
        ),
      ),
    ),
  );
}
