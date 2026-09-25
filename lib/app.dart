import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/localization_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'data/local/playback_speed_local_data_source.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/progress_repository.dart';

class ThaheenApp extends StatefulWidget {
  const ThaheenApp({
    super.key,
    required this.courseRepository,
    required this.progressRepository,
    required this.localizationCubit,
    required this.themeCubit,
    required this.playbackSpeedDataSource,
  });

  final CourseRepository courseRepository;
  final ProgressRepository progressRepository;
  final LocalizationCubit localizationCubit;
  final ThemeCubit themeCubit;
  final PlaybackSpeedLocalDataSource playbackSpeedDataSource;

  @override
  State<ThaheenApp> createState() => _ThaheenAppState();
}

class _ThaheenAppState extends State<ThaheenApp> {
  /// Created once so navigation state survives locale and theme rebuilds.
  final GoRouter _router = AppRouter.createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.courseRepository),
        RepositoryProvider.value(value: widget.progressRepository),
        RepositoryProvider.value(value: widget.playbackSpeedDataSource),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: widget.localizationCubit),
          BlocProvider.value(value: widget.themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) =>
              BlocBuilder<LocalizationCubit, Locale>(
                builder: (context, locale) => MaterialApp.router(
                  title: AppConstants.appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: AppConstants.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  routerConfig: _router,
                ),
              ),
        ),
      ),
    );
  }
}
