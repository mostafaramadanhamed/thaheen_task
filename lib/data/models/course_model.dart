import '../../domain/entities/course.dart';
import 'json_reader.dart';
import 'localized_text_model.dart';
import 'section_model.dart';

class CourseModel {
  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailPath,
    required this.sections,
  });

  factory CourseModel.fromJson(JsonMap json) {
    return CourseModel(
      id: json.requireString('id'),
      title: LocalizedTextModel.fromJson(json.requireMap('title')),
      description: LocalizedTextModel.fromJson(json.requireMap('description')),
      instructor: LocalizedTextModel.fromJson(json.requireMap('instructor')),
      thumbnailPath: json.requireString('thumbnail'),
      sections: json
          .requireMapList('sections')
          .map(SectionModel.fromJson)
          .toList(),
    );
  }

  final String id;
  final LocalizedTextModel title;
  final LocalizedTextModel description;
  final LocalizedTextModel instructor;
  final String thumbnailPath;
  final List<SectionModel> sections;

  Course toEntity() => Course(
    id: id,
    title: title.toEntity(),
    description: description.toEntity(),
    instructor: instructor.toEntity(),
    thumbnailPath: thumbnailPath,
    sections: sections.map((section) => section.toEntity()).toList(),
  );
}
