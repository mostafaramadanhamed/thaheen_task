import '../entities/course.dart';
import '../entities/lesson_progress.dart';

/// The first lesson of a course is always unlocked. Every other lesson is
/// unlocked only when the lesson right before it — in the order flattened
/// across sections — is completed.
///
/// Returns `false` for a lesson that does not belong to [course].
bool isLessonUnlocked({
  required Course course,
  required String lessonId,
  required Map<String, LessonProgress> progress,
}) {
  final lessons = course.lessons;
  final index = lessons.indexWhere((lesson) => lesson.id == lessonId);
  if (index < 0) return false;
  if (index == 0) return true;

  final previousLessonId = lessons[index - 1].id;
  return progress[previousLessonId]?.completed ?? false;
}
