import '../entities/course.dart';
import '../entities/lesson_progress.dart';

/// Returns [completedLessons] / [totalLessons] as a value from 0.0 to 1.0.
/// A course without lessons has 0.0 progress.
double calculateProgress({
  required int completedLessons,
  required int totalLessons,
}) {
  if (totalLessons <= 0) return 0;
  return (completedLessons / totalLessons).clamp(0.0, 1.0);
}

int countCompletedLessons(Course course, Map<String, LessonProgress> progress) {
  return course.lessons
      .where((lesson) => progress[lesson.id]?.completed ?? false)
      .length;
}

double calculateCourseProgress(
  Course course,
  Map<String, LessonProgress> progress,
) {
  return calculateProgress(
    completedLessons: countCompletedLessons(course, progress),
    totalLessons: course.lessonCount,
  );
}
