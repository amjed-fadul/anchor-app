library;

/// StyledAddButton - Reusable Add Button Component
///
/// A styled circular/rounded button with teal background, elevation, and ripple effect.
/// Used across the app for consistent "add" action styling.
///
/// Design Pattern: Component Reusability
/// Instead of duplicating the same button code in multiple screens,
/// we create a single reusable widget that can be used anywhere.
///
/// Benefits:
/// - Consistency: All add buttons look the same
/// - Maintainability: Update once, changes apply everywhere
/// - DRY (Don't Repeat Yourself): No code duplication
///
/// Usage:
/// ```dart
/// StyledAddButton(
///   onPressed: () => showCreateSheet(),
///   tooltip: 'Create new item',
/// )
/// ```

import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

class StyledAddButton extends StatelessWidget {
  /// Callback when button is tapped
  final VoidCallback onPressed;

  /// Tooltip text shown on long press
  final String tooltip;

  /// Button size (default: 40x40 for AppBar context)
  final double size;

  /// Icon size (default: 24 for AppBar context)
  final double iconSize;

  const StyledAddButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.size = 40,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 2, // Subtle shadow for depth (AppBar context)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners
        ),
        color: AnchorColors.anchorTeal, // Brand teal background (#0D9488)
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8), // Rounded tap effect
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              Icons.add,
              color: Colors.white, // White icon
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎓 Learning Summary: Reusable Widget Pattern
///
/// **What is a Reusable Widget?**
/// A widget that encapsulates common functionality and can be used
/// in multiple places throughout your app.
///
/// **When to Create Reusable Widgets:**
/// - Same UI pattern used in 2+ places
/// - Complex widget with multiple properties
/// - Consistent styling needed across screens
/// - Want to enforce design system standards
///
/// **Component Design Principles:**
///
/// 1. **Single Responsibility**: Each widget does ONE thing well
///    - StyledAddButton ONLY handles the add button styling
///    - Doesn't care about what happens when clicked (callback pattern)
///
/// 2. **Configurable**: Allow customization through parameters
///    - `onPressed`: What happens when clicked
///    - `tooltip`: What text to show
///    - `size`: How big the button is
///    - Provides sensible defaults
///
/// 3. **Consistent**: Enforces design system standards
///    - Always uses `AnchorColors.anchorTeal`
///    - Always has elevation and rounded corners
///    - Can't accidentally use wrong color
///
/// **Real-World Analogy:**
/// Think of reusable widgets like **LEGO bricks**:
/// - Each brick has a specific shape and purpose
/// - You can use the same brick in many different creations
/// - Changing the brick design affects all places it's used
/// - Mix and match bricks to build complex structures
///
/// **Before (Code Duplication):**
/// ```dart
/// // spaces_screen.dart
/// Material(
///   elevation: 2,
///   shape: RoundedRectangleBorder(...),
///   color: AnchorColors.anchorTeal,
///   child: InkWell(...),
/// )
///
/// // space_detail_screen.dart
/// Material(
///   elevation: 2,
///   shape: RoundedRectangleBorder(...),
///   color: AnchorColors.anchorTeal,
///   child: InkWell(...),
/// )
/// ```
/// ❌ Problem: Same code in 2 places. If you need to change the color,
///    you have to update it in both files!
///
/// **After (Reusable Component):**
/// ```dart
/// // spaces_screen.dart
/// StyledAddButton(
///   onPressed: _showCreateSpaceSheet,
///   tooltip: 'Create new space',
/// )
///
/// // space_detail_screen.dart
/// StyledAddButton(
///   onPressed: () => _showAddLinkFlow(context),
///   tooltip: 'Add link to ${space.name}',
/// )
/// ```
/// ✅ Solution: Widget defined ONCE, used in many places. Change the
///    StyledAddButton file and all buttons update automatically!
///
/// **Flutter Widget Composition:**
/// This is a core Flutter pattern - build complex UIs by composing
/// small, focused, reusable widgets together.
///
/// **Next Steps:**
/// When you see duplicate UI code, ask yourself:
/// "Can this be extracted into a reusable widget?"
/// If yes, create a new widget file and use it everywhere!
