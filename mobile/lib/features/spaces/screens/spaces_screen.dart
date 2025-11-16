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
import '../providers/space_provider.dart';
import '../widgets/space_card.dart';
import '../widgets/create_space_bottom_sheet.dart';
import '../../../design_system/design_system.dart';

class SpacesScreen extends ConsumerStatefulWidget {
  const SpacesScreen({super.key});

  @override
  ConsumerState<SpacesScreen> createState() => _SpacesScreenState();
}

class _SpacesScreenState extends ConsumerState<SpacesScreen> {
  /// Default spaces are created automatically by database
  ///
  /// - NEW users: Database trigger creates default spaces on signup
  ///   (See: supabase/migrations/002_create_spaces_table.sql)
  ///
  /// - EXISTING users: Backfill migration creates defaults
  ///   (See: supabase/migrations/005_backfill_default_spaces.sql)
  ///
  /// This screen simply displays whatever spaces exist in the database.

  /// Show Create Space bottom sheet
  ///
  /// Opens a modal bottom sheet with the 2-step space creation flow:
  /// 1. Enter space name
  /// 2. Pick a color
  void _showCreateSpaceSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow custom height
      backgroundColor: Colors.transparent, // For rounded corners
      builder: (context) => const CreateSpaceBottomSheet(),
    );
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
                  // If no spaces, show empty state
                  // (This should never happen for normal users - database trigger creates defaults)
                  if (spaces.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.folder_outlined,
                              size: 64,
                              color: Color(0xff6a6770), // Gray
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No spaces yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff0a090d),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first space',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xff6a6770),
                              ),
                            ),
                          ],
                        ),
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

          // Plus button (for creating new space)
          // Styled to match home screen FAB with circular teal button
          Material(
            elevation: 2, // Subtle shadow for depth (AppBar context)
            shape: const CircleBorder(), // Perfect circle
            color: AnchorColors.anchorTeal, // Brand teal background (#0D9488)
            child: InkWell(
              onTap: _showCreateSpaceSheet,
              borderRadius: BorderRadius.circular(20), // Circular tap effect
              child: Container(
                width: 40, // Compact size for AppBar (vs 56 for FAB)
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add,
                  color: Colors.white, // White icon (like FAB)
                  size: 24, // Slightly smaller for AppBar
                ),
              ),
            ),
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
