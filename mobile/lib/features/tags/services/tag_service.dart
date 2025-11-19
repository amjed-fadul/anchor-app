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
      // First, check if tag already exists for this user (with retry)
      List<dynamic>? existingTags;
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          existingTags = await _supabase
              .from('tags')
              .select()
              .eq('user_id', userId)
              .ilike('name', name) // Case-insensitive match
              .limit(1)
              .timeout(const Duration(seconds: 10));
          break; // Success!
        } catch (e) {
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (existingTags!.isNotEmpty) {
        return Tag.fromJson(existingTags.first);
      }

      // Tag doesn't exist, create it (with retry)
      Tag? newTag;
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          final response = await _supabase
              .from('tags')
              .insert({
                'user_id': userId,
                'name': name.trim(),
                'color': _generateRandomColor(),
              })
              .select()
              .single()
              .timeout(const Duration(seconds: 10));

          newTag = Tag.fromJson(response);
          break; // Success!
        } catch (e) {
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      return newTag!;
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
  ///
  /// Retry Logic:
  /// - 2 attempts with 500ms delay between retries
  /// - 10 second timeout per attempt
  /// - Handles intermittent network failures (DNS lookup, connection drops)
  Future<List<Tag>> getUserTags(String userId) async {
    try {
      // Fetch tags (with retry logic for network resilience)
      List<dynamic>? response;
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          debugPrint('🔵 [TagService] getUserTags attempt $attempt/2');

          // Query tags table sorted alphabetically (A→Z)
          response = await _supabase
              .from('tags')
              .select()
              .eq('user_id', userId)
              .order('name', ascending: true)
              .timeout(const Duration(seconds: 10));

          debugPrint('🟢 [TagService] Successfully fetched tags');
          break; // Success!
        } catch (e) {
          debugPrint('🔴 [TagService] Error fetching tags (attempt $attempt/2): $e');
          if (attempt == 2) rethrow;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      final tags = (response! as List).map((json) => Tag.fromJson(json)).toList();
      debugPrint('🟢 [TagService] Mapped to ${tags.length} Tag objects');
      return tags;
    } catch (e, stackTrace) {
      // Log error and rethrow (matches SpaceService pattern)
      debugPrint('🔴 [TagService] Failed to fetch tags after retries: $e');
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
