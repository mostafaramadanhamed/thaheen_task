import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/player_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/app_loading_view.dart';
import '../cubit/lesson_player_cubit.dart';
import '../cubit/lesson_player_state.dart';
import '../widgets/lesson_info_panel.dart';
import '../widgets/player_video_view.dart';

class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({super.key});

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  bool _isFullscreen = false;

  @override
  void dispose() {
    if (_isFullscreen) unawaited(_applySystemUi(fullscreen: false));
    super.dispose();
  }

  Future<void> _setFullscreen(bool fullscreen) async {
    setState(() => _isFullscreen = fullscreen);
    await _applySystemUi(fullscreen: fullscreen);
  }

  Future<void> _applySystemUi({required bool fullscreen}) async {
    await SystemChrome.setPreferredOrientations(
      fullscreen
          ? PlayerConstants.fullscreenOrientations
          : PlayerConstants.portraitOrientations,
    );
    await SystemChrome.setEnabledSystemUIMode(
      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  void _showCompletedMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.lessonCompletedMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_setFullscreen(false));
      },
      child: BlocConsumer<LessonPlayerCubit, LessonPlayerState>(
        listenWhen: (previous, current) =>
            previous is LessonPlayerReady &&
            current is LessonPlayerReady &&
            !previous.isCompleted &&
            current.isCompleted,
        listener: (context, state) => _showCompletedMessage(context),
        builder: (context, state) {
          if (state is LessonPlayerReady && _isFullscreen) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: PlayerVideoView(
                state: state,
                isFullscreen: true,
                onToggleFullscreen: () => _setFullscreen(false),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(),
            body: switch (state) {
              LessonPlayerInitial() ||
              LessonPlayerLoading() => const AppLoadingView(),
              LessonPlayerError() => _PlayerErrorView(failure: state.failure),
              LessonPlayerReady() => Column(
                children: [
                  PlayerVideoView(
                    state: state,
                    isFullscreen: false,
                    onToggleFullscreen: () => _setFullscreen(true),
                  ),
                  Expanded(child: LessonInfoPanel(state: state)),
                ],
              ),
            },
          );
        },
      ),
    );
  }
}

class _PlayerErrorView extends StatelessWidget {
  const _PlayerErrorView({required this.failure});

  final LessonPlayerFailure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final retry = context.read<LessonPlayerCubit>().initialize;

    return switch (failure) {
      LessonPlayerFailure.notFound => AppErrorView(
        title: l10n.lessonNotFoundTitle,
      ),
      LessonPlayerFailure.locked => AppErrorView(
        title: l10n.lessonLockedTitle,
        message: l10n.lessonLockedMessage,
      ),
      LessonPlayerFailure.loadFailed => AppErrorView(
        title: l10n.courseDetailsErrorTitle,
        message: l10n.coursesErrorMessage,
        onRetry: retry,
      ),
      LessonPlayerFailure.videoUnavailable => AppErrorView(
        title: l10n.videoErrorTitle,
        message: l10n.videoErrorMessage,
        onRetry: retry,
      ),
    };
  }
}
