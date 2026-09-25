import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/course_details/cubit/course_details_cubit.dart';
import '../../features/course_details/screens/course_details_screen.dart';
import '../../features/courses/cubit/courses_cubit.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../extensions/context_extensions.dart';
import '../widgets/app_error_view.dart';
import 'route_names.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    return switch (settings.name) {
      RouteNames.courses => _page(
        settings,
        (context) => BlocProvider(
          create: (context) => CoursesCubit(
            courseRepository: context.read(),
            progressRepository: context.read(),
          )..loadCourses(),
          child: const CoursesScreen(),
        ),
      ),
      RouteNames.courseDetails when arguments is String => _page(
        settings,
        (context) => BlocProvider(
          create: (context) => CourseDetailsCubit(
            courseId: arguments,
            courseRepository: context.read(),
            progressRepository: context.read(),
          )..loadCourse(),
          child: const CourseDetailsScreen(),
        ),
      ),
      _ => _page(settings, (context) => const _NotFoundScreen()),
    };
  }

  static MaterialPageRoute<void> _page(
    RouteSettings settings,
    WidgetBuilder builder,
  ) {
    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AppErrorView(title: context.l10n.pageNotFound),
    );
  }
}
