import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/core/utils/duration_formatter.dart';

void main() {
  group('formatDuration', () {
    test('formats minutes and seconds', () {
      expect(formatDuration(Duration.zero), '0:00');
      expect(formatDuration(const Duration(seconds: 9)), '0:09');
      expect(formatDuration(const Duration(minutes: 12, seconds: 5)), '12:05');
    });

    test('includes hours when needed', () {
      expect(
        formatDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('treats negative durations as zero', () {
      expect(formatDuration(const Duration(seconds: -5)), '0:00');
    });
  });
}
