import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:path/path.dart' as p;

/// The settings file: one JSON object in the app's support folder,
/// written whole through a temporary file.
class SettingsStorage {
  SettingsStorage(this.directory);

  final Directory directory;

  File get _file => File(p.join(directory.path, 'settings.json'));

  Future<Map<String, Object?>?> read() async {
    final file = _file;
    try {
      if (!file.existsSync()) {
        return null;
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, Object?>) {
        return decoded;
      }
      throw const InvalidDataFailure(reason: 'settings are not an object');
    } on FormatException catch (error, stackTrace) {
      throw InvalidDataFailure(
        reason: 'settings are not JSON',
        origin: error,
        originStackTrace: stackTrace,
      );
    } on FileSystemException catch (error, stackTrace) {
      throw StorageFailure(
        reason: 'cannot read ${file.path}',
        origin: error,
        originStackTrace: stackTrace,
      );
    }
  }

  Future<void> write(Map<String, Object?> json) async {
    final file = _file;
    final part = File('${file.path}.part');
    try {
      await directory.create(recursive: true);
      await part.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
      await part.rename(file.path);
    } on FileSystemException catch (error, stackTrace) {
      throw StorageFailure(
        reason: 'cannot write ${file.path}',
        origin: error,
        originStackTrace: stackTrace,
      );
    }
  }
}
