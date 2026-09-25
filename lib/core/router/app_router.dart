import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/course_details/cubit/course_details_cubit.dart';
import '../../features/course_details/screens/course_details_screen.dart';
import '../../features/courses/cubit/courses_cubit.dart';
import '../../features/courses/screens/courses_screen.dart';
import '../../features/lesson_player/cubit/lesson_player_cubit.dart';
import '../../features/lesson_player/screens/lesson_player_screen.dart';
import '../extensions/context_extensions.dart';
import '../widgets/app_error_view.dart';
import 'route_names.dart';

/// Route tree:
///
/// ```text
/// /                                         Courses
/// /courses/:courseId                        Course details
/// /courses/:courseId/lessons/:lessonId      Lesson player
/// ```
///
/// Nesting gives every deep link a natural back stack, e.g. the player
/// always returns to its course details.
abstract final class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      errorBuilder: (context, state) => const _NotFoundScreen(),
      routes: [
        GoRoute(
          path: '/',
          name: RouteNames.courses,
          builder: (context, state) => BlocProvider(
            create: (context) => CoursesCubit(
              courseRepository: context.read(),
              progressRepository: context.read(),
            )..loadCourses(),
            child: const CoursesScreen(),
          ),
          routes: [
            GoRoute(
              path: 'courses/:${RouteParams.courseId}',
              name: RouteNames.courseDetails,
              pageBuilder: (context, state) => _page(
                state,
                BlocProvider(
                  create: (context) => CourseDetailsCubit(
                    courseId: state.pathParameters[RouteParams.courseId]!,
                    courseRepository: context.read(),
                    progressRepository: context.read(),
                  )..loadCourse(),
                  child: const CourseDetailsScreen(),
                ),
              ),
              routes: [
                GoRoute(
                  path: 'lessons/:${RouteParams.lessonId}',
                  name: RouteNames.lessonPlayer,
                  pageBuilder: (context, state) => _page(
                    state,
                    BlocProvider(
                      create: (context) => LessonPlayerCubit(
                        courseId: state.pathParameters[RouteParams.courseId]!,
                        lessonId: state.pathParameters[RouteParams.lessonId]!,
                        courseRepository: context.read(),
                        progressRepository: context.read(),
                      )..initialize(),
                      child: const LessonPlayerScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// go_router keys pages by route pattern by default, so moving between
  /// two lessons would reuse the page and keep the previous lesson's cubit.
  /// Keying by the actual location gives each lesson its own page.
  static MaterialPage<void> _page(GoRouterState state, Widget child) {
    return MaterialPage<void>(
      key: ValueKey<String>(state.matchedLocation),
      child: child,
    );
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
