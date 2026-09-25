import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';

import '../helpers/fake_asset_bundle.dart';

CourseRepository _repositoryWith(String? json) =>
    CourseRepository(CourseLocalDataSource(FakeAssetBundle(json)));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses the bundled course catalog', () async {
    final repository = CourseRepository(CourseLocalDataSource(rootBundle));

    final courses = await repository.getCourses();

    expect(courses, isNotEmpty);
    final anatomy = await repository.getCourseById('anatomy');
    expect(anatomy, isNotNull);
    expect(anatomy!.sections, hasLength(2));
    expect(anatomy.lessons.map((lesson) => lesson.id), [
      'anatomy_l1',
      'anatomy_l2',
      'anatomy_l3',
      'anatomy_l4',
    ]);
  });

  test('bundled lesson ids are unique across courses', () async {
    final repository = CourseRepository(CourseLocalDataSource(rootBundle));

    final ids = [
      for (final course in await repository.getCourses())
        ...course.lessons.map((lesson) => lesson.id),
    ];

    expect(ids.toSet(), hasLength(ids.length));
  });

  test('returns null for an unknown course id', () async {
    final repository = _repositoryWith('{"courses": []}');

    expect(await repository.getCourseById('missing'), isNull);
  });

  test('returns an empty list when there are no courses', () async {
    final repository = _repositoryWith('{"courses": []}');

    expect(await repository.getCourses(), isEmpty);
  });

  test('throws CourseLoadException when the asset is missing', () {
    final repository = _repositoryWith(null);

    expect(repository.getCourses(), throwsA(isA<CourseLoadException>()));
  });

  test('throws CourseLoadException for invalid JSON', () {
    final repository = _repositoryWith('{not json');

    expect(repository.getCourses(), throwsA(isA<CourseLoadException>()));
  });

  test('throws CourseLoadException when a required field is missing', () {
    final repository = _repositoryWith(
      '{"courses": [{"id": "c1", "title": {"ar": "أ", "en": "A"}}]}',
    );

    expect(repository.getCourses(), throwsA(isA<CourseLoadException>()));
  });
}
