import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/player_constants.dart';
import 'core/localization/localization_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'data/local/course_local_data_source.dart';
import 'data/local/language_local_data_source.dart';
import 'data/local/progress_local_data_source.dart';
import 'data/local/theme_local_data_source.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    PlayerConstants.portraitOrientations,
  );
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ThaheenApp(
      courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
      progressRepository: ProgressRepository(
        ProgressLocalDataSource(preferences),
      ),
      localizationCubit: LocalizationCubit(
        LanguageLocalDataSource(preferences),
      ),
      themeCubit: ThemeCubit(ThemeLocalDataSource(preferences)),
    ),
  );
}
