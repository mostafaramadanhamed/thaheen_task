import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/player_constants.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/repositories/progress_repository.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/lesson_progress.dart';
import '../../../domain/services/completion_rule.dart';
import '../../../domain/services/unlock_rule.dart';
import 'lesson_player_state.dart';

/// Owns the [VideoPlayerController] for one lesson: playback, resume,
/// completion detection and throttled progress persistence.
class LessonPlayerCubit extends Cubit<LessonPlayerState> {
  LessonPlayerCubit({
    required this.courseId,
    required this.lessonId,
    required this._courseRepository,
    required this._progressRepository,
  }) : super(const LessonPlayerInitial());

  final String courseId;
  final String lessonId;
  final CourseRepository _courseRepository;
  final ProgressRepository _progressRepository;

  VideoPlayerController? _controller;
  Course? _course;
  Lesson? _lesson;
  bool _isCompleted = false;
  bool _wasPlaying = false;
  DateTime? _lastSavedAt;

  /// Exposed only so the video surface can render frames. Playback must go
  /// through the cubit methods so state and persistence stay consistent.
  VideoPlayerController? get controller => _controller;

  Future<void> initialize() async {
    emit(const LessonPlayerLoading());
    await _disposeController();

    final Course? course;
    try {
      course = await _courseRepository.getCourseById(courseId);
    } on CourseLoadException {
      _emitIfOpen(const LessonPlayerError(LessonPlayerFailure.loadFailed));
      return;
    }

    final lesson = course?.lessons
        .where((candidate) => candidate.id == lessonId)
        .firstOrNull;
    if (course == null || lesson == null) {
      _emitIfOpen(const LessonPlayerError(LessonPlayerFailure.notFound));
      return;
    }

    final unlocked = isLessonUnlocked(
      course: course,
      lessonId: lessonId,
      progress: _progressRepository.getAll(),
    );
    if (!unlocked) {
      _emitIfOpen(const LessonPlayerError(LessonPlayerFailure.locked));
      return;
    }

    _course = course;
    _lesson = lesson;
    await _initializeVideo(lesson);
  }

  Future<void> play() async {
    final controller = _readyController;
    if (controller == null) return;

    if (controller.value.position >= controller.value.duration) {
      await controller.seekTo(Duration.zero);
    }
    await controller.play();
  }

  Future<void> pause() async {
    await _readyController?.pause();
  }

  Future<void> togglePlayPause() {
    final isPlaying = _readyController?.value.isPlaying ?? false;
    return isPlaying ? pause() : play();
  }

  Future<void> seekTo(Duration position) async {
    final controller = _readyController;
    if (controller == null) return;

    final duration = controller.value.duration;
    final target = position < Duration.zero
        ? Duration.zero
        : (position > duration ? duration : position);
    await controller.seekTo(target);
  }

  Future<void> seekBy(Duration offset) async {
    final controller = _readyController;
    if (controller == null) return;
    await seekTo(controller.value.position + offset);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _readyController?.setPlaybackSpeed(speed);
  }

  Future<void> _initializeVideo(Lesson lesson) async {
    final controller = VideoPlayerController.asset(lesson.videoPath);
    _controller = controller;

    try {
      await controller.initialize();
    } catch (error, stackTrace) {
      log(
        'Failed to initialize video ${lesson.videoPath}',
        name: 'LessonPlayer',
        error: error,
        stackTrace: stackTrace,
      );
      _emitIfOpen(
        const LessonPlayerError(LessonPlayerFailure.videoUnavailable),
      );
      return;
    }
    if (isClosed) return;

    if (controller.value.duration <= Duration.zero) {
      _emitIfOpen(
        const LessonPlayerError(LessonPlayerFailure.videoUnavailable),
      );
      return;
    }

    final saved = _progressRepository.getProgress(lesson.id);
    _isCompleted = saved.completed;
    _wasPlaying = false;
    await _restorePosition(controller, saved);
    if (isClosed) return;

    controller.addListener(_onVideoUpdate);
    _emitReady(controller.value);
    await controller.play();
  }

  Future<void> _restorePosition(
    VideoPlayerController controller,
    LessonProgress saved,
  ) async {
    final resumeAt = Duration(seconds: saved.positionSeconds);
    final restartFrom =
        controller.value.duration -
        PlayerConstants.restartFromBeginningThreshold;
    if (resumeAt > Duration.zero && resumeAt < restartFrom) {
      await controller.seekTo(resumeAt);
    }
  }

  void _onVideoUpdate() {
    final controller = _controller;
    if (controller == null || isClosed) return;
    final value = controller.value;

    if (value.hasError) {
      log('Playback error: ${value.errorDescription}', name: 'LessonPlayer');
      controller.removeListener(_onVideoUpdate);
      emit(const LessonPlayerError(LessonPlayerFailure.videoUnavailable));
      return;
    }

    final justCompleted = _updateCompletion(value);
    final justPaused = _wasPlaying && !value.isPlaying;
    _wasPlaying = value.isPlaying;

    if (justCompleted || justPaused || _isSaveDue) {
      unawaited(_saveProgress());
    }
    _emitReady(value);
  }

  /// Returns `true` when this update is the one that completes the lesson.
  bool _updateCompletion(VideoPlayerValue value) {
    if (_isCompleted) return false;

    _isCompleted = isLessonCompleted(
      positionSeconds: value.position.inSeconds,
      durationSeconds: value.duration.inSeconds,
    );
    return _isCompleted;
  }

  bool get _isSaveDue {
    final lastSavedAt = _lastSavedAt;
    return lastSavedAt == null ||
        DateTime.now().difference(lastSavedAt) >=
            PlayerConstants.progressSaveInterval;
  }

  Future<void> _saveProgress() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final positionSeconds = controller.value.position.inSeconds;
    final saved = _progressRepository.getProgress(lessonId);
    if (saved.positionSeconds == positionSeconds &&
        saved.completed == _isCompleted) {
      return;
    }

    _lastSavedAt = DateTime.now();
    await _progressRepository.saveProgress(
      saved.copyWith(
        positionSeconds: positionSeconds,
        completed: _isCompleted,
        lastWatchedAt: _lastSavedAt,
      ),
    );
  }

  void _emitReady(VideoPlayerValue value) {
    final course = _course;
    final lesson = _lesson;
    if (course == null || lesson == null || isClosed) return;

    emit(
      LessonPlayerReady(
        course: course,
        lesson: lesson,
        position: value.position,
        duration: value.duration,
        aspectRatio: value.aspectRatio,
        isPlaying: value.isPlaying,
        isBuffering: value.isBuffering,
        playbackSpeed: value.playbackSpeed,
        isCompleted: _isCompleted,
        nextLesson: course.lessonAfter(lesson.id),
      ),
    );
  }

  void _emitIfOpen(LessonPlayerState state) {
    if (!isClosed) emit(state);
  }

  VideoPlayerController? get _readyController {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;
    return controller;
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    if (controller == null) return;

    _controller = null;
    controller.removeListener(_onVideoUpdate);
    await controller.dispose();
  }

  @override
  Future<void> close() async {
    await _saveProgress();
    await _disposeController();
    return super.close();
  }
}
