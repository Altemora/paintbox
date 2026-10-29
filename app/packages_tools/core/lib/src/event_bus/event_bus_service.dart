import 'dart:async';

/// One-shot application action: the fact that something happened. Never a
/// carrier of screen state - that lives only in bloc states.
///
/// Channels are modelled by type hierarchies: subscribing to a base action
/// type listens to the whole channel, a concrete type to one event kind.
abstract class ActionEvent {
  const ActionEvent();
}

/// App-wide bus for [ActionEvent]s. Blocs push actions here instead of
/// putting flags into their states; the UI (through `ActionListener`) and
/// other blocs subscribe to the types they care about.
class EventBusService {
  final _controller = StreamController<ActionEvent>.broadcast();

  Stream<ActionEvent> get actions => _controller.stream;

  Stream<T> on<T extends ActionEvent>() =>
      actions.where((action) => action is T).cast<T>();

  void add(ActionEvent action) {
    if (!_controller.isClosed) {
      _controller.add(action);
    }
  }

  Future<void> dispose() => _controller.close();
}
