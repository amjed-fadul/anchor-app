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
import 'package:cached_network_image/cached_network_image.dart';
import '../services/link_service.dart';
import '../../tags/widgets/tag_badge.dart';

class LinkCard extends StatelessWidget {
  final LinkWithTags linkWithTags;

  const LinkCard({
    super.key,
    required this.linkWithTags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
