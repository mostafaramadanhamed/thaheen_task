import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/player_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/theme_extensions.dart';
import '../cubit/lesson_notes_cubit.dart';
import '../cubit/lesson_notes_state.dart';

/// Free-text note for the current lesson, saved automatically.
class LessonNotesField extends StatefulWidget {
  const LessonNotesField({super.key});

  @override
  State<LessonNotesField> createState() => _LessonNotesFieldState();
}

class _LessonNotesFieldState extends State<LessonNotesField> {
  late final TextEditingController _controller = TextEditingController(
    text: context.read<LessonNotesCubit>().state.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mutedStyle = context.textTheme.labelMedium?.copyWith(
      color: context.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note_rounded, color: context.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.myNotes, style: context.textTheme.titleMedium),
            ),
            BlocBuilder<LessonNotesCubit, LessonNotesState>(
              builder: (context, state) {
                if (state.text.trim().isEmpty) return const SizedBox.shrink();
                return Text(
                  state.status == NoteSaveStatus.saving
                      ? l10n.noteSaving
                      : l10n.noteSaved,
                  style: mutedStyle,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: context.read<LessonNotesCubit>().updateNote,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          minLines: 3,
          maxLines: 8,
          maxLength: PlayerConstants.noteMaxLength,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(hintText: l10n.notesHint),
        ),
      ],
    );
  }
}
