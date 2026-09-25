import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/domain/entities/lesson_status.dart';
import 'package:thaheen_task/features/course_details/cubit/course_details_cubit.dart';
import 'package:thaheen_task/features/course_details/cubit/course_details_state.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProgressRepository progressRepository;

  setUp(() async {
    progressRepository = await createProgressRepository();
  });

  CourseDetailsCubit createCubit(String courseId, [AssetBundle? bundle]) =>
      CourseDetailsCubit(
        courseId: courseId,
        courseRepository: CourseRepository(
          CourseLocalDataSource(bundle ?? rootBundle),
        ),
        progressRepository: progressRepository,
      );

  test('loads the course with only the first lesson unlocked', () async {
    final cubit = createCubit('anatomy');

    await cubit.loadCourse();

    final state = cubit.state as CourseDetailsLoaded;
    expect(state.course.id, 'anatomy');
    expect(state.lessonStatuses, {
      'anatomy_l1': LessonStatus.notStarted,
      'anatomy_l2': LessonStatus.locked,
      'anatomy_l3': LessonStatus.locked,
      'anatomy_l4': LessonStatus.locked,
    });
    expect(state.progress, 0.0);
    await cubit.close();
  });

  test('emits notFound for an unknown course', () async {
    final cubit = createCubit('missing');

    await cubit.loadCourse();

    expect(
      cubit.state,
      const CourseDetailsError(CourseDetailsFailure.notFound),
    );
    await cubit.close();
  });

  test('emits loadFailed when the catalog cannot be loaded', () async {
    final cubit = createCubit('anatomy', FakeAssetBundle(null));

    await cubit.loadCourse();

    expect(
      cubit.state,
      const CourseDetailsError(CourseDetailsFailure.loadFailed),
    );
    await cubit.close();
  });

  test('unlocks across sections as progress changes', () async {
    final cubit = createCubit('anatomy');
    await cubit.loadCourse();

    await progressRepository.saveProgress(
      const LessonProgress(lessonId: 'anatomy_l1', completed: true),
    );
    await progressRepository.saveProgress(
      const LessonProgress(lessonId: 'anatomy_l2', completed: true),
    );
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as CourseDetailsLoaded;
    expect(state.statusOf('anatomy_l2'), LessonStatus.completed);
    expect(state.statusOf('anatomy_l3'), LessonStatus.notStarted);
    expect(state.statusOf('anatomy_l4'), LessonStatus.locked);
    expect(state.completedLessons, 2);
    expect(state.progress, 0.5);
    await cubit.close();
  });
}
