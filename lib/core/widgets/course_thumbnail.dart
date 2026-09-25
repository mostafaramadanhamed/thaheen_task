import 'package:flutter/material.dart';

import '../extensions/theme_extensions.dart';

/// Bundled course image with a neutral placeholder if the asset is missing.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({super.key, required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => ColoredBox(
        color: context.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.school_outlined,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
