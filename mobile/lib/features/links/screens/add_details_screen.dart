library;

/// Add Details Screen
///
/// Tabbed bottom sheet for adding optional details to saved link.
///
/// Design from Figma:
/// - Gradient background continues from success screen
/// - Bottom sheet with rounded top corners
/// - 3 tabs: Tag / Note / Space
/// - Tab content changes smoothly
/// - "Done" button at bottom
///
/// Tabs:
/// 1. Tag - Autocomplete field for adding tags
/// 2. Note - Text area for personal notes
/// 3. Space - List of spaces with selection

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/links/providers/add_link_provider.dart';
import 'package:mobile/features/links/widgets/tag_picker_content.dart';
import 'package:mobile/features/spaces/providers/space_provider.dart';
import 'package:mobile/features/tags/providers/tag_provider.dart';

class AddDetailsScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;

  /// Optional: Pre-select a space when adding details
  ///
  /// When adding a link from a Space Detail Screen, this will be the space ID.
  /// The link will be automatically assigned to this space.
  final String? initialSpaceId;

  /// Optional: Scroll controller from parent DraggableScrollableSheet
  ///
  /// When provided, enables swipe-to-expand/collapse functionality.
  /// The parent DraggableScrollableSheet passes this to enable smooth scrolling
  /// and dragging behavior.
  final ScrollController? scrollController;

  const AddDetailsScreen({
    super.key,
    required this.onDone,
    this.initialSpaceId,
    this.scrollController,
  });

  @override
  ConsumerState<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends ConsumerState<AddDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes to update icon colors
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update icon colors
    });

    // Pre-select space if initialSpaceId is provided
    //
    // We use addPostFrameCallback to ensure the provider is ready
    // before we try to update it. Calling ref.read() directly in
    // initState can cause issues because the widget tree isn't fully built yet.
    if (widget.initialSpaceId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addLinkProvider.notifier)
            .updateSpace(widget.initialSpaceId);
      });
    }

    // Note: We don't initialize _noteController here because
    // ref.read() in initState can cause issues. Instead, we'll
    // initialize it in the first build when the note field is rendered.
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Build SVG icon with dynamic color based on tab selection
  ///
  /// Returns an SVG icon that changes color:
  /// - Teal (AnchorColors.anchorTeal) when tab is selected
  /// - Light gray (Colors.grey[600]) when tab is not selected
  Widget _buildTabIcon(String assetPath, int tabIndex) {
    final isSelected = _tabController.index == tabIndex;
    final color = isSelected ? AnchorColors.anchorTeal : Colors.grey[600];

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        color!,
        BlendMode.srcIn, // This tints the SVG with the specified color
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addLinkState = ref.watch(addLinkProvider);
    final addLinkNotifier = ref.read(addLinkProvider.notifier);
    final spacesAsync = ref.watch(spacesProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA8FF78),
            Color(0xFF78AFFF),
          ],
        ),
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
          children: [
            // Scrollable content (handle, tabs, tab content)
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                children: [
                  // Drag handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AnchorColors.anchorTeal,
                    labelColor: AnchorColors.anchorTeal,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        icon: _buildTabIcon('assets/images/tags.svg', 0),
                        text: 'Tag',
                      ),
                      Tab(
                        icon: _buildTabIcon('assets/images/note.svg', 1),
                        text: 'Note',
                      ),
                      Tab(
                        icon: _buildTabIcon('assets/images/Spaces icon.svg', 2),
                        text: 'Space',
                      ),
                    ],
                  ),

                  // Tab Content (flexible height based on content)
                  Flexible(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Tab 1: Tags
                        _buildTagTab(addLinkNotifier),

                        // Tab 2: Note
                        _buildNoteTab(addLinkNotifier),

                        // Tab 3: Space
                        _buildSpaceTab(spacesAsync, addLinkState, addLinkNotifier),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fixed Done Button at bottom
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: addLinkState.isSaving
                      ? null
                      : () async {
                          await addLinkNotifier.saveDetails();
                          widget.onDone();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AnchorColors.anchorTeal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: addLinkState.isSaving
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagTab(AddLinkNotifier notifier) {
    final addLinkState = ref.watch(addLinkProvider);
    final tagsAsync = ref.watch(tagsProvider);

    return tagsAsync.when(
      // Show loading spinner while fetching tags
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AnchorColors.anchorTeal,
        ),
      ),

      // Show error message if fetching fails
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading tags: $error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),

      // Show TagPickerContent with all available tags
      data: (availableTags) => TagPickerContent(
        availableTags: availableTags,
        selectedTagIds: addLinkState.selectedTagIds,
        onTagsChanged: (selectedTagIds) {
          // Update addLinkProvider when tags change
          notifier.updateTags(selectedTagIds);
        },
      ),
    );
  }

  Widget _buildNoteTab(AddLinkNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADD WHY YOU SAVED THIS LINK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            autofocus: true,
            maxLines: 8,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: '| Start typing',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AnchorColors.anchorTeal, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AnchorColors.anchorTeal, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AnchorColors.anchorTeal, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (value) => notifier.updateNote(value.isEmpty ? null : value),
          ),
        ],
      ),
    );
  }

  Widget _buildSpaceTab(
    AsyncValue<List<dynamic>> spacesAsync,
    AddLinkState state,
    AddLinkNotifier notifier,
  ) {
    return spacesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (spaces) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECT SPACE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: spaces.length,
                  itemBuilder: (context, index) {
                    final space = spaces[index];
                    final isSelected = state.spaceId == space.id;

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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AnchorColors.anchorTeal)
                            : null,
                        onTap: () {
                          notifier.updateSpace(isSelected ? null : space.id);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
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
