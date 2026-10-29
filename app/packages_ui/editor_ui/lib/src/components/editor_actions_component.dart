import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/dialogs/save_options_dialog_widget.dart';
import 'package:editor_ui/src/dialogs/size_dialog_widget.dart';
import 'package:editor_ui/src/widgets/paint_words.dart';
import 'package:flutter/material.dart' hide ActionListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// Turns the editor's one-shot actions into what they stand for: the
/// questions (a size, save options, unsaved changes) whose answers go
/// back as events, and the toasts.
class EditorActionsComponent extends StatelessWidget {
  const EditorActionsComponent({required this.child, super.key});

  final Widget child;

  static const _toastKey = 'editor';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditorBloc>();
    final toasts = injector<AppToastService>();
    return ActionListener<ShowFailureAction>(
      onAction: (context, action) => toasts.show(
        AppToast(
          key: _toastKey,
          message: AppLocalizations.of(context).failure(action.failure),
          isFailure: true,
        ),
      ),
      child: ActionListener<EditorAction>(
        onAction: (context, action) => _onAction(context, bloc, toasts, action),
        child: child,
      ),
    );
  }

  static Future<void> _onAction(
    BuildContext context,
    EditorBloc bloc,
    AppToastService toasts,
    EditorAction action,
  ) async {
    final words = AppLocalizations.of(context);
    switch (action) {
      case CanvasTilesAction() || ExitConfirmedAction():
        return;
      case AskNewImageAction(:final width, :final height):
        final answer = await AppDialogs.show<SizeAnswer>(
          context,
          builder: (_) => SizeDialogWidget(
            kind: SizeDialogKind.newImage,
            width: width,
            height: height,
          ),
        );
        if (answer != null) {
          bloc.add(NewImageConfirmedEvent(answer.width, answer.height));
        }
      case AskResizeAction(:final width, :final height, :final resampling):
        final answer = await AppDialogs.show<SizeAnswer>(
          context,
          builder: (_) => SizeDialogWidget(
            kind: SizeDialogKind.resize,
            width: width,
            height: height,
            resampling: resampling,
          ),
        );
        if (answer != null) {
          bloc.add(
            ResizeConfirmedEvent(
              answer.width,
              answer.height,
              answer.resampling ?? resampling,
            ),
          );
        }
      case AskCanvasSizeAction(:final width, :final height):
        final answer = await AppDialogs.show<SizeAnswer>(
          context,
          builder: (_) => SizeDialogWidget(
            kind: SizeDialogKind.canvasSize,
            width: width,
            height: height,
          ),
        );
        if (answer != null) {
          bloc.add(
            CanvasSizeConfirmedEvent(
              answer.width,
              answer.height,
              answer.anchor ?? Anchor.center,
            ),
          );
        }
      case AskSaveOptionsAction():
        final quality = await AppDialogs.show<int>(
          context,
          builder: (_) => SaveOptionsDialogWidget(
            path: action.path,
            flatten: action.flatten,
            quality: action.jpegQuality,
          ),
        );
        bloc.add(
          quality == null
              ? const SaveCancelledEvent()
              : SaveConfirmedEvent(
                  imageId: action.imageId,
                  path: action.path,
                  jpegQuality: quality,
                  closeAfter: action.closeAfter,
                ),
        );
      case AskCloseAction(:final imageId, :final title):
        final save = await AppDialogs.ask<bool>(
          context,
          title: words.unsavedTitle,
          message: words.unsavedMessage(words.title(title)),
          choices: [
            DialogChoice(words.dontSave, false),
            DialogChoice(words.save, true, primary: true),
          ],
        );
        bloc.add(CloseAnsweredEvent(imageId, save: save));
      case AskExpandCanvasAction():
        final expand = await AppDialogs.ask<bool>(
          context,
          title: words.largerTitle,
          message: words.largerMessage,
          choices: [
            DialogChoice(words.keepCanvas, false),
            DialogChoice(words.expandCanvas, true, primary: true),
          ],
        );
        bloc.add(ExpandAnsweredEvent(expand: expand));
      case ImageSavedAction(:final title):
        toasts.show(
          AppToast(key: _toastKey, message: words.savedTo(words.title(title))),
        );
      case ToolUnavailableAction(:final tool):
        toasts.show(
          AppToast(
            key: _toastKey,
            message: words.toolUnavailable(words.tool(tool)),
          ),
        );
      case ShowHelpAction():
        // The keys, then the notice GPL 3 asks an interactive program to
        // show: the copyright, no warranty, the license and the licenses
        // of what the program is built from.
        unawaited(
          AppDialogs.show<void>(
            context,
            builder: (context) => AppDialogs.card(
              context,
              title: words.helpTitle,
              body: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(words.helpMessage),
                  const SizedBox(height: Space.sm),
                  Text(
                    words.aboutLegal,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: context.tokens.muted),
                  ),
                ],
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => showLicensePage(
                    context: context,
                    applicationName: words.appTitle,
                  ),
                  child: Text(words.licenses),
                ),
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(words.ok),
                ),
              ],
            ),
          ),
        );
    }
  }
}
