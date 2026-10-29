import 'package:get_it/get_it.dart';

/// The one service locator. Registered in the composition root
/// (`lib/di.dart`), read by pages when they build their blocs. Nothing in
/// `packages_logic` reads it: logic receives its dependencies through
/// constructors.
final GetIt injector = GetIt.instance;
