import 'dart:ui' show lerpDouble;

import 'package:app_ui/src/theme/accent_palette.dart';
import 'package:flutter/material.dart';

/// Spacing scale, in logical pixels. Distances come from here and nowhere
/// else.
abstract final class Space {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radii, a common glass-UI scale with one smaller step. The
/// editor keeps them small to save room: buttons, rows and fields
/// [xxs], floating windows and menus [xs], dialogs [sm]; the larger steps
/// are for pills only. A nested element's radius is at most its
/// parent's minus the gap between them.
abstract final class Radii {
  static const double xxs = 6;
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

/// Motion: transitions 160 - 220 ms, easing out.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Curve curve = Curves.easeOutCubic;
}

/// Sizes of the editor's dense controls, which the spacing scale does not
/// cover: a desktop tool bar is denser than a chat.
abstract final class ControlSize {
  /// Tool buttons, icon buttons of panels and the tool bar.
  static const double button = 28;
  static const double icon = 16;

  /// The tool bar's setting pictures, drawn and Material alike: a little
  /// larger than [icon], their details being finer.
  static const double settingIcon = 18;

  /// Rows of the History and Layers windows.
  static const double row = 30;

  /// Height of the menu bar, the tool bar and the status bar.
  static const double bar = 32;
  static const double statusBar = 26;

  /// The rulers along the canvas.
  static const double ruler = 18;

  /// A swatch of the palette.
  static const double swatch = 13;

