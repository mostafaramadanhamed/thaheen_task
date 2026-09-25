import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/player_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/duration_formatter.dart';
import '../cubit/lesson_player_cubit.dart';
import '../cubit/lesson_player_state.dart';
import 'playback_speed_selector.dart';
import 'seek_bar.dart';

/// Overlay controls drawn on top of the video.
///
/// Media controls stay left-to-right in both languages: the timeline and
/// rewind/forward icons describe playback direction, not reading direction.
class VideoControls extends StatelessWidget {
  const VideoControls({
    super.key,
    required this.state,
    required this.isFullscreen,
    required this.onToggleFullscreen,
    required this.onInteraction,
  });

  final LessonPlayerReady state;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  /// Called on any control tap so the overlay can restart its hide timer.
  final VoidCallback onInteraction;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LessonPlayerCubit>();
    final l10n = context.l10n;

    void run(VoidCallback action) {
      onInteraction();
      action();
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black26, Colors.black54],
          ),
        ),
        child: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: Stack(
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.rewind,
                      iconSize: 32,
                      onPressed: () =>
                          run(() => cubit.seekBy(-PlayerConstants.seekStep)),
                      icon: const Icon(Icons.replay_10_rounded),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      tooltip: state.isPlaying ? l10n.pause : l10n.play,
                      iconSize: 56,
                      onPressed: () => run(cubit.togglePlayPause),
                      icon: Icon(
                        state.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                      ),
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      tooltip: l10n.fastForward,
                      iconSize: 32,
                      onPressed: () =>
                          run(() => cubit.seekBy(PlayerConstants.seekStep)),
                      icon: const Icon(Icons.forward_10_rounded),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 0,
                child: Row(
                  children: [
                    _TimeLabel(state.position),
                    Expanded(
                      child: SeekBar(
                        position: state.position,
                        duration: state.duration,
                        onSeek: (position) => run(() => cubit.seekTo(position)),
                      ),
                    ),
                    _TimeLabel(state.duration),
                    PlaybackSpeedSelector(
                      speed: state.playbackSpeed,
                      onSelected: (speed) =>
                          run(() => cubit.setPlaybackSpeed(speed)),
                    ),
                    IconButton(
                      tooltip: isFullscreen
                          ? l10n.exitFullscreen
                          : l10n.enterFullscreen,
                      onPressed: () => run(onToggleFullscreen),
                      icon: Icon(
                        isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  const _TimeLabel(this.time);

  final Duration time;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(time),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
