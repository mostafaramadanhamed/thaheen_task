import '../../domain/entities/lesson.dart';
import 'json_reader.dart';
import 'localized_text_model.dart';

class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.videoPath,
  });

  factory LessonModel.fromJson(JsonMap json) {
    final durationSeconds = json.requireInt('durationSeconds');
    if (durationSeconds < 0) {
      throw FormatException('Negative lesson duration', durationSeconds);
    }

    return LessonModel(
      id: json.requireString('id'),
      title: LocalizedTextModel.fromJson(json.requireMap('title')),
      durationSeconds: durationSeconds,
      videoPath: json.requireString('videoPath'),
    );
  }

  final String id;
  final LocalizedTextModel title;
  final int durationSeconds;
  final String videoPath;

  Lesson toEntity() => Lesson(
    id: id,
    title: title.toEntity(),
    durationSeconds: durationSeconds,
    videoPath: videoPath,
  );
}
