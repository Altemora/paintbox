import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// Reacts to [ActionEvent]s of type [T] from the app-wide
/// [EventBusService] with side effects (toasts, dialogs, the window)
/// without rebuilding [child]. A sealed base type listens to the whole
/// channel.
class ActionListener<T extends ActionEvent> extends StatefulWidget {
  const ActionListener({
    required this.onAction,
    required this.child,
    this.filter,
    super.key,
  });

  final FutureOr<void> Function(BuildContext context, T action) onAction;

  /// Optional narrowing on top of the type, e.g. by image id.
  final bool Function(T action)? filter;

  final Widget child;

  @override
  State<ActionListener<T>> createState() => _ActionListenerState<T>();
}

class _ActionListenerState<T extends ActionEvent>
    extends State<ActionListener<T>> {
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = injector<EventBusService>().on<T>().listen((action) {
      if (!mounted || widget.filter?.call(action) == false) {
        return;
      }
      unawaited(Future.sync(() => widget.onAction(context, action)));
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
