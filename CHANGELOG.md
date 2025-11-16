# Changelog

All notable changes to the Anchor app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

#### Space Indicator on Link Cards (2025-11-16 12:00)
- **Feature**: Visual indicator showing which space a link belongs to
- **Implementation**: 4px colored stripe at top edge of link card thumbnail
- **Design**: Uses space's assigned color for instant visual recognition
- **Files Added**: None (enhanced existing LinkCard widget)
- **Files Changed**: `mobile/lib/features/links/widgets/link_card.dart`
- **Result**: ✅ Users can quickly identify link organization at a glance

#### Add to Space / Remove from Space Actions (2025-11-16 12:15)
- **Feature**: Complete space management from link action menu
- **Implementation**:
  - Dynamic action: "Add to Space" (if link has no space) or "Remove from Space" (if link is in a space)
  - Space picker bottom sheet for selecting destination space
  - Confirmation dialog for removal with space name
  - Success snackbar messages with space names
- **Files Added**: `mobile/lib/features/links/widgets/space_picker_sheet.dart`
- **Files Changed**: `mobile/lib/features/links/widgets/link_card.dart`
- **Result**: ✅ Users can organize links into spaces from any screen

#### Reusable StyledAddButton Component (2025-11-16 12:20)
- **Feature**: Consistent "+" button UI across app
- **Implementation**: Reusable widget with teal background, white plus icon, consistent sizing
- **Usage**: Space detail screen, Spaces screen header
- **Files Added**: `mobile/lib/shared/widgets/styled_add_button.dart`
- **Files Changed**: `mobile/lib/features/spaces/screens/space_detail_screen.dart`, `mobile/lib/features/spaces/screens/spaces_screen.dart`
- **Result**: ✅ Consistent UI pattern, DRY principle, easier maintenance

### Improved

#### Code Quality: Debug Log Cleanup (2025-11-16 12:30)
- **Issue**: 50+ verbose debug logs cluttering console output during development
- **Solution**: Systematic cleanup keeping only critical error/warning logs
- **Impact**:
  - Removed ~46 verbose flow-tracing logs (🔵 🟢 ✅ 🔍 📊)
  - Kept 15 critical logs (🔴 errors + ⚠️ warnings)
- **Files Changed**:
  - `mobile/lib/features/links/widgets/link_card.dart` (20 logs removed)
  - `mobile/lib/features/spaces/providers/space_provider.dart` (17 logs removed)
  - `mobile/lib/features/spaces/services/space_service.dart` (6 logs removed)
  - `mobile/lib/features/links/widgets/tag_picker_sheet.dart` (3 logs removed)
- **Result**: ✅ Cleaner console output, easier debugging, production-safe logging

#### Code Quality: Replaced Deprecated Color API (2025-11-16 12:45)
- **Issue**: 7 uses of deprecated `.withOpacity()` causing Flutter 3.x warnings
- **Solution**: Replaced with new `.withValues(alpha: ...)` API
- **Files Changed**:
  - `mobile/lib/features/links/widgets/link_action_sheet.dart` (3 replacements)
  - `mobile/lib/features/spaces/widgets/space_menu_bottom_sheet.dart` (4 replacements)
- **Result**: ✅ 0 deprecation warnings, future-proof code

#### Code Quality: Replaced print() with debugPrint() (2025-11-16 12:50)
- **Issue**: 4 production print() statements (not production-safe)
- **Solution**: Replaced with debugPrint() for debug-only logging
- **Files Changed**:
  - `mobile/lib/features/links/providers/add_link_provider.dart` (3 replacements)
  - `mobile/lib/features/links/screens/add_details_screen.dart` (1 replacement)
- **Result**: ✅ Production-safe logging, consistent with codebase standards

### Fixed

#### Space Menu Icon Rendering Issues (2025-11-16 00:00)
- **Problem**: SVG icons (`edit-01.svg`, `trash-01.svg`, `more-vertical.svg`) not visible or missing from assets
- **Root Cause**: SVG files either don't exist or have rendering issues in Flutter
- **Solution**: Replaced SVG icons with reliable Material icons:
  - `edit-01.svg` → Material `Icons.edit`
  - `trash-01.svg` → Existing `delete-02.svg` asset
  - `more-vertical.svg` → Material `Icons.more_vert`
- **Files Changed**: `mobile/lib/features/spaces/widgets/space_menu_bottom_sheet.dart`, `mobile/lib/features/spaces/screens/space_detail_screen.dart`
- **Result**: ✅ All icons now render correctly, menu fully functional

