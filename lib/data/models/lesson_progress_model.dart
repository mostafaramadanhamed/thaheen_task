import '../../domain/entities/lesson_progress.dart';
import 'json_reader.dart';

/// Stored shape of one lesson's progress. The lesson id is the map key
/// in the persisted JSON, so it is not repeated inside the value.
class LessonProgressModel {
  const LessonProgressModel({
    required this.positionSeconds,
    required this.completed,
  });

  factory LessonProgressModel.fromEntity(LessonProgress progress) {
    return LessonProgressModel(
      positionSeconds: progress.positionSeconds,
      completed: progress.completed,
    );
  }

  factory LessonProgressModel.fromJson(JsonMap json) {
    final completed = json[_completedKey];
    return LessonProgressModel(
      positionSeconds: json.requireInt(_positionKey),
      completed: completed is bool && completed,
    );
  }

  static const String _positionKey = 'position';
  static const String _completedKey = 'completed';

  final int positionSeconds;
  final bool completed;

  JsonMap toJson() => {_positionKey: positionSeconds, _completedKey: completed};

  LessonProgress toEntity(String lessonId) => LessonProgress(
    lessonId: lessonId,
    positionSeconds: positionSeconds < 0 ? 0 : positionSeconds,
    completed: completed,
  );
}
