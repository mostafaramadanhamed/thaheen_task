import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/storage_keys.dart';
import 'package:thaheen_task/core/localization/localization_cubit.dart';
import 'package:thaheen_task/data/local/language_local_data_source.dart';

Future<LocalizationCubit> _createCubit([
  Map<String, Object> initialValues = const {},
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final preferences = await SharedPreferences.getInstance();
  return LocalizationCubit(LanguageLocalDataSource(preferences));
}

void main() {
  test('defaults to Arabic', () async {
    final cubit = await _createCubit();

    expect(cubit.state, const Locale('ar'));
    await cubit.close();
  });

  test('restores the saved language', () async {
    final cubit = await _createCubit({StorageKeys.languageCode: 'en'});

    expect(cubit.state, const Locale('en'));
    await cubit.close();
  });

  test('falls back to Arabic for an unsupported saved language', () async {
    final cubit = await _createCubit({StorageKeys.languageCode: 'fr'});

    expect(cubit.state, const Locale('ar'));
    await cubit.close();
  });

  test('toggling switches language and persists it', () async {
    final cubit = await _createCubit();

    await cubit.toggleLanguage();

    expect(cubit.state, const Locale('en'));
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(StorageKeys.languageCode), 'en');

    await cubit.toggleLanguage();
    expect(cubit.state, const Locale('ar'));
    expect(preferences.getString(StorageKeys.languageCode), 'ar');
    await cubit.close();
  });
}
