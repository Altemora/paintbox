import 'package:equatable/equatable.dart';

/// A word about what just happened. A toast with the [key] of one already
/// shown or waiting takes its place.
final class AppToast extends Equatable {
  const AppToast({required this.message, this.key, this.isFailure = false});

  final String message;
  final String? key;
  final bool isFailure;

  @override
  List<Object?> get props => [message, key, isFailure];
}
