import 'package:equatable/equatable.dart';

class LessonPlayerArguments extends Equatable {
  const LessonPlayerArguments({required this.courseId, required this.lessonId});

  final String courseId;
  final String lessonId;

  @override
  List<Object?> get props => [courseId, lessonId];
}
