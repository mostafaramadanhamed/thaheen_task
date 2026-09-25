import 'package:equatable/equatable.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson_status.dart';

sealed class CourseDetailsState extends Equatable {
  const CourseDetailsState();

  @override
  List<Object?> get props => [];
}

final class CourseDetailsInitial extends CourseDetailsState {
  const CourseDetailsInitial();
}

final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

enum CourseDetailsFailure { notFound, loadFailed }

final class CourseDetailsError extends CourseDetailsState {
  const CourseDetailsError(this.failure);

  final CourseDetailsFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class CourseDetailsLoaded extends CourseDetailsState {
  const CourseDetailsLoaded({
    required this.course,
    required this.lessonStatuses,
    required this.completedLessons,
    required this.progress,
  });

  final Course course;

  /// Derived status for every lesson, keyed by lesson id.
  final Map<String, LessonStatus> lessonStatuses;
  final int completedLessons;

  /// Course progress from 0.0 to 1.0.
  final double progress;

  LessonStatus statusOf(String lessonId) =>
      lessonStatuses[lessonId] ?? LessonStatus.locked;

  @override
  List<Object?> get props => [
    course,
    lessonStatuses,
    completedLessons,
    progress,
  ];
}
