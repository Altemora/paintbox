import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/editor_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:paintbox/screenshot/screenshot_runner.dart';

/// The app: the theme the settings choose (dark first), Ukrainian then
/// English, the toast layer over the editor window.
class PaintboxApp extends StatefulWidget {
  const PaintboxApp({this.paths = const [], this.runner, super.key});

  final List<String> paths;

  /// Plays the screenshot scenes instead of a session.
  final ScreenshotRunner? runner;

  @override
  State<PaintboxApp> createState() => _PaintboxAppState();
}

class _PaintboxAppState extends State<PaintboxApp> {
  final GlobalKey _boundary = GlobalKey();
  ThemeChoice _theme = injector<SettingsRepository>().getSettingsSync().theme;

  @override
  Widget build(BuildContext context) {
    final runner = widget.runner;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (_theme) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.dark => ThemeMode.dark,
        ThemeChoice.light => ThemeMode.light,
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: runner?.locale,
      builder: (context, child) => RepaintBoundary(
        key: _boundary,
        child: AppBackground(
          child: AppToastLayerComponent(child: child ?? const SizedBox()),
        ),
      ),
      home: EditorPage(
        paths: widget.paths,
        manageWindow: runner == null,
        onBloc: (bloc) {
          bloc.stream.listen((state) {
            if (state is EditorReady && state.theme != _theme) {
              setState(() => _theme = state.theme);
            }
          });
          runner?.start(bloc, _boundary);
        },
      ),
    );
  }
}
