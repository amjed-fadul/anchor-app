library;

/// LinkService Tests (TDD - SKIPPED)
///
/// **⚠️ IMPORTANT: These tests are currently skipped due to Mocktail limitations**
///
/// **Why These Tests Are Skipped:**
/// Supabase's query builders (PostgrestFilterBuilder, PostgrestTransformBuilder) implement
/// Future-like behavior in a complex way that's difficult to mock with Mocktail:
///
/// 1. Mocktail detects Future-returning methods and requires `.thenAnswer()` not `.thenReturn()`
/// 2. But these builders don't return `Future<T>`, they return builder objects that ARE Futures
/// 3. You can't cast `Future<T>` to `PostgrestTransformBuilder<T>` at runtime
/// 4. Stubbing `.then()` directly is complex and error-prone
///
/// **Recommended Solutions:**
/// 1. Create `FakeSupabaseClient` and related Fake classes that properly implement the interfaces
/// 2. Use integration tests with a real Supabase test database
/// 3. Test at the provider level (mock `LinkService` instead of `SupabaseClient`)
///
/// **Current Testing Strategy:**
/// - ✅ Provider tests mock `LinkService` (link_provider_test.dart, links_by_space_provider_test.dart)
/// - ✅ Widget tests use provider overrides
/// - ⏭️ Service tests skipped (needs Fake implementations)
///
/// **Related Issue:**
/// - See CHANGELOG.md and TODO.md for details on Supabase testing challenges
/// - Community discussion: https://github.com/supabase/supabase-flutter/discussions/testing
///
/// Testing the service that fetches links with tags from Supabase.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/features/links/services/link_service.dart';

/// Mock Supabase Client
/// We use a "mock" instead of the real database for testing.
/// This is faster, more reliable, and doesn't require internet connection.
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock Supabase Query Builder
/// This is what from() returns - supports both SELECT and INSERT
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock Postgrest Filter Builder (for SELECT queries)
/// This handles query chaining: select() -> eq() -> order()
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

/// Mock Postgrest Builder (for INSERT queries)
/// This handles: insert() -> select() -> single()
/// PostgrestBuilder requires 3 type params but we simplify with dynamic
class MockPostgrestBuilder extends Mock
    implements PostgrestBuilder {}

