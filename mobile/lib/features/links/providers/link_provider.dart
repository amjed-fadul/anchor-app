library;

/// Link Providers
///
/// State management for links using Riverpod.
///
/// What is State Management?
/// It's how we share data between different parts of the app.
/// Think of it like a shared clipboard that any screen can read from or write to.
///
/// Why Riverpod?
/// - Reactive: UI automatically updates when data changes
/// - Cached: Fetches data once, reuses it across screens
/// - Type-safe: Compiler catches errors at build time
/// - Testable: Easy to test with mocked providers
///
/// Real-World Analogy:
/// Think of providers like a bulletin board in an office:
/// - Anyone can read what's posted (UI reads data)
/// - When someone updates it, everyone sees the change (reactivity)
/// - You don't need to ask the same question twice (caching)

import 'package:flutter/material.dart'; // For debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/link_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for LinkService instance
///
/// This is a "singleton" - only one LinkService exists for the whole app.
/// Every screen that needs to fetch links uses this same service.
///
/// Why?
/// - Efficiency: Don't create multiple service instances
/// - Consistency: All screens use the same data source
/// - Easy to mock for testing
final linkServiceProvider = Provider<LinkService>((ref) {
  // Get the Supabase client
  final supabase = Supabase.instance.client;

  // Create and return the service
  return LinkService(supabase);
});

/// Provider for fetching links with tags
///
/// This is an AsyncNotifier - it handles async data fetching automatically.
/// It manages three states: loading, data, error.
///
/// How to use in UI:
/// ```dart
/// final linksAsync = ref.watch(linksWithTagsProvider);
///
/// linksAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
///   data: (links) => ListView.builder(...),
/// );
/// ```
final linksWithTagsProvider = AsyncNotifierProvider<LinksNotifier, List<LinkWithTags>>(
  LinksNotifier.new,
);

/// LinksNotifier - Manages the state of links
///
/// This class:
/// 1. Fetches links when first accessed
/// 2. Caches the result
/// 3. Provides a method to refresh
/// 4. Handles errors automatically
class LinksNotifier extends AsyncNotifier<List<LinkWithTags>> {
  /// build - Called when the notifier is first accessed
  ///
  /// This is where we fetch the initial data.
  /// Riverpod automatically handles loading/error states.
  ///
  /// IMPORTANT: We use ref.watch() for currentUserProvider so that
  /// this provider automatically rebuilds when the user logs in/out.
  @override
  Future<List<LinkWithTags>> build() async {
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

    // Fetch links with tags
    // This is async, so Riverpod shows loading state automatically
    return await linkService.getLinksWithTags(userId);
  }

  /// refresh - Manually refresh the links
  ///
  /// Call this when:
  /// - User pulls to refresh
  /// - User adds a new link
  /// - User deletes a link
  ///
  /// Usage:
  /// ```dart
  /// ref.read(linksWithTagsProvider.notifier).refresh();
  /// ```
  Future<void> refresh() async {
    // Invalidate the current state and rebuild
    // This fetches fresh data from the database
    ref.invalidateSelf();

    // Wait for the new data to load
    await future;
  }
}

/// Provider for paginated links (for home screen)
///
/// This is an optimized version that loads links in pages of 30 at a time.
/// Much faster initial load for users with many links!
///
/// Features:
/// - Initial load: 30 links (~300ms instead of ~900ms for 100 links)
/// - Infinite scroll: Automatically loads more as user scrolls
/// - Smooth UX: No lag from loading all data upfront
///
/// How to use:
/// ```dart
/// final linksAsync = ref.watch(paginatedLinksProvider);
/// // Then call ref.read(paginatedLinksProvider.notifier).loadNextPage() when scrolling
/// ```
final paginatedLinksProvider = AsyncNotifierProvider<PaginatedLinksNotifier, List<LinkWithTags>>(
  PaginatedLinksNotifier.new,
);

/// PaginatedLinksNotifier - Manages paginated link loading
///
/// This handles loading links in batches of 30 for better performance.
/// Essential for users with 100+ links.
class PaginatedLinksNotifier extends AsyncNotifier<List<LinkWithTags>> {
  static const int _pageSize = 30; // Links per page
  int _currentPage = 0; // Current page number
  bool _hasMoreData = true; // Whether there are more pages to load
  bool _isLoadingMore = false; // Prevent duplicate loads

  @override
  Future<List<LinkWithTags>> build() async {
    debugPrint('🔵 [PaginatedLinksNotifier] build() - Initial load');
    _currentPage = 0;
    _hasMoreData = true;
    return _fetchPage(0);
  }

