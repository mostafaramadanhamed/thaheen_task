import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/player_constants.dart';
import '../cubit/lesson_player_cubit.dart';
import '../cubit/lesson_player_state.dart';
import 'video_controls.dart';

/// Video surface with tap-to-toggle controls that hide automatically
/// while the video is playing.
class PlayerVideoView extends StatefulWidget {
  const PlayerVideoView({
    super.key,
    required this.state,
    required this.isFullscreen,
    required this.onToggleFullscreen,
  });

  final LessonPlayerReady state;
  final bool isFullscreen;
  final VoidCallback onToggleFullscreen;

  @override
  State<PlayerVideoView> createState() => _PlayerVideoViewState();
}

class _PlayerVideoViewState extends State<PlayerVideoView> {
  bool _controlsVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleHide();
  }

  @override
  void didUpdateWidget(PlayerVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.isPlaying != widget.state.isPlaying) {
      _showControls();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _showControls() {
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _scheduleHide();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  /// Controls stay visible while paused so the user can always resume.
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!widget.state.isPlaying) return;
    _hideTimer = Timer(PlayerConstants.controlsAutoHideDelay, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LessonPlayerCubit>().controller;

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: widget.state.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (controller != null) VideoPlayer(controller),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleControls,
              ),
              if (widget.state.isBuffering)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              IgnorePointer(
                ignoring: !_controlsVisible,
                child: AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControls,
                    child: VideoControls(
                      state: widget.state,
                      isFullscreen: widget.isFullscreen,
                      onToggleFullscreen: widget.onToggleFullscreen,
                      onInteraction: _scheduleHide,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
