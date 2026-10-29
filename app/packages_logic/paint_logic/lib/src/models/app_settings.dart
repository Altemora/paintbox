import 'package:equatable/equatable.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/models/panels.dart';

enum ThemeChoice { system, dark, light }

/// The accent the interface is tinted with: one of the set or [custom].
enum AccentChoice { blue, green, amber, purple, red, gray, custom }

/// What the program remembers between launches.
final class AppSettings extends Equatable {
  const AppSettings({
    required this.tool,
    required this.toolSettings,
    required this.jpegQuality,
    this.recentFiles = const [],
    this.panels = const Panels(),
    this.theme = ThemeChoice.system,
    this.accent = AccentChoice.blue,
    this.customAccent = defaultCustomAccent,
    this.language,
    this.lastDirectory,
    this.rulers = true,
  });

  static const maxRecentFiles = 8;

  /// The custom accent before one is chosen: the blue of the set, ARGB.
  static const defaultCustomAccent = 0xFF5B8DEF;

  final Tool tool;
  final ToolSettings toolSettings;
  final int jpegQuality;

  /// Newest first.
  final List<String> recentFiles;
  final Panels panels;
  final ThemeChoice theme;
  final AccentChoice accent;

  /// ARGB of the accent when [accent] is [AccentChoice.custom].
  final int customAccent;

  /// A language code of the interface; null follows the system.
  final String? language;
  final String? lastDirectory;
  final bool rulers;

  AppSettings copyWith({
    Tool? tool,
    ToolSettings? toolSettings,
    int? jpegQuality,
    List<String>? recentFiles,
    Panels? panels,
    ThemeChoice? theme,
    AccentChoice? accent,
    int? customAccent,
    String? Function()? language,
    String? lastDirectory,
    bool? rulers,
  }) => AppSettings(
    tool: tool ?? this.tool,
    toolSettings: toolSettings ?? this.toolSettings,
    jpegQuality: jpegQuality ?? this.jpegQuality,
    recentFiles: recentFiles ?? this.recentFiles,
    panels: panels ?? this.panels,
    theme: theme ?? this.theme,
    accent: accent ?? this.accent,
    customAccent: customAccent ?? this.customAccent,
    language: language == null ? this.language : language(),
    lastDirectory: lastDirectory ?? this.lastDirectory,
    rulers: rulers ?? this.rulers,
  );

  /// [path] moved to the front of the recent files.
  AppSettings withRecent(String path) => copyWith(
    recentFiles: [
      path,
      ...recentFiles.where((p) => p != path),
    ].take(maxRecentFiles).toList(),
  );

  @override
  List<Object?> get props => [
    tool,
    toolSettings,
    jpegQuality,
    recentFiles,
    panels,
    theme,
    accent,
    customAccent,
    language,
    lastDirectory,
    rulers,
  ];
}
