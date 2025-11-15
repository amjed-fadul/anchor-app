library;

/// LinkCard Widget - Redesigned to Match Figma Specifications
///
/// Displays saved links with:
/// - Image or gradient placeholder
/// - Tags overlay (top-left on image)
/// - Description box overlay (bottom-left on image) containing:
///   - Title (2 lines max, semibold, black)
///   - Description (2 lines max, regular, gray)
///   - Note (1 line max, regular, teal)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/link_service.dart' show LinkWithTags;
import '../providers/link_provider.dart';
import '../../tags/widgets/tag_badge.dart';
import '../../tags/providers/tag_provider.dart';
import 'link_action_sheet.dart';
import 'tag_picker_sheet.dart';

class LinkCard extends ConsumerWidget {
  final LinkWithTags linkWithTags;

  const LinkCard({
    super.key,
    required this.linkWithTags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onLongPress: () => _showActionSheet(context, ref),
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Image (full width, fills card)
            _buildImage(),

            // Tags overlay (top-left)
            if (linkWithTags.tags.isNotEmpty) _buildTagsOverlay(),

            // Description box overlay (bottom-left)
            _buildDescriptionBox(context),
          ],
        ),
      ),
    );
  }

  /// Show action sheet on long press
  ///
  /// Displays a bottom sheet with actions for this link:
  /// - Copy to clipboard
  /// - Add/Edit Tags
  /// - Add to Space / Remove from Space
  /// - Delete Link
  ///
  /// Provides haptic feedback when sheet opens
  void _showActionSheet(BuildContext context, WidgetRef ref) {
    // Trigger haptic feedback for tactile confirmation
    HapticFeedback.mediumImpact();

    // Capture parent context before showing sheet (will remain valid after sheet closes)
    final parentContext = context;

    // Show modal bottom sheet with actions
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => LinkActionSheet(
        linkWithTags: linkWithTags,
        onCopyToClipboard: () async {
          // Close action sheet first
          Navigator.pop(sheetContext);

          // Copy URL to clipboard
          await Clipboard.setData(ClipboardData(text: linkWithTags.link.url));

          // Show success feedback
          if (parentContext.mounted) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              const SnackBar(
                content: Text('Link copied to clipboard'),
                backgroundColor: Color(0xff075a52), // Anchor teal
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        onAddTag: () {
          // Close action sheet first
          Navigator.pop(sheetContext);

          // Show tag picker sheet
          _showTagPicker(parentContext, ref);
        },
        onSpaceAction: () {
          // TODO: Implement add/remove space
          Navigator.pop(sheetContext);
        },
        onDelete: () async {
          // Close action sheet first
          Navigator.pop(sheetContext);

          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: parentContext,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Delete Link'),
              content: const Text(
                'Are you sure you want to delete this link? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );

          // If user confirmed, delete the link
          if (confirmed == true && parentContext.mounted) {
            try {

              // Get link service
              final linkService = ref.read(linkServiceProvider);

              // Delete the link
              await linkService.deleteLink(linkWithTags.link.id);

              // Refresh the links provider
              await ref.read(linksWithTagsProvider.notifier).refresh();

              // Show success message
              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Link deleted'),
                    backgroundColor: Color(0xff075a52), // Anchor teal
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              debugPrint('🔴 [LinkCard] Error deleting link: $e');

              // Show error message
              if (parentContext.mounted) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting link: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          }
        },
      ),
    );
  }

  /// Show tag picker sheet
  ///
  /// Displays a bottom sheet for selecting/creating tags for this link.
  /// Uses Riverpod's AsyncValue.when() pattern to handle loading/error/data states.
  /// This avoids context.mounted issues with manual dialog management.
  void _showTagPicker(BuildContext context, WidgetRef ref) {
    debugPrint('🔵 [LinkCard] _showTagPicker START');

    // Show bottom sheet that handles async states via AsyncValue.when()
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (consumerContext, consumerRef, child) {
          // Watch tags provider - Riverpod handles loading/error/data states
          final tagsAsync = consumerRef.watch(tagsProvider);

          debugPrint('🔵 [LinkCard] tagsAsync state: ${tagsAsync.runtimeType}');

          return tagsAsync.when(
            // Loading state: Show spinner inside bottom sheet
            loading: () {
              debugPrint('🔵 [LinkCard] Showing loading state');
              return _buildLoadingSheet();
            },

            // Error state: Show error message inside bottom sheet
            error: (error, stackTrace) {
              debugPrint('🔴 [LinkCard] Error state: $error');
              return _buildErrorSheet(error);
            },

            // Data state: Show tag picker with loaded tags
            data: (tags) {
              debugPrint('🟢 [LinkCard] Data state: ${tags.length} tags loaded');
              return TagPickerSheet(
                availableTags: tags,
                selectedTagIds:
                    linkWithTags.tags.map((tag) => tag.id).toList(),
                onDone: (selectedTagIds) async {
                  // Update link's tags via LinkService
                  try {
                    debugPrint(
                        '🔵 [LinkCard] Updating tags: $selectedTagIds');

                    // Get the link service
                    final linkService = consumerRef.read(linkServiceProvider);

                    // Update the link with new tags
                    await linkService.updateLink(
                      linkId: linkWithTags.link.id,
                      tagIds: selectedTagIds,
                    );

                    debugPrint('🟢 [LinkCard] Tags updated, refreshing links');

                    // Refresh the links provider to show updated tags
                    await consumerRef
                        .read(linksWithTagsProvider.notifier)
                        .refresh();

                    // Show success feedback
                    if (consumerContext.mounted) {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Tags updated successfully'),
                          backgroundColor: Color(0xff075a52), // Anchor teal
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('🔴 [LinkCard] Error updating tags: $e');

                    // Show error feedback
                    if (consumerContext.mounted) {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(
                          content: Text('Error updating tags: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  /// Build loading sheet (shown while tags are being fetched)
  Widget _buildLoadingSheet() {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Color(0xff075a52), // Anchor teal
            ),
            SizedBox(height: 16),
            Text(
              'Loading tags...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff6a6770), // Secondary content color
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error sheet (shown if tag fetching fails)
  Widget _buildErrorSheet(Object error) {
    return Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error loading tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff0a090d),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xff6a6770),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build image or gradient placeholder
  Widget _buildImage() {
    final thumbnailUrl = linkWithTags.link.thumbnailUrl;

    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: thumbnailUrl,
        width: double.infinity,
        height: 200, // Fixed height for card
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildGradientPlaceholder(),
        errorWidget: (context, url, error) => _buildGradientPlaceholder(),
      );
    }

    return _buildGradientPlaceholder();
  }

  /// Build gradient placeholder for images
  Widget _buildGradientPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200, // Match image height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff075a52), // Anchor teal
            const Color(0xff054139), // Darker teal
          ],
        ),
      ),
      child: const Icon(
        Icons.link,
        color: Colors.white54,
        size: 40,
      ),
    );
  }

  /// Build tags overlay (top-left corner of image)
  Widget _buildTagsOverlay() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Wrap(
        spacing: 9, // Gap between tags (from Figma)
        runSpacing: 4,
        children: linkWithTags.tags
            .map((tag) => TagBadge(tag: tag))
            .toList(),
      ),
    );
  }

  /// Build description box overlay (bottom-left corner of image)
  Widget _buildDescriptionBox(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use 50% of card width (responsive) as per user request
    final boxWidth = screenWidth * 0.5;

    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: boxWidth,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title (2 lines max, semibold, black)
            _buildTitle(),

            // Description (2 lines max, regular, gray) - if exists
            if (linkWithTags.link.description != null) ...[
              const SizedBox(height: 4),
              _buildDescription(),
            ],

            // Note (1 line max, regular, teal) - if exists
            if (linkWithTags.link.note != null) ...[
              const SizedBox(height: 4),
              _buildNote(),
            ],
          ],
        ),
      ),
    );
  }

  /// Build title text (from metadata)
  Widget _buildTitle() {
    final title = linkWithTags.link.title ?? 'Untitled';

    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600, // Semibold
        fontSize: 13,
        color: Color(0xff0a090d), // Primary content color from Figma
        height: 1.0,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build description text (from metadata)
  Widget _buildDescription() {
    return Text(
      linkWithTags.link.description!,
      style: const TextStyle(
        fontWeight: FontWeight.w400, // Regular
        fontSize: 13,
        color: Color(0xff6a6770), // Secondary content color from Figma
        height: 16 / 13, // Line height 16px / font size 13px
        letterSpacing: -0.14,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build note text (user's personal note)
  Widget _buildNote() {
    return Text(
      linkWithTags.link.note!,
      style: const TextStyle(
        fontWeight: FontWeight.w400, // Regular
        fontSize: 13,
        color: Color(0xff075a52), // Anchor teal color from Figma
        height: 16 / 13, // Line height 16px / font size 13px
        letterSpacing: -0.14,
      ),
      maxLines: 1, // Only 1 line for notes
      overflow: TextOverflow.ellipsis,
    );
  }
}
