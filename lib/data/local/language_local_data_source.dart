import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

class LanguageLocalDataSource {
  const LanguageLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  String? readLanguageCode() =>
      _preferences.getString(StorageKeys.languageCode);

  Future<void> writeLanguageCode(String languageCode) async {
    await _preferences.setString(StorageKeys.languageCode, languageCode);
  }
}
