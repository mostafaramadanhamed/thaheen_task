import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';
import '../models/json_reader.dart';

/// Stores all lesson notes as one JSON object: `{ "<lessonId>": "text" }`.
class NotesLocalDataSource {
  const NotesLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  /// Returns stored notes keyed by lesson id. Unreadable data is logged and
  /// ignored so a bad entry never blocks the player.
  Map<String, String> readAll() {
    final raw = _preferences.getString(StorageKeys.lessonNotes);
    if (raw == null) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! JsonMap) return {};
      return {
        for (final entry in decoded.entries)
          if (entry.value case final String text) entry.key: text,
      };
    } on FormatException catch (error) {
      log('Discarding unreadable notes', name: 'Notes', error: error);
      return {};
    }
  }

  Future<void> writeAll(Map<String, String> notes) async {
    await _preferences.setString(StorageKeys.lessonNotes, jsonEncode(notes));
  }
}
