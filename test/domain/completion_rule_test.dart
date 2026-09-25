import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/domain/services/completion_rule.dart';

void main() {
  group('isLessonCompleted', () {
    test('89% is not completed', () {
      expect(
        isLessonCompleted(positionSeconds: 89, durationSeconds: 100),
        isFalse,
      );
    });

    test('90% is completed', () {
      expect(
        isLessonCompleted(positionSeconds: 90, durationSeconds: 100),
        isTrue,
      );
    });

    test('95% is completed', () {
      expect(
        isLessonCompleted(positionSeconds: 95, durationSeconds: 100),
        isTrue,
      );
    });

    test('100% is completed', () {
      expect(
        isLessonCompleted(positionSeconds: 100, durationSeconds: 100),
        isTrue,
      );
    });

    test('90% of a short video is completed', () {
      expect(
        isLessonCompleted(positionSeconds: 9, durationSeconds: 10),
        isTrue,
      );
    });

    test('zero duration is never completed', () {
      expect(
        isLessonCompleted(positionSeconds: 0, durationSeconds: 0),
        isFalse,
      );
      expect(
        isLessonCompleted(positionSeconds: 10, durationSeconds: 0),
        isFalse,
      );
    });

    test('negative values are never completed', () {
      expect(
        isLessonCompleted(positionSeconds: 50, durationSeconds: -1),
        isFalse,
      );
      expect(
        isLessonCompleted(positionSeconds: -5, durationSeconds: 100),
        isFalse,
      );
    });
  });
}
