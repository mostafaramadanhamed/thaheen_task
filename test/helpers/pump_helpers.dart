import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps until no loading indicator remains on screen. Real asset I/O
/// (e.g. `rootBundle`) does not advance inside the fake-async test zone,
/// so each attempt yields a little real time first.
Future<void> pumpUntilLoaded(WidgetTester tester) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
  throw TestFailure('Timed out waiting for loading to finish');
}
