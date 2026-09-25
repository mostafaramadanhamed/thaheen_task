import 'package:equatable/equatable.dart';

import 'lesson.dart';
import 'localized_text.dart';

class Section extends Equatable {
  const Section({required this.id, required this.title, required this.lessons});

  final String id;
  final LocalizedText title;
  final List<Lesson> lessons;

  @override
  List<Object?> get props => [id, title, lessons];
}
