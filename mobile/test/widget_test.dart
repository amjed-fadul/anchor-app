import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App launches and shows welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnchorApp());

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to Anchor'), findsOneWidget);

    // Verify that the app bar title is displayed.
    expect(find.text('Anchor'), findsOneWidget);
  });
}
