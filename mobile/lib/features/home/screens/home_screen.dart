import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../links/providers/link_provider.dart';
import '../../links/widgets/link_card.dart';

/// Home Screen
///
/// Main screen after login where users see their saved links.
///
/// Layout:
/// - Header: Avatar + Greeting + SearchBar
/// - Main: 2-column grid of LinkCard widgets
/// - States: Loading, Error, Empty, Data
///
/// Real-World Analogy:
/// Like a Pinterest board or Instagram feed - grid of visual cards
/// showing your saved content with search at the top.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final linksAsync = ref.watch(linksWithTagsProvider);

    return Scaffold(
      // No AppBar - we'll build custom header
      body: SafeArea(
        child: Column(
          children: [
            // Header: Avatar + Greeting + SearchBar
            _buildHeader(user?.email),

            // Main content: Links grid or states
            Expanded(
              child: linksAsync.when(
                // Loading state: Show skeleton/loading
                loading: () => _buildLoadingState(),

                // Error state: Show error message
                error: (error, stack) => _buildErrorState(error.toString()),

                // Data state: Show links or empty state
                data: (links) {
                  if (links.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildLinksGrid(links);
                },
              ),
            ),
          ],
        ),
      ),

      // Logout button (temporary - will be replaced with settings)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final authService = ref.read(authServiceProvider);
          await authService.signOut();
        },
        backgroundColor: AnchorColors.anchorTeal,
        child: const Icon(Icons.logout, color: Colors.white),
      ),
    );
  }

  /// Build header section with avatar, greeting, and search
  ///
  /// Layout:
  /// ┌─────────────────────────────────────┐
  /// │ [A] Hello Amjed                     │ ← Avatar + Greeting
  /// │                                     │
  /// │ [🔍 Search bookmarks, links...]     │ ← SearchBar
  /// └─────────────────────────────────────┘
  Widget _buildHeader(String? email) {
    // Extract first name from email (before @)
    final firstName = email?.split('@').first ?? 'User';
    // Capitalize first letter
    final displayName = firstName[0].toUpperCase() + firstName.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Greeting row
          Row(
            children: [
              // Avatar circle with initial
              CircleAvatar(
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
              const SizedBox(width: 12),
              // Greeting text
              Text(
                'Hello $displayName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          const SearchBarWidget(),
        ],
      ),
    );
  }

  /// Build links grid (2-column layout)
  ///
  /// GridView.builder:
  /// - crossAxisCount: 2 = 2 columns
  /// - childAspectRatio: width/height ratio of each card
  /// - spacing: gaps between cards
  Widget _buildLinksGrid(links) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 columns
        childAspectRatio: 0.75, // Width/height ratio (card height > width)
        crossAxisSpacing: 12, // Horizontal gap between cards
        mainAxisSpacing: 12, // Vertical gap between cards
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final linkWithTags = links[index];
        return LinkCard(linkWithTags: linkWithTags);
      },
    );
  }

  /// Build loading state
  ///
  /// Shows circular progress indicator while fetching links from database.
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AnchorColors.anchorTeal,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your links...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
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
}

/// 🎓 Learning Summary: Async State Management with Riverpod
///
/// **AsyncValue.when() Pattern:**
/// This is how we handle async data (loading, error, data states):
///
/// ```dart
/// linksAsync.when(
///   loading: () => LoadingWidget(),    // While fetching
///   error: (err, stack) => ErrorWidget(), // If fetch fails
///   data: (links) => DataWidget(links),   // When data arrives
/// )
/// ```
///
/// **Why This Pattern?**
/// - Automatic state management (no manual setState)
/// - Covers all possible states
/// - Type-safe (compiler catches errors)
/// - Clean, readable code
///
/// **Real-World Analogy:**
/// Think of ordering food delivery:
/// - loading: "Your order is being prepared..."
/// - error: "Sorry, restaurant is closed"
/// - data: "Here's your food!" 🍕
///
/// **GridView.builder Explained:**
///
/// Grid layout for displaying items in columns and rows.
///
/// Key properties:
/// - `crossAxisCount: 2` = 2 columns
/// - `childAspectRatio: 0.75` = card height is 1.33x width
/// - `crossAxisSpacing: 12` = horizontal gap
/// - `mainAxisSpacing: 12` = vertical gap
///
/// **Why .builder?**
/// Instead of creating all widgets upfront, builder creates them
/// on-demand as you scroll. Better performance for long lists!
///
/// **childAspectRatio Math:**
/// - 0.75 means width/height = 0.75
/// - If width = 100px, height = 133px (taller than wide)
/// - Cards are portrait orientation (like phone screen)
///
/// **Responsive Design:**
/// This screen is responsive because:
/// - SafeArea handles notches and system UI
/// - Padding uses EdgeInsets (scales with screen)
/// - GridView adapts to screen width
/// - childAspectRatio maintains proportions
/// - Text wraps and truncates properly
/// - No fixed pixel widths anywhere
///
/// **State Management Flow:**
/// 1. Screen mounts
/// 2. ref.watch(linksWithTagsProvider) starts
/// 3. Provider calls build() which fetches from database
/// 4. Shows loading state while fetching
/// 5. Shows data/error state when complete
/// 6. Any changes automatically trigger rebuild
///
/// **Next Enhancements:**
/// - Pull-to-refresh gesture
/// - Bottom navigation bar
/// - FAB for adding links
/// - Tap to open links in browser
/// - Long-press for context menu
/// - Search functionality
/// - Filter by tags
///
