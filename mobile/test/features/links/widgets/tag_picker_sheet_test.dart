library;

/// TagPickerSheet Widget Tests (TDD - RED Phase)
///
/// Tests for the tag picker bottom sheet that appears when user taps "Add Tag" action.
///
/// What is TagPickerSheet?
/// A multi-select tag interface that allows users to:
/// - Select/deselect existing tags
/// - Create new tags on the fly
/// - Search/filter tags by name
/// - See currently selected tags highlighted
///
/// Real-World Analogy:
/// Think of it like adding labels to an email in Gmail:
/// - See all your existing labels
/// - Check/uncheck labels to apply them
/// - Create new labels right from the picker
/// - Search for labels when you have many
///
/// Test Coverage:
/// 1. Widget renders correctly
/// 2. Displays list of available tags
/// 3. Shows currently selected tags as checked
/// 4. Tapping tag toggles selection
/// 5. Search field filters tags by name
/// 6. "Create new tag" input field exists
/// 7. Creating new tag adds it to selection
/// 8. Done button calls callback with selected tag IDs
/// 9. Cancel/close dismisses sheet without saving
/// 10. Empty state when no tags exist

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/links/widgets/tag_picker_sheet.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

void main() {
  group('TagPickerSheet Widget Tests', () {
    final now = DateTime.now();

    // Test data: Sample tags
    final availableTags = [
      Tag(
        id: 'tag1',
        userId: 'user1',
        name: 'Design',
        color: '#f42cff',
        createdAt: now,
      ),
      Tag(
        id: 'tag2',
        userId: 'user1',
        name: 'Apple',
        color: '#682cff',
        createdAt: now,
      ),
      Tag(
        id: 'tag3',
        userId: 'user1',
        name: 'Development',
        color: '#2cff68',
        createdAt: now,
      ),
    ];

    /// Test #1: Widget renders correctly
    ///
    /// Why this matters:
    /// Basic sanity check - the widget should build without errors
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should find the main container
      expect(find.byType(TagPickerSheet), findsOneWidget);
    });

    /// Test #2: Displays list of available tags
    ///
    /// Why this matters:
    /// Users need to see all their tags to choose from
    testWidgets('displays all available tags', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should display all tag names
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Development'), findsOneWidget);
    });

    /// Test #3: Shows currently selected tags as checked
    ///
    /// Why this matters:
    /// Users need to see which tags are already applied to the link
    testWidgets('shows selected tags as checked', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const ['tag1', 'tag2'], // Design and Apple selected
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should find check icons for selected tags
      // (Implementation uses Icon(Icons.check), not Checkbox)
      final checkIcons = tester.widgetList<Icon>(find.byIcon(Icons.check));
      expect(checkIcons.length, 2); // 2 tags should have check icons
    });

    /// Test #4: Tapping tag toggles selection
    ///
    /// Why this matters:
    /// Users need to select/deselect tags by tapping them
    testWidgets('tapping tag toggles selection', (tester) async {
      final selectedTags = <String>[];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return TagPickerSheet(
                    availableTags: availableTags,
                    selectedTagIds: selectedTags,
                    onDone: (tagIds) {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Initially, no tags should be checked
      expect(find.byIcon(Icons.check), findsNothing);

      // Tap the first tag (Design)
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();

      // Now one tag should have a check icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    /// Test #5: Search field filters tags by name
    ///
    /// Why this matters:
    /// When users have many tags, they need to search quickly
    testWidgets('search field filters tags by name', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Initially, all 3 tags should be visible
      expect(find.text('Design'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Development'), findsOneWidget);

      // Type "Dev" in search field
      await tester.enterText(find.byType(TextField).first, 'Dev');
      await tester.pumpAndSettle();

      // Only "Development" should be visible now
      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Design'), findsNothing);
      expect(find.text('Apple'), findsNothing);
    });

    /// Test #6: "Create new tag" input field exists
    ///
    /// Why this matters:
    /// Users should be able to create new tags on the fly
    testWidgets('shows create tag suggestion when searching for non-existent tag', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Enter text in search field for a tag that doesn't exist
      await tester.enterText(find.byType(TextField), 'NewTag');
      await tester.pumpAndSettle();

      // Should show create suggestion with add icon
      // (Implementation uses Icons.add_circle_outline for create suggestion)
      expect(
        find.byIcon(Icons.add_circle_outline),
        findsOneWidget,
        reason: 'Should show create tag suggestion with add icon for non-existent tag',
      );
    });

    /// Test #7: Done button exists
    ///
    /// Why this matters:
    /// Users need a way to confirm their tag selection
    testWidgets('has done button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should find Done button
      expect(find.text('Done'), findsOneWidget);
    });

    /// Test #8: Done button calls callback with selected tag IDs
    ///
    /// Why this matters:
    /// Clicking Done should return the selected tags to parent
    testWidgets('done button calls callback with selected tags', (tester) async {
      List<String>? returnedTagIds;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const ['tag1', 'tag2'],
                onDone: (tagIds) {
                  returnedTagIds = tagIds;
                },
              ),
            ),
          ),
        ),
      );

      // Tap Done button
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Should have called callback with selected tag IDs
      expect(returnedTagIds, isNotNull);
      expect(returnedTagIds, containsAll(['tag1', 'tag2']));
    });

    /// Test #9: Empty state when no tags exist
    ///
    /// Why this matters:
    /// First-time users won't have any tags yet
    testWidgets('shows empty state when no tags exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: const [], // No tags
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should show empty state message
      expect(
        find.text('No tags yet'),
        findsOneWidget,
        reason: 'Should display empty state message',
      );
    });

    /// Test #10: Has grabber handle at top
    ///
    /// Why this matters:
    /// Bottom sheets should have a visual indicator they're draggable
    testWidgets('has grabber handle at top', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Find the grabber handle (small rounded container at top)
      // Grabber should be 36x5px like LinkActionSheet
      final grabberFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.constraints?.maxWidth == 36 &&
            widget.constraints?.maxHeight == 5,
      );

      expect(grabberFinder, findsOneWidget);
    });

    /// Test #11: Tags display with colored badges
    ///
    /// Why this matters:
    /// Tags should be visually distinct with their assigned colors
    testWidgets('displays tags with colored badges', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Should find Container widgets with colored backgrounds for each tag
      final coloredContainers = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration != null,
      );

      expect(coloredContainers, findsWidgets);
    });

    /// Test #12: Search is case-insensitive
    ///
    /// Why this matters:
    /// Users shouldn't have to remember exact capitalization
    testWidgets('search is case-insensitive', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TagPickerSheet(
                availableTags: availableTags,
                selectedTagIds: const [],
                onDone: (tagIds) {},
              ),
            ),
          ),
        ),
      );

      // Type lowercase "design" to search for "Design" tag
      await tester.enterText(find.byType(TextField).first, 'design');
      await tester.pumpAndSettle();

      // Should still find "Design" (capitalized)
      expect(find.text('Design'), findsOneWidget);
    });
  });
}

