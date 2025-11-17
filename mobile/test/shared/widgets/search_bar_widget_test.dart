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

    /// Test #6: Clear button is hidden when text is empty
    ///
    /// Why this matters:
    /// Clear button should only appear when there's text to clear.
    /// Keeps UI clean when nothing to clear.
    testWidgets('hides clear button when text is empty', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(),
          ),
        ),
      );

      // ASSERT: Clear button (close icon) should not be visible
      expect(find.byIcon(Icons.close), findsNothing);
    });

    /// Test #7: Clear button appears when text is entered
    ///
    /// Why this matters:
    /// Users need a quick way to clear search and return to all links.
    /// X button is universally recognized for "clear/delete".
    testWidgets('shows clear button when text is entered', (WidgetTester tester) async {
      // ACT
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(); // Rebuild to show clear button

      // ASSERT: Clear button should now be visible
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    /// Test #8: Tapping clear button clears text and calls onChanged
    ///
    /// Why this matters:
    /// Clear button should:
    /// 1. Clear the text field
    /// 2. Trigger onChanged with empty string (so search resets)
    testWidgets('clear button clears text and calls onChanged', (WidgetTester tester) async {
      // ARRANGE
      String? capturedText;

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

      // Enter text first
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump(); // Show clear button
      expect(capturedText, 'test query'); // Verify text was entered

      // ACT: Tap clear button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(); // Process the tap

      // ASSERT: onChanged should be called with empty string
      expect(capturedText, '');

      // Verify text field is actually empty
      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.controller?.text, '');

      // Verify clear button is hidden again
      expect(find.byIcon(Icons.close), findsNothing);
    });

    /// Test #9: Controller integration - external controller can control text
    ///
    /// Why this matters:
    /// Parent widgets (like HomeScreen) need to be able to clear search
    /// programmatically, not just through user interaction.
    testWidgets('accepts external controller', (WidgetTester tester) async {
      // ARRANGE
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              controller: controller,
            ),
          ),
        ),
      );

      // ACT: Set text via controller
      controller.text = 'controller text';
      await tester.pump();

      // ASSERT: Text should appear in field
      expect(find.text('controller text'), findsOneWidget);

      // Cleanup
      controller.dispose();
    });

    /// Test #10: Controller integration - external controller can clear text
    ///
    /// Why this matters:
    /// Parent widgets need to be able to clear search programmatically.
    /// Note: Setting controller.text directly doesn't trigger onChanged
    /// (onChanged is only triggered by user input via TextField).
    testWidgets('external controller can clear text', (WidgetTester tester) async {
      // ARRANGE
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBarWidget(
              controller: controller,
            ),
          ),
        ),
      );

      // ACT: Type text via user input (this triggers onChanged)
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Verify text is set
      expect(controller.text, 'test');
      expect(find.text('test'), findsOneWidget);

      // Clear via controller programmatically
      controller.clear();
      await tester.pump();

      // ASSERT: Text should be cleared
      expect(controller.text, '');
      expect(find.text('test'), findsNothing);

      // Cleanup
      controller.dispose();
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
