library;

/// SearchBar Widget
///
/// A visual search input component for the home screen.
/// Currently displays the UI only - search functionality will be added later.
///
/// Think of this like a search box on a website:
/// - Shows where users can type
/// - Has a magnifying glass icon hint
/// - Placeholder text explains what you can search
///
/// Real-World Analogy:
/// Like the search bar on Google or the search box in a library.
/// Visual affordance that says "you can search here!"
///
/// Usage:
/// ```dart
/// SearchBarWidget(
///   onChanged: (query) {
///     // Handle search later
///   },
/// )
/// ```
///
/// Note: We call it SearchBarWidget (not SearchBar) because Flutter already
/// has a SearchBar widget, and we don't want naming conflicts.

import 'package:flutter/material.dart';

/// SearchBarWidget - Visual search input component
class SearchBarWidget extends StatelessWidget {
  /// Callback when search text changes (optional for now)
  final ValueChanged<String>? onChanged;

  /// Placeholder text shown when empty
  final String placeholder;

  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.placeholder = 'Search bookmarks, links or tags',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding - only top spacing (horizontal spacing provided by parent container)
      padding: const EdgeInsets.only(top: 12),

      child: TextField(
        // onChanged callback (will be used when search is functional)
        onChanged: onChanged,

        // Decoration: Visual styling of the text field
        decoration: InputDecoration(
          // Prefix icon: Magnifying glass on the left
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 22,
          ),

          // Hint text: Placeholder shown when empty
          hintText: placeholder,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 15,
          ),

          // Filled: Use background color
          filled: true,
          fillColor: Colors.grey[100], // Light gray background

          // Border: Rounded corners, no visible border
          // enabledBorder: When not focused
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // No border line
          ),

          // focusedBorder: When user taps/focuses
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xff075a52), // Teal theme color
              width: 2,
            ),
          ),

          // Content padding: Space inside the text field
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          // Dense: Makes field more compact
          isDense: true,
        ),

        // Text style
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// 🎓 Learning Summary: TextField Widget
///
/// **What is TextField?**
/// A widget that lets users type text input.
/// Think of it like an HTML <input> element.
///
/// **Key Properties:**
///
/// 1. **decoration**: Visual styling
///    - InputDecoration controls how it looks
///    - Icons, borders, hints, colors, etc.
///
/// 2. **prefixIcon**: Icon on the left side
///    - Magnifying glass indicates "search"
///    - User icon might indicate "username"
///    - Lock icon might indicate "password"
///
/// 3. **hintText**: Placeholder when empty
///    - Shows what user should type
///    - Disappears when user starts typing
///    - Gray color so it doesn't look like actual input
///
/// 4. **filled & fillColor**: Background color
///    - filled: true enables background
///    - fillColor: sets the color
///    - Light gray (grey[100]) is common for search
///
/// 5. **Borders**: Different states
///    - enabledBorder: Normal state (not focused)
///    - focusedBorder: When user taps in
///    - errorBorder: When validation fails
///
/// **Border Styles:**
///
/// OutlineInputBorder:
/// - Creates rounded rectangle border
/// - borderRadius: how rounded the corners are
/// - borderSide: the actual border line
/// - BorderSide.none: no visible border
///
/// **Why BorderSide.none?**
/// For search bars, we often want just a filled background
/// without a border line. This creates a cleaner, modern look.
/// When focused, we show teal border for feedback.
///
/// **Responsive Design:**
/// This widget is responsive because:
/// - Width adapts to parent (no fixed width)
/// - Padding uses EdgeInsets (scales with screen)
/// - Font sizes are readable on all devices
/// - Touch target is large enough (44px+ height)
///
/// **State Management Note:**
/// We use StatelessWidget because:
/// - TextField manages its own text internally
/// - We don't need to store or manipulate the text yet
/// - onChanged callback sends text to parent when needed
///
/// **Later Enhancements:**
/// When we add search functionality:
/// 1. Add TextEditingController to control text
/// 2. Implement search logic in onChanged
/// 3. Add loading indicator while searching
/// 4. Show search results dropdown
/// 5. Add clear button (X) when text is entered
///
/// **Material Design Guidelines:**
/// - Search fields should be easy to find (top of screen)
/// - Use magnifying glass icon universally recognized
/// - Placeholder text should explain what's searchable
/// - Focus state should be visually distinct
/// - Field should be wide enough to show search terms
///
/// **Next:**
/// This SearchBar will be used in the home screen header
/// along with the user avatar and greeting.
