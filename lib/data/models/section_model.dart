import '../../domain/entities/section.dart';
import 'json_reader.dart';
import 'lesson_model.dart';
import 'localized_text_model.dart';

class SectionModel {
  const SectionModel({
    required this.id,
    required this.title,
    required this.lessons,
  });

  factory SectionModel.fromJson(JsonMap json) {
    return SectionModel(
      id: json.requireString('id'),
      title: LocalizedTextModel.fromJson(json.requireMap('title')),
      lessons: json
          .requireMapList('lessons')
          .map(LessonModel.fromJson)
          .toList(),
    );
  }

  final String id;
  final LocalizedTextModel title;
  final List<LessonModel> lessons;

  Section toEntity() => Section(
    id: id,
    title: title.toEntity(),
    lessons: lessons.map((lesson) => lesson.toEntity()).toList(),
  );
}
