library;

/// TagPickerContent Widget
///
/// Reusable tag picker UI that can be embedded anywhere or used in modal sheets.
///
/// Features:
/// - Search/filter tags by name (case-insensitive)
/// - Multi-select with checkboxes
/// - Create new tags on the fly
/// - Shows selected tags as dismissible chips
/// - Real-time updates via callback
///
/// This component is the core UI extracted from TagPickerSheet.
/// It can be used:
/// 1. Embedded directly in AddDetailsScreen Tag tab
/// 2. Inside TagPickerSheet modal (for editing existing links)
///
/// Real-World Analogy:
/// Like a Gmail label picker widget that you can drop anywhere in your app -
/// same functionality whether it's in a modal or embedded in a page.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/tags/models/tag_model.dart';
import 'package:mobile/features/tags/services/tag_service.dart';
import 'package:mobile/features/tags/providers/tag_provider.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

class TagPickerContent extends ConsumerStatefulWidget {
  /// All available tags to choose from
  final List<Tag> availableTags;

  /// Currently selected tag IDs
  final List<String> selectedTagIds;

  /// Callback when tag selection changes (add or remove)
  ///
  /// Called immediately when user checks/unchecks a tag or creates a new one.
  /// The parent is responsible for updating its state.
  final Function(List<String> tagIds) onTagsChanged;

  /// Optional scroll controller for embedding in scrollable views
  ///
  /// When used inside a DraggableScrollableSheet, pass the scrollController
  /// to enable swipe-to-dismiss and scroll behavior.
  final ScrollController? scrollController;

  const TagPickerContent({
    super.key,
    required this.availableTags,
    required this.selectedTagIds,
    required this.onTagsChanged,
    this.scrollController,
  });

  @override
  ConsumerState<TagPickerContent> createState() => _TagPickerContentState();
}

