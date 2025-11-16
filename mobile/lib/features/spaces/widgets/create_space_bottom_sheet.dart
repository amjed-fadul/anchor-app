library;

/// Create Space Bottom Sheet
///
/// A 2-step flow for creating a new space:
/// 1. Enter space name (with auto-focus)
/// 2. Pick a color from predefined palette
///
/// Design from Figma:
/// - Node 1-1146: Name input screen
/// - Node 1-1163: Color picker screen
/// - Node 1-1196: Color selected state
///
/// Real-World Analogy:
/// Think of this like creating a new folder on your computer:
/// Step 1: "What do you want to name this folder?"
/// Step 2: "What color label should it have?"

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/space_provider.dart';

/// Color palette for spaces (14 colors from Figma design)
const List<String> spaceColors = [
  // Row 1
  '#7cfec4', // Light green/teal
  '#c3c3d1', // Gray
  '#ff8da7', // Pink
  '#000002', // Black
  '#15afcf', // Blue
  '#1ac47f', // Green
  '#ffdcd4', // Peach

  // Row 2
  '#7e30d1', // Purple
  '#fff273', // Yellow
  '#c5a3af', // Dusty rose
  '#97cdd3', // Light blue
  '#c2b8d9', // Lavender
  '#1773fa', // Bright blue
  '#ed404d', // Red
];

/// CreateSpaceBottomSheet - Main widget for create space flow
///
/// This widget manages the 2-step process:
/// - Page 0: Name input (with auto-focus and validation)
/// - Page 1: Color picker (with visual selection feedback)
///
/// State is managed locally using StatefulWidget since it's a
/// self-contained flow that doesn't need app-wide state.
class CreateSpaceBottomSheet extends StatefulWidget {
  const CreateSpaceBottomSheet({super.key});

  @override
  State<CreateSpaceBottomSheet> createState() =>
      _CreateSpaceBottomSheetState();
}

class _CreateSpaceBottomSheetState extends State<CreateSpaceBottomSheet> {
  /// Controller for navigating between pages
  final PageController _pageController = PageController();

  /// Current page index (0 = name input, 1 = color picker)
  int _currentPage = 0;

  /// User-entered space name
  String _spaceName = '';

  /// Selected color (null until user picks one)
  String? _selectedColor;

