/// SearchBarWidget Tests
///
/// Testing the visual search input component.
/// Currently just verifies UI elements render correctly.
/// Search functionality will be tested when implemented.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/widgets/search_bar_widget.dart';

void main() {
  group('SearchBarWidget', () {
    /// Test #1: Widget displays search icon
    testWidgets('displays search icon', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(),
          ),
        ),
      );

      // ASSERT: Should find search icon
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    /// Test #2: Widget displays placeholder text
    testWidgets('displays placeholder text', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(),
          ),
        ),
      );

      // ASSERT: Should find placeholder
      expect(find.text('Search bookmarks, links or tags'), findsOneWidget);
    });

    /// Test #3: Widget displays custom placeholder
    testWidgets('displays custom placeholder', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              placeholder: 'Custom search text',
            ),
          ),
        ),
      );

      // ASSERT
      expect(find.text('Custom search text'), findsOneWidget);
    });

    /// Test #4: TextField is present
    testWidgets('contains TextField', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(),
          ),
        ),
      );

      // ASSERT
      expect(find.byType(TextField), findsOneWidget);
    });

    /// Test #5: onChanged callback works
    testWidgets('calls onChanged when text entered', (WidgetTester tester) async {
      // ARRANGE
      String? capturedText;

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              onChanged: (text) {
                capturedText = text;
              },
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');

      // ASSERT: Callback should have been called
      expect(capturedText, 'test query');
    });
  });
}

/// 🎓 Learning Summary: Testing User Input
///
/// **Testing Text Input:**
/// ```dart
/// await tester.enterText(find.byType(TextField), 'test query');
/// ```
///
/// This simulates user typing in the text field.
///
/// **Testing Callbacks:**
/// We capture the callback value to verify it was called:
/// ```dart
/// String? capturedText;
/// SearchBarWidget(
///   onChanged: (text) {
///     capturedText = text;  // Capture the value
///   },
/// )
/// ```
///
/// Then assert the captured value matches what we entered.
///
/// **Why These Tests Matter:**
/// 1. Verifies search icon is visible (users recognize it)
/// 2. Verifies placeholder guides users
/// 3. Verifies TextField is present (can be interacted with)
/// 4. Verifies onChanged works (for future search functionality)
///
/// **Next:**
/// Run tests, then use SearchBarWidget in home screen.
