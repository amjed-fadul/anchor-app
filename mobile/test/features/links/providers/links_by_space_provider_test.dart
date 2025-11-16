/// Links By Space Provider Tests
///
/// Testing Riverpod FamilyAsyncNotifierProvider for fetching links by space.
/// Following TDD: Writing tests BEFORE implementation!
///
/// Test Strategy:
/// - Mock LinkService to control responses
/// - Test success case (fetch links for specific space)
/// - Test empty space case (no links)
/// - Test error handling
///
/// Real-World Analogy:
/// Think of this like a folder viewer in a file manager:
/// - Success: Open "Design" folder, see all design files
/// - Empty: Open "Archive" folder, it's empty
/// - Error: Folder is corrupted, show error message
///
/// Provider Type: FamilyAsyncNotifierProvider
/// Why "Family"? Because we need one provider instance PER space ID.
/// Example: linksBySpaceProvider('space-1') is different from linksBySpaceProvider('space-2')

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/features/links/models/link_model.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/links/providers/links_by_space_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

/// Mock LinkService for testing
class MockLinkService extends Mock implements LinkService {}

/// Mock Supabase User for testing
class MockUser extends Mock implements supabase.User {}

void main() {
  group('LinksBySpaceProvider', () {
    late MockLinkService mockLinkService;
    late MockUser mockUser;
    late ProviderContainer container;

    /// Test data: Mock user
    const mockUserId = 'test-user-id';
    const mockSpaceId = 'test-space-id';

    /// Test data: Mock links with tags
    final mockLinksWithTags = [
      LinkWithTags(
        link: Link(
          id: 'link-1',
          userId: mockUserId,
          spaceId: mockSpaceId,
          url: 'https://apple.com',
          normalizedUrl: 'https://apple.com',
          title: 'Apple',
          description: 'Think Different',
          thumbnailUrl: 'https://apple.com/thumb.jpg',
          domain: 'apple.com',
          note: 'Design inspiration',
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
      LinkWithTags(
        link: Link(
          id: 'link-2',
          userId: mockUserId,
          spaceId: mockSpaceId,
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

    /// Setup before each test
    setUp(() {
      mockLinkService = MockLinkService();
      mockUser = MockUser();

      // Configure mock user
      when(() => mockUser.id).thenReturn(mockUserId);

      // Create container with overridden providers
      container = ProviderContainer(
        overrides: [
          // Override linkServiceProvider to use mock
          linkServiceProvider.overrideWithValue(mockLinkService),
          // Override currentUserProvider to return mock user
          currentUserProvider.overrideWith((ref) => mockUser),
        ],
      );
    });

    /// Cleanup after each test
    tearDown(() {
      container.dispose();
    });

    /// Test #1: Successfully fetches links for specific space
    ///
    /// Why this matters:
    /// This is the core functionality for the Space Detail Screen.
    /// When user taps on a space, they should see all links in that space.
    test('fetches links for specific space', () async {
      // Arrange: Mock service to return links
      when(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .thenAnswer((_) async => mockLinksWithTags);

      // Act: Read the provider (this triggers the fetch)
      final asyncValue =
          await container.read(linksBySpaceProvider(mockSpaceId).future);

      // Assert: Verify we got the correct data
      expect(asyncValue.length, 2);
      expect(asyncValue[0].link.id, 'link-1');
      expect(asyncValue[0].link.spaceId, mockSpaceId);
      expect(asyncValue[0].tags.length, 1);
      expect(asyncValue[1].link.id, 'link-2');
      expect(asyncValue[1].tags.length, 0);

      // Verify service was called with correct parameters
      verify(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .called(1);
    });

    /// Test #2: Returns empty list when space has no links
    ///
    /// Why this matters:
    /// New spaces or spaces after clearing all links should show empty state.
    /// The UI will show "This space is empty" message.
    test('returns empty list when space has no links', () async {
      // Arrange: Mock service to return empty list
      when(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .thenAnswer((_) async => []);

      // Act: Read the provider
      final asyncValue =
          await container.read(linksBySpaceProvider(mockSpaceId).future);

      // Assert: Should return empty list (not null, not error)
      expect(asyncValue, []);
      expect(asyncValue.length, 0);

      // Verify service was called
      verify(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .called(1);
    });

    /// Test #3: Handles database errors gracefully
    ///
    /// Why this matters:
    /// Network issues, database downtime, or permissions errors should not crash the app.
    /// Instead, show an error state in the UI.
    test('handles errors from service', () async {
      // Arrange: Mock service to throw an error
      when(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .thenThrow(Exception('Failed to fetch links for space'));

      // Act & Assert: Provider should be in error state
      final asyncValue =
          container.read(linksBySpaceProvider(mockSpaceId));

      // Wait for the future to complete
      await expectLater(
        container.read(linksBySpaceProvider(mockSpaceId).future),
        throwsException,
      );

      // Verify service was called
      verify(() => mockLinkService.getLinksBySpace(mockUserId, mockSpaceId))
          .called(1);
    });

    /// Test #4: Different space IDs create different provider instances
    ///
    /// Why this matters:
    /// This is unique to FamilyProviders. Each space should have its own cache.
    /// Opening "Design Resources" space shouldn't affect "Work" space's data.
    test('creates separate instances for different space IDs', () async {
      // Arrange: Create mock data for two different spaces
      const spaceId1 = 'space-1';
      const spaceId2 = 'space-2';

      final linksSpace1 = [
        LinkWithTags(
          link: Link(
            id: 'link-1',
            userId: mockUserId,
            spaceId: spaceId1,
            url: 'https://example1.com',
            normalizedUrl: 'https://example1.com',
            title: 'Example 1',
            description: null,
            thumbnailUrl: null,
            domain: 'example1.com',
            note: null,
            openedAt: null,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          tags: [],
        ),
      ];

      final linksSpace2 = [
        LinkWithTags(
          link: Link(
            id: 'link-2',
            userId: mockUserId,
            spaceId: spaceId2,
            url: 'https://example2.com',
            normalizedUrl: 'https://example2.com',
            title: 'Example 2',
            description: null,
            thumbnailUrl: null,
            domain: 'example2.com',
            note: null,
            openedAt: null,
            createdAt: DateTime(2024, 1, 2),
            updatedAt: DateTime(2024, 1, 2),
          ),
          tags: [],
        ),
      ];

      // Mock service to return different data for each space
      when(() => mockLinkService.getLinksBySpace(mockUserId, spaceId1))
          .thenAnswer((_) async => linksSpace1);
      when(() => mockLinkService.getLinksBySpace(mockUserId, spaceId2))
          .thenAnswer((_) async => linksSpace2);

      // Act: Fetch links for both spaces
      final space1Links =
          await container.read(linksBySpaceProvider(spaceId1).future);
      final space2Links =
          await container.read(linksBySpaceProvider(spaceId2).future);

      // Assert: Each space should have its own data
      expect(space1Links.length, 1);
      expect(space1Links[0].link.id, 'link-1');
      expect(space1Links[0].link.spaceId, spaceId1);

      expect(space2Links.length, 1);
      expect(space2Links[0].link.id, 'link-2');
      expect(space2Links[0].link.spaceId, spaceId2);

      // Verify service was called once for each space
      verify(() => mockLinkService.getLinksBySpace(mockUserId, spaceId1))
          .called(1);
      verify(() => mockLinkService.getLinksBySpace(mockUserId, spaceId2))
          .called(1);
    });
  });
}

/// 🎓 Learning Summary: FamilyAsyncNotifierProvider
///
/// **What is a Family Provider?**
/// A provider that takes parameters and creates separate instances for each parameter value.
///
/// **Real-World Analogy:**
/// Think of a vending machine with multiple slots:
/// - Regular provider = One slot (always gives the same thing)
/// - Family provider = Multiple slots (each slot has different content)
/// - linksBySpaceProvider('space-1') = Slot A (has Design links)
/// - linksBySpaceProvider('space-2') = Slot B (has Work links)
///
/// **When to Use Family Providers:**
/// - Fetching data by ID (user profile by userId, space links by spaceId)
/// - Parameterized state (search results by query, filtered lists by category)
/// - Any time you need "one provider instance per X"
///
/// **Benefits:**
/// - Automatic caching (each spaceId caches its own data)
/// - Automatic disposal (when no longer watched, instance is cleaned up)
/// - Type-safe parameters (Dart knows what type spaceId should be)
///
/// **Next:**
/// Implement the LinksBySpaceProvider to make these tests pass!
