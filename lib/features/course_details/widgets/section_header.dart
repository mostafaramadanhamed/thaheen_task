import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../domain/entities/section.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.section});

  final Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 20, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.localize(section.title),
              style: context.textTheme.titleSmall?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.lessonCount(section.lessons.length),
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
