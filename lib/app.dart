import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/router/route_names.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/progress_repository.dart';

class ThaheenApp extends StatelessWidget {
  const ThaheenApp({
    super.key,
    required this.courseRepository,
    required this.progressRepository,
  });

  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: courseRepository),
        RepositoryProvider.value(value: progressRepository),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        locale: AppConstants.defaultLocale,
        supportedLocales: AppConstants.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        initialRoute: RouteNames.courses,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
