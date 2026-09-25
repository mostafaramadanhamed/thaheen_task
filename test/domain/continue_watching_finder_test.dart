import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/domain/services/continue_watching_finder.dart';

import '../helpers/test_data.dart';

void main() {
  final courseA = buildCourse(
    id: 'a',
    sections: [
      ['a1', 'a2'],
    ],
  );
  final courseB = buildCourse(
    id: 'b',
    sections: [
      ['b1'],
    ],
  );
  final courses = [courseA, courseB];

  group('findContinueWatching', () {
    test('returns null when nothing has been started', () {
      expect(findContinueWatching(courses, {}), isNull);
    });

    test('ignores completed lessons', () {
      final progress = {
        'a1': const LessonProgress(
          lessonId: 'a1',
          positionSeconds: 95,
          completed: true,
        ),
      };

      expect(findContinueWatching(courses, progress), isNull);
    });

    test('ignores lessons with zero position', () {
      final progress = {'a1': const LessonProgress(lessonId: 'a1')};

      expect(findContinueWatching(courses, progress), isNull);
    });

    test('returns the started, unfinished lesson with its course', () {
      const progress = LessonProgress(lessonId: 'a2', positionSeconds: 30);

      final item = findContinueWatching(courses, {'a2': progress});

      expect(item?.course.id, 'a');
      expect(item?.lesson.id, 'a2');
      expect(item?.progress, progress);
    });

    test('prefers the most recently watched lesson', () {
      final progress = {
        'a1': LessonProgress(
          lessonId: 'a1',
          positionSeconds: 10,
          lastWatchedAt: DateTime(2026, 1, 1),
        ),
        'b1': LessonProgress(
          lessonId: 'b1',
          positionSeconds: 10,
          lastWatchedAt: DateTime(2026, 1, 2),
        ),
      };

      expect(findContinueWatching(courses, progress)?.lesson.id, 'b1');
    });
  });
}