  /// Fetch a specific page of links
  Future<List<LinkWithTags>> _fetchPage(int page) async {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id;

    if (userId == null) {
      debugPrint('🔴 [PaginatedLinksNotifier] No user logged in');
      return [];
    }

    final linkService = ref.read(linkServiceProvider);
    final offset = page * _pageSize;

    debugPrint('🔵 [PaginatedLinksNotifier] Fetching page $page (offset: $offset, limit: $_pageSize)');

    // Fetch page from database
    final links = await linkService.getLinksWithTagsPaginated(
      userId,
      offset: offset,
      limit: _pageSize,
    );

    debugPrint('🟢 [PaginatedLinksNotifier] Page $page loaded: ${links.length} links');

    // If we got fewer links than page size, we've reached the end
    if (links.length < _pageSize) {
      _hasMoreData = false;
      debugPrint('🟡 [PaginatedLinksNotifier] No more pages (last page had ${links.length} links)');
    }

    return links;
  }

  /// Load the next page of links
  ///
  /// Call this when user scrolls near the bottom of the list.
  /// Appends new links to existing state.
  ///
  /// Usage:
  /// ```dart
  /// if (scrolledNearBottom) {
  ///   ref.read(paginatedLinksProvider.notifier).loadNextPage();
  /// }
  /// ```
  Future<void> loadNextPage() async {
    // Prevent loading if already loading or no more data
    if (_isLoadingMore || !_hasMoreData) {
      debugPrint('🟡 [PaginatedLinksNotifier] Skipping loadNextPage (isLoading: $_isLoadingMore, hasMore: $_hasMoreData)');
      return;
    }

    _isLoadingMore = true;
    _currentPage++;

    debugPrint('🔵 [PaginatedLinksNotifier] loadNextPage() - Loading page $_currentPage');

    try {
      final newLinks = await _fetchPage(_currentPage);

      // Append new links to existing state
      final currentLinks = state.value ?? [];
      state = AsyncValue.data([...currentLinks, ...newLinks]);

      debugPrint('🟢 [PaginatedLinksNotifier] Total links now: ${currentLinks.length + newLinks.length}');
    } catch (e, stack) {
      debugPrint('🔴 [PaginatedLinksNotifier] Error loading next page: $e');
      state = AsyncValue.error(e, stack);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh links (pull-to-refresh)
  ///
  /// Resets pagination and fetches first page again.
  Future<void> refresh() async {
    debugPrint('🔵 [PaginatedLinksNotifier] refresh() - Resetting pagination');
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;

    // Invalidate and rebuild
    ref.invalidateSelf();
    await future;
  }

  /// Check if there's more data to load
  bool get hasMoreData => _hasMoreData;

  /// Check if currently loading more data
  bool get isLoadingMore => _isLoadingMore;
}

/// 🎓 Learning Summary: Riverpod Providers
///
/// **Types of Providers:**
///
/// 1. **Provider**: For simple, synchronous values
///    - Example: Configuration, services, constants
///    - Usage: `final config = ref.watch(configProvider);`
///
/// 2. **AsyncNotifier**: For async data that can change
///    - Example: Fetching from API, database queries
///    - Handles loading/error/data states automatically
///    - Usage: `final data = ref.watch(dataProvider);`
///
/// 3. **StateNotifier**: For complex state with multiple fields
///    - Example: Form state, multi-step wizards
///    - Can update individual fields without rebuilding everything
///
/// **How This Works:**
///
/// 1. **First Access**: When a screen uses `ref.watch(linksWithTagsProvider)`:
///    - Riverpod calls `build()`
///    - Shows loading state while fetching
///    - Shows data when complete
///    - Shows error if fetch fails
///
/// 2. **Subsequent Access**: Other screens get the cached data
///    - No additional database queries
///    - Instant display
///
/// 3. **Refresh**: When user pulls to refresh:
///    - Call `ref.read(linksWithTagsProvider.notifier).refresh()`
///    - Fetches new data from database
///    - Updates all listening screens automatically
///
/// **UI Integration Example:**
///
/// ```dart
/// class HomeScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Watch the provider - rebuilds when data changes
///     final linksAsync = ref.watch(linksWithTagsProvider);
///
///     return linksAsync.when(
///       // While fetching data
///       loading: () => Center(child: CircularProgressIndicator()),
///
///       // If fetch failed
///       error: (error, stack) => Center(
///         child: Text('Error: $error'),
///       ),
///
///       // When data is available
///       data: (links) {
///         if (links.isEmpty) {
///           return EmptyState();
///         }
///         return GridView.builder(
///           itemCount: links.length,
///           itemBuilder: (context, index) {
///             final linkWithTags = links[index];
///             return LinkCard(
///               link: linkWithTags.link,
///               tags: linkWithTags.tags,
///             );
///           },
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// **Next:**
/// Now we can start building the UI components:
/// 1. TagBadge widget (colored tags)
/// 2. LinkCard widget (display link with image, title, note, tags)
/// 3. HomeScreen (put it all together)
