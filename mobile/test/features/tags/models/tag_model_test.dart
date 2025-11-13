library;

/// Tag Model Tests (TDD - RED)
///
/// Testing the Tag model that represents labels for organizing links.
///
/// What are tags?
/// Think of tags like labels or stickers you put on bookmarks:
/// - "Design" tag for design-related links
/// - "React" tag for React tutorials
/// - "Inspiration" tag for inspirational content
///
/// Each tag has a color (shown as colored badges in UI).
///
/// What we're testing:
/// 1. JSON deserialization (fromJson) - Convert Supabase data to Dart object
/// 2. JSON serialization (toJson) - Convert Dart object to JSON
/// 3. copyWith method - Create modified copies immutably

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tags/models/tag_model.dart';

void main() {
  group('Tag Model', () {
    /// Test Data
    /// This simulates what we'd get from Supabase
    final testJson = {
      'id': 'tag-123-abc',
      'user_id': 'user-456-def',
      'name': 'Design',
      'color': '#f42cff', // Pink color
      'created_at': '2025-11-13T09:00:00Z',
    };

    /// Test #1: fromJson() - Converting Supabase JSON to Tag object
    ///
    /// Why this matters:
    /// When we fetch tags from Supabase, we get JSON data.
    /// We need to convert it to a Dart Tag object.
    test('fromJson() creates Tag from JSON map', () {
      // ACT: Create Tag from JSON (this will fail until we implement the model)
      final tag = Tag.fromJson(testJson);

      // ASSERT: Verify all properties were set correctly
      expect(tag.id, 'tag-123-abc');
      expect(tag.userId, 'user-456-def');
      expect(tag.name, 'Design');
      expect(tag.color, '#f42cff');
      expect(tag.createdAt, DateTime.parse('2025-11-13T09:00:00Z'));
    });

    /// Test #2: toJson() - Converting Tag object back to JSON
    ///
    /// Why this matters:
    /// When we create or update a tag in Supabase, we need to convert
    /// the Dart object back to JSON format.
    test('toJson() converts Tag to JSON map', () {
      // ARRANGE: Create a Tag object
      final tag = Tag.fromJson(testJson);

      // ACT: Convert back to JSON
      final json = tag.toJson();

      // ASSERT: JSON should match Supabase format
      expect(json['id'], 'tag-123-abc');
      expect(json['user_id'], 'user-456-def');
      expect(json['name'], 'Design');
      expect(json['color'], '#f42cff');
      expect(json['created_at'], '2025-11-13T09:00:00.000Z');
    });

    /// Test #3: copyWith() - Immutable updates
    ///
    /// Why this matters:
    /// When we update a tag (e.g., rename it or change color),
    /// we want to create a NEW object with the changes.
    test('copyWith() creates modified copy', () {
      // ARRANGE: Original tag
      final original = Tag.fromJson(testJson);

      // ACT: Create modified copy with new name and color
      final modified = original.copyWith(
        name: 'UI Design',
        color: '#075a52', // Teal color
      );

      // ASSERT: Modified tag has new values
      expect(modified.name, 'UI Design');
      expect(modified.color, '#075a52');

      // Original tag is unchanged (immutability!)
      expect(original.name, 'Design');
      expect(original.color, '#f42cff');

      // Other fields remain the same
      expect(modified.id, original.id);
      expect(modified.userId, original.userId);
      expect(modified.createdAt, original.createdAt);
    });

    /// Test #4: copyWith() with partial updates
    ///
    /// Should be able to update just one field
    test('copyWith() allows partial updates', () {
      // ARRANGE
      final tag = Tag.fromJson(testJson);

      // ACT: Update only the color
      final updatedTag = tag.copyWith(color: '#2c4cff'); // Blue

      // ASSERT: Only color changed
      expect(updatedTag.color, '#2c4cff');
      expect(updatedTag.name, 'Design'); // Unchanged
      expect(updatedTag.id, tag.id); // Unchanged
    });

    /// Test #5: Color validation helper
    ///
    /// Tags should have valid hex colors for the UI.
    /// This test ensures we can validate color format.
    test('isValidColor() validates hex color format', () {
      // ARRANGE
      final tag = Tag.fromJson(testJson);

      // ACT & ASSERT: Valid colors
      expect(tag.isValidColor(), true); // #f42cff is valid

      // Create tags with invalid colors
      final invalidTag1 = tag.copyWith(color: 'not-a-color');
      final invalidTag2 = tag.copyWith(color: '#gg0000'); // Invalid hex
      final invalidTag3 = tag.copyWith(color: '#fff'); // Too short

      expect(invalidTag1.isValidColor(), false);
      expect(invalidTag2.isValidColor(), false);
      expect(invalidTag3.isValidColor(), false);

      // Valid color formats
      final validTag1 = tag.copyWith(color: '#000000');
      final validTag2 = tag.copyWith(color: '#FFFFFF');

      expect(validTag1.isValidColor(), true);
      expect(validTag2.isValidColor(), true);
    });

    /// Test #6: toString() for debugging
    ///
    /// When debugging, we want to see tag info clearly
    test('toString() returns readable format', () {
      // ARRANGE
      final tag = Tag.fromJson(testJson);

      // ACT
      final result = tag.toString();

      // ASSERT: Should contain key info
      expect(result, contains('Design'));
      expect(result, contains('#f42cff'));
      expect(result, contains('tag-123-abc'));
    });
  });
}

/// 🎓 Learning Summary: Tag Model
///
/// **What is a Tag?**
/// A tag is a label or category for organizing links.
/// Think of them like hashtags on social media.
///
/// **Properties:**
/// - id: Unique identifier
/// - userId: Who created this tag
/// - name: The label text (e.g., "Design", "React", "Inspiration")
/// - color: Hex color for visual distinction (e.g., "#f42cff" for pink)
/// - createdAt: When the tag was created
///
/// **Why Colors?**
/// In the UI, tags appear as colored badges on link cards.
/// Different colors help users visually distinguish tag types.
///
/// **Example in UI:**
/// ```
/// [Design]  [Apple]  [Headset]
///   pink     purple    teal
/// ```
///
/// **Next:**
/// Run `flutter test test/features/tags/models/tag_model_test.dart`
/// Watch it FAIL (🔴 RED) because Tag model doesn't exist yet.
/// Then implement the model to make tests pass (🟢 GREEN).
