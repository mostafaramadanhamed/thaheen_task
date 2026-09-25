import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/app.dart';
import 'package:thaheen_task/core/localization/localization_cubit.dart';
import 'package:thaheen_task/core/theme/theme_cubit.dart';
import 'package:thaheen_task/data/local/course_local_data_source.dart';
import 'package:thaheen_task/data/local/language_local_data_source.dart';
import 'package:thaheen_task/data/local/notes_local_data_source.dart';
import 'package:thaheen_task/data/local/playback_speed_local_data_source.dart';
import 'package:thaheen_task/data/local/progress_local_data_source.dart';
import 'package:thaheen_task/data/local/theme_local_data_source.dart';
import 'package:thaheen_task/data/repositories/course_repository.dart';
import 'package:thaheen_task/data/repositories/notes_repository.dart';
import 'package:thaheen_task/data/repositories/progress_repository.dart';

import 'pump_helpers.dart';

/// Launches the full app on a phone-sized screen, built from the persisted
/// [SharedPreferences] exactly like `main.dart`. Calling it again simulates
/// a cold start on the same storage.
Future<void> launchApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final preferences = await SharedPreferences.getInstance();
  final localizationCubit = LocalizationCubit(
    LanguageLocalDataSource(preferences),
  );
  addTearDown(localizationCubit.close);
  final themeCubit = ThemeCubit(ThemeLocalDataSource(preferences));
  addTearDown(themeCubit.close);

  await tester.pumpWidget(
    ThaheenApp(
      key: UniqueKey(),
      courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
      progressRepository: ProgressRepository(
        ProgressLocalDataSource(preferences),
      ),
      localizationCubit: localizationCubit,
      themeCubit: themeCubit,
      playbackSpeedDataSource: PlaybackSpeedLocalDataSource(preferences),
      notesRepository: NotesRepository(NotesLocalDataSource(preferences)),
    ),
  );
  await pumpUntilLoaded(tester);
}
