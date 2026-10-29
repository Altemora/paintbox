import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:paintbox/app.dart';
import 'package:paintbox/app_bloc_observer.dart';
import 'package:paintbox/di.dart';
import 'package:paintbox/launch_options.dart';
import 'package:paintbox/screenshot/screenshot_runner.dart';
import 'package:window_manager/window_manager.dart';

/// Loads the Rust core, reads the settings, builds the graph, opens the
/// window. `--screenshot=<png>` instead plays the screenshot scenes and
/// quits (docs/building.md).
Future<void> bootstrap(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = LaunchOptions.parse(args);
  FlutterError.onError = (details) =>
      AppLog.error(details.exception, details.stack, where: 'FlutterError');
  // Errors outside the framework (a future nobody awaited, the bridge)
  // reach the log too.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLog.error(error, stackTrace, where: 'PlatformDispatcher');
    return true;
  };
  Bloc.observer = const AppBlocObserver();
  await PaintBridge.load();
  await configureDependencies(options);
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(1440, 900),
      minimumSize: Size(960, 640),
      title: 'Paintbox',
      center: true,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
  AppLog.startup(
    'Paintbox on ${Platform.operatingSystem}'
    '${options.screenshot == null ? '' : ', screenshots to ${options.screenshot}'}',
    where: 'bootstrap',
  );
  final screenshot = options.screenshot;
  runApp(
    PaintboxApp(
      paths: options.paths,
      runner: screenshot == null
          ? null
          : ScreenshotRunner(
              target: screenshot,
              scene: options.scene,
              theme: ThemeChoice.values.firstWhere(
                (t) => t.name == options.theme,
                orElse: () => ThemeChoice.dark,
              ),
              accent: AccentChoice.values.firstWhere(
                (a) => a.name == options.accent,
                orElse: () => AccentChoice.blue,
              ),
              language: options.language ?? 'en',
            ),
    ),
  );
}
