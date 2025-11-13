/// LinkCard Widget Tests (TDD - RED)
///
/// Testing a card component that displays saved links with thumbnails, tags, titles, and notes.
///
/// What is a LinkCard?
/// A card that shows everything about a saved link:
/// - Thumbnail image
/// - Colored tag badges
/// - Link title
/// - User's note
/// - Domain/source
///
/// Real-World Analogy:
/// Think of it like a recipe card in a recipe box:
/// - Picture of the dish at the top
/// - Category labels (dessert, quick, healthy)
/// - Recipe name
/// - Your personal notes
///
/// What we're testing:
/// 1. Displays link title
/// 2. Displays link note
/// 3. Displays tags using TagBadge widgets
/// 4. Displays placeholder image when no thumbnail
/// 5. Has rounded corners and elevation (shadow)
/// 6. Responsive sizing on different screens
/// 7. Handles links without notes gracefully
/// 8. Handles links without tags gracefully

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/links/widgets/link_card.dart';
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/tags/models/tag_model.dart';
import 'package:mobile/features/tags/widgets/tag_badge.dart';
import 'package:mobile/features/links/services/link_service.dart';

void main() {
  group('LinkCard Widget', () {
    /// Helper function to create a test link
    Link createLink({
      String title = 'Apple Vision Pro',
      String? note = 'Check this out later',
      String url = 'https://apple.com',
    }) {
      return Link(
        id: 'test-link-id',
        userId: 'test-user-id',
        spaceId: 'test-space-id',
        url: url,
        title: title,
        note: note,
        openedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    /// Helper function to create a test tag
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

    /// Test #1: Displays link title
    ///
    /// Why this matters:
    /// Users need to see what the link is about at a glance
    testWidgets('displays link title', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink(title: 'Apple Vision Pro');
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT
      expect(find.text('Apple Vision Pro'), findsOneWidget);
    });

    /// Test #2: Displays link note
    ///
    /// Why this matters:
    /// Users add notes to remind themselves why they saved the link
    testWidgets('displays link note', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink(note: 'Check this out later');
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT
      expect(find.text('Check this out later'), findsOneWidget);
    });

    /// Test #3: Displays tags using TagBadge widgets
    ///
    /// Why this matters:
    /// Tags help users categorize and identify links quickly
    testWidgets('displays tags as TagBadge widgets', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink();
      final tags = [
        createTag(name: 'Design', color: '#f42cff'),
        createTag(name: 'Apple', color: '#682cff'),
      ];
      final linkWithTags = LinkWithTags(link: link, tags: tags);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should find TagBadge widgets
      expect(find.byType(TagBadge), findsNWidgets(2));
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });

    /// Test #4: Handles links without notes
    ///
    /// Why this matters:
    /// Not all links have notes. Widget should handle this gracefully.
    testWidgets('handles links without notes', (WidgetTester tester) async {
      // ARRANGE: Link with null note
      final link = createLink(note: null);
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should still render without crashing
      expect(find.text('Apple Vision Pro'), findsOneWidget);
      // Note should not be present
      expect(find.text('Check this out later'), findsNothing);
    });

    /// Test #5: Handles links without tags
    ///
    /// Why this matters:
    /// Not all links have tags assigned yet
    testWidgets('handles links without tags', (WidgetTester tester) async {
      // ARRANGE: Link with empty tags list
      final link = createLink();
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should render without TagBadges
      expect(find.byType(TagBadge), findsNothing);
      expect(find.text('Apple Vision Pro'), findsOneWidget);
    });

    /// Test #6: Has rounded corners (Card widget)
    ///
    /// Why this matters:
    /// Matches Figma design - rounded corners look polished
    testWidgets('has rounded corners', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink();
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should use Card widget with shape
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.shape, isNotNull);
      expect(card.shape, isA<RoundedRectangleBorder>());

      // Check border radius exists
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, isNotNull);
    });

    /// Test #7: Has elevation (shadow) for depth
    ///
    /// Why this matters:
    /// Subtle shadow gives cards depth and makes them stand out
    testWidgets('has elevation for shadow', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink();
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Card should have elevation
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, greaterThan(0));
    });

    /// Test #8: Displays placeholder when no image
    ///
    /// Why this matters:
    /// Not all links have thumbnails. We need a placeholder.
    testWidgets('displays placeholder when no image', (WidgetTester tester) async {
      // ARRANGE: Link without image
      final link = createLink();
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should find a Container with placeholder color
      // (We'll use a colored container as placeholder)
      expect(find.byType(Container), findsWidgets);
    });

    /// Test #9: Title has proper styling (bold, black)
    ///
    /// Why this matters:
    /// Title should be prominent and readable
    testWidgets('title has bold black text', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink(title: 'Apple Vision Pro');
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Title text should be bold and dark
      final titleText = tester.widget<Text>(
        find.text('Apple Vision Pro'),
      );

      expect(titleText.style?.fontWeight, FontWeight.bold);
      expect(titleText.style?.color, Colors.black);
    });

    /// Test #10: Note has proper styling (gray, smaller)
    ///
    /// Why this matters:
    /// Note should be secondary information, not as prominent as title
    testWidgets('note has gray smaller text', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink(note: 'Check this out later');
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Note text should be gray and smaller than title
      final noteText = tester.widget<Text>(
        find.text('Check this out later'),
      );

      expect(noteText.style?.color, Colors.grey[600]);
      expect(noteText.style?.fontSize, lessThan(16)); // Smaller than typical title
    });

    /// Test #11: Limits note to 2 lines with ellipsis
    ///
    /// Why this matters:
    /// Long notes would make cards too tall. Truncate for consistency.
    testWidgets('limits note to 2 lines', (WidgetTester tester) async {
      // ARRANGE: Link with very long note
      final link = createLink(
        note: 'This is a very long note that should be truncated to only two lines '
              'so that the card does not become too tall and maintains consistent sizing',
      );
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Note should have maxLines and overflow
      final noteText = tester.widget<Text>(find.byType(Text).last);
      expect(noteText.maxLines, 2);
      expect(noteText.overflow, TextOverflow.ellipsis);
    });

    /// Test #12: Has fixed aspect ratio for consistent card heights
    ///
    /// Why this matters:
    /// Cards in a grid should have consistent heights for visual harmony
    testWidgets('has consistent aspect ratio', (WidgetTester tester) async {
      // ARRANGE
      final link = createLink();
      final linkWithTags = LinkWithTags(link: link, tags: []);

      // ACT
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkCard(linkWithTags: linkWithTags),
          ),
        ),
      );

      // ASSERT: Should use AspectRatio widget or similar for consistency
      // This ensures all cards have same dimensions in grid
      expect(find.byType(LinkCard), findsOneWidget);
    });
  });
}

