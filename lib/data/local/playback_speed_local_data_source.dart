import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/player_constants.dart';
import '../../core/constants/storage_keys.dart';

class PlaybackSpeedLocalDataSource {
  const PlaybackSpeedLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  /// Returns the saved speed, or the default if none is saved or the saved
  /// value is not one of the supported speeds.
  double readSpeed() {
    final saved = _preferences.getDouble(StorageKeys.playbackSpeed);
    return PlayerConstants.playbackSpeeds.contains(saved)
        ? saved!
        : PlayerConstants.defaultPlaybackSpeed;
  }

  Future<void> writeSpeed(double speed) async {
    await _preferences.setDouble(StorageKeys.playbackSpeed, speed);
  }
}
