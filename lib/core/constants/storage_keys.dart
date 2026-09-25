abstract final class StorageKeys {
  /// Single JSON entry holding progress for every lesson, keyed by lesson id.
  static const String lessonProgress = 'lesson_progress';

  /// Selected UI language code (`ar` or `en`).
  static const String languageCode = 'language_code';

  /// Selected theme mode (`light` or `dark`); absent means follow the system.
  static const String themeMode = 'theme_mode';

  /// Last playback speed chosen in the player, applied to every lesson.
  static const String playbackSpeed = 'playback_speed';
}