class _TagPickerContentState extends ConsumerState<TagPickerContent> {
  late List<String> _selectedTagIds;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize selected tags from widget prop
    _selectedTagIds = List.from(widget.selectedTagIds);
  }

  @override
  void didUpdateWidget(TagPickerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local state if parent changes selectedTagIds
    if (oldWidget.selectedTagIds != widget.selectedTagIds) {
      _selectedTagIds = List.from(widget.selectedTagIds);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter tags based on search query (case-insensitive)
  List<Tag> get _filteredTags {
    if (_searchQuery.isEmpty) {
      return widget.availableTags;
    }

    return widget.availableTags.where((tag) {
      return tag.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// Toggle tag selection
  ///
  /// Immediately calls onTagsChanged to notify parent of the change.
  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });

    // Notify parent immediately
    widget.onTagsChanged(_selectedTagIds);
  }

  /// Check if tag is selected
  bool _isTagSelected(String tagId) {
    return _selectedTagIds.contains(tagId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          _buildSearchField(),

          // Selected tags as dismissible chips
          if (_selectedTagIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSelectedTagsChips(),
            const SizedBox(height: 12),
          ],

          // Tag list or empty state (no extra spacing when no tags selected)
          Expanded(
            child: widget.availableTags.isEmpty
                ? _buildEmptyState()
                : _buildTagList(),
          ),
        ],
      ),
    );
  }

  /// Build search field with light beige background
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Add a tag',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xfff5f5f0), // Light beige
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// Build selected tags as dismissible chips
  ///
  /// Shows chips for all currently selected tags below the search field.
  /// Each chip has an X button to remove the tag from selection.
  Widget _buildSelectedTagsChips() {
    // Get the actual Tag objects for selected IDs
    final selectedTags = widget.availableTags
        .where((tag) => _selectedTagIds.contains(tag.id))
        .toList();

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: selectedTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xffe8e8e8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tag.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff0a090d),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _toggleTag(tag.id),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xff6a6770),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build list of tags with simple rows
  Widget _buildTagList() {
    final filteredTags = _filteredTags;

    // Check if we should show "Create tag" suggestion
    final showCreateSuggestion = _searchQuery.trim().isNotEmpty &&
        !filteredTags.any((tag) =>
            tag.name.toLowerCase() == _searchQuery.trim().toLowerCase());

    return ListView.separated(
      // Conditional scrolling:
      // - If scrollController provided (AddDetailsScreen): Parent scrolls, disable child
      // - If no scrollController (TagPickerSheet): This list scrolls itself
      shrinkWrap: true,
      physics: widget.scrollController != null
          ? const NeverScrollableScrollPhysics() // Parent handles scroll
          : null, // Default scrolling behavior
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: filteredTags.length + (showCreateSuggestion ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
        color: Color(0xffe8e8e8),
      ),
      itemBuilder: (context, index) {
        // Show "Create tag" suggestion at top if needed
        if (showCreateSuggestion && index == 0) {
          return _buildCreateTagSuggestion(_searchQuery.trim());
        }

        // Adjust index if we showed create suggestion
        final tagIndex = showCreateSuggestion ? index - 1 : index;
        final tag = filteredTags[tagIndex];
        final isSelected = _isTagSelected(tag.id);

        return _buildTagListItem(tag, isSelected);
      },
    );
  }

  /// Build a single tag list item (tag icon + name + checkmark if selected)
  Widget _buildTagListItem(Tag tag, bool isSelected) {
    return InkWell(
      onTap: () => _toggleTag(tag.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Tag icon
            SvgPicture.asset(
              'assets/images/tags.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),

            // Tag name
            Expanded(
              child: Text(
                tag.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff0a090d),
                ),
              ),
            ),

            // Checkmark if selected
            if (isSelected)
              const Icon(
                Icons.check,
                color: AnchorColors.anchorTeal,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Build "Create 'tag name'" suggestion row
  Widget _buildCreateTagSuggestion(String tagName) {
    return InkWell(
      onTap: () => _createAndSelectTag(tagName),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            // Plus icon
            const Icon(
              Icons.add_circle_outline,
              color: AnchorColors.anchorTeal,
              size: 24,
            ),
            const SizedBox(width: 16),

            // "Create 'name'" text
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff0a090d),
                  ),
                  children: [
                    const TextSpan(text: 'Create '),
                    TextSpan(
                      text: '"$tagName"',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AnchorColors.anchorTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a new tag and add it to selection
  ///
  /// This method:
  /// 1. Gets current user ID
  /// 2. Creates tag via TagService (or gets existing if name exists)
  /// 3. Adds tag to selection
  /// 4. Refreshes tags provider to show new tag in list
  /// 5. Clears search field
  /// 6. Notifies parent via onTagsChanged callback
  Future<void> _createAndSelectTag(String tagName) async {
    try {
      // Get current user
      final user = ref.read(currentUserProvider);
      if (user == null) {
        debugPrint('🔴 [TagPickerContent] No user logged in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not logged in'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get tag service
      final tagService = ref.read(tagServiceProvider);

      // Create or get existing tag
      final tag = await tagService.getOrCreateTag(
        userId: user.id,
        name: tagName,
      );

      // Add to selection if not already selected
      setState(() {
        if (!_selectedTagIds.contains(tag.id)) {
          _selectedTagIds.add(tag.id);
        }
        // Clear search field
        _searchQuery = '';
        _searchController.clear();
      });

      // Notify parent of change
      widget.onTagsChanged(_selectedTagIds);

      // Refresh tags provider to show new tag in list
      await ref.read(tagsProvider.notifier).refresh();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tag "$tagName" created and selected'),
            backgroundColor: AnchorColors.anchorTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 [TagPickerContent] Error creating tag: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating tag: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Build empty state when no tags exist
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/tags.svg',
              width: 64,
              height: 64,
              colorFilter: ColorFilter.mode(
                Colors.grey[400]!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No tags yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first tag using the search field above',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
