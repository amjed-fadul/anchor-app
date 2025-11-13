/// Link Metadata Model
///
/// Data class that holds metadata extracted from a URL.
///
/// What is Metadata?
/// Information ABOUT the web page (not the content itself):
/// - Title: The page title ("Example Domain")
/// - Description: What the page is about
/// - Thumbnail: Preview image for the page
/// - Domain: The website name (example.com)
///
/// Real-World Analogy:
/// Think of metadata like a book cover:
/// - Title = Book title
/// - Description = Back cover summary
/// - Thumbnail = Cover artwork
/// - Domain = Publisher name
///
/// This data makes link cards look good and helps users
/// remember what they saved!

class LinkMetadata {
  /// The page title (from <title> or og:title meta tag)
  final String title;

  /// Short description of the page (from meta description or og:description)
  final String? description;

  /// URL to thumbnail/preview image (from og:image)
  final String? thumbnailUrl;

  /// The domain name extracted from the URL (e.g., "example.com")
  final String domain;

  /// Constructor
  const LinkMetadata({
    required this.title,
    required this.domain,
    this.description,
    this.thumbnailUrl,
  });

  /// Create LinkMetadata from JSON
  ///
  /// Used when parsing data from API responses or database.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'title': 'Example Domain',
  ///   'domain': 'example.com',
  ///   'description': 'Example description',
  ///   'thumbnailUrl': 'https://example.com/image.png',
  /// };
  /// final metadata = LinkMetadata.fromJson(json);
  /// ```
  factory LinkMetadata.fromJson(Map<String, dynamic> json) {
    return LinkMetadata(
      title: json['title'] as String,
      domain: json['domain'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }

  /// Convert LinkMetadata to JSON
  ///
  /// Used when saving to database or sending to API.
  ///
  /// Example:
  /// ```dart
  /// final metadata = LinkMetadata(
  ///   title: 'Example',
  ///   domain: 'example.com',
  /// );
  /// final json = metadata.toJson();
  /// // Returns: {'title': 'Example', 'domain': 'example.com', ...}
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'domain': domain,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  /// Create a copy with some fields replaced
  ///
  /// Useful when you want to update just one field:
  /// ```dart
  /// final updated = original.copyWith(title: 'New Title');
  /// ```
  LinkMetadata copyWith({
    String? title,
    String? description,
    String? thumbnailUrl,
    String? domain,
  }) {
    return LinkMetadata(
      title: title ?? this.title,
      domain: domain ?? this.domain,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }

  /// String representation for debugging
  @override
  String toString() {
    return 'LinkMetadata(title: $title, domain: $domain, '
        'description: $description, thumbnailUrl: $thumbnailUrl)';
  }

  /// Equality comparison
  ///
  /// Two LinkMetadata objects are equal if all fields match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LinkMetadata &&
        other.title == title &&
        other.domain == domain &&
        other.description == description &&
        other.thumbnailUrl == thumbnailUrl;
  }

  /// Hash code for using in Sets/Maps
  @override
  int get hashCode {
    return title.hashCode ^
        domain.hashCode ^
        description.hashCode ^
        thumbnailUrl.hashCode;
  }
}

/// 🎓 Learning Summary: Data Models
///
/// **What is a Data Model?**
/// A blueprint for organizing related data together.
///
/// **Why Use Classes for Data?**
/// Instead of passing around loose variables:
/// ```dart
/// // ❌ BAD: Too many parameters
/// void displayLink(String title, String domain, String? desc, String? thumb) {
///   ...
/// }
/// ```
///
/// Use a class to group related data:
/// ```dart
/// // ✅ GOOD: One parameter, all data together
/// void displayLink(LinkMetadata metadata) {
///   print(metadata.title);
///   print(metadata.domain);
/// }
/// ```
///
/// **Benefits:**
/// 1. **Type Safety:** Compiler catches errors
/// 2. **Organization:** Related data stays together
/// 3. **Readability:** Clear what data represents
/// 4. **Reusability:** Use same model everywhere
///
/// **const Constructor:**
/// ```dart
/// const LinkMetadata({...})
/// ```
///
/// `const` = This object is immutable (can't be changed).
/// Benefits:
/// - Better performance (Flutter can reuse it)
/// - Prevents accidental modifications
/// - Safer in async code
///
/// **factory Constructor:**
/// ```dart
/// factory LinkMetadata.fromJson(Map<String, dynamic> json) {
///   return LinkMetadata(...);
/// }
/// ```
///
/// `factory` = Special constructor that can return existing instances
/// or do processing before creating the object.
///
/// Used for:
/// - Parsing JSON
/// - Caching instances
/// - Conditional object creation
///
/// **Equality (== operator):**
/// By default, Dart compares object references (memory addresses).
/// We override `==` to compare actual field values.
///
/// Example:
/// ```dart
/// final meta1 = LinkMetadata(title: 'Test', domain: 'test.com');
/// final meta2 = LinkMetadata(title: 'Test', domain: 'test.com');
///
/// // Without override: meta1 == meta2 is FALSE (different objects)
/// // With override: meta1 == meta2 is TRUE (same values)
/// ```
///
/// **Next:**
/// Use this model in MetadataService to return structured data.
