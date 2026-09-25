import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/lesson_status.dart';
import '../cubit/course_details_cubit.dart';
import '../cubit/course_details_state.dart';
import '../widgets/course_header.dart';
import '../widgets/lesson_tile.dart';
import '../widgets/section_header.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) => switch (state) {
          CourseDetailsInitial() ||
          CourseDetailsLoading() => const AppLoadingView(),
          CourseDetailsError() => _ErrorView(failure: state.failure),
          CourseDetailsLoaded() => _CourseDetailsContent(state: state),
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure});

  final CourseDetailsFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return switch (failure) {
      CourseDetailsFailure.notFound => AppErrorView(
        title: l10n.courseNotFoundTitle,
        message: l10n.courseNotFoundMessage,
      ),
      CourseDetailsFailure.loadFailed => AppErrorView(
        title: l10n.courseDetailsErrorTitle,
        message: l10n.coursesErrorMessage,
        onRetry: context.read<CourseDetailsCubit>().loadCourse,
      ),
    };
  }
}

class _CourseDetailsContent extends StatelessWidget {
  const _CourseDetailsContent({required this.state});

  final CourseDetailsLoaded state;

  void _onLessonTap(BuildContext context, Lesson lesson) {
    if (state.statusOf(lesson.id) == LessonStatus.locked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.lockedLessonMessage),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    // Opening the lesson player is added with the player feature.
  }

  @override
  Widget build(BuildContext context) {
    final course = state.course;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
          sliver: SliverToBoxAdapter(
            child: CourseHeader(
              course: course,
              completedLessons: state.completedLessons,
              progress: state.progress,
            ),
          ),
        ),
        if (course.lessonCount == 0)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyView(
              icon: Icons.video_library_outlined,
              title: context.l10n.noLessonsYet,
              message: context.l10n.noLessonsMessage,
            ),
          )
        else ...[
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                context.l10n.courseContent,
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          for (final section in course.sections) ...[
            SliverToBoxAdapter(child: SectionHeader(section: section)),
            SliverList.list(
              children: [
                for (final lesson in section.lessons)
                  LessonTile(
                    lesson: lesson,
                    status: state.statusOf(lesson.id),
                    onTap: () => _onLessonTap(context, lesson),
                  ),
              ],
            ),
          ],
          const SliverPadding(padding: EdgeInsetsDirectional.only(bottom: 24)),
        ],
      ],
    );
  }
}
