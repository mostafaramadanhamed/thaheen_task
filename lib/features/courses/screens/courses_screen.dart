import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/navigation_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/app_empty_view.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../../../core/widgets/language_switch_button.dart';
import '../../../core/widgets/theme_switch_button.dart';
import '../cubit/courses_cubit.dart';
import '../cubit/courses_state.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';
import '../widgets/course_search_field.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCourses),
        actions: const [
          ThemeSwitchButton(),
          LanguageSwitchButton(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CoursesCubit, CoursesState>(
        builder: (context, state) => switch (state) {
          CoursesInitial() || CoursesLoading() => const AppLoadingView(),
          CoursesError() => AppErrorView(
            title: l10n.coursesErrorTitle,
            message: l10n.coursesErrorMessage,
            onRetry: context.read<CoursesCubit>().loadCourses,
          ),
          CoursesEmpty() => AppEmptyView(
            icon: Icons.school_outlined,
            title: l10n.noCoursesTitle,
            message: l10n.noCoursesMessage,
          ),
          CoursesLoaded() => _CoursesContent(state: state),
        },
      ),
    );
  }
}

class _CoursesContent extends StatelessWidget {
  const _CoursesContent({required this.state});

  static const EdgeInsetsDirectional _horizontalPadding =
      EdgeInsetsDirectional.symmetric(horizontal: 16);

  final CoursesLoaded state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final continueWatching = state.continueWatching;

    // Continue Watching sits above search and stays visible while searching,
    // so the search field never jumps under the user's finger.
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (continueWatching != null) ...[
          _SectionTitle(l10n.continueWatching, isFirst: true),
          SliverPadding(
            padding: _horizontalPadding,
            sliver: SliverToBoxAdapter(
              child: ContinueWatchingCard(
                item: continueWatching,
                onTap: () => context.goToLessonPlayer(
                  courseId: continueWatching.course.id,
                  lessonId: continueWatching.lesson.id,
                ),
              ),
            ),
          ),
        ],
        SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            continueWatching == null ? 8 : 24,
            16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: CourseSearchField(
              initialQuery: state.searchQuery,
              onChanged: context.read<CoursesCubit>().search,
            ),
          ),
        ),
        _SectionTitle(l10n.allCourses),
        if (state.filteredCourses.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AppEmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.noSearchResultsTitle,
              message: l10n.noSearchResultsMessage(state.searchQuery.trim()),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: state.filteredCourses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final course = state.filteredCourses[index];
                return CourseCard(
                  course: course,
                  progress: state.progressOf(course),
                  onTap: () => context.goToCourseDetails(course.id),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.isFirst = false});

  final String title;

  /// The first title on the screen needs less space above it.
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsDirectional.fromSTEB(16, isFirst ? 8 : 24, 16, 12),
      sliver: SliverToBoxAdapter(
        child: Text(title, style: context.textTheme.titleLarge),
      ),
    );
  }
}
