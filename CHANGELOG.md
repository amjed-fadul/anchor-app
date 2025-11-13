# Changelog

All notable changes to the Anchor app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

#### Add Link Feature - Complete Implementation (2025-11-14 01:00)
- **What**: Full Add Link flow from URL input to saved link with metadata
- **Why**: Users needed ability to save links from within the app (core feature #1)
- **Solution**:
  - Created 4-screen flow: URL Input → Metadata Fetch → Success → Add Details (optional)
  - URL input screen with real-time validation using URLValidator utility
  - Automatic metadata extraction (title, description, thumbnail, domain) via MetadataService with 10s timeout
  - Link saved immediately after metadata fetch (even if metadata fails)
  - Optional details screen with 3 tabs: Tag / Note / Space
  - Tag autocomplete with comma/newline separation (creates tags on-the-fly via TagService)
  - Space assignment picker displaying all user spaces
  - Personal notes text area (1-line display on card, unlimited input)
  - Modal bottom sheet presentation with DraggableScrollableSheet
  - Graceful degradation if metadata fetch times out (link still saves with URL only)
- **Files Changed**:
  - `mobile/lib/features/links/screens/add_link_flow_screen.dart` - Created flow coordinator
  - `mobile/lib/features/links/screens/url_input_screen.dart` - Created URL input UI
  - `mobile/lib/features/links/screens/link_success_screen.dart` - Created success confirmation
  - `mobile/lib/features/links/screens/add_details_screen.dart` - Created tabbed details modal
  - `mobile/lib/features/links/providers/add_link_provider.dart` - Created state management (5 flow states)
  - `mobile/lib/features/home/screens/home_screen.dart` - Replaced logout FAB with Add Link FAB
  - `mobile/test/features/links/services/link_service_test.dart` - Added comprehensive tests (TDD)
- **Result**: ✅ Users can now save links with automatic metadata, organize with tags/notes/spaces

#### Settings Screen with Logout Functionality (2025-11-14 00:45)
- **What**: Settings screen accessible from home screen avatar with sign out capability
- **Why**: Users needed a way to manage account settings and safely sign out
- **Solution**:
  - Created clean settings UI with sections: Account (email display), Actions (sign out)
  - Email display as read-only information
  - Sign out button with confirmation dialog for safety ("Are you sure?")
  - Proper error handling if logout fails (shows SnackBar with error message)
  - Logout calls AuthService.signOut() then navigates to /login
  - Integrated into router as protected route (requires authentication)
  - Made home screen avatar tappable → navigates to /settings using context.go()
- **Files Changed**:
  - `mobile/lib/features/settings/screens/settings_screen.dart` - Created settings UI
  - `mobile/lib/core/router/app_router.dart` - Added /settings route, updated _isProtectedRoute()
  - `mobile/lib/features/home/screens/home_screen.dart` - Wrapped avatar in GestureDetector
- **Result**: ✅ Users can access settings via avatar tap and safely sign out with confirmation

#### Link Service Update Method (2025-11-14 00:30)
- **What**: Added `updateLink()` method to LinkService for updating existing links
- **Why**: Need ability to update link details (note, space, tags) after creation, preparing for future edit feature
- **Solution**:
  - Implemented `updateLink()` with parameters: linkId (required), note, spaceId, tagIds (all optional)
  - Method updates link record in `links` table (note, space_id fields)
  - Handles tag association updates in `link_tags` junction table:
    - Removes all existing tag associations for the link
    - Creates new tag associations from provided tagIds array
    - Supports empty tagIds array (removes all tags)
  - Returns updated Link object from database
  - Comprehensive error handling with descriptive exception messages
  - Used by AddDetailsScreen.saveDetails() to persist optional details
- **Files Changed**:
  - `mobile/lib/features/links/services/link_service.dart` - Added updateLink() method (lines 132-195)
  - `mobile/test/features/links/services/link_service_test.dart` - Added update tests
- **Result**: ✅ Links can now be updated after creation (note, space, tags)

#### Tag Colors from Figma Design Palette (2025-11-14 00:35)
- **What**: Updated tag color palette to match Figma design specifications
- **Why**: Tags were using random colors that didn't match the design system
- **Solution**:
  - Replaced 7 generic colors with 14 Figma-specified colors
  - New palette includes: light green/teal, gray, pink, black, blue, green, peach, purple, yellow, dusty rose, light blue, lavender, bright blue, red
  - Colors are HEX codes matching exact Figma values (e.g., #7cfec4, #c3c3d1, #ff8da7)
  - Random selection ensures variety while maintaining design consistency
- **Files Changed**:
  - `mobile/lib/features/tags/services/tag_service.dart` - Updated _generateRandomColor() palette
- **Result**: ✅ Tags now use beautiful, design-system-approved colors

#### Thumbnail Image Loading with Caching (2025-11-13 22:20)
- **What**: Added real image loading for link thumbnails with caching support
- **Why**: Links were showing placeholder gradients even when thumbnail URLs existed
- **Solution**:
  - Added `cached_network_image: ^3.3.1` package for efficient image loading and caching
  - Rewrote LinkCard's `_buildImagePlaceholder()` to load actual thumbnail images
  - Extracted gradient placeholder to separate `_buildGradientPlaceholder()` method for fallback
  - Images automatically fall back to gradient placeholder when loading fails or URL is missing
- **Files Changed**:
  - `mobile/pubspec.yaml` - Added dependency
  - `mobile/lib/features/links/widgets/link_card.dart` - Implemented image loading
- **Result**: ✅ Link cards now display actual website thumbnails when available, improving visual recognition

### Fixed

#### Link Provider Not Rebuilding on Auth State Change (2025-11-14 00:20)
- **Problem**: When user logged in, links wouldn't load (empty state shown). When user logged out, old links remained visible. Links only appeared after adding a new link.
- **Root Cause**: `LinksNotifier.build()` used `ref.read(currentUserProvider)` which reads the value once and never watches for changes. Provider built once on first access and never rebuilt when auth state changed (login/logout events).
- **Solution**: Changed `ref.read(currentUserProvider)` to `ref.watch(currentUserProvider)` so the provider automatically rebuilds whenever the auth state changes (user logs in or out)
- **Files Changed**:
  - `mobile/lib/features/links/providers/link_provider.dart` - Changed read() to watch() on line 83
- **Result**: ✅ Links now load immediately on login and clear immediately on logout (reactive state management)

#### Missing Link Model Fields Causing Null Errors (2025-11-13 22:00)
- **Problem**: Link model was missing fields (domain, description, thumbnailUrl, normalizedUrl) that the database and metadata service were providing
- **Root Cause**: Model was created before metadata extraction feature was built, didn't include new fields
- **Solution**:
  - Added `normalizedUrl` (required String) - normalized version of URL for duplicate detection
  - Added `description` (nullable String) - page description from metadata
  - Added `thumbnailUrl` (nullable String) - thumbnail image URL from metadata
  - Added `domain` (nullable String) - extracted domain for grouping/display
  - Updated all related methods: constructor, fromJson, toJson, copyWith
  - Fixed test file to include new required `normalizedUrl` parameter
- **Files Changed**:
  - `mobile/lib/features/links/models/link_model.dart`
  - `mobile/test/features/links/widgets/link_card_test.dart`
- **Result**: ✅ Model now matches database schema and supports all metadata fields

#### Metadata Fetch Timeout Too Aggressive (2025-11-13 21:50)
- **Problem**: Links saved successfully but showed as "Untitled" with no images, despite metadata existing
- **Root Cause**: Two conflicting timeouts - MetadataService had 5s timeout, but AddLinkProvider added 3s timeout on top, causing premature cancellation before metadata could be fetched
- **Solution**:
  - Increased AddLinkProvider timeout from 3s to 10s to allow adequate fetch time
  - Added comprehensive logging throughout metadata fetch process for debugging
  - Metadata fetch failures now gracefully degrade (link still saves, just without metadata)
- **Files Changed**:
  - `mobile/lib/features/links/providers/add_link_provider.dart` - Increased timeout and added logging
  - `mobile/lib/shared/services/metadata_service.dart` - Added detailed logging
- **Result**: ✅ Metadata now fetches successfully for most websites, improving link previews

#### Link Model spaceId Null Safety Crash (2025-11-13 21:30)
- **Problem**: App crashed with `type 'Null' is not a subtype of type 'String' in type cast` when loading links
- **Root Cause**: Link model defined `spaceId` as non-nullable `String`, but database returns `null` when no space is assigned to a link
- **Solution**: Changed `spaceId` from `String` to `String?` (nullable) throughout the model
- **Files Changed**:
  - `mobile/lib/features/links/models/link_model.dart` - Made spaceId nullable
- **Result**: ✅ Links without spaces now load correctly without crashes

#### Foreign Key Constraint Violation When Saving Links (2025-11-13 21:00)
- **Problem**: Users couldn't save links - got `PostgrestException: insert or update on table "links" violates foreign key constraint "links_user_id_fkey"`
- **Root Cause**: User existed in `auth.users` (Supabase managed) but not in `public.users` (application schema). No automatic synchronization between the two tables.
- **Solution**:
  - Created database migration `004_create_user_trigger.sql`
  - Added trigger function `handle_new_user()` that automatically creates `public.users` record when `auth.users` record is inserted
  - Added backfill query to create `public.users` records for existing users
- **Files Changed**:
  - `supabase/migrations/004_create_user_trigger.sql` - Created trigger and backfill
- **Result**: ✅ Links now save successfully, trigger ensures future signups work automatically

---

## Notes

- This changelog follows the principles outlined in CLAUDE.md
- Each entry includes: Problem, Root Cause, Solution, Files Changed, and Result
- Dates are in YYYY-MM-DD HH:MM format (24-hour)
