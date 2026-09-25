import 'package:flutter/widgets.dart';

import '../router/route_arguments.dart';
import '../router/route_names.dart';

/// Screen-level navigation so widgets never deal with route names directly.
extension AppNavigation on BuildContext {
  void goToCourses() {
    Navigator.of(this).popUntil(
      (route) => route.settings.name == RouteNames.courses || route.isFirst,
    );
  }

  Future<void> goToCourseDetails(String courseId) {
    return Navigator.of(
      this,
    ).pushNamed(RouteNames.courseDetails, arguments: courseId);
  }

  Future<void> goToLessonPlayer({
    required String courseId,
    required String lessonId,
  }) {
    return Navigator.of(this).pushNamed(
      RouteNames.lessonPlayer,
      arguments: LessonPlayerArguments(courseId: courseId, lessonId: lessonId),
    );
  }

  /// Replaces the current player with another lesson, so going back
  /// returns to the course instead of the previous lesson.
  Future<void> replaceWithLessonPlayer({
    required String courseId,
    required String lessonId,
  }) {
    return Navigator.of(this).pushReplacementNamed(
      RouteNames.lessonPlayer,
      arguments: LessonPlayerArguments(courseId: courseId, lessonId: lessonId),
    );
  }
}
