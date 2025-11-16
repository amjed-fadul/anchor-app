library;

/// Space Detail Screen
///
/// Displays all links in a specific space with empty state support.
///
/// Features:
/// - Header with back button and space name
/// - Search bar (disabled placeholder for now)
/// - Grid of link cards (2 columns, responsive)
/// - Empty state when space has no links
/// - Add link button (reuses existing Add Link flow)
///
/// Design from Figma (node-id=1-1229):
/// - Light gray background (#f5f5f0)
/// - Full screen (no bottom nav)
/// - GridView with 2 columns, 16px spacing
/// - Empty state: centered text "This space is empty"
///
/// Real-World Analogy:
/// Think of this like opening a folder on your computer:
/// - Folder name at the top (space name)
/// - Files inside displayed in a grid (links)
/// - Empty folder shows "This folder is empty"
/// - Button to add new files (add link)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../widgets/space_menu_bottom_sheet.dart';
import '../../links/providers/links_by_space_provider.dart';
import '../../links/widgets/link_card.dart';
import '../../links/screens/add_link_flow_screen.dart';

class SpaceDetailScreen extends ConsumerWidget {
  final Space space;

  const SpaceDetailScreen({
    super.key,
    required this.space,
  });

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
        initialSpaceId: space.id, // Pre-select this space
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch links for this space
    final linksAsync = ref.watch(linksBySpaceProvider(space.id));

    // Watch spaces to get updated space data (for name changes)
    final spacesAsync = ref.watch(spacesProvider);

    // Get the current space data (updated name, color, etc.)
    final currentSpace = spacesAsync.whenData((spaces) {
      try {
        return spaces.firstWhere((s) => s.id == space.id);
      } catch (e) {
        return space; // Fallback to original if not found
      }
    }).value ?? space;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f0), // Light gray from Figma

      // Header with back button and space name
      appBar: AppBar(
        backgroundColor: const Color(0xfff5f5f0),
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
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xff075a52)),
            iconSize: 28,
            onPressed: () => _showAddLinkFlow(context),
            tooltip: 'Add link to ${currentSpace.name}',
          ),

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
            // Search bar (disabled placeholder)
            _buildSearchBar(),

            const SizedBox(height: 16),

            // Links grid (with loading/error/empty states)
            // Wrapped with RefreshIndicator for pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xff075a52), // Anchor teal
                onRefresh: () async {
                  // Refresh links for this space
                  ref.invalidate(linksBySpaceProvider(space.id));
                  // Wait for new data to load
                  await ref.read(linksBySpaceProvider(space.id).future);
                },
                child: linksAsync.when(
                  // Loading state
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff075a52),
                    ),
                  ),

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
                  // Empty state (wrapped in ListView for pull-to-refresh to work)
                  if (links.isEmpty) {
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

                  // Grid of links
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 16, // Horizontal spacing
                      mainAxisSpacing: 16, // Vertical spacing
                      childAspectRatio: 0.75, // Card aspect ratio
                    ),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final linkWithTags = links[index];
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

  /// Build search bar (disabled placeholder)
  ///
  /// Shows a search bar UI but doesn't actually work yet.
  /// This matches the Figma design and sets up for future search feature.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xffe0e0e0),
            width: 1,
          ),
        ),
        child: const Row(
          children: [
            SizedBox(width: 12),
            Icon(
              Icons.search,
              color: Color(0xff6a6770),
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search links...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff6a6770),
                ),
              ),
            ),
          ],
        ),
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
