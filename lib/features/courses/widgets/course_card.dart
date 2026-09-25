import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/course_thumbnail.dart';
import '../../../core/widgets/labeled_progress_bar.dart';
import '../../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.progress,
    this.onTap,
  });

  final Course course;
  final double progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final hasLessons = course.lessonCount > 0;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CourseThumbnail(assetPath: course.thumbnailPath),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.localize(course.title),
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: context.localize(course.instructor),
                    style: mutedStyle,
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.play_lesson_outlined,
                    label: context.l10n.lessonCount(course.lessonCount),
                    style: mutedStyle,
                  ),
                  const SizedBox(height: 12),
                  if (hasLessons)
                    LabeledProgressBar(progress: progress)
                  else
                    Text(context.l10n.noLessonsYet, style: mutedStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.style});

  final IconData icon;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: style?.color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
