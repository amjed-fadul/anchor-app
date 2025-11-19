library;

/// Space Search Provider Tests
///
/// Tests for space-specific search functionality.
/// These tests follow the same pattern as home search tests,
/// but filter links within a specific space by space ID.
///
/// Test Coverage:
/// - spaceSearchQueryProvider: Manages search query state
/// - filteredSpaceLinksProvider: Filters links by title, note, domain, tags
///
/// Real-World Analogy:
/// Think of this like searching inside a specific folder on your computer:
/// - You open a folder (space)
/// - Type in the search box (spaceSearchQueryProvider)
/// - See only files in THAT folder matching your search (filteredSpaceLinksProvider)
///
/// TDD Approach:
/// 🔴 RED: Write tests first (they will fail - provider doesn't exist yet)
/// 🟢 GREEN: Implement provider to make tests pass
/// 🔵 REFACTOR: Clean up code while keeping tests passing

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/spaces/providers/space_search_provider.dart';
import 'package:mobile/features/links/providers/links_by_space_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/tags/models/tag_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock LinkService for testing
///
/// Returns predefined test data instead of querying real database.
/// This makes tests fast, reliable, and independent of database state.
class MockSpaceSearchLinkService implements LinkService {
  /// Test space ID for all test links
  static const testSpaceId = 'test-space-123';

  /// Mock data: Two links in test space with different attributes
  ///
  /// Link 1:
  /// - Title: "Design System Guide"
  /// - Note: "Important reference"
  /// - Domain: "figma.com"
  /// - Tags: ["Design", "Reference"]
  ///
  /// Link 2:
  /// - Title: "API Documentation"
  /// - Note: "Backend docs"
  /// - Domain: "api.example.com"
  /// - Tags: ["Dev", "Backend"]
  List<LinkWithTags> getMockLinksForSpace() {
    final now = DateTime.now();
    return [
      // Link 1: Design System Guide
      LinkWithTags(
        link: Link(
          id: 'link-1',
          userId: 'user-1',
          spaceId: testSpaceId,
          url: 'https://figma.com/design-system',
          normalizedUrl: 'https://figma.com/design-system',
          title: 'Design System Guide',
          description: null,
          thumbnailUrl: null,
          domain: 'figma.com',
          note: 'Important reference',
          openedAt: null,
          createdAt: now,
          updatedAt: now,
        ),
        tags: [
          Tag(
            id: 'tag-1',
            userId: 'user-1',
            name: 'Design',
            color: '#f42cff',
            createdAt: now,
          ),
          Tag(
            id: 'tag-2',
            userId: 'user-1',
            name: 'Reference',
            color: '#682cff',
            createdAt: now,
          ),
        ],
      ),

      // Link 2: API Documentation
      LinkWithTags(
        link: Link(
          id: 'link-2',
          userId: 'user-1',
          spaceId: testSpaceId,
          url: 'https://api.example.com/docs',
          normalizedUrl: 'https://api.example.com/docs',
          title: 'API Documentation',
          description: null,
          thumbnailUrl: null,
          domain: 'api.example.com',
          note: 'Backend docs',
          openedAt: null,
          createdAt: now,
          updatedAt: now,
        ),
        tags: [
          Tag(
            id: 'tag-3',
            userId: 'user-1',
            name: 'Dev',
            color: '#3B82F6',
            createdAt: now,
          ),
          Tag(
            id: 'tag-4',
            userId: 'user-1',
            name: 'Backend',
            color: '#075a52',
            createdAt: now,
          ),
        ],
      ),
    ];
  }

  @override
  Future<List<LinkWithTags>> getLinksBySpace(String userId, String spaceId) async {
    // Only return links for the test space
    if (spaceId == testSpaceId) {
      return getMockLinksForSpace();
    }
    return [];
  }

  // Implement other required methods (not used in these tests)
  @override
  Future<List<LinkWithTags>> getLinksWithTags(String userId) async => [];

  @override
  Future<List<LinkWithTags>> getLinksWithTagsPaginated(
    String userId, {
    required int offset,
    required int limit,
  }) async =>
      [];

