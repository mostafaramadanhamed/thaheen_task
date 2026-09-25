import 'package:equatable/equatable.dart';

import 'lesson.dart';
import 'localized_text.dart';
import 'section.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.thumbnailPath,
    required this.sections,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final LocalizedText instructor;
  final String thumbnailPath;
  final List<Section> sections;

  /// All lessons in learning order, flattened across sections.
  List<Lesson> get lessons => [
    for (final section in sections) ...section.lessons,
  ];

  int get lessonCount => lessons.length;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructor,
    thumbnailPath,
    sections,
  ];
}
