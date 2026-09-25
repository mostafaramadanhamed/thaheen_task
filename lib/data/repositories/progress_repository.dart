import 'dart:async';

import '../../domain/entities/lesson_progress.dart';
import '../local/progress_local_data_source.dart';
import '../models/lesson_progress_model.dart';

/// Source of truth for user progress. Keeps an in-memory copy for
/// synchronous reads and notifies listeners whenever progress changes.
class ProgressRepository {
  ProgressRepository(this._dataSource)
    : _progress = {
        for (final entry in _dataSource.readAll().entries)
          entry.key: entry.value.toEntity(entry.key),
      };

  final ProgressLocalDataSource _dataSource;
  final Map<String, LessonProgress> _progress;
  final StreamController<Map<String, LessonProgress>> _changes =
      StreamController.broadcast();

  /// Emits the full progress map after every change.
  Stream<Map<String, LessonProgress>> get changes => _changes.stream;

  Map<String, LessonProgress> getAll() => Map.unmodifiable(_progress);

  /// Returns saved progress, or a not-started entry if none exists.
  LessonProgress getProgress(String lessonId) {
    return _progress[lessonId] ?? LessonProgress(lessonId: lessonId);
  }

  Future<void> saveProgress(LessonProgress progress) async {
    if (_progress[progress.lessonId] == progress) return;

    _progress[progress.lessonId] = progress;
    _changes.add(getAll());
    await _dataSource.writeAll({
      for (final entry in _progress.entries)
        entry.key: LessonProgressModel.fromEntity(entry.value),
    });
  }

  Future<void> dispose() => _changes.close();
}
