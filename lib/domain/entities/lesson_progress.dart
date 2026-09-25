import 'package:equatable/equatable.dart';

/// The user's progress on a single lesson. Kept separate from [Lesson]
/// so that bundled content and user state never mix.
class LessonProgress extends Equatable {
  const LessonProgress({
    required this.lessonId,
    this.positionSeconds = 0,
    this.completed = false,
  });

  final String lessonId;
  final int positionSeconds;
  final bool completed;

  bool get isStarted => positionSeconds > 0 || completed;

  LessonProgress copyWith({int? positionSeconds, bool? completed}) {
    return LessonProgress(
      lessonId: lessonId,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [lessonId, positionSeconds, completed];
}