#### Default Spaces Showing Edit/Delete Menu (2025-11-16 00:05)
- **Problem**: Menu button appeared for default spaces (Unread, Reference) which cannot be edited or deleted
- **Root Cause**: No conditional logic to hide menu for default spaces
- **Solution**: Added conditional rendering `if (!currentSpace.isDefault)` around menu IconButton
- **Files Changed**: `mobile/lib/features/spaces/screens/space_detail_screen.dart` (line 106)
- **Result**: ✅ Menu only shows for custom spaces, default spaces remain protected

#### Keyboard Covering Edit Space Sheet (2025-11-16 00:10)
- **Problem**: When editing space name, keyboard appears but input field is hidden behind it
- **Root Cause**: Fixed height on EditSpaceSheet Container prevents natural resize with keyboard
- **Solution**: Removed `height: MediaQuery.of(context).size.height * 0.5` to allow natural keyboard adjustment
- **Files Changed**: `mobile/lib/features/spaces/widgets/space_menu_bottom_sheet.dart`
- **Result**: ✅ Input field visible and accessible when keyboard appears

#### RenderFlex Overflow in Edit Space Sheet (2025-11-16 00:15)
- **Problem**: Console error "A RenderFlex overflowed by 50 pixels on the bottom"
- **Root Cause**: `const Spacer()` conflicts with `mainAxisSize.min` in Column
- **Solution**: Replaced `const Spacer()` with `const SizedBox(height: 24)` for fixed spacing
- **Files Changed**: `mobile/lib/features/spaces/widgets/space_menu_bottom_sheet.dart`
- **Result**: ✅ No overflow errors, proper layout

#### Database RLS Policy Error on Space Update (2025-11-16 00:20)
- **Problem**: PostgreSQL error "more than one row returned by a subquery used as an expression (code: 21000)" when updating space name
- **Root Cause**: Buggy RLS policy in migration 002 with ambiguous WHERE clause in subquery returning multiple rows
- **Solution**:
  - Created migration 007 to drop old policy and use simpler approach
  - Replaced complex WITH CHECK subquery with database trigger to prevent `is_default` flag changes
  - New policy: `USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id)`
  - Trigger: `prevent_default_flag_change()` raises exception if `is_default` changes
- **Files Changed**:
  - Created `supabase/migrations/007_fix_update_space_policy.sql`
- **Result**: ✅ Space updates work correctly, default flag still protected

#### Space Name Not Updating in Header After Edit (2025-11-16 00:25)
- **Problem**: After editing space name and clicking save, header title still shows old name until navigating back
- **Root Cause**: Using stale `space` parameter instead of watching provider for real-time updates
- **Solution**:
  - Added `import '../providers/space_provider.dart';`
  - Watch `spacesProvider` to get updated space data
  - Use `currentSpace` from provider instead of stale parameter
  - Fallback to original space if not found
- **Files Changed**: `mobile/lib/features/spaces/screens/space_detail_screen.dart` (lines 66-76, 89, 102, 212)
- **Result**: ✅ Space name updates immediately in header after edit

#### Deleted Link Still Showing in Space (2025-11-16 00:30)
- **Problem**: After deleting a link from space detail screen, link card still appears until manual refresh
- **Root Cause**: Only invalidating `linksWithTagsProvider` (home screen), not `linksBySpaceProvider` (space screen)
- **Solution**: Added `ref.invalidate(linksBySpaceProvider(linkWithTags.link.spaceId!))` after deletion
- **Files Changed**: `mobile/lib/features/links/widgets/link_card.dart` (lines 153-155)
- **Result**: ✅ Deleted links disappear immediately from space detail screen

#### Missing Pull-to-Refresh in Space Detail Screen (2025-11-16 00:35)
- **Problem**: No way to manually refresh links in space detail screen
- **Root Cause**: RefreshIndicator not implemented
- **Solution**:
  - Wrapped `linksAsync.when()` with RefreshIndicator
  - Added `onRefresh` that invalidates `linksBySpaceProvider(space.id)` and waits for new data
  - Made error and empty states scrollable (wrapped in ListView) for pull-to-refresh to work
- **Files Changed**: `mobile/lib/features/spaces/screens/space_detail_screen.dart` (lines 129-246)
- **Result**: ✅ Users can pull to refresh links in any space

#### Tag Updates Not Reflecting in Space Detail Screen (2025-11-16 00:40)
- **Problem**: When updating tags on a link from space detail screen, changes don't appear
- **Root Cause**: Missing provider invalidation for `linksBySpaceProvider` after tag update
- **Solution**: Added `consumerRef.invalidate(linksBySpaceProvider(linkWithTags.link.spaceId!))` after tag update
- **Files Changed**: `mobile/lib/features/links/widgets/link_card.dart` (lines 251-254)
- **Result**: ✅ Tag updates reflect immediately in space detail screen

