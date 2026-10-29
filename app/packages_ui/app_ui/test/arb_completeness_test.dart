import 'dart:convert';
import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every translation carries every message of the English template, with
/// the same placeholders and the same choices of its select messages, so
/// no word of the interface falls back to another language unnoticed.
void main() {
  final folder = Directory('lib/src/localization/arb');
  Map<String, Object?> read(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  final template = read(File('${folder.path}/app_en.arb'));
  final keys = template.keys.where((k) => !k.startsWith('@')).toList();
  final placeholder = RegExp(r'\{(\w+)\}');
  final choice = RegExp(r'(\w+)\{');

  Set<String> placeholders(String text) =>
      placeholder.allMatches(text).map((m) => m[1]!).toSet();

  /// The choices of a `{x, select, a{…} b{…}}` message, nothing otherwise.
  Set<String> choices(String text) => text.contains(', select,')
      ? choice.allMatches(text).map((m) => m[1]!).toSet()
      : const {};

  final files = folder
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList();

  test('every supported language has its file', () {
    final codes = {
      for (final f in files)
        f.uri.pathSegments.last.replaceAll('app_', '').replaceAll('.arb', ''),
    };
    expect(codes, AppLanguages.names.keys.toSet());
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      codes,
    );
  });

  for (final file in files) {
    final name = file.uri.pathSegments.last;
    test('$name has every message of the template', () {
      final arb = read(file);
      expect(
        arb.keys.where((k) => !k.startsWith('@')).toList(),
        keys,
        reason: 'the keys and their order',
      );
      for (final key in keys) {
        final source = template[key]! as String;
        final text = arb[key]! as String;
        expect(text.trim(), isNotEmpty, reason: key);
        expect(
          placeholders(text),
          containsAll(
            choices(source).isEmpty ? placeholders(source) : <String>{},
          ),
          reason: '$key keeps its placeholders',
        );
        expect(
          choices(text),
          choices(source),
          reason: '$key keeps its choices',
        );
      }
    });
  }
}
