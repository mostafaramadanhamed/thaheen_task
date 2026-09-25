import '../../domain/entities/localized_text.dart';
import 'json_reader.dart';

class LocalizedTextModel {
  const LocalizedTextModel({required this.ar, required this.en});

  factory LocalizedTextModel.fromJson(JsonMap json) {
    return LocalizedTextModel(
      ar: json.requireString('ar'),
      en: json.requireString('en'),
    );
  }

  final String ar;
  final String en;

  LocalizedText toEntity() => LocalizedText(ar: ar, en: en);
}
