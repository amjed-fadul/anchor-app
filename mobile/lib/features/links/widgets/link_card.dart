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
import 'package:url_launcher/url_launcher.dart';
import '../services/link_service.dart' show LinkWithTags;
import '../providers/link_provider.dart';
import '../providers/links_by_space_provider.dart';
import '../../tags/widgets/tag_badge.dart';
import '../../tags/providers/tag_provider.dart';
import '../../spaces/providers/space_provider.dart';
import 'link_action_sheet.dart';
import 'tag_picker_sheet.dart';
import 'space_picker_sheet.dart';

class LinkCard extends ConsumerWidget {
  final LinkWithTags linkWithTags;

  const LinkCard({
    super.key,
    required this.linkWithTags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch spaces provider to get space color for the border
    final spacesAsync = ref.watch(spacesProvider);

    // Determine border color based on space assignment
    Color? borderColor;

    // Only add border if link is in a space
    if (linkWithTags.link.spaceId != null) {
      spacesAsync.whenData((spaces) {
        try {
          // Find the space this link belongs to
          final space = spaces.firstWhere(
            (s) => s.id == linkWithTags.link.spaceId,
          );
          // Parse the space's hex color
          borderColor = _parseColor(space.color);
        } catch (e) {
          // Space not found or color parsing failed - no border
          borderColor = null;
        }
      });
    }

    return GestureDetector(
      onTap: () => _openLink(context),
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

            // Colored space indicator stripe (top edge of image)
            if (borderColor != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4.0, // 4px colored stripe
                  decoration: BoxDecoration(
                    color: borderColor,
                  ),
                ),
              ),

            // Tags overlay (top-left)
            if (linkWithTags.tags.isNotEmpty) _buildTagsOverlay(),

            // Description box overlay (bottom-left)
            _buildDescriptionBox(context),
          ],
        ),
      ),
    );
  }

  /// Open link in external browser
  ///
  /// Opens the saved link URL in the user's default browser.
  /// Shows error snackbar if the URL cannot be opened.
  ///
  /// Uses url_launcher package with mode: LaunchMode.externalApplication
  /// to ensure link opens in browser, not in-app webview.
  Future<void> _openLink(BuildContext context) async {
    try {
      final url = Uri.parse(linkWithTags.link.url);

      // Try to launch URL in external browser
      final canLaunch = await canLaunchUrl(url);

      if (canLaunch) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Open in browser, not in-app
        );
      } else {
        // URL cannot be opened (invalid scheme, etc.)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open URL: ${linkWithTags.link.url}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Error parsing or launching URL
      debugPrint('🔴 [LinkCard] Error opening link: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          // Close action sheet first
          Navigator.pop(sheetContext);

          // Check if link is currently in a space
          final isInSpace = linkWithTags.link.spaceId != null;

          if (isInSpace) {
            // Link is in a space → Remove from space
            _showRemoveFromSpaceConfirmation(parentContext, ref);
          } else {
            // Link is not in a space → Add to space
            _showAddToSpaceSheet(parentContext, ref);
          }
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
            debugPrint('🔵 [LinkCard] Delete confirmed, starting optimistic deletion...');
            final startTime = DateTime.now();

            // Show success message immediately (optimistic)
            if (parentContext.mounted) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(
                  content: Text('Link deleted'),
                  backgroundColor: Color(0xff075a52), // Anchor teal
                  duration: Duration(seconds: 2),
                ),
              );
              debugPrint('🟢 [LinkCard] Success snackbar shown immediately');
            }

            // Optimistically delete from UI and database in background
            try {
              // This removes the link from UI immediately, then deletes from DB
              await ref.read(linksWithTagsProvider.notifier).optimisticallyDeleteLink(
                linkWithTags.link.id,
              );

              // Also refresh the space detail screen if link was in a space
              if (linkWithTags.link.spaceId != null) {
                debugPrint('🔵 [LinkCard] Invalidating linksBySpaceProvider for space ${linkWithTags.link.spaceId}');
                ref.invalidate(linksBySpaceProvider(linkWithTags.link.spaceId!));
              }

              final totalTime = DateTime.now().difference(startTime).inMilliseconds;
              debugPrint('🟢 [LinkCard] Total deletion flow completed in ${totalTime}ms');
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
    // Show bottom sheet that handles async states via AsyncValue.when()
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (consumerContext, consumerRef, child) {
          // Watch tags provider - Riverpod handles loading/error/data states
          final tagsAsync = consumerRef.watch(tagsProvider);

          return tagsAsync.when(
            // Loading state: Show spinner inside bottom sheet
            loading: () {
              return _buildLoadingSheet();
            },

            // Error state: Show error message inside bottom sheet
            error: (error, stackTrace) {
              return _buildErrorSheet(error);
            },

            // Data state: Show tag picker with loaded tags
            data: (tags) {
              return TagPickerSheet(
                availableTags: tags,
                selectedTagIds:
                    linkWithTags.tags.map((tag) => tag.id).toList(),
                onDone: (selectedTagIds) async {
                  debugPrint('🔵 [LinkCard] Tag update started...');
                  final startTime = DateTime.now();

                  // Show success feedback immediately (optimistic)
                  if (consumerContext.mounted) {
                    ScaffoldMessenger.of(consumerContext).showSnackBar(
                      const SnackBar(
                        content: Text('Tags updated successfully'),
                        backgroundColor: Color(0xff075a52), // Anchor teal
                        duration: Duration(seconds: 2),
                      ),
                    );
                    debugPrint('🟢 [LinkCard] Success snackbar shown immediately');
                  }

                  // Update link's tags optimistically
                  try {
                    // Get all tags to build updated LinkWithTags
                    final tagsAsync = consumerRef.read(tagsProvider);
                    final allTags = tagsAsync.value ?? [];

                    // Build updated tags list
                    final updatedTags = allTags
                        .where((tag) => selectedTagIds.contains(tag.id))
                        .toList();

                    // Create updated LinkWithTags
                    final updatedLink = LinkWithTags(
                      link: linkWithTags.link,
                      tags: updatedTags,
                    );

                    // This updates the link in UI immediately, then updates DB
                    await consumerRef
                        .read(linksWithTagsProvider.notifier)
                        .optimisticallyUpdateLink(
                          linkId: linkWithTags.link.id,
                          updatedLink: updatedLink,
                        );

                    // Also refresh the space detail screen if link is in a space
                    if (linkWithTags.link.spaceId != null) {
                      debugPrint('🔵 [LinkCard] Invalidating linksBySpaceProvider');
                      consumerRef.invalidate(
                          linksBySpaceProvider(linkWithTags.link.spaceId!));
                    }

                    final totalTime = DateTime.now().difference(startTime).inMilliseconds;
                    debugPrint('🟢 [LinkCard] Total tag update flow completed in ${totalTime}ms');
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

  /// Show Add to Space bottom sheet
  ///
  /// Displays a bottom sheet with list of available spaces for user to select.
  /// After selection, updates the link with the new space assignment.
  void _showAddToSpaceSheet(BuildContext context, WidgetRef ref) {
    // Show bottom sheet that handles async states via AsyncValue.when()
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Consumer(
        builder: (consumerContext, consumerRef, child) {
          // Watch spaces provider - Riverpod handles loading/error/data states
          final spacesAsync = consumerRef.watch(spacesProvider);

          return spacesAsync.when(
            // Loading state: Show spinner inside bottom sheet
            loading: () {
              return _buildLoadingSheet();
            },

            // Error state: Show error message inside bottom sheet
            error: (error, stackTrace) {
              return _buildErrorSheet(error);
            },

            // Data state: Show space picker with loaded spaces
            data: (spaces) {
              return SpacePickerSheet(
                availableSpaces: spaces,
                selectedSpaceId: linkWithTags.link.spaceId,
                onSpaceSelected: (selectedSpaceId) async {
                  // User selected a space - update the link
                  if (selectedSpaceId == null) {
                    // User deselected - close sheet without doing anything
                    Navigator.pop(sheetContext);
                    return;
                  }

                  try {
                    debugPrint('🔵 [LinkCard] Add to space started...');
                    final startTime = DateTime.now();

                    // Close the sheet
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }

                    // Try to get space name for better feedback
                    final spaceName = spaces
                        .firstWhere((s) => s.id == selectedSpaceId)
                        .name;

                    // Show success feedback immediately (optimistic)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "$spaceName"'),
                          backgroundColor: const Color(0xff075a52), // Anchor teal
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      debugPrint('🟢 [LinkCard] Success snackbar shown immediately');
                    }

                    // Create updated link with new space
                    final updatedLink = LinkWithTags(
                      link: linkWithTags.link.copyWith(spaceId: selectedSpaceId),
                      tags: linkWithTags.tags,
                    );

                    // This updates the link in UI immediately, then updates DB
                    await consumerRef
                        .read(linksWithTagsProvider.notifier)
                        .optimisticallyUpdateLink(
                          linkId: linkWithTags.link.id,
                          updatedLink: updatedLink,
                        );

                    final totalTime = DateTime.now().difference(startTime).inMilliseconds;
                    debugPrint('🟢 [LinkCard] Total add to space flow completed in ${totalTime}ms');
                  } catch (e) {
                    debugPrint('🔴 [LinkCard] Error adding link to space: $e');

                    // Close the sheet
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }

                    // Show error feedback
                    if (consumerContext.mounted) {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(
                          content: Text('Error adding to space: $e'),
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

  /// Show Remove from Space confirmation dialog
  ///
  /// Shows a confirmation dialog before removing the link from its current space.
  /// After confirmation, updates the link to remove space assignment (set spaceId to null).
  void _showRemoveFromSpaceConfirmation(BuildContext context, WidgetRef ref) async {
    // Get the space name for better messaging
    final spacesAsync = ref.read(spacesProvider);
    final spaceName = spacesAsync.whenData((spaces) {
      try {
        return spaces.firstWhere((s) => s.id == linkWithTags.link.spaceId).name;
      } catch (e) {
        return 'this space';
      }
    }).value ?? 'this space';

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from Space'),
        content: Text(
          'This link will be removed from "$spaceName". You can add to any space again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff075a52), // Anchor teal
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    // If user confirmed, remove link from space
    if (confirmed == true && context.mounted) {
      debugPrint('🔵 [LinkCard] Remove from space started...');
      final startTime = DateTime.now();

      // Store the original space ID for provider invalidation
      final originalSpaceId = linkWithTags.link.spaceId;

      // Show success message immediately (optimistic)
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from "$spaceName"'),
            backgroundColor: const Color(0xff075a52), // Anchor teal
            duration: const Duration(seconds: 2),
          ),
        );
        debugPrint('🟢 [LinkCard] Success snackbar shown immediately');
      }

      try {
        // Create updated link with no space
        final updatedLink = LinkWithTags(
          link: linkWithTags.link.copyWith(spaceId: null),
          tags: linkWithTags.tags,
        );

        // This updates the link in UI immediately, then updates DB
        await ref
            .read(linksWithTagsProvider.notifier)
            .optimisticallyUpdateLink(
              linkId: linkWithTags.link.id,
              updatedLink: updatedLink,
            );

        // Also refresh the space detail screen if link was in a space
        if (originalSpaceId != null) {
          debugPrint('🔵 [LinkCard] Invalidating linksBySpaceProvider');
          ref.invalidate(linksBySpaceProvider(originalSpaceId));
        }

        final totalTime = DateTime.now().difference(startTime).inMilliseconds;
        debugPrint('🟢 [LinkCard] Total remove from space flow completed in ${totalTime}ms');
      } catch (e) {
        debugPrint('🔴 [LinkCard] Error removing link from space: $e');

        // Show error message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error removing from space: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  /// Parse hex color string to Color object
  ///
  /// Handles hex strings like:
  /// - "#7c3aed" → Color(0xff7c3aed)
  /// - "7c3aed" → Color(0xff7c3aed)
  /// - Invalid → Returns transparent color
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
      // Fallback to transparent if color parsing fails
      debugPrint('⚠️ [LinkCard] Failed to parse space color: $hexColor');
      return Colors.transparent;
    }
  }
}
