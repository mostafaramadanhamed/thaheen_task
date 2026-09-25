import 'package:equatable/equatable.dart';

import '../../../domain/entities/continue_watching_item.dart';
import '../../../domain/entities/course.dart';

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

final class CoursesLoading extends CoursesState {
  const CoursesLoading();
}

/// The catalog loaded successfully but contains no courses.
final class CoursesEmpty extends CoursesState {
  const CoursesEmpty();
}

final class CoursesError extends CoursesState {
  const CoursesError();
}

final class CoursesLoaded extends CoursesState {
  const CoursesLoaded({
    required this.allCourses,
    required this.filteredCourses,
    required this.searchQuery,
    required this.courseProgress,
    required this.continueWatching,
  });

  final List<Course> allCourses;
  final List<Course> filteredCourses;
  final String searchQuery;

  /// Progress from 0.0 to 1.0, keyed by course id.
  final Map<String, double> courseProgress;
  final ContinueWatchingItem? continueWatching;

  double progressOf(Course course) => courseProgress[course.id] ?? 0;

  @override
  List<Object?> get props => [
    allCourses,
    filteredCourses,
    searchQuery,
    courseProgress,
    continueWatching,
  ];
}
