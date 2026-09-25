import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../models/json_reader.dart';
import '../models/lesson_progress_model.dart';

/// Stores all lesson progress as one JSON object under a single key:
/// `{ "<lessonId>": { "position": 125, "completed": false } }`.
class ProgressLocalDataSource {
  const ProgressLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  /// Returns stored progress keyed by lesson id. Corrupt data is logged
  /// and skipped so that a bad entry never blocks the app.
  Map<String, LessonProgressModel> readAll() {
    final raw = _preferences.getString(StorageKeys.lessonProgress);
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! JsonMap) return {};
      return {
        for (final entry in decoded.entries) entry.key: ?_tryParse(entry),
      };
    } on FormatException catch (error) {
      log(
        'Discarding unreadable progress data',
        name: 'Progress',
        error: error,
      );
      return {};
    }
  }

  Future<void> writeAll(Map<String, LessonProgressModel> progress) async {
    final encoded = jsonEncode({
      for (final entry in progress.entries) entry.key: entry.value.toJson(),
    });
    await _preferences.setString(StorageKeys.lessonProgress, encoded);
  }

  LessonProgressModel? _tryParse(MapEntry<String, dynamic> entry) {
    final value = entry.value;
    if (value is! JsonMap) return null;
    try {
      return LessonProgressModel.fromJson(value);
    } on FormatException catch (error) {
      log(
        'Skipping progress for "${entry.key}"',
        name: 'Progress',
        error: error,
      );
      return null;
    }
  }
}
