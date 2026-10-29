import 'package:core/src/event_bus/event_bus_service.dart';
import 'package:core/src/failure.dart';

/// An operation failed in a way the current screen has no dedicated UI
/// for: the toast layer words it.
class ShowFailureAction extends ActionEvent {
  const ShowFailureAction(this.failure);

  final Failure failure;
}
