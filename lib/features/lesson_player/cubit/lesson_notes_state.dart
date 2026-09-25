import 'package:equatable/equatable.dart';

enum NoteSaveStatus { saved, saving }

class LessonNotesState extends Equatable {
  const LessonNotesState({
    required this.text,
    this.status = NoteSaveStatus.saved,
  });

  final String text;
  final NoteSaveStatus status;

  LessonNotesState copyWith({String? text, NoteSaveStatus? status}) {
    return LessonNotesState(
      text: text ?? this.text,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [text, status];
}
