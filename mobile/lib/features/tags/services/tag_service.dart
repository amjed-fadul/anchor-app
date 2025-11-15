library;

/// TagService - Handle tag operations in Supabase

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tag_model.dart';

class TagService {
  final SupabaseClient _supabase;

  TagService(this._supabase);

  /// Get or create a tag by name
  /// If tag exists for this user, return it
  /// If not, create it with a random color
  Future<Tag> getOrCreateTag({
    required String userId,
    required String name,
  }) async {
    try {
      // First, check if tag already exists for this user
      final existingTags = await _supabase
          .from('tags')
          .select()
          .eq('user_id', userId)
          .ilike('name', name) // Case-insensitive match
          .limit(1);

      if (existingTags.isNotEmpty) {
        return Tag.fromJson(existingTags.first);
      }

      // Tag doesn't exist, create it
      final newTag = await _supabase.from('tags').insert({
        'user_id': userId,
        'name': name.trim(),
        'color': _generateRandomColor(),
      }).select().single();

      return Tag.fromJson(newTag);
    } catch (e) {
      throw Exception('Failed to get or create tag: $e');
    }
  }

  /// Generate a random color from predefined palette (Figma colors)
  String _generateRandomColor() {
    final colors = [
      '#7cfec4', // Light green/teal
      '#c3c3d1', // Gray
      '#ff8da7', // Pink
      '#000002', // Black
      '#15afcf', // Blue
      '#1ac47f', // Green
      '#ffdcd4', // Peach
      '#7e30d1', // Purple
      '#fff273', // Yellow
      '#c5a3af', // Dusty rose
      '#97cdd3', // Light blue
      '#c2b8d9', // Lavender
      '#1773fa', // Bright blue
      '#ed404d', // Red
    ];
    colors.shuffle();
    return colors.first;
  }

  /// Get all tags for a user
  Future<List<Tag>> getUserTags(String userId) async {
    debugPrint('🔵 [TagService] getUserTags START - userId: $userId');
    try {
      debugPrint('🔵 [TagService] Executing Supabase query: tags table, user_id = $userId');
      // Query tags table (matches SpaceService.getSpaces pattern)
      final response = await _supabase
          .from('tags')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('🟢 [TagService] Supabase query returned successfully');
      debugPrint('🔵 [TagService] Response type: ${response.runtimeType}, length: ${(response as List).length}');

      final tags = response.map((json) => Tag.fromJson(json)).toList();
      debugPrint('🟢 [TagService] Mapped to ${tags.length} Tag objects');
      return tags;
    } catch (e, stackTrace) {
      // Log error and rethrow (matches SpaceService pattern)
      debugPrint('🔴 [TagService] ERROR: $e');
      debugPrint('🔴 [TagService] Stack trace: $stackTrace');
      throw Exception('Failed to fetch tags: $e');
    }
  }
}

/// Provider for TagService
final tagServiceProvider = Provider<TagService>((ref) {
  final supabase = Supabase.instance.client;
  return TagService(supabase);
});
