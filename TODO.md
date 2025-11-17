# TODO & Project Roadmap

**Last Updated:** 2025-11-17 17:00

This file tracks active tasks, planned features, known issues, and future ideas for the Anchor App.

**Format:**
- ✅ Completed
- 🚧 In Progress
- 📋 Planned (not started)
- 🐛 Known Issue
- 💡 Future Idea

---

## 🚧 Active Tasks

### High Priority Tasks (2025-11-17)

🚧 **Fix Remaining Test Failures** (In Progress) 🟡 LOW RISK
- **Current Status**: 219 passing ✅, 1 skipped ⏭️, 18 failing ❌
- **Progress**: 26 tests fixed from original 44 failures (59.1% complete) 📈
  - ✅ Link Model tests: 8/8 fixed (missing normalized_url, description, etc.)
  - ✅ Link Service tests: 2/2 fixed (getLinksWithTags tests)
  - ✅ Test compilation errors: 17 fixed (Supabase mocking, provider overrides)
  - ✅ Space Detail Screen tests: 6/6 fixed (2025-11-17 17:00) - provider override syntax
  - 🐛 Remaining: 18 runtime test failures (need investigation)
- **Latest Fix (2025-11-17 17:00)**: Fixed space_detail_screen_test.dart compilation errors
  - Changed provider overrides from instance to family: `linksBySpaceProvider.overrideWith()`
  - Updated mock to extend actual `LinksBySpaceNotifier` class
  - All 6 space detail screen tests now passing
- **Priority:** HIGH (TDD compliance)
- **Impact:** Restores full test coverage and verification

---

## 📋 Planned Features

### High Priority
- 📋 **Tag management UI** - Create/edit/delete tags from dedicated screen (currently tags created inline only)
- 📋 **Full-text search** - Make SearchBarWidget functional (currently visual only)
- 📋 **iOS/Android Share Extension** ⭐ CRITICAL UX - Save links from any app via system share sheet
  - **Current State**: NOT STARTED - Users can only save via in-app FAB button
  - **Impact**: Major UX limitation - cannot share Safari/Chrome/Twitter links → Anchor
  - **Why Deferred**: Focused on core app (auth, home screen, spaces) first
  - **Phase**: Originally Phase 2, now deferred to Phase 6 (post-MVP)
  - **Complexity**: High - Requires native code (Swift for iOS, Kotlin for Android)
  - **Estimated Time**: 2-3 weeks
  - **Technical Requirements**:
    - iOS: Share Extension target in Xcode, Swift code for intent handling
    - Android: Intent filter in AndroidManifest.xml, Kotlin activity for ACTION_SEND
    - Flutter: Platform channels to communicate between native → Dart
    - Deep linking: Handle app launch from share sheet
  - **Workaround**: Users currently open Anchor app → tap FAB → paste URL manually
  - **Reference**: See PRD lines 175-210 for detailed AC1-AC3 acceptance criteria

### Medium Priority
- 📋 **Link sharing** - Share saved links with others
- 📋 **Offline mode** - Work without internet (already cached)

### Low Priority
- 📋 **Dark mode** - System-based theme switching
- 📋 **Import links** - From browser bookmarks
- 📋 **Export links** - To CSV/JSON
- 📋 **Link analytics** - Track usage stats
- 📋 **Browser extension** - Save from desktop

---

## 🐛 Known Issues

### Test Failures - 18 Remaining (2025-11-17 17:00)
- **Current Status**: 219 passing ✅ | 1 skipped ⏭️ | 18 failing ❌
- **Original**: 44 test failures
- **Progress**: 26 fixed, 18 remaining (59.1% complete) 📈
- **Fixed**:
  - ✅ Link Model tests (8/8) - Added missing fields to test data
  - ✅ Link Service `getLinksWithTags()` tests (2/2) - Added missing fields
  - ✅ Test compilation errors (17/17) - Fixed Supabase mocking and provider overrides
  - ✅ Space Detail Screen tests (6/6) - Fixed provider override syntax (2025-11-17 17:00)