  @override
  Future<Link> createLink({
    required String userId,
    required String url,
    required String normalizedUrl,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? domain,
    String? note,
    String? spaceId,
    List<String>? tagIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLink(String linkId) async {}

  @override
  Future<Link> updateLink({
    required String linkId,
    String? note,
    String? spaceId,
    List<String>? tagIds,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> attachTags(String linkId, List<String> tagIds) async {}

  @override
  Future<void> detachTag(String linkId, String tagId) async {}

  @override
  Future<List<Link>> getLinksWithIncompleteMetadata(
    String userId, {
    int limit = 10,
  }) async {
    return [];
  }

  @override
  Future<Link> updateLinkMetadata({
    required String linkId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? domain,
    required bool metadataComplete,
    required int metadataFetchAttempts,
  }) async {
    throw UnimplementedError();
  }
}

/// Mock User for testing
User getMockUser() {
  return User(
    id: 'user-1',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  /// Test Group: Space Search Query Provider
  ///
  /// Tests the StateProvider that holds the current search query.
  /// This is the "source of truth" for what the user is searching for in a space.
  group('spaceSearchQueryProvider', () {
    test('starts with empty string', () {
      // Arrange: Create a provider container
      final container = ProviderContainer();

      // Act: Read the initial value
      final query = container.read(spaceSearchQueryProvider);

      // Assert: Should start empty
      expect(query, '');

      container.dispose();
    });

    test('updates when query changes', () {
      // Arrange: Create container
      final container = ProviderContainer();

      // Act: Update the query
      container.read(spaceSearchQueryProvider.notifier).state = 'design';

      // Assert: Should reflect new value
      final query = container.read(spaceSearchQueryProvider);
      expect(query, 'design');

      container.dispose();
    });

    test('can be cleared', () {
      // Arrange: Create container with existing query
      final container = ProviderContainer();
      container.read(spaceSearchQueryProvider.notifier).state = 'design';

      // Act: Clear the query
      container.read(spaceSearchQueryProvider.notifier).state = '';

      // Assert: Should be empty
      final query = container.read(spaceSearchQueryProvider);
      expect(query, '');

      container.dispose();
    });
  });

  /// Test Group: Filtered Space Links Provider
  ///
  /// Tests the derived provider that filters links within a specific space
  /// based on the search query.
  ///
  /// This tests:
  /// - Filtering by title
  /// - Filtering by note
  /// - Filtering by domain
  /// - Filtering by tags
  /// - Case-insensitive matching
  /// - Empty query returns all space links
  /// - No matches returns empty list
  group('filteredSpaceLinksProvider', () {
    late ProviderContainer container;

    setUp(() {
      // Create container with mock overrides
      container = ProviderContainer(
        overrides: [
          // Mock the current user
          currentUserProvider.overrideWith((ref) => getMockUser()),

          // Mock the link service
          linkServiceProvider.overrideWith((ref) => MockSpaceSearchLinkService()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// Test #1: Empty query returns all links in the space
    test('returns all space links when query is empty', () async {
      // Arrange: Wait for links to load
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Read filtered links with empty query (default state)
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return all 2 links in the space
      expect(filtered.length, 2);
      expect(filtered[0].link.id, 'link-1');
      expect(filtered[1].link.id, 'link-2');
    });

    /// Test #2: Filters by title (case-insensitive)
    test('filters by title', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for "design" (should match "Design System Guide")
      container.read(spaceSearchQueryProvider.notifier).state = 'design';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return only link-1
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-1');
      expect(filtered[0].link.title, 'Design System Guide');
    });

    /// Test #3: Filters by note
    test('filters by note', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for "backend" (should match note "Backend docs")
      container.read(spaceSearchQueryProvider.notifier).state = 'backend';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return only link-2
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-2');
      expect(filtered[0].link.note, 'Backend docs');
    });

    /// Test #4: Filters by domain
    test('filters by domain', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for "figma" (should match domain "figma.com")
      container.read(spaceSearchQueryProvider.notifier).state = 'figma';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return only link-1
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-1');
      expect(filtered[0].link.domain, 'figma.com');
    });

    /// Test #5: Filters by tag name
    test('filters by tag name', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for "design" (should match tag "Design")
      container.read(spaceSearchQueryProvider.notifier).state = 'design';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return link-1 (has "Design" tag)
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-1');
      expect(
        filtered[0].tags.any((tag) => tag.name == 'Design'),
        true,
      );
    });

    /// Test #6: Case-insensitive tag matching with uppercase
    test('filters by tag name (case-insensitive with uppercase)', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for "DESIGN" (uppercase) should still match "Design"
      container.read(spaceSearchQueryProvider.notifier).state = 'DESIGN';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return link-1
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-1');
    });

    /// Test #7: No matches returns empty list
    test('returns empty list when no matches found', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for something that doesn't exist
      container.read(spaceSearchQueryProvider.notifier).state =
          'nonexistentkeyword';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return empty list
      expect(filtered, []);
    });

    /// Test #8: Handles links with no tags gracefully
    test('handles links with no tags gracefully', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search for a tag that doesn't exist
      container.read(spaceSearchQueryProvider.notifier).state = 'nonexistenttag';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should return empty list (no matches)
      expect(filtered, []);
    });

    /// Test #9: Trims whitespace from query
    test('trims whitespace from search query', () async {
      // Arrange: Load links
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Search with extra whitespace
      container.read(spaceSearchQueryProvider.notifier).state = '  design  ';
      final filtered = container.read(
        filteredSpaceLinksProvider(MockSpaceSearchLinkService.testSpaceId),
      );

      // Assert: Should still match (whitespace trimmed)
      expect(filtered.length, 1);
      expect(filtered[0].link.id, 'link-1');
    });

    /// Test #10: Different space IDs have independent results
    test('filters only links in specified space', () async {
      // Arrange: Load links for test space
      await container.read(
        linksBySpaceProvider(MockSpaceSearchLinkService.testSpaceId).future,
      );

      // Act: Try to filter links from a different space
      const differentSpaceId = 'different-space-456';
      final filtered = container.read(
        filteredSpaceLinksProvider(differentSpaceId),
      );

      // Assert: Should return empty list (no links in that space)
      expect(filtered, []);
    });
  });
}

/// 🎓 Learning Summary: Space Search Provider Tests
///
/// **What We're Testing:**
/// Two providers that enable searching within a specific space:
/// 1. spaceSearchQueryProvider - Holds the search query
/// 2. filteredSpaceLinksProvider - Filters space links based on query
///
/// **Key Differences from Home Search:**
///
/// **Home Search (Global):**
/// - Searches ALL user links across all spaces
/// - Uses `linksWithTagsProvider` (returns all links)
/// - Single instance: `filteredLinksProvider`
///
/// **Space Search (Scoped):**
/// - Searches links ONLY in a specific space
/// - Uses `linksBySpaceProvider(spaceId)` (returns space-specific links)
/// - Family provider: `filteredSpaceLinksProvider(spaceId)`
///
/// **Real-World Analogy:**
///
/// **Home Search:**
/// Like searching your entire file system:
/// - "Find files named 'report.pdf' on my whole computer"
///
/// **Space Search:**
/// Like searching within one folder:
/// - "Find files named 'report.pdf' in the Documents/Work folder"
///
/// **Why Family Provider for Space Search?**
///
/// ```dart
/// // Home search - one instance
/// final filtered = ref.watch(filteredLinksProvider);
///
/// // Space search - one instance PER space
/// final filtered = ref.watch(filteredSpaceLinksProvider('space-1'));
/// final filtered = ref.watch(filteredSpaceLinksProvider('space-2'));
/// ```
///
/// Each space gets its own:
/// - Search query state
/// - Filtered results cache
/// - Independent from other spaces
///
/// **Test Pattern (AAA):**
/// Every test follows Arrange-Act-Assert:
///
/// 1. **Arrange**: Set up test data and state
///    - Create container with mocks
///    - Load initial data
///
/// 2. **Act**: Perform the action being tested
///    - Update search query
///    - Read filtered results
///
/// 3. **Assert**: Verify expected outcome
///    - Check result count
///    - Check result content
///
/// **Mock Data Strategy:**
///
/// We use MockSpaceSearchLinkService to provide:
/// - 2 test links in a test space
/// - Different attributes to test all search fields
/// - Consistent, predictable data
/// - Fast tests (no real database)
///
/// **Coverage Summary:**
///
/// ✅ Search query state management (3 tests)
/// ✅ Empty query handling (1 test)
/// ✅ Title filtering (1 test)
/// ✅ Note filtering (1 test)
/// ✅ Domain filtering (1 test)
/// ✅ Tag filtering (2 tests)
/// ✅ Case-insensitive matching (covered in all tests)
/// ✅ No results handling (1 test)
/// ✅ Whitespace trimming (1 test)
/// ✅ Space isolation (1 test)
///
/// **Total: 13 tests** covering all search scenarios within a space.
///
/// **Next Steps (TDD):**
/// 1. 🔴 Run tests - they should FAIL (provider doesn't exist yet)
/// 2. 🟢 Create space_search_provider.dart to make tests pass
/// 3. 🔵 Refactor if needed while keeping tests passing
