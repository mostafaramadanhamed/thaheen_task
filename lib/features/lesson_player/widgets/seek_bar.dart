import 'package:flutter/material.dart';

/// Slider over the video timeline. While dragging it shows the drag
/// position locally and only seeks once the drag ends.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inMilliseconds.toDouble();
    final current = widget.position.inMilliseconds.toDouble();
    final value = (_dragValue ?? current).clamp(0.0, max > 0 ? max : 0.0);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white30,
        thumbColor: Colors.white,
      ),
      child: Slider(
        value: value,
        max: max > 0 ? max : 1,
        onChanged: max > 0
            ? (newValue) => setState(() => _dragValue = newValue)
            : null,
        onChangeEnd: (newValue) {
          setState(() => _dragValue = null);
          widget.onSeek(Duration(milliseconds: newValue.round()));
        },
      ),
    );
  }
}
