import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/features/course_details/screens/course_details_screen.dart';

import 'helpers/app_harness.dart';
import 'helpers/pump_helpers.dart';

TextDirection _textDirection(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts in Arabic with an RTL layout', (tester) async {
    await launchApp(tester);

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('أساسيات علم التشريح'), findsOneWidget);
    expect(find.text('تابع المشاهدة'), findsNothing);
    expect(_textDirection(tester), TextDirection.rtl);
  });

  testWidgets('switches to English LTR and keeps it after a restart', (
    tester,
  ) async {
    await launchApp(tester);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('My Courses'), findsOneWidget);
    expect(find.text('Anatomy Fundamentals'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(_textDirection(tester), TextDirection.ltr);

    await launchApp(tester);

    expect(find.text('My Courses'), findsOneWidget);
    expect(_textDirection(tester), TextDirection.ltr);
  });

  testWidgets('opens course details and blocks a locked lesson', (
    tester,
  ) async {
    await launchApp(tester);

    await tester.tap(find.text('أساسيات علم التشريح'));
    await tester.pumpAndSettle();
    await pumpUntilLoaded(tester);

    final lockedLesson = find.text('المصطلحات التشريحية');
    await tester.scrollUntilVisible(
      lockedLesson,
      200,
      scrollable: find
          .descendant(
            of: find.byType(CourseDetailsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('محتوى الدورة'), findsOneWidget);

    await tester.tap(lockedLesson);
    await tester.pump();

    expect(
      find.text('هذا الدرس مقفل. أكمل الدرس السابق أولًا لفتحه.'),
      findsOneWidget,
    );
  });
}
