import '../../core/constants/learning_constants.dart';

/// Fraction of a lesson watched, from 0.0 to 1.0.
/// Returns 0.0 for zero or negative durations instead of dividing by zero.
double watchedFraction({
  required int positionSeconds,
  required int durationSeconds,
}) {
  if (durationSeconds <= 0 || positionSeconds <= 0) return 0;
  return (positionSeconds / durationSeconds).clamp(0.0, 1.0);
}

/// A lesson is completed once the watched position reaches
/// [LearningConstants.completionThreshold] of its duration.
bool isLessonCompleted({
  required int positionSeconds,
  required int durationSeconds,
}) {
  if (durationSeconds <= 0) return false;
  return watchedFraction(
        positionSeconds: positionSeconds,
        durationSeconds: durationSeconds,
      ) >=
      LearningConstants.completionThreshold;
}
