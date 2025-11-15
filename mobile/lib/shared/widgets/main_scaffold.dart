library;

/// MainScaffold - Bottom Navigation Wrapper
///
/// Provides the main app structure with bottom navigation bar.
/// Wraps Home and Spaces screens, manages tab selection.
///
/// Real-World Analogy:
/// Think of this like a book with tabs - you can flip between
/// chapters (screens) using the tabs at the bottom.
///
/// Features:
/// - Bottom navigation with 2 tabs: Home and Spaces
/// - Active tab shown in teal (#075a52)
/// - Inactive tabs shown in gray (#6a6770)
/// - Uses IndexedStack to preserve state when switching tabs
/// - SVG icons for home and spaces

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/spaces/screens/spaces_screen.dart';

/// Provider for managing current tab index
///
/// Why StateProvider?
/// - Simple state (just an integer 0 or 1)
/// - Needs to be reactive (UI updates when tab changes)
/// - No complex logic required
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current tab index
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      // Body: IndexedStack preserves state of each screen
      // when switching tabs (scroll position, form data, etc.)
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomeScreen(),      // Index 0
          SpacesScreen(),    // Index 1
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Update current tab index when user taps
          ref.read(currentTabIndexProvider.notifier).state = index;
        },

        // Styling
        type: BottomNavigationBarType.fixed, // Keeps labels always visible
        backgroundColor: Colors.white,
        elevation: 8, // Subtle shadow for depth
        selectedItemColor: const Color(0xff075a52), // Anchor teal
        unselectedItemColor: const Color(0xff6a6770), // Gray
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),

        // Navigation Items
        items: [
          // Home Tab
          BottomNavigationBarItem(
            icon: _buildIcon('assets/images/home icon.svg', currentIndex == 0),
            label: 'Home',
          ),

          // Spaces Tab
          BottomNavigationBarItem(
            icon: _buildIcon('assets/images/Spaces icon.svg', currentIndex == 1),
            label: 'Spaces',
          ),
        ],
      ),
    );
  }

  /// Build SVG icon with proper color based on active state
  ///
  /// Parameters:
  /// - assetPath: Path to SVG file
  /// - isActive: Whether this tab is currently selected
  ///
  /// Returns colored SVG icon widget
  Widget _buildIcon(String assetPath, bool isActive) {
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive
            ? const Color(0xff075a52) // Teal when active
            : const Color(0xff6a6770), // Gray when inactive
        BlendMode.srcIn,
      ),
    );
  }
}

/// 🎓 Learning Summary: Bottom Navigation
///
/// **What is IndexedStack?**
/// A Stack that shows only ONE child at a time based on index.
/// Unlike PageView, it keeps ALL children in memory (preserves state).
///
/// **Why IndexedStack over PageView?**
/// - Preserves scroll position when switching tabs
/// - Keeps form data intact when navigating away
/// - No animation/swipe gesture (just instant switch)
/// - Better for bottom nav where you want state preservation
///
/// **State Management Pattern:**
/// ```dart
/// // Provider holds the tab index
/// final currentTabIndexProvider = StateProvider<int>((ref) => 0);
///
/// // Widget watches the provider
/// final currentIndex = ref.watch(currentTabIndexProvider);
///
/// // onTap updates the provider
/// onTap: (index) => ref.read(currentTabIndexProvider.notifier).state = index
/// ```
///
/// **SVG Icon Coloring:**
/// We use ColorFilter to tint SVG icons:
/// - BlendMode.srcIn replaces SVG color with our color
/// - Active tab gets teal (#075a52)
/// - Inactive tabs get gray (#6a6770)
///
/// **Next:**
/// Create the SpacesScreen that will be shown when user taps Spaces tab.
