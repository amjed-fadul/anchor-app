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
import 'package:mobile/design_system/design_system.dart';
import 'package:mobile/features/links/providers/add_link_provider.dart';
import 'package:mobile/features/spaces/providers/space_provider.dart';
import 'package:mobile/features/tags/services/tag_service.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

class AddDetailsScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;

  const AddDetailsScreen({
    super.key,
    required this.onDone,
  });

  @override
  ConsumerState<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends ConsumerState<AddDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  bool _isCreatingTags = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Note: We don't initialize _noteController here because
    // ref.read() in initState can cause issues. Instead, we'll
    // initialize it in the first build when the note field is rendered.
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// Parse tag input and create/get tags
  Future<void> _handleTagInput(String input) async {
    if (input.trim().isEmpty) {
      ref.read(addLinkProvider.notifier).updateTags([]);
      return;
    }

    setState(() => _isCreatingTags = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final tagService = ref.read(tagServiceProvider);

      // Split by comma or newline
      final tagNames = input
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Create or get tags
      final tagIds = <String>[];
      for (final name in tagNames) {
        final tag = await tagService.getOrCreateTag(
          userId: user.id,
          name: name,
        );
        tagIds.add(tag.id);
      }

      // Update state with tag IDs
      ref.read(addLinkProvider.notifier).updateTags(tagIds);
    } catch (e) {
      print('Error creating tags: $e');
    } finally {
      setState(() => _isCreatingTags = false);
    }
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
              tabs: const [
                Tab(
                  icon: Icon(Icons.label_outline, size: 20),
                  text: 'Tag',
                ),
                Tab(
                  icon: Icon(Icons.edit_note_outlined, size: 20),
                  text: 'Note',
                ),
                Tab(
                  icon: Icon(Icons.folder_outlined, size: 20),
                  text: 'Space',
                ),
              ],
            ),

            // Tab Content
            // Using Flexible instead of Expanded to avoid layout conflicts
            // with the modal bottom sheet's DraggableScrollableSheet
            Flexible(
              child: TabBarView(
                controller: _tabController,
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

            // Done Button
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ADD TAGS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagController,
            autofocus: true,
            onChanged: _handleTagInput,
            decoration: InputDecoration(
              hintText: '| Start typing tags ....',
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: _isCreatingTags
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Separate tags with commas or press Enter',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
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
                            color: _getSpaceColor(space.name),
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

  Color _getSpaceColor(String spaceName) {
    // Match colors from Figma design
    switch (spaceName.toLowerCase()) {
      case 'unread':
        return const Color(0xFF9747FF); // Purple
      case 'reference':
        return const Color(0xFFFF4747); // Red
      case 'design inspiration':
        return const Color(0xFF47FFFF); // Cyan
      case 'articles':
        return const Color(0xFFB8B8B8); // Gray
      case 'test':
        return const Color(0xFF000000); // Black
      default:
        return AnchorColors.anchorTeal;
    }
  }
}
