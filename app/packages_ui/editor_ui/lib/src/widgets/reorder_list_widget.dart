import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// A list whose items are dragged to another place, as Paint.NET's tabs
/// and layers are: the item follows the pointer along the list, an
/// accent line marks where it will go, and letting go there calls
/// [onMove] with its old and new index. A click without a drag stays a
/// click.
class ReorderListWidget extends StatefulWidget {
  const ReorderListWidget({
    required this.axis,
    required this.itemCount,
    required this.itemBuilder,
    required this.onMove,
    this.itemExtent,
    this.padding,
    this.shrinkWrap = false,
    this.enabled = true,
    super.key,
  });

  final Axis axis;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// From the item's index to the index it has once moved.
  final void Function(int from, int to) onMove;
  final double? itemExtent;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final bool enabled;

  /// The insertion line's key, for tests.
  static const markerKey = ValueKey('reorder-marker');

  @override
  State<ReorderListWidget> createState() => _ReorderListWidgetState();
}

class _ReorderListWidgetState extends State<ReorderListWidget> {
  final Map<int, GlobalKey> _keys = {};

  /// The dragged item and where it would go: an index between items,
  /// 0 – [ReorderListWidget.itemCount].
  int? _from;
  int? _insertAt;

  /// Where in its item the pointer took hold, and the item's size then
  /// (a size can only be read outside a build).
  Offset _grab = Offset.zero;
  Size? _grabbed;

  GlobalKey _key(int i) => _keys.putIfAbsent(i, GlobalKey.new);

  /// The gap before the first item whose middle lies past the pointer.
  int _insertionAt(Offset pointer) {
    for (var i = 0; i < widget.itemCount; i++) {
      final box = _key(i).currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached) {
        continue;
      }
      final middle = box.localToGlobal(box.size.center(Offset.zero));
      final before = widget.axis == Axis.horizontal
          ? pointer.dx < middle.dx
          : pointer.dy < middle.dy;
      if (before) {
        return i;
      }
    }
    return widget.itemCount;
  }

  /// Letting go beside the item itself moves nothing.
  bool get _moves {
    final from = _from;
    final at = _insertAt;
    return from != null && at != null && at != from && at != from + 1;
  }

  void _reset() => setState(() {
    _from = null;
    _insertAt = null;
  });

  @override
  Widget build(BuildContext context) => DragTarget<int>(
    // Asked before the drag reports its start: the item comes with it.
    onWillAcceptWithDetails: (details) => widget.enabled,
    onMove: (details) {
      final at = _insertionAt(details.offset + _grab);
      if (at != _insertAt || details.data != _from) {
        setState(() {
          _from = details.data;
          _insertAt = at;
        });
      }
    },
    onLeave: (_) => setState(() => _insertAt = null),
    onAcceptWithDetails: (_) {
      final from = _from;
      final at = _insertAt;
      final moves = _moves;
      _reset();
      if (from != null && at != null && moves) {
        widget.onMove(from, at > from ? at - 1 : at);
      }
    },
    builder: (context, _, _) => ListView.builder(
      scrollDirection: widget.axis,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemExtent: widget.itemExtent,
      itemCount: widget.itemCount,
      itemBuilder: _item,
    ),
  );

  Widget _item(BuildContext context, int i) {
    final child = widget.itemBuilder(context, i);
    final key = _key(i);
    final item = KeyedSubtree(key: key, child: child);
    final last = i == widget.itemCount - 1;
    final marked =
        _moves && (_insertAt == i || (last && _insertAt == widget.itemCount));
    return Listener(
      onPointerDown: (e) {
        _grab = e.localPosition;
        _grabbed = key.currentContext?.size;
      },
      child: Draggable<int>(
        data: i,
        axis: widget.axis,
        maxSimultaneousDrags: widget.enabled ? 1 : 0,
        onDragStarted: () => setState(() => _from = i),
        onDragEnd: (_) => _reset(),
        onDraggableCanceled: (_, _) => _reset(),
        feedback: Builder(
          builder: (context) => _FeedbackWidget(size: _grabbed, child: child),
        ),
        childWhenDragging: Opacity(opacity: 0.35, child: item),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            item,
            if (marked)
              _MarkerWidget(
                axis: widget.axis,
                after: _insertAt == widget.itemCount,
              ),
          ],
        ),
      ),
    );
  }
}

/// The accent line in the gap where the item would go.
class _MarkerWidget extends StatelessWidget {
  const _MarkerWidget({required this.axis, required this.after});

  final Axis axis;

  /// After the last item rather than before this one.
  final bool after;

  static const double _thickness = 2;

  @override
  Widget build(BuildContext context) {
    final line = DecoratedBox(
      key: ReorderListWidget.markerKey,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(_thickness),
      ),
    );
    const edge = -_thickness / 2;
    return axis == Axis.horizontal
        ? Positioned(
            top: Space.xxs,
            bottom: Space.xxs,
            left: after ? null : edge,
            right: after ? edge : null,
            width: _thickness,
            child: line,
          )
        : Positioned(
            left: Space.xxs,
            right: Space.xxs,
            top: after ? null : edge,
            bottom: after ? edge : null,
            height: _thickness,
            child: line,
          );
  }
}

/// The item under the pointer while it is dragged: its own size, on
/// floating glass.
class _FeedbackWidget extends StatelessWidget {
  const _FeedbackWidget({required this.size, required this.child});

  final Size? size;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: SizedBox.fromSize(
      size: size,
      child: GlassPanel(
        strong: true,
        shadow: true,
        radius: Radii.xxs,
        child: child,
      ),
    ),
  );
}
