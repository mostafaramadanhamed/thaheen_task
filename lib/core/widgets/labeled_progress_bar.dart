import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// A rounded progress bar with a "N% complete" label underneath.
class LabeledProgressBar extends StatelessWidget {
  const LabeledProgressBar({super.key, required this.progress});

  /// Value from 0.0 to 1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: progress, minHeight: 6),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.percentComplete(progress),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
