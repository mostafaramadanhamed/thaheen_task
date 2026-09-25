import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/domain/entities/localized_text.dart';
import 'package:thaheen_task/domain/services/course_filter.dart';

import '../helpers/test_data.dart';

void main() {
  final anatomy = buildCourse(
    id: 'anatomy',
    title: const LocalizedText(
      ar: 'أساسيات علم التشريح',
      en: 'Anatomy Fundamentals',
    ),
    instructor: const LocalizedText(
      ar: 'د. سارة المالكي',
      en: 'Dr. Sara Almalki',
    ),
  );
  final firstAid = buildCourse(
    id: 'first_aid',
    title: const LocalizedText(
      ar: 'الإسعافات الأولية',
      en: 'First Aid Essentials',
    ),
    instructor: const LocalizedText(
      ar: 'أ. نورة القحطاني',
      en: 'Noura Alqahtani',
    ),
  );
  final courses = [anatomy, firstAid];

  group('filterCourses', () {
    test('empty or blank query returns all courses', () {
      expect(filterCourses(courses, ''), courses);
      expect(filterCourses(courses, '   '), courses);
    });

    test('matches English title case-insensitively', () {
      expect(filterCourses(courses, 'ANATOMY'), [anatomy]);
    });

    test('matches Arabic title', () {
      expect(filterCourses(courses, 'التشريح'), [anatomy]);
    });

    test('matches instructor in either language', () {
      expect(filterCourses(courses, 'noura'), [firstAid]);
      expect(filterCourses(courses, 'سارة'), [anatomy]);
    });

    test('ignores Arabic spelling variations', () {
      expect(filterCourses(courses, 'الاسعافات'), [firstAid]);
      expect(filterCourses(courses, 'ساره'), [anatomy]);
    });

    test('returns an empty list when nothing matches', () {
      expect(filterCourses(courses, 'cardiology'), isEmpty);
    });
  });
}
