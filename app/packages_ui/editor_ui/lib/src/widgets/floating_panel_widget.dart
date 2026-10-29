import 'package:app_ui/app_ui.dart';
import 'package:editor_ui/src/widgets/bar_button_widget.dart';
import 'package:flutter/material.dart';

/// A floating window over the canvas (Tools, History, Layers, Colors):
/// glass with a title bar to drag it by and a button to hide it. Where it
/// was let go is [offset] from its corner, kept by the owner. While
/// the pointer is over the canvas and not over the window, it fades, as
/// Paint.NET's windows do.
class FloatingPanelWidget extends StatefulWidget {
  const FloatingPanelWidget({
    required this.title,
    required this.child,
    required this.alignment,
    required this.onHide,
    required this.hideTooltip,
    required this.onMoved,
    this.offset = Offset.zero,
    this.width,
    this.dimmed = false,
    this.inset = EdgeInsets.zero,
    super.key,
  });

  final String title;
  final Widget child;
  final Alignment alignment;
  final VoidCallback onHide;
  final String hideTooltip;
  final Offset offset;
  final ValueChanged<Offset> onMoved;
  final double? width;
  final bool dimmed;

  /// Room kept free beside the window (another window docked there).
  final EdgeInsets inset;

  @override
  State<FloatingPanelWidget> createState() => _FloatingPanelWidgetState();
}

class _FloatingPanelWidgetState extends State<FloatingPanelWidget> {
  /// Where a drag holds the window until the owner's offset catches up.
  Offset? _drag;
  bool _hovered = false;

  @override
  void didUpdateWidget(FloatingPanelWidget old) {
    super.didUpdateWidget(old);
    if (old.offset != widget.offset) {
      _drag = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(Space.sm) + widget.inset,
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: widget.alignment,
            child: Transform.translate(
              offset: _clamped(_drag ?? widget.offset, constraints.biggest),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: AnimatedOpacity(
                  duration: Motion.normal,
                  curve: Motion.curve,
                  opacity: widget.dimmed && !_hovered ? 0.8 : 1,
                  // Without a width the window fits its content.
                  child: IntrinsicWidth(
                    child: SizedBox(
                      width: widget.width,
                      child: GlassPanel(
                        shadow: true,
                        strong: true,
                        radius: Radii.xs,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (_) => setState(() {
                                _drag = _clamped(
                                  widget.offset,
                                  constraints.biggest,
                                );
                              }),
                              onPanUpdate: (d) => setState(() {
                                _drag = _clamped(
                                  (_drag ?? widget.offset) + d.delta,
                                  constraints.biggest,
                                );
                              }),
                              onPanEnd: (_) {
                                final at = _drag;
                                if (at != null && at != widget.offset) {
                                  widget.onMoved(at);
                                } else {
                                  setState(() => _drag = null);
                                }
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.move,
                                // One button high, the title on the content's edge.
                                child: Container(
                                  height: ControlSize.button,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Space.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: text.labelMedium?.copyWith(
                                            color: tokens.muted,
                                          ),
                                        ),
                                      ),
                                      BarButtonWidget(
                                        tooltip: widget.hideTooltip,
                                        size: 20,
                                        onPressed: widget.onHide,
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                Space.xs,
                                0,
                                Space.xs,
                                Space.xs,
                              ),
                              child: RepaintBoundary(child: widget.child),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The window may not be dragged out of the area entirely.
  Offset _clamped(Offset offset, Size area) => Offset(
    offset.dx.clamp(-area.width, area.width),
    offset.dy.clamp(-area.height, area.height),
  );
}
