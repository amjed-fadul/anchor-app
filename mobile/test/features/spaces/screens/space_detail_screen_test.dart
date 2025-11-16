/// Space Detail Screen Widget Tests
///
/// Testing the UI for viewing links in a specific space.
///
/// Test Strategy:
/// - Test that screen renders with correct space name
/// - Test empty state when no links
/// - Test grid display when links exist
/// - Test error state
///
/// Note: We already tested business logic at provider/service level.
/// These tests focus on UI rendering and user-facing behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/spaces/screens/space_detail_screen.dart';
import 'package:mobile/features/spaces/models/space_model.dart';
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/links/providers/links_by_space_provider.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

/// Helper function to create a test widget with providers
Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('SpaceDetailScreen', () {
    /// Test data
    final testSpace = Space(
      id: 'test-space-id',
      userId: 'test-user-id',
      name: 'Design Resources',
      color: '#7cfec4',
      isDefault: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    /// Test #1: Screen renders with space name in header
    testWidgets('displays space name in header', (WidgetTester tester) async {
      // Arrange: Override provider to return loading state initially
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.value(<LinkWithTags>[]),
            ),
          ],
        ),
      );

      // Act: Let the widget build
      await tester.pumpAndSettle();

      // Assert: Space name should be visible
      expect(find.text('Design Resources'), findsOneWidget);
    });

    /// Test #2: Shows empty state when space has no links
    testWidgets('shows empty state when space has no links',
        (WidgetTester tester) async {
      // Arrange: Override provider to return empty list
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.value(<LinkWithTags>[]),
            ),
          ],
        ),
      );

      // Act: Wait for async operations
      await tester.pumpAndSettle();

      // Assert: Empty state message should be visible
      expect(find.text('This space is empty'), findsOneWidget);
    });

    /// Test #3: Displays links in grid when data exists
    testWidgets('displays links in grid when data exists',
        (WidgetTester tester) async {
      // Arrange: Create mock links
      final mockLinks = [
        LinkWithTags(
          link: Link(
            id: 'link-1',
            userId: 'test-user-id',
            spaceId: testSpace.id,
            url: 'https://apple.com',
            normalizedUrl: 'https://apple.com',
            title: 'Apple',
            description: 'Think Different',
            thumbnailUrl: null,
            domain: 'apple.com',
            note: null,
            openedAt: null,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          tags: [
            Tag(
              id: 'tag-1',
              userId: 'test-user-id',
              name: 'Design',
              color: '#f42cff',
              createdAt: DateTime(2024, 1, 1),
            ),
          ],
        ),
        LinkWithTags(
          link: Link(
            id: 'link-2',
            userId: 'test-user-id',
            spaceId: testSpace.id,
            url: 'https://figma.com',
            normalizedUrl: 'https://figma.com',
            title: 'Figma',
            description: 'Design tool',
            thumbnailUrl: null,
            domain: 'figma.com',
            note: null,
            openedAt: null,
            createdAt: DateTime(2024, 1, 2),
            updatedAt: DateTime(2024, 1, 2),
          ),
          tags: [],
        ),
      ];

      // Override provider to return mock links
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.value(mockLinks),
            ),
          ],
        ),
      );

      // Act: Wait for async operations
      await tester.pumpAndSettle();

      // Assert: Should find GridView with links
      expect(find.byType(GridView), findsOneWidget);

      // Should NOT show empty state
      expect(find.text('This space is empty'), findsNothing);
    });

    /// Test #4: Shows loading state while fetching
    testWidgets('shows loading indicator while fetching',
        (WidgetTester tester) async {
      // Arrange: Override provider to return a delayed future
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.delayed(
                const Duration(seconds: 1),
                () => <LinkWithTags>[],
              ),
            ),
          ],
        ),
      );

      // Act: Pump once (don't wait for future to complete)
      await tester.pump();

      // Assert: Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    /// Test #5: Shows error state on failure
    testWidgets('shows error message on failure', (WidgetTester tester) async {
      // Arrange: Override provider to throw an error
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.error('Failed to fetch links'),
            ),
          ],
        ),
      );

      // Act: Wait for error state
      await tester.pumpAndSettle();

      // Assert: Error message should be visible
      expect(find.text('Error loading links'), findsOneWidget);
    });

    /// Test #6: Has back button in header
    testWidgets('has back button in header', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          SpaceDetailScreen(space: testSpace),
          overrides: [
            linksBySpaceProvider(testSpace.id).overrideWith(
              (ref) => Future.value(<LinkWithTags>[]),
            ),
          ],
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert: Back button should exist
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}

/// 🎓 Learning Summary: Widget Testing Levels
///
/// **Testing Pyramid:**
/// ```
///        /\
///       /UI\       ← Few tests (expensive, fragile)
///      /────\
///     /Widget\     ← Some tests (medium cost)
///    /────────\
///   /Integration\  ← More tests (provider/service)
///  /────────────\
/// / Unit Tests  \ ← Most tests (cheap, fast)
/// ```
///
/// **What We Test at Each Level:**
///
/// 1. **Unit Tests** (Lots) - Pure business logic
///    - Services (database queries, API calls)
///    - Models (parsing, validation)
///    - Utilities (formatters, validators)
///    - Fast, isolated, easy to maintain
///
/// 2. **Integration Tests** (Some) - Provider layer
///    - Provider state management
///    - Data flow between service and UI
///    - Mocking services, not Supabase
///
/// 3. **Widget Tests** (Few) - UI rendering
///    - Screen renders correctly
///    - Empty/loading/error states display
///    - User interactions work
///
/// 4. **UI Tests** (Very Few) - End-to-end flows
///    - Full user journeys
///    - Real device testing
///    - Manual testing often sufficient
///
/// **Why This Approach?**
/// - Unit tests are FAST (milliseconds) and RELIABLE
/// - Widget tests are SLOWER (seconds) and can be FRAGILE
/// - Focus testing effort where bugs are most likely (business logic)
/// - UI bugs are often caught in manual testing anyway
///
/// **For SpaceDetailScreen:**
/// - ✅ Service tested: getLinksBySpace() logic
/// - ✅ Provider tested: LinksBySpaceProvider state management
/// - ✅ Widget tested: Basic rendering (these 6 tests)
/// - ⏭️  UI testing: Manual verification on device
///
/// **Next:**
/// Implement the SpaceDetailScreen to make these tests pass!
