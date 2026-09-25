import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../../../core/widgets/course_thumbnail.dart';
import '../../../core/widgets/labeled_progress_bar.dart';
import '../../../domain/entities/course.dart';

class CourseHeader extends StatelessWidget {
  const CourseHeader({
    super.key,
    required this.course,
    required this.completedLessons,
    required this.progress,
  });

  final Course course;
  final int completedLessons;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mutedColor = context.colorScheme.onSurfaceVariant;
    final hasLessons = course.lessonCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CourseThumbnail(assetPath: course.thumbnailPath),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.localize(course.title),
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.person_outline_rounded, size: 18, color: mutedColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.localize(course.instructor),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                ),
              ),
            ),
          ],
        ),
        if (hasLessons) ...[
          const SizedBox(height: 16),
          Text(
            l10n.lessonsCompleted(completedLessons, course.lessonCount),
            style: context.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          LabeledProgressBar(progress: progress),
        ],
        const SizedBox(height: 20),
        Text(l10n.aboutCourse, style: context.textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(
          context.localize(course.description),
          style: context.textTheme.bodyMedium?.copyWith(color: mutedColor),
        ),
      ],
    );
  }
}
