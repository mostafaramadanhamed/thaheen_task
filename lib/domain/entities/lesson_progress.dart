import 'package:equatable/equatable.dart';

/// The user's progress on a single lesson. Kept separate from [Lesson]
/// so that bundled content and user state never mix.
class LessonProgress extends Equatable {
  const LessonProgress({
    required this.lessonId,
    this.positionSeconds = 0,
    this.completed = false,
    this.lastWatchedAt,
  });

  final String lessonId;
  final int positionSeconds;
  final bool completed;

  /// When the lesson was last watched; used to pick the most recent
  /// lesson for Continue Watching.
  final DateTime? lastWatchedAt;

  bool get isStarted => positionSeconds > 0 || completed;

  LessonProgress copyWith({
    int? positionSeconds,
    bool? completed,
    DateTime? lastWatchedAt,
  }) {
    return LessonProgress(
      lessonId: lessonId,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      completed: completed ?? this.completed,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
    );
  }

  @override
  List<Object?> get props => [
    lessonId,
    positionSeconds,
    completed,
    lastWatchedAt,
  ];
}
