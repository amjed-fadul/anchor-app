library;

/// Link Model Tests (TDD - RED)
///
/// Testing the Link model that represents a saved link/bookmark.
///
/// What we're testing:
/// 1. JSON deserialization (fromJson) - Convert Supabase data to Dart object
/// 2. JSON serialization (toJson) - Convert Dart object to JSON
/// 3. copyWith method - Create modified copies immutably
/// 4. Domain extraction - Get domain from URL
///
/// Why TDD (Red-Green-Refactor)?
/// We write tests FIRST (before the model exists), watch them fail (RED),
/// then implement the model to make them pass (GREEN).

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/links/models/link_model.dart';

void main() {
  group('Link Model', () {
    /// Test Data
    /// This simulates what we'd get from Supabase
    final testJson = {
      'id': '123e4567-e89b-12d3-a456-426614174000',
      'user_id': '987e6543-e21b-12d3-a456-426614174999',
      'space_id': '456e7890-e12b-34d5-a678-426614175111',
      'url': 'https://www.apple.com/newsroom/2023/06/apple-vision-pro/',
      'title': 'Apple Vision Pro - Apple Newsroom',
      'note': 'Check this out later',
      'opened_at': '2025-11-13T10:30:00Z',
      'created_at': '2025-11-13T09:00:00Z',
      'updated_at': '2025-11-13T10:30:00Z',
    };

    /// Test #1: fromJson() - Converting Supabase JSON to Link object
    ///
    /// Why this matters:
    /// When we fetch links from Supabase, we get JSON data.
    /// We need to convert it to a Dart Link object we can work with.
    test('fromJson() creates Link from JSON map', () {
      // ACT: Create Link from JSON (this will fail until we implement the model)
      final link = Link.fromJson(testJson);

      // ASSERT: Verify all properties were set correctly
      expect(link.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(link.userId, '987e6543-e21b-12d3-a456-426614174999');
      expect(link.spaceId, '456e7890-e12b-34d5-a678-426614175111');
      expect(link.url, 'https://www.apple.com/newsroom/2023/06/apple-vision-pro/');
      expect(link.title, 'Apple Vision Pro - Apple Newsroom');
      expect(link.note, 'Check this out later');
      expect(link.openedAt, DateTime.parse('2025-11-13T10:30:00Z'));
      expect(link.createdAt, DateTime.parse('2025-11-13T09:00:00Z'));
      expect(link.updatedAt, DateTime.parse('2025-11-13T10:30:00Z'));
    });

    /// Test #2: fromJson() with nullable fields
    ///
    /// Why this matters:
    /// Not all links have titles, notes, or opened_at timestamps.
    /// We need to handle missing/null fields gracefully.
    test('fromJson() handles nullable fields correctly', () {
      // ARRANGE: JSON with missing optional fields
      final jsonWithNulls = {
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'user_id': '987e6543-e21b-12d3-a456-426614174999',
        'space_id': '456e7890-e12b-34d5-a678-426614175111',
        'url': 'https://example.com',
        'title': null, // No title
        'note': null, // No note
        'opened_at': null, // Never opened
        'created_at': '2025-11-13T09:00:00Z',
        'updated_at': '2025-11-13T09:00:00Z',
      };

      // ACT
      final link = Link.fromJson(jsonWithNulls);

      // ASSERT: Nullable fields should be null
      expect(link.title, null);
      expect(link.note, null);
      expect(link.openedAt, null);

      // Required fields should still be set
      expect(link.id, '123e4567-e89b-12d3-a456-426614174000');
      expect(link.url, 'https://example.com');
    });

    /// Test #3: toJson() - Converting Link object back to JSON
    ///
    /// Why this matters:
    /// When we update a link in Supabase, we need to convert
    /// the Dart object back to JSON format.
    test('toJson() converts Link to JSON map', () {
      // ARRANGE: Create a Link object
      final link = Link.fromJson(testJson);

      // ACT: Convert back to JSON
      final json = link.toJson();

      // ASSERT: JSON should match original format
      expect(json['id'], '123e4567-e89b-12d3-a456-426614174000');
      expect(json['user_id'], '987e6543-e21b-12d3-a456-426614174999');
      expect(json['space_id'], '456e7890-e12b-34d5-a678-426614175111');
      expect(json['url'], 'https://www.apple.com/newsroom/2023/06/apple-vision-pro/');
      expect(json['title'], 'Apple Vision Pro - Apple Newsroom');
      expect(json['note'], 'Check this out later');
      expect(json['opened_at'], '2025-11-13T10:30:00.000Z');
      expect(json['created_at'], '2025-11-13T09:00:00.000Z');
      expect(json['updated_at'], '2025-11-13T10:30:00.000Z');
    });

    /// Test #4: copyWith() - Immutable updates
    ///
    /// Why this matters:
    /// When we update a link (e.g., move to different space, add note),
    /// we want to create a NEW object with the changes, not modify the original.
    /// This is the "immutable" pattern that prevents bugs.
    test('copyWith() creates modified copy', () {
      // ARRANGE: Original link
      final original = Link.fromJson(testJson);

      // ACT: Create modified copy with new note and space
      final modified = original.copyWith(
        note: 'Updated note',
        spaceId: 'new-space-id',
      );

      // ASSERT: Modified link has new values
      expect(modified.note, 'Updated note');
      expect(modified.spaceId, 'new-space-id');

      // Original link is unchanged (immutability!)
      expect(original.note, 'Check this out later');
      expect(original.spaceId, '456e7890-e12b-34d5-a678-426614175111');

      // Other fields remain the same
      expect(modified.id, original.id);
      expect(modified.url, original.url);
      expect(modified.title, original.title);
    });

    /// Test #5: copyWith() with null values
    ///
    /// Why this matters:
    /// We should be able to clear optional fields (set to null).
    /// For example, user wants to remove a note from a link.
    test('copyWith() can set fields to null', () {
      // ARRANGE: Link with note
      final linkWithNote = Link.fromJson(testJson);
      expect(linkWithNote.note, 'Check this out later'); // Has a note

      // ACT: Clear the note
      final linkWithoutNote = linkWithNote.copyWith(note: null);

      // ASSERT: Note should be null
      expect(linkWithoutNote.note, null);
    });

    /// Test #6: extractDomain() - Get domain from URL
    ///
    /// Why this matters:
    /// In the UI, we want to show "apple.com" instead of the full URL.
    /// This makes it easier for users to identify links at a glance.
    test('extractDomain() returns domain from URL', () {
      // ARRANGE
      final link = Link.fromJson(testJson);

      // ACT
      final domain = link.extractDomain();

      // ASSERT: Should extract just the domain
      expect(domain, 'www.apple.com');
    });

    /// Test #7: extractDomain() handles edge cases
    test('extractDomain() handles URLs without protocol', () {
      // ARRANGE: URL without https://
      final jsonWithShortUrl = {
        ...testJson,
        'url': 'example.com/page',
      };
      final link = Link.fromJson(jsonWithShortUrl);

      // ACT
      final domain = link.extractDomain();

      // ASSERT: Should still extract domain
      expect(domain, 'example.com');
    });

    /// Test #8: extractDomain() handles invalid URLs
    test('extractDomain() returns URL if invalid', () {
      // ARRANGE: Invalid URL
      final jsonWithInvalidUrl = {
        ...testJson,
        'url': 'not a valid url',
      };
      final link = Link.fromJson(jsonWithInvalidUrl);

      // ACT
      final domain = link.extractDomain();

      // ASSERT: Should return original URL if can't parse
      expect(domain, 'not a valid url');
    });
  });
}

/// 🎓 Learning Summary: What We Tested
///
/// **JSON Serialization:**
/// - fromJson() converts Supabase data to Dart objects
/// - toJson() converts Dart objects back to JSON
/// - Handles nullable fields correctly
///
/// **Immutability:**
/// - copyWith() creates new objects instead of modifying existing ones
/// - Prevents bugs where changing one link accidentally changes another
///
/// **Helper Methods:**
/// - extractDomain() makes URLs more readable in UI
/// - Handles edge cases gracefully
///
/// **Next Step:**
/// Run `flutter test test/features/links/models/link_model_test.dart`
/// Watch it FAIL (🔴 RED) because Link model doesn't exist yet.
/// Then we'll implement the model to make these tests pass (🟢 GREEN).
