import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/features/course_details/screens/course_details_screen.dart';
import 'package:thaheen_task/features/courses/screens/courses_screen.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_player_cubit.dart';
import 'package:thaheen_task/features/lesson_player/screens/lesson_player_screen.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_video_player_platform.dart';
import '../helpers/pump_helpers.dart';

GoRouter _router(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));

Future<void> _go(WidgetTester tester, String location) async {
  _router(tester).go(location);
  await tester.pumpAndSettle();
  await pumpUntilLoaded(tester);
}

Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('deep link to a lesson goes back to its course, then home', (
    tester,
  ) async {
    await launchApp(tester);

    await _go(tester, '/courses/anatomy/lessons/anatomy_l1');
    expect(find.byType(LessonPlayerScreen), findsOneWidget);

    await _goBack(tester);
    expect(find.byType(CourseDetailsScreen), findsOneWidget);

    await _goBack(tester);
    expect(find.byType(CoursesScreen), findsOneWidget);
  });

  testWidgets('next lesson replaces the player instead of stacking it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      StorageKeys.lessonProgress:
          '{"anatomy_l1": {"position": 10, "completed": true}}',
    });
    await launchApp(tester);
    await _go(tester, '/courses/anatomy/lessons/anatomy_l1');

    await tester.tap(find.text('الدرس التالي'));
    await tester.pumpAndSettle();
    await pumpUntilLoaded(tester);

    final cubit = tester
        .element(find.byType(LessonPlayerScreen))
        .read<LessonPlayerCubit>();
    expect(cubit.lessonId, 'anatomy_l2');

    await _goBack(tester);
    expect(find.byType(CourseDetailsScreen), findsOneWidget);
  });

  testWidgets('unknown course shows a friendly not-found message', (
    tester,
  ) async {
    await launchApp(tester);

    await _go(tester, '/courses/missing');

    expect(find.text('الدورة غير موجودة'), findsOneWidget);
  });

  testWidgets('unknown path shows the not-found screen', (tester) async {
    await launchApp(tester);

    await _go(tester, '/does-not-exist');

    expect(find.text('الصفحة غير موجودة'), findsOneWidget);
  });
}
