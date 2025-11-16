library;

/// SpacePickerSheet - Reusable Space Selection Bottom Sheet
///
/// A reusable widget for selecting a space from the user's available spaces.
/// Used in multiple places throughout the app for consistent space selection UX.
///
/// Design Pattern: Component Reusability
/// Instead of duplicating space selection UI in multiple screens,
/// we create a single reusable widget that handles all space selection interactions.
///
/// Features:
/// - Displays list of all user spaces with colors
/// - Shows checkmark for currently selected space
/// - Allows deselecting by tapping selected space (toggle behavior)
/// - Handles empty state when no spaces exist
/// - Responsive to different screen sizes
///
/// Real-World Analogy:
/// Think of this like a **folder picker dialog** in file managers:
/// - Shows all available folders (spaces)
/// - Current folder is highlighted (checkmark)
/// - Click to move item to that folder
/// - Click highlighted folder again to unassign
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => SpacePickerSheet(
///     availableSpaces: spaces,
///     selectedSpaceId: currentSpaceId,
///     onSpaceSelected: (spaceId) {
///       // Update link with new space
///       Navigator.pop(context);
///     },
///   ),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:mobile/design_system/design_system.dart';
import '../../spaces/models/space_model.dart';

class SpacePickerSheet extends StatefulWidget {
  /// List of all available spaces to choose from
  final List<Space> availableSpaces;

  /// Currently selected space ID (null = no space selected)
  final String? selectedSpaceId;

  /// Callback when a space is confirmed
  /// Passes the new space ID (or null if deselected)
  final Function(String?) onSpaceSelected;

  /// Title text shown at the top of the sheet
  final String title;

  const SpacePickerSheet({
    super.key,
    required this.availableSpaces,
    required this.selectedSpaceId,
    required this.onSpaceSelected,
    this.title = 'SELECT SPACE',
  });

  @override
  State<SpacePickerSheet> createState() => _SpacePickerSheetState();
}

class _SpacePickerSheetState extends State<SpacePickerSheet> {
  /// Internal state: Currently selected space ID
  /// This allows users to change their selection before confirming
  late String? _currentSelection;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed-in selected space
    _currentSelection = widget.selectedSpaceId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Color(0xff0a090d),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Space list
            Flexible(
              child: widget.availableSpaces.isEmpty
                  ? _buildEmptyState()
                  : _buildSpaceList(),
            ),

            // Done button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Call the callback with the current selection
                    widget.onSpaceSelected(_currentSelection);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnchorColors.anchorTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no spaces exist
  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 64,
            color: Color(0xff6a6770), // Gray
          ),
          SizedBox(height: 16),
          Text(
            'No spaces yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xff0a090d),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a space from the Spaces tab to organize your links',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xff6a6770),
            ),
          ),
        ],
      ),
    );
  }

  /// Build list of available spaces
  Widget _buildSpaceList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.availableSpaces.length,
      itemBuilder: (context, index) {
        final space = widget.availableSpaces[index];
        final isSelected = _currentSelection == space.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AnchorColors.anchorTeal : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _parseColor(space.color),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Text(
              space.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xff0a090d),
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check,
                    color: AnchorColors.anchorTeal,
                  )
                : null,
            onTap: () {
              // Toggle behavior: tap selected space to deselect
              setState(() {
                _currentSelection = isSelected ? null : space.id;
              });
            },
          ),
        );
      },
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

/// 🎓 Learning Summary: Reusable Bottom Sheet Pattern
///
/// **What is a Reusable Bottom Sheet?**
/// A bottom sheet widget that can be used in multiple places throughout
/// the app with different data and callbacks.
///
/// **Why Create This Component?**
/// 1. **DRY (Don't Repeat Yourself)**: Space selection UI was duplicated in
///    AddDetailsScreen. Now it's defined once, used multiple times.
///
/// 2. **Consistent UX**: All space selection interactions look and behave
///    the same across the app.
///
/// 3. **Easy Maintenance**: Update the design once, changes apply everywhere.
///
/// 4. **Testability**: Easier to test as a standalone component.
///
/// **Component Design Pattern:**
///
/// ```
/// SpacePickerSheet
/// ├── Inputs (Props):
/// │   ├── availableSpaces: List<Space> (data to display)
/// │   ├── selectedSpaceId: String? (current selection)
/// │   └── onSpaceSelected: Function (what to do when selected)
/// ├── Output:
/// │   └── Calls onSpaceSelected(spaceId) when user taps
/// └── Responsibilities:
///     ├── Render list of spaces
///     ├── Show selection state (checkmark)
///     ├── Handle tap interactions
///     └── Parse space colors
/// ```
///
/// **Callback Pattern:**
/// The widget doesn't know or care what happens after a space is selected.
/// It simply calls the `onSpaceSelected` callback with the new space ID.
/// This makes the widget flexible and reusable in different contexts.
///
/// **Real-World Analogy:**
/// Think of this like a **template** or **stencil**:
/// - The template (SpacePickerSheet) defines the shape/structure
/// - You fill in the specifics (spaces, selection, callback) each time you use it
/// - Same template works for different contexts (add link, move link, etc.)
///
/// **Where Used:**
/// 1. LinkCard → Add to Space action
/// 2. AddDetailsScreen → Space tab (could be refactored to use this)
/// 3. Future: Any place that needs space selection
///
/// **Benefits Over Inline Implementation:**
/// - **Before**: 80 lines of space picker code duplicated in each screen
/// - **After**: 3 lines to show picker + 1 reusable component
/// - **Maintenance**: Update component once vs update every screen
/// - **Consistency**: Same UI/UX everywhere automatically
///
/// **Next Steps:**
/// Could enhance this component with:
/// - Search/filter spaces by name
/// - Create new space button
/// - Recently used spaces at top
/// - Space link count badge
