import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class NextLessonButton extends StatelessWidget {
  const NextLessonButton({super.key, required this.onPressed});

  /// `null` disables the button while the next lesson is still locked.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      // Placed at the end and mirrored automatically in RTL.
      iconAlignment: IconAlignment.end,
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(context.l10n.nextLesson),
    );
  }
}
