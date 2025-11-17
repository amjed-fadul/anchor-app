/// Search Provider Tests
///
/// Testing Riverpod providers for search functionality.
/// Following TDD: Writing tests BEFORE implementation!
///
/// Test Strategy:
/// - Test searchQueryProvider (StateProvider for search string)
/// - Test filteredLinksProvider (filters links based on search query)
/// - Test case-insensitive matching
/// - Test matching across multiple fields (title, note, domain, url)
/// - Test empty query returns all links
/// - Test no matches returns empty list
///
/// Real-World Analogy:
/// Think of this like a library search:
/// - Empty search: Shows all books
/// - Search "design": Shows books with "design" in title, author, or notes
/// - Search "DeSiGn": Same results (case-insensitive)
/// - Search "xyz123": No books found (empty results)

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/features/links/services/link_service.dart' show LinkService, LinkWithTags;
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/links/providers/search_provider.dart';
import 'package:mobile/features/links/providers/link_provider.dart' show linksWithTagsProvider, linkServiceProvider;
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

/// Mock LinkService for testing
class MockLinkService extends Mock implements LinkService {}

/// Mock Supabase User for testing
class MockUser extends Mock implements supabase.User {}

void main() {
  group('SearchProvider', () {
    late MockLinkService mockLinkService;
    late MockUser mockUser;
    late ProviderContainer container;

    /// Test data: Mock user
    const mockUserId = 'test-user-id';

    /// Test data: Mock links with tags for search testing
    ///
    /// We'll create diverse links to test different search scenarios:
    /// - Link 1: Title contains "Design", has tags
    /// - Link 2: Note contains "tutorial", no tags
    /// - Link 3: Domain is "apple.com"
    /// - Link 4: URL contains "github.com/flutter"
    /// - Link 5: No matching content (for negative tests)
    final mockLinksWithTags = [
      // Link 1: Title match
      LinkWithTags(
        link: Link(
          id: 'link-1',
          userId: mockUserId,
          spaceId: 'space-1',
          url: 'https://designsystem.com/guide',
          normalizedUrl: 'https://designsystem.com/guide',
          title: 'Design System Guide',
          description: 'A comprehensive guide to design systems',
          thumbnailUrl: 'https://designsystem.com/thumb.jpg',
          domain: 'designsystem.com',
          note: 'Great resource for learning',
          openedAt: null,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        tags: [
          Tag(
            id: 'tag-1',
            userId: mockUserId,
            name: 'Design',
            color: '#f42cff',
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
      ),
      // Link 2: Note match
      LinkWithTags(
        link: Link(
          id: 'link-2',
          userId: mockUserId,
          spaceId: null,
          url: 'https://example.com/article',
          normalizedUrl: 'https://example.com/article',
          title: 'Interesting Article',
          description: 'An article about something',
          thumbnailUrl: null,
          domain: 'example.com',
          note: 'Watch this tutorial later',
          openedAt: null,
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        ),
        tags: [],
      ),
      // Link 3: Domain match
      LinkWithTags(
        link: Link(
          id: 'link-3',
          userId: mockUserId,
          spaceId: 'space-1',
          url: 'https://apple.com/newsroom/2023/06/vision-pro/',
          normalizedUrl: 'https://apple.com/newsroom/2023/06/vision-pro/',
          title: 'Apple Vision Pro Announcement',
          description: 'Revolutionary spatial computing',
          thumbnailUrl: 'https://apple.com/thumb.jpg',
          domain: 'apple.com',
          note: null,
          openedAt: null,
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
        ),
        tags: [],
      ),
      // Link 4: URL match
      LinkWithTags(
        link: Link(
          id: 'link-4',
          userId: mockUserId,
          spaceId: null,
          url: 'https://github.com/flutter/flutter',
          normalizedUrl: 'https://github.com/flutter/flutter',
          title: 'Flutter Repository',
          description: 'Open-source UI framework',
          thumbnailUrl: null,
          domain: 'github.com',
          note: null,
          openedAt: null,
          createdAt: DateTime(2024, 1, 4),
          updatedAt: DateTime(2024, 1, 4),
        ),
        tags: [],
      ),
      // Link 5: No match (for negative tests)
      LinkWithTags(
        link: Link(
          id: 'link-5',
          userId: mockUserId,
          spaceId: 'space-2',
          url: 'https://random.org',
          normalizedUrl: 'https://random.org',
          title: 'Random Website',
          description: 'Something completely different',
          thumbnailUrl: null,
          domain: 'random.org',
          note: 'Bookmark for later',
          openedAt: null,
          createdAt: DateTime(2024, 1, 5),
          updatedAt: DateTime(2024, 1, 5),
        ),
        tags: [],
      ),
    ];

    /// Setup before each test
    setUp(() {
      mockLinkService = MockLinkService();
      mockUser = MockUser();

      // Configure mock user
      when(() => mockUser.id).thenReturn(mockUserId);

      // Configure mock service to return all links
      when(() => mockLinkService.getLinksWithTags(mockUserId))
          .thenAnswer((_) async => mockLinksWithTags);

      // Create container with overridden providers
      container = ProviderContainer(
        overrides: [
          linkServiceProvider.overrideWithValue(mockLinkService),
          currentUserProvider.overrideWith((ref) => mockUser),
        ],
      );
    });

    /// Cleanup after each test
    tearDown(() {
      container.dispose();
    });

    /// Test Group: searchQueryProvider
    ///
    /// This is a simple StateProvider that holds the current search string
    group('searchQueryProvider', () {
      /// Test #1: Starts with empty string
      ///
      /// Why this matters:
      /// Initial state should be empty so all links are shown by default
      test('starts with empty string', () {
        // Act: Read initial state
        final query = container.read(searchQueryProvider);

        // Assert: Should be empty
        expect(query, '');
      });

      /// Test #2: Updates search query
      ///
      /// Why this matters:
      /// User typing in search bar should update this provider
      test('updates search query', () {
        // Act: Update the query
        container.read(searchQueryProvider.notifier).state = 'design';

        // Assert: Query should be updated
        expect(container.read(searchQueryProvider), 'design');
      });

      /// Test #3: Can be set to empty string
      ///
      /// Why this matters:
      /// Clearing search (clicking X button) should reset to show all links
      test('can be set to empty string', () {
        // Arrange: Set initial query
        container.read(searchQueryProvider.notifier).state = 'test';
        expect(container.read(searchQueryProvider), 'test');

        // Act: Clear query
        container.read(searchQueryProvider.notifier).state = '';

        // Assert: Should be empty
        expect(container.read(searchQueryProvider), '');
      });
    });

    /// Test Group: filteredLinksProvider
    ///
    /// This provider filters linksWithTagsProvider based on searchQueryProvider
    group('filteredLinksProvider', () {
      /// Test #1: Returns all links when query is empty
      ///
      /// Why this matters:
      /// Default state (no search) should show all saved links
      test('returns all links when query is empty', () async {
        // Arrange: Ensure query is empty (default state)
        expect(container.read(searchQueryProvider), '');

        // Act: Read filtered links
        // Wait for linksWithTagsProvider to load first
        await container.read(linksWithTagsProvider.future);
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return all 5 links
        expect(filtered.length, 5);
        expect(filtered, mockLinksWithTags);
      });

      /// Test #2: Filters by title (case-insensitive)
      ///
      /// Why this matters:
      /// Users often search by remembering part of the title
      test('filters by title (case-insensitive)', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for "design" (should match "Design System Guide")
        container.read(searchQueryProvider.notifier).state = 'design';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return only link-1
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-1');
        expect(filtered[0].link.title, contains('Design'));
      });

      /// Test #3: Filters by title with different case
      ///
      /// Why this matters:
      /// Search should work regardless of capitalization
      test('filters by title (case-insensitive with uppercase)', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search with uppercase "DESIGN"
        container.read(searchQueryProvider.notifier).state = 'DESIGN';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should still match "Design System Guide"
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-1');
      });

      /// Test #4: Filters by note content
      ///
      /// Why this matters:
      /// Users add notes to help them find links later
      test('filters by note content', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for "tutorial" (should match link-2's note)
        container.read(searchQueryProvider.notifier).state = 'tutorial';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return only link-2
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-2');
        expect(filtered[0].link.note, contains('tutorial'));
      });

      /// Test #5: Filters by domain
      ///
      /// Why this matters:
      /// Users often remember which website a link is from
      test('filters by domain', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for "apple" (should match link-3's domain)
        container.read(searchQueryProvider.notifier).state = 'apple';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return only link-3
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-3');
        expect(filtered[0].link.domain, contains('apple'));
      });

      /// Test #6: Filters by tag name
      ///
      /// Why this matters:
      /// Users organize links with tags and search by tag names
      test('filters by tag name', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for "design" (should match link-1's tag)
        container.read(searchQueryProvider.notifier).state = 'design';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return link-1 (has "Design" tag)
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-1');
        expect(filtered[0].tags.any((tag) => tag.name == 'Design'), true);
      });

      /// Test #6b: Filters by tag name (case-insensitive with uppercase)
      ///
      /// Why this matters:
      /// Tag search should work regardless of capitalization
      test('filters by tag name (case-insensitive with uppercase)', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search with uppercase "DESIGN" (should match "Design" tag)
        container.read(searchQueryProvider.notifier).state = 'DESIGN';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should still match link-1 (has "Design" tag)
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-1');
      });

      /// Test #6c: Handles links with no tags gracefully
      ///
      /// Why this matters:
      /// Links without tags shouldn't cause errors when searching
      test('handles links with no tags gracefully', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for tag name that doesn't exist
        // link-2, link-3, link-4, link-5 have no tags
        container.read(searchQueryProvider.notifier).state = 'nonexistenttag';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return empty (no crashes)
        expect(filtered, []);
      });

      /// Test #7: Returns empty list when no matches
      ///
      /// Why this matters:
      /// UI needs to show "No results" state when search finds nothing
      test('returns empty list when no matches found', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for non-existent term
        container.read(searchQueryProvider.notifier).state = 'xyz123nonexistent';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return empty list
        expect(filtered.length, 0);
        expect(filtered, []);
      });

      /// Test #8: Returns multiple matches
      ///
      /// Why this matters:
      /// Search results can contain multiple links
      test('returns multiple matches', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for "com" (matches domains: designsystem.com, example.com, apple.com, github.com, random.org)
        // Actually random.org doesn't contain "com", so should match 4 links
        container.read(searchQueryProvider.notifier).state = 'com';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return 4 links (all except random.org)
        expect(filtered.length, 4);
        expect(filtered.any((l) => l.link.id == 'link-1'), true);
        expect(filtered.any((l) => l.link.id == 'link-2'), true);
        expect(filtered.any((l) => l.link.id == 'link-3'), true);
        expect(filtered.any((l) => l.link.id == 'link-4'), true);
        expect(filtered.any((l) => l.link.id == 'link-5'), false);
      });

      /// Test #9: Handles null fields gracefully
      ///
      /// Why this matters:
      /// Not all links have title, note, or domain set
      test('handles null fields gracefully', () async {
        // Arrange: Load links first
        await container.read(linksWithTagsProvider.future);

        // Act: Search for content that only exists in non-null fields
        // link-4 has null note, search should still work
        container.read(searchQueryProvider.notifier).state = 'github';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should find link-4 by domain even though note is null
        expect(filtered.length, 1);
        expect(filtered[0].link.id, 'link-4');
        expect(filtered[0].link.note, null);
      });

      /// Test #10: Resets to all links when query is cleared
      ///
      /// Why this matters:
      /// Clicking X button to clear search should show all links again
      test('resets to all links when query is cleared', () async {
        // Arrange: Load links and set initial search
        await container.read(linksWithTagsProvider.future);
        container.read(searchQueryProvider.notifier).state = 'design';

        // Verify search is working
        expect(container.read(filteredLinksProvider).length, 1);

        // Act: Clear search
        container.read(searchQueryProvider.notifier).state = '';
        final filtered = container.read(filteredLinksProvider);

        // Assert: Should return all links again
        expect(filtered.length, 5);
        expect(filtered, mockLinksWithTags);
      });
    });
  });
}

