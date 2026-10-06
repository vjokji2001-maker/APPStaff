import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:staff_mate/main.dart';

void main() {
  testWidgets('MyApp loads its startup splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
