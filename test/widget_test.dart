// This is a basic Flutter widget test for RESOLVE app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resolve/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResolveApp());

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
