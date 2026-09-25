import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/app.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/local/progress_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';
import 'package:thaheen_task/features/course_details/screens/course_details_screen.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_player_cubit.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_player_state.dart';
import 'package:thaheen_task/features/lesson_player/screens/lesson_player_screen.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import '../helpers/fake_video_player_platform.dart';
import '../helpers/pump_helpers.dart';

const _anatomyTitle = 'أساسيات علم التشريح';
const _firstLessonTitle = 'ما هو علم التشريح؟';
const _secondLessonTitle = 'المصطلحات التشريحية';
const _continueWatching = 'تابع المشاهدة';

/// Launches the app on top of the persisted [SharedPreferences], the way a
/// real cold start would.
Future<void> _launchApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ThaheenApp(
      key: UniqueKey(),
      courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
      progressRepository: ProgressRepository(
        ProgressLocalDataSource(preferences),
      ),
    ),
  );
  await pumpUntilLoaded(tester);
}

Future<void> _openLesson(WidgetTester tester, String lessonTitle) async {
  await tester.tap(find.text(_anatomyTitle));
  await tester.pumpAndSettle();
  await pumpUntilLoaded(tester);

  final lesson = find.text(lessonTitle);
  await tester.scrollUntilVisible(
    lesson,
    200,
    scrollable: find
        .descendant(
          of: find.byType(CourseDetailsScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.tap(lesson);
  await tester.pumpAndSettle();
  await pumpUntilLoaded(tester);
}

LessonPlayerCubit _playerCubit(WidgetTester tester) =>
    tester.element(find.byType(LessonPlayerScreen)).read<LessonPlayerCubit>();

/// Taps the app bar back button. `tester.pageBack()` looks for the English
/// "Back" tooltip, which does not exist in the Arabic UI.
Future<void> _goBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).last);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('partially watched lesson shows Continue Watching and resumes '
      'after an app restart', (tester) async {
    await _launchApp(tester);
    expect(find.text(_continueWatching), findsNothing);

    await _openLesson(tester, _firstLessonTitle);
    await _playerCubit(tester).seekTo(const Duration(seconds: 40));
    await tester.pump();
    await _goBack(tester);
    await _goBack(tester);

    expect(find.text(_continueWatching), findsOneWidget);
    expect(find.text(_firstLessonTitle), findsOneWidget);

    // Cold start: new repositories reading the same persisted storage.
    await _launchApp(tester);
    expect(find.text(_continueWatching), findsOneWidget);

    await tester.tap(find.text(_firstLessonTitle));
    await tester.pumpAndSettle();
    await pumpUntilLoaded(tester);

    final state = _playerCubit(tester).state as LessonPlayerReady;
    expect(state.position, const Duration(seconds: 40));
    await _goBack(tester);
  });

  testWidgets('completing a lesson unlocks the next one', (tester) async {
    await _launchApp(tester);
    await _openLesson(tester, _firstLessonTitle);

    await _playerCubit(tester).seekTo(const Duration(seconds: 90));
    await tester.pump();
    await tester.pump(); // The snackbar is added on the frame after the state.
    expect(find.text('أحسنت! اكتمل الدرس'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await _goBack(tester);

    final secondLessonTile = find.ancestor(
      of: find.text(_secondLessonTitle),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: secondLessonTile, matching: find.text('لم يبدأ')),
      findsOneWidget,
    );

    // A completed lesson is not a Continue Watching candidate.
    await _goBack(tester);
    expect(find.text(_continueWatching), findsNothing);
  });
}
