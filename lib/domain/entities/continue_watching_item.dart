import 'package:equatable/equatable.dart';

import 'course.dart';
import 'lesson.dart';
import 'lesson_progress.dart';

/// A started but unfinished lesson the user can resume.
class ContinueWatchingItem extends Equatable {
  const ContinueWatchingItem({
    required this.course,
    required this.lesson,
    required this.progress,
  });

  final Course course;
  final Lesson lesson;
  final LessonProgress progress;

  @override
  List<Object?> get props => [course, lesson, progress];
}