  /// Fields, steppers and chips of the tool bar and the windows.
  static const double field = 24;
}

/// Design tokens that Material's [ColorScheme] has no role for: the glass
/// surfaces, hairlines and glows of the app's look, and the canvas's
/// surroundings.
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.glass,
    required this.glassStrong,
    required this.glassHover,
    required this.hairline,
    required this.hairlineStrong,
    required this.glow,
    required this.shadow,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.muted,
    required this.blur,
    required this.workspace,
    required this.checkerLight,
    required this.checkerDark,
    required this.ants,
    required this.antsDash,
    required this.handle,
  });

  factory AppTokens.dark(ColorScheme scheme) => AppTokens(
    glass: Colors.white.withValues(alpha: 0.045),
    glassStrong: Colors.white.withValues(alpha: 0.08),
    glassHover: Colors.white.withValues(alpha: 0.11),
    hairline: Colors.white.withValues(alpha: 0.08),
    hairlineStrong: Colors.white.withValues(alpha: 0.16),
    glow: scheme.primary.withValues(alpha: 0.28),
    shadow: Colors.black.withValues(alpha: 0.45),
    accentSoft: scheme.primary.withValues(alpha: 0.16),
    onAccentSoft: AccentPalette.readable(
      Color.lerp(scheme.primary, Colors.white, 0.35)!,
      scheme.surface,
      4.5,
    ),
    success: const Color(0xFF5BD39B),
    warning: const Color(0xFFF2B65B),
    danger: const Color(0xFFF26B6B),
    muted: scheme.onSurface.withValues(alpha: 0.55),
    blur: 24,
    workspace: const Color(0xFF131216),
    checkerLight: const Color(0xFFFFFFFF),
    checkerDark: const Color(0xFFCCCCCC),
    ants: Colors.black,
    antsDash: Colors.white,
    handle: scheme.primary,
  );

  factory AppTokens.light(ColorScheme scheme) => AppTokens(
    glass: Colors.white.withValues(alpha: 0.55),
    glassStrong: Colors.white.withValues(alpha: 0.72),
    glassHover: Colors.white.withValues(alpha: 0.86),
    // Stronger than dark's: a black line on paper fades sooner than a
    // white one on night.
    hairline: Colors.black.withValues(alpha: 0.1),
    hairlineStrong: Colors.black.withValues(alpha: 0.18),
    glow: scheme.primary.withValues(alpha: 0.22),
    shadow: Colors.black.withValues(alpha: 0.12),
    accentSoft: scheme.primary.withValues(alpha: 0.12),
    onAccentSoft: AccentPalette.readable(
      Color.lerp(scheme.primary, Colors.black, 0.25)!,
      scheme.surface,
      4.5,
    ),
    success: const Color(0xFF1F9D62),
    warning: const Color(0xFFB7791F),
    danger: const Color(0xFFC84B4B),
    muted: scheme.onSurface.withValues(alpha: 0.64),
    blur: 24,
    workspace: const Color(0xFFDCD7D1),
    checkerLight: const Color(0xFFFFFFFF),
    checkerDark: const Color(0xFFCCCCCC),
    ants: Colors.black,
    antsDash: Colors.white,
    handle: scheme.primary,
  );

  /// Default translucent fill of a panel or card.
  final Color glass;

  /// Fill for what must read as "in front": dialogs, menus, popovers.
  final Color glassStrong;

  /// Fill for a hovered row or button.
  final Color glassHover;

  /// One-pixel border that separates glass from glass.
  final Color hairline;
  final Color hairlineStrong;

  /// Accent-coloured soft light behind the one active element.
  final Color glow;

  /// Drop shadow for floating panels.
  final Color shadow;

  /// Accent at low alpha: selected rows, the active tool.
  final Color accentSoft;
  final Color onAccentSoft;

  final Color success;
  final Color warning;
  final Color danger;

  /// Secondary text.
  final Color muted;

  /// Backdrop blur sigma for glass over moving content.
  final double blur;

  /// Around the image: a quiet grey, so the picture's colours read true.
  final Color workspace;

  /// The transparency checkerboard.
  final Color checkerLight;
  final Color checkerDark;

  /// The marching ants' two dashes.
  final Color ants;
  final Color antsDash;

  /// Handles of a live gradient, curve or moved selection.
  final Color handle;

  @override
  AppTokens copyWith({
    Color? glass,
    Color? glassStrong,
    Color? glassHover,
    Color? hairline,
    Color? hairlineStrong,
    Color? glow,
    Color? shadow,
    Color? accentSoft,
    Color? onAccentSoft,
    Color? success,
    Color? warning,
    Color? danger,
    Color? muted,
    double? blur,
    Color? workspace,
    Color? checkerLight,
    Color? checkerDark,
    Color? ants,
    Color? antsDash,
    Color? handle,
  }) => AppTokens(
    glass: glass ?? this.glass,
    glassStrong: glassStrong ?? this.glassStrong,
    glassHover: glassHover ?? this.glassHover,
    hairline: hairline ?? this.hairline,
    hairlineStrong: hairlineStrong ?? this.hairlineStrong,
    glow: glow ?? this.glow,
    shadow: shadow ?? this.shadow,
    accentSoft: accentSoft ?? this.accentSoft,
    onAccentSoft: onAccentSoft ?? this.onAccentSoft,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    muted: muted ?? this.muted,
    blur: blur ?? this.blur,
    workspace: workspace ?? this.workspace,
    checkerLight: checkerLight ?? this.checkerLight,
    checkerDark: checkerDark ?? this.checkerDark,
    ants: ants ?? this.ants,
    antsDash: antsDash ?? this.antsDash,
    handle: handle ?? this.handle,
  );

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      glass: c(glass, other.glass),
      glassStrong: c(glassStrong, other.glassStrong),
      glassHover: c(glassHover, other.glassHover),
      hairline: c(hairline, other.hairline),
      hairlineStrong: c(hairlineStrong, other.hairlineStrong),
      glow: c(glow, other.glow),
      shadow: c(shadow, other.shadow),
      accentSoft: c(accentSoft, other.accentSoft),
      onAccentSoft: c(onAccentSoft, other.onAccentSoft),
      success: c(success, other.success),
      warning: c(warning, other.warning),
      danger: c(danger, other.danger),
      muted: c(muted, other.muted),
      blur: lerpDouble(blur, other.blur, t)!,
      workspace: c(workspace, other.workspace),
      checkerLight: c(checkerLight, other.checkerLight),
      checkerDark: c(checkerDark, other.checkerDark),
      ants: c(ants, other.ants),
      antsDash: c(antsDash, other.antsDash),
      handle: c(handle, other.handle),
    );
  }
}

extension AppTokensContext on BuildContext {
  /// Never null in practice: every [ThemeData] of the app registers one.
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
