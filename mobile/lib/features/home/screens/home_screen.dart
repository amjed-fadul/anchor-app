import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Skeleton loading screens
import '../../../design_system/design_system.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../links/providers/link_provider.dart';
import '../../links/providers/search_provider.dart'; // NEW: Search functionality
import '../../links/widgets/link_card.dart';
import '../../links/screens/add_link_flow_screen.dart';
import '../../links/models/link_model.dart'; // For skeleton data
import '../../links/services/link_service.dart'; // For LinkWithTags
import '../../../core/services/deep_link_service.dart';
import '../../../core/services/deep_link_state.dart';

/// Home Screen
///
/// Main screen after login where users see their saved links with search.
///
/// Features:
/// - Real-time search with 300ms debouncing
/// - 2-column grid of LinkCard widgets
/// - Pull-to-refresh
/// - States: Loading, Error, Empty, No Results
///
/// Search Architecture:
/// - User types → debounced (300ms) → searchQueryProvider updates
/// - filteredLinksProvider automatically filters links
/// - UI rebuilds with filtered results
///
/// Real-World Analogy:
/// Like a Pinterest board with a search bar - type to filter your saved content.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Debounce timer for search input
  ///
  /// Why debouncing?
  /// - Prevents filtering on every keystroke (performance)
  /// - Waits 300ms after user stops typing before searching
  /// - Better UX (less flickering, more responsive feel)
  ///
  /// Example:
  /// User types "design":
  /// - d → timer starts (300ms)
  /// - de → timer resets (300ms)
  /// - des → timer resets (300ms)
  /// - desi → timer resets (300ms)
  /// - desig → timer resets (300ms)
  /// - design → timer resets (300ms)
  /// - [user stops typing]
  /// - After 300ms → search executes with "design"
  Timer? _debounceTimer;

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    // If we don't do this, timer might fire after widget is disposed
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handle search input with debouncing
  ///
  /// This method is called every time user types in SearchBarWidget.
  /// We don't search immediately - we wait 300ms after user stops typing.
  ///
  /// Why 300ms?
  /// - Industry standard for search debouncing
  /// - Fast enough to feel instant
  /// - Slow enough to avoid excessive updates
  void _onSearchChanged(String value) {
    // Cancel previous timer if it's still waiting
    // This "resets" the countdown each time user types
    _debounceTimer?.cancel();

    // Start new timer (300ms countdown)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // After 300ms of no typing, update search query
      // This triggers filteredLinksProvider to recompute
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  /// Show the Add Link Flow sheet for a shared URL
  ///
  /// Extracted to a helper method so it can be called from:
  /// 1. ref.listen() callback (warm start - app already running)
  /// 2. After checking current state (cold start - state changed before listener set up)
  void _showSharedLinkSheet(BuildContext context, String url) {
    debugPrint('🟢 [HomeScreen] _showSharedLinkSheet called');
    debugPrint('  - Shared URL: $url');
    debugPrint('  - Context mounted: ${context.mounted}');

    // Only show if context is still mounted
    if (!context.mounted) {
      debugPrint('🔴 [HomeScreen] Context not mounted, cannot show sheet');
      return;
    }

    // Show AddLinkFlowScreen with the shared URL
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      isDismissible: false, // Don't dismiss on tap outside for shared links
      builder: (context) => SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: AddLinkFlowScreen(sharedUrl: url),
      ),
    );

    // Reset state to prevent showing again
    ref.read(deepLinkServiceProvider.notifier).resetState();
    debugPrint('🟢 [HomeScreen] Sheet shown, state reset');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 [HomeScreen] build() START');

    final user = ref.watch(currentUserProvider);

    // Watch linksWithTagsProvider for loading/error states
    // We need this for showing loading spinner while fetching from database
    final linksAsync = ref.watch(linksWithTagsProvider);

    // Watch filteredLinksProvider for actual display
    // This automatically filters based on searchQueryProvider
    final filteredLinks = ref.watch(filteredLinksProvider);

    // Watch search query to check if user is searching
    // Used to differentiate "No links" from "No results"
    final searchQuery = ref.watch(searchQueryProvider);

    // Listen for incoming shared URLs from DeepLinkService
    // This listener catches FUTURE state changes (warm start scenario)
    debugPrint('🔵 [HomeScreen] Setting up ref.listen() for future state changes');
    ref.listen<DeepLinkState>(
      deepLinkServiceProvider,
      (previous, next) {
        debugPrint('🔵 [HomeScreen] ref.listen() triggered!');
        debugPrint('  - Previous state: ${previous?.runtimeType}');
        debugPrint('  - Next state: ${next.runtimeType}');

        // When a URL is pending, show AddLinkFlowScreen
        if (next is DeepLinkUrlPending) {
          _showSharedLinkSheet(context, next.url);
        }
      },
    );

    // Check current deep link state (for cold start scenario)
    // This handles the case where state changed BEFORE listener was set up
    final currentDeepLinkState = ref.read(deepLinkServiceProvider);
    debugPrint('🔵 [HomeScreen] Current deep link state: ${currentDeepLinkState.runtimeType}');

    // If there's already a pending URL (cold start), show it after build completes
    if (currentDeepLinkState is DeepLinkUrlPending) {
      debugPrint('🟡 [HomeScreen] Found existing DeepLinkUrlPending state (cold start!)');
      debugPrint('  - This means share was received before HomeScreen built');
      debugPrint('  - Scheduling sheet to show after frame renders');

      // We can't call showModalBottomSheet directly in build()
      // We need to wait until after the first frame is rendered
      // Use addPostFrameCallback to defer until widget tree is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🟡 [HomeScreen] Post-frame callback executing');
        _showSharedLinkSheet(context, currentDeepLinkState.url);
      });
    }

    return Scaffold(
      // No AppBar - we'll build custom header
      body: SafeArea(
        child: Column(
          children: [
            // Header: Avatar + Greeting + SearchBar (with search callback)
            _buildHeader(context, user?.email),

            // Main content: Links grid or states
            Expanded(
              child: linksAsync.when(
                // Loading state: Show skeleton/loading
                loading: () => _buildLoadingState(),

                // Error state: Show error message
                error: (error, stack) => _buildErrorState(error.toString()),

                // Data state: Show links, empty state, or no results
                data: (allLinks) {
                  // Check if we're searching
                  final isSearching = searchQuery.isNotEmpty;

                  // If no filtered results
                  if (filteredLinks.isEmpty) {
                    // Differentiate between "No links saved" and "No results"
                    return isSearching
                        ? _buildNoResultsState(searchQuery)
                        : _buildEmptyState();
                  }

                  // Show filtered links
                  return _buildLinksGrid(filteredLinks, ref);
                },
              ),
            ),
          ],
        ),
      ),

      // Add Link FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            useSafeArea: true,
            builder: (context) => const AddLinkFlowScreen(),
          );
        },
        backgroundColor: AnchorColors.anchorTeal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  /// Build header section with avatar, greeting, and search
  ///
  /// Layout:
  /// ┌─────────────────────────────────────┐
  /// │ [A] Hello Amjed                     │ ← Avatar + Greeting
  /// │                                     │
  /// │ [🔍 Search bookmarks, links...]     │ ← SearchBar (functional!)
  /// └─────────────────────────────────────┘
  Widget _buildHeader(BuildContext context, String? email) {
    // Extract first name from email (before @)
    final firstName = email?.split('@').first ?? 'User';
    // Capitalize first letter
    final displayName = firstName[0].toUpperCase() + firstName.substring(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Greeting row
          Row(
            children: [
              // Avatar circle with initial (tappable to open settings)
              GestureDetector(
                onTap: () {
                  // Navigate to settings screen
                  context.go('/settings');
                },
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AnchorColors.anchorTeal,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting text
              Text(
                'Hello $displayName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar with functional search callback
          SearchBarWidget(
            onChanged: _onSearchChanged, // Debounced search
          ),
        ],
      ),
    );
  }

  /// Build links grid (2-column layout) with pull-to-refresh
  ///
  /// RefreshIndicator:
  /// - Enables pull-down gesture to refresh
  /// - Shows loading indicator during refresh
  /// - Calls provider's refresh() method
  ///
  /// GridView.builder:
  /// - crossAxisCount: 2 = 2 columns
  /// - childAspectRatio: width/height ratio of each card
  /// - spacing: gaps between cards
  Widget _buildLinksGrid(links, WidgetRef ref) {
    return RefreshIndicator(
      // Color of the refresh indicator
      color: AnchorColors.anchorTeal,

      // Called when user pulls down to refresh
      onRefresh: () async {
        // Call the provider's refresh method
        await ref.read(linksWithTagsProvider.notifier).refresh();
      },

      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          childAspectRatio: 0.75, // Width/height ratio (card height > width)
          crossAxisSpacing: 8, // Horizontal gap between cards
          mainAxisSpacing: 8, // Vertical gap between cards
        ),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final linkWithTags = links[index];
          return LinkCard(linkWithTags: linkWithTags);
        },
      ),
    );
  }

  /// Build loading state with skeleton cards
  ///
  /// Shows modern shimmer skeleton cards while fetching links from database.
  /// This creates a better UX than a simple spinner - users see the layout
  /// they're about to get, which makes the app feel faster.
  ///
  /// Uses Skeletonizer package which automatically turns real widgets into
  /// shimmering skeletons - no need to duplicate the LinkCard layout!
  Widget _buildLoadingState() {
    // Create fake link data for skeleton cards
    final skeletonLinks = List.generate(
      6, // Show 6 skeleton cards
      (index) => LinkWithTags(
        link: Link(
          id: 'skeleton-$index',
          url: 'https://example.com',
          normalizedUrl: 'https://example.com',
          title: 'Loading Link Title Placeholder...',
          description: 'Loading description text here that shows while data is being fetched from the database...',
          thumbnailUrl: null, // No thumbnail for skeleton
          domain: 'example.com',
          note: 'Loading note text here...',
          userId: 'skeleton-user',
          spaceId: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          openedAt: null,
        ),
        tags: [], // No tags for skeleton
      ),
    );

    return Skeletonizer(
      enabled: true, // Enable skeleton effect
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Match real grid layout
          childAspectRatio: 0.75, // Match real card ratio
          crossAxisSpacing: 8, // Match real spacing
          mainAxisSpacing: 8, // Match real spacing
        ),
        itemCount: skeletonLinks.length,
        itemBuilder: (context, index) {
          // Skeletonizer automatically turns LinkCard into a skeleton!
          return LinkCard(linkWithTags: skeletonLinks[index]);
        },
      ),
    );
  }

  /// Build error state
  ///
  /// Shows error message when links fail to load.
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load links',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  ///
  /// Shows friendly message when user has no saved links yet.
  /// This is different from "No results" - this is for brand new users.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No links saved yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start saving links to see them here',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build no results state
  ///
  /// Shows when user searches but no links match the query.
  /// Different from empty state - user HAS links, just none matching search.
  ///
  /// Provides clear feedback and way to reset search.
  Widget _buildNoResultsState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No links match "$query"',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Clear search button
            TextButton.icon(
              onPressed: () {
                // Clear search query
                ref.read(searchQueryProvider.notifier).state = '';
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear search'),
              style: TextButton.styleFrom(
                foregroundColor: AnchorColors.anchorTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎓 Learning Summary: Search Integration with Debouncing
///
/// **Debouncing Pattern:**
///
/// Problem: User types "design" → triggers 6 searches (d, de, des, desi, desig, design)
/// Solution: Wait 300ms after user stops typing, then search once
///
/// ```dart
/// Timer? _debounceTimer;
///
/// void _onSearchChanged(String value) {
///   _debounceTimer?.cancel();  // Cancel previous timer
///   _debounceTimer = Timer(Duration(milliseconds: 300), () {
///     // Execute search after 300ms of no typing
///     ref.read(searchQueryProvider.notifier).state = value;
///   });
/// }
/// ```
///
/// **Real-World Analogy:**
/// Think of debouncing like an elevator that waits:
/// - Person enters → door waits 5 seconds
/// - Another person enters → door resets, waits 5 seconds
/// - Another person enters → door resets, waits 5 seconds
/// - [No one enters for 5 seconds]
/// - Door closes and elevator moves
///
/// Same with search:
/// - User types "d" → timer starts (300ms)
/// - User types "e" → timer resets (300ms)
/// - User types "s" → timer resets (300ms)
/// - [User stops typing]
/// - After 300ms → search executes
///
/// **Why StatefulWidget?**
/// - Need to manage Timer instance
/// - Need dispose() to clean up timer
/// - ConsumerStatefulWidget = StatefulWidget + Riverpod
///
/// **Data Flow:**
///
/// ```
/// User types "design"
///     ↓
/// SearchBarWidget.onChanged("design")
///     ↓
/// _onSearchChanged("design")
///     ↓
/// Timer starts (300ms)
///     ↓
/// [300ms passes, user stopped typing]
///     ↓
/// searchQueryProvider.state = "design"
///     ↓
/// filteredLinksProvider recomputes (filters links)
///     ↓
/// HomeScreen rebuilds with filtered results
///     ↓
/// UI shows only links matching "design"
/// ```
///
/// **State Differentiation:**
///
/// We have 4 distinct states:
/// 1. **Loading**: Fetching from database (loading indicator)
/// 2. **Error**: Database error (error message)
/// 3. **Empty**: No links saved (empty state with "Start saving")
/// 4. **No Results**: Search found nothing (no results with "Clear search")
///
/// **Why This Matters:**
/// - Loading: User knows we're fetching data
/// - Error: User knows something went wrong
/// - Empty: User is new, needs guidance to add first link
/// - No Results: User has links but search didn't match, can clear search
///
/// **Performance:**
/// - Debouncing reduces filtering operations by ~80%
/// - Client-side filtering is instant for < 1000 links
/// - No unnecessary database queries
///
/// **UX Benefits:**
/// - Feels instant (300ms is below perception threshold)
/// - No flickering (fewer updates)
/// - Clear feedback (distinct empty vs no results states)
/// - Easy recovery (clear search button)
///
/// **Memory Management:**
/// - Timer is cancelled in dispose()
/// - Prevents memory leaks
/// - Prevents crashes from timer firing after dispose
///
/// **Next:**
/// Test the search functionality on a device!
/// - Type in search bar
/// - Results should filter in real-time
/// - Clear button should reset search
/// - Empty states should be distinct
