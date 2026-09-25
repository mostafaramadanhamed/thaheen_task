import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/data/local/progress_local_data_source.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';

Future<ProgressRepository> _createRepository([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return ProgressRepository(ProgressLocalDataSource(preferences));
}

void main() {
  test('returns not-started progress for an unknown lesson', () async {
    final repository = await _createRepository();

    expect(
      repository.getProgress('lesson_1'),
      const LessonProgress(lessonId: 'lesson_1'),
    );
  });

  test('persists saved progress across repository instances', () async {
    final repository = await _createRepository();
    final progress = LessonProgress(
      lessonId: 'lesson_1',
      positionSeconds: 42,
      completed: true,
      lastWatchedAt: DateTime(2026, 9, 25, 10, 30),
    );

    await repository.saveProgress(progress);

    final preferences = await SharedPreferences.getInstance();
    final reloaded = ProgressRepository(ProgressLocalDataSource(preferences));
    expect(reloaded.getProgress('lesson_1'), progress);
  });

  test('emits the updated progress map when progress changes', () async {
    final repository = await _createRepository();
    const progress = LessonProgress(lessonId: 'lesson_1', positionSeconds: 5);

    final emitted = repository.changes.first;
    await repository.saveProgress(progress);

    expect(await emitted, {'lesson_1': progress});
  });

  test('ignores corrupt stored progress', () async {
    final repository = await _createRepository({
      StorageKeys.lessonProgress: '{broken',
    });

    expect(repository.getAll(), isEmpty);
  });

  test('skips invalid entries but keeps valid ones', () async {
    final repository = await _createRepository({
      StorageKeys.lessonProgress:
          '{"lesson_1": {"position": 10, "completed": false},'
          ' "lesson_2": {"position": "oops"}}',
    });

    expect(repository.getAll().keys, ['lesson_1']);
  });
}
