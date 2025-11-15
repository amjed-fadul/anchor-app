library;

/// SpacesScreen - Main Screen for Spaces Tab
///
/// Displays a list of user's spaces with header and actions.
/// Auto-creates two default spaces on first launch:
/// - "Unread" (purple #7c3aed)
/// - "Reference" (red #ef4444)
///
/// Real-World Analogy:
/// Think of this like a folder view in a file manager - you see all your
/// folders (spaces) listed, and can tap to open them or create new ones.
///
/// Design from Figma (node-id=1-1288):
/// - Light gray background (#f5f5f0)
/// - Header with title, plus button, and menu button
/// - List of space cards with 16px horizontal padding
/// - Auto-creates default spaces if user has none

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';
import '../widgets/space_card.dart';
import '../../auth/providers/auth_provider.dart';

class SpacesScreen extends ConsumerStatefulWidget {
  const SpacesScreen({super.key});

  @override
  ConsumerState<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends ConsumerState<SpacesScreen> {
  /// Auto-create default spaces on first launch
  ///
  /// Checks if user has any spaces. If not, creates two defaults:
  /// - "Unread" (purple #7c3aed) - for saving links to read later
  /// - "Reference" (red #ef4444) - for important reference materials
  Future<void> _ensureDefaultSpaces(List<Space> spaces) async {
    // If user already has spaces, do nothing
    if (spaces.isNotEmpty) {
      debugPrint('✅ [SpacesScreen] User has ${spaces.length} spaces, skipping auto-creation');
      return;
    }

    debugPrint('🔵 [SpacesScreen] No spaces found, creating defaults...');

    try {
      // Get current user ID from auth service
      final authService = ref.read(authServiceProvider);
      final userId = authService.currentUser?.id;

      if (userId == null) {
        debugPrint('🔴 [SpacesScreen] No user ID available, cannot create spaces');
        return;
      }

      final spaceService = ref.read(spaceServiceProvider);

      // Create "Unread" space (purple)
      await spaceService.createSpace(
        userId: userId,
        name: 'Unread',
        color: '#7c3aed', // Purple
      );

      // Create "Reference" space (red)
      await spaceService.createSpace(
        userId: userId,
        name: 'Reference',
        color: '#ef4444', // Red
      );

      debugPrint('✅ [SpacesScreen] Default spaces created successfully');

      // Refresh spaces provider to show new spaces
      await ref.read(spacesProvider.notifier).refresh();
    } catch (e) {
      debugPrint('🔴 [SpacesScreen] Error creating default spaces: $e');
      // Don't show error to user - they'll just see an empty list
      // They can manually create spaces if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch spaces provider for real-time updates
    final spacesAsync = ref.watch(spacesProvider);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xfff5f5f0), // Light gray from Figma

        body: Column(
          children: [
            // Header with title and action buttons
            _buildHeader(),

            // Spaces list (with loading/error/data states)
            Expanded(
              child: spacesAsync.when(
                // Loading state: Show spinner while fetching spaces
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff075a52), // Anchor teal
                  ),
                ),

                // Error state: Show error message
                error: (error, stackTrace) => Center(
                  child: Padding(
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
                          'Error loading spaces',
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
                ),

                // Data state: Show list of spaces
                data: (spaces) {
                  // Auto-create default spaces if this is first launch
                  // This runs asynchronously after the widget builds
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _ensureDefaultSpaces(spaces);
                  });

                  // If no spaces yet (waiting for auto-creation), show loading
                  if (spaces.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xff075a52), // Anchor teal
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Setting up your spaces...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff6a6770),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show list of spaces
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: spaces.length,
                    itemBuilder: (context, index) {
                      final space = spaces[index];
                      return SpaceCard(space: space);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build header with title and action buttons
  ///
  /// Layout:
  /// [Spaces Title] ----------- [+ Button] [Menu Button]
  ///
  /// Buttons are disabled (onPressed: null) for now
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xfff5f5f0), // Match background
      child: Row(
        children: [
          // "Spaces" title
          const Text(
            'Spaces',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700, // Bold
              color: Color(0xff0a090d), // Black
            ),
          ),

          const Spacer(),

          // Plus button (for creating new space - disabled for now)
          IconButton(
            icon: const Icon(Icons.add),
            color: const Color(0xff075a52), // Teal
            iconSize: 28,
            onPressed: null, // Disabled for now
            tooltip: 'Create new space',
          ),

          // Menu button (for settings/actions - disabled for now)
          IconButton(
            icon: const Icon(Icons.menu),
            color: const Color(0xff6a6770), // Gray
            iconSize: 28,
            onPressed: null, // Disabled for now
            tooltip: 'Spaces menu',
          ),
        ],
      ),
    );
  }
}

/// 🎓 Learning Summary: SpacesScreen Architecture
///
/// **AsyncValue.when() Pattern:**
/// Riverpod's AsyncValue provides three states for async data:
/// - loading: Data is being fetched (show spinner)
/// - error: Something went wrong (show error message)
/// - data: Data loaded successfully (show UI)
///
/// **Why ConsumerStatefulWidget?**
/// We need state to handle auto-creation logic on first launch.
/// ConsumerStatefulWidget combines StatefulWidget with Riverpod's ref.
///
/// **Auto-Creation Logic Flow:**
/// ```
/// 1. Screen builds with spacesProvider data
/// 2. If spaces.isEmpty, schedule _ensureDefaultSpaces() after build
/// 3. _ensureDefaultSpaces creates "Unread" and "Reference" spaces
/// 4. Refreshes spacesProvider
/// 5. Screen rebuilds with new spaces shown
/// ```
///
/// **Why addPostFrameCallback?**
/// Can't modify state during build (causes errors).
/// addPostFrameCallback runs AFTER the current frame completes,
/// so it's safe to call async functions and update providers.
///
/// **Disabled Buttons Pattern:**
/// Setting onPressed: null disables buttons but keeps them visible.
/// This is better than hiding them completely because:
/// - User knows the feature exists
/// - UI looks complete (not like something is missing)
/// - Easy to enable later by adding onPressed callback
///
/// **Next:**
/// Update router to use MainScaffold instead of HomeScreen directly.
