library;

/// Search Provider
///
/// Manages search state and filters links based on search query.
///
/// Architecture:
/// - searchQueryProvider: Holds the current search string (StateProvider)
/// - filteredLinksProvider: Filters linksWithTagsProvider based on search query (Provider)
///
/// Real-World Analogy:
/// Think of this like a library search system:
/// - searchQueryProvider = The search box where you type
/// - filteredLinksProvider = The filtered catalog of books matching your search
///
/// Search Strategy:
/// - Case-insensitive matching (DESIGN matches design, Design, DeSiGn)
/// - Searches across multiple fields: title, note, domain, URL
/// - Empty query = show all links (no filter)
/// - No matches = empty list (UI shows "No results")
///
/// Why Client-Side Filtering?
/// For MVP, we filter in memory instead of querying the database:
/// - Faster for small datasets (< 1000 links)
/// - Simpler implementation (no new database queries)
/// - Works offline immediately
/// - Can upgrade to server-side when dataset grows

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/links/services/link_service.dart';
import 'package:mobile/features/links/providers/link_provider.dart';

/// Search Query Provider
///
/// A simple StateProvider that holds the current search string.
///
/// Usage:
/// ```dart
/// // Read current search query
/// final query = ref.watch(searchQueryProvider);
///
/// // Update search query (from SearchBarWidget onChanged)
/// ref.read(searchQueryProvider.notifier).state = 'design';
///
/// // Clear search
/// ref.read(searchQueryProvider.notifier).state = '';
/// ```
///
/// Why StateProvider?
/// - Simple state (just a string)
/// - No complex logic needed
/// - UI can read and write directly
///
/// Initial State:
/// - Starts with empty string ('')
/// - Empty query means "show all links"
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Filtered Links Provider
///
/// Filters linksWithTagsProvider based on searchQueryProvider.
///
/// How it works:
/// 1. Watches searchQueryProvider for current query
/// 2. Watches linksWithTagsProvider for all links
/// 3. If query is empty → returns all links
/// 4. If query is not empty → filters links that match query
///
/// Matching Logic:
/// - Convert query to lowercase for case-insensitive search
/// - Check if query appears in: title, note, domain, or URL
/// - Return link if ANY field matches (OR logic, not AND)
///
/// Why Provider (not StateNotifier)?
/// - This is derived/computed state (depends on other providers)
/// - No local state to manage
/// - Automatically recomputes when dependencies change
///
/// Reactivity:
/// - When searchQueryProvider changes → this recomputes automatically
/// - When linksWithTagsProvider changes → this recomputes automatically
/// - UI watching this provider gets instant updates
///
/// Performance:
/// - O(n) filtering where n = number of links
/// - For < 1000 links, this is instant
/// - For > 1000 links, consider server-side search
final filteredLinksProvider = Provider<List<LinkWithTags>>((ref) {
  // Get current search query (reactive - updates when query changes)
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  // Get all links (reactive - updates when links change)
  final asyncLinks = ref.watch(linksWithTagsProvider);

  // Handle AsyncValue states
  // - Loading: Return empty list (UI will show loading state separately)
  // - Error: Return empty list (UI will show error state separately)
  // - Data: Filter the links
  return asyncLinks.when(
    data: (links) {
      // If query is empty, return all links (no filter)
      if (query.isEmpty) {
        return links;
      }

      // Filter links based on query
      // A link matches if query appears in ANY of these fields:
      // - title (e.g., "Design System Guide")
      // - note (e.g., "Watch this tutorial later")
      // - domain (e.g., "apple.com")
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

/// 🎓 Learning Summary: Search Provider Architecture
///
/// **Two-Provider Pattern:**
///
/// 1. **searchQueryProvider (Source of Truth)**
///    - Type: StateProvider<String>
///    - Holds: Current search query
///    - Updated by: UI (SearchBarWidget onChanged)
///    - Role: Single source of truth for what user is searching
///
/// 2. **filteredLinksProvider (Derived State)**
///    - Type: Provider<List<LinkWithTags>>
///    - Depends on: searchQueryProvider + linksWithTagsProvider
///    - Role: Automatically computes filtered results
///    - Updates: Whenever dependencies change
///
/// **Real-World Analogy:**
///
/// Think of a restaurant with a menu board:
/// - searchQueryProvider = What customer asks for ("vegetarian")
/// - linksWithTagsProvider = Full menu (all dishes)
/// - filteredLinksProvider = Filtered menu (only vegetarian dishes)
///
/// When customer changes their request ("gluten-free"), the filtered
/// menu automatically updates because it's watching the request.
///
/// **Data Flow:**
///
/// ```
/// User types "design"
///     ↓
/// SearchBarWidget.onChanged
///     ↓
/// searchQueryProvider.state = "design"
///     ↓
/// filteredLinksProvider sees query changed
///     ↓
/// Recomputes: filters links matching "design"
///     ↓
/// HomeScreen watching filteredLinksProvider
///     ↓
/// UI automatically updates with filtered results
/// ```
///
/// **Why This Pattern?**
///
/// 1. **Separation of Concerns**
///    - Query state (searchQueryProvider) separate from filtering logic
///    - Easy to test each piece independently
///
/// 2. **Automatic Reactivity**
///    - No manual updates needed
///    - Change query → results update automatically
///    - Add/remove links → search results update automatically
///
/// 3. **Single Responsibility**
///    - searchQueryProvider: Manages search string
///    - filteredLinksProvider: Computes filtered results
///    - Neither needs to know about UI
///
/// 4. **Type Safety**
///    - Dart knows searchQueryProvider is String
///    - Dart knows filteredLinksProvider is List<LinkWithTags>
///    - Compiler catches errors at build time
///
/// **Performance Notes:**
///
/// - Client-side filtering is O(n) per search
/// - Fast for < 1000 links (< 10ms typically)
/// - If dataset grows, consider:
///   - Server-side search with PostgreSQL full-text search
///   - Indexed database queries
///   - Debouncing to reduce filter frequency (300ms delay)
///
/// **Next Steps:**
///
/// 1. Run tests: `flutter test test/features/links/providers/search_provider_test.dart`
/// 2. Verify tests pass (🟢 GREEN)
/// 3. Integrate with SearchBarWidget
/// 4. Update HomeScreen to use filteredLinksProvider
/// 5. Add debouncing for better UX
///
/// **Future Enhancements:**
///
/// - Server-side full-text search (leverage PostgreSQL GIN index)
/// - Search by tags (not just link fields)
/// - Search history / suggestions
/// - Advanced query syntax (AND, OR, NOT, exact phrases)
/// - Search within specific space
