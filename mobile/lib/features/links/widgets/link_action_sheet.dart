library;

/// LinkActionSheet Widget
///
/// Bottom sheet with 4 action items that appears when user long-presses a link card.
///
/// Actions:
/// 1. Copy to clipboard - Copy link URL
/// 2. Add Tag - Open tag picker
/// 3. Add to Space / Remove from Space - Conditional based on link.spaceId
/// 4. Delete Link - Show confirmation dialog + undo option
///
/// Design from Figma:
/// - Grabber handle at top (36×5px, rounded, gray)
/// - Translucent background with blur effect
/// - Action items: 24px border radius, white background
/// - Delete action: Pink background (#ffe7eb), red text (#e70c31)
/// - Icon size: 24×24px
/// - Spacing: 16px between items, 8px icon-to-text gap

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/design_system/design_system.dart';
import '../services/link_service.dart';

class LinkActionSheet extends StatelessWidget {
  final LinkWithTags linkWithTags;
  final VoidCallback onCopyToClipboard;
  final VoidCallback onAddTag;
  final VoidCallback onSpaceAction;
  final VoidCallback onDelete;

  const LinkActionSheet({
    super.key,
    required this.linkWithTags,
    required this.onCopyToClipboard,
    required this.onAddTag,
    required this.onSpaceAction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine space action text and icon based on link's space membership
    final isInSpace = linkWithTags.link.spaceId != null;
    final spaceActionText = isInSpace ? 'Remove from Space' : 'Add to Space';
    final spaceActionIcon =
        isInSpace ? 'assets/images/remove-circle.svg' : 'assets/images/Spaces icon.svg';

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4), // Translucent background
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
            color: Colors.white.withOpacity(0.9),
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

              // Action items
              _buildActionItem(
                icon: 'assets/images/copy-01.svg',
                text: 'Copy to clipboard',
                onTap: onCopyToClipboard,
              ),
              const SizedBox(height: 16),

              _buildActionItem(
                icon: 'assets/images/tags.svg',
                text: 'Add Tag',
                onTap: onAddTag,
              ),
              const SizedBox(height: 16),

              _buildActionItem(
                icon: spaceActionIcon,
                text: spaceActionText,
                onTap: onSpaceAction,
              ),
              const SizedBox(height: 16),

              // Delete action (special styling)
              _buildDeleteAction(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build grabber handle at top of sheet
  ///
  /// Small rounded bar that indicates sheet is draggable.
  /// Design: 36×5px, rounded, gray color
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

  /// Build standard action item
  ///
  /// White background, rounded corners, icon on left, text on right.
  Widget _buildActionItem({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xff0a090d), // Primary text color
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8), // Icon-to-text gap

            // Text
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400, // Regular weight
                  color: Color(0xff0a090d), // Primary text color
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
  /// Special styling: Pink background (#ffe7eb), red text/icon (#e70c31).
  /// This is a destructive action, so it needs visual distinction.
  Widget _buildDeleteAction() {
    return GestureDetector(
      onTap: onDelete,
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
        ),
        child: Row(
          children: [
            // Delete icon
            SvgPicture.asset(
              'assets/images/delete-02.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xffe70c31), // Red color
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8), // Icon-to-text gap

            // Text
            const Expanded(
              child: Text(
                'Delete Link',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400, // Regular weight
                  color: Color(0xffe70c31), // Red color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
