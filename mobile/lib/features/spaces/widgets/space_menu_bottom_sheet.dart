library;

/// Space Menu Bottom Sheets
///
/// Contains two bottom sheets for space management:
/// 1. SpaceActionsSheet - Menu with Edit and Delete options
/// 2. EditSpaceSheet - Form to edit space name
///
/// Design from Figma:
/// - Actions Sheet: node-id=100-1063
/// - Edit Sheet: Similar to Create Space but simpler (name only)

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/space_model.dart';
import '../providers/space_provider.dart';

/// Show space actions menu (Edit / Delete)
///
/// This is the first sheet that appears when user taps the menu icon.
void showSpaceActionsSheet(BuildContext context, Space space) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => SpaceActionsSheet(space: space),
  );
}

/// Show edit space sheet
///
/// This appears when user taps "Edit" in the actions menu.
void showEditSpaceSheet(BuildContext context, Space space) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditSpaceSheet(space: space),
  );
}

/// SpaceActionsSheet - Menu with Edit and Delete options
///
/// Simple action list that shows:
/// - Edit (opens EditSpaceSheet)
/// - Delete (disabled for default spaces)
class SpaceActionsSheet extends StatelessWidget {
  final Space space;

  const SpaceActionsSheet({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4), // Translucent background
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur effect
        child: Container(
          padding: const EdgeInsets.only(
            top: 12,
            left: 16,
            right: 16,
            bottom: 32, // Extra bottom padding for safe area
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber handle
              _buildGrabberHandle(),
              const SizedBox(height: 20),

              // Edit action
              _buildEditAction(context),
              const SizedBox(height: 16),

              // Delete action (disabled for default spaces)
              _buildDeleteAction(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Grabber handle at top
  Widget _buildGrabberHandle() {
    return Center(
      child: Container(
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2.5),
        ),
      ),
    );
  }

  /// Build edit action item
  Widget _buildEditAction(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Close current sheet
        Navigator.pop(context);
        // Open edit sheet
        showEditSpaceSheet(context, space);
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 16,
          bottom: 16,
          right: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Edit icon
            const Icon(
              Icons.edit,
              color: Color(0xff0a090d), // Black
              size: 24,
            ),
            const SizedBox(width: 8),

            // Text
            const Expanded(
              child: Text(
                'Edit name',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff0a090d),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build delete action item
  ///
  /// Pink background for default spaces (disabled), white for custom spaces.
  Widget _buildDeleteAction(BuildContext context) {
    final isDefault = space.isDefault;

    return GestureDetector(
      onTap: isDefault
          ? null // Disabled for default spaces
          : () {
              // Close actions sheet
              Navigator.pop(context);
              // Show delete confirmation
              _showDeleteConfirmation(context);
            },
      child: Opacity(
        opacity: isDefault ? 0.5 : 1.0, // Dim if disabled
        child: Container(
          padding: const EdgeInsets.only(
            left: 20,
            top: 16,
            bottom: 16,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffffe7eb), // Pink background
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Delete icon
              SvgPicture.asset(
                'assets/images/delete-02.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Color(0xffe70c31), // Red
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),

              // Text
              Expanded(
                child: Text(
                  isDefault ? 'Cannot delete default space' : 'Delete space',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffe70c31), // Red
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Space'),
        content: Text(
          'Are you sure you want to delete "${space.name}"?\n\n'
          'Links in this space will not be deleted - they will become unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close dialog

                  try {
                    // Delete space
                    await ref.read(spacesProvider.notifier).deleteSpace(space.id);

                    if (context.mounted) {
                      // Navigate back to Spaces screen
                      context.pop();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Space "${space.name}" deleted'),
                          backgroundColor: const Color(0xff0d9488), // Teal
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete space: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xffe70c31)), // Red
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// EditSpaceSheet - Form to edit space name
///
/// Simpler than Create Space - only allows editing the name, not color.
/// Pre-fills the TextField with current space name.
class EditSpaceSheet extends ConsumerStatefulWidget {
  final Space space;

  const EditSpaceSheet({
    super.key,
    required this.space,
  });

  @override
  ConsumerState<EditSpaceSheet> createState() => _EditSpaceSheetState();
}

class _EditSpaceSheetState extends ConsumerState<EditSpaceSheet> {
  late final TextEditingController _nameController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current space name
    _nameController = TextEditingController(text: widget.space.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Update space name
  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();

    // Validation
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Space name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newName == widget.space.name) {
      // No change - just close
      Navigator.pop(context);
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // Update space
      await ref
          .read(spacesProvider.notifier)
          .updateSpace(widget.space.id, name: newName);

      if (context.mounted) {
        // Close sheet
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Space renamed to "$newName"'),
            backgroundColor: const Color(0xff0d9488), // Teal
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() => _isUpdating = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update space: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameController.text.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grabber handle
              Center(
                child: Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                  margin: const EdgeInsets.only(bottom: 24),
                ),
              ),

              // Title
              const Text(
                'Edit Space',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff0a090d),
                ),
              ),
              const SizedBox(height: 24),

              // Space icon (colored square)
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _parseColor(widget.space.color),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Label
              const Text(
                'Space Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff6a6770), // Gray
                ),
              ),
              const SizedBox(height: 8),

              // Text input
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 50,
                onChanged: (_) => setState(() {}), // Rebuild to update button state
                decoration: InputDecoration(
                  hintText: 'Enter space name',
                  filled: true,
                  fillColor: const Color(0xfff5f5f0), // Light gray
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: '', // Hide character counter
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isValid && !_isUpdating ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0d9488), // Teal
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xffc3c3d1), // Gray
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse hex color string to Color object
  Color _parseColor(String hexColor) {
    try {
      String cleanHex = hexColor.replaceAll('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'ff$cleanHex';
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      return const Color(0xff6a6770); // Fallback gray
    }
  }
}
