import 'package:equatable/equatable.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson.dart';

sealed class LessonPlayerState extends Equatable {
  const LessonPlayerState();

  @override
  List<Object?> get props => [];
}

final class LessonPlayerInitial extends LessonPlayerState {
  const LessonPlayerInitial();
}

final class LessonPlayerLoading extends LessonPlayerState {
  const LessonPlayerLoading();
}

enum LessonPlayerFailure { notFound, locked, loadFailed, videoUnavailable }

final class LessonPlayerError extends LessonPlayerState {
  const LessonPlayerError(this.failure);

  final LessonPlayerFailure failure;

  @override
  List<Object?> get props => [failure];
}

final class LessonPlayerReady extends LessonPlayerState {
  const LessonPlayerReady({
    required this.course,
    required this.lesson,
    required this.position,
    required this.duration,
    required this.aspectRatio,
    required this.isPlaying,
    required this.isBuffering,
    required this.playbackSpeed,
    required this.isCompleted,
    required this.nextLesson,
  });

  final Course course;
  final Lesson lesson;
  final Duration position;
  final Duration duration;
  final double aspectRatio;
  final bool isPlaying;
  final bool isBuffering;
  final double playbackSpeed;

  /// Whether this lesson reached the completion threshold, now or earlier.
  final bool isCompleted;

  /// The following lesson in course order, or `null` for the last lesson.
  final Lesson? nextLesson;

  /// The next lesson unlocks only once this lesson is completed.
  bool get canGoNext => isCompleted && nextLesson != null;

  bool get isCourseFinished => isCompleted && nextLesson == null;

  @override
  List<Object?> get props => [
    course,
    lesson,
    position,
    duration,
    aspectRatio,
    isPlaying,
    isBuffering,
    playbackSpeed,
    isCompleted,
    nextLesson,
  ];
}
