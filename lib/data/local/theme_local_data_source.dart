import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

class ThemeLocalDataSource {
  const ThemeLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  /// Returns the saved mode, or [ThemeMode.system] if none or unknown.
  ThemeMode readThemeMode() {
    final saved = _preferences.getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    await _preferences.setString(StorageKeys.themeMode, mode.name);
  }
}
