import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../router/route_names.dart';

/// Screen-level navigation so widgets never deal with routes directly.
extension AppNavigation on BuildContext {
  void goToCourses() => goNamed(RouteNames.courses);

  void goToCourseDetails(String courseId) {
    goNamed(
      RouteNames.courseDetails,
      pathParameters: {RouteParams.courseId: courseId},
    );
  }

  /// Opens a lesson on top of its course details. Going to another lesson
  /// of the same course replaces the current player, so back always
  /// returns to the course.
  void goToLessonPlayer({required String courseId, required String lessonId}) {
    goNamed(
      RouteNames.lessonPlayer,
      pathParameters: {
        RouteParams.courseId: courseId,
        RouteParams.lessonId: lessonId,
      },
    );
  }
}
