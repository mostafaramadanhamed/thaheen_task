import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thaheen_task/core/constants/player_constants.dart';
import 'package:thaheen_task/data/local/notes_local_data_source.dart';
import 'package:thaheen_task/data/repositories/notes_repository.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_notes_cubit.dart';
import 'package:thaheen_task/features/lesson_player/cubit/lesson_notes_state.dart';

void main() {
  late NotesRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    repository = NotesRepository(NotesLocalDataSource(preferences));
  });

  LessonNotesCubit createCubit() =>
      LessonNotesCubit(lessonId: 'lesson_1', notesRepository: repository);

  test('starts with the saved note', () async {
    await repository.saveNote('lesson_1', 'saved note');

    final cubit = createCubit();

    expect(cubit.state, const LessonNotesState(text: 'saved note'));
    await cubit.close();
  });

  test('saves shortly after the user stops typing', () async {
    final cubit = createCubit();

    cubit.updateNote('first draft');
    expect(cubit.state.status, NoteSaveStatus.saving);
    expect(repository.getNote('lesson_1'), '');

    await Future<void>.delayed(
      PlayerConstants.noteSaveDelay + const Duration(milliseconds: 100),
    );

    expect(repository.getNote('lesson_1'), 'first draft');
    expect(cubit.state.status, NoteSaveStatus.saved);
    await cubit.close();
  });

  test('saves a pending note when closed', () async {
    final cubit = createCubit();

    cubit.updateNote('typed right before leaving');
    await cubit.close();

    expect(repository.getNote('lesson_1'), 'typed right before leaving');
  });
}
