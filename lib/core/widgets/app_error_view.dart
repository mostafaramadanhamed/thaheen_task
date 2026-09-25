import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../extensions/theme_extensions.dart';
import 'app_message_view.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
  });

  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final onRetry = this.onRetry;

    return AppMessageView(
      icon: Icons.error_outline_rounded,
      iconColor: context.colorScheme.error,
      title: title,
      message: message,
      action: onRetry == null
          ? null
          : FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.retry),
            ),
    );
  }
}
