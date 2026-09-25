import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/app.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';

import 'helpers/repositories.dart';

void main() {
  testWidgets('shows the Arabic courses screen in RTL', (tester) async {
    final progressRepository = await createProgressRepository();

    await tester.pumpWidget(
      ThaheenApp(
        courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
        progressRepository: progressRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('أساسيات علم التشريح'), findsOneWidget);
    expect(find.text('تابع المشاهدة'), findsNothing);

    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
