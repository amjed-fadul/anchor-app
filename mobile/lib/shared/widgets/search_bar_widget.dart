library;

/// SearchBar Widget
///
/// A functional search input component with clear button and controller support.
///
/// Features:
/// - Text input with search icon
/// - Clear button (X) appears when text is entered
/// - Optional TextEditingController for external control
/// - onChanged callback for reactive search
///
/// Think of this like a search box on a website:
/// - Shows where users can type
/// - Has a magnifying glass icon hint
/// - X button to quickly clear search
/// - Placeholder text explains what you can search
///
/// Real-World Analogy:
/// Like the search bar on Google or the search box in a library.
/// Visual affordance that says "you can search here!"
///
/// Usage:
/// ```dart
/// // Basic usage (widget manages its own controller)
/// SearchBarWidget(
///   onChanged: (query) {
///     // Handle search
///   },
/// )
///
/// // Advanced usage (external controller)
/// final controller = TextEditingController();
/// SearchBarWidget(
///   controller: controller,
///   onChanged: (query) {
///     // Handle search
///   },
/// )
/// // Later: controller.clear() to reset search
/// ```
///
/// Note: We call it SearchBarWidget (not SearchBar) because Flutter already
/// has a SearchBar widget, and we don't want naming conflicts.

import 'package:flutter/material.dart';

/// SearchBarWidget - Functional search input component
///
/// Why StatefulWidget now?
/// - Need to manage internal TextEditingController (if not provided)
/// - Need to listen to controller for clear button visibility
/// - Need to clean up controller in dispose()
///
/// Previous version was StatelessWidget because it had no state.
/// Now we have state: whether clear button should be visible.
class SearchBarWidget extends StatefulWidget {
  /// Optional external TextEditingController
  ///
  /// Why optional?
  /// - Most use cases don't need external control (null = we create internal)
  /// - Advanced use cases (like HomeScreen) may want to control text externally
  ///
  /// Example:
  /// ```dart
  /// // Let widget manage controller (most common)
  /// SearchBarWidget()
  ///
  /// // Control externally
  /// final _controller = TextEditingController();
  /// SearchBarWidget(controller: _controller)
  /// // Later: _controller.clear()
  /// ```
  final TextEditingController? controller;

  /// Callback when search text changes
  ///
  /// Called whenever user types or clears the field.
  /// Includes when clear button is tapped (sends empty string).
  final ValueChanged<String>? onChanged;

  /// Placeholder text shown when empty
  final String placeholder;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.placeholder = 'Search bookmarks, links or tags',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  /// Internal controller (used if no external controller provided)
  ///
  /// Why late?
  /// - Initialized in initState() (can't initialize in declaration)
  /// - Guaranteed to be initialized before first use
  ///
  /// Why nullable?
  /// - Only created if widget.controller is null
  /// - If external controller provided, this stays null
  late TextEditingController? _internalController;

  /// The actual controller being used (external or internal)
  ///
  /// This is a getter that returns whichever controller is active.
  /// Makes rest of code simpler - just use `_controller` everywhere.
  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  /// Whether clear button should be visible
  ///
  /// True when text is not empty, false when empty.
  /// Updates via listener on controller.
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();

    // Create internal controller if no external controller provided
    if (widget.controller == null) {
      _internalController = TextEditingController();
    } else {
      _internalController = null;
    }

    // Listen to controller changes to show/hide clear button
    // addListener() is called whenever text changes
    _controller.addListener(_onTextChanged);

