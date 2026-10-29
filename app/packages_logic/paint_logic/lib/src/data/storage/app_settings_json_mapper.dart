import 'dart:ui';

import 'package:core/core.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/models/app_settings.dart';
import 'package:paint_logic/src/models/panels.dart';

/// The settings file's format. Unknown or missing values fall back to
/// the defaults, so a file from another version still opens; the tool
/// bar's values are kept in range by the core.
abstract final class AppSettingsJsonMapper {
  static AppSettings decode(Map<String, Object?> json, AppSettings defaults) {
    final settings = json['tool_settings'];
    final panels = json['panels'];
    final recent = json['recent_files'];
    final directory = json['last_directory'];
    return AppSettings(
      tool: _enum(Tool.values, json['tool'], defaults.tool),
      toolSettings: settings is Map<String, Object?>
          ? sanitizeToolSettings(
              settings: _settings(settings, defaults.toolSettings),
            )
          : defaults.toolSettings,
      jpegQuality: switch (json['jpeg_quality']) {
        final int q when q >= 1 && q <= 100 => q,
        _ => defaults.jpegQuality,
      },
      recentFiles: recent is List<Object?>
          ? recent.whereType<String>().take(AppSettings.maxRecentFiles).toList()
          : const [],
      panels: panels is Map<String, Object?>
          ? Panels(
              tools: _bool(panels['tools'], true),
              history: _bool(panels['history'], true),
              layers: _bool(panels['layers'], true),
              colors: _bool(panels['colors'], true),
              colorsMore: _bool(panels['colors_more'], true),
              places: _places(panels['places']),
            )
          : const Panels(),
      theme: _enum(ThemeChoice.values, json['theme'], defaults.theme),
      accent: _enum(AccentChoice.values, json['accent'], defaults.accent),
      customAccent: switch (json['custom_accent']) {
        final int argb when argb >= 0 && argb <= 0xFFFFFFFF =>
          argb | 0xFF000000,
        _ => defaults.customAccent,
      },
      language: switch (json['language']) {
        final String code when code.isNotEmpty => code,
        _ => null,
      },
      lastDirectory: directory is String ? directory : null,
      rulers: _bool(json['rulers'], true),
    );
  }

  static Map<String, Object?> encode(AppSettings settings) {
    final t = settings.toolSettings;
    return {
      'tool': settings.tool.name,
      'tool_settings': {
        'width': t.width,
        'antialias': t.antialias,
        'alpha_blending': t.alphaBlending,
        'hardness': t.hardness,
        'tolerance': t.tolerance,
        'flood_mode': t.floodMode.name,
        'selection_mode': t.selectionMode.name,
        'select_draw': t.selectDraw.name,
        'fixed': [t.fixed.$1, t.fixed.$2],
        'resampling': t.resampling.name,
        'gradient': t.gradient.name,
        'gradient_transparency': t.gradientTransparency,
        'shape_draw': t.shapeDraw.name,
        'picker_after': t.pickerAfter.name,
        'line_start': t.lineStart.name,
        'line_end': t.lineEnd.name,
        'dash': t.dash.name,
        'font': t.font,
        'font_size': t.fontSize,
        'bold': t.bold,
        'italic': t.italic,
        'underline': t.underline,
        'strikeout': t.strikeout,
        'text_align': t.textAlign.name,
      },
      'jpeg_quality': settings.jpegQuality,
      'recent_files': settings.recentFiles,
      'panels': {
        'tools': settings.panels.tools,
        'history': settings.panels.history,
        'layers': settings.panels.layers,
        'colors': settings.panels.colors,
        'colors_more': settings.panels.colorsMore,
        'places': {
          for (final MapEntry(:key, :value) in settings.panels.places.entries)
            key: [value.dx, value.dy],
        },
      },
      'theme': settings.theme.name,
      'accent': settings.accent.name,
      'custom_accent': settings.customAccent,
      'language': settings.language,
      'last_directory': settings.lastDirectory,
      'rulers': settings.rulers,
    };
  }

  /// `{"tools": [dx, dy]}`; a broken entry is the window's corner.
  static Map<String, Offset> _places(Object? json) {
    if (json is! Map<String, Object?>) {
      return const {};
    }
    return {
      for (final MapEntry(:key, :value) in json.entries)
        if (value case [final num dx, final num dy]
            when dx.isFinite && dy.isFinite)
          key: Offset(dx.toDouble(), dy.toDouble()),
    };
  }

  static ToolSettings _settings(Map<String, Object?> j, ToolSettings d) {
    final fixed = j['fixed'];
    return ToolSettings(
      width: _double(j['width'], d.width),
      antialias: _bool(j['antialias'], d.antialias),
      alphaBlending: _bool(j['alpha_blending'], d.alphaBlending),
      hardness: _double(j['hardness'], d.hardness),
      tolerance: _double(j['tolerance'], d.tolerance),
      floodMode: _enum(FloodMode.values, j['flood_mode'], d.floodMode),
      selectionMode: _enum(
        CombineMode.values,
        j['selection_mode'],
        d.selectionMode,
      ),
      selectDraw: _enum(SelectDraw.values, j['select_draw'], d.selectDraw),
      fixed: fixed is List<Object?> && fixed.length == 2
          ? (_double(fixed[0], d.fixed.$1), _double(fixed[1], d.fixed.$2))
          : d.fixed,
      resampling: _enum(Resampling.values, j['resampling'], d.resampling),
      gradient: _enum(GradientKind.values, j['gradient'], d.gradient),
      gradientTransparency: _bool(
        j['gradient_transparency'],
        d.gradientTransparency,
      ),
      shapeDraw: _enum(ShapeDraw.values, j['shape_draw'], d.shapeDraw),
      pickerAfter: _enum(PickerAfter.values, j['picker_after'], d.pickerAfter),
      lineStart: _enum(LineCap.values, j['line_start'], d.lineStart),
      lineEnd: _enum(LineCap.values, j['line_end'], d.lineEnd),
      dash: _enum(DashStyle.values, j['dash'], d.dash),
      font: j['font'] is String ? j['font']! as String : d.font,
      fontSize: _double(j['font_size'], d.fontSize),
      bold: _bool(j['bold'], d.bold),
      italic: _bool(j['italic'], d.italic),
      underline: _bool(j['underline'], d.underline),
      strikeout: _bool(j['strikeout'], d.strikeout),
      textAlign: _enum(PaintTextAlign.values, j['text_align'], d.textAlign),
    );
  }

  static T _enum<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    if (name != null) {
      AppLog.warn(
        'unknown setting value $name',
        where: 'AppSettingsJsonMapper',
      );
    }
    return fallback;
  }

  static bool _bool(Object? value, bool fallback) =>
      value is bool ? value : fallback;

  static double _double(Object? value, double fallback) =>
      value is num ? value.toDouble() : fallback;
}
