import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../domain/entities/lesson.dart';
import '../../../domain/entities/lesson_status.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.status,
    required this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    final accentColor = _accentColor(context.colorScheme);
    final duration = formatDuration(Duration(seconds: lesson.durationSeconds));

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      leading: CircleAvatar(
        backgroundColor: accentColor.withValues(alpha: 0.12),
        foregroundColor: accentColor,
        child: Icon(_icon),
      ),
      title: Text(
        context.localize(lesson.title),
        style: context.textTheme.bodyLarge?.copyWith(
          color: isLocked ? context.colorScheme.onSurfaceVariant : null,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 14,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(duration),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _label(context.l10n),
              style: TextStyle(color: accentColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (status) {
    LessonStatus.locked => Icons.lock_outline_rounded,
    LessonStatus.notStarted => Icons.play_arrow_rounded,
    LessonStatus.inProgress => Icons.timelapse_rounded,
    LessonStatus.completed => Icons.check_rounded,
  };

  Color _accentColor(ColorScheme colorScheme) => switch (status) {
    LessonStatus.locked => colorScheme.onSurfaceVariant,
    LessonStatus.notStarted => colorScheme.primary,
    LessonStatus.inProgress => colorScheme.tertiary,
    LessonStatus.completed => Colors.green.shade700,
  };

  String _label(AppLocalizations l10n) => switch (status) {
    LessonStatus.locked => l10n.statusLocked,
    LessonStatus.notStarted => l10n.statusNotStarted,
    LessonStatus.inProgress => l10n.statusInProgress,
    LessonStatus.completed => l10n.statusCompleted,
  };
}
