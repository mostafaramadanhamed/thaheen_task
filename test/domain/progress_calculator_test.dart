import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/domain/services/progress_calculator.dart';

import '../helpers/test_data.dart';

void main() {
  group('calculateProgress', () {
    test('0 / 6 is 0.0', () {
      expect(calculateProgress(completedLessons: 0, totalLessons: 6), 0.0);
    });

    test('3 / 6 is 0.5', () {
      expect(calculateProgress(completedLessons: 3, totalLessons: 6), 0.5);
    });

    test('6 / 6 is 1.0', () {
      expect(calculateProgress(completedLessons: 6, totalLessons: 6), 1.0);
    });

    test('zero total lessons is 0.0', () {
      expect(calculateProgress(completedLessons: 0, totalLessons: 0), 0.0);
    });

    test('result is clamped to 1.0', () {
      expect(calculateProgress(completedLessons: 7, totalLessons: 6), 1.0);
    });
  });

  group('calculateCourseProgress', () {
    final course = buildCourse(
      sections: [
        ['l1', 'l2', 'l3'],
        ['l4', 'l5', 'l6'],
      ],
    );

    test('counts only completed lessons of the course', () {
      final progress = {
        ...completed(['l1', 'l2', 'l4', 'other_course_lesson']),
        'l3': const LessonProgress(lessonId: 'l3', positionSeconds: 80),
      };

      expect(calculateCourseProgress(course, progress), 0.5);
    });

    test('course without lessons has 0.0 progress', () {
      expect(calculateCourseProgress(buildCourse(), {}), 0.0);
    });
  });
}
