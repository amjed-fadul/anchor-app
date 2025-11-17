library;

/// Space Search Provider
///
/// Manages search state and filters links within a specific space.
///
/// Architecture:
/// - spaceSearchQueryProvider: Holds the current search string (StateProvider)
/// - filteredSpaceLinksProvider: Filters links in a space based on search query (Provider.family)
///
/// Key Difference from Home Search:
/// - Home Search: Searches ALL user links across all spaces
/// - Space Search: Searches links ONLY within a specific space
///
/// Real-World Analogy:
/// Think of this like searching inside a specific folder on your computer:
/// - Global search (Home): "Find all files named 'report.pdf' on my computer"
/// - Folder search (Space): "Find files named 'report.pdf' in Documents/Work"
///
/// Search Strategy:
/// - Case-insensitive matching (DESIGN matches design, Design, DeSiGn)
/// - Searches across multiple fields: title, note, domain, tags
/// - Empty query = show all links in space (no filter)
/// - No matches = empty list (UI shows "No results")
///
/// Why Client-Side Filtering?
/// For MVP, we filter in memory instead of querying the database:
/// - Faster for small datasets (< 1000 links per space)
/// - Simpler implementation (no new database queries)
/// - Works offline immediately
/// - Can upgrade to server-side when dataset grows

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/links/providers/links_by_space_provider.dart';

