import 'package:flutter/material.dart';

/// Semantic colors that Material's [ColorScheme] does not provide.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({required this.success});

  static const AppColors light = AppColors(success: Color(0xFF2E7D32));
  static const AppColors dark = AppColors(success: Color(0xFF81C784));

  /// Positive state, such as a completed lesson.
  final Color success;

  @override
  AppColors copyWith({Color? success}) =>
      AppColors(success: success ?? this.success);

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(success: Color.lerp(success, other.success, t)!);
  }
}
