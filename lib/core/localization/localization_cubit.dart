import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/local/language_local_data_source.dart';
import '../constants/app_constants.dart';

/// Holds the app locale and persists the user's language choice.
class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit(LanguageLocalDataSource dataSource)
    : _dataSource = dataSource,
      super(_resolve(dataSource.readLanguageCode()));

  final LanguageLocalDataSource _dataSource;

  bool get isArabic => state.languageCode == 'ar';

  Future<void> changeLanguage(String languageCode) async {
    final locale = _resolve(languageCode);
    if (locale == state) return;

    emit(locale);
    try {
      await _dataSource.writeLanguageCode(locale.languageCode);
    } on Exception catch (error, stackTrace) {
      log(
        'Failed to persist language',
        name: 'LocalizationCubit',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> toggleLanguage() => changeLanguage(isArabic ? 'en' : 'ar');

  /// Unknown or missing codes fall back to the Arabic default.
  static Locale _resolve(String? languageCode) {
    return AppConstants.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => AppConstants.defaultLocale,
    );
  }
}