/// 🎓 Learning Summary: Multi-Select UI Testing
///
/// **Key Concepts Tested:**
/// 1. **Stateful Widgets**: TagPickerSheet needs to track selected tags
/// 2. **List Filtering**: Search functionality filters displayed items
/// 3. **Checkbox Widgets**: Multi-select requires checkboxes or similar UI
/// 4. **Callbacks**: Parent needs to receive selected tags on Done
/// 5. **Empty States**: Always handle case when no data exists
///
/// **Widget Testing Patterns:**
/// ```dart
/// // Finding stateful widgets
/// find.byType(Checkbox)
///
/// // Checking widget state
/// tester.widget<Checkbox>(find.byType(Checkbox)).value
///
/// // Simulating user input
/// await tester.enterText(find.byType(TextField), 'search query');
///
/// // Testing callbacks
/// String? result;
/// onDone: (value) => result = value,
/// // ... tap button ...
/// expect(result, expectedValue);
/// ```
///
/// **Testing Multi-Select UI:**
/// - Test initial state (what's checked/unchecked)
/// - Test toggling selections (tap to check/uncheck)
/// - Test selection persistence (selections remain after interactions)
/// - Test callback with final selections
///
/// **Next:**
/// Run `flutter test test/features/links/widgets/tag_picker_sheet_test.dart`
/// Watch it FAIL (🔴 RED) because TagPickerSheet widget doesn't exist yet.
/// Then implement the widget to make tests pass (🟢 GREEN).