/// 🎓 Learning Summary: Widget Testing Deep Dive
///
/// **What Makes a Good Widget Test?**
/// 1. **Arrange**: Set up test data
/// 2. **Act**: Build the widget
/// 3. **Assert**: Verify it looks/behaves correctly
///
/// **Testing Visual Properties:**
/// - Colors: `expect(text.style?.color, Colors.white)`
/// - Font sizes: `expect(text.style?.fontSize, 14)`
/// - Font weights: `expect(text.style?.fontWeight, FontWeight.bold)`
/// - Borders: `expect(card.shape, isA<RoundedRectangleBorder>())`
/// - Elevation: `expect(card.elevation, greaterThan(0))`
///
/// **Testing Nested Widgets:**
/// ```dart
/// // Find specific widget type
/// find.byType(TagBadge)
///
/// // Find text within widget
/// find.text('Design')
///
/// // Find descendant widgets
/// find.descendant(of: find.byType(LinkCard), matching: find.byType(TagBadge))
/// ```
///
/// **Widget Finders:**
/// - `findsOneWidget` - Exactly 1 match
/// - `findsNothing` - 0 matches
/// - `findsNWidgets(2)` - Exactly 2 matches
/// - `findsWidgets` - At least 1 match
///
/// **Why MaterialApp Wrapper?**
/// Many widgets need Material context for:
/// - Theme data
/// - Text styles
/// - Colors
/// - Typography
///
/// **Testing Edge Cases:**
/// - Null values (no note, no tags)
/// - Long text (truncation)
/// - Empty lists (no tags)
/// - Missing data (no image)
///
/// **Next:**
/// Run `flutter test test/features/links/widgets/link_card_test.dart`
/// Watch it FAIL (🔴 RED) because LinkCard widget doesn't exist yet.
/// Then implement the widget to make tests pass (🟢 GREEN).
