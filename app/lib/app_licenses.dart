import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The licenses Flutter does not collect by itself, added to the ones it
/// lists for the Dart packages: the Manrope font and the Rust crates
/// linked into the core (assets/licenses/rust-crates.txt, written by
/// tools/make-notices.ps1).
abstract final class AppLicenses {
  static const _crateSeparator =
      '================================================================';

  static void register() => LicenseRegistry.addLicense(_entries);

  static Stream<LicenseEntry> _entries() async* {
    yield LicenseEntryWithLineBreaks(const [
      'Manrope',
    ], await rootBundle.loadString('assets/fonts/OFL-Manrope.txt'));
    final crates = await rootBundle.loadString(
      'assets/licenses/rust-crates.txt',
    );
    for (final entry in crates.split(_crateSeparator)) {
      final text = entry.trim();
      if (text.isEmpty) {
        continue;
      }
      // The first line is "name version".
      final name = text.split('\n').first.split(' ').first;
      yield LicenseEntryWithLineBreaks([name], text);
    }
  }
}