  /// Loading state during space creation
  bool _isCreating = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to color picker page
  void _goToColorPicker() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = 1);
  }

  /// Create the space and dismiss sheet
  Future<void> _handleCreate(BuildContext context, WidgetRef ref) async {
    if (_selectedColor == null || _spaceName.trim().isEmpty) return;

    setState(() => _isCreating = true);

    try {
      // Create space via provider
      await ref
          .read(spacesProvider.notifier)
          .createSpace(_spaceName.trim(), _selectedColor!);

      if (context.mounted) {
        // Success! Dismiss sheet
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Space "${_spaceName.trim()}" created!'),
            backgroundColor: const Color(0xff0d9488), // Teal
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        setState(() => _isCreating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create space: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xfff4f4f4), // Light gray background
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [
          _buildNameInputPage(),
          _buildColorPickerPage(),
        ],
      ),
    );
  }

  /// Page 1: Name Input
  ///
  /// User enters the name for their new space.
  /// TextField auto-focuses so keyboard opens immediately.
  Widget _buildNameInputPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Grabber (drag handle)
            Container(
              width: 36,
              height: 5,
              margin: const EdgeInsets.only(top: 6, bottom: 48),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),

            // Icon
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xff0d9488), // Teal
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.folder_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),

            // Title
            const Text(
              'Create new space',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                letterSpacing: -0.264,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Description
            const Text(
              'A space is a collection of bookmarks inside your Anchor. '
              'Save directly to your space or add from your home links',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xff5f5f5f),
                letterSpacing: -0.176,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Name input field
            TextField(
              autofocus: true, // ✅ Auto-focus for immediate keyboard
              maxLength: 50, // Database constraint
              onChanged: (value) {
                setState(() => _spaceName = value);
              },
              decoration: InputDecoration(
                hintText: 'Name your space',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xff0d9488),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xff0d9488),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xff0d9488),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),

            const Spacer(),

            // Next button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _spaceName.trim().isEmpty ? null : _goToColorPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0d9488), // Teal
                  disabledBackgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Page 2: Color Picker
  ///
  /// User picks a color for their space from a predefined palette.
  /// When a color is selected, shows a large 84x84 preview above the grid.
  Widget _buildColorPickerPage() {
    return Consumer(
      builder: (context, ref, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Grabber
                Container(
                  width: 36,
                  height: 5,
                  margin: const EdgeInsets.only(top: 6, bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),

                // Icon
                Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0d9488), // Teal
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                // Title
                const Text(
                  'Pick a color',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    letterSpacing: -0.264,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Adding Color to your space helps you to identify it easy when you search for it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff5f5f5f),
                      letterSpacing: -0.176,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // Selected color preview (large 84x84 square)
                if (_selectedColor != null) ...[
                  Container(
                    width: 84,
                    height: 84,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Color(
                        int.parse(
                            _selectedColor!.replaceFirst('#', '0xFF')),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],

                // Color grid (14 colors, 2 rows × 7 columns)
                _buildColorGrid(),

                const Spacer(flex: 3),

                // Create button (changes text based on selection)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isCreating
                        ? null
                        : (_selectedColor == null
                            ? null
                            : () => _handleCreate(context, ref)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor != null
                          ? const Color(0xff0d9488)
                          : Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _selectedColor != null
                                ? 'Save and finish'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build color grid (2 rows × 7 columns)
  ///
  /// Each color is a 32x32 rounded square with 16px spacing.
  /// Tapping a color updates selectedColor state.
  Widget _buildColorGrid() {
    return Column(
      children: [
        // Row 1 (first 7 colors)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: spaceColors
              .take(7)
              .map((color) => _buildColorOption(color))
              .toList(),
        ),

        const SizedBox(height: 16),

        // Row 2 (last 7 colors)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: spaceColors
              .skip(7)
              .map((color) => _buildColorOption(color))
              .toList(),
        ),
      ],
    );
  }

  /// Build individual color option (32x32 square)
  Widget _buildColorOption(String color) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedColor = color);
      },
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
          borderRadius: BorderRadius.circular(4),
          // Optional: Add border for selected state (not in Figma, but could be useful)
          // border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}

/// 🎓 Learning Summary: Bottom Sheet UI Pattern
///
/// **What is a Bottom Sheet?**
/// A modal panel that slides up from the bottom of the screen.
/// Used for short, focused tasks like creating a space or picking options.
///
/// **showModalBottomSheet vs showDialog:**
/// - Bottom sheet: Feels native, follows material design, user can dismiss by dragging
/// - Dialog: Centered, requires button tap to dismiss, more formal
///
/// **PageView for Multi-Step Flows:**
/// ```dart
/// PageView(
///   controller: PageController(),
///   physics: NeverScrollableScrollPhysics(), // Disable swipe
///   children: [Page1(), Page2()],
/// )
/// ```
///
/// Why PageView?
/// - Smooth animated transitions between steps
/// - Can go forward AND backward easily
/// - Each page maintains its own state
/// - Built-in swipe (disabled here for controlled navigation)
///
/// **Auto-Focus Pattern:**
/// ```dart
/// TextField(autofocus: true)
/// ```
///
/// Benefits:
/// - Keyboard opens immediately when sheet appears
/// - User can start typing right away
/// - Better UX - one less tap needed
///
/// **Conditional Rendering Pattern:**
/// ```dart
/// if (condition) ...[
///   Widget1(),
///   Widget2(),
/// ]
/// ```
///
/// The `...` (spread operator) unwraps the list, so widgets are added directly
/// to the parent's children list. Alternative to ternary operators for multiple widgets.
///
/// **Color Hex to Flutter Color:**
/// ```dart
/// Color(int.parse('#7cfec4'.replaceFirst('#', '0xFF')))
/// ```
///
/// Breakdown:
/// - Remove '#' from hex string
/// - Add '0xFF' prefix (alpha channel = fully opaque)
/// - Parse as int
/// - Convert to Color
///
/// **Next:**
/// Add createSpace method to SpacesProvider to handle the actual space creation.
