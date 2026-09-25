import 'package:flutter/widgets.dart';

abstract final class AppConstants {
  static const String appTitle = 'Thaheen';

  static const Locale defaultLocale = Locale('ar');
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
}
