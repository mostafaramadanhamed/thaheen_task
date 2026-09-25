import 'package:thaheen_task/domain/entities/course.dart';
import 'package:thaheen_task/domain/entities/lesson.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/domain/entities/localized_text.dart';
import 'package:thaheen_task/domain/entities/section.dart';

LocalizedText text(String value, [String? ar]) =>
    LocalizedText(ar: ar ?? value, en: value);

Lesson buildLesson(String id) => Lesson(
  id: id,
  title: text(id),
  durationSeconds: 100,
  videoPath: 'assets/videos/$id.mp4',
);

/// Builds a course whose sections contain the given lesson ids, e.g.
/// `buildCourse(sections: [['l1', 'l2'], ['l3']])`.
Course buildCourse({
  String id = 'course',
  List<List<String>> sections = const [],
  LocalizedText? title,
  LocalizedText? instructor,
}) {
  return Course(
    id: id,
    title: title ?? text(id),
    description: text('description'),
    instructor: instructor ?? text('instructor'),
    thumbnailPath: 'assets/images/$id.png',
    sections: [
      for (var i = 0; i < sections.length; i++)
        Section(
          id: '${id}_s$i',
          title: text('Section $i'),
          lessons: sections[i].map(buildLesson).toList(),
        ),
    ],
  );
}

Map<String, LessonProgress> completed(Iterable<String> lessonIds) => {
  for (final id in lessonIds) id: LessonProgress(lessonId: id, completed: true),
};
