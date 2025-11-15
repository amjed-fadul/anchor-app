library;

/// Tests for CreateSpaceBottomSheet Widget
///
/// Following TDD - these tests are written BEFORE the widget implementation.
/// They define the expected behavior of the Create Space flow.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/spaces/widgets/create_space_bottom_sheet.dart';

void main() {
  group('CreateSpaceBottomSheet - Name Input Page', () {
    testWidgets('auto-focuses name input when sheet opens', (tester) async {
      // Arrange: Build widget
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: TextField should be focused
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, true);
    });

    testWidgets('displays correct title and description', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Title and description are visible
      expect(find.text('Create new space'), findsOneWidget);
      expect(
        find.textContaining('A space is a collection of bookmarks'),
        findsOneWidget,
      );
    });

    testWidgets('disables Next button when name is empty', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Next button should be disabled
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull); // null = disabled
    });

    testWidgets('enables Next button when name has text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Enter text
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();

      // Assert: Next button should be enabled
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNotNull); // not null = enabled
    });

    testWidgets('trims whitespace when validating name', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Enter only spaces
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // Assert: Next button should still be disabled
      final nextButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(nextButton.onPressed, isNull);
    });
  });

  group('CreateSpaceBottomSheet - Color Picker Page', () {
    testWidgets('navigates to color picker when Next is tapped',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Enter name and tap Next
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Assert: Should show color picker page
      expect(find.text('Pick a color'), findsOneWidget);
      expect(
        find.textContaining('Adding Color to your space'),
        findsOneWidget,
      );
    });

    testWidgets('displays 14 color options in grid', (tester) async {
      // Arrange: Navigate to color picker
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Assert: Should have 14 color containers
      final colorContainers = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration,
      );
      expect(colorContainers, findsNWidgets(14));
    });

    testWidgets('button is disabled when no color selected', (tester) async {
      // Arrange: Navigate to color picker
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Assert: Button should be disabled (showing "Next")
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Next'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('shows large preview when color is selected', (tester) async {
      // Arrange: Navigate to color picker
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Act: Tap first color
      final firstColor = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration,
      );
      await tester.tap(firstColor.first);
      await tester.pump();

      // Assert: Should show large preview (84x84)
      final largePreview = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 84 &&
            widget.constraints?.maxHeight == 84,
      );
      expect(largePreview, findsOneWidget);
    });

    testWidgets('changes button text to "Save and finish" when color selected',
        (tester) async {
      // Arrange: Navigate to color picker
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Act: Select a color
      final firstColor = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration,
      );
      await tester.tap(firstColor.first);
      await tester.pump();

      // Assert: Button text should change
      expect(find.widgetWithText(ElevatedButton, 'Save and finish'),
          findsOneWidget);
    });

    testWidgets('enables button when color is selected', (tester) async {
      // Arrange: Navigate to color picker
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CreateSpaceBottomSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Space');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
      await tester.pumpAndSettle();

      // Act: Select a color
      final firstColor = find.byWidgetPredicate(
        (widget) =>
            widget is GestureDetector &&
            widget.child is Container &&
            (widget.child as Container).decoration is BoxDecoration,
      );
      await tester.tap(firstColor.first);
      await tester.pump();

      // Assert: Button should be enabled
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save and finish'),
      );
      expect(button.onPressed, isNotNull);
    });
  });
}

/// 🎓 Learning Summary: Widget Testing in Flutter
///
/// **What is Widget Testing?**
/// Tests that verify UI behavior and user interactions.
/// Runs faster than integration tests, slower than unit tests.
///
/// **Key Testing Widgets:**
/// - `WidgetTester`: Simulates user interactions (tap, enterText, etc.)
/// - `pump()`: Rebuilds widget after state change
/// - `pumpAndSettle()`: Waits for all animations to complete
///
/// **Finding Widgets:**
/// - `find.text('Hello')`: Finds by text
/// - `find.byType(TextField)`: Finds by widget type
/// - `find.widgetWithText(Button, 'Click')`: Finds by type + text
/// - `find.byWidgetPredicate()`: Custom conditions
///
/// **Assertions:**
/// - `findsOneWidget`: Expects exactly 1 match
/// - `findsNWidgets(n)`: Expects exactly n matches
/// - `findsNothing`: Expects 0 matches
/// - `isNull` / `isNotNull`: For checking button enabled state
///
/// **TDD Workflow:**
/// 1. Write test describing expected behavior (RED ❌)
/// 2. Run test - it should fail
/// 3. Write minimal code to pass test (GREEN ✅)
/// 4. Refactor code while keeping tests passing (REFACTOR 🔵)
///
/// **Next:**
/// Run `flutter test` - all tests should fail (no widget exists yet).
/// Then implement CreateSpaceBottomSheet to make tests pass.
