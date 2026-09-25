import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../extensions/context_extensions.dart';
import '../extensions/theme_extensions.dart';
import '../theme/theme_cubit.dart';

/// Toggles between light and dark mode. The icon shows the mode the user
/// will switch to.
class ThemeSwitchButton extends StatelessWidget {
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      // Matches the language switch next to it in the app bar.
      color: context.colorScheme.primary,
      tooltip: isDark
          ? context.l10n.switchToLightMode
          : context.l10n.switchToDarkMode,
      onPressed: () =>
          context.read<ThemeCubit>().toggle(currentBrightness: brightness),
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
    );
  }
}
