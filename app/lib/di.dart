import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:paintbox/launch_options.dart';
import 'package:path_provider/path_provider.dart';

/// The composition root: every dependency of the app is built and
/// registered here, in the order the graph needs. Pages read the
/// injector; nothing in `packages_logic` does.
Future<void> configureDependencies(LaunchOptions options) async {
  final settings = SettingsRepository(
    options.isScreenshot
        ? null
        : SettingsStorage(await getApplicationSupportDirectory()),
  );
  await settings.load();
  final clipboard = options.isScreenshot
      ? MemoryClipboardService() as ClipboardService
      : SystemClipboardService();
  injector
    ..registerSingleton<EventBusService>(EventBusService())
    ..registerSingleton<AppToastService>(AppToastService())
    ..registerSingleton<SettingsRepository>(settings)
    ..registerSingleton<ImagesRepository>(ImagesRepository())
    ..registerSingleton<ClipboardRepository>(ClipboardRepository(clipboard))
    ..registerSingleton<FileDialogService>(SystemFileDialogService())
    // One stream for the program: the core tells it when an effect's
    // render is in.
    ..registerSingleton<Stream<int>>(
      previewWakes().asBroadcastStream(),
      instanceName: 'previewWakes',
    );
}
