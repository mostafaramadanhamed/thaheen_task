import 'package:equatable/equatable.dart';

import 'localized_text.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.videoPath,
  });

  final String id;
  final LocalizedText title;
  final int durationSeconds;
  final String videoPath;

  @override
  List<Object?> get props => [id, title, durationSeconds, videoPath];
}
