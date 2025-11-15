library;

/// LinkActionSheet Widget Tests
///
/// Tests for the bottom sheet action menu that appears on long-press.
///
/// Test Coverage:
/// - Widget renders correctly
/// - Displays all 4 action items
/// - Shows correct icons
/// - Delete action has pink background
/// - Conditional space button (Add vs Remove)
/// - Callbacks are invoked when actions are tapped

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/features/links/widgets/link_action_sheet.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/links/models/link_model.dart';

void main() {
  group('LinkActionSheet Widget Tests', () {
    final now = DateTime.now();

    // Test data: Link WITH a space
    final linkWithSpace = LinkWithTags(
      link: Link(
        id: '1',
        userId: 'user1',
        url: 'https://example.com',
        normalizedUrl: 'https://example.com',
        title: 'Test Link',
        spaceId: 'space123', // Link IS in a space
        createdAt: now,
        updatedAt: now,
      ),
      tags: [],
    );

    // Test data: Link WITHOUT a space
    final linkWithoutSpace = LinkWithTags(
      link: Link(
        id: '2',
        userId: 'user1',
        url: 'https://example.com',
        normalizedUrl: 'https://example.com',
        title: 'Test Link',
        spaceId: null, // Link is NOT in a space
        createdAt: now,
        updatedAt: now,
      ),
      tags: [],
    );

    testWidgets('displays all 4 action items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Verify all 4 action texts are displayed
      expect(find.text('Copy to clipboard'), findsOneWidget);
      expect(find.text('Add Tag'), findsOneWidget);
      expect(find.text('Delete Link'), findsOneWidget);

      // Space action should show "Remove from Space" when link has spaceId
      expect(find.text('Remove from Space'), findsOneWidget);
    });

    testWidgets('shows "Add to Space" when link has no space', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithoutSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should show "Add to Space" when link.spaceId is null
      expect(find.text('Add to Space'), findsOneWidget);
      expect(find.text('Remove from Space'), findsNothing);
    });

    testWidgets('displays correct SVG icons for each action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find all SvgPicture widgets
      final svgPictures = find.byType(SvgPicture);

      // Should have 4 SVG icons (one for each action)
      expect(svgPictures, findsNWidgets(4));
    });

    testWidgets('delete action has pink background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the delete action container
      final deleteActionFinder = find.ancestor(
        of: find.text('Delete Link'),
        matching: find.byType(Container),
      );

      expect(deleteActionFinder, findsWidgets);

      // Verify the container has pink background color (#ffe7eb)
      final deleteContainer = tester.widget<Container>(deleteActionFinder.first);
      final decoration = deleteContainer.decoration as BoxDecoration?;

      expect(decoration?.color, const Color(0xffffe7eb));
    });

    testWidgets('invokes onCopyToClipboard when copy action is tapped', (tester) async {
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () => callbackInvoked = true,
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the "Copy to clipboard" action
      await tester.tap(find.text('Copy to clipboard'));
      await tester.pumpAndSettle();

      expect(callbackInvoked, true);
    });

    testWidgets('invokes onAddTag when tag action is tapped', (tester) async {
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () => callbackInvoked = true,
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the "Add Tag" action
      await tester.tap(find.text('Add Tag'));
      await tester.pumpAndSettle();

      expect(callbackInvoked, true);
    });

    testWidgets('invokes onSpaceAction when space action is tapped', (tester) async {
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () => callbackInvoked = true,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Tap the space action (should be "Remove from Space" for this link)
      await tester.tap(find.text('Remove from Space'));
      await tester.pumpAndSettle();

      expect(callbackInvoked, true);
    });

    testWidgets('invokes onDelete when delete action is tapped', (tester) async {
      bool callbackInvoked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () => callbackInvoked = true,
            ),
          ),
        ),
      );

      // Tap the "Delete Link" action
      await tester.tap(find.text('Delete Link'));
      await tester.pumpAndSettle();

      expect(callbackInvoked, true);
    });

    testWidgets('has grabber handle at top', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinkActionSheet(
              linkWithTags: linkWithSpace,
              onCopyToClipboard: () {},
              onAddTag: () {},
              onSpaceAction: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      // Find the grabber handle (small rounded container at top)
      // Grabber should be 36x5px
      final grabberFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 36 &&
            widget.constraints?.maxHeight == 5,
      );

      expect(grabberFinder, findsOneWidget);
    });
  });
}
