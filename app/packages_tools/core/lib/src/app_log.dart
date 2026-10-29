import 'dart:developer' as developer;

import 'package:core/src/failure.dart';

/// Console log for anything the app decided to survive. Every swallowed or
/// mapped [Failure] must pass through here, so a silent failure is
/// impossible.
abstract final class AppLog {
  static const _name = 'paintbox';
  static const _levelInfo = 800;
  static const _levelWarning = 900;
  static const _levelError = 1000;

  static void info(String message, {required String where}) =>
      _write(_levelInfo, where, message);

  /// An [info] that is also printed: `dart:developer` lines do not reach
  /// the `flutter run` console, and what a build started with must be
  /// checkable right there.
  static void startup(String message, {required String where}) {
    info(message, where: where);
    // ignore: avoid_print
    print('[$_name][$where] $message');
  }

  static void warn(String message, {required String where}) =>
      _write(_levelWarning, where, message);

  static void failure(
    Failure failure, {
    required String where,
    String? details,
  }) => _write(
    _levelError,
    where,
    details == null ? '$failure' : '$failure\n$details',
    error: failure.origin,
    stackTrace: failure.originStackTrace,
  );

  static void error(
    Object error,
    StackTrace? stackTrace, {
    required String where,
  }) => _write(
    _levelError,
    where,
    '$error',
    error: error,
    stackTrace: stackTrace,
  );

  static void _write(
    int level,
    String where,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) => developer.log(
    '[$where] $message',
    name: _name,
    level: level,
    error: error,
    stackTrace: stackTrace,
  );
}
