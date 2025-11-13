library;

/// Space Service
///
/// Handles all database operations for Spaces (folders for organizing links).
///
/// What it does:
/// - Fetches user's spaces from Supabase
/// - Creates new spaces
/// - Updates existing spaces
/// - Deletes spaces (except default ones)
///
/// Real-World Analogy:
/// Think of this like a filing cabinet manager:
/// - getSpaces() = Opens cabinet, shows you all your folders
/// - createSpace() = Creates a new folder with a label
/// - updateSpace() = Relabels an existing folder
/// - deleteSpace() = Removes a folder (but not the default ones!)

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/space_model.dart';

class SpaceService {
  /// Supabase client for database operations
  final SupabaseClient supabase;

  /// Constructor
  SpaceService(this.supabase);

  /// Fetches all spaces for a user, ordered by:
  /// 1. Default spaces first (Unread, Reference)
  /// 2. Then custom spaces alphabetically
  ///
  /// Why this order?
  /// - Users always see default spaces at top
  /// - Custom spaces are alphabetically sorted for easy finding
  ///
  /// Example:
  /// ```dart
  /// final spaces = await service.getSpaces(userId);
  /// // Returns: [Unread, Reference, Articles, Work, ...]
  /// ```
  Future<List<Space>> getSpaces(String userId) async {
    try {
      // Query spaces table
      final response = await supabase
          .from('spaces')
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false) // Default spaces first
          .order('name', ascending: true); // Then alphabetically

      // Convert JSON list to Space objects
      final spaces = (response as List)
          .map((json) => Space.fromJson(json as Map<String, dynamic>))
          .toList();

      return spaces;
    } catch (e) {
      // Log error and rethrow
      throw Exception('Failed to fetch spaces: $e');
    }
  }

  /// Creates a new space
  ///
  /// Note: Default spaces (Unread, Reference) are created automatically
  /// by the database when a user signs up. This is for custom spaces only.
  ///
  /// Example:
  /// ```dart
  /// final space = await service.createSpace(
  ///   userId: userId,
  ///   name: 'Work',
  ///   color: '#3B82F6',
  /// );
  /// ```
  Future<Space> createSpace({
    required String userId,
    required String name,
    required String color,
  }) async {
    try {
      // Insert new space
      final response = await supabase
          .from('spaces')
          .insert({
            'user_id': userId,
            'name': name,
            'color': color,
            'is_default': false, // Custom spaces are never default
          })
          .select()
          .single();

      return Space.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create space: $e');
    }
  }

  /// Updates an existing space
  ///
  /// Can update name and/or color.
  /// Cannot change is_default flag (enforced by database).
  ///
  /// Example:
  /// ```dart
  /// final updated = await service.updateSpace(
  ///   spaceId: spaceId,
  ///   name: 'Work Projects',
  ///   color: '#10B981',
  /// );
  /// ```
  Future<Space> updateSpace({
    required String spaceId,
    String? name,
    String? color,
  }) async {
    try {
      // Build update map (only include non-null fields)
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (color != null) updates['color'] = color;

      // Update space
      final response = await supabase
          .from('spaces')
          .update(updates)
          .eq('id', spaceId)
          .select()
          .single();

      return Space.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update space: $e');
    }
  }

  /// Deletes a space
  ///
  /// IMPORTANT: Cannot delete default spaces (Unread, Reference).
  /// Database trigger prevents this.
  ///
  /// What happens to links in deleted space?
  /// - Links are NOT deleted
  /// - Their space_id becomes null (unassigned)
  /// - Links remain in the database
  ///
  /// Example:
  /// ```dart
  /// await service.deleteSpace(spaceId);
  /// ```
  Future<void> deleteSpace(String spaceId) async {
    try {
      await supabase.from('spaces').delete().eq('id', spaceId);
    } catch (e) {
      throw Exception('Failed to delete space: $e');
    }
  }
}

/// 🎓 Learning Summary: Service Layer Pattern
///
/// **What is a Service?**
/// A class that handles business logic and data operations.
/// Separates data access from UI code.
///
/// **Architecture Layers:**
/// ```
/// UI (Widgets)
///    ↓
/// Providers (State Management)
///    ↓
/// Services (Business Logic)
///    ↓
/// Database (Supabase)
/// ```
///
/// **Why This Separation?**
/// 1. **Testability:** Can test services without UI
/// 2. **Reusability:** Multiple screens can use same service
/// 3. **Maintainability:** Business logic in one place
/// 4. **Clarity:** Each layer has clear responsibility
///
/// **Service Responsibilities:**
/// - ✅ Database queries
/// - ✅ Data transformation (JSON → Model)
/// - ✅ Error handling
/// - ✅ Business logic
/// - ❌ UI logic (belongs in widgets)
/// - ❌ State management (belongs in providers)
///
/// **Error Handling Pattern:**
/// ```dart
/// try {
///   final result = await database.query();
///   return result;
/// } catch (e) {
///   throw Exception('Failed to ...: $e');
/// }
/// ```
///
/// We catch errors, add context, and rethrow.
/// Why rethrow? Let the caller decide how to handle the error:
/// - UI might show a snackbar
/// - Provider might retry
/// - Test might assert error type
///
/// **Supabase Query Pattern:**
/// ```dart
/// await supabase
///   .from('table_name')      // Select table
///   .select()                 // Fetch data
///   .eq('column', value)      // Filter: WHERE column = value
///   .order('column')          // Sort
/// ```
///
/// Multiple ordering:
/// ```dart
/// .order('is_default', ascending: false)  // Default first (true > false)
/// .order('name', ascending: true)          // Then alphabetically
/// ```
///
/// **Insert Pattern:**
/// ```dart
/// await supabase
///   .from('table')
///   .insert({...})  // Insert data
///   .select()       // Return inserted row
///   .single()       // Get single result (not array)
/// ```
///
/// Without `.select().single()`, you wouldn't get the created object back.
///
/// **Update Pattern:**
/// ```dart
/// await supabase
///   .from('table')
///   .update({...})        // Update data
///   .eq('id', spaceId)    // WHERE id = spaceId
///   .select()             // Return updated row
///   .single()
/// ```
///
/// **Delete Pattern:**
/// ```dart
/// await supabase
///   .from('table')
///   .delete()
///   .eq('id', id)  // WHERE id = id
/// ```
///
/// **Next:**
/// Create SpaceProvider that uses this service to manage state
/// with Riverpod AsyncNotifier.
