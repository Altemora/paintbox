import 'package:equatable/equatable.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/models/panels.dart';

enum ThemeChoice { system, dark, light }

/// What the program remembers between sessions.
final class AppSettings extends Equatable {
  const AppSettings({
    required this.tool,
    required this.toolSettings,
    required this.jpegQuality,
    this.recentFiles = const [],
    this.panels = const Panels(),
    this.theme = ThemeChoice.system,
    this.lastDirectory,
    this.rulers = true,
  });

  static const maxRecentFiles = 8;

  final Tool tool;
  final ToolSettings toolSettings;
  final int jpegQuality;

  /// Newest first.
  final List<String> recentFiles;
  final Panels panels;
  final ThemeChoice theme;
  final String? lastDirectory;
  final bool rulers;

  AppSettings copyWith({
    Tool? tool,
    ToolSettings? toolSettings,
    int? jpegQuality,
    List<String>? recentFiles,
    Panels? panels,
    ThemeChoice? theme,
    String? lastDirectory,
    bool? rulers,
  }) => AppSettings(
    tool: tool ?? this.tool,
    toolSettings: toolSettings ?? this.toolSettings,
    jpegQuality: jpegQuality ?? this.jpegQuality,
    recentFiles: recentFiles ?? this.recentFiles,
    panels: panels ?? this.panels,
    theme: theme ?? this.theme,
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
    lastDirectory,
    rulers,
  ];
}
