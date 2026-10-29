import 'package:app_ui/src/theme/app_tokens.dart';
import 'package:app_ui/src/theme/icon_hues.dart';
import 'package:flutter/material.dart';

/// The app's theme: dark first, translucent surfaces over an ambient
/// background, one typeface (Manrope), a dense desktop scale.
///
/// Material widgets are themed to disappear: no tonal elevation, no
/// surface tint, transparent scaffolds. Surfaces come from `GlassPanel`
/// and the tokens in [AppTokens].
abstract final class AppTheme {
  static const Color seed = Color(0xFF5B8DEF);
  static const _sans = 'Manrope';

  static ThemeData dark() => _base(_scheme(Brightness.dark));

  static ThemeData light() => _base(_scheme(Brightness.light));

  /// Deep, slightly cool neutrals for dark; warm paper for light. The
  /// seed drives only the accent roles.
  static ColorScheme _scheme(Brightness brightness) {
    final seeded = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    );
    if (brightness == Brightness.dark) {
      return seeded.copyWith(
        primary: Color.lerp(seed, Colors.white, 0.12),
        onPrimary: const Color(0xFF0F1117),
        surface: const Color(0xFF0E0D10),
        onSurface: const Color(0xFFF1EEEA),
        onSurfaceVariant: const Color(0xFFA9A39D),
        surfaceContainerLowest: const Color(0xFF0A090B),
        surfaceContainerLow: const Color(0xFF131216),
        surfaceContainer: const Color(0xFF18171C),
        surfaceContainerHigh: const Color(0xFF1E1D23),
        surfaceContainerHighest: const Color(0xFF26252B),
        outline: const Color(0xFF4A4750),
        outlineVariant: const Color(0xFF2E2C33),
      );
    }
    return seeded.copyWith(
      primary: Color.lerp(seed, Colors.black, 0.1),
      surface: const Color(0xFFF6F3EF),
      onSurface: const Color(0xFF1B1917),
      onSurfaceVariant: const Color(0xFF5E5852),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFFBF9F6),
      surfaceContainer: const Color(0xFFF1EDE8),
      surfaceContainerHigh: const Color(0xFFEAE5DF),
      surfaceContainerHighest: const Color(0xFFE2DCD5),
      outline: const Color(0xFFB9B1A8),
      outlineVariant: const Color(0xFFDDD6CE),
    );
  }

  static TextStyle _face(
    TextStyle? base, {
    required double size,
    FontWeight weight = FontWeight.w400,
    double? letterSpacing,
    double? height,
  }) => (base ?? const TextStyle()).copyWith(
    fontFamily: _sans,
    fontSize: size,
    fontWeight: weight,
    fontVariations: [FontVariation('wght', weight.value.toDouble())],
    letterSpacing: letterSpacing,
    height: height,
  );

  /// One family, a tight scale for a dense editor: titles at 600 with
  /// slightly negative tracking, body at 400.
  static TextTheme _typography(TextTheme base) => TextTheme(
    headlineSmall: _face(
      base.headlineSmall,
      size: 19,
      weight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    titleLarge: _face(
      base.titleLarge,
      size: 17,
      weight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
    ),
    titleMedium: _face(
      base.titleMedium,
      size: 14,
      weight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.3,
    ),
    titleSmall: _face(
      base.titleSmall,
      size: 13,
      weight: FontWeight.w600,
      height: 1.3,
    ),
    bodyLarge: _face(base.bodyLarge, size: 14, height: 1.45),
    bodyMedium: _face(base.bodyMedium, size: 13, height: 1.4),
    bodySmall: _face(base.bodySmall, size: 12, height: 1.35),
    labelLarge: _face(
      base.labelLarge,
      size: 13,
      weight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    labelMedium: _face(
      base.labelMedium,
      size: 12,
      weight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelSmall: _face(
      base.labelSmall,
      size: 11,
      weight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme);
    final text = _typography(base.textTheme)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
    final isDark = scheme.brightness == Brightness.dark;
    final tokens = isDark ? AppTokens.dark(scheme) : AppTokens.light(scheme);
    final popover = isDark ? const Color(0xFF1E1D23) : const Color(0xFFFFFFFF);
    // Buttons keep the small radius of every control: room is dear.
    final pill = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.xxs),
    );
    final small = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Radii.xxs),
    );
    OutlineInputBorder field(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.xxs),
          borderSide: BorderSide(color: color, width: width),
        );
    return base.copyWith(
      extensions: [tokens, if (isDark) IconHues.dark() else IconHues.light()],
      textTheme: text,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      dividerColor: tokens.hairline,
      hoverColor: tokens.glassHover,
      focusColor: tokens.accentSoft,
      highlightColor: tokens.glass,
      splashColor: tokens.glassHover,
      splashFactory: InkRipple.splashFactory,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 18),
      dividerTheme: DividerThemeData(
        color: tokens.hairline,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: tokens.glass,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.xs,
          vertical: Space.xs,
        ),
        hintStyle: text.bodySmall?.copyWith(color: tokens.muted),
        labelStyle: text.bodySmall?.copyWith(color: tokens.muted),
        border: field(tokens.hairline),
        enabledBorder: field(tokens.hairline),
        focusedBorder: field(scheme.primary.withValues(alpha: 0.7), 1.2),
        errorBorder: field(tokens.danger),
        focusedErrorBorder: field(tokens.danger, 1.2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1A191E)
            : const Color(0xFFFBF9F6),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          side: BorderSide(color: tokens.hairlineStrong),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(popover),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          shadowColor: WidgetStatePropertyAll<Color>(tokens.shadow),
          elevation: const WidgetStatePropertyAll<double>(8),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.all(Space.xxs),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.xs),
              side: BorderSide(color: tokens.hairlineStrong),
            ),
          ),
        ),
      ),
      menuBarTheme: MenuBarThemeData(
        style: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          surfaceTintColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          elevation: const WidgetStatePropertyAll<double>(0),
          padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
          shape: WidgetStatePropertyAll<OutlinedBorder>(small),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll<TextStyle?>(text.bodyMedium),
          // A menu bar item is as tall as an icon button: the bar reads as
          // one row with the buttons in its corner.
          minimumSize: const WidgetStatePropertyAll<Size>(
            Size(0, ControlSize.button),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: Space.xs),
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(small),
          overlayColor: WidgetStatePropertyAll<Color>(tokens.glassHover),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 450),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xs,
          vertical: Space.xxs,
        ),
        textStyle: text.bodySmall?.copyWith(color: Colors.white),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2724).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(Radii.xs),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: scheme.primary,
        inactiveTrackColor: tokens.hairlineStrong,
        thumbColor: scheme.primary,
        overlayColor: tokens.accentSoft,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      checkboxTheme: CheckboxThemeData(
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: tokens.hairlineStrong, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Space.xxs),
        ),
      ),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll<Color>(tokens.hairline),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelMedium),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: tokens.hairlineStrong),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? tokens.accentSoft
                : tokens.glass,
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(pill),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: text.labelLarge,
          shape: pill,
          elevation: 0,
          minimumSize: const Size(72, 28),
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: text.labelLarge,
          shape: pill,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: tokens.hairlineStrong),
          minimumSize: const Size(72, 28),
          padding: const EdgeInsets.symmetric(horizontal: Space.md),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: text.labelLarge,
          shape: pill,
          foregroundColor: scheme.onSurface,
          minimumSize: const Size(56, 28),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: const WidgetStatePropertyAll<double>(6),
        radius: const Radius.circular(Radii.pill),
        thumbColor: WidgetStatePropertyAll<Color>(tokens.hairlineStrong),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: tokens.hairline,
      ),
    );
  }
}
