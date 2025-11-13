library;

/// TagBadge Widget
///
/// A small colored pill component that displays tag names.
///
/// Think of this like a colored label or sticker:
/// - Shows the tag name (like "Design", "Apple", "Work")
/// - Has a unique color for visual distinction
/// - Pill-shaped with rounded corners
/// - Compact size so it doesn't dominate the screen
///
/// Real-World Analogy:
/// Like colored name tags at a conference or sticky notes on a bulletin board.
/// Each tag has a name and color to help you quickly identify categories.
///
/// Usage:
/// ```dart
/// TagBadge(tag: Tag(
///   name: 'Design',
///   color: '#f42cff',
///   // ... other fields
/// ))
/// ```

import 'package:flutter/material.dart';
import '../models/tag_model.dart';

/// TagBadge - Colored pill component for displaying tags
class TagBadge extends StatelessWidget {
  /// The tag to display
  final Tag tag;

  const TagBadge({
    super.key,
    required this.tag,
  });

  /// Convert hex color string to Flutter Color object
  ///
  /// Why we need this:
  /// Tags store colors as hex strings (like "#f42cff") because that's
  /// how they're stored in the database. Flutter needs Color objects.
  ///
  /// Example conversions:
  /// - "#f42cff" -> Color(0xfff42cff) - Pink
  /// - "#075a52" -> Color(0xff075a52) - Teal
  /// - "#682cff" -> Color(0xff682cff) - Purple
  ///
  /// The "0xff" prefix means:
  /// - 0x = hexadecimal number
  /// - ff = alpha channel (fully opaque)
  /// - Rest = RGB color from hex string
  Color _hexToColor(String hexColor) {
    // Remove the # symbol
    final hexWithoutHash = hexColor.replaceAll('#', '');

    // Convert to integer and add alpha channel
    // Example: "f42cff" becomes "fff42cff" (fully opaque pink)
    return Color(int.parse('ff$hexWithoutHash', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding: Space between text and container edges
      // EdgeInsets.symmetric means:
      // - horizontal: 12px left + 12px right
      // - vertical: 6px top + 6px bottom
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      // Decoration: Background color and rounded corners
      decoration: BoxDecoration(
        // Use the tag's color for background
        color: _hexToColor(tag.color),

        // BorderRadius: Makes it pill-shaped with rounded corners
        // circular(16) = radius of 16px on all corners
        borderRadius: BorderRadius.circular(16),
      ),

      // The actual tag name text
      child: Text(
        tag.name,
        style: const TextStyle(
          // White text for contrast against colored background
          color: Colors.white,

          // Small font size (12px) for compact display
          fontSize: 12,

          // FontWeight.w500 = medium weight (not too thin, not too bold)
          fontWeight: FontWeight.w500,
        ),

        // Handle long tag names gracefully
        // TextOverflow.ellipsis adds "..." if text is too long
        // Example: "Very Long Tag Name" becomes "Very Long Ta..."
        overflow: TextOverflow.ellipsis,

        // maxLines: 1 ensures tag stays on single line
        maxLines: 1,
      ),
    );
  }
}

/// 🎓 Learning Summary: StatelessWidget
///
/// **What is StatelessWidget?**
/// A widget that doesn't change after it's created.
/// Think of it like a printed photograph - once created, it never changes.
///
/// **When to use StatelessWidget:**
/// - Widget only depends on input parameters (like our Tag)
/// - No user interactions that change the widget
/// - No animations or timers
///
/// **When NOT to use StatelessWidget:**
/// - Widget needs to change based on user actions (use StatefulWidget)
/// - Widget has animations (use StatefulWidget)
/// - Widget has internal state that changes
///
/// **Our TagBadge is Stateless because:**
/// - It receives a Tag object
/// - It displays that tag
/// - Nothing changes after creation
/// - If the tag changes, a NEW TagBadge is created
///
/// **Widget Lifecycle:**
/// 1. Constructor called: `TagBadge(tag: myTag)`
/// 2. build() called: Creates the UI
/// 3. Widget displayed on screen
/// 4. If tag changes: NEW widget created (old one destroyed)
///
/// **Performance Tip:**
/// StatelessWidget is faster than StatefulWidget because it's simpler.
/// Always use StatelessWidget unless you specifically need state.
///
/// **Color Conversion Details:**
///
/// Why we need to convert hex to Color:
/// - Database stores colors as strings: "#f42cff"
/// - Flutter widgets need Color objects: Color(0xfff42cff)
///
/// Hex color format:
/// - # = prefix
/// - First 2 digits = Red (00-ff)
/// - Middle 2 digits = Green (00-ff)
/// - Last 2 digits = Blue (00-ff)
///
/// Flutter Color format:
/// - 0x = hex number prefix
/// - First 2 digits = Alpha/opacity (ff = fully opaque)
/// - Last 6 digits = RGB from hex color
///
/// Example: "#f42cff" (pink)
/// - f4 = 244 red
/// - 2c = 44 green
/// - ff = 255 blue
/// - Result: Pink color!
///
/// **Responsive Design:**
/// This widget is responsive because:
/// - Uses relative sizing (padding scales with screen)
/// - Handles text overflow gracefully
/// - Works on any screen size
/// - No hardcoded pixel widths
///
/// **Next:**
/// Run tests again - they should now PASS (🟢 GREEN)!
