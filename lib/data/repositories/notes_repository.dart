import 'dart:developer';

import '../local/notes_local_data_source.dart';

/// Per-lesson notes with an in-memory copy for synchronous reads.
class NotesRepository {
  NotesRepository(this._dataSource) : _notes = _dataSource.readAll();

  final NotesLocalDataSource _dataSource;
  final Map<String, String> _notes;

  String getNote(String lessonId) => _notes[lessonId] ?? '';

  /// Saves [text] for [lessonId]; blank text removes the note. A failed
  /// write is logged rather than thrown, and the in-memory note is kept.
  Future<void> saveNote(String lessonId, String text) async {
    final trimmed = text.trim();
    if (getNote(lessonId) == trimmed) return;

    if (trimmed.isEmpty) {
      _notes.remove(lessonId);
    } else {
      _notes[lessonId] = trimmed;
    }

    try {
      await _dataSource.writeAll(_notes);
    } on Exception catch (error, stackTrace) {
      log(
        'Failed to persist lesson notes',
        name: 'NotesRepository',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