- **Current Blockers**:
  - 🐛 **Runtime failures**: 18 tests with business logic issues (need investigation)
- **Impact**: Partial TDD compliance, most features verified
- **Priority**: HIGH (TDD compliance required)

---

## ✅ Recently Completed (Last 7 Days)

### 2025-11-17 Evening: Space Detail Screen Test Fixes 🧪

**Space Detail Screen Tests - Provider Override Fix (17:00)** ✅ 🟡 LOW RISK
- ✅ Fixed 6 compilation errors in space_detail_screen_test.dart
- ✅ Changed provider overrides from instance to family: `linksBySpaceProvider.overrideWith()`
- ✅ Updated MockLinksBySpaceNotifier to extend actual LinksBySpaceNotifier class
- ✅ Fixed "loading indicator" test to cleanup pending timer
- ✅ Reduced mock delay from 1 second to 100ms for faster tests
- **Root Cause**: Incorrect Riverpod family provider override syntax
- **Impact**: All 6 space detail screen tests now passing, TDD workflow restored
- **Test Progress**: 213 → 219 passing, 19 → 18 failing (59.1% complete)
- **Files Changed**: `mobile/test/features/spaces/screens/space_detail_screen_test.dart`

### 2025-11-17 Afternoon: README.md Critical Alignment 📚

**README.md Documentation Fixes (16:00-16:30)** ✅ 🟢 SAFE
- ✅ Fixed all broken documentation links (`docs/PRD/` → `PRD/`)
- ✅ Added prominent AMENDMENTS.md reference with warning at top of Documentation section
- ✅ Updated development roadmap to reflect actual Phase 5 (70% complete) instead of Phase 0 (10%)
  - Marked Phase 0-4 as ✅ COMPLETE with detailed feature lists
  - Marked Phase 5 as 🔄 IN PROGRESS (Current)
  - Marked Phase 6 as 📋 NOT STARTED
