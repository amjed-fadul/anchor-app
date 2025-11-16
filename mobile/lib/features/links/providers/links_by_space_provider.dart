library;

/// Links By Space Provider
///
/// State management for fetching links filtered by space ID using Riverpod.
///
/// What is a Family Provider?
/// A provider that takes parameters and creates separate instances for each parameter.
/// Think of it like a vending machine with multiple slots - each slot (space ID) has its own contents.
///
/// Why Family Provider for Space Links?
/// - Each space has its own list of links
/// - Separate caching per space (opening "Design" space doesn't affect "Work" space)
/// - Automatic disposal when space screen is closed
/// - Type-safe parameter (Dart knows spaceId must be a String)
///
/// Real-World Analogy:
/// Imagine a filing cabinet with drawers (spaces):
/// - linksBySpaceProvider('design-drawer') fetches contents of design drawer
/// - linksBySpaceProvider('work-drawer') fetches contents of work drawer
/// - Each drawer maintains its own cache
/// - When you close a drawer (navigate away), it cleans up resources

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/link_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for fetching links by space ID
///
/// This is a FamilyAsyncNotifierProvider - it takes a spaceId parameter.
/// Each unique spaceId gets its own provider instance with its own cache.
///
/// How to use in UI:
/// ```dart
/// final spaceLinksAsync = ref.watch(linksBySpaceProvider(spaceId));
///
/// spaceLinksAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
///   data: (links) {
///     if (links.isEmpty) {
///       return Text('This space is empty');
///     }
///     return GridView.builder(
///       itemCount: links.length,
///       itemBuilder: (context, index) {
///         final linkWithTags = links[index];
///         return LinkCard(
///           link: linkWithTags.link,
///           tags: linkWithTags.tags,
///         );
///       },
///     );
///   },
/// );
/// ```
final linksBySpaceProvider =
    AsyncNotifierProvider.family<LinksBySpaceNotifier, List<LinkWithTags>, String>(
  LinksBySpaceNotifier.new,
);

/// LinksBySpaceNotifier - Manages the state of links for a specific space
///
/// This class:
/// 1. Fetches links for a specific space when first accessed
/// 2. Caches the result per space ID
/// 3. Provides a method to refresh
/// 4. Handles errors automatically
/// 5. Auto-disposes when no longer watched
///
/// Family Notifier vs Regular Notifier:
/// - Regular: build() { ... } - no parameters
/// - Family: build(String spaceId) { ... } - takes parameter
class LinksBySpaceNotifier extends FamilyAsyncNotifier<List<LinkWithTags>, String> {
  /// build - Called when the notifier is first accessed for a given spaceId
  ///
  /// This is where we fetch the initial data for the specified space.
  /// Riverpod automatically handles loading/error states.
  ///
  /// @param spaceId The ID of the space whose links we want to fetch
  ///
  /// IMPORTANT: We use ref.watch() for currentUserProvider so that
  /// this provider automatically rebuilds when the user logs in/out.
  @override
  Future<List<LinkWithTags>> build(String spaceId) async {
    // CRITICAL: Watch the current user (not read)
    // This makes the provider rebuild when auth state changes
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;

    // If no user is logged in, return empty list
    if (userId == null) {
      return [];
    }

    // Get the service
    final linkService = ref.read(linkServiceProvider);

    // Fetch links for this specific space
    // The service filters by BOTH user_id (security) and space_id (feature)
    return await linkService.getLinksBySpace(userId, spaceId);
  }

  /// refresh - Manually refresh the links for this space
  ///
  /// Call this when:
  /// - User pulls to refresh on Space Detail Screen
  /// - User adds a new link to this space
  /// - User deletes a link from this space
  /// - User moves a link into/out of this space
  ///
  /// Usage:
  /// ```dart
  /// ref.read(linksBySpaceProvider(spaceId).notifier).refresh();
  /// ```
  Future<void> refresh() async {
    // Invalidate the current state and rebuild
    // This fetches fresh data from the database
    ref.invalidateSelf();

    // Wait for the new data to load
    await future;
  }
}

/// 🎓 Learning Summary: Family Providers
///
/// **What is a Family Provider?**
/// A provider that takes parameters and creates separate instances for each parameter value.
///
/// **Regular Provider vs Family Provider:**
///
/// ```dart
/// // Regular Provider - One instance for the whole app
/// final linksProvider = AsyncNotifierProvider<LinksNotifier, List<Link>>(
///   LinksNotifier.new,
/// );
/// // Usage: ref.watch(linksProvider)
///
/// // Family Provider - One instance per parameter
/// final linksBySpaceProvider = AsyncNotifierProvider.family<
///   LinksBySpaceNotifier,
///   List<Link>,
///   String  // Parameter type (spaceId)
/// >(LinksBySpaceNotifier.new);
/// // Usage: ref.watch(linksBySpaceProvider('space-1'))
/// //        ref.watch(linksBySpaceProvider('space-2'))
/// ```
///
/// **When to Use Family Providers:**
/// - Fetching data by ID (user by userId, links by spaceId)
/// - Parameterized state (search results by query, filtered lists by category)
/// - Any time you need "one provider instance per X"
///
/// **Benefits:**
/// 1. **Separate Caching**: Each parameter gets its own cache
///    - Opening space-1 doesn't refetch data for space-2
/// 2. **Automatic Disposal**: When no widget watches a specific parameter, that instance is disposed
/// 3. **Type Safety**: Dart enforces parameter types at compile time
/// 4. **Performance**: Only fetch data for the specific parameter you need
///
/// **Example Use Case:**
/// Space Detail Screen shows links for a specific space:
/// - User opens "Design Resources" space → fetches links for space-123
/// - Navigates back, then opens "Work" space → fetches links for space-456
/// - Navigates back to "Design Resources" → uses cached data from space-123 (no refetch!)
///
/// **How Caching Works:**
/// ```
/// Time 0: User opens Space A
/// → linksBySpaceProvider('space-a').build() called
/// → Fetches from database
/// → Caches result
///
/// Time 1: User navigates away from Space A
/// → Cache remains in memory (by default)
///
/// Time 2: User opens Space B
/// → linksBySpaceProvider('space-b').build() called
/// → Fetches from database (different parameter!)
/// → Caches result separately
///
/// Time 3: User returns to Space A
/// → Uses cached data from Time 0 (no database call!)
/// ```
///
/// **Next:**
/// Use this provider in the Space Detail Screen to display links for a specific space.
