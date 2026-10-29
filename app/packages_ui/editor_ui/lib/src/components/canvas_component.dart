import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/bloc/editor_bloc.dart';
import 'package:editor_ui/src/widgets/canvas_tiles.dart';
import 'package:editor_ui/src/widgets/canvas_widget.dart';
import 'package:flutter/material.dart' hide ActionListener;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';

/// The active image's canvas: turns the bloc's tiles into GPU images and
/// the pointer into events.
class CanvasComponent extends StatefulWidget {
  const CanvasComponent({super.key});

  @override
  State<CanvasComponent> createState() => _CanvasComponentState();
}

class _CanvasComponentState extends State<CanvasComponent> {
  final CanvasTiles _tiles = CanvasTiles();
  int? _attached;

  @override
  void dispose() {
    _tiles.dispose();
    super.dispose();
  }

  static MouseCursor _cursor(EditorReady s) {
    if (s.panning) {
      return SystemMouseCursors.grabbing;
    }
    if (s.temporaryPan) {
      return SystemMouseCursors.grab;
    }
    return switch (s.tool) {
      Tool.pan => SystemMouseCursors.grab,
      Tool.zoom => SystemMouseCursors.zoomIn,
      Tool.moveSelectedPixels || Tool.moveSelection => SystemMouseCursors.move,
      Tool.text => SystemMouseCursors.text,
      _ => SystemMouseCursors.precise,
    };
  }

  static CanvasButton _button(CanvasMouse mouse) => switch (mouse) {
    CanvasMouse.primary => CanvasButton.primary,
    CanvasMouse.secondary => CanvasButton.secondary,
    CanvasMouse.middle => CanvasButton.middle,
  };

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EditorBloc>();
    return ActionListener<CanvasTilesAction>(
      onAction: (context, action) =>
          _tiles.apply(action.imageId, action.blocks, reset: action.reset),
      child: BlocBuilder<EditorBloc, EditorState>(
        buildWhen: (a, b) =>
            a is! EditorReady ||
            b is! EditorReady ||
            a.view != b.view ||
            a.image?.id != b.image?.id ||
            a.image?.outline != b.image?.outline ||
            a.image?.handles != b.image?.handles ||
            a.image?.guide != b.image?.guide ||
            a.image?.stamp.width != b.image?.stamp.width ||
            a.image?.stamp.height != b.image?.stamp.height ||
            a.zoomBox != b.zoomBox ||
            a.tool != b.tool ||
            a.temporaryPan != b.temporaryPan ||
            a.panning != b.panning ||
            a.pixelGrid != b.pixelGrid,
        builder: (context, state) {
          final ready = state is EditorReady ? state : null;
          final image = ready?.image;
          final view = ready?.view;
          if (ready == null || image == null || view == null) {
            return ColoredBox(
              color: context.tokens.workspace,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;
                  final ratio = MediaQuery.devicePixelRatioOf(context);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => bloc.add(ViewportChangedEvent(size, ratio)),
                  );
                  return const SizedBox.expand();
                },
              ),
            );
          }
          // Only the first image needs asking: later ones arrive whole
          // with their activation.
          if (_attached == null) {
            _attached = image.id;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => bloc.add(CanvasAttachedEvent(image.id)),
            );
          }
          return CanvasWidget(
            tiles: _tiles,
            view: view,
            imageWidth: image.width,
            imageHeight: image.height,
            outline: image.outline.segments,
            outlineStamp: image.outline.stamp,
            outlineOffset: image.outline.offset,
            handles: image.handles,
            guide: image.guide,
            zoomBox: ready.zoomBox,
            pixelGrid: ready.pixelGrid,
            cursor: _cursor(ready),
            onViewport: (size, ratio) =>
                bloc.add(ViewportChangedEvent(size, ratio)),
            onDown: (at, button, mods) => bloc.add(
              CanvasPointerDownEvent(
                position: at,
                button: _button(button),
                ctrl: mods.ctrl,
                shift: mods.shift,
                alt: mods.alt,
              ),
            ),
            onMove: (at) => bloc.add(CanvasPointerMovedEvent(at)),
            onUp: (at, button, mods) => bloc.add(
              CanvasPointerUpEvent(
                position: at,
                button: _button(button),
                ctrl: mods.ctrl,
                shift: mods.shift,
                alt: mods.alt,
              ),
            ),
            onExit: () => bloc.add(const CanvasPointerExitedEvent()),
            onWheel: (at, delta, mods) => bloc.add(
              CanvasWheelEvent(
                position: at,
                delta: delta,
                ctrl: mods.ctrl,
                shift: mods.shift,
                alt: mods.alt,
              ),
            ),
            onPanZoom: (at, pan, scale) => bloc.add(
              CanvasPanZoomEvent(position: at, pan: pan, scale: scale),
            ),
          );
        },
      ),
    );
  }
}
