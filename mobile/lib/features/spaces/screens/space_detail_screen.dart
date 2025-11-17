library;

/// Space Detail Screen
///
/// Displays all links in a specific space with working search functionality.
///
/// Features:
/// - Header with back button and space name
/// - Real-time search with 300ms debouncing
/// - Grid of link cards (2 columns, responsive)
/// - Empty state when space has no links
/// - No results state when search returns nothing
/// - Add link button (reuses existing Add Link flow)
/// - Pull-to-refresh
///
/// Search Architecture:
/// - User types → debounced (300ms) → spaceSearchQueryProvider updates
/// - filteredSpaceLinksProvider automatically filters links in this space
/// - UI rebuilds with filtered results
///
/// Real-World Analogy:
/// Think of this like opening a folder on your computer with search:
/// - Folder name at the top (space name)
/// - Search bar to filter files (search links)
/// - Files inside displayed in a grid (links)
/// - Empty folder shows "This folder is empty"
/// - Search with no results shows "No results found"

import 'dart:async'; // For Timer (debouncing)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../providers/space_search_provider.dart'; // NEW: Space search functionality
import '../widgets/space_menu_bottom_sheet.dart';
import '../../links/providers/links_by_space_provider.dart';
import '../../links/widgets/link_card.dart';
import '../../links/screens/add_link_flow_screen.dart';
import '../../../shared/widgets/styled_add_button.dart';
import '../../../shared/widgets/search_bar_widget.dart'; // NEW: Reusable search widget

class SpaceDetailScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceDetailScreen({
    super.key,
    required this.space,
  });

  @override
  ConsumerState<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends ConsumerState<SpaceDetailScreen> {
  /// Debounce timer for search input
  ///
  /// Why debouncing?
  /// - Prevents filtering on every keystroke (performance)
  /// - Waits 300ms after user stops typing before searching
  /// - Better UX (less flickering, more responsive feel)
  Timer? _debounceTimer;

  @override
  void dispose() {
    // Cancel timer to prevent memory leaks
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handle search input with debouncing
  ///
  /// Called every time user types in SearchBarWidget.
  /// Waits 300ms after user stops typing before updating search query.
  void _onSearchChanged(String value) {
    // Cancel previous timer if still waiting
    _debounceTimer?.cancel();

    // Start new 300ms timer
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // Update search query → triggers filteredSpaceLinksProvider to recompute
      ref.read(spaceSearchQueryProvider.notifier).state = value;
    });
  }

  /// Show Add Link flow with this space pre-selected
  ///
  /// This reuses the existing Add Link flow but passes the space ID
  /// so the link is automatically assigned to this space.
  void _showAddLinkFlow(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLinkFlowScreen(
        initialSpaceId: widget.space.id, // Pre-select this space
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch links for this space (for loading/error states)
    final linksAsync = ref.watch(linksBySpaceProvider(widget.space.id));

    // Watch filtered links (for actual display with search)
    final filteredLinks = ref.watch(filteredSpaceLinksProvider(widget.space.id));

    // Watch search query to check if user is searching
    // Used to differentiate "No links" (empty space) from "No results" (search found nothing)
    final searchQuery = ref.watch(spaceSearchQueryProvider);

    // Watch spaces to get updated space data (for name changes)
    final spacesAsync = ref.watch(spacesProvider);

    // Get the current space data (updated name, color, etc.)
    final currentSpace = spacesAsync.whenData((spaces) {
      try {
        return spaces.firstWhere((s) => s.id == widget.space.id);
      } catch (e) {
        return widget.space; // Fallback to original if not found
      }
    }).value ?? widget.space;

    return Scaffold(
      // Header with back button and space name
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff0a090d)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          currentSpace.name, // Use current space data, not stale space
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xff0a090d),
          ),
        ),
        actions: [
          // Add Link button
          StyledAddButton(
            onPressed: () => _showAddLinkFlow(context),
            tooltip: 'Add link to ${currentSpace.name}',
          ),

          const SizedBox(width: 8), // Spacing between buttons

          // Menu button (Edit / Delete space) - ONLY for custom spaces
          if (!currentSpace.isDefault)
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xff6a6770), // Gray
              ),
              iconSize: 24,
              onPressed: () => showSpaceActionsSheet(context, currentSpace),
              tooltip: 'Space menu',
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Search bar (functional with debouncing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBarWidget(
                placeholder: 'Search links in ${currentSpace.name}...',
                onChanged: _onSearchChanged,
              ),
            ),

            const SizedBox(height: 16),

            // Links grid (with loading/error/empty states)
            // Wrapped with RefreshIndicator for pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xff075a52), // Anchor teal
                onRefresh: () async {
                  // Refresh links for this space
                  ref.invalidate(linksBySpaceProvider(widget.space.id));
                  // Wait for new data to load
                  await ref.read(linksBySpaceProvider(widget.space.id).future);
                },
                child: linksAsync.when(
                  // Loading state - Show skeleton cards
                  loading: () => _buildLoadingState(),

                  // Error state (wrapped in ListView for pull-to-refresh to work)
                  error: (error, stackTrace) => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Error loading links',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff0a090d),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xff6a6770),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                // Data state
                data: (links) {
                  // State differentiation: Empty vs No Results
                  // - Empty: Space has no links at all
                  // - No Results: Space has links but search found nothing
                  if (filteredLinks.isEmpty) {
                    // Check if user is searching
                    if (searchQuery.isNotEmpty) {
                      // No Results state (wrapped in ListView for pull-to-refresh)
                      return _buildNoResultsState();
                    } else {
                      // Empty state (wrapped in ListView for pull-to-refresh)
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.folder_outlined,
                                  size: 64,
                                  color: Color(0xff6a6770),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'This space is empty',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xff0a090d),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add links to ${currentSpace.name}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xff6a6770),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  // Grid of filtered links
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 8, // Horizontal spacing (match Home screen)
                      mainAxisSpacing: 8, // Vertical spacing (match Home screen)
                      childAspectRatio: 0.75, // Card aspect ratio
                    ),
                    itemCount: filteredLinks.length,
                    itemBuilder: (context, index) {
                      final linkWithTags = filteredLinks[index];
                      return LinkCard(
                        linkWithTags: linkWithTags,
                      );
                    },
                  );
                },
              ), // End of linksAsync.when()
            ), // End of RefreshIndicator
          ), // End of Expanded
          ],
        ),
      ),
    );
  }

  /// Build "No Results" state
  ///
  /// Shown when search query returns no matching links.
  /// Wrapped in ListView for pull-to-refresh compatibility.
  Widget _buildNoResultsState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off,
                size: 64,
                color: Color(0xff6a6770),
              ),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0a090d),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try different keywords or clear your search',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff6a6770),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build loading state with custom skeleton cards
  ///
  /// Shows simple gray skeleton cards while fetching links from database.
  /// Matches the grid layout used for real link cards.
  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Match real grid layout
        childAspectRatio: 0.75, // Match real card ratio
        crossAxisSpacing: 8, // Match Home screen spacing
        mainAxisSpacing: 8, // Match Home screen spacing
      ),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  /// Build a single skeleton card
  ///
  /// Clean gray placeholder that matches LinkCard layout:
  /// - Rounded corners (12px)
  /// - White background with border
  /// - Gray rectangles for image, title, note
  /// - No shimmer animation (simple and clean)
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder (gray rectangle at top)
          Container(
            height: 118, // Reduced from 120 to prevent overflow
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), // Very light gray
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          // Content area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder (2 lines)
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0), // Light gray
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 12),

                // Note placeholder (1 line)
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE), // Lighter gray
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎓 Learning Summary: Grid Layouts in Flutter
///
/// **GridView.builder vs ListView.builder:**
///
/// ```dart
/// // ListView - Single column
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) => ItemWidget(items[index]),
/// )
///
/// // GridView - Multiple columns
/// GridView.builder(
///   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2, // Number of columns
///     crossAxisSpacing: 16, // Horizontal gap
///     mainAxisSpacing: 16, // Vertical gap
///     childAspectRatio: 0.75, // Width/Height ratio
///   ),
///   itemCount: items.length,
///   itemBuilder: (context, index) => ItemWidget(items[index]),
/// )
/// ```
///
/// **SliverGridDelegateWithFixedCrossAxisCount:**
/// - `crossAxisCount`: Number of columns (2 = 2-column grid)
/// - `crossAxisSpacing`: Horizontal gap between items
/// - `mainAxisSpacing`: Vertical gap between rows
/// - `childAspectRatio`: Width/Height ratio for each cell
///
/// **Why GridView for Links?**
/// - Maximizes screen space (2 links side-by-side)
/// - Easier to scan visually (grid vs long list)
/// - Matches common UI patterns (Pinterest, Instagram, etc.)
/// - Responsive (adjusts to different screen sizes)
///
/// **Responsive Grid Tips:**
/// ```dart
/// // For tablets/large screens, use more columns:
/// crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2
///
/// // For very small screens, use single column:
/// crossAxisCount: MediaQuery.of(context).size.width < 360 ? 1 : 2
/// ```
///
/// **Consumer Widget Pattern:**
/// We use `ConsumerWidget` instead of `StatelessWidget` because:
/// - Need access to `WidgetRef ref` for Riverpod providers
/// - Want widget to rebuild when provider data changes
/// - Cleaner than wrapping in Consumer()
///
/// **Next:**
/// 1. Integrate with router (add route for /spaces/:spaceId)
/// 2. Make SpaceCard tappable to navigate here
/// 3. Test on device with real data
