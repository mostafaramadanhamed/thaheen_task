import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thaheen_task/main.dart';

void main() {
  testWidgets('app starts with Arabic RTL layout', (tester) async {
    await tester.pumpWidget(const ThaheenApp());

    final context = tester.element(find.byType(Scaffold));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
