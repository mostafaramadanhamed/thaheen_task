import 'package:flutter/material.dart';

import '../../../core/constants/player_constants.dart';
import '../../../core/extensions/context_extensions.dart';

class PlaybackSpeedSelector extends StatelessWidget {
  const PlaybackSpeedSelector({
    super.key,
    required this.speed,
    required this.onSelected,
  });

  final double speed;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: context.l10n.playbackSpeed,
      initialValue: speed,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in PlayerConstants.playbackSpeeds)
          CheckedPopupMenuItem(
            value: option,
            checked: option == speed,
            child: Text(_formatSpeed(option)),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text(
          _formatSpeed(speed),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// `1.0` → `1x`, `1.25` → `1.25x`.
String _formatSpeed(double speed) {
  final text = speed == speed.roundToDouble()
      ? speed.toStringAsFixed(0)
      : speed.toString();
  return '${text}x';
}
