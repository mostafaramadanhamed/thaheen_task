import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/core/theme/theme_cubit.dart';
import 'package:thaheen_task/data/local/theme_local_data_source.dart';

Future<ThemeCubit> _createCubit([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return ThemeCubit(ThemeLocalDataSource(preferences));
}

void main() {
  test('follows the system theme by default', () async {
    final cubit = await _createCubit();

    expect(cubit.state, ThemeMode.system);
    await cubit.close();
  });

  test('restores the saved theme mode', () async {
    final cubit = await _createCubit({StorageKeys.themeMode: 'dark'});

    expect(cubit.state, ThemeMode.dark);
    await cubit.close();
  });

  test('falls back to system for an unknown saved value', () async {
    final cubit = await _createCubit({StorageKeys.themeMode: 'sepia'});

    expect(cubit.state, ThemeMode.system);
    await cubit.close();
  });

  test(
    'toggle switches away from the displayed brightness and persists',
    () async {
      final cubit = await _createCubit();

      await cubit.toggle(currentBrightness: Brightness.light);

      expect(cubit.state, ThemeMode.dark);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString(StorageKeys.themeMode), 'dark');

      await cubit.toggle(currentBrightness: Brightness.dark);
      expect(cubit.state, ThemeMode.light);
      expect(preferences.getString(StorageKeys.themeMode), 'light');
      await cubit.close();
    },
  );
}
