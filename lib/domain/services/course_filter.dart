import '../entities/course.dart';

/// Filters [courses] by [query] against the Arabic and English titles and
/// instructor names. Matching ignores English letter case and common Arabic
/// spelling variations (diacritics, alef forms, taa marbuta, alef maqsura).
List<Course> filterCourses(List<Course> courses, String query) {
  final normalizedQuery = _normalize(query);
  if (normalizedQuery.isEmpty) return courses;

  return courses.where((course) {
    final searchable = [
      course.title.ar,
      course.title.en,
      course.instructor.ar,
      course.instructor.en,
    ];
    return searchable.any((text) => _normalize(text).contains(normalizedQuery));
  }).toList();
}

final RegExp _arabicDiacritics = RegExp('[\u064B-\u065F\u0670\u0640]');
final RegExp _alefVariants = RegExp('[أإآ]');
final RegExp _whitespace = RegExp(r'\s+');

String _normalize(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(_arabicDiacritics, '')
      .replaceAll(_alefVariants, 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll(_whitespace, ' ');
}