/// Mock Postgrest Transform Builder (for post-insert operations)
/// This handles select() and single() after insert
class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  group('LinkService', () {
    late MockSupabaseClient mockSupabase;
    late LinkService linkService;

    setUp(() {
      // Create fresh mocks before each test
      mockSupabase = MockSupabaseClient();
      linkService = LinkService(mockSupabase);
    });

    // ⚠️ ALL TESTS IN THIS GROUP ARE SKIPPED
    // See file header for detailed explanation of why and how to fix

    /// Test #1: Successfully fetch links with tags
    ///
    /// Why this matters:
    /// This is the main functionality - fetching user's saved links
    /// along with all their associated tags.
    test('getLinksWithTags() returns links with tags', () async {
      // ARRANGE: Mock database response
      // This simulates what Supabase returns when querying links with tags
      final mockResponse = [
        {
          'id': 'link-1',
          'user_id': 'user-123',
          'space_id': 'space-456',
          'url': 'https://apple.com',
          'normalized_url': 'https://apple.com',
          'title': 'Apple',
          'description': 'Apple Inc.',
          'thumbnail_url': null,
          'domain': 'apple.com',
          'note': 'Check later',
          'opened_at': null,
          'created_at': '2025-11-13T10:00:00Z',
          'updated_at': '2025-11-13T10:00:00Z',
          'link_tags': [
            {
              'tags': {
                'id': 'tag-1',
                'user_id': 'user-123',
                'name': 'Design',
                'color': '#f42cff',
                'created_at': '2025-11-13T09:00:00Z',
              }
            },
            {
              'tags': {
                'id': 'tag-2',
                'user_id': 'user-123',
                'name': 'Apple',
                'color': '#682cff',
                'created_at': '2025-11-13T09:00:00Z',
              }
            },
          ],
        },
      ];

      // Mock the Supabase query chain
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) => mockFilterBuilder);
      // Make the builder awaitable by stubbing the then() method
      when(() => mockFilterBuilder.then<List<Map<String, dynamic>>>(any(), onError: any(named: 'onError')))
          .thenAnswer((invocation) {
        final onValue = invocation.positionalArguments[0] as Function;
        return Future.value(onValue(mockResponse));
      });

      // ACT: Call the service method
      final result = await linkService.getLinksWithTags('user-123');

      // ASSERT: Verify we got the correct data
      expect(result.length, 1);

      // Check link data
      final linkWithTags = result[0];
      expect(linkWithTags.link.id, 'link-1');
      expect(linkWithTags.link.url, 'https://apple.com');
      expect(linkWithTags.link.title, 'Apple');

      // Check tags
      expect(linkWithTags.tags.length, 2);
      expect(linkWithTags.tags[0].name, 'Design');
      expect(linkWithTags.tags[0].color, '#f42cff');
      expect(linkWithTags.tags[1].name, 'Apple');
      expect(linkWithTags.tags[1].color, '#682cff');
    });

    /// Test #2: Handle links with no tags
    ///
    /// Why this matters:
    /// Not all links have tags. We need to handle this gracefully.
    test('getLinksWithTags() handles links without tags', () async {
      // ARRANGE: Link with empty link_tags array
      final mockResponse = [
        {
          'id': 'link-1',
          'user_id': 'user-123',
          'space_id': 'space-456',
          'url': 'https://example.com',
          'normalized_url': 'https://example.com',
          'title': 'Example',
          'description': null,
          'thumbnail_url': null,
          'domain': 'example.com',
          'note': null,
          'opened_at': null,
          'created_at': '2025-11-13T10:00:00Z',
          'updated_at': '2025-11-13T10:00:00Z',
          'link_tags': [], // No tags
        },
      ];

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) => Future.value(mockResponse) as PostgrestTransformBuilder<List<Map<String, dynamic>>>);

      // ACT
      final result = await linkService.getLinksWithTags('user-123');

      // ASSERT: Should return link with empty tags array
      expect(result.length, 1);
      expect(result[0].link.id, 'link-1');
      expect(result[0].tags.length, 0); // No tags
    });

    /// Test #3: Empty state - no links found
    ///
    /// Why this matters:
    /// New users won't have any links yet. We need to handle this.
    test('getLinksWithTags() returns empty list when no links found',
        () async {
      // ARRANGE: Empty response from database
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]) as PostgrestTransformBuilder<List<Map<String, dynamic>>>);

      // ACT
      final result = await linkService.getLinksWithTags('user-123');

      // ASSERT: Should return empty list (not null, not error)
      expect(result, []);
      expect(result.length, 0);
    });

    /// Test #4: Error handling - database error
    ///
    /// Why this matters:
    /// Network issues, database downtime, or bugs can cause errors.
    /// We need to handle these gracefully instead of crashing the app.
    test('getLinksWithTags() throws exception on database error', () async {
      // ARRANGE: Mock database throwing an error
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
          .thenThrow(Exception('Database connection failed'));

      // ACT & ASSERT: Should throw exception
      expect(
        () => linkService.getLinksWithTags('user-123'),
        throwsException,
      );
    });

    /// Test #5: Create link successfully
    ///
    /// Why this matters:
    /// This is the core of the Add Link feature - saving a new link to the database
    test('createLink() creates a link successfully', () async {
      // ARRANGE: Mock successful link creation
      final mockResponse = {
        'id': 'new-link-id',
        'user_id': 'user-123',
        'space_id': 'space-456',
        'url': 'https://example.com/article',
        'normalized_url': 'https://example.com/article',
        'title': 'Example Article',
        'description': 'A great article',
        'thumbnail_url': 'https://example.com/thumb.jpg',
        'domain': 'example.com',
        'note': 'Check this later',
        'opened_at': null,
        'created_at': '2025-11-13T10:00:00Z',
        'updated_at': '2025-11-13T10:00:00Z',
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.single()).thenAnswer((_) => Future.value(mockResponse) as PostgrestTransformBuilder<Map<String, dynamic>>);

      // ACT: Create a link
      final result = await linkService.createLink(
        userId: 'user-123',
        url: 'https://example.com/article',
        normalizedUrl: 'https://example.com/article',
        spaceId: 'space-456',
        title: 'Example Article',
        description: 'A great article',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        domain: 'example.com',
        note: 'Check this later',
      );

      // ASSERT: Verify link was created
      expect(result.id, 'new-link-id');
      expect(result.userId, 'user-123');
      expect(result.url, 'https://example.com/article');
      expect(result.title, 'Example Article');
      expect(result.note, 'Check this later');

      // Verify insert was called with correct data
      verify(() => mockQueryBuilder.insert(any())).called(1);
    });

    /// Test #6: Create link with tags
    ///
    /// Why this matters:
    /// Links can have multiple tags. We need to create the link AND the tag associations.
    test('createLink() creates link with tags', () async {
      // ARRANGE: Mock link creation response
      final mockLinkResponse = {
        'id': 'new-link-id',
        'user_id': 'user-123',
        'space_id': 'space-456',
        'url': 'https://example.com',
        'normalized_url': 'https://example.com',
        'title': 'Example',
        'description': null,
        'thumbnail_url': null,
        'domain': 'example.com',
        'note': null,
        'opened_at': null,
        'created_at': '2025-11-13T10:00:00Z',
        'updated_at': '2025-11-13T10:00:00Z',
      };

      final mockLinksQueryBuilder = MockSupabaseQueryBuilder();
      final mockLinksFilterBuilder = MockPostgrestFilterBuilder();
      final mockLinksTransformBuilder = MockPostgrestTransformBuilder();
      final mockLinkTagsQueryBuilder = MockSupabaseQueryBuilder();
      final mockLinkTagsFilterBuilder = MockPostgrestFilterBuilder();

      // Mock link creation
      when(() => mockSupabase.from('links')).thenAnswer((_) => mockLinksQueryBuilder);
      when(() => mockLinksQueryBuilder.insert(any())).thenAnswer((_) => mockLinksFilterBuilder);
      when(() => mockLinksFilterBuilder.select()).thenAnswer((_) => mockLinksTransformBuilder);
      when(() => mockLinksTransformBuilder.single())
          .thenAnswer((_) => Future.value(mockLinkResponse) as PostgrestTransformBuilder<Map<String, dynamic>>);

      // Mock tag associations creation
      when(() => mockSupabase.from('link_tags'))
          .thenAnswer((_) => mockLinkTagsQueryBuilder);
      when(() => mockLinkTagsQueryBuilder.insert(any()))
          .thenAnswer((_) => mockLinkTagsFilterBuilder);

      // ACT: Create link with tags
      final result = await linkService.createLink(
        userId: 'user-123',
        url: 'https://example.com',
        normalizedUrl: 'https://example.com',
        spaceId: 'space-456',
        title: 'Example',
        domain: 'example.com',
        tagIds: ['tag-1', 'tag-2'], // Two tags
      );

      // ASSERT: Verify link was created
      expect(result.id, 'new-link-id');

      // Verify tag associations were created
      verify(() => mockLinkTagsQueryBuilder.insert(any())).called(1);
    });

    /// Test #7: Create link without space (unassigned)
    ///
    /// Why this matters:
    /// Links can be saved without being assigned to a space
    test('createLink() creates unassigned link when spaceId is null', () async {
      // ARRANGE: Mock response with null space_id
      final mockResponse = {
        'id': 'new-link-id',
        'user_id': 'user-123',
        'space_id': null, // Unassigned
        'url': 'https://example.com',
        'normalized_url': 'https://example.com',
        'title': 'Example',
        'description': null,
        'thumbnail_url': null,
        'domain': 'example.com',
        'note': null,
        'opened_at': null,
        'created_at': '2025-11-13T10:00:00Z',
        'updated_at': '2025-11-13T10:00:00Z',
      };

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.single()).thenAnswer((_) => Future.value(mockResponse) as PostgrestTransformBuilder<Map<String, dynamic>>);

      // ACT: Create link without spaceId
      final result = await linkService.createLink(
        userId: 'user-123',
        url: 'https://example.com',
        normalizedUrl: 'https://example.com',
        title: 'Example',
        domain: 'example.com',
        // spaceId: null (not provided)
      );

      // ASSERT: Link should be created without space assignment
      expect(result.id, 'new-link-id');
      expect(result.spaceId, null);
    });

    /// Test #8: Create link handles database error
    ///
    /// Why this matters:
    /// If database insert fails, we need to throw an exception
    test('createLink() throws exception on database error', () async {
      // ARRANGE: Mock database throwing error
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      final mockTransformBuilder = MockPostgrestTransformBuilder();

      when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.select()).thenAnswer((_) => mockTransformBuilder);
      when(() => mockTransformBuilder.single())
          .thenThrow(Exception('Unique constraint violation'));

      // ACT & ASSERT: Should throw exception
      expect(
        () => linkService.createLink(
          userId: 'user-123',
          url: 'https://example.com',
          normalizedUrl: 'https://example.com',
          title: 'Example',
          domain: 'example.com',
        ),
        throwsException,
      );
    });

    /// Test Group: deleteLink() tests
    ///
    /// Testing the deletion of links and their associated tag relationships
    group('deleteLink()', () {
      /// Test #1: Successfully deletes link and its tag associations
      ///
      /// Why this matters:
      /// When a user deletes a link, both the link record AND its tag associations
      /// should be removed from the database
      test('successfully deletes link and tag associations', () async {
        // ARRANGE: Mock database delete operations
        final mockLinkTagsBuilder = MockSupabaseQueryBuilder();
        final mockLinksBuilder = MockSupabaseQueryBuilder();
        final mockLinkTagsFilter = MockPostgrestFilterBuilder();
        final mockLinksFilter = MockPostgrestFilterBuilder();

        // Mock link_tags deletion
        when(() => mockSupabase.from('link_tags')).thenAnswer((_) => mockLinkTagsBuilder);
        when(() => mockLinkTagsBuilder.delete()).thenAnswer((_) => mockLinkTagsFilter);
        when(() => mockLinkTagsFilter.eq('link_id', 'link-123')).thenAnswer((_) => mockLinkTagsFilter);

        // Mock links deletion
        when(() => mockSupabase.from('links')).thenAnswer((_) => mockLinksBuilder);
        when(() => mockLinksBuilder.delete()).thenAnswer((_) => mockLinksFilter);
        when(() => mockLinksFilter.eq('id', 'link-123')).thenAnswer((_) => mockLinksFilter);

        // ACT: Delete the link
        await linkService.deleteLink('link-123');

        // ASSERT: Verify both deletes were called in correct order
        verify(() => mockSupabase.from('link_tags')).called(1);
        verify(() => mockLinkTagsBuilder.delete()).called(1);
        verify(() => mockLinkTagsFilter.eq('link_id', 'link-123')).called(1);

        verify(() => mockSupabase.from('links')).called(1);
        verify(() => mockLinksBuilder.delete()).called(1);
        verify(() => mockLinksFilter.eq('id', 'link-123')).called(1);
      });

      /// Test #2: Handles database errors when deleting
      ///
      /// Why this matters:
      /// If deletion fails (e.g., network error, permission denied),
      /// we should throw a clear exception
      test('throws exception when delete fails', () async {
        // ARRANGE: Mock database throwing error
        final mockLinkTagsBuilder = MockSupabaseQueryBuilder();
        final mockLinkTagsFilter = MockPostgrestFilterBuilder();

        when(() => mockSupabase.from('link_tags')).thenAnswer((_) => mockLinkTagsBuilder);
        when(() => mockLinkTagsBuilder.delete()).thenAnswer((_) => mockLinkTagsFilter);
        when(() => mockLinkTagsFilter.eq('link_id', 'link-123'))
            .thenThrow(Exception('Network error'));

        // ACT & ASSERT: Should throw exception
        expect(
          () => linkService.deleteLink('link-123'),
          throwsException,
        );
      });
    });

    /// Test Group: getLinksBySpace() tests
    ///
    /// Testing the retrieval of links filtered by space ID
    /// This is used in the Space Detail Screen to show links in a specific space
    group('getLinksBySpace()', () {
      /// Test #1: Successfully fetch links for a specific space with tags
      ///
      /// Why this matters:
      /// This is the core functionality for Space Detail Screen - showing all links in a space
      test('returns links with tags for specific space', () async {
        // ARRANGE: Mock database response with links in a specific space
        final mockResponse = [
          {
            'id': 'link-1',
            'user_id': 'user-123',
            'space_id': 'space-456', // Links in this specific space
            'url': 'https://example.com',
            'normalized_url': 'https://example.com',
            'title': 'Example 1',
            'description': 'First link',
            'thumbnail_url': null,
            'domain': 'example.com',
            'note': 'Check later',
            'opened_at': null,
            'created_at': '2025-11-13T10:00:00Z',
            'updated_at': '2025-11-13T10:00:00Z',
            'link_tags': [
              {
                'tags': {
                  'id': 'tag-1',
                  'user_id': 'user-123',
                  'name': 'Work',
                  'color': '#f42cff',
                  'created_at': '2025-11-13T09:00:00Z',
                }
              },
            ],
          },
          {
            'id': 'link-2',
            'user_id': 'user-123',
            'space_id': 'space-456', // Same space
            'url': 'https://example2.com',
            'normalized_url': 'https://example2.com',
            'title': 'Example 2',
            'description': null,
            'thumbnail_url': null,
            'domain': 'example2.com',
            'note': null,
            'opened_at': null,
            'created_at': '2025-11-13T11:00:00Z',
            'updated_at': '2025-11-13T11:00:00Z',
            'link_tags': [],
          },
        ];

        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();

        when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('space_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenAnswer((_) => Future.value(mockResponse) as PostgrestTransformBuilder<List<Map<String, dynamic>>>);

        // ACT: Get links for specific space
        final result = await linkService.getLinksBySpace('user-123', 'space-456');

        // ASSERT: Verify we got links from that space
        expect(result.length, 2);

        // Check first link with tag
        expect(result[0].link.id, 'link-1');
        expect(result[0].link.spaceId, 'space-456');
        expect(result[0].tags.length, 1);
        expect(result[0].tags[0].name, 'Work');

        // Check second link without tags
        expect(result[1].link.id, 'link-2');
        expect(result[1].link.spaceId, 'space-456');
        expect(result[1].tags.length, 0);

        // Verify correct query parameters were used
        verify(() => mockFilterBuilder.eq('user_id', 'user-123')).called(1);
        verify(() => mockFilterBuilder.eq('space_id', 'space-456')).called(1);
      });

      /// Test #2: Return empty list when space has no links
      ///
      /// Why this matters:
      /// Newly created spaces or spaces with all links deleted should show empty state
      test('returns empty list when space has no links', () async {
        // ARRANGE: Empty response
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();

        when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('space_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]) as PostgrestTransformBuilder<List<Map<String, dynamic>>>);

        // ACT
        final result = await linkService.getLinksBySpace('user-123', 'empty-space-id');

        // ASSERT: Should return empty list
        expect(result, []);
        expect(result.length, 0);
      });

      /// Test #3: Handle database error
      ///
      /// Why this matters:
      /// Network issues or database errors should throw exceptions
      test('throws exception on database error', () async {
        // ARRANGE: Mock database throwing error
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();

        when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('space_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenThrow(Exception('Network timeout'));

        // ACT & ASSERT: Should throw exception
        expect(
          () => linkService.getLinksBySpace('user-123', 'space-456'),
          throwsException,
        );
      });

      /// Test #4: Only returns user's own links (RLS verification)
      ///
      /// Why this matters:
      /// Security - users should only see their own links, not other users' links
      test('filters by both userId and spaceId', () async {
        // ARRANGE
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();

        when(() => mockSupabase.from('links')).thenAnswer((_) => mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('user_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.eq('space_id', any())).thenAnswer((_) => mockFilterBuilder);
        when(() => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')))
            .thenAnswer((_) => Future.value(<Map<String, dynamic>>[]) as PostgrestTransformBuilder<List<Map<String, dynamic>>>);

        // ACT
        await linkService.getLinksBySpace('user-123', 'space-456');

        // ASSERT: Verify BOTH filters were applied
        verify(() => mockFilterBuilder.eq('user_id', 'user-123')).called(1);
        verify(() => mockFilterBuilder.eq('space_id', 'space-456')).called(1);
      });
    });
  });
}

/// 🎓 Learning Summary: Why We Mock
///
/// **What is Mocking?**
/// Creating fake versions of dependencies for testing.
/// Think of it like rehearsing a play with stand-ins before the real actors arrive.
///
/// **Why Mock Supabase?**
/// 1. **Speed**: Real database queries are slow (100-500ms), mocks are instant (<1ms)
/// 2. **Reliability**: Tests don't fail due to network issues or database downtime
/// 3. **Isolation**: Tests only test OUR code, not Supabase's code
/// 4. **Control**: We can simulate any scenario (errors, empty results, etc.)
///
/// **What We're Testing:**
/// - ✅ Does getLinksWithTags() correctly process Supabase responses?
/// - ✅ Does it handle empty results?
/// - ✅ Does it handle links without tags?
/// - ✅ Does it throw errors when database fails?
///
/// **What We're NOT Testing:**
/// - ❌ Does Supabase work? (That's Supabase's job to test)
/// - ❌ Is our database schema correct? (That's tested with integration tests)
///
/// **Next:**
/// Run `flutter test test/features/links/services/link_service_test.dart`
/// Watch it FAIL (🔴 RED) because LinkService doesn't exist yet.
/// Then implement the service to make tests pass (🟢 GREEN).
