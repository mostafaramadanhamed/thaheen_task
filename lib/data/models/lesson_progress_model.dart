import '../../domain/entities/lesson_progress.dart';
import 'json_reader.dart';

/// Stored shape of one lesson's progress. The lesson id is the map key
/// in the persisted JSON, so it is not repeated inside the value.
class LessonProgressModel {
  const LessonProgressModel({
    required this.positionSeconds,
    required this.completed,
    this.lastWatchedAtMillis,
  });

  factory LessonProgressModel.fromEntity(LessonProgress progress) {
    return LessonProgressModel(
      positionSeconds: progress.positionSeconds,
      completed: progress.completed,
      lastWatchedAtMillis: progress.lastWatchedAt?.millisecondsSinceEpoch,
    );
  }

  factory LessonProgressModel.fromJson(JsonMap json) {
    final completed = json[_completedKey];
    final lastWatchedAt = json[_lastWatchedAtKey];
    return LessonProgressModel(
      positionSeconds: json.requireInt(_positionKey),
      completed: completed is bool && completed,
      lastWatchedAtMillis: lastWatchedAt is int ? lastWatchedAt : null,
    );
  }

  static const String _positionKey = 'position';
  static const String _completedKey = 'completed';
  static const String _lastWatchedAtKey = 'lastWatchedAt';

  final int positionSeconds;
  final bool completed;
  final int? lastWatchedAtMillis;

  JsonMap toJson() => {
    _positionKey: positionSeconds,
    _completedKey: completed,
    _lastWatchedAtKey: ?lastWatchedAtMillis,
  };

  LessonProgress toEntity(String lessonId) {
    final lastWatchedAtMillis = this.lastWatchedAtMillis;
    return LessonProgress(
      lessonId: lessonId,
      positionSeconds: positionSeconds < 0 ? 0 : positionSeconds,
      completed: completed,
      lastWatchedAt: lastWatchedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastWatchedAtMillis),
    );
  }
}
