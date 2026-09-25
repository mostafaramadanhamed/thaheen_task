import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  AppColors get appColors => theme.extension<AppColors>() ?? AppColors.light;
}
