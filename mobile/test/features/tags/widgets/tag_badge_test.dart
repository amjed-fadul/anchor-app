/// TagBadge Widget Tests (TDD - RED)
///
/// Testing a small colored pill component that displays tag names.
///
/// What is a Widget Test?
/// Widget tests verify that UI components render correctly and respond to interactions.
/// Think of it like testing a light switch - does it turn on/off when clicked?
///
/// What we're testing:
/// 1. Tag name displays correctly
/// 2. Background color matches tag color
/// 3. Text is readable (white color for contrast)
/// 4. Handles long tag names gracefully
/// 5. Rounded corners (pill shape)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tags/widgets/tag_badge.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

void main() {
  group('TagBadge Widget', () {
    /// Helper function to create a test tag
    /// Makes tests cleaner and easier to read
    Tag createTag({
      String name = 'Design',
      String color = '#f42cff',
    }) {
      return Tag(
        id: 'test-tag-id',
        userId: 'test-user-id',
        name: name,
        color: color,
        createdAt: DateTime.now(),
      );
    }

    /// Test #1: Widget displays tag name
    ///
    /// Why this matters:
    /// The whole point of a tag badge is to show the tag name!
    testWidgets('displays tag name', (WidgetTester tester) async {
      // ARRANGE: Create a tag
      final tag = createTag(name: 'Design');

      // ACT: Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Tag name should be visible
      expect(find.text('Design'), findsOneWidget);
    });

    /// Test #2: Widget uses tag color for background
    ///
    /// Why this matters:
    /// Colors provide visual distinction between different tags
    testWidgets('uses tag color for background', (WidgetTester tester) async {
      // ARRANGE: Create tag with specific color
      final tag = createTag(color: '#f42cff'); // Pink

      // ACT: Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Find the Container with background color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TagBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;

      // Convert hex color to Color object for comparison
      // #f42cff = RGB(244, 44, 255)
      expect(
        decoration.color,
        const Color(0xfff42cff),
      );
    });

    /// Test #3: Text color is white for contrast
    ///
    /// Why this matters:
    /// White text on colored backgrounds ensures readability
    testWidgets('displays white text for contrast', (WidgetTester tester) async {
      // ARRANGE
      final tag = createTag(color: '#075a52'); // Dark teal

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Text should be white
      final text = tester.widget<Text>(find.text('Design'));
      expect(text.style?.color, Colors.white);
    });

    /// Test #4: Has rounded corners (pill shape)
    ///
    /// Why this matters:
    /// Rounded corners match the Figma design and look polished
    testWidgets('has rounded corners', (WidgetTester tester) async {
      // ARRANGE
      final tag = createTag();

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Container should have BorderRadius
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TagBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);

      // Pill shape typically has radius of 12-16
      expect(
        (decoration.borderRadius as BorderRadius).topLeft.x,
        greaterThanOrEqualTo(12),
      );
    });

    /// Test #5: Handles long tag names
    ///
    /// Why this matters:
    /// Users might create tags with long names. We need to handle this gracefully.
    testWidgets('truncates long tag names', (WidgetTester tester) async {
      // ARRANGE: Tag with very long name
      final tag = createTag(name: 'This Is A Very Long Tag Name That Should Be Truncated');

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Text should have overflow handling
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, TextOverflow.ellipsis);
    });

    /// Test #6: Has appropriate padding
    ///
    /// Why this matters:
    /// Padding makes the badge look polished (not cramped)
    testWidgets('has padding around text', (WidgetTester tester) async {
      // ARRANGE
      final tag = createTag();

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Container should have padding
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(TagBadge),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, isNotNull);
    });

    /// Test #7: Small font size for compact display
    ///
    /// Why this matters:
    /// Tags should be small and unobtrusive, not dominate the screen
    testWidgets('uses small font size', (WidgetTester tester) async {
      // ARRANGE
      final tag = createTag();

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagBadge(tag: tag),
          ),
        ),
      );

      // ASSERT: Font size should be small (12-14)
      final text = tester.widget<Text>(find.text('Design'));
      expect(text.style?.fontSize, lessThanOrEqualTo(14));
    });
  });
}

/// 🎓 Learning Summary: Widget Testing
///
/// **What We're Testing:**
/// - ✅ Visual appearance (colors, shapes, sizes)
/// - ✅ Text display and formatting
/// - ✅ Responsive behavior (long names)
/// - ✅ Styling details (padding, borders, fonts)
///
/// **Widget Testing Pattern:**
/// 1. **pumpWidget()**: Renders the widget in test environment
/// 2. **find**: Locates widgets on screen (find.text, find.byType)
/// 3. **expect**: Verifies widget properties match expectations
///
/// **Why MaterialApp wrapper?**
/// Many widgets need Material context (theme, typography, etc.)
/// We wrap in MaterialApp + Scaffold to provide this context
///
/// **Common Finders:**
/// - `find.text('Design')` - Find widget containing text
/// - `find.byType(Container)` - Find widget by type
/// - `find.descendant()` - Find child widget
///
/// **Next:**
/// Run `flutter test test/features/tags/widgets/tag_badge_test.dart`
/// Watch it FAIL (🔴 RED) because TagBadge widget doesn't exist yet.
/// Then implement the widget to make tests pass (🟢 GREEN).
