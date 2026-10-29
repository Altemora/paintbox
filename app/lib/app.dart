import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:editor_ui/editor_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:paint_logic/paint_logic.dart';
import 'package:paintbox/screenshot/screenshot_runner.dart';

/// The app: the theme, accent and language the settings choose (the
/// system's language when none is), the toast layer over the editor
/// window.
class PaintboxApp extends StatefulWidget {
  const PaintboxApp({this.paths = const [], this.runner, super.key});

  final List<String> paths;

  /// Plays the screenshot scenes instead of a working window.
  final ScreenshotRunner? runner;

  @override
  State<PaintboxApp> createState() => _PaintboxAppState();
}

class _PaintboxAppState extends State<PaintboxApp> {
  final GlobalKey _boundary = GlobalKey();
  late _Look _look = _Look.of(
    injector<SettingsRepository>().getSettingsSync(),
    widget.runner,
  );

  @override
  Widget build(BuildContext context) {
    final runner = widget.runner;
    final accent = _look.accent.color(_look.customAccent);
    final language = _look.language;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(accent: accent),
      darkTheme: AppTheme.dark(accent: accent),
      themeMode: switch (_look.theme) {
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
      // Null follows the system; a system language the program lacks
      // falls back to English, the first supported locale.
      locale: language == null ? null : Locale(language),
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
            if (state is EditorReady && runner == null) {
              final look = _Look.ofState(state);
              if (look != _look) {
                setState(() => _look = look);
              }
            }
          });
          runner?.start(bloc, _boundary);
        },
      ),
    );
  }
}

/// What the window looks like and speaks: the theme, the accent and the
/// language.
final class _Look {
  const _Look(this.theme, this.accent, this.customAccent, this.language);

  /// The settings', or the screenshot runner's own when it plays.
  factory _Look.of(AppSettings settings, ScreenshotRunner? runner) =>
      runner == null
      ? _Look(
          settings.theme,
          settings.accent,
          settings.customAccent,
          settings.language,
        )
      : _Look(
          runner.theme,
          runner.accent,
          AppSettings.defaultCustomAccent,
          runner.language,
        );

  factory _Look.ofState(EditorReady state) =>
      _Look(state.theme, state.accent, state.customAccent, state.language);

  final ThemeChoice theme;
  final AccentChoice accent;
  final int customAccent;
  final String? language;

  @override
  bool operator ==(Object other) =>
      other is _Look &&
      other.theme == theme &&
      other.accent == accent &&
      other.customAccent == customAccent &&
      other.language == language;

  @override
  int get hashCode => Object.hash(theme, accent, customAccent, language);
}
