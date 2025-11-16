library;

/// Space Providers
///
/// State management for spaces using Riverpod.
///
/// What this does:
/// - Provides access to user's spaces (folders for organizing links)
/// - Automatically fetches spaces when accessed
/// - Caches spaces for quick access
/// - Provides refresh method to reload from database
///
/// Real-World Analogy:
/// Think of this like a smart filing cabinet:
/// - First time you open it: Fetches your folders from storage
/// - After that: Shows cached folders instantly
/// - Pull to refresh: Re-checks storage for new folders

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/space_model.dart';
import '../services/space_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for SpaceService instance
///
/// This is a singleton - only one SpaceService exists for the whole app.
/// Every screen that needs to interact with spaces uses this same service.
///
/// Why?
/// - Efficiency: Don't create multiple service instances
/// - Consistency: All screens use the same data source
/// - Easy to mock for testing
final spaceServiceProvider = Provider<SpaceService>((ref) {
  // Get Supabase client
  final supabase = Supabase.instance.client;

  // Create and return service
  return SpaceService(supabase);
});

/// Provider for fetching user's spaces
///
/// This is an AsyncNotifier - it handles async data fetching automatically.
/// It manages three states: loading, data, error.
///
/// How to use in UI:
/// ```dart
/// final spacesAsync = ref.watch(spacesProvider);
///
/// spacesAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
///   data: (spaces) => ListView.builder(
///     itemCount: spaces.length,
///     itemBuilder: (context, index) {
///       final space = spaces[index];
///       return ListTile(
///         title: Text(space.name),
///         leading: CircleAvatar(
///           backgroundColor: Color(int.parse(space.color.replaceFirst('#', '0xFF'))),
///         ),
///       );
///     },
///   ),
/// );
/// ```
final spacesProvider = AsyncNotifierProvider.autoDispose<SpacesNotifier, List<Space>>(
  SpacesNotifier.new,
);

/// SpacesNotifier - Manages the state of spaces
///
/// This class:
/// 1. Fetches spaces when first accessed
/// 2. Caches the result
/// 3. Provides a method to refresh
/// 4. Handles errors automatically
/// 5. Auto-disposes when no longer watched (prevents stale state)
class SpacesNotifier extends AutoDisposeAsyncNotifier<List<Space>> {
  /// build - Called when the notifier is first accessed
  ///
  /// This is where we fetch the initial data.
  /// Riverpod automatically handles loading/error states.
  @override
  Future<List<Space>> build() async {
    // 🐛 DEBUG: Track when and from where build() is called
    debugPrint('🔵 [SpacesNotifier] build() called');
    debugPrint('🔵 [SpacesNotifier] Stack trace:\n${StackTrace.current}');

    // Get the current user from auth
    // IMPORTANT: Use ref.watch() not ref.read() so provider rebuilds on auth changes
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;

    debugPrint('🔵 [SpacesNotifier] User ID: $userId');

    // If no user is logged in, return empty list
    if (userId == null) {
      debugPrint('⚠️ [SpacesNotifier] No user logged in, returning empty list');
      return [];
    }

    // Get the service
    final spaceService = ref.read(spaceServiceProvider);

    debugPrint('🔵 [SpacesNotifier] About to fetch spaces from database...');

    // Fetch spaces
    // This is async, so Riverpod shows loading state automatically
    final spaces = await spaceService.getSpaces(userId);

    debugPrint('✅ [SpacesNotifier] build() completed, returning ${spaces.length} spaces');

    return spaces;
  }

  /// refresh - Manually refresh the spaces
  ///
  /// Call this when:
  /// - User pulls to refresh
  /// - User creates a new space
  /// - User updates a space
  /// - User deletes a space
  ///
  /// Usage:
  /// ```dart
  /// ref.read(spacesProvider.notifier).refresh();
  /// ```
  Future<void> refresh() async {
    // Invalidate the current state and rebuild
    // This fetches fresh data from the database
    ref.invalidateSelf();

    // Wait for the new data to load
    await future;
  }

  /// createSpace - Create a new space
  ///
  /// Creates a new custom space with the given name and color.
  /// After creation, automatically refreshes the spaces list to show the new space.
  ///
  /// Parameters:
  /// - name: Name for the new space (1-50 characters)
  /// - color: Hex color code (e.g., '#7cfec4')
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(spacesProvider.notifier).createSpace('Work', '#3B82F6');
  /// ```
  ///
  /// Throws Exception if:
  /// - User not logged in
  /// - Name is invalid (empty, too long)
  /// - Database error occurs
  Future<void> createSpace(String name, String color) async {
    debugPrint('🔵 [SpacesNotifier] createSpace() called');
    debugPrint('🔵 [SpacesNotifier] Name: $name, Color: $color');

    // Get current user
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    if (userId == null) {
      debugPrint('🔴 [SpacesNotifier] Cannot create space: No user logged in');
      throw Exception('User not logged in');
    }

    // Validate name
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      debugPrint('🔴 [SpacesNotifier] Cannot create space: Name is empty');
      throw Exception('Space name cannot be empty');
    }

    if (trimmedName.length > 50) {
      debugPrint('🔴 [SpacesNotifier] Cannot create space: Name too long');
      throw Exception('Space name cannot exceed 50 characters');
    }

