import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Centralized UI strings for Arabic and English.
///
/// Course content is localized separately through `LocalizedText`.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get languageCode => locale.languageCode;

  static const String _ltrIsolate = '\u2066';
  static const String _popIsolate = '\u2069';

  bool get _isArabic => languageCode == 'ar';

  String _pick({required String ar, required String en}) => _isArabic ? ar : en;

  // General
  String get retry => _pick(ar: 'إعادة المحاولة', en: 'Try again');
  String get pageNotFound =>
      _pick(ar: 'الصفحة غير موجودة', en: 'Page not found');

  // Courses
  String get myCourses => _pick(ar: 'دوراتي', en: 'My Courses');
  String get allCourses => _pick(ar: 'جميع الدورات', en: 'All Courses');
  String get continueWatching =>
      _pick(ar: 'تابع المشاهدة', en: 'Continue Watching');
  String get searchHint =>
      _pick(ar: 'ابحث عن دورة أو مدرّب', en: 'Search courses or instructors');
  String get clearSearch => _pick(ar: 'مسح البحث', en: 'Clear search');
  String get noLessonsYet =>
      _pick(ar: 'لا توجد دروس بعد', en: 'No lessons yet');
  String get coursesErrorTitle =>
      _pick(ar: 'تعذّر تحميل الدورات', en: "Couldn't load courses");
  String get coursesErrorMessage => _pick(
    ar: 'حدث خطأ أثناء قراءة بيانات الدورات. حاول مرة أخرى.',
    en: 'Something went wrong while reading the course data. Please try again.',
  );
  String get noCoursesTitle =>
      _pick(ar: 'لا توجد دورات متاحة', en: 'No courses available');
  String get noCoursesMessage => _pick(
    ar: 'ستظهر الدورات هنا عند توفرها.',
    en: 'Courses will appear here once they are available.',
  );
  String get noSearchResultsTitle =>
      _pick(ar: 'لا توجد نتائج', en: 'No results');

  String noSearchResultsMessage(String query) => _pick(
    ar: 'لم نجد دورات تطابق "$query".',
    en: 'No courses match "$query".',
  );

  // Course details
  String get aboutCourse => _pick(ar: 'عن الدورة', en: 'About this course');
  String get courseContent => _pick(ar: 'محتوى الدورة', en: 'Course content');
  String get courseNotFoundTitle =>
      _pick(ar: 'الدورة غير موجودة', en: 'Course not found');
  String get courseNotFoundMessage => _pick(
    ar: 'ربما تمت إزالة هذه الدورة. عد إلى قائمة الدورات.',
    en: 'This course may have been removed. Go back to the course list.',
  );
  String get courseDetailsErrorTitle =>
      _pick(ar: 'تعذّر تحميل الدورة', en: "Couldn't load this course");
  String get noLessonsMessage => _pick(
    ar: 'ستتوفر دروس هذه الدورة قريبًا.',
    en: 'Lessons for this course will be available soon.',
  );
  String get lockedLessonMessage => _pick(
    ar: 'هذا الدرس مقفل. أكمل الدرس السابق أولًا لفتحه.',
    en: 'This lesson is locked. Complete the previous lesson first to unlock it.',
  );
  String get statusLocked => _pick(ar: 'مقفل', en: 'Locked');
  String get statusNotStarted => _pick(ar: 'لم يبدأ', en: 'Not started');
  String get statusInProgress => _pick(ar: 'قيد التقدم', en: 'In progress');
  String get statusCompleted => _pick(ar: 'مكتمل', en: 'Completed');

  String lessonsCompleted(int completed, int total) => _pick(
    ar: 'أكملت $completed من $total',
    en: '$completed of $total completed',
  );

  String percentComplete(double progress) {
    final percent = (progress * 100).round();
    // Isolate the number so "%" stays attached to it inside Arabic text.
    final isolatedPercent = '$_ltrIsolate$percent%$_popIsolate';
    return _pick(ar: 'مكتمل $isolatedPercent', en: '$percent% complete');
  }

  String lessonCount(int count) {
    if (!_isArabic) {
      if (count == 0) return 'No lessons';
      return count == 1 ? '1 lesson' : '$count lessons';
    }
    return switch (count) {
      0 => 'لا توجد دروس',
      1 => 'درس واحد',
      2 => 'درسان',
      >= 3 && <= 10 => '$count دروس',
      _ => '$count درسًا',
    };
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppConstants.supportedLocales.any(
    (supported) => supported.languageCode == locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
