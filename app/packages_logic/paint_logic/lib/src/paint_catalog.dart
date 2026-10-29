import 'package:paint_bridge/paint_bridge.dart' as bridge;
import 'package:paint_bridge/paint_bridge.dart'
    show CommandInfo, EffectGroup, FilterInfo, Tool, ToolInfo;

/// What the core lists without an image, read once: tools, commands
/// with their shortcut texts, the Adjustments and Effects menus.
abstract final class PaintCatalog {
  static List<ToolInfo>? _tools;
  static Map<Tool, String>? _toolIds;
  static Map<String, CommandInfo>? _commands;
  static List<FilterInfo>? _adjustments;
  static List<EffectGroup>? _effects;
  static Future<List<String>>? _fonts;
  static Map<String, String>? _names;

  static List<ToolInfo> get tools => _tools ??= bridge.tools();

  static ToolInfo tool(Tool tool) => tools.firstWhere((t) => t.tool == tool);

  /// The core's stable name of a tool (`rectangle_select`).
  static String toolId(Tool tool) => (_toolIds ??= {
    for (final t in tools) t.tool: bridge.toolId(tool: t.tool),
  })[tool]!;

  static Map<String, CommandInfo> get commands =>
      _commands ??= {for (final c in bridge.commands()) c.id: c};

  static String shortcut(String id) => commands[id]?.shortcut ?? '';

  static List<FilterInfo> get adjustments =>
      _adjustments ??= bridge.adjustments();

  static List<EffectGroup> get effectMenu => _effects ??= bridge.effectMenu();

  /// The Text tool's fonts, the built-in one first; the core scans the
  /// system's font folders once, on a worker.
  static Future<List<String>> get fonts => _fonts ??= bridge.fontNames();

  /// History steps are named with the core's English names of tools and
  /// commands; this finds what a name belongs to (`tool:paintbrush`,
  /// `command:select_all`), for its words.
  static String? idOfName(String name) => (_names ??= {
    for (final c in commands.values)
      c.label.replaceAll('...', ''): 'command:${c.id}',
    for (final f in adjustments) f.name: 'command:${f.id}',
    for (final f in bridge.effects()) f.name: 'command:${f.id}',
    for (final t in tools) t.name: 'tool:${toolId(t.tool)}',
  })[name];
}
