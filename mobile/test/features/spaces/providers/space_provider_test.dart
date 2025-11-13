/// Space Provider Tests
///
/// Testing Riverpod provider for spaces using TDD.
/// Following TDD: Writing tests BEFORE implementation!
///
/// Test Strategy:
/// - Mock SpaceService to control responses
/// - Test success case (fetch spaces)
/// - Test error handling
/// - Test that default spaces appear first
///
/// Real-World Analogy:
/// Think of this like testing a filing cabinet manager:
/// - Success: Opens cabinet, returns all folders in order
/// - Error: Cabinet is locked, returns error message
/// - Order: Default folders (Inbox, Sent) always appear first

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mobile/features/spaces/models/space_model.dart';
import 'package:mobile/features/spaces/services/space_service.dart';
import 'package:mobile/features/spaces/providers/space_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

/// Mock SpaceService for testing
class MockSpaceService extends Mock implements SpaceService {}

/// Mock Supabase User for testing
class MockUser extends Mock implements supabase.User {}

void main() {
  group('SpaceProvider', () {
    late MockSpaceService mockSpaceService;
    late MockUser mockUser;
    late ProviderContainer container;

    /// Test data: Mock user
    const mockUserId = 'test-user-id';

    /// Test data: Mock spaces
    final mockSpaces = [
      Space(
        id: '1',
        userId: mockUserId,
        name: 'Unread',
        color: '#9333EA',
        isDefault: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Space(
        id: '2',
        userId: mockUserId,
        name: 'Reference',
        color: '#DC2626',
        isDefault: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Space(
        id: '3',
        userId: mockUserId,
        name: 'Work',
        color: '#3B82F6',
        isDefault: false,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    /// Setup before each test
    setUp(() {
      mockSpaceService = MockSpaceService();
      mockUser = MockUser();

      // Configure mock user
      when(() => mockUser.id).thenReturn(mockUserId);

      // Create container with overridden providers
      container = ProviderContainer(
        overrides: [
          // Override spaceServiceProvider to use mock
          spaceServiceProvider.overrideWithValue(mockSpaceService),
          // Override currentUserProvider to return mock user
          currentUserProvider.overrideWith((ref) => mockUser),
        ],
      );
    });

    /// Cleanup after each test
    tearDown(() {
      container.dispose();
    });

    /// Test #1: Successfully fetches spaces for authenticated user
    test('fetches spaces from service', () async {
      // Arrange: Mock service to return spaces
      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenAnswer((_) async => mockSpaces);

      // Act: Read the provider (triggers build())
      final spacesAsync = await container.read(spacesProvider.future);

      // Assert: Should return all spaces
      expect(spacesAsync, mockSpaces);
      expect(spacesAsync.length, 3);

      // Verify service was called with correct user ID
      verify(() => mockSpaceService.getSpaces(mockUserId)).called(1);
    });

    /// Test #2: Returns default spaces first
    test('returns default spaces before custom spaces', () async {
      // Arrange
      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenAnswer((_) async => mockSpaces);

      // Act
      final spacesAsync = await container.read(spacesProvider.future);

      // Assert: First two should be default spaces
      expect(spacesAsync[0].name, 'Unread');
      expect(spacesAsync[0].isDefault, true);
      expect(spacesAsync[1].name, 'Reference');
      expect(spacesAsync[1].isDefault, true);
      expect(spacesAsync[2].name, 'Work');
      expect(spacesAsync[2].isDefault, false);
    });

    /// Test #3: Returns empty list if user has no spaces
    test('returns empty list when user has no spaces', () async {
      // Arrange: Mock service to return empty list
      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenAnswer((_) async => []);

      // Act
      final spacesAsync = await container.read(spacesProvider.future);

      // Assert
      expect(spacesAsync, isEmpty);
    });

    /// Test #4: Returns empty list if user is not authenticated
    test('returns empty list when user is not logged in', () async {
      // Arrange: Override to return null user
      final unauthContainer = ProviderContainer(
        overrides: [
          spaceServiceProvider.overrideWithValue(mockSpaceService),
          currentUserProvider.overrideWith((ref) => null),
        ],
      );

      // Act
      final spacesAsync = await unauthContainer.read(spacesProvider.future);

      // Assert: Should return empty list
      expect(spacesAsync, isEmpty);

      // Service should NOT be called for unauthenticated user
      verifyNever(() => mockSpaceService.getSpaces(any()));

      unauthContainer.dispose();
    });

    /// Test #5: Handles service errors gracefully
    test('throws error when service fails', () async {
      // Arrange: Mock service to throw error
      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenThrow(Exception('Database error'));

      // Act & Assert: Should propagate error
      expect(
        () => container.read(spacesProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    /// Test #6: Refresh method re-fetches spaces
    test('refresh() invalidates and re-fetches spaces', () async {
      // Arrange: Initial fetch
      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenAnswer((_) async => mockSpaces);

      // Act: First fetch
      await container.read(spacesProvider.future);

      // Arrange: Change mock data for refresh
      final newSpaces = [
        ...mockSpaces,
        Space(
          id: '4',
          userId: mockUserId,
          name: 'New Space',
          color: '#10B981',
          isDefault: false,
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 3),
        ),
      ];

      when(() => mockSpaceService.getSpaces(mockUserId))
          .thenAnswer((_) async => newSpaces);

      // Act: Refresh
      await container.read(spacesProvider.notifier).refresh();

      // Assert: Should have new data
      final refreshedSpaces = await container.read(spacesProvider.future);
      expect(refreshedSpaces.length, 4);
      expect(refreshedSpaces.last.name, 'New Space');

      // Service should have been called twice (initial + refresh)
      verify(() => mockSpaceService.getSpaces(mockUserId)).called(2);
    });
  });
}

/// 🎓 Learning Summary: Testing Riverpod Providers
///
/// **ProviderContainer:**
/// In tests, we can't use `ref.watch()` like in widgets.
/// Instead, we create a ProviderContainer to simulate the provider tree:
/// ```dart
/// final container = ProviderContainer();
/// final value = await container.read(myProvider.future);
/// ```
///
/// **Provider Overrides:**
/// We can replace providers with test versions:
/// ```dart
/// ProviderContainer(
///   overrides: [
///     myServiceProvider.overrideWithValue(mockService),
///   ],
/// )
/// ```
///
/// This lets us:
/// - Use mocks instead of real services
/// - Control what data providers return
/// - Test providers in isolation
///
/// **AsyncNotifier Testing:**
/// AsyncNotifier providers have special properties:
/// - `.future` - Get the Future value
/// - `.notifier` - Access the notifier methods
///
/// ```dart
/// // Read the data
/// final data = await container.read(provider.future);
///
/// // Call notifier methods
/// await container.read(provider.notifier).refresh();
/// ```
///
/// **Why Mock Services?**
/// We don't want tests to:
/// - Make real database calls (slow, unreliable)
/// - Require database setup
/// - Depend on network connectivity
///
/// Mocking lets us:
/// - Control exactly what data is returned
/// - Test error scenarios
/// - Run tests fast
///
/// **Testing Error Cases:**
/// ```dart
/// when(() => mockService.method())
///   .thenThrow(Exception('Error'));
///
/// expect(
///   () => container.read(provider.future),
///   throwsA(isA<Exception>()),
/// );
/// ```
///
/// **Testing Refresh:**
/// Providers can have refresh methods:
/// ```dart
/// await container.read(provider.notifier).refresh();
/// ```
///
/// We test that:
/// 1. Service is called again
/// 2. New data is returned
/// 3. Old data is replaced
///
/// **Cleanup:**
/// Always dispose containers after tests:
/// ```dart
/// tearDown(() {
///   container.dispose();
/// });
/// ```
///
/// This prevents memory leaks and ensures clean state
/// between tests.
///
/// **Next:**
/// Run these tests - they will FAIL (🔴 RED) because
/// SpaceProvider doesn't exist yet. Then we'll implement it
/// to make them pass (🟢 GREEN).
