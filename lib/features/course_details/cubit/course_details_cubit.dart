import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson_progress.dart';
import '../../../domain/services/lesson_status_resolver.dart';
import '../../../domain/services/progress_calculator.dart';
import 'course_details_state.dart';

class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit({
    required this.courseId,
    required this._courseRepository,
    required this._progressRepository,
  }) : super(const CourseDetailsInitial());

  final String courseId;
  final CourseRepository _courseRepository;
  final ProgressRepository _progressRepository;
  StreamSubscription<Map<String, LessonProgress>>? _progressSubscription;

  Future<void> loadCourse() async {
    emit(const CourseDetailsLoading());

    final Course? course;
    try {
      course = await _courseRepository.getCourseById(courseId);
    } on CourseLoadException {
      emit(const CourseDetailsError(CourseDetailsFailure.loadFailed));
      return;
    }

    if (course == null) {
      emit(const CourseDetailsError(CourseDetailsFailure.notFound));
      return;
    }

    _progressSubscription ??= _progressRepository.changes.listen(
      _onProgressChanged,
    );
    emit(_buildLoadedState(course, _progressRepository.getAll()));
  }

  void _onProgressChanged(Map<String, LessonProgress> progress) {
    final current = state;
    if (current is! CourseDetailsLoaded) return;
    emit(_buildLoadedState(current.course, progress));
  }

  CourseDetailsLoaded _buildLoadedState(
    Course course,
    Map<String, LessonProgress> progress,
  ) {
    return CourseDetailsLoaded(
      course: course,
      lessonStatuses: {
        for (final lesson in course.lessons)
          lesson.id: resolveLessonStatus(
            course: course,
            lessonId: lesson.id,
            progress: progress,
          ),
      },
      completedLessons: countCompletedLessons(course, progress),
      progress: calculateCourseProgress(course, progress),
    );
  }

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    return super.close();
  }
}
