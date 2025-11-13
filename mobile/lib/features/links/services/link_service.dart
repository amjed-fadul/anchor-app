/// LinkService
///
/// Service for fetching and managing links from Supabase.
///
/// What is a Service?
/// A service is like a specialized worker that handles one specific job.
/// In this case, LinkService's job is to fetch links from the database.
///
/// Real-World Analogy:
/// Think of a service like a waiter at a restaurant:
/// - You (the UI) ask the waiter (service) for data
/// - The waiter goes to the kitchen (database) and gets it
/// - The waiter brings it back in a nice format
/// - If something goes wrong, the waiter tells you
///
/// Why Services?
/// - Separation of Concerns: UI code doesn't need to know about database queries
/// - Reusability: Multiple screens can use the same service
/// - Testing: Easier to test database logic separately from UI
/// - Maintainability: All database queries in one place

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/link_model.dart';
import '../../tags/models/tag_model.dart';

/// LinkWithTags - Holds a link and its associated tags
///
/// Why a separate class?
/// In the database, links and tags are in separate tables connected by
/// a junction table (link_tags). We need to combine them for the UI.
class LinkWithTags {
  final Link link;
  final List<Tag> tags;

  LinkWithTags({
    required this.link,
    required this.tags,
  });
}

/// LinkService - Handles all link-related database operations
class LinkService {
  final SupabaseClient _supabase;

  /// Constructor
  /// Takes a Supabase client so we can query the database
  LinkService(this._supabase);

  /// getLinksWithTags - Fetch all links for a user with their tags
  ///
  /// Why this query structure?
  /// We need to:
  /// 1. Get all links for a specific user
  /// 2. For each link, get all its tags
  /// 3. Return them combined
  ///
  /// SQL equivalent (what Supabase does under the hood):
  /// ```sql
  /// SELECT links.*, tags.*
  /// FROM links
  /// LEFT JOIN link_tags ON links.id = link_tags.link_id
  /// LEFT JOIN tags ON link_tags.tag_id = tags.id
  /// WHERE links.user_id = $userId
  /// ORDER BY links.created_at DESC
  /// ```
  ///
  /// Parameters:
  /// - userId: The ID of the user whose links we're fetching
  ///
  /// Returns:
  /// List of LinkWithTags objects (link + its tags)
  ///
  /// Throws:
  /// Exception if database query fails
  Future<List<LinkWithTags>> getLinksWithTags(String userId) async {
    try {
      // Query links with their tags using Supabase
      // The syntax: link_tags(tags(*)) means:
      // - Get link_tags for this link
      // - For each link_tag, get the full tag object
      final response = await _supabase
          .from('links')
          .select('*, link_tags(tags(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Convert the response to our models
      final List<LinkWithTags> results = [];

      for (final linkData in response) {
        // Create Link object
        final link = Link.fromJson(linkData);

        // Extract tags from the nested link_tags array
        final List<Tag> tags = [];
        final linkTagsData = linkData['link_tags'] as List<dynamic>?;

        if (linkTagsData != null) {
          for (final linkTag in linkTagsData) {
            final tagData = linkTag['tags'] as Map<String, dynamic>?;
            if (tagData != null) {
              tags.add(Tag.fromJson(tagData));
            }
          }
        }

        // Combine link with its tags
        results.add(LinkWithTags(
          link: link,
          tags: tags,
        ));
      }

      return results;
    } catch (e) {
      // Re-throw with context
      throw Exception('Failed to fetch links: $e');
    }
  }
}

/// 🎓 Learning Summary: Database Queries
///
/// **What We're Doing:**
/// Fetching links and their related tags in one query instead of multiple queries.
///
/// **Why One Query?**
/// - Faster: One round-trip to database instead of N+1 queries
/// - Efficient: Database does the joining (it's optimized for this)
/// - Simpler: We get all data at once
///
/// **The Query Breakdown:**
/// ```dart
/// .from('links')                    // Start with links table
/// .select('*, link_tags(tags(*))')  // Get all link columns + nested tags
/// .eq('user_id', userId)            // Filter by user
/// .order('created_at', ascending: false)  // Newest first
/// ```
///
/// **What `link_tags(tags(*))` means:**
/// - `link_tags`: Get rows from link_tags junction table
/// - `tags(*)`: For each link_tag, get the full tag object
/// - This creates nested data: link { link_tags: [ { tags: {...} } ] }
///
/// **Response Structure:**
/// ```json
/// [
///   {
///     "id": "link-1",
///     "url": "https://apple.com",
///     "title": "Apple",
///     "link_tags": [
///       {
///         "tags": {
///           "id": "tag-1",
///           "name": "Design",
///           "color": "#f42cff"
///         }
///       },
///       {
///         "tags": {
///           "id": "tag-2",
///           "name": "Apple",
///           "color": "#682cff"
///         }
///       }
///     ]
///   }
/// ]
/// ```
///
/// **Next:**
/// Now we need to create providers (state management) that use this service
/// to fetch data and make it available to the UI.