/// 🎓 Learning Summary: Search Provider Testing
///
/// **What We're Testing:**
/// - searchQueryProvider: Simple state holder for search string
/// - filteredLinksProvider: Filters links based on search query
///
/// **Key Testing Concepts:**
/// 1. **Arrange-Act-Assert Pattern**: Set up → Do something → Check result
/// 2. **Mock Data**: Use realistic test data that covers different scenarios
/// 3. **Edge Cases**: Empty search, no results, null fields
/// 4. **Case Insensitivity**: Search should work regardless of capitalization
/// 5. **Multiple Fields**: Search across title, note, domain, URL
///
/// **Real-World Analogy:**
/// Think of testing like quality control at a factory:
/// - Each test is a quality check (does this part work?)
/// - Mock data is like sample materials (test with known inputs)
/// - Edge cases are stress tests (what if this breaks?)
/// - If all tests pass, the product is ready to ship
///
/// **TDD Flow:**
/// 1. 🔴 RED: Write tests first (they fail because no implementation)
/// 2. 🟢 GREEN: Write minimal code to make tests pass
/// 3. 🔵 REFACTOR: Clean up code while keeping tests passing
///
/// **Next:**
/// Run `flutter test` to watch these tests FAIL (🔴 RED),
/// then implement search_provider.dart to make them PASS (🟢 GREEN)!
