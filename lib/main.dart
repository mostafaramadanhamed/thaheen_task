import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local/course_local_data_source.dart';
import 'data/local/progress_local_data_source.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ThaheenApp(
      courseRepository: CourseRepository(CourseLocalDataSource(rootBundle)),
      progressRepository: ProgressRepository(
        ProgressLocalDataSource(preferences),
      ),
    ),
  );
}
