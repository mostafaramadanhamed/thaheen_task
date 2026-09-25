import '../entities/continue_watching_item.dart';
import '../entities/lesson_progress.dart';
import '../entities/course.dart';

/// Returns the most recently watched lesson that was started but not
/// completed (`position > 0 && !completed`), or `null` if there is none.
/// Ties, including entries without a timestamp, keep catalog order.
ContinueWatchingItem? findContinueWatching(
  List<Course> courses,
  Map<String, LessonProgress> progress,
) {
  ContinueWatchingItem? latest;

  for (final course in courses) {
    for (final lesson in course.lessons) {
      final lessonProgress = progress[lesson.id];
      if (lessonProgress == null || !_isResumable(lessonProgress)) continue;

      if (latest == null ||
          _isMoreRecent(lessonProgress, than: latest.progress)) {
        latest = ContinueWatchingItem(
          course: course,
          lesson: lesson,
          progress: lessonProgress,
        );
      }
    }
  }
  return latest;
}

bool _isResumable(LessonProgress progress) =>
    progress.positionSeconds > 0 && !progress.completed;

bool _isMoreRecent(LessonProgress candidate, {required LessonProgress than}) {
  final candidateTime = candidate.lastWatchedAt;
  final currentTime = than.lastWatchedAt;
  if (candidateTime == null) return false;
  if (currentTime == null) return true;
  return candidateTime.isAfter(currentTime);
}
