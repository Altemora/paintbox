import 'dart:async';

import 'package:core/core.dart';
import 'package:paint_bridge/paint_bridge.dart';
import 'package:paint_logic/src/data/storage/app_settings_json_mapper.dart';
import 'package:paint_logic/src/data/storage/settings_storage.dart';
import 'package:paint_logic/src/models/app_settings.dart';

/// The program's settings: read once at start, kept in memory, written
/// shortly after a change (a later change replaces a write still
/// waiting). Without storage (tests, screenshots) nothing is written.
class SettingsRepository {
  SettingsRepository(
    this._storage, {
    this._delay = const Duration(milliseconds: 400),
  });

  final SettingsStorage? _storage;
  final Duration _delay;
  AppSettings? _settings;
  Timer? _pending;

  static AppSettings defaults() => AppSettings(
    tool: Tool.paintbrush,
    toolSettings: defaultToolSettings(),
    jpegQuality: defaultJpegQuality(),
  );

  AppSettings getSettingsSync() => _settings ??= defaults();

  /// Reads the file; a missing or broken one gives the defaults (a broken
  /// one is logged).
  Future<AppSettings> load() async {
    final storage = _storage;
    if (storage == null) {
      return getSettingsSync();
    }
    var settings = defaults();
    try {
      final json = await storage.read();
      if (json != null) {
        settings = AppSettingsJsonMapper.decode(json, settings);
      }
    } on Failure catch (failure) {
      AppLog.failure(failure, where: 'SettingsRepository.load');
    }
    return _settings = settings;
  }

  void update(AppSettings settings) {
    if (settings == _settings) {
      return;
    }
    _settings = settings;
    if (_storage == null) {
      return;
    }
    _pending?.cancel();
    _pending = Timer(_delay, () => unawaited(flush()));
  }

  /// Writes what waits now (on exit).
  Future<void> flush() async {
    _pending?.cancel();
    _pending = null;
    final storage = _storage;
    final settings = _settings;
    if (storage == null || settings == null) {
      return;
    }
    try {
      await storage.write(AppSettingsJsonMapper.encode(settings));
    } on Failure catch (failure) {
      AppLog.failure(failure, where: 'SettingsRepository.flush');
    }
  }
}
