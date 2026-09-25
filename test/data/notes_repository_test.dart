import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/data/local/notes_local_data_source.dart';
import 'package:thaheen_task/data/repositories/notes_repository.dart';

Future<NotesRepository> _createRepository([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return NotesRepository(NotesLocalDataSource(preferences));
}

void main() {
  test('returns an empty note for a lesson without one', () async {
    final repository = await _createRepository();

    expect(repository.getNote('lesson_1'), '');
  });

  test('persists trimmed notes across repository instances', () async {
    final repository = await _createRepository();

    await repository.saveNote('lesson_1', '  العظام الطويلة  ');

    final preferences = await SharedPreferences.getInstance();
    final reloaded = NotesRepository(NotesLocalDataSource(preferences));
    expect(reloaded.getNote('lesson_1'), 'العظام الطويلة');
  });

  test('saving blank text removes the note', () async {
    final repository = await _createRepository();
    await repository.saveNote('lesson_1', 'note');

    await repository.saveNote('lesson_1', '   ');

    final preferences = await SharedPreferences.getInstance();
    expect(repository.getNote('lesson_1'), '');
    expect(preferences.getString(StorageKeys.lessonNotes), '{}');
  });

  test('ignores corrupt stored notes', () async {
    final repository = await _createRepository({
      StorageKeys.lessonNotes: '{broken',
    });

    expect(repository.getNote('lesson_1'), '');
  });
}
