import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/theme_local_data_source.dart';

/// Holds the app [ThemeMode]. Follows the system until the user picks
/// light or dark, then persists that choice.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(ThemeLocalDataSource dataSource)
    : _dataSource = dataSource,
      super(dataSource.readThemeMode());

  final ThemeLocalDataSource _dataSource;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) return;

    emit(mode);
    try {
      await _dataSource.writeThemeMode(mode);
    } on Exception catch (error, stackTrace) {
      log(
        'Failed to persist theme mode',
        name: 'ThemeCubit',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Switches to the opposite of what is currently shown, which may come
  /// from the system setting.
  Future<void> toggle({required Brightness currentBrightness}) {
    return setThemeMode(
      currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}
