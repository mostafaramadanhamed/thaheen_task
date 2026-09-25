import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

class CourseSearchField extends StatefulWidget {
  const CourseSearchField({
    super.key,
    required this.initialQuery,
    required this.onChanged,
  });

  final String initialQuery;
  final ValueChanged<String> onChanged;

  @override
  State<CourseSearchField> createState() => _CourseSearchFieldState();
}

class _CourseSearchFieldState extends State<CourseSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: context.l10n.searchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: context.l10n.clearSearch,
                  onPressed: _clear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
      ),
    );
  }
}
