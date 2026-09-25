import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/domain/entities/lesson_progress.dart';
import 'package:thaheen_task/domain/entities/lesson_status.dart';
import 'package:thaheen_task/domain/services/lesson_status_resolver.dart';
import 'package:thaheen_task/domain/services/unlock_rule.dart';

import '../helpers/test_data.dart';

void main() {
  final course = buildCourse(
    sections: [
      ['l1', 'l2'],
      ['l3', 'l4'],
    ],
  );

  bool unlocked(String lessonId, Map<String, LessonProgress> progress) =>
      isLessonUnlocked(course: course, lessonId: lessonId, progress: progress);

  group('isLessonUnlocked', () {
    test('first lesson is always unlocked', () {
      expect(unlocked('l1', {}), isTrue);
    });

    test('lesson is locked while the previous lesson is incomplete', () {
      final progress = {
        'l1': const LessonProgress(lessonId: 'l1', positionSeconds: 50),
      };

      expect(unlocked('l2', progress), isFalse);
    });

    test('lesson is unlocked once the previous lesson is completed', () {
      expect(unlocked('l2', completed(['l1'])), isTrue);
    });

    test('only the lesson right after the last completed one unlocks', () {
      final progress = completed(['l1']);

      expect(unlocked('l2', progress), isTrue);
      expect(unlocked('l3', progress), isFalse);
      expect(unlocked('l4', progress), isFalse);
    });

    test('unlocking continues across sections', () {
      expect(unlocked('l3', completed(['l1'])), isFalse);
      expect(unlocked('l3', completed(['l1', 'l2'])), isTrue);
      expect(unlocked('l4', completed(['l1', 'l2'])), isFalse);
      expect(unlocked('l4', completed(['l1', 'l2', 'l3'])), isTrue);
    });

    test('unknown lesson is locked', () {
      expect(unlocked('missing', {}), isFalse);
    });
  });

  group('resolveLessonStatus', () {
    LessonStatus status(
      String lessonId,
      Map<String, LessonProgress> progress,
    ) => resolveLessonStatus(
      course: course,
      lessonId: lessonId,
      progress: progress,
    );

    test('derives each status from progress and the unlock rule', () {
      final progress = {
        ...completed(['l1']),
        'l2': const LessonProgress(lessonId: 'l2', positionSeconds: 30),
      };

      expect(status('l1', progress), LessonStatus.completed);
      expect(status('l2', progress), LessonStatus.inProgress);
      expect(status('l3', progress), LessonStatus.locked);
    });

    test('unlocked lesson without progress is not started', () {
      expect(status('l1', {}), LessonStatus.notStarted);
      expect(status('l2', completed(['l1'])), LessonStatus.notStarted);
    });
  });
}
