import '../entities/course.dart';
import '../entities/lesson_progress.dart';
import '../entities/lesson_status.dart';
import 'unlock_rule.dart';

/// Derives a lesson's display status from its progress and the unlock rule.
/// A completed lesson stays completed even if an earlier lesson changes.
LessonStatus resolveLessonStatus({
  required Course course,
  required String lessonId,
  required Map<String, LessonProgress> progress,
}) {
  final lessonProgress = progress[lessonId];
  if (lessonProgress?.completed ?? false) return LessonStatus.completed;

  final unlocked = isLessonUnlocked(
    course: course,
    lessonId: lessonId,
    progress: progress,
  );
  if (!unlocked) return LessonStatus.locked;

  final started = (lessonProgress?.positionSeconds ?? 0) > 0;
  return started ? LessonStatus.inProgress : LessonStatus.notStarted;
}
