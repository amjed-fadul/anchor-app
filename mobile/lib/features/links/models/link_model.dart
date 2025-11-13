library;

/// Link Model
///
/// Represents a saved link/bookmark in the Anchor App.
///
/// Think of this like a bookmark in your browser, but more powerful:
/// - URL: The web address you're saving
/// - Title: The page title (or custom title)
/// - Note: Your personal thoughts about this link
/// - Space: Which folder/category it belongs to
/// - Tags: Labels for organization
/// - Timestamps: When you saved it, last opened it, etc.
///
/// Why we need models:
/// - Type Safety: Dart knows what properties exist and their types
/// - JSON Conversion: Easy to convert between database format and Dart objects
/// - Immutability: Use copyWith() to create modified copies safely
/// - Business Logic: Methods like extractDomain() encapsulate link-related logic

/// Sentinel value for distinguishing "not provided" from "explicitly null"
/// This allows copyWith() to handle nullable parameters correctly
const Object _undefined = Object();

class Link {
  /// Unique identifier (UUID from Supabase)
  final String id;

  /// ID of the user who saved this link
  final String userId;

  /// ID of the space (folder/category) this link belongs to
  final String spaceId;

  /// The actual URL being saved
  final String url;

  /// Title of the link (can be null if not fetched yet)
  /// Usually comes from the <title> tag of the webpage
  final String? title;

  /// User's personal note about this link (nullable)
  /// Example: "Check this out later", "Great tutorial", etc.
  final String? note;

  /// When the user last opened/viewed this link (nullable)
  /// Used to show "recently viewed" or track engagement
  final DateTime? openedAt;

  /// When this link was first saved
  final DateTime createdAt;

  /// When this link was last modified
  final DateTime updatedAt;

  /// Constructor
  ///
  /// We use `required` for non-nullable fields to ensure they're always provided.
  /// Nullable fields (title, note, openedAt) are optional.
  Link({
    required this.id,
    required this.userId,
    required this.spaceId,
    required this.url,
    this.title,
    this.note,
    this.openedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// fromJson - Convert Supabase JSON to Link object
  ///
  /// When we fetch links from Supabase, we get data like:
  /// {
  ///   "id": "123-abc",
  ///   "user_id": "456-def",
  ///   "url": "https://example.com",
  ///   ...
  /// }
  ///
  /// This factory constructor converts that JSON map to a Link object.
  ///
  /// Note: Supabase uses snake_case (user_id), Dart uses camelCase (userId)
  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      spaceId: json['space_id'] as String,
      url: json['url'] as String,
      title: json['title'] as String?,
      note: json['note'] as String?,
      openedAt: json['opened_at'] != null
          ? DateTime.parse(json['opened_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// toJson - Convert Link object to JSON for Supabase
  ///
  /// When we update a link in Supabase, we need to convert the Dart object
  /// back to JSON format that Supabase expects.
  ///
  /// Example usage:
  /// ```dart
  /// final link = Link(...);
  /// await supabase.from('links').update(link.toJson()).eq('id', link.id);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'space_id': spaceId,
      'url': url,
      'title': title,
      'note': note,
      'opened_at': openedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// copyWith - Create a modified copy of this Link
  ///
  /// Why immutability?
  /// Instead of changing the existing object (mutable), we create a NEW object
  /// with the changes. This prevents bugs where modifying one link accidentally
  /// affects another part of the app.
  ///
  /// Example usage:
  /// ```dart
  /// final originalLink = Link(note: "Old note", ...);
  /// final updatedLink = originalLink.copyWith(note: "New note");
  /// // originalLink.note is still "Old note"
  /// // updatedLink.note is "New note"
  /// ```
  ///
  /// To explicitly set a nullable field to null:
  /// ```dart
  /// final linkWithoutNote = link.copyWith(note: null);
  /// // Now linkWithoutNote.note == null
  /// ```
  ///
  /// Real-world analogy:
  /// Think of copying a file instead of editing it in place.
  /// You keep the original safe while working on the copy.
  Link copyWith({
    String? id,
    String? userId,
    String? spaceId,
    String? url,
    Object? title = _undefined,
    Object? note = _undefined,
    Object? openedAt = _undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Link(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      spaceId: spaceId ?? this.spaceId,
      url: url ?? this.url,
      title: title == _undefined ? this.title : title as String?,
      note: note == _undefined ? this.note : note as String?,
      openedAt: openedAt == _undefined ? this.openedAt : openedAt as DateTime?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// extractDomain - Get the domain name from the URL
  ///
  /// Converts:
  /// "https://www.apple.com/newsroom/2023/06/vision-pro/" → "www.apple.com"
  /// "https://github.com/flutter/flutter" → "github.com"
  /// "example.com/page" → "example.com"
  ///
  /// Why?
  /// In the UI, showing the full URL takes too much space.
  /// Showing just the domain makes it easier for users to scan their links.
  ///
  /// Example in UI:
  /// [apple.com]
  /// Apple Vision Pro - Release Date
  /// "Check this out later"
  String extractDomain() {
    try {
      // Add https:// if no protocol is present
      // This allows Uri.parse() to work correctly
      String urlToParse = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        urlToParse = 'https://$url';
      }

      // Parse the URL
      final uri = Uri.parse(urlToParse);

      // Check if host is valid (not empty and doesn't contain spaces)
      // Uri.parse can succeed but produce invalid hosts with URL-encoded characters
      if (uri.host.isNotEmpty && !uri.host.contains('%')) {
        return uri.host;
      }

      // If host is empty or invalid, return original URL
      return url;
    } catch (e) {
      // If URL is invalid or can't be parsed, return the original URL
      // This prevents the app from crashing on malformed URLs
      return url;
    }
  }

  /// Equality operator
  ///
  /// Two links are equal if they have the same ID.
  /// We don't compare all fields because ID is the unique identifier.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Link && other.id == id;
  }

  /// Hash code for use in collections (Sets, Maps)
  @override
  int get hashCode => id.hashCode;

  /// toString for debugging
  ///
  /// When you print a Link object, you'll see:
  /// Link(id: 123-abc, url: https://example.com, title: Example)
  ///
  /// This is super helpful when debugging!
  @override
  String toString() {
    return 'Link(id: $id, url: $url, title: $title, note: $note)';
  }
}

/// 🎓 Learning Summary: What is a Model?
///
/// **Definition:**
/// A model is a Dart class that represents data from your database.
/// It's like a blueprint or template for a specific type of object.
///
/// **Real-World Analogy:**
/// Think of a model like a form:
/// - The form has specific fields (name, email, phone)
/// - Each filled-out form is an instance of that model
/// - The form defines what data is required vs optional
///
/// **Why Models Matter:**
/// 1. **Type Safety**: Compiler catches errors at build time, not runtime
/// 2. **Autocomplete**: Your IDE knows what properties exist
/// 3. **Documentation**: Properties have clear names and types
/// 4. **Validation**: Can add validation logic in one place
/// 5. **Serialization**: Easy conversion between JSON ↔ Dart objects
///
/// **Common Pattern:**
/// - fromJson() - Convert database data TO Dart object
/// - toJson() - Convert Dart object TO database format
/// - copyWith() - Create modified copies immutably
///
/// **Next:**
/// Now that we have the Link model, we can:
/// 1. Fetch links from Supabase and convert them to Link objects
/// 2. Display links in the UI using Link properties
/// 3. Update links and save changes back to Supabase