- ✅ Fixed project structure diagram (removed non-existent `docs/` directory, added actual files)
- ✅ Updated version number from 0.1.0 (Pre-Alpha) → 0.7.0 (Beta)
- ✅ Clarified success metrics with "Post-Launch" and beta status note
- ✅ Updated Contributing section with links to CHANGELOG, TODO, claude.md
- **Root Cause**: Documentation not updated as project progressed through phases
- **Impact**: New developers/stakeholders now have accurate understanding of 70% project completion
- **Files Changed**: `README.md` (8 sections), `CHANGELOG.md` (added entry), `TODO.md` (this entry)
- **Reference**: See AMENDMENTS_README_ALIGNMENT_REPORT.md for complete audit findings
- **Alignment**: Implements critical fixes from documentation audit (Findings #1-3, #5-7)

### 2025-11-17 Morning: URL Shortener Support 🎉

**URL Shortener Metadata Extraction (08:00-08:30)** ✅
- ✅ Fixed metadata not displaying for shortened URLs (bit.ly, t.co, share.google)
- ✅ Created `fetchMetadataWithFinalUrl()` method in MetadataService
- ✅ Method captures final destination URL after following all redirects
- ✅ Uses `http.Request` + `client.send()` to access redirect information
- ✅ Returns tuple `(LinkMetadata, String finalUrl)` for both metadata and expanded URL
- ✅ Updated AddLinkProvider to save final URLs instead of short URLs
- ✅ Domain now matches metadata source (no more confusion)
- ✅ Added 6 comprehensive unit tests for redirect scenarios
- ✅ All 16 metadata service tests passing
- ✅ Comprehensive debug logging tracks redirects (📡🔀 emojis)
- ✅ Maintains backward compatibility with original `fetchMetadata()` method
- **Impact**: Users can now save shortened URLs and see metadata immediately
- **Example**: `https://share.google/abc` → expands to → `https://apple.com/vision-pro`

### 2025-11-16: Major UI/UX Improvements & Bug Fixes 🎉

**Critical UX: Tap to Open Links (13:00)** ✅ ⭐
- ✅ Added onTap gesture to LinkCard widget
- ✅ Opens URLs in external browser using url_launcher
- ✅ Comprehensive error handling with user-friendly messages
- **Impact**: CRITICAL - Users can now actually use their saved links!

**Space Management Features (12:00-12:20)** ✅
- ✅ Space indicator on link cards (4px colored stripe at top of thumbnail)
- ✅ Add to Space / Remove from Space actions in link action menu
- ✅ Space picker bottom sheet for selecting destination space
- ✅ Reusable StyledAddButton component (consistent UI across app)
- **Impact**: Better visual organization and link management

**Code Quality Improvements (12:30-12:50)** ✅
- ✅ Debug log cleanup (removed 46 verbose logs, kept 15 critical)
- ✅ Replaced deprecated `.withOpacity()` with `.withValues(alpha: ...)` (7 replacements)
- ✅ Replaced `print()` with `debugPrint()` (4 replacements)
- **Impact**: Cleaner console, no deprecation warnings, production-safe logging

**Space-Related Bug Fixes (00:00-01:00)** ✅
- ✅ Fixed space menu icon rendering issues (SVG → Material icons)
- ✅ Fixed default spaces showing edit/delete menu (now protected)
- ✅ Fixed keyboard covering edit space sheet
- ✅ Fixed RenderFlex overflow in edit space sheet
- ✅ Fixed database RLS policy error on space update
- ✅ Fixed space name not updating in header after edit
- ✅ Fixed deleted link still showing in space (provider invalidation)
- ✅ Added pull-to-refresh in space detail screen
- ✅ Fixed tag updates not reflecting in space detail screen
- ✅ Fixed links disappearing when adding tags in space
- ✅ Fixed custom spaces showing wrong colors in picker
- ✅ Fixed new links not appearing in space after assignment
- ✅ Fixed Spaces + button visual style (brand color, elevation)
- **Impact**: Space management now fully functional and bug-free

**Test Fixes (16:15)** ✅
- ✅ Fixed 17 test compilation errors
- ✅ Supabase mock return type mismatches resolved
- ✅ Provider override syntax corrected
- **Impact**: Restored TDD workflow, tests compile again

### 2025-11-14 Night: Major Feature Completions 🎉

**Sprint 2 COMPLETE: Add Link Feature (00:00-01:00)**
- ✅ Complete Add Link flow (4 screens: URL Input → Metadata → Success → Add Details)
- ✅ URL input with real-time validation
- ✅ Automatic metadata extraction (title, description, thumbnail, domain)
- ✅ Optional details screen with 3 tabs (Tag / Note / Space)
- ✅ Tag autocomplete with comma/newline separation
- ✅ Space assignment picker
- ✅ Personal notes text area
- ✅ Modal bottom sheet with DraggableScrollableSheet
- ✅ Graceful degradation for metadata timeouts
- ✅ All tests passing (68+ tests)

**Settings & Logout Feature (00:45)**
- ✅ Created Settings screen accessible via avatar tap
- ✅ Email display (read-only)
- ✅ Sign out button with confirmation dialog
- ✅ Proper error handling for logout failures
- ✅ Integrated into router as protected route

**Link Service Enhancements (00:30)**
- ✅ Added `updateLink()` method for editing links
- ✅ Handles note, space, and tag updates
- ✅ Tag association updates via junction table
- ✅ Comprehensive error handling
- ✅ Used by AddDetailsScreen for persisting optional details

**Design System Updates (00:35)**
- ✅ Updated tag color palette to match Figma (14 colors)
- ✅ Exact HEX values from design specifications
- ✅ Replaced 7 generic colors with design-approved palette

**Critical Bug Fix: Link Provider Auth (00:20)**
- ✅ Fixed links not loading after login/logout
- ✅ Changed `ref.read()` to `ref.watch()` for reactive rebuilding
- ✅ Links now load immediately on login
- ✅ Links clear immediately on logout

### 2025-11-13 Evening: Crash Recovery & Code Quality

**Claude Crash Recovery (20:00-21:00)**
- ✅ Recovered from mid-development crash
- ✅ Fixed 52 analyzer errors → 0 errors
- ✅ Added `library;` directives to 15+ files
- ✅ Fixed deprecated `.withOpacity()` → `.withValues()`
- ✅ Removed unnecessary casts and unused imports
- ✅ Committed LinkService implementation

**LinkService Implementation (16:30-20:00)**
- ✅ Created `createLink()` method with tag association support
- ✅ Created `getLinksWithTags()` method for fetching links
- ✅ Added comprehensive error handling
- ✅ Production-ready implementation (0 analyzer errors)

### 2025-11-13 Afternoon: Home Screen Complete

**Phase 6: Navigation & Polish (Completed)**
- ✅ Added pull-to-refresh functionality
- ✅ Tested responsive layout on multiple sizes
- ✅ Added FAB for Add Link (wired up next)

**Phase 5: Home Screen UI (Completed)**
- ✅ Implemented home screen header with avatar and search
- ✅ Implemented link cards grid with GridView
- ✅ Added loading skeleton for link cards
- ✅ Added empty state for home screen

**Phase 4: UI Components (Completed)**
- ✅ Created TagBadge widget with colored pills
- ✅ Created LinkCard widget matching Figma design
- ✅ Created SearchBar widget (visual only)
- ✅ All widgets responsive and tested

**Phase 3: State Management (Completed)**
- ✅ Created Link providers for state management
- ✅ Created Space providers
- ✅ Integrated with Riverpod for reactivity

**Phase 2: Services (Completed)**
- ✅ Created SpaceService for space management
- ✅ Created LinkService for link operations
- ✅ Created MetadataService for URL metadata fetching
- ✅ Created URL validation utility

**Phase 1: Data Models (Completed)**
- ✅ Created Link model with 8 comprehensive tests
- ✅ Created Tag model with 6 comprehensive tests
- ✅ Created Space model with full test coverage
- ✅ All model tests passing

### Earlier Today: Auth & Documentation

**Auth Fixes (13:00-15:00)**
- ✅ Fixed signup redirect to onboarding issue
- ✅ Configured email confirmation deep link
- ✅ Replaced 70 print() statements with logger
- ✅ Fixed 79 analyzer warnings → 0 warnings
- ✅ Added DeepLinkService tests (10 tests)
- ✅ Added SplashScreen tests (12 tests)
- ✅ Fixed BuildContext async gap
- ✅ Fixed password reset race conditions

**Documentation (14:00-16:00)**
- ✅ Created CHANGELOG.md
- ✅ Created TODO.md (this file)
- ✅ Updated CLAUDE.md with TDD and documentation workflows
- ✅ Analyzed Figma design for implementation

---

## 💡 Future Ideas

*Ideas to consider for future releases:*

- 💡 Browser extension for easy link saving
- 💡 Collaboration features (shared spaces)
- 💡 AI-powered link categorization (Smart Space Suggestions)
- 💡 Integration with Notion, Evernote
- 💡 Mobile widget for quick link access
- 💡 Voice commands for adding links
- 💡 Smart notifications (remind about saved links)
- 💡 Space Analytics & Insights (usage tracking, idle space warnings)

---

## 🚫 Explicitly Rejected Ideas

*Features we've consciously decided NOT to implement (documented for future reference)*

### ❌ Space Templates
- **Proposed Feature:**
  - Predefined space sets for different user types
  - Designer template: "Inspiration", "Resources", "Clients"
  - Developer template: "Docs", "Tutorials", "Libraries"
  - Researcher template: "Papers", "Data", "Tools"
  - One-click setup for new users
- **Why Not:** Too prescriptive - users prefer creating their own spaces organically based on their actual needs. Templates could limit creativity and impose structure that doesn't match their workflow. The two default spaces (Unread, Reference) are sufficient for onboarding.
- **Alternative:** Let users discover space organization naturally, provide examples in onboarding/help docs instead
- **Decision Date:** 2025-11-17
- **Reference:** See AMENDMENTS.md for Spaces-Only model philosophy

### ❌ Bulk Operations
- **Proposed Feature:**
  - Select multiple links at once
  - Batch actions: "Move all to Reference", "Delete selected"
  - Archive old links: Move all links >90 days to "Archive" space
  - Export space: Share all links in a space
- **Why Not:** Adds significant UI/UX complexity for MVP. Single-link operations are sufficient for initial use cases. Bulk operations are power-user features that can be added post-launch if user research shows demand.
- **Alternative:** Optimize single-link operations to be fast enough that bulk isn't needed initially
- **Decision Date:** 2025-11-17
- **Status:** Could be reconsidered post-MVP based on user feedback

### ❌ Status Field System
- **Proposed Feature:** Separate database field for link status ('unread', 'reference') in addition to spaces
- **Why Not:** Would reintroduce dual organizational systems (status + spaces) causing conflicts and user confusion. Spaces already serve the purpose of organizing links by their read/reference status.
- **Decision Date:** November 2025
- **Reference:** See AMENDMENTS.md for complete analysis of conflicts

### ❌ Nested Spaces / Folder Hierarchy
- **Proposed Feature:** Allow spaces to contain sub-spaces (folder hierarchy)
- **Why Not:** Adds unnecessary complexity that users don't need. Flat space structure is simpler and more visual. Tags already provide cross-cutting organization.
- **Decision Date:** November 2025
- **Reference:** AMENDMENTS.md - keeps architecture clean

### ❌ Smart Lists (iOS Reminders-style)
- **Proposed Feature:** Auto-populating lists based on rules (e.g., "All links from last week")
- **Why Not:** Would conflict with spaces + tags paradigm. Tags already provide flexible filtering across spaces. Smart lists add cognitive overhead.
- **Decision Date:** November 2025
- **Alternative:** Use combination of spaces + tags + search for dynamic organization

---

## 📝 Notes

### Testing Strategy
- All new features must have unit tests (TDD approach)
- Test coverage goal: 80%+ for core features
- **Current test count: 111+ tests** (97 existing + 14 model tests)
- ⚠️ LinkService tests need mocking strategy refinement

### Code Quality
- ✅ **0 analyzer errors** (as of 2025-11-13 21:00)
- ⚠️ 14 minor warnings/info (non-blocking)
- ✅ Use proper logging (no print statements)
- ✅ Follow Flutter/Dart style guide
- ✅ Document all public APIs

### Authentication Status
- ✅ Email/password signup working
- ✅ Email confirmation flow working
- ✅ Password reset working
- ✅ Deep linking configured
- ✅ Session management working
- 📋 OAuth (Google) - needs testing

### Data Models Status
- ✅ Link model (8 tests passing)
- ✅ Tag model (6 tests passing)
- ✅ Space model (tests passing)

### Services Status
- ✅ LinkService (implementation complete)
- ✅ SpaceService (complete)
- ✅ MetadataService (complete)
- ✅ URL validation utility (complete)

### UI Components Status
- ✅ LinkCard widget (complete, responsive)
- ✅ TagBadge widget (complete)
- ✅ SearchBar widget (visual complete)
- ✅ Home screen (complete)

### Database Status
- ✅ Supabase migrations applied
- ✅ Tables created: users, spaces, links, tags, link_tags
- ✅ RLS policies active
- ✅ Default spaces auto-create for new users

---

## 🔄 How to Use This File

**When starting a new task:**
1. Move item from "Planned Features" to "Active Tasks"
2. Add 🚧 emoji and today's date
3. Update "Last Updated" at top

**When completing a task:**
1. Move from "Active Tasks" to "Recently Completed"
2. Change 🚧 to ✅ and add completion time
3. Add entry to CHANGELOG.md with details
4. Update "Last Updated" at top

**When discovering a bug:**
1. Add to "Known Issues" section with 🐛 emoji
2. Include description and reproduction steps
3. Create GitHub issue if appropriate

**When planning ahead:**
1. Add to "Planned Features" with 📋 emoji
2. Assign priority level
3. Add any notes or requirements

**Weekly cleanup:**
1. Move old completed items (>7 days) to CHANGELOG.md
2. Re-prioritize planned features
3. Review future ideas for promotion to planned

---

## 🎯 Current Sprint Status

**Sprint 1: Home Screen MVP** ✅ **COMPLETE!**

~~**Goal:** Build a working home screen that displays saved links from Supabase~~ ✅

**Deliverables:**
- ✅ Phase 1: Data models (Link, Tag, Space) - **COMPLETE**
- ✅ Phase 2: Services (LinkService, SpaceService) - **COMPLETE**
- ✅ Phase 3: State management (Providers) - **COMPLETE**
- ✅ Phase 4: UI components (LinkCard, TagBadge, SearchBar) - **COMPLETE**
- ✅ Phase 5: Home screen implementation - **COMPLETE**
- ✅ Phase 6: Navigation & polish - **COMPLETE**

**Success Criteria:**
- ✅ User can see list of saved links on home screen
- ✅ Links display with thumbnails, titles, notes, and tags
- ✅ Pull-to-refresh works
- ✅ Responsive on all device sizes
- ⚠️ Most tests passing (mocking strategy needs work)

**Completed:** 2025-11-13 ✅

---

## 🎯 Previous Sprint: Add Link Feature ✅ COMPLETE

**Sprint 2: Add Link Functionality (2025-11-13 to 2025-11-14)**

**Goal:** Allow users to save new links from within the app ✅

**Deliverables:**
- ✅ Backend: LinkService.createLink() - **COMPLETE**
- ✅ Backend: LinkService.updateLink() - **COMPLETE**
- ✅ UI: Add Link bottom sheet - **COMPLETE**
- ✅ UI: Form with URL, space, tags, notes - **COMPLETE**
- ✅ Integration: Wire FAB to open sheet - **COMPLETE**
- ✅ Integration: Save link and refresh home - **COMPLETE**
- ✅ Polish: Success/error states - **COMPLETE**

**Success Criteria:**
- ✅ User can tap FAB to add link
- ✅ User can enter URL and see metadata
- ✅ User can select space and add tags
- ✅ User can add personal note
- ✅ Link appears on home screen after save
- ✅ Clear success feedback shown

**Completed:** 2025-11-14 01:00 ✅ (1 day ahead of schedule!)

---

## 🎯 Sprint 3: Enhanced Link Management ✅ COMPLETE

**Sprint 3: Link Editing & Organization (2025-11-15 to 2025-11-16)** ✅

**Goal:** Allow users to edit existing links and improve organization ✅

**Deliverables:**
- ✅ Tap to open link in browser (2025-11-16 13:00) ⭐ CRITICAL
- ✅ Edit link functionality via action menu (tags, notes, space)
- ✅ Delete link functionality with confirmation dialog
- ✅ Long-press menu on LinkCard (opens action sheet)
- ✅ Add to Space / Remove from Space actions
- ✅ Space picker for link organization

**Success Criteria:**
- ✅ User can tap link card to open in browser
- ✅ User can edit link metadata after creation (via action menu)
- ✅ User can delete unwanted links (with confirmation)
- ✅ User can move links between spaces
- ✅ Changes reflect immediately in UI

**Completed:** 2025-11-16 (1 day ahead of schedule!) 🎉

---

*This file is a living document - update it frequently as work progresses!*
