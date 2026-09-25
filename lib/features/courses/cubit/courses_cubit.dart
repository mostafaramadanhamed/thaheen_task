import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson_progress.dart';
import '../../../domain/services/continue_watching_finder.dart';
import '../../../domain/services/course_filter.dart';
import '../../../domain/services/progress_calculator.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit({
    required this._courseRepository,
    required this._progressRepository,
  }) : super(const CoursesInitial());

  final CourseRepository _courseRepository;
  final ProgressRepository _progressRepository;
  StreamSubscription<Map<String, LessonProgress>>? _progressSubscription;

  Future<void> loadCourses() async {
    emit(const CoursesLoading());

    final List<Course> courses;
    try {
      courses = await _courseRepository.getCourses();
    } on CourseLoadException {
      emit(const CoursesError());
      return;
    }

    if (courses.isEmpty) {
      emit(const CoursesEmpty());
      return;
    }

    _progressSubscription ??= _progressRepository.changes.listen(
      _onProgressChanged,
    );
    emit(
      _buildLoadedState(
        courses: courses,
        progress: _progressRepository.getAll(),
        searchQuery: '',
      ),
    );
  }

  void search(String query) {
    final current = state;
    if (current is! CoursesLoaded || current.searchQuery == query) return;

    emit(
      _buildLoadedState(
        courses: current.allCourses,
        progress: _progressRepository.getAll(),
        searchQuery: query,
      ),
    );
  }

  void _onProgressChanged(Map<String, LessonProgress> progress) {
    final current = state;
    if (current is! CoursesLoaded) return;

    emit(
      _buildLoadedState(
        courses: current.allCourses,
        progress: progress,
        searchQuery: current.searchQuery,
      ),
    );
  }

  CoursesLoaded _buildLoadedState({
    required List<Course> courses,
    required Map<String, LessonProgress> progress,
    required String searchQuery,
  }) {
    return CoursesLoaded(
      allCourses: courses,
      filteredCourses: filterCourses(courses, searchQuery),
      searchQuery: searchQuery,
      courseProgress: {
        for (final course in courses)
          course.id: calculateCourseProgress(course, progress),
      },
      continueWatching: findContinueWatching(courses, progress),
    );
  }

  @override
  Future<void> close() async {
    await _progressSubscription?.cancel();
    return super.close();
  }
}
