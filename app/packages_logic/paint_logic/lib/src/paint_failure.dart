import 'package:core/core.dart';

/// A refusal of the core: its stable [code] (`decode`, `invalid_size`,
/// `last_layer`...) is what the UI words.
final class PaintFailure extends BusinessFailure {
  const PaintFailure({
    required this.code,
    required super.reason,
    super.origin,
    super.originStackTrace,
  });

  final String code;

  @override
  String get debugDescription => '$code: $reason';
}
