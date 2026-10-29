/// The only throwable kind in the app. Anything escaping a repository,
/// service or the bridge must be a [Failure]; foreign exceptions are
/// wrapped into [UnknownFailure] with the origin preserved.
sealed class Failure implements Exception {
  const Failure({this.origin, this.originStackTrace});

  /// Wraps any foreign throwable; an existing [Failure] passes through.
  static Failure wrap(Object error, [StackTrace? stackTrace]) =>
      switch (error) {
        final Failure failure => failure,
        _ => UnknownFailure(origin: error, originStackTrace: stackTrace),
      };

  final Object? origin;
  final StackTrace? originStackTrace;

  String get debugDescription;

  @override
  String toString() =>
      '$runtimeType($debugDescription${origin == null ? '' : ', origin: $origin'})';
}

/// Reading or writing a file or the settings failed.
final class StorageFailure extends Failure {
  const StorageFailure({
    required this.reason,
    super.origin,
    super.originStackTrace,
  });

  final String reason;

  @override
  String get debugDescription => 'storage: $reason';
}

/// A file, the clipboard or the settings held data the app cannot make
/// sense of.
final class InvalidDataFailure extends Failure {
  const InvalidDataFailure({
    required this.reason,
    super.origin,
    super.originStackTrace,
  });

  final String reason;

  @override
  String get debugDescription => 'invalid data: $reason';
}

/// Extendable base for failures of the editing rules, declared by the
/// logic packages.
base class BusinessFailure extends Failure {
  const BusinessFailure({
    required this.reason,
    super.origin,
    super.originStackTrace,
  });

  final String reason;

  @override
  String get debugDescription => reason;
}

/// Wrapper for anything unexpected; [origin] always holds the source error.
final class UnknownFailure extends Failure {
  const UnknownFailure({required Object super.origin, super.originStackTrace});

  @override
  String get debugDescription => 'unknown';
}
