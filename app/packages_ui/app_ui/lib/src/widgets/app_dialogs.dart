import 'dart:ui' show ImageFilter;

import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:app_ui/src/widgets/glass_panel.dart';
import 'package:flutter/material.dart';

/// One button of a question.
final class DialogChoice<T> {
  const DialogChoice(this.label, this.value, {this.primary = false});

  final String label;
  final T value;

  /// The filled button; Enter picks it.
  final bool primary;
}

/// The pop-ups: a small card over a dimmed, blurred window. Esc and a
/// click outside answer null. Modal dialogs with fields build their body
/// on [card].
abstract final class AppDialogs {
  static Future<T?> ask<T>(
    BuildContext context, {
    required String title,
    required String message,
    required List<DialogChoice<T>> choices,
  }) => show<T>(
    context,
    builder: (context) => card(
      context,
      title: title,
      body: Text(message),
      actions: [
        for (final choice in choices)
          choice.primary
              ? FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(choice.value),
                  child: Text(choice.label),
                )
              : OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(choice.value),
                  child: Text(choice.label),
                ),
      ],
    ),
  );

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) => showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: Motion.normal,
    pageBuilder: (context, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Center(child: builder(context)),
    ),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Motion.curve),
      child: ScaleTransition(
        scale: Tween(
          begin: 0.97,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Motion.curve)),
        child: child,
      ),
    ),
  );

  /// The card every dialog sits on: a title, a body, buttons at the end.
  static Widget card(
    BuildContext context, {
    required String title,
    required Widget body,
    required List<Widget> actions,
    double width = 420,
  }) {
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: width,
      child: Material(
        type: MaterialType.transparency,
        child: GlassPanel(
          strong: true,
          shadow: true,
          radius: Radii.sm,
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: text.titleLarge),
              const SizedBox(height: Space.sm),
              DefaultTextStyle(style: text.bodyMedium!, child: body),
              const SizedBox(height: Space.lg),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: Space.xs,
                runSpacing: Space.xs,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
