/// LinkCard Widget
///
/// A card component that displays saved links with thumbnails, tags, titles, and notes.
///
/// Think of this like a bookmark card in a physical organizer:
/// - Picture/thumbnail at the top
/// - Colored labels (tags) for categorization
/// - Title describing what it is
/// - Your personal notes about why you saved it
///
/// Real-World Analogy:
/// Like a recipe card in a recipe box, or a product card on a shopping website.
/// Quick visual reference with all important info at a glance.
///
/// Usage:
/// ```dart
/// LinkCard(
///   linkWithTags: LinkWithTags(
///     link: myLink,
///     tags: [tag1, tag2],
///   ),
/// )
/// ```

import 'package:flutter/material.dart';
import '../models/link_model.dart';
import '../services/link_service.dart';
import '../../tags/widgets/tag_badge.dart';

/// LinkCard - Displays a saved link with thumbnail, tags, title, and note
class LinkCard extends StatelessWidget {
  /// The link data with associated tags
  final LinkWithTags linkWithTags;

  const LinkCard({
    super.key,
    required this.linkWithTags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Elevation creates shadow for depth
      // 2.0 = subtle shadow (not too strong)
      elevation: 2.0,

      // Shape with rounded corners
      // 12px radius matches Figma design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // clipBehavior ensures content respects rounded corners
      // Without this, images would have square corners
      clipBehavior: Clip.antiAlias,

      // Column stacks widgets vertically:
      // 1. Image placeholder with tags overlay
      // 2. Padding with title and note
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with tags overlay
          _buildImageSection(),

          // Content section with title and note
          _buildContentSection(),
        ],
      ),
    );
  }

  /// Build the image section with tags overlay
  ///
  /// This creates:
  /// - Colored placeholder container (gradient from teal)
  /// - Tags positioned in top-left corner (overlaying image)
  /// - Fixed aspect ratio for consistent card heights
  Widget _buildImageSection() {
    return SizedBox(
      // Fixed height for image section
      // This ensures all cards have same height in grid
      height: 120,
      width: double.infinity, // Full width of card

      child: Stack(
        // Stack allows overlaying tags on top of image
        children: [
          // Image placeholder (will be replaced with actual image later)
          _buildImagePlaceholder(),

          // Tags overlay (top-left corner)
          if (linkWithTags.tags.isNotEmpty) _buildTagsOverlay(),
        ],
      ),
    );
  }

  /// Build image placeholder
  ///
  /// Why a placeholder?
  /// Links don't always have thumbnail images yet.
  /// We show a colored gradient as placeholder until we implement image loading.
  ///
  /// The gradient:
  /// - Starts with teal (#075a52) - matches app theme
  /// - Fades to darker teal for subtle depth
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Gradient from teal to darker teal
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xff075a52), // Teal (theme color)
            const Color(0xff054139), // Darker teal
          ],
        ),
      ),
      // Center an icon as placeholder content
      child: const Icon(
        Icons.link,
        color: Colors.white54,
        size: 40,
      ),
    );
  }

  /// Build tags overlay
  ///
  /// Why overlay?
  /// From Figma design, tags appear in top-left corner on top of image.
  /// This creates better visual hierarchy and saves space.
  ///
  /// Implementation:
  /// - Positioned widget places tags at specific location
  /// - Wrap widget allows tags to flow horizontally with wrapping
  /// - Semi-transparent background improves tag readability
  Widget _buildTagsOverlay() {
    return Positioned(
      // Position in top-left corner
      top: 8,
      left: 8,
      right: 8, // Add right constraint to prevent overflow

      child: Container(
        // Semi-transparent background for readability
        // Without this, tags might be hard to read on busy images
        decoration: BoxDecoration(
          // Black with 30% opacity
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(4),

        // Wrap allows tags to flow and wrap to next line
        // Like text wrapping, but for widgets
        child: Wrap(
          spacing: 6, // Horizontal space between tags
          runSpacing: 4, // Vertical space when wrapping
          children: linkWithTags.tags
              .map((tag) => TagBadge(tag: tag))
              .toList(),
        ),
      ),
    );
  }

  /// Build content section with title and note
  ///
  /// This creates:
  /// - Title: Bold, black, max 2 lines
  /// - Note: Gray, smaller, max 2 lines (if present)
  /// - Proper spacing between elements
  Widget _buildContentSection() {
    return Padding(
      // Padding around content
      // 12px horizontal, 12px vertical
      padding: const EdgeInsets.all(12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          _buildTitle(),

          // Space between title and note
          if (linkWithTags.link.note != null) const SizedBox(height: 6),

          // Note (if present)
          if (linkWithTags.link.note != null) _buildNote(),
        ],
      ),
    );
  }

  /// Build title text
  ///
  /// Styling:
  /// - Bold font weight for prominence
  /// - Black color for high contrast
  /// - Font size 15 (readable but not too large)
  /// - Max 2 lines with ellipsis for long titles
  Widget _buildTitle() {
    // Get the title, fallback to "Untitled" if null
    final title = linkWithTags.link.title ?? 'Untitled';

    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontSize: 15,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Build note text
  ///
  /// Styling:
  /// - Gray color (secondary information)
  /// - Smaller font size (13) than title
  /// - Max 2 lines with ellipsis for long notes
  /// - This keeps card height consistent
  Widget _buildNote() {
    return Text(
      linkWithTags.link.note!,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 13,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// 🎓 Learning Summary: Complex Widget Composition
///
/// **Widget Building Blocks:**
/// This LinkCard is built from smaller pieces:
/// - Card (container with elevation)
/// - Column (vertical layout)
/// - Stack (overlay tags on image)
/// - Positioned (place tags in corner)
/// - Wrap (tags flow and wrap)
/// - Text (display content)
///
/// **Why Break Into Methods?**
/// Instead of one giant build() method, we split into:
/// - `_buildImageSection()` - Image and tags
/// - `_buildImagePlaceholder()` - Placeholder graphic
/// - `_buildTagsOverlay()` - Tags on image
/// - `_buildContentSection()` - Title and note
/// - `_buildTitle()` - Title text
/// - `_buildNote()` - Note text
///
/// **Benefits:**
/// - Easier to read and understand
/// - Easier to modify one section
/// - Can reuse methods if needed
/// - Better for testing individual pieces
///
/// **Stack Widget Explained:**
/// ```dart
/// Stack(
///   children: [
///     Image(),       // Bottom layer
///     TagsOverlay(), // Top layer (overlays image)
///   ],
/// )
/// ```
///
/// Think of Stack like layers in Photoshop:
/// - First child is bottom layer (image)
/// - Second child is top layer (tags)
/// - Positioned widget controls where top layer appears
///
/// **Positioned Widget:**
/// ```dart
/// Positioned(
///   top: 8,    // 8px from top
///   left: 8,   // 8px from left
///   right: 8,  // 8px from right
///   child: ...,
/// )
/// ```
///
/// Without Positioned, widgets stack in top-left corner.
/// With Positioned, we control exact placement.
///
/// **Wrap Widget:**
/// Like Row, but wraps to next line when out of space:
/// ```
/// [Tag1] [Tag2] [Tag3]
/// [Tag4] [Tag5]
/// ```
///
/// **Responsive Design:**
/// This widget is responsive because:
/// - Uses relative sizing (width: double.infinity)
/// - Text truncates on small screens
/// - Tags wrap to multiple lines if needed
/// - No hardcoded widths (adapts to container)
/// - Fixed height prevents layout shift in grid
///
/// **Color with Opacity:**
/// ```dart
/// Colors.black.withOpacity(0.3)  // 30% black
/// ```
///
/// This creates semi-transparent colors:
/// - 0.0 = fully transparent (invisible)
/// - 0.5 = 50% transparent (half visible)
/// - 1.0 = fully opaque (solid color)
///
/// **Next Steps:**
/// 1. Run tests - they should now PASS (🟢 GREEN)
/// 2. Later: Add real image loading (NetworkImage, CachedNetworkImage)
/// 3. Later: Add tap handling to open links
/// 4. Later: Add long-press for context menu