    // Set initial clear button visibility
    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If controller changed (unlikely but handle it), update listeners
    if (widget.controller != oldWidget.controller) {
      // Remove listener from old controller
      oldWidget.controller?.removeListener(_onTextChanged);
      _internalController?.removeListener(_onTextChanged);

      // If switching from internal to external or vice versa
      if (widget.controller == null && oldWidget.controller != null) {
        // Switching to internal controller
        _internalController = TextEditingController();
      } else if (widget.controller != null && oldWidget.controller == null) {
        // Switching to external controller
        _internalController?.dispose();
        _internalController = null;
      }

      // Add listener to new controller
      _controller.addListener(_onTextChanged);
      _showClearButton = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    // Remove listener before disposing
    _controller.removeListener(_onTextChanged);

    // Only dispose internal controller (external controllers are managed by parent)
    _internalController?.dispose();

    super.dispose();
  }

  /// Callback when text changes
  ///
  /// Updates clear button visibility based on whether text is empty.
  /// Called automatically via controller listener.
  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
  }

  /// Handle clear button tap
  ///
  /// Clears the text field and calls onChanged with empty string.
  /// This resets search results to show all links.
  void _handleClear() {
    _controller.clear();
    // onChanged is automatically called by TextField when text changes
    // But if onChanged is provided, we ensure it's called with empty string
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding - only top spacing (horizontal spacing provided by parent container)
      padding: const EdgeInsets.only(top: 12),

      child: TextField(
        // Controller - manages the text content
        controller: _controller,

        // onChanged callback (called when user types)
        onChanged: widget.onChanged,

        // Decoration: Visual styling of the text field
        decoration: InputDecoration(
          // Prefix icon: Magnifying glass on the left
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 22,
          ),

          // Suffix icon: Clear button (X) on the right
          // Only shown when text is not empty
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: _handleClear,
                  tooltip: 'Clear search',
                  // Smaller padding to fit nicely in search bar
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                )
              : null,

          // Hint text: Placeholder shown when empty
          hintText: widget.placeholder,
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

/// 🎓 Learning Summary: StatefulWidget vs StatelessWidget
///
/// **When to Use StatefulWidget:**
/// - When widget needs to manage internal state (like clear button visibility)
/// - When widget needs to listen to controllers/streams
/// - When widget needs lifecycle methods (initState, dispose)
/// - When widget needs to update UI based on changes
///
/// **When to Use StatelessWidget:**
/// - When widget is purely presentational
/// - When all data comes from constructor parameters
/// - When widget doesn't need to track changes
/// - When widget doesn't need cleanup (no dispose)
///
/// **SearchBarWidget Evolution:**
/// - v1: StatelessWidget (just displayed TextField)
/// - v2: StatefulWidget (manages controller, clear button state)
///
/// **TextEditingController Pattern:**
///
/// Why we support both internal and external controllers:
///
/// ```dart
/// // Internal controller (most common)
/// SearchBarWidget()  // Widget creates and manages controller
///
/// // External controller (advanced)
/// final _controller = TextEditingController();
/// SearchBarWidget(controller: _controller)
/// // Parent can control: _controller.clear(), _controller.text = 'foo'
/// ```
///
/// **Listener Pattern:**
///
/// ```dart
/// _controller.addListener(_onTextChanged);  // Register listener
/// // When text changes: _onTextChanged() is called
/// _controller.removeListener(_onTextChanged);  // Cleanup
/// ```
///
/// **Why This Matters:**
/// - Clear button only shown when needed (better UX)
/// - External control enables programmatic search clearing
/// - Proper cleanup prevents memory leaks
///
/// **Memory Management:**
/// - Internal controller: We create it → we dispose it
/// - External controller: Parent creates it → parent disposes it
/// - This prevents double-disposal bugs!
///
/// **Real-World Analogy:**
///
/// Think of TextEditingController like a TV remote:
/// - Internal controller: Widget has its own remote (most common)
/// - External controller: Parent passes down their remote (advanced control)
/// - Either way, someone owns the remote and is responsible for its batteries
///
/// **Testing Note:**
/// All the tests we wrote earlier should now pass!
/// - Clear button visibility tests
/// - Clear button tap tests
/// - External controller tests
/// - onChanged callback tests
///
/// **Next:**
/// Integrate this SearchBarWidget into HomeScreen with debounced search!
