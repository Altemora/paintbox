import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const accents = [
    AccentPalette.blue,
    AccentPalette.green,
    AccentPalette.amber,
    AccentPalette.purple,
    AccentPalette.red,
    AccentPalette.gray,
    // Custom colours at the edges: nearly the surface of each theme.
    Color(0xFFFFFF00),
    Color(0xFF101010),
    Color(0xFFF5F2EE),
  ];

  test('every accent reads on both themes', () {
    for (final accent in accents) {
      for (final theme in [
        AppTheme.dark(accent: accent),
        AppTheme.light(accent: accent),
      ]) {
        final scheme = theme.colorScheme;
        final tokens = theme.extension<AppTokens>()!;
        expect(
          AccentPalette.contrast(scheme.primary, scheme.surface),
          greaterThanOrEqualTo(3),
          reason: '$accent on ${scheme.brightness}',
        );
        expect(
          AccentPalette.contrast(tokens.onAccentSoft, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'accent text $accent on ${scheme.brightness}',
        );
        expect(
          AccentPalette.contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(3),
          reason: 'text on $accent on ${scheme.brightness}',
        );
      }
    }
  });

  test('body and muted text read on both surfaces', () {
    for (final theme in [AppTheme.dark(), AppTheme.light()]) {
      final scheme = theme.colorScheme;
      final muted = Color.alphaBlend(
        theme.extension<AppTokens>()!.muted,
        scheme.surface,
      );
      expect(
        AccentPalette.contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(7),
      );
      expect(
        AccentPalette.contrast(muted, scheme.surface),
        greaterThanOrEqualTo(4.5),
        reason: '${scheme.brightness}',
      );
    }
  });
}
