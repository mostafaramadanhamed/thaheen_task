import 'package:flutter/widgets.dart';

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
}