#### Links Disappearing When Adding Tags in Space (2025-11-16 00:45)
- **Problem**: Adding a new tag to a link causes the link to disappear from its space
- **Root Cause**: `updateLink()` was setting `space_id` to NULL because existing data wasn't being preserved
- **Solution**:
  - Preserve existing `note` and `spaceId` when calling `updateLink()` for tag changes
  - Pass `linkWithTags.link.note` and `linkWithTags.link.spaceId` along with new `tagIds`
- **Files Changed**: `mobile/lib/features/links/widgets/link_card.dart` (lines 237-241)
- **Result**: ✅ Links stay in their assigned space when tags are updated

#### Custom Spaces Showing Wrong Colors in Picker (2025-11-16 00:50)
- **Problem**: Custom spaces all show green color in space picker instead of their actual assigned colors
- **Root Cause**: Hardcoded `_getSpaceColor()` function defaulting to green for unknown space names
- **Solution**:
  - Deleted `_getSpaceColor()` method
  - Added `_parseColor()` method that reads actual `space.color` from database
  - Changed line 440 from `color: _getSpaceColor(space.name)` to `color: _parseColor(space.color)`
- **Files Changed**: `mobile/lib/features/links/screens/add_details_screen.dart` (deleted lines 469-485, added lines 469-491, modified line 440)
- **Result**: ✅ Space picker displays correct colors for all spaces (default and custom)

#### New Links Not Appearing in Space After Assignment (2025-11-16 00:55)
- **Problem**: When adding a link and assigning it to a space, link doesn't appear in that space until manual refresh
- **Root Cause**: Only invalidating `initialSpaceId`, not final space if user changed it in details screen
- **Solution**:
  - Read final `spaceId` from `ref.read(addLinkProvider).spaceId` (the actual assigned space)
  - Invalidate `linksBySpaceProvider(finalSpaceId)` instead of `initialSpaceId`
  - Handles ALL scenarios: add from home, add from space, change space in details
- **Files Changed**: `mobile/lib/features/links/screens/add_link_flow_screen.dart` (lines 84-98)
- **Result**: ✅ New links appear immediately in their assigned space

