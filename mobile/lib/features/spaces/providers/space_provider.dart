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
final spacesProvider = AsyncNotifierProvider<SpacesNotifier, List<Space>>(
  SpacesNotifier.new,
);

/// SpacesNotifier - Manages the state of spaces
///
/// This class:
/// 1. Fetches spaces when first accessed
/// 2. Caches the result
/// 3. Provides a method to refresh
/// 4. Handles errors automatically
class SpacesNotifier extends AsyncNotifier<List<Space>> {
  /// build - Called when the notifier is first accessed
  ///
  /// This is where we fetch the initial data.
  /// Riverpod automatically handles loading/error states.
  @override
  Future<List<Space>> build() async {
    // Get the current user from auth
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    // If no user is logged in, return empty list
    if (userId == null) {
      return [];
    }

    // Get the service
    final spaceService = ref.read(spaceServiceProvider);

    // Fetch spaces
    // This is async, so Riverpod shows loading state automatically
    return await spaceService.getSpaces(userId);
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
