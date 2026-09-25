import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/app.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/features/course_details/screens/course_details_screen.dart';

import 'helpers/pump_helpers.dart';
import 'helpers/repositories.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final progressRepository = await createProgressRepository();
  await tester.pumpWidget(
    ThaheenApp(
      courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
      progressRepository: progressRepository,
    ),
  );
  await pumpUntilLoaded(tester);
}

void main() {
  testWidgets('shows the Arabic courses screen in RTL', (tester) async {
    await _pumpApp(tester);

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('أساسيات علم التشريح'), findsOneWidget);
    expect(find.text('تابع المشاهدة'), findsNothing);

    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('opens course details and blocks a locked lesson', (
    tester,
  ) async {
    await _pumpApp(tester);

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
