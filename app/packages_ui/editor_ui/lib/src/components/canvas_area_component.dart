import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/ruler_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The canvas with its rulers (View > Rulers) along the top and the left
/// edge; [child] — the canvas and what floats over it — fills the rest.
class CanvasAreaComponent extends StatelessWidget {
  const CanvasAreaComponent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final words = AppLocalizations.of(context);
    final tokens = context.tokens;
    return BlocBuilder<EditorBloc, EditorState>(
      buildWhen: (a, b) =>
          a is! EditorReady ||
          b is! EditorReady ||
          a.rulers != b.rulers ||
          a.view != b.view ||
          a.pointer != b.pointer,
      builder: (context, state) {
        final ready = state is EditorReady ? state : null;
        final view = ready?.view;
        if (ready == null || !ready.rulers || view == null) {
          return child;
        }
        final edge = BoxDecoration(
          color: tokens.glass,
          border: Border(
            right: BorderSide(color: tokens.hairline),
            bottom: BorderSide(color: tokens.hairline),
          ),
        );
        return Column(
          children: [
            SizedBox(
              height: ControlSize.ruler,
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: edge,
                    child: SizedBox.square(
                      dimension: ControlSize.ruler,
                      // The unit the rulers count in, as Paint.NET has it, at
                      // the size of the rulers' numbers.
                      child: Center(
                        child: Text(
                          words.unitsPixels,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: RulerWidget.labelStyle(context),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: DecoratedBox(
                      decoration: edge,
                      child: RulerWidget(
                        view: view,
                        vertical: false,
                        pointer: ready.pointer?.dx,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: ControlSize.ruler,
                    child: DecoratedBox(
                      decoration: edge,
                      child: RulerWidget(
                        view: view,
                        vertical: true,
                        pointer: ready.pointer?.dy,
                      ),
                    ),
                  ),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
