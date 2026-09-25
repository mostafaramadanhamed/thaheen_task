import '../../core/constants/learning_constants.dart';

/// A lesson is completed once the watched position reaches
/// [LearningConstants.completionThreshold] of its duration.
///
/// Returns `false` for zero or negative durations instead of dividing by zero.
bool isLessonCompleted({
  required int positionSeconds,
  required int durationSeconds,
}) {
  if (durationSeconds <= 0 || positionSeconds <= 0) return false;
  return positionSeconds / durationSeconds >=
      LearningConstants.completionThreshold;
}
