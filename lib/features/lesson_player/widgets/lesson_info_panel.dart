import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/navigation_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../cubit/lesson_player_state.dart';
import 'next_lesson_button.dart';

/// Lesson details and the Next Lesson action shown under the video.
class LessonInfoPanel extends StatelessWidget {
  const LessonInfoPanel({super.key, required this.state});

  final LessonPlayerReady state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nextLesson = state.nextLesson;

    return ListView(
      padding: const EdgeInsetsDirectional.all(16),
      children: [
        Text(
          context.localize(state.lesson.title),
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          context.localize(state.course.title),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        if (state.isCourseFinished)
          _CourseFinishedCard(onBack: Navigator.of(context).pop)
        else ...[
          NextLessonButton(
            onPressed: state.canGoNext && nextLesson != null
                ? () => context.replaceWithLessonPlayer(
                    courseId: state.course.id,
                    lessonId: nextLesson.id,
                  )
                : null,
          ),
          if (!state.isCompleted) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.completeToUnlockNext,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _CourseFinishedCard extends StatelessWidget {
  const _CourseFinishedCard({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.courseCompletedTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onBack,
              child: Text(context.l10n.backToCourse),
            ),
          ],
        ),
      ),
    );
  }
}
