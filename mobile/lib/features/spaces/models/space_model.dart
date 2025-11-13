library;

/// Space Model
///
/// Represents a "Space" - a folder/collection for organizing links.
///
/// What is a Space?
/// A Space is like a folder on your computer - it groups related links together.
/// Users can create custom spaces or use default ones (Unread, Reference).
///
/// Real-World Analogy:
/// Think of Spaces like folders in your email:
/// - "Inbox" (default folder everyone has)
/// - "Work" (custom folder you created)
/// - "Personal" (another custom folder)
///
/// Every space has a color for visual identification,
/// making it easy to spot where your links are saved.
///
/// Database Schema (from 002_create_spaces_table.sql):
/// - id: UUID primary key
/// - user_id: UUID foreign key
/// - name: TEXT (1-50 chars, unique per user)
/// - color: TEXT (hex color from approved palette)
/// - is_default: BOOLEAN (true for Unread/Reference only)
/// - created_at, updated_at: TIMESTAMPTZ

class Space {
  /// Unique identifier for the space
  final String id;

  /// User who owns this space
  final String userId;

  /// Name of the space (e.g., "Unread", "Work", "Personal")
  final String name;

  /// Hex color code for visual identification (e.g., "#9333EA" for purple)
  final String color;

  /// Whether this is a default space (Unread or Reference)
  /// Default spaces cannot be deleted
  final bool isDefault;

  /// When the space was created
  final DateTime createdAt;

  /// When the space was last updated
  final DateTime updatedAt;

  /// Constructor
  const Space({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Space from JSON (Supabase response)
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "id": "123e4567-e89b-12d3-a456-426614174000",
  ///   "user_id": "user-uuid",
  ///   "name": "Unread",
  ///   "color": "#9333EA",
  ///   "is_default": true,
  ///   "created_at": "2024-01-01T00:00:00.000Z",
  ///   "updated_at": "2024-01-01T00:00:00.000Z"
  /// }
  /// ```
  factory Space.fromJson(Map<String, dynamic> json) {
    return Space(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      isDefault: json['is_default'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Space to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with some fields replaced
  Space copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Space(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'Space(id: $id, name: $name, color: $color, '
        'isDefault: $isDefault)';
  }

  /// Equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Space &&
        other.id == id &&
        other.userId == userId &&
        other.name == name &&
        other.color == color &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Hash code for using in Sets/Maps
  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        name.hashCode ^
        color.hashCode ^
        isDefault.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}

/// 🎓 Learning Summary: Spaces in Anchor App
///
/// **Design Decision: Spaces-Only Model**
/// The original PRD had both a `status` field ('unread'/'reference')
/// AND Spaces, creating conflicts. This was simplified to use ONLY Spaces.
///
/// **Default Spaces:**
/// Every user gets two default spaces automatically created:
/// 1. **Unread** (Purple #9333EA)
///    - For links you haven't read/processed yet
///    - Like an inbox for links
///
/// 2. **Reference** (Red #DC2626)
///    - For important links you want to keep
///    - Like a favorites/starred folder
///
/// **Custom Spaces:**
/// Users can create their own spaces:
/// - "Work" for work-related links
/// - "Recipes" for cooking sites
/// - "Articles" for reading material
/// - Any category they want!
///
/// **Color Coding:**
/// Each space has a color from an approved 14-color palette.
/// Colors help users visually identify where their links are saved:
/// - Purple = Unread
/// - Red = Reference
/// - Blue = Work
/// - Green = Personal
/// - etc.
///
/// **Link → Space Relationship:**
/// - Each link can be in ONE space OR NO space
/// - Links table has optional `space_id` foreign key
/// - If space is deleted, links become unassigned (space_id = null)
/// - Links don't get deleted when space is deleted
///
/// **Database Constraints:**
/// - Space names are 1-50 characters
/// - Space names are unique per user (case-insensitive)
/// - Default spaces cannot be deleted (enforced by database trigger)
/// - User can only see their own spaces (Row Level Security)
///
/// **Next:**
/// Create SpaceService to interact with Supabase spaces table.
