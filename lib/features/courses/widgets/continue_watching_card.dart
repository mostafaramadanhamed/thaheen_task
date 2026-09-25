import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/course_thumbnail.dart';
import '../../../core/widgets/labeled_progress_bar.dart';
import '../../../domain/entities/continue_watching_item.dart';
import '../../../domain/services/completion_rule.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({super.key, required this.item, this.onTap});

  static const double _thumbnailWidth = 112;

  final ContinueWatchingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lessonProgress = watchedFraction(
      positionSeconds: item.progress.positionSeconds,
      durationSeconds: item.lesson.durationSeconds,
    );

    return Card(
      color: colorScheme.primaryContainer,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: _thumbnailWidth,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CourseThumbnail(assetPath: item.course.thumbnailPath),
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localize(item.lesson.title),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.localize(item.course.title),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    LabeledProgressBar(progress: lessonProgress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
