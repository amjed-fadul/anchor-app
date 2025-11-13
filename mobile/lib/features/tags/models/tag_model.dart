library;

/// Tag Model
///
/// Represents a tag/label for organizing links in the Anchor App.
///
/// Think of tags like colored stickers or labels:
/// - "Design" tag for design-related links (pink color)
/// - "React" tag for React tutorials (purple color)
/// - "Inspiration" tag for inspirational content (blue color)
///
/// Why we need tags:
/// - Organization: Group links by topic or category
/// - Visual Distinction: Each tag has a unique color
/// - Quick Filtering: Find all links with a specific tag
/// - User-Created: Users can create their own tags
///
/// Real-World Analogy:
/// Think of physical sticky notes or labels you put on folders.
/// Each label has a color and name to help you organize and find things quickly.

class Tag {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// ID of the user who created this tag
  final String userId;

  /// The tag name/label
  /// Examples: "Design", "React", "Inspiration", "Work", "Personal"
  final String name;

  /// Hex color code for visual distinction
  /// Examples: "#f42cff" (pink), "#682cff" (purple), "#075a52" (teal)
  final String color;

  /// When this tag was created
  final DateTime createdAt;

  /// Constructor
  Tag({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  /// fromJson - Convert Supabase JSON to Tag object
  ///
  /// When we fetch tags from Supabase, we get data like:
  /// {
  ///   "id": "tag-123",
  ///   "user_id": "user-456",
  ///   "name": "Design",
  ///   "color": "#f42cff",
  ///   "created_at": "2025-11-13T09:00:00Z"
  /// }
  ///
  /// This factory constructor converts that JSON map to a Tag object.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// toJson - Convert Tag object to JSON for Supabase
  ///
  /// When we create or update a tag in Supabase, we need to convert
  /// the Dart object back to JSON format that Supabase expects.
  ///
  /// Example usage:
  /// ```dart
  /// final tag = Tag(...);
  /// await supabase.from('tags').insert(tag.toJson());
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// copyWith - Create a modified copy of this Tag
  ///
  /// Why immutability?
  /// Instead of changing the existing object, we create a NEW object
  /// with the changes. This prevents bugs and makes state management easier.
  ///
  /// Example usage:
  /// ```dart
  /// final originalTag = Tag(name: "Design", color: "#f42cff", ...);
  /// final updatedTag = originalTag.copyWith(name: "UI Design");
  /// // originalTag.name is still "Design"
  /// // updatedTag.name is "UI Design"
  /// ```
  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    DateTime? createdAt,
  }) {
    return Tag(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// isValidColor - Check if color is a valid hex color
  ///
  /// Why this matters:
  /// In the UI, we use the color to display colored tag badges.
  /// Invalid colors would cause crashes or look broken.
  ///
  /// Valid formats:
  /// - #000000 (black)
  /// - #FFFFFF (white)
  /// - #f42cff (pink)
  ///
  /// Invalid formats:
  /// - #fff (too short)
  /// - #gggggg (invalid hex characters)
  /// - not-a-color (no # prefix)
  bool isValidColor() {
    // Regex pattern for hex color: #RRGGBB
    // ^ = start of string
    // # = literal hash
    // [0-9A-Fa-f]{6} = exactly 6 hex digits (0-9, A-F, case insensitive)
    // $ = end of string
    final hexColorPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return hexColorPattern.hasMatch(color);
  }

  /// Equality operator
  ///
  /// Two tags are equal if they have the same ID.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id;
  }

  /// Hash code for use in collections (Sets, Maps)
  @override
  int get hashCode => id.hashCode;

  /// toString for debugging
  ///
  /// When you print a Tag object, you'll see:
  /// Tag(id: tag-123, name: Design, color: #f42cff)
  ///
  /// This is super helpful when debugging!
  @override
  String toString() {
    return 'Tag(id: $id, name: $name, color: $color)';
  }
}

/// 🎓 Learning Summary: Tags in Action
///
/// **UI Example:**
/// When displaying a link card in the home screen, tags appear as colored badges:
///
/// ```
/// ┌─────────────────────────────────┐
/// │ [Design] [Apple] [Headset]      │ ← Tag badges (colored)
/// │                                 │
/// │ Apple Vision Pro - Release      │ ← Link title
/// │ Check this out later            │ ← User note
/// └─────────────────────────────────┘
/// ```
///
/// **How Tags are Used:**
/// 1. **Visual Organization**: Colors help users quickly identify topic
/// 2. **Filtering**: Click a tag to see all links with that tag
/// 3. **Searching**: Search for links by tag name
/// 4. **User-Created**: Users can create custom tags as needed
///
/// **Tag Colors in Figma Design:**
/// - Teal: #075a52 (primary accent)
/// - Purple: #682cff
/// - Pink: #f42cff
/// - Blue: #2c4cff
///
/// **Database Schema:**
/// - tags table: Stores all tags with id, user_id, name, color
/// - link_tags table: Junction table linking links to tags (many-to-many)
///
/// **Next:**
/// Now that we have the Tag model, we can:
/// 1. Fetch tags from Supabase
/// 2. Display tags as colored badges in the UI
/// 3. Allow users to filter links by tag
/// 4. Create new tags when saving links
