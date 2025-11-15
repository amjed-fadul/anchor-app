library;

/// Tag Providers
///
/// State management for tags using Riverpod.
///
/// What this does:
/// - Provides access to user's tags for categorizing links
/// - Automatically fetches tags when accessed
/// - Caches tags for quick access
/// - Provides refresh method to reload from database
///
/// Real-World Analogy:
/// Think of this like a label maker with memory:
/// - First time you use it: Loads all your label templates from storage
/// - After that: Shows cached labels instantly
/// - Refresh: Re-loads labels from storage to get new ones

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag_model.dart';
import '../services/tag_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for fetching user's tags
///
/// This is an AsyncNotifier - it handles async data fetching automatically.
/// It manages three states: loading, data, error.
///
/// How to use in UI:
/// ```dart
/// final tagsAsync = ref.watch(tagsProvider);
///
/// tagsAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
///   data: (tags) => TagPickerSheet(
///     availableTags: tags,
///     selectedTagIds: currentTagIds,
///     onDone: (tagIds) => updateTags(tagIds),
///   ),
/// );
/// ```
final tagsProvider = AsyncNotifierProvider<TagsNotifier, List<Tag>>(
  TagsNotifier.new,
);

/// TagsNotifier - Manages the state of tags
///
/// This class:
/// 1. Fetches tags when first accessed
/// 2. Caches the result
/// 3. Provides a method to refresh
/// 4. Handles errors automatically
class TagsNotifier extends AsyncNotifier<List<Tag>> {
  /// build - Called when the notifier is first accessed
  ///
  /// This is where we fetch the initial data.
  /// Riverpod automatically handles loading/error states.
  @override
  Future<List<Tag>> build() async {
    debugPrint('🔵 [TagsNotifier] build() START');

    // Get the current user from auth (matches SpacesProvider pattern)
    final user = ref.read(currentUserProvider);
    debugPrint('🔵 [TagsNotifier] currentUserProvider result: ${user != null ? "User(id: ${user.id})" : "null"}');
    final userId = user?.id;

    // If no user is logged in, return empty list
    if (userId == null) {
      debugPrint('⚠️ [TagsNotifier] userId is null, returning empty list');
      return [];
    }

    debugPrint('🔵 [TagsNotifier] userId: $userId, getting tagService...');
    // Get the service
    final tagService = ref.read(tagServiceProvider);

    debugPrint('🔵 [TagsNotifier] Calling tagService.getUserTags($userId)');
    // Fetch tags (matches SpacesProvider pattern)
    // This is async, so Riverpod shows loading state automatically
    final tags = await tagService.getUserTags(userId);
    debugPrint('🟢 [TagsNotifier] tagService.getUserTags returned ${tags.length} tags');
    return tags;
  }

  /// refresh - Manually refresh the tags
  ///
  /// Call this when:
  /// - User creates a new tag
  /// - User updates a tag
  /// - User deletes a tag
  ///
  /// Usage:
  /// ```dart
  /// ref.read(tagsProvider.notifier).refresh();
  /// ```
  Future<void> refresh() async {
    // Invalidate the current state and rebuild
    // This fetches fresh data from the database
    ref.invalidateSelf();

    // Wait for the new data to load
    await future;
  }
}

/// 🎓 Learning Summary: Riverpod Provider Pattern for Tags
///
/// **Why create a separate provider?**
/// - Tags are a different resource than spaces
/// - Each resource should have its own provider
/// - Makes code modular and testable
///
/// **How this works with TagPickerSheet:**
/// 1. User long-presses a link card
/// 2. LinkCard shows action sheet
/// 3. User taps "Add Tag"
/// 4. LinkCard fetches tags using `ref.watch(tagsProvider)`
/// 5. Shows TagPickerSheet with fetched tags
/// 6. User selects tags and taps Done
/// 7. LinkCard updates the link's tags
/// 8. Refreshes tags provider if new tags were created
///
/// **Caching Benefits:**
/// - First tag picker open: Fetches from database
/// - Subsequent opens: Instant (uses cached data)
/// - After creating new tag: Refresh to get updated list
///
/// **Error Handling:**
/// Riverpod automatically handles errors:
/// ```dart
/// tagsAsync.when(
///   loading: () => ...,
///   error: (err, stack) => ..., // Shows error automatically
///   data: (tags) => ...,
/// )
/// ```
///
/// **Next:**
/// Integrate this provider with LinkCard to show TagPickerSheet
