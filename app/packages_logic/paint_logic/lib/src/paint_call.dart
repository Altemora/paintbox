import 'package:core/core.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/paint_failure.dart';

/// The one place a bridge error becomes a [Failure]: every call into the
/// core from logic goes through [run] or [runAsync].
abstract final class PaintCall {
  static T run<T>(T Function() call) {
    try {
      return call();
    } on Object catch (error, stackTrace) {
      throw map(error, stackTrace);
    }
  }

  static Future<T> runAsync<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (error, stackTrace) {
      throw map(error, stackTrace);
    }
  }

  static Failure map(Object error, [StackTrace? stackTrace]) => switch (error) {
    final Failure failure => failure,
    PaintError(code: 'io', :final message) => StorageFailure(
      reason: message,
      origin: error,
      originStackTrace: stackTrace,
    ),
    PaintError(:final code, :final message) => PaintFailure(
      code: code,
      reason: message,
      origin: error,
      originStackTrace: stackTrace,
    ),
    _ => Failure.wrap(error, stackTrace),
  };
}
