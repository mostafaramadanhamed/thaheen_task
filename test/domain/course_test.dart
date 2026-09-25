import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_data.dart';

void main() {
  final course = buildCourse(
    sections: [
      ['l1', 'l2'],
      ['l3'],
    ],
  );

  group('Course', () {
    test('flattens lessons across sections in order', () {
      expect(course.lessons.map((lesson) => lesson.id), ['l1', 'l2', 'l3']);
      expect(course.lessonCount, 3);
    });

    test('lessonAfter returns the next lesson across sections', () {
      expect(course.lessonAfter('l1')?.id, 'l2');
      expect(course.lessonAfter('l2')?.id, 'l3');
    });

    test('lessonAfter returns null for the last or an unknown lesson', () {
      expect(course.lessonAfter('l3'), isNull);
      expect(course.lessonAfter('missing'), isNull);
    });
  });
}
