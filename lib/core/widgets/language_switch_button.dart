import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../extensions/context_extensions.dart';
import '../localization/localization_cubit.dart';

/// Switches between Arabic and English. The label names the language the
/// user will switch to, written in that language.
class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextButton.icon(
      onPressed: context.read<LocalizationCubit>().toggleLanguage,
      icon: const Icon(Icons.translate_rounded),
      label: Text(l10n.otherLanguageName, semanticsLabel: l10n.switchLanguage),
    );
  }
}
