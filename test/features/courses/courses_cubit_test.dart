import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/features/courses/cubit/courses_cubit.dart';
import 'package:thaheen_task/features/courses/cubit/courses_state.dart';

import '../../helpers/fake_asset_bundle.dart';
import '../../helpers/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProgressRepository progressRepository;

  setUp(() async {
    progressRepository = await createProgressRepository();
  });

  CoursesCubit createCubit([AssetBundle? bundle]) => CoursesCubit(
    courseRepository: CourseRepository(
      CourseLocalDataSource(bundle ?? rootBundle),
    ),
    progressRepository: progressRepository,
  );

  test('emits loading then loaded with the bundled courses', () async {
    final cubit = createCubit();
    final states = <CoursesState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.loadCourses();
    await Future<void>.delayed(Duration.zero);

    expect(states.first, isA<CoursesLoading>());
    final loaded = states.last as CoursesLoaded;
    expect(loaded.allCourses, isNotEmpty);
    expect(loaded.filteredCourses, loaded.allCourses);
    expect(loaded.continueWatching, isNull);
    expect(loaded.courseProgress.values, everyElement(0.0));

    await subscription.cancel();
    await cubit.close();
  });

  test('emits error when the catalog cannot be parsed', () async {
    final cubit = createCubit(FakeAssetBundle('{broken'));

    await cubit.loadCourses();

    expect(cubit.state, isA<CoursesError>());
    await cubit.close();
  });

  test('emits empty when the catalog has no courses', () async {
    final cubit = createCubit(FakeAssetBundle('{"courses": []}'));

    await cubit.loadCourses();

    expect(cubit.state, isA<CoursesEmpty>());
    await cubit.close();
  });

  test('search filters courses and keeps all courses', () async {
    final cubit = createCubit();
    await cubit.loadCourses();

    cubit.search('anatomy');

    final state = cubit.state as CoursesLoaded;
    expect(state.searchQuery, 'anatomy');
    expect(state.filteredCourses.map((course) => course.id), ['anatomy']);
    expect(state.allCourses.length, greaterThan(1));
    await cubit.close();
  });

  test(
    'updates progress and continue watching when progress changes',
    () async {
      final cubit = createCubit();
      await cubit.loadCourses();

      await progressRepository.saveProgress(
        const LessonProgress(lessonId: 'anatomy_l1', completed: true),
      );
      await progressRepository.saveProgress(
        const LessonProgress(lessonId: 'anatomy_l2', positionSeconds: 4),
      );
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state as CoursesLoaded;
      expect(state.courseProgress['anatomy'], 0.25);
      expect(state.continueWatching?.lesson.id, 'anatomy_l2');
      await cubit.close();
    },
  );
}