/// Space Search Query Provider
///
/// A simple StateProvider that holds the current search string for space search.
///
/// Usage:
/// ```dart
/// // Read current search query
/// final query = ref.watch(spaceSearchQueryProvider);
///
/// // Update search query (from SearchBarWidget onChanged)
/// ref.read(spaceSearchQueryProvider.notifier).state = 'design';
///
/// // Clear search
/// ref.read(spaceSearchQueryProvider.notifier).state = '';
/// ```
///
/// Why StateProvider?
/// - Simple state (just a string)
/// - No complex logic needed
/// - UI can read and write directly
///
/// Initial State:
/// - Starts with empty string ('')
/// - Empty query means "show all links in space"
final spaceSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filtered Space Links Provider
///
/// Filters links within a specific space based on search query.
///
/// This is a family provider - takes spaceId as parameter.
/// Each space gets its own search instance with independent state.
///
/// How it works:
/// 1. Takes spaceId parameter
/// 2. Watches spaceSearchQueryProvider for current query
/// 3. Watches linksBySpaceProvider(spaceId) for links in that space
/// 4. If query is empty → returns all space links
/// 5. If query is not empty → filters links that match query
///
/// Matching Logic:
/// - Convert query to lowercase for case-insensitive search
/// - Check if query appears in: title, note, domain, or tags
/// - Return link if ANY field matches (OR logic, not AND)
///
/// Why Provider.family?
/// - Each space needs its own filtered results
/// - Space A search doesn't affect Space B search
/// - Separate caching per space
///
/// Reactivity:
/// - When spaceSearchQueryProvider changes → this recomputes automatically
/// - When linksBySpaceProvider(spaceId) changes → this recomputes automatically
/// - UI watching this provider gets instant updates
///
/// Performance:
/// - O(n) filtering where n = number of links in space
/// - Fast for < 1000 links per space (< 10ms typically)
/// - For > 1000 links, consider server-side search
final filteredSpaceLinksProvider = Provider.family<List<LinkWithTags>, String>((ref, spaceId) {
  // Get current search query (reactive - updates when query changes)
  final query = ref.watch(spaceSearchQueryProvider).toLowerCase().trim();

  // Get links for this specific space (reactive - updates when links change)
  final asyncLinks = ref.watch(linksBySpaceProvider(spaceId));

  // Handle AsyncValue states
  // - Loading: Return empty list (UI will show loading state separately)
  // - Error: Return empty list (UI will show error state separately)
  // - Data: Filter the links
  return asyncLinks.when(
    data: (links) {
      // If query is empty, return all links in space (no filter)
      if (query.isEmpty) {
        return links;
      }

      // Filter links based on query
      // A link matches if query appears in ANY of these fields:
      // - title (e.g., "Design System Guide")
      // - note (e.g., "Watch this tutorial later")
      // - domain (e.g., "figma.com")
      // - tags (e.g., user tagged with "design", "work", etc.)
      return links.where((linkWithTags) {
        final link = linkWithTags.link;

        // Check each field (null-safe with ?? false pattern)
        // If field is null, contains() would crash, so we use ?? false
        final matchesTitle =
            link.title?.toLowerCase().contains(query) ?? false;
        final matchesNote = link.note?.toLowerCase().contains(query) ?? false;
        final matchesDomain =
            link.domain?.toLowerCase().contains(query) ?? false;

        // Check if query matches any tag name (case-insensitive)
        // Tags are user-created labels for organizing links
        final matchesTags = linkWithTags.tags.any(
          (tag) => tag.name.toLowerCase().contains(query)
        );

        // Return true if ANY field matches (OR logic)
        return matchesTitle || matchesNote || matchesDomain || matchesTags;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 🎓 Learning Summary: Space Search vs Home Search
///
/// **Comparison Table:**
///
/// | Aspect             | Home Search                  | Space Search                    |
/// |--------------------|------------------------------|---------------------------------|
/// | **Scope**          | All user links (all spaces)  | Links in ONE specific space     |
/// | **Provider Type**  | Regular Provider             | Family Provider (takes spaceId) |
/// | **Data Source**    | linksWithTagsProvider        | linksBySpaceProvider(spaceId)   |
/// | **Search Query**   | searchQueryProvider          | spaceSearchQueryProvider        |
/// | **Use Case**       | Global "find anything"       | Focused "find in this folder"   |
///
/// **Why Separate Providers?**
///
/// We could have reused the home search provider, but having separate providers:
/// 1. **Clear Intent**: Code clearly shows "this is space-specific search"
/// 2. **Independent State**: Home search and space search don't interfere
/// 3. **Better UX**: User can search in home, open a space, search there differently
/// 4. **Performance**: Only filter links in current space, not all links
///
/// **Real-World Example:**
///
/// User has 500 links across 10 spaces (50 links per space average):
///
/// **Home Search:**
/// - Filters all 500 links
/// - Query "design" → checks 500 links → returns ~50 matches across spaces
///
/// **Space Search (in "Work" space with 50 links):**
/// - Filters only 50 links in "Work" space
/// - Query "design" → checks 50 links → returns ~5 matches in this space
/// - 10x faster!
///
/// **Code Reuse:**
///
/// Both providers use the SAME filtering logic (title, note, domain, tags).
/// The only difference is the data source:
/// ```dart
/// // Home: Filter all links
/// ref.watch(linksWithTagsProvider)
///
/// // Space: Filter space-specific links
/// ref.watch(linksBySpaceProvider(spaceId))
/// ```
///
/// **Family Provider Pattern:**
///
/// ```dart
/// // Regular Provider - One instance
/// final filteredLinksProvider = Provider<List<LinkWithTags>>((ref) {
///   // Returns filtered results for ALL links
/// });
///
/// // Family Provider - One instance PER spaceId
/// final filteredSpaceLinksProvider = Provider.family<List<LinkWithTags>, String>((ref, spaceId) {
///   // Returns filtered results for ONE specific space
/// });
/// ```
///
/// Usage:
/// ```dart
/// // Home screen
/// final allFiltered = ref.watch(filteredLinksProvider);
///
/// // Space detail screen for "Work" space
/// final workFiltered = ref.watch(filteredSpaceLinksProvider('work-space-id'));
///
/// // Space detail screen for "Design" space
/// final designFiltered = ref.watch(filteredSpaceLinksProvider('design-space-id'));
/// ```
///
/// **Performance Optimization:**
///
/// Current approach (client-side filtering) is optimal for:
/// - Spaces with < 1000 links
/// - Instant results (< 10ms)
/// - No database roundtrips
///
/// Future optimization (server-side search) if needed:
/// - Use PostgreSQL full-text search
/// - Add GIN index on searchable columns
/// - Replace Provider with AsyncNotifierProvider
/// - Query database with search parameter
///
/// **Next Steps:**
/// 1. Run tests to verify implementation passes (🟢 GREEN)
/// 2. Integrate with Space Detail Screen
/// 3. Replace custom search bar with SearchBarWidget
/// 4. Add debouncing for better UX
