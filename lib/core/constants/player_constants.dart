import 'package:flutter/services.dart';

abstract final class PlayerConstants {
  static const List<double> playbackSpeeds = [1.0, 1.25, 1.5, 2.0];
  static const double defaultPlaybackSpeed = 1.0;

  /// How often playback position is persisted while a lesson is playing.
  static const Duration progressSaveInterval = Duration(seconds: 5);

  /// A saved position closer than this to the end restarts the lesson.
  static const Duration restartFromBeginningThreshold = Duration(seconds: 2);

  static const Duration seekStep = Duration(seconds: 10);
  static const Duration controlsAutoHideDelay = Duration(seconds: 3);

  static const List<DeviceOrientation> portraitOrientations = [
    DeviceOrientation.portraitUp,
  ];
  static const List<DeviceOrientation> fullscreenOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
}
