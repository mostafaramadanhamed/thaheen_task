import 'package:flutter/material.dart';

import 'app_message_view.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppMessageView(icon: icon, title: title, message: message);
  }
}
