import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/local/playback_speed_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_player_cubit.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_player_state.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../../helpers/fake_video_player_platform.dart';
import '../../helpers/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVideoPlayerPlatform platform;
  late ProgressRepository progressRepository;
  late CourseRepository courseRepository;
  late SharedPreferences preferences;

  setUp(() async {
    platform = FakeVideoPlayerPlatform();
    VideoPlayerPlatform.instance = platform;
    progressRepository = await createProgressRepository();
    preferences = await SharedPreferences.getInstance();
    courseRepository = CourseRepository(CourseLocalDataSource(rootBundle));
  });

  LessonPlayerCubit createCubit(String lessonId) => LessonPlayerCubit(
    courseId: 'anatomy',
    lessonId: lessonId,
    courseRepository: courseRepository,
    progressRepository: progressRepository,
    playbackSpeedDataSource: PlaybackSpeedLocalDataSource(preferences),
  );

  Future<void> complete(String lessonId) => progressRepository.saveProgress(
    LessonProgress(lessonId: lessonId, completed: true),
  );

  test('refuses to open a locked lesson', () async {
    final cubit = createCubit('anatomy_l2');

    await cubit.initialize();

    expect(cubit.state, const LessonPlayerError(LessonPlayerFailure.locked));
    expect(platform.calls, isNot(contains('create')));
    await cubit.close();
  });

  test('reports an unknown lesson as not found', () async {
    final cubit = createCubit('missing');

    await cubit.initialize();

    expect(cubit.state, const LessonPlayerError(LessonPlayerFailure.notFound));
    await cubit.close();
  });

  test('reports a video that cannot be initialized', () async {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform(
      failInitialization: true,
    );
    final cubit = createCubit('anatomy_l1');

    await cubit.initialize();

    expect(
      cubit.state,
      const LessonPlayerError(LessonPlayerFailure.videoUnavailable),
    );
    await cubit.close();
  });

  test('starts playing and resumes the saved position', () async {
    await progressRepository.saveProgress(
      const LessonProgress(lessonId: 'anatomy_l1', positionSeconds: 42),
    );
    final cubit = createCubit('anatomy_l1');

    await cubit.initialize();

    final state = cubit.state as LessonPlayerReady;
    expect(state.duration, const Duration(seconds: 100));
    expect(state.position, const Duration(seconds: 42));
    expect(state.isPlaying, isTrue);
    expect(state.isCompleted, isFalse);
    expect(state.canGoNext, isFalse);
    await cubit.close();
  });

  test('restarts from the beginning when saved near the end', () async {
    await progressRepository.saveProgress(
      const LessonProgress(lessonId: 'anatomy_l1', positionSeconds: 99),
    );
    final cubit = createCubit('anatomy_l1');

    await cubit.initialize();

    expect((cubit.state as LessonPlayerReady).position, Duration.zero);
    await cubit.close();
  });

  test('does not complete the lesson before 90%', () async {
    final cubit = createCubit('anatomy_l1');
    await cubit.initialize();

    await cubit.seekTo(const Duration(seconds: 89));

    expect((cubit.state as LessonPlayerReady).isCompleted, isFalse);
    expect(progressRepository.getProgress('anatomy_l1').completed, isFalse);
    await cubit.close();
  });

  test('completes at 90%, persists it and unlocks the next lesson', () async {
    final cubit = createCubit('anatomy_l2');
    await complete('anatomy_l1');
    await cubit.initialize();

    await cubit.seekTo(const Duration(seconds: 90));

    final state = cubit.state as LessonPlayerReady;
    expect(state.isCompleted, isTrue);
    expect(state.canGoNext, isTrue);
    expect(state.nextLesson?.id, 'anatomy_l3');
    final saved = progressRepository.getProgress('anatomy_l2');
    expect(saved.completed, isTrue);
    expect(saved.positionSeconds, 90);
    await cubit.close();
  });

  test('finishing the last lesson finishes the course', () async {
    for (final id in ['anatomy_l1', 'anatomy_l2', 'anatomy_l3']) {
      await complete(id);
    }
    final cubit = createCubit('anatomy_l4');
    await cubit.initialize();

    await cubit.seekTo(const Duration(seconds: 95));

    final state = cubit.state as LessonPlayerReady;
    expect(state.nextLesson, isNull);
    expect(state.canGoNext, isFalse);
    expect(state.isCourseFinished, isTrue);
    await cubit.close();
  });

  test('saves the position when paused', () async {
    final cubit = createCubit('anatomy_l1');
    await cubit.initialize();
    await cubit.seekTo(const Duration(seconds: 30));

    await cubit.pause();
    await Future<void>.delayed(Duration.zero);

    expect(progressRepository.getProgress('anatomy_l1').positionSeconds, 30);
    expect((cubit.state as LessonPlayerReady).isPlaying, isFalse);
    await cubit.close();
  });

  test('saves the final position and disposes the video on close', () async {
    final cubit = createCubit('anatomy_l1');
    await cubit.initialize();
    await cubit.seekTo(const Duration(seconds: 12));

    await cubit.close();

    final saved = progressRepository.getProgress('anatomy_l1');
    expect(saved.positionSeconds, 12);
    expect(saved.lastWatchedAt, isNotNull);
    expect(platform.calls, contains('dispose'));
  });

  test('changing playback speed applies and remembers it', () async {
    final cubit = createCubit('anatomy_l1');
    await cubit.initialize();

    await cubit.setPlaybackSpeed(1.5);

    expect((cubit.state as LessonPlayerReady).playbackSpeed, 1.5);
    expect(preferences.getDouble(StorageKeys.playbackSpeed), 1.5);
    await cubit.close();
  });

  test('opens every lesson at the last chosen speed', () async {
    await preferences.setDouble(StorageKeys.playbackSpeed, 1.25);
    final cubit = createCubit('anatomy_l1');

    await cubit.initialize();

    expect((cubit.state as LessonPlayerReady).playbackSpeed, 1.25);
    await cubit.close();
  });

  test('ignores an unsupported saved speed', () async {
    await preferences.setDouble(StorageKeys.playbackSpeed, 3.0);
    final cubit = createCubit('anatomy_l1');

    await cubit.initialize();

    expect((cubit.state as LessonPlayerReady).playbackSpeed, 1.0);
    await cubit.close();
  });
}
