import 'package:equatable/equatable.dart';

/// Content text available in both supported languages.
class LocalizedText extends Equatable {
  const LocalizedText({required this.ar, required this.en});

  final String ar;
  final String en;

  /// Returns the text for [languageCode], falling back to the other
  /// language when the requested translation is empty.
  String resolve(String languageCode) {
    final preferred = languageCode == 'en' ? en : ar;
    final fallback = languageCode == 'en' ? ar : en;
    return preferred.isNotEmpty ? preferred : fallback;
  }

  @override
  List<Object?> get props => [ar, en];
}