    try {
      // Create space via service
      final spaceService = ref.read(spaceServiceProvider);
      final newSpace = await spaceService.createSpace(
        userId: userId,
        name: trimmedName,
        color: color,
      );

      debugPrint('✅ [SpacesNotifier] Space created: ${newSpace.name} (${newSpace.color})');

      // Refresh the spaces list to include the new space
      await refresh();

      debugPrint('✅ [SpacesNotifier] Spaces list refreshed');
    } catch (e) {
      debugPrint('🔴 [SpacesNotifier] Error creating space: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// updateSpace - Update an existing space
  ///
  /// Updates a space's name and/or color.
  /// After update, automatically refreshes the spaces list.
  ///
  /// Parameters:
  /// - spaceId: ID of the space to update
  /// - name: New name (optional)
  /// - color: New color (optional)
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(spacesProvider.notifier).updateSpace(
  ///   spaceId,
  ///   name: 'Updated Name',
  /// );
  /// ```
  ///
  /// Throws Exception if:
  /// - Database error occurs
  Future<void> updateSpace(String spaceId, {String? name, String? color}) async {
    debugPrint('🔵 [SpacesNotifier] updateSpace() called');
    debugPrint('🔵 [SpacesNotifier] Space ID: $spaceId, Name: $name, Color: $color');

    try {
      // Update space via service
      final spaceService = ref.read(spaceServiceProvider);
      await spaceService.updateSpace(
        spaceId: spaceId,
        name: name,
        color: color,
      );

      debugPrint('✅ [SpacesNotifier] Space updated successfully');

      // Refresh the spaces list to show updated space
      await refresh();

      debugPrint('✅ [SpacesNotifier] Spaces list refreshed');
    } catch (e) {
      debugPrint('🔴 [SpacesNotifier] Error updating space: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }

  /// deleteSpace - Delete a space
  ///
  /// Deletes a space. Cannot delete default spaces (Unread, Reference).
  /// Links in the deleted space are not deleted - they become unassigned.
  /// After deletion, automatically refreshes the spaces list.
  ///
  /// Parameters:
  /// - spaceId: ID of the space to delete
  ///
  /// Usage:
  /// ```dart
  /// await ref.read(spacesProvider.notifier).deleteSpace(spaceId);
  /// ```
  ///
  /// Throws Exception if:
  /// - Trying to delete a default space (database trigger prevents this)
  /// - Database error occurs
  Future<void> deleteSpace(String spaceId) async {
    debugPrint('🔵 [SpacesNotifier] deleteSpace() called');
    debugPrint('🔵 [SpacesNotifier] Space ID: $spaceId');

    try {
      // Delete space via service
      final spaceService = ref.read(spaceServiceProvider);
      await spaceService.deleteSpace(spaceId);

      debugPrint('✅ [SpacesNotifier] Space deleted successfully');

      // Refresh the spaces list to remove deleted space
      await refresh();

      debugPrint('✅ [SpacesNotifier] Spaces list refreshed');
    } catch (e) {
      debugPrint('🔴 [SpacesNotifier] Error deleting space: $e');
      rethrow; // Re-throw to let UI handle the error
    }
  }
}

/// 🎓 Learning Summary: Riverpod AsyncNotifier Pattern
///
/// **AsyncNotifier vs StateNotifier:**
///
/// **StateNotifier:**
/// - For synchronous state
/// - You manage state manually: `state = newValue`
/// - Example: Counter, form input
///
/// **AsyncNotifier:**
/// - For asynchronous data (database, API calls)
/// - Riverpod manages loading/error/data states
/// - Example: Fetching from database, API requests
///
/// **How AsyncNotifier Works:**
///
/// 1. **First Access:**
/// ```dart
/// ref.watch(spacesProvider)
/// ```
/// - Riverpod calls `build()`
/// - Returns `AsyncLoading` (loading state)
/// - Fetches data from database
/// - Returns `AsyncData` (success) or `AsyncError` (failure)
///
/// 2. **Subsequent Access:**
/// - Returns cached `AsyncData`
/// - No additional database queries
/// - Instant display
///
/// 3. **Manual Refresh:**
/// ```dart
/// ref.read(spacesProvider.notifier).refresh()
/// ```
/// - Invalidates cache
/// - Calls `build()` again
/// - Fetches fresh data
/// - All listeners automatically update
///
/// **AsyncValue States:**
/// ```dart
/// spacesAsync.when(
///   loading: () => LoadingWidget(),     // While fetching
///   error: (err, stack) => ErrorWidget(), // If fetch fails
///   data: (spaces) => DataWidget(),      // When data arrives
/// )
/// ```
///
/// **Why This Pattern?**
/// 1. **Automatic State Management:**
///    - No manual loading flags
///    - No manual error handling
///    - Riverpod does it all
///
/// 2. **Type Safety:**
///    - Compiler knows the data type
///    - Can't access data in loading state
///    - Forces you to handle all states
///
/// 3. **Caching:**
///    - Data is cached automatically
///    - Multiple widgets can read without re-fetching
///    - Reduces database load
///
/// 4. **Refresh:**
///    - Easy to refresh from anywhere
///    - All consumers update automatically
///    - No need to notify widgets manually
///
/// **Provider Dependencies:**
/// ```dart
/// final user = ref.read(currentUserProvider);
/// ```
///
/// Providers can depend on other providers!
/// When `currentUserProvider` changes (user logs out),
/// this provider automatically rebuilds.
///
/// **Early Return for Invalid State:**
/// ```dart
/// if (userId == null) {
///   return [];
/// }
/// ```
///
/// If user is not logged in, we return empty list immediately.
/// No need to call the database with null user ID.
///
/// **ref.invalidateSelf():**
/// ```dart
/// ref.invalidateSelf();
/// await future;
/// ```
///
/// This tells Riverpod to:
/// 1. Discard current cached data
/// 2. Call `build()` again
/// 3. Show loading state to UI
/// 4. Fetch fresh data from database
///
/// **Next:**
/// Run tests to verify implementation passes (🟢 GREEN)
