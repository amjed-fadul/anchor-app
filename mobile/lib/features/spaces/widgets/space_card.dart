library;

/// SpaceCard Widget
///
/// Displays a single space as a card with:
/// - Colored square icon on left
/// - Space name in middle
/// - Chevron arrow on right
///
/// Real-World Analogy:
/// Like a folder in a file manager - colored icon shows category,
/// name shows what's inside, arrow indicates you can open it.
///
/// Design from Figma:
/// - White card with rounded corners (12px)
/// - Height: ~72px with padding
/// - Colored square: 40x40, rounded 8px
/// - Space name: 16px, semibold, black
/// - Chevron: gray, 24px

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/space_model.dart';

class SpaceCard extends StatelessWidget {
  final Space space;

  const SpaceCard({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Flat design as per Figma
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12), // Space between cards
      child: InkWell(
        // Navigate to Space Detail Screen when tapped
        // Using push() instead of go() so back button works
        onTap: () => context.push('/spaces/${space.id}', extra: space),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Colored square icon
              _buildColoredIcon(),

              const SizedBox(width: 16),

              // Space name (expanded to take available space)
              Expanded(
                child: Text(
                  space.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // Semibold
                    color: Color(0xff0a090d), // Black
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // Chevron arrow
              const Icon(
                Icons.chevron_right,
                color: Color(0xff6a6770), // Gray
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build colored square icon for the space
  ///
  /// Returns a 40x40 container with rounded corners
  /// colored based on the space's color property
  Widget _buildColoredIcon() {
    // Parse hex color string to Color object
    // Space.color is stored as hex string like "#7c3aed"
    final color = _parseColor(space.color);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Parse hex color string to Color object
  ///
  /// Handles hex strings like:
  /// - "#7c3aed" → Color(0xff7c3aed)
  /// - "7c3aed" → Color(0xff7c3aed)
  /// - Invalid → Fallback gray color
  Color _parseColor(String hexColor) {
    try {
      // Remove # if present
      String cleanHex = hexColor.replaceAll('#', '');

      // Add alpha channel (ff) if not present
      if (cleanHex.length == 6) {
        cleanHex = 'ff$cleanHex';
      }

      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      // Fallback to gray if color parsing fails
      debugPrint('⚠️ Failed to parse space color: $hexColor, using fallback gray');
      return const Color(0xff6a6770);
    }
  }
}

/// 🎓 Learning Summary: SpaceCard Design
///
/// **Layout Structure:**
/// ```
/// Card (white, rounded 12px)
/// └── InkWell (tap feedback - disabled for now)
///     └── Padding (16px all sides)
///         └── Row
///             ├── Container (colored square 40x40, rounded 8px)
///             ├── SizedBox (16px gap)
///             ├── Expanded (space name text)
///             └── Icon (chevron arrow, gray)
/// ```
///
/// **Color Parsing:**
/// Space colors are stored as hex strings in database ("#7c3aed").
/// We parse them to Flutter Color objects:
/// - Remove # prefix
/// - Add alpha channel "ff" for full opacity
/// - Parse as base-16 integer
/// - Create Color object
///
/// **Why Expanded for Text?**
/// - Takes all available space between icon and chevron
/// - Allows long space names to wrap/ellipsis properly
/// - Prevents overflow if space name is very long
///
/// **Why InkWell with onTap: null?**
/// - Keeps structure ready for future implementation
/// - No tap feedback shown when disabled (null)
/// - Easy to enable later by adding onTap callback
///
/// **Next:**
/// Create SpacesScreen that displays a list of these SpaceCards.
