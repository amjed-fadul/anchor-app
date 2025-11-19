library;

/// TagPickerSheet Widget
///
/// Modal bottom sheet for editing tags on existing links.
///
/// This is a thin wrapper around TagPickerContent that provides:
/// - Modal sheet styling (container, grabber handle, title)
/// - "Done" button to confirm selection
/// - Async handling for database updates
///
/// The actual tag selection UI is handled by TagPickerContent,
/// which can be reused in other contexts (like AddDetailsScreen).
///
/// Real-World Analogy:
/// Like Gmail's label picker modal - opens as a sheet, lets you
/// select/create labels, then closes when you click "Done".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/tags/models/tag_model.dart';
import 'package:mobile/features/links/widgets/tag_picker_content.dart';

class TagPickerSheet extends ConsumerStatefulWidget {
  final List<Tag> availableTags;
  final List<String> selectedTagIds;
  final Function(List<String> tagIds) onDone;

  const TagPickerSheet({
    super.key,
    required this.availableTags,
    required this.selectedTagIds,
    required this.onDone,
  });

  @override
  ConsumerState<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<TagPickerSheet> {
  late List<String> _selectedTagIds;
  bool _isUpdating = false; // Track if we're currently updating tags

  @override
  void initState() {
    super.initState();
    // Initialize selected tags from widget prop
    _selectedTagIds = List.from(widget.selectedTagIds);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber handle
            const SizedBox(height: 12),
            _buildGrabberHandle(),
            const SizedBox(height: 16),

            // Title
            _buildTitle(),
            const SizedBox(height: 16),

            // Tag picker content (search, tags, create)
            Flexible(
              child: TagPickerContent(
                availableTags: widget.availableTags,
                selectedTagIds: _selectedTagIds,
                onTagsChanged: (selectedTagIds) {
                  // Update local state when tags change
                  setState(() {
                    _selectedTagIds = selectedTagIds;
                  });
                },
              ),
            ),

            // Done button
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  /// Build grabber handle at top of sheet
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

  /// Build title "Edit Tags"
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Edit Tags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xff0a090d),
          ),
        ),
      ),
    );
  }

  /// Build Done button at bottom
  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          // Disable button while updating
          onPressed: _isUpdating
              ? null
              : () async {
                  // Capture navigator before async gap
                  final navigator = Navigator.of(context);

                  // Show loading state
                  setState(() => _isUpdating = true);

                  // Wait for database update and provider refresh to complete
                  await widget.onDone(_selectedTagIds);

                  // Close sheet AFTER update completes
                  if (mounted) {
                    navigator.pop();
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AnchorColors.anchorTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
