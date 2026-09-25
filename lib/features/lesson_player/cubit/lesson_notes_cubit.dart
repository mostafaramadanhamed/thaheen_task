import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/player_constants.dart';
import '../../../data/repositories/notes_repository.dart';
import 'lesson_notes_state.dart';

/// Holds the note for one lesson and saves it shortly after the user stops
/// typing, plus once more when the lesson is closed.
class LessonNotesCubit extends Cubit<LessonNotesState> {
  LessonNotesCubit({
    required this.lessonId,
    required NotesRepository notesRepository,
  }) : _notesRepository = notesRepository,
       super(LessonNotesState(text: notesRepository.getNote(lessonId)));

  final String lessonId;
  final NotesRepository _notesRepository;
  Timer? _saveTimer;

  void updateNote(String text) {
    if (text == state.text) return;

    emit(state.copyWith(text: text, status: NoteSaveStatus.saving));
    _saveTimer?.cancel();
    _saveTimer = Timer(PlayerConstants.noteSaveDelay, _save);
  }

  Future<void> _save() async {
    _saveTimer?.cancel();
    await _notesRepository.saveNote(lessonId, state.text);
    if (!isClosed) emit(state.copyWith(status: NoteSaveStatus.saved));
  }

  @override
  Future<void> close() async {
    if (_saveTimer?.isActive ?? false) await _save();
    return super.close();
  }
}
