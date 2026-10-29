import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// An error a bloc did not handle reaches the log instead of vanishing.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLog.error(error, stackTrace, where: '${bloc.runtimeType}');
    super.onError(bloc, error, stackTrace);
  }
}