#### Spaces + Button Visual Style Update (2025-11-16 01:00)
- **Problem**: Spaces screen "+" button was basic IconButton, inconsistent with home screen FAB style
- **Root Cause**: Using simple IconButton instead of Material design with elevation and circular shape
- **Solution**:
  - Added design system import
  - Replaced IconButton with Material/InkWell combination
  - Used correct brand color (AnchorColors.anchorTeal = #0D9488) instead of wrong custom teal (#075a52)
  - Added 2dp elevation for subtle shadow (AppBar context)
  - Perfect circle shape with CircleBorder
  - White icon at 24px for AppBar context (vs 56px FAB)
  - Material ripple effect on tap via InkWell
- **Files Changed**: `mobile/lib/features/spaces/screens/spaces_screen.dart` (added import line 25, replaced lines 199-206)
- **Result**: ✅ Spaces + button now matches home screen FAB style with correct brand color and elevation

### Added

#### Create Space Feature - Complete 2-Step Flow (2025-11-15 18:00)
- **What**: Full Create Space flow accessible from Spaces screen + button
- **Why**: Users need ability to create custom spaces beyond default "Unread" and "Reference" spaces
- **Solution**:
  - Created 2-step modal bottom sheet flow matching Figma design exactly:
    - Step 1: Name Input - Auto-focused text field that opens keyboard immediately, validates input (1-50 chars, trims whitespace), disabled "Next" button when empty
    - Step 2: Color Picker - Grid of 14 design-approved colors, large 84x84 preview when selected, dynamic button text ("Next" → "Save and finish")
  - PageView with disabled swipe for controlled navigation between steps
  - Color palette from Figma: 14 specific hex codes (#7cfec4, #c3c3d1, #ff8da7, #000002, #15afcf, #1ac47f, #ffdcd4, #7e30d1, #fff273, #c5a3af, #97cdd3, #c2b8d9, #1773fa, #ed404d)
  - Implemented `createSpace()` method in SpacesNotifier provider:
    - Validates user authentication
    - Validates space name (1-50 characters, non-empty after trim)
    - Creates space via SpaceService
    - Automatically refreshes spaces list to show new space
    - Error handling with user-friendly messages
  - Success SnackBar confirmation: "Space '[name]' created!"
  - Loading state with CircularProgressIndicator during creation
  - Graceful error handling with error SnackBar if creation fails
  - Responsive layout using Spacer widgets instead of fixed heights
- **Files Changed**:
  - `mobile/lib/features/spaces/widgets/create_space_bottom_sheet.dart` - Created 2-step bottom sheet widget (500+ lines)
  - `mobile/lib/features/spaces/providers/space_provider.dart` - Added createSpace() method with validation
  - `mobile/lib/features/spaces/screens/spaces_screen.dart` - Enabled + button, added _showCreateSpaceSheet() method
  - `mobile/test/features/spaces/widgets/create_space_bottom_sheet_test.dart` - Created 11 comprehensive widget tests (TDD)
- **Testing**: ✅ All 11 widget tests passing (TDD approach - tests written first, then implementation)
- **Result**: ✅ Users can now create custom spaces with personalized names and colors, spaces appear immediately in list

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

#### Duplicate Spaces Database Fetches on App Launch (2025-11-15 17:35)
- **Problem**: On app launch, `spacesProvider` was making duplicate database queries - fetching spaces 2 times with the same authenticated user instead of once. This caused unnecessary database load and wasted API calls. Debug logs revealed 3 total provider builds: one with null user (before auth loads), then TWO builds with the authenticated user.
- **Root Cause**: The `spacesProvider` depends on `currentUserProvider` via `ref.watch(currentUserProvider)`. When auth state changes from "not ready" → "ready", the provider dependency chain triggers a rebuild. Without `.autoDispose`, Riverpod was rebuilding the provider multiple times during the auth state transition, causing duplicate fetches with the same user ID.
- **Solution**:
  - Added `.autoDispose` modifier to `spacesProvider` (changed from `AsyncNotifierProvider` to `AsyncNotifierProvider.autoDispose`)
  - Updated `SpacesNotifier` to extend `AutoDisposeAsyncNotifier` instead of `AsyncNotifier`
  - Added comprehensive debug logging with `debugPrint()` and stack traces to track provider lifecycle
  - `.autoDispose` manages provider lifecycle better - disposes when not watched, prevents stale state, and eliminates duplicate builds during auth transitions
- **Files Changed**:
  - `mobile/lib/features/spaces/providers/space_provider.dart` - Added .autoDispose modifier and debug logging
- **Testing**: Verified with debug logs - now only 2 builds occur (one with null user before auth, one with authenticated user), eliminating the duplicate fetch
- **Result**: ✅ Single database query on app launch instead of duplicate, reduced database load by 50%

#### Space Provider Not Rebuilding on Auth State Change (2025-11-15 16:15)
- **Problem**: Spaces screen showed "No spaces yet" even though default spaces existed in database. Spaces never appeared even after login. Debug logs showed SpaceService.getSpaces() was never being called.
- **Root Cause**: `SpacesNotifier.build()` used `ref.read(currentUserProvider)` which reads the value once and never watches for changes. Provider built once when app started (before user authenticated) and never rebuilt when auth state changed (login event). This is IDENTICAL to the bug that was fixed for LinksProvider.
- **Solution**: Changed `ref.read(currentUserProvider)` to `ref.watch(currentUserProvider)` so the provider automatically rebuilds whenever the auth state changes (user logs in or out). Added comment to prevent future regression.
- **Files Changed**:
  - `mobile/lib/features/spaces/providers/space_provider.dart` - Changed read() to watch() on line 88, added warning comment
- **Result**: ✅ Spaces now load immediately on login and clear immediately on logout (reactive state management)

#### Missing Default Spaces for Existing Users (2025-11-15 14:30)
- **Problem**: Users who signed up before migrations were created saw "No spaces yet" message instead of default "Unread" and "Reference" spaces
- **Root Cause**: Database trigger in migration 002 only fires for NEW user signups. When migration 004 backfilled existing auth.users into public.users, it used `ON CONFLICT DO NOTHING` which prevented the INSERT, so the trigger never fired. Existing users ended up with public.users records but no default spaces.
- **Solution**:
  - Created migration 005_backfill_default_spaces.sql
  - Finds all users without spaces and creates "Unread" (purple #9333EA) and "Reference" (red #DC2626) spaces
  - Uses ON CONFLICT to make it idempotent (safe to run multiple times)
  - Includes verification queries to check all users have default spaces
  - Fixed 2 lint warnings in SpaceService (removed unnecessary type casts)
  - Updated SpacesScreen comment to clarify trigger handles NEW users, migration handles EXISTING users
- **Files Changed**:
  - `supabase/migrations/005_backfill_default_spaces.sql` - Created backfill migration
  - `mobile/lib/features/spaces/services/space_service.dart` - Removed unnecessary casts, added debug logging
  - `mobile/lib/features/spaces/screens/spaces_screen.dart` - Updated comment to reference both migrations
- **Result**: ✅ All users (new and existing) now have default Unread and Reference spaces

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
