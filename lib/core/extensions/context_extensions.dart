import 'package:flutter/widgets.dart';

import '../../domain/entities/localized_text.dart';
import '../localization/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Resolves bundled course content to the current app language.
  String localize(LocalizedText text) => text.resolve(l10n.languageCode);
}
