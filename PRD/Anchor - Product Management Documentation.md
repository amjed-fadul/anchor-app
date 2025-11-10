# Anchor - Product Management Documentation

**Version:** 2.0

**Date:** November 2025

**Document Owner:** Product Management

**Status:** Design Complete - Ready for Development

---

## Executive Summary

### Elevator Pitch

Anchor helps people save links from their phone and actually find them later by organizing into spaces and remembering why they saved them.

**Tagline:** "Anchored! Find it anytime" by remembering why they saved them.

### Problem Statement

Users save links across multiple platforms (Telegram, Notes, browser bookmarks) but can never find them later, and even when they do, they've forgotten why the link was important. This results in hundreds of saved but unused links, wasted time searching, and lost valuable information.

### Target Audience

**Primary Users:**

**Designers & Creatives** (25-40 years old)

- Save 15-25 links/week
- Need visual inspiration boards
- Use mobile + desktop daily
- High aesthetic expectations

**Knowledge Workers** (28-45 years old)

- Save 20-30 links/week
- Research-heavy workflows
- Multi-device usage patterns
- Value search accuracy over organization

**Content Creators** (22-38 years old)

- Save 10-20 links/week
- Reference material collectors
- Mobile-first behavior
- Need quick access during creation

**Students & Researchers** (18-35 years old)

- Save 15-40 links/week
- Academic/educational focus
- Budget-conscious
- Need citation-ready information

**Behavioral Characteristics:**

- Currently frustrated with existing solutions
- Willing to try new apps if onboarding is simple
- Expect cross-platform sync "to just work"
- Won't tolerate complex organization systems
- Value speed over features

### Unique Selling Proposition

**"Anchored! Find it anytime"**

Anchor is the only link manager that:

1. Saves in under 1 second from any app (instant save, no modal)
2. Organizes into visual spaces (collections you can browse)
3. Lets you add context when you have time (tags + notes, optional)
4. Syncs instantly across all devices

**vs. Pocket:** Not shutting down, actively maintained, has spaces + context notes

**vs. Raindrop:** Simpler, faster, more mobile-first, no privacy concerns

**vs. Browser Bookmarks:** Cross-platform, organized into spaces, visual browsing, searchable

**vs. Pocket:** Not shutting down, actually maintained, has context notes

**vs. Raindrop:** Cheaper ($0 vs $28/year for core features), simpler, no privacy concerns

**vs. Browser Bookmarks:** Cross-platform, searchable, visual, metadata-rich

### Success Metrics

**MVP Launch Goals (First 90 Days):**

- **Acquisition:** 1,000 active users
- **Engagement:** 10,000+ total links saved
- **Retention:** 35%+ week-1 retention (adjusted from 40% based on productivity app benchmarks)
- **Usage:** Average 5+ saves per user per week
- **Quality:** 4.5+ app store rating, <0.5% crash rate
- **Performance:** <3 seconds save time, <500ms search results

---

## Technical Architecture Decisions

### Backend: Supabase (SELECTED)

**Decision Rationale:**

After evaluating Firebase vs. Supabase, **Supabase is the optimal choice** for Anchor based on:

**1. Cost Structure**

- Supabase Free Tier: 500MB database, 1GB storage, 100K MAU auth
- Firebase Free Tier: 1GB storage, 10K MAU auth, BUT charges per read/write
- **Critical Difference:** Anchor will have high read volumes (search, browse, sync). Supabase doesn't charge per query; Firebase charges per document read.
- **Projected Cost at 1,000 users:** Supabase = $0 (within free tier), Firebase = $15-30/month in read costs
- **Projected Cost at 10,000 users:** Supabase = $25/month (Pro plan), Firebase = $150-300/month

**2. Search Capabilities**

- Supabase: PostgreSQL full-text search built-in, supports fuzzy matching with trigrams
- Firebase: No native search; requires third-party integration (Algolia = $1/month minimum, ElasticSearch = complex setup)
- **Impact:** Search is a core feature. Supabase enables this without additional services.

**3. Query Complexity**

- Supabase: SQL joins, complex filtering, aggregations in single query
- Firebase: Limited querying, no joins, requires denormalization and multiple reads
- **Impact:** Features like "find all links with tag X saved this week" are trivial in SQL, complex in NoSQL

**4. Real-Time Sync**

- Both support real-time updates
- Supabase: PostgreSQL logical replication (stable, battle-tested)
- Firebase: Firestore real-time listeners (excellent, mature)
- **Verdict:** Tie, both are excellent

**5. Developer Experience**

- Supabase: SQL knowledge required, excellent documentation, open-source
- Firebase: Easier learning curve, extensive community, Google backing
- **Impact:** Single developer project benefits from Supabase's straightforward SQL vs. Firebase's NoSQL mental model

**6. Vendor Lock-In**

- Supabase: Open-source, self-hostable, standard PostgreSQL
- Firebase: Proprietary, difficult to migrate away from
- **Impact:** Future-proofing and exit strategy matter for long-term product

**DECISION: Supabase**

**Implementation Notes:**

- Use Supabase Pro plan at scale ($25/month for 8GB database, sufficient for 10K+ users)
- Implement PostgreSQL full-text search with GIN indexes for performance
- Use Row Level Security (RLS) policies for data access control
- Edge Functions for metadata extraction (TypeScript/Deno)

---

## MVP Feature Specifications - MOBILE APP

### Feature 1: Instant Save Flow (Mobile)

**User Story:**

As a mobile user, I want to save a link in under 1 seconds with zero friction, and optionally add context later, so I never lose content while browsing.

**Acceptance Criteria:**

**AC1: Share Sheet Integration (iOS + Android)**

- GIVEN I'm viewing a webpage in any app (Safari, Chrome, Twitter, Instagram, etc.)
- WHEN I tap the system share button
- THEN "Anchor" appears in the share sheet
- AND tapping it **immediately saves the link** (no modal, no blocking)
- AND I see a full-screen confirmation

**AC2: Instant Save Confirmation Screen**

- GIVEN I shared a link to Anchor
- WHEN the save completes (within 1 second)
- THEN I see a **3-second full-screen confirmation**:
    - Gradient background (green to blue)
    - Large text: "Anchored! Find it anytime"
    - Progress bar at top (visual countdown, 3 seconds)
    - "Add Details" button (centered, bottom third, optional)
- AND link is saved to database immediately with:
    - URL (required)
    - Status: queued for metadata extraction
    - Space: None (unassigned by default, shows in Home only)
    - No tags
    - No note
    - Timestamp: current datetime
- AND after 3 seconds OR user taps outside, screen auto-dismisses
- AND user returns to previous app

**AC3: Add Details (Optional Action)**

- GIVEN the confirmation screen is showing
- WHEN I tap "Add Details" button
- THEN bottom sheet slides up from bottom with three tabs: **Tag | Note | Space**
- AND I can add tags, write a note, or select a space
- AND tapping "Done" saves all changes
- AND sheet dismisses, returns to previous app

**AC4: Background Metadata Extraction**

- GIVEN link is saved
- WHEN metadata extraction Edge Function runs (async, in background)
- THEN within 5 seconds, link updates with:
    - Title (extracted from og:title or <title> tag)
    - Description (extracted from og:description or meta description)
    - Thumbnail URL (extracted from og:image)
    - Domain (parsed from URL)
- AND if extraction fails or times out (>5 seconds):
    - Title = domain name (fallback)
    - Description = empty
    - Thumbnail = placeholder gradient (color based on domain hash)
- AND metadata extraction retries in background (max 3 attempts)

**AC5: Offline Save**

- GIVEN I have no internet connection
- WHEN I attempt to save a link
- THEN link is saved locally (Hive database) with:
    - URL (captured from share data)
    - Basic title (from share data if available)
    - Status: pending_sync
    - Offline indicator: will show gray cloud icon in app
- AND I see confirmation toast: "Anchored offline - will sync when online"
- AND link appears in my home list immediately
- WHEN connection restores
- THEN link syncs to server automatically
- AND metadata extraction starts
- AND offline indicator updates to synced

**AC6: Duplicate Detection (After Save)**

- GIVEN I've already saved "[https://example.com/article](https://example.com/article)"
- WHEN I try to save the same URL again (normalized URL comparison)
- THEN link saves instantly first (no blocking)
- AND approximately 1 second after "Anchored!" confirmation shows
- I see an **alert modal** overlay:
    - Title: "Already Saved"
    - Message: "You saved this on Nov 3, 2024"
    - Shows preview: thumbnail + title of existing save
    - Buttons:
        - "View in Anchor" (primary, blue) - opens app to that link
        - "Keep Both" (secondary, gray) - keeps duplicate
        - "Cancel" (tertiary, text only) - deletes the new save
- WHEN I tap "View in Anchor"
- THEN app opens to Home screen, scrolls to existing link
- WHEN I tap "Keep Both"
- THEN both saves exist independently (duplicate allowed)
- WHEN I tap "Cancel"
- THEN new save is deleted, only original remains

**AC7: Cancel Save (During Confirmation)**

- GIVEN the confirmation screen is showing
- WHEN I swipe down OR tap outside the screen area
- THEN confirmation dismisses immediately
- AND save is NOT cancelled (link is already saved)
- AND I return to previous app

**Priority:** P0 (Blocker)

**Dependencies:**

- Supabase authentication configured
- `links` database table created
- Metadata extraction Edge Function deployed
- iOS share extension configured
- Android intent filter configured

**Technical Constraints:**

- Save must complete in <1 second (database write only, metadata async)
- Confirmation screen shows for exactly 3 seconds (visual progress bar)
- Metadata extraction timeout: 5 seconds
- URL normalization removes: utm_*, fbclid, gclid, ref, source, www subdomain, trailing slash
- Duplicate check is async (doesn't block save)

**UX Considerations:**

- Instant save removes all friction (no decisions required)
- 3-second confirmation builds trust ("it worked!")
- "Add Details" is optional (respects user's time)
- Background metadata means no waiting
- Duplicate alert appears AFTER save (not blocking)
- Gradient celebration screen = delightful moment

**Dependencies:**

- Supabase authentication configured
- `links` database table created
- Edge Function for metadata extraction deployed
- iOS share extension configured
- Android intent filter configured

**Technical Constraints:**

- iOS: Share extension must be <10MB (enforced by iOS)
- Android: Intent filter must handle http/https schemes
- Metadata extraction: 5 second timeout
- Network: Must work on 3G connections
- Modal must feel instant (no splash screens)

**UX Considerations:**

- Modal should feel instant (no loading delays before showing)
- Thumbnail loading state should not block save action
- Tag suggestions should appear as user types (debounced 300ms)
- Success feedback must be clear but non-intrusive
- Return to previous app immediately after save (don't force user into LinkSaver app)
- Note field collapsed by default (reduces cognitive load)
- Character counter only shows when typing (not distracting)

---

### Feature 2: Add Details Bottom Sheet (Tag | Note | Space)

**User Story:**

As a user who just saved a link, I want to optionally add context (tags, notes, space) immediately after saving, so that I can organize and remember why I saved it—but only if I have time.

**Acceptance Criteria:**

**AC1: Trigger from Confirmation Screen**

- GIVEN the "Anchored!" confirmation screen is showing
- WHEN I tap the "Add Details" button
- THEN a bottom sheet slides up from bottom
- AND I see a tabbed interface with three tabs: **Tag | Note | Space**
- AND the **Tag** tab is selected by default
- AND sheet takes up ~70% of screen height
- AND grabber handle visible at top (for swipe-to-dismiss)
- AND "Done" button always visible (top right, sticky)

**AC2: Tag Tab - Default State**

- GIVEN I'm on the Tag tab (default)
- WHEN the bottom sheet opens
- THEN I see:
    - Label: "ADD TAGS" (uppercase, small, gray)
    - Auto-suggested tags (if available, based on domain):
        - Example: Saving [dribbble.com](http://dribbble.com) shows "design", "inspiration", "dribbble"
        - Pills with "+" icon
        - Light background colors (blue, purple, green)
    - Tag input field below suggestions:
        - Placeholder: "Type to add tags..."
        - Keyboard optimized for lowercase + hyphens
    - Empty state (no tags added yet)

**AC3: Tag Tab - Add Suggested Tag**

- GIVEN I see suggested tags: "design", "inspiration"
- WHEN I tap "design" suggestion pill
- THEN:
    - "design" tag moves to "Added Tags" section above input
    - Pill darkens (indicates added state)
    - "+" icon changes to "×" (remove option)
    - Suggestion pill disappears from suggestions
    - Haptic feedback (light tap)
    - Can continue adding more tags

**AC4: Tag Tab - Custom Tag Creation**

- GIVEN I tap the tag input field
- WHEN I start typing "ux-research"
- THEN:
    - Keyboard appears
    - As I type, autocomplete dropdown appears (if I have existing tags that match)
    - If no matches: "Create 'ux-research'" option appears
- WHEN I press Enter OR tap "Create"
- THEN:
    - New tag "ux-research" is created
    - Tag appears as chip above input (in Added Tags section)
    - Tag color is auto-generated (consistent hash)
    - Input clears, ready for next tag

**AC5: Tag Tab - Remove Tag**

- GIVEN I've added tags: "design", "inspiration", "ui"
- WHEN I tap the "×" on "inspiration" chip
- THEN:
    - "inspiration" tag is removed from this link
    - Chip disappears with animation
    - If it was a suggestion, it returns to suggestions area
    - Other tags remain unchanged

**AC6: Note Tab - Switch to Note**

- GIVEN I'm on the Tag tab
- WHEN I tap the "Note" tab
- THEN:
    - View switches to Note tab
    - Previous tab (Tag) content hidden
    - "Note" tab indicator shows active state (underline or highlight)
    - All added tags are preserved (not lost)

**AC7: Note Tab - Default State**

- GIVEN I'm on the Note tab
- WHEN the tab loads
- THEN I see:
    - Label: "ADD NOTE" (uppercase, small, gray)
    - Multiline text field (3-5 lines visible)
    - Placeholder: "Why are you saving this? (optional)"
    - Character counter: "0/200" (bottom right, subtle)
    - Keyboard opens automatically (optimized for sentences)

**AC8: Note Tab - Text Entry**

- GIVEN I'm typing in the note field
- WHEN I type: "Great minimal UI example for client project"
- THEN:
    - Character counter updates in real-time: "45/200"
    - Text auto-wraps to multiple lines
    - Field expands vertically if needed (up to sheet height)
    - When I reach 200 characters:
        - Counter turns red: "200/200"
        - Cannot type more (input blocked)
        - Backspace still works

**AC9: Note Tab - With Emoji**

- GIVEN I'm typing a note
- WHEN I add emoji: "Great design 🎨✨"
- THEN:
    - Emoji are supported and displayed correctly
    - Character count includes emoji (typically 1-2 chars each)
    - Emoji display in character counter

**AC10: Space Tab - Switch to Space**

- GIVEN I'm on the Note tab
- WHEN I tap the "Space" tab
- THEN:
    - View switches to Space tab
    - Previous content (Note) hidden but preserved
    - "Space" tab indicator shows active state
    - All previous inputs (tags, note) are preserved

**AC11: Space Tab - Selection List**

- GIVEN I'm on the Space tab
- THEN I see:
    - Label: "SELECT SPACE" (uppercase, small, gray)
    - List of spaces with **radio buttons** (mutually exclusive selection):
        - Default spaces first (always present):
            - ○ Unread (with purple color indicator)
            - ○ Reference (with red color indicator)
        - User-created spaces below (if any, alphabetical)
        - Each row shows: ○ Radio + Color square (24×24) + Space name
    - Initially no space is selected (all radio buttons empty)
    - Bottom of list: "+ Create New Space" button (optional, for power users)

**AC12: Space Tab - Select a Space**

- GIVEN I see the space list
- WHEN I tap "Unread" row
- THEN:
    - Radio button for "Unread" fills (selected state)
    - Checkmark appears on right side of row (visual confirmation)
    - All other radio buttons remain empty
    - Haptic feedback (light tap)
- WHEN I tap a different space (e.g., "Reference")
- THEN:
    - "Unread" radio clears (deselected)
    - "Reference" radio fills (selected)
    - Checkmark moves to "Reference" row
    - Only one space can be selected at a time

**AC13: Space Tab - Unassigned State**

- GIVEN I don't select any space
- WHEN I tap "Done" without selecting a space
- THEN:
    - Link is saved with no space assignment
    - Link appears in Home/All view only (not in any specific space)
    - This is valid—spaces are optional

**AC14: Space Tab - Create New Space (Optional)**

- GIVEN I tap "+ Create New Space" at bottom of list
- THEN:
    - Modal or inline input appears
    - Input field: "Space name"
    - Color picker (predefined palette)
    - "Create" button
- WHEN I create a space
- THEN:
    - New space appears in list immediately
    - Automatically selected (radio filled)
    - Can be used right away

**AC15: Save All Changes (Done Button)**

- GIVEN I've added:
    - Tags: "design", "tutorial"
    - Note: "Great example for client work"
    - Space: "Unread" selected
- WHEN I tap "Done" button (always visible, top right)
- THEN:
    - All changes save in one API call
    - Bottom sheet dismisses with slide-down animation
    - User returns to previous app
    - Toast appears briefly: "Saved" (1 second)
    - Link now has all context attached

**AC16: Dismiss Without Saving (Swipe or Outside Tap)**

- GIVEN I've entered some data in the bottom sheet
- WHEN I swipe down on grabber OR tap outside the sheet
- THEN:
    - Confirmation modal appears:
        - Title: "Discard changes?"
        - Message: "Tags, notes, and space selection will be lost."
        - Buttons: "Cancel" | "Discard" (destructive, red)
- WHEN I tap "Discard"
- THEN:
    - Bottom sheet dismisses
    - All entered data is lost
    - Link remains saved (from initial save) but without context
- WHEN I tap "Cancel"
- THEN:
    - Modal closes
    - Bottom sheet remains open
    - All data preserved

**AC17: Tab Switching Preserves Data**

- GIVEN I add tags: "design", "ui"
- AND I switch to Note tab and type: "Great example"
- AND I switch to Space tab and select "Unread"
- AND I switch back to Tag tab
- THEN:
    - All my tags are still there: "design", "ui"
    - Note is preserved: "Great example"
    - Space selection preserved: "Unread" is selected
- Nothing is lost when switching tabs

**Priority:** P0 (Core differentiating feature - this is where context gets added)

**Dependencies:**

- Feature 1 (Instant Save Flow) - this sheet triggers from confirmation
- Feature 3 (Smart Tagging System) - for tag suggestions and creation
- Spaces System (needs to be defined) - for space list and selection
- `links` table with `note` column (TEXT, max 200 chars)
- `link_tags` junction table
- `spaces` table (to be defined)

**Technical Constraints:**

- Bottom sheet: ~70% screen height, dismissible via swipe or outside tap
- Note field: max 200 characters (enforced client-side AND database)
- Tab switching: instant (no loading), all data preserved in memory
- Save: single API call with all data (tags, note, space)
- Space selection: mutually exclusive (radio buttons, not checkboxes)
- Auto-save debounce: 500ms (if implementing auto-save later)

**UX Considerations:**

- Three tabs reduce cognitive load (one thing at a time)
- Tag tab first (most common action)
- Optional nature respects user's time (can skip all tabs)
- "Done" button always visible (no scrolling to save)
- Swipe-to-dismiss is natural gesture
- Tab switching is smooth and preserves all data
- Radio buttons clearly communicate "one space only"
- Unassigned is valid (not every link needs a space)
- Character counter visible but not anxiety-inducing
- Confirmation on dismiss prevents accidental data loss

**AC6: Add Note (If No Note)**

---

### Feature 3: Spaces System (Organization)

**User Story:**

As a user, I want to organize my links into spaces (visual collections like folders), so I can browse related content together and keep things organized without complexity.

**Acceptance Criteria:**

**AC1: Default Spaces (Auto-Created for Every User)**

- GIVEN I'm a new user who just signed up
- WHEN my account is created
- THEN I automatically get two default spaces:
    - **Unread** (purple color square, cannot be deleted)
    - **Reference** (red color square, cannot be deleted)
- AND these spaces always appear first in the spaces list
- AND links can be assigned to these spaces just like user-created spaces
- AND if a link is not assigned to any space, it appears in Home/All view only

**AC2: Spaces Tab Navigation**

- GIVEN I'm on the Home screen
- WHEN I tap the "Spaces" tab (bottom navigation)
- THEN I navigate to Spaces screen showing:
    - Header: "Spaces" title (large, bold)
    - "+" button (top right, create new space)
    - More menu "•••" (top right, next to +)
    - List of all my spaces:
        - Default spaces first (Unread, Reference)
        - User-created spaces below (alphabetical)
        - Each row: color square (40×40) + space name + arrow
        - Tap anywhere on row to open that space

**AC3: Create New Space**

- GIVEN I'm on the Spaces screen
- WHEN I tap the "+" button
- THEN bottom sheet opens: "Create new space"
- AND I see:
    - App logo/icon at top
    - Title: "Create new space"
    - Explanation: "A space is a collection of bookmarks inside your Anchor. Save directly to your space or add from your home links."
    - Input field: "Name your space" (placeholder)
    - "Next" button (full width, teal, bottom)
- WHEN I enter name (e.g., "Design inspiration") and tap "Next"
- THEN color picker screen appears

**AC4: Color Picker (Part 2 of Space Creation)**

- GIVEN I tapped "Next" after entering space name
- WHEN color picker screen loads
- THEN I see:
    - App logo/icon at top
    - Title: "Pick a color"
    - Explanation: "Adding Color to your space helps you to identify it easy when you search for it"
    - Color grid (14 colors, 2 rows of 7):
        - Each color is a square (48×48)
        - Colors: purple, blue, teal, green, yellow, orange, red, pink, brown, gray, etc.
        - Tappable
    - "Done" button (full width, teal, bottom)
- WHEN I select a color (e.g., purple)
- THEN:
    - Selected color has checkmark overlay
    - Selected color has larger size (visual feedback)
    - Can change selection (only one selected at a time)
- WHEN I tap "Done"
- THEN:
    - Space is created with chosen name + color
    - Bottom sheet dismisses
    - I'm navigated to the new space's view (empty state)

**AC5: View a Space (Empty State)**

- GIVEN I just created a space OR I'm viewing a space with no links
- WHEN I enter the space view
- THEN I see:
    - Header:
        - Back arrow (top left, returns to Spaces list)
        - Space name (center, with color indicator)
        - "+" button (add link, top right)
        - More menu "•••" (top right)
    - Search bar (searches within this space only)
    - Empty state message (center): "This space is empty"
    - Bottom tab navigation (Home | Spaces tabs visible)

**AC6: View a Space (With Links)**

- GIVEN a space contains links (e.g., "Design inspiration" has 12 links)
- WHEN I open that space
- THEN I see:
    - Header (same as AC5)
    - Search bar
    - 2-column grid of link cards
    - Link cards show:
        - Thumbnail (16:9)
        - Tags overlay (top left of thumbnail, max 3 pills)
        - Title (below thumbnail, 2 lines max + ellipsis)
        - Description (gray, 2 lines max + ellipsis)
        - Note (if exists, lighter gray, 2 lines max + ellipsis, note icon prefix)
    - Infinite scroll
    - Bottom tab navigation

**AC7: Add Link to Space (From Space View)**

- GIVEN I'm viewing a space
- WHEN I tap the "+" button (top right)
- THEN I see options:
    - "Share a link" (opens share instructions or triggers system share)
    - "Add from Home" (shows list of unassigned links to add)
- WHEN I select "Add from Home"
- THEN:
    - Modal shows my links that are NOT in this space
    - I can select multiple links
    - "Add to [Space Name]" button at bottom
- WHEN I confirm
- THEN:
    - Selected links move to this space
    - Links appear in space view
    - Toast: "X links added to [Space Name]"

**AC8: Remove Link from Space (Context Menu)**

- GIVEN I'm viewing a link inside a space
- WHEN I long-press the link card
- THEN context menu appears with:
    - Copy to clipboard
    - Add Tag
    - **Remove from space** (only shows when in space view, not on Home)
    - Delete Link
- WHEN I tap "Remove from space"
- THEN:
    - Link is unassigned from this space
    - Link disappears from space view (animated out)
    - Link still exists in Home/All view (becomes unassigned)
    - Toast: "Removed from [Space Name]"
- Note: This is different from "Delete Link" which deletes permanently

**AC9: Add Link to Space (Context Menu from Home)**

- GIVEN I'm on Home screen viewing all links
- WHEN I long-press a link card
- THEN context menu appears with:
    - Copy to clipboard
    - Add Tag
    - **Add to space** (only shows when link is NOT in a space)
    - Delete Link
- WHEN I tap "Add to space"
- THEN:
    - "Add Details" bottom sheet opens on Space tab
    - I can select a space (radio buttons)
    - Tap "Done"
    - Link moves to selected space
    - Toast: "Added to [Space Name]"

**AC10: Delete Space**

- GIVEN I'm viewing a space
- WHEN I tap more menu "•••" (top right)
- THEN I see options:
    - Rename space (optional, for future)
    - **Delete space** (red text)
- WHEN I tap "Delete space"
- THEN confirmation modal appears:
    - Title: "Delete this space?"
    - Message: "X links will be moved to Reference" (count of links in space)
    - Buttons:
        - "Cancel" (secondary)
        - "Delete" (destructive, red)
- WHEN I confirm "Delete"
- THEN:
    - Space is deleted
    - All links in that space are moved to "Reference" default space
    - I'm returned to Spaces list
    - Deleted space is gone from list
    - Toast: "[Space Name] deleted. Links moved to Reference."

**AC11: Cannot Delete Default Spaces**

- GIVEN I'm viewing "Unread" or "Reference" space
- WHEN I tap more menu "•••"
- THEN "Delete space" option is NOT available
- OR if shown, tapping it shows error: "Cannot delete default spaces"
- (Rationale: These are foundational to the app's organization)

**AC12: Space Appears in Add Details Sheet**

- GIVEN I'm in "Add Details" bottom sheet → Space tab
- WHEN viewing the space list
- THEN I see:
    - All my spaces listed (default spaces + user spaces)
    - Each with radio button (mutually exclusive)
    - Can select one space
    - Link is assigned to that space when I tap "Done"

**AC13: Link Can Only Be in One Space**

- GIVEN a link is in "Design inspiration" space
- WHEN I assign it to "Reference" space
- THEN:
    - Link is removed from "Design inspiration"
    - Link is added to "Reference"
    - Link appears in both Home view AND Reference space view
    - Link does NOT appear in "Design inspiration" anymore
- (Spaces are mutually exclusive, unlike tags)

**AC14: Unassigned Links**

- GIVEN I saved a link without assigning it to a space
- WHEN viewing Home screen
- THEN:
    - Link appears in Home/All view (always shows all links)
- WHEN viewing any space
- THEN:
    - Link does NOT appear in any space (it's unassigned)
- User can assign it to a space later via context menu

**AC15: Search Within Space**

- GIVEN I'm viewing "Design inspiration" space
- WHEN I use the search bar
- THEN:
    - Search ONLY searches links within this space
    - Results are limited to this space's links
    - Search highlights matching terms (yellow)
    - Empty state if no results: "No links found in this space"

**Priority:** P0 (Core organizational feature, central to product differentiation)

**Dependencies:**

- `spaces` database table (id, user_id, name, color, is_default, created_at)
- [`links.space](http://links.space)_id` foreign key column (nullable, references [spaces.id](http://spaces.id))
- Bottom navigation component (Home | Spaces tabs)
- Color picker component
- Context menu updates (different options based on location)

**Technical Constraints:**

- Space names: 1-50 characters
- Color: hex string from predefined palette (14 colors)
- Default spaces (Unread, Reference) have `is_default = true` flag
- Links can have `space_id = NULL` (unassigned)
- When space is deleted, all links in that space get `space_id` updated to Reference space's ID
- Space list sorted: default spaces first, then user spaces alphabetically

**UX Considerations:**

- Spaces are simple: just name + color + links
- Default spaces provide structure for new users
- Color helps visual identification and browsing
- One space per link prevents organizational complexity
- Unassigned links are valid (not everything needs a space)
- "Remove from space" vs "Delete link" is clear (different actions)
- Search is scoped to space (keeps results relevant)
- Cannot delete default spaces (prevents user confusion)
- Moving links between spaces is easy (via context menu or Add Details)
- GIVEN a link has no note
- WHEN I'm viewing detail view
- THEN I see:
    - "Add note" button (in place of note section)
    - Small note icon + text
- WHEN I tap "Add note"
- THEN:
    - Note input field appears
    - Placeholder: "Why did you save this?"
    - Keyboard opens
    - Character counter shows: "0/200"
- WHEN I type and tap Done
- THEN:
    - Note saves automatically
    - Note section replaces "Add note" button
    - Success indicator

**AC7: Toggle Status**

- GIVEN the link is "Reference"
- WHEN I tap the status badge (top right)
- THEN:
    - Status changes to "Unread"
    - Badge updates: "Unread" (blue)
    - Change saves immediately (API call)
    - Toast: "Marked as unread"
    - Badge count increases (if visible on home screen)

**AC8: Share Link**

- GIVEN I'm viewing link details
- WHEN I tap the Share icon button
- THEN:
    - System share sheet opens
    - Share options:
        - "Share URL only" (just the link)
        - "Share with note" (URL + note text)
    - I can share via: Messages, Email, Twitter, Copy Link, etc.

**AC9: Delete Link**

- GIVEN I'm viewing link details
- WHEN I tap the Delete icon button (trash, red)
- THEN:
    - Confirmation alert appears:
        - Title: "Delete this link?"
        - Message: "This can't be undone."
        - Buttons:
            - "Cancel" (secondary)
            - "Delete" (destructive, red)
- WHEN I tap "Delete"
- THEN:
    - Link is deleted from database
    - Detail view closes immediately
    - Return to previous list view
    - Deleted link is removed from view (animated out)
    - Undo toast appears (5 seconds): "Link deleted. Undo?"
    - If I tap "Undo" within 5 seconds:
        - Link is restored
        - Link reappears in list (animated in)
        - Toast: "Link restored"

**AC10: Navigation Between Links**

- GIVEN I'm in detail view
- WHEN I swipe left or right
- THEN:
    - Navigate to previous/next link in the list
    - Detail view updates with new link data (smooth transition)
    - Can swipe through multiple links without closing detail view
    - Navigation indicators show position (e.g., "3 of 12")

**AC11: Close Detail View**

- GIVEN I'm in detail view
- WHEN I:
    - Tap back button (top left), OR
    - Swipe down from top, OR
    - Tap outside the modal (on dimmed area)
- THEN:
    - Detail view closes (slide down animation)
    - Return to previous list view
    - Scroll position preserved

**AC12: Detail View with No Thumbnail**

- GIVEN a link has no thumbnail (extraction failed)
- WHEN I open detail view
- THEN:
    - Hero section shows:
        - Large placeholder (gray gradient OR domain-based color)
        - Domain name as large text (centered)
        - Domain favicon (if available)
    - Rest of layout remains same

**Priority:** P0 (Core feature)

**Dependencies:**

- All previous features (displays their data)
- Edit functionality requires update API endpoints
- Share functionality requires system share API

**Technical Constraints:**

- Hero image should be high quality (use og:image URL, not thumbnail)
- Description can be long (make scrollable if needed)
- Edit auto-save should debounce (500ms delay to avoid excessive API calls)
- Undo delete must preserve link for 30 seconds (soft delete)

**UX Considerations:**

- Detail view should feel immersive (full screen, large images)
- Back button/gestures should be prominent and intuitive
- Actions should be discoverable but not crowded
- Auto-save prevents "did I save my changes?" anxiety
- Undo delete is critical (prevents accidental data loss)
- Swipe between links = power user feature (nice to have)
- Opening link = automatic mark as read (delightful automation)

---

### Feature 8: Duplicate Detection (Mobile)

**User Story:**

As a user who saves many links, I want to be notified if I'm saving something I already have, so that I don't clutter my library with duplicates and waste time re-reading content.

**Acceptance Criteria:**

**AC1: Exact URL Match**

- GIVEN I've already saved "[https://example.com/article?id=123](https://example.com/article?id=123)"
- WHEN I try to save "[https://example.com/article?id=123](https://example.com/article?id=123)" again
- THEN I immediately see a modal (before save completes):
    - Title: "Already Saved"
    - Message: "You saved this on Nov 3, 2024"
    - Shows preview:
        - Original thumbnail
        - Original title
        - Original tags (chips)
        - Original note (if any)
    - Buttons:
        - "View Saved" (primary, blue)
        - "Save Anyway" (secondary, gray)
        - "Cancel" (tertiary, text only)

**AC2: Normalized URL Match**

- GIVEN I've saved "[https://example.com/article?utm_source=twitter&fbclid=123](https://example.com/article?utm_source=twitter&fbclid=123)"
- WHEN I try to save "[https://example.com/article?utm_campaign=2024&ref=google](https://example.com/article?utm_campaign=2024&ref=google)"
- THEN I see duplicate alert
- (Tracking params ignored: utm_*, fbclid, gclid, ref, source, etc.)
- (URLs are normalized before comparison)

**AC3: Duplicate Alert - View Saved Action**

- GIVEN I see the duplicate alert
- WHEN I tap "View Saved"
- THEN:
    - Modal closes
    - Save modal closes
    - App opens to link detail view of existing save
    - I can edit tags/note if needed
    - I return to previous app after viewing

**AC4: Duplicate Alert - Save Anyway Action**

- GIVEN I see the duplicate alert
- WHEN I tap "Save Anyway"
- THEN:
    - New save is created (duplicate allowed)
    - Both saves exist independently
    - Success toast: "Saved as duplicate"
    - Save modal closes
    - User may want duplicate with different tags/note (valid use case)

**AC5: Duplicate Alert - Cancel Action**

- GIVEN I see the duplicate alert
- WHEN I tap "Cancel"
- THEN:
    - Modal closes
    - Save modal closes
    - No action taken
    - Return to previous app
    - Link is NOT saved

**AC6: Duplicate Badge in List View**

- GIVEN I have duplicate saves of same URL
- WHEN I'm viewing my links list
- THEN each duplicate card shows:
    - "Duplicate" badge (small, orange, top right corner)
    - Different save dates visible (helps identify which is newer)
    - Can tap to view both separately

**AC7: Merge Duplicates (Swipe Action)**

- GIVEN I have duplicates in my list
- WHEN I swipe left on a duplicate card
- THEN I see:
    - "Merge Duplicates" action (orange background)
    - Merge icon
- WHEN I complete swipe OR tap "Merge"
- THEN:
    - Merge modal appears:
        - Shows both duplicates side-by-side
        - "Keep" radio button for each
        - Option to "Merge tags" (combine tags from both)
        - Option to "Keep both notes" (concatenate)
    - I select which to keep
    - Tap "Merge"
    - One duplicate is deleted
    - Tags/notes merged if selected
    - Toast: "Duplicates merged"

**AC8: No False Positives**

- GIVEN URLs: "[https://medium.com/article-1](https://medium.com/article-1)" and "[https://medium.com/article-2](https://medium.com/article-2)"
- WHEN I save article-2
- THEN NO duplicate alert (different URLs)
- (Only trigger on actual duplicate URLs)

**AC9: Subdomain Handling (www.)**

- GIVEN I've saved "[https://www.example.com/page](https://www.example.com/page)"
- WHEN I try to save "[https://example.com/page](https://example.com/page)"
- THEN I see duplicate alert
- (www. subdomain is ignored in normalization)

**AC10: URL Shortener Limitation**

- GIVEN I've saved "[https://bit.ly/abc123](https://bit.ly/abc123)"
- WHEN I try to save another shortened URL: "[https://bit.ly/xyz789](https://bit.ly/xyz789)"
- THEN NO duplicate alert (even if they resolve to same URL)
- (MVP: Don't expand URL shorteners, too slow/complex)
- (Future: v1.1 could expand and check)

**Priority:** P0 (High user value, prevents frustration)

**Dependencies:**

- Save Link Flow (Feature 1)
- URL normalization function (remove tracking params)
- Database index on normalized_url column (for fast lookup)

**Technical Constraints:**

- Normalization must be fast (<50ms)
- Must handle edge cases:
    - URL shorteners (don't expand in MVP)
    - Redirects (don't follow in MVP)
    - Mobile vs desktop URLs ([m.example.com](http://m.example.com) = [example.com](http://example.com))
    - Case sensitivity (normalize to lowercase)
- Store both original URL and normalized URL in database

**URL Normalization Rules (MVP):**

1. Remove tracking parameters: utm_*, fbclid, gclid, ref, source
2. Remove www. subdomain
3. Remove trailing slash
4. Lowercase domain
5. Remove fragment (#section)
6. Sort query parameters (for consistent hashing)

**UX Considerations:**

- Alert should appear immediately (before save completes)
- "Save Anyway" option respects user agency (don't prevent duplicates)
- Showing original save context helps user decide
- Merge option in list view helps clean up existing duplicates
- Duplicate badge is non-alarming (informational, not error)
- False positives worse than false negatives (be conservative)

---

### Feature 9: Mobile App Settings

**User Story:**

As a user, I want to manage my account, preferences, and app settings, so that I can customize LinkSaver to my needs.

**Acceptance Criteria:**

**AC1: Open Settings**

- GIVEN I'm on the home screen
- WHEN I tap the profile icon (top right)
- THEN settings screen opens (slide in from right)

**AC2: Settings Screen Structure**

- THEN I see sections:
    - **Profile**
        - Profile photo (circular, editable)
        - Email (display only)
        - "Edit Profile" button
    - **Preferences**
        - Default view (Grid / List)
        - Default status (Unread / Reference)
        - Theme (Light / Dark / System)
        - App badge (On / Off)
    - **Data & Privacy**
        - Export links (JSON, CSV)
        - Import bookmarks
        - Delete all links
        - Delete account
    - **Devices**
        - Connected devices (list)
        - "Manage Devices" button
    - **About**
        - Version number
        - Terms of Service
        - Privacy Policy
        - Contact Support
        - Rate on App Store
    - **Account**
        - Sign out

**AC3: Change Default View**

- GIVEN I'm in Settings → Preferences
- WHEN I tap "Default view"
- THEN I see options:
    - ○ Grid (default)
    - ○ List
- WHEN I select "List"
- THEN:
    - Radio button updates
    - Change saves immediately
    - Next app launch uses List view by default

**AC4: Change Theme**

- GIVEN I tap "Theme"
- WHEN I see options:
    - ○ Light
    - ○ Dark
    - ● System (default, selected)
- WHEN I select "Dark"
- THEN:
    - App immediately switches to dark theme (no restart)
    - All screens update (smooth transition)
    - Preference saved

**AC5: Export Links (CSV)**

- GIVEN I tap "Export links"
- THEN I see format options:
    - CSV (recommended)
    - JSON (for developers)
- WHEN I select CSV
- THEN:
    - Progress indicator: "Generating export..."
    - File is generated (all links + metadata)
    - System share sheet opens
    - I can:
        - Save to Files/iCloud Drive
        - Share via email
        - Share to Google Drive
    - File name: "linksaver-export-2024-11-06.csv"
    - Toast: "Export complete"

**AC6: Import Bookmarks**

- GIVEN I tap "Import bookmarks"
- THEN I see browser options:
    - Chrome
    - Safari
    - Firefox
    - Other (file picker)
- WHEN I select "Chrome"
- THEN:
    - Instructions appear:
        - "Export bookmarks from Chrome (Bookmarks → Export bookmarks)"
        - "Save the HTML file"
        - "Tap 'Choose File' below"
    - "Choose File" button
- WHEN I choose file and tap "Import"
- THEN:
    - Progress indicator: "Importing X bookmarks..."
    - Duplicates are detected and skipped
    - Folders are converted to tags
    - Bookmark dates are preserved
    - Toast: "Imported 245 bookmarks (12 duplicates skipped)"

**AC7: Delete All Links (Confirmation)**

- GIVEN I tap "Delete all links"
- THEN I see confirmation alert:
    - Title: "Delete All Links?"
    - Message: "This will delete X links permanently. This cannot be undone."
    - Input field: "Type DELETE to confirm"
    - Buttons:
        - "Cancel"
        - "Delete All" (disabled until typed correctly)
- WHEN I type "DELETE" and tap "Delete All"
- THEN:
    - All links deleted from database
    - Progress: "Deleting..."
    - Return to home screen
    - Empty state appears
    - Toast: "All links deleted"

**AC8: Manage Devices**

- GIVEN I tap "Manage Devices"
- THEN I see list of connected devices:
    - Device 1: "iPhone 13" - "Active now" (current device, green dot)
    - Device 2: "Chrome on MacBook" - "Last active: 2 hours ago"
    - Device 3: "iPad Pro" - "Last active: 3 days ago"
    - Device 4: "Firefox on Windows" - "Last active: 1 week ago"
    - Device 5: "Android Phone" - "Last active: 2 weeks ago"
- WHEN I tap a device (not current device)
- THEN I see:
    - Device details (OS, browser, last IP)
    - "Remove Device" button (red)
- WHEN I tap "Remove Device"
- THEN:
    - Confirmation: "Remove this device?"
    - Device is logged out
    - Device count: 4/5
    - Toast: "Device removed"

**AC9: Contact Support**

- GIVEN I tap "Contact Support"
- THEN I see options:
    - "Email Support" (opens email app with pre-filled template)
    - "Report a Bug" (opens form)
    - "Feature Request" (opens form)
    - "FAQ" (opens help center)

**AC10: Sign Out**

- GIVEN I tap "Sign out"
- THEN I see confirmation:
    - "Sign out of Anchor?"
    - "Your links are safely stored and will be available when you sign in again."
    - Buttons:
        - "Cancel"
        - "Sign Out" (destructive)
- WHEN I tap "Sign Out"
- THEN:
    - User is logged out
    - Local cache is cleared
    - Return to login screen
    - Toast: "Signed out successfully"

**Priority:** P1 (Important but not blocking MVP launch)

**Dependencies:**

- User preferences stored in `users.settings` JSONB column
- Export functionality needs CSV/JSON generator
- Import needs HTML bookmark parser
- Device management needs `devices` table

**Technical Constraints:**

- Theme change must be instant (no app restart)
- Export should handle large datasets (10K+ links)
- Import should be idempotent (can run multiple times safely)
- Device list limited to 5 on free tier

**UX Considerations:**

- Settings should be organized clearly (grouped by topic)
- Dangerous actions (delete) require confirmation
- Export/import should be self-explanatory (with instructions)
- Device management helps with security
- Sign out should be easy to find but not accidental

**User Story:**

As a user who switches between phone and computer constantly, I want my saved links to appear everywhere instantly, so that I never lose track of what I've saved.

**Acceptance Criteria:**

**AC1: Save on Mobile → Appears on Desktop**

- Save link on mobile
- Link appears on desktop within 2 seconds
- No manual sync button needed

**AC2: Offline-First Architecture**

- Save link while offline → Stored locally immediately
- When connection restores → Auto-sync to server
- User sees link in list (no loading state)

**AC3: Conflict Resolution**

- Edit on mobile (offline) + edit on desktop (offline)
- Last write wins (timestamp comparison)
- Both changes preserved where possible (tags + note = merge)

**Priority:** P0 (Core value prop)

---

## Development Roadmap (16 Weeks to MVP)

### Phase 1: Foundation (Weeks 1-4)

**Week 1: Setup & Architecture**

- Supabase project setup
- Database schema creation (all tables)
- Row Level Security (RLS) policies
- Authentication configuration (Google, Apple, Email)
- Flutter project setup (iOS + Android)
- State management (Riverpod) structure
- Design system foundations (colors, typography, spacing)

**Week 2: Core Models & Services**

- Link model (Dart class)
- Tag model
- User model
- API service (Supabase client wrapper)
- Local storage service (Hive)
- Authentication service
- Metadata extraction Edge Function (basic version)

**Week 3: Authentication & Onboarding**

- Splash screen
- Onboarding carousel (3 screens)
- Sign up screen (email + social)
- Login screen
- Password reset flow
- Session management
- Empty state (first user experience)

**Week 4: Save Flow (Mobile)**

- iOS share extension setup
- Android intent filter setup
- Save modal UI
- Thumbnail extraction
- Tag input component
- Note input component
- Status toggle
- Save API integration
- Success feedback (toast)

**Deliverable:** Users can sign up and save their first link from mobile

---

### Phase 2: Core Features (Weeks 5-8)

**Week 5: Search & Browse**

- Home screen layout
- Search bar component
- Search API implementation (PostgreSQL full-text)
- Search results UI (grid view)
- Empty search state
- Search debouncing (300ms)
- Search highlighting

**Week 6: Filtering & Views**

- Filter chips component
- Tag filter implementation
- Date filter (today, week, month, custom)
- Domain filter
- Status filter (unread/reference)
- List view toggle
- View preference persistence
- Sort options (newest, oldest, relevant)

**Week 7: Link Detail & Editing**

- Link detail screen
- Large thumbnail display
- Full metadata display
- Edit tags (inline)
- Edit note (inline)
- Toggle status
- Delete confirmation
- Share functionality
- Auto-save changes (debounced)

**Week 8: Tagging System**

- Tag auto-suggestions (domain-based)
- Tag auto-complete (from user history)
- Tag creation flow
- Tag display (chips with colors)
- Tag color generation (consistent hashing)
- Tag usage tracking
- Tag management (rename, delete)

**Deliverable:** Complete mobile app with search, filtering, and tagging

---

### Phase 3: Sync & Polish (Weeks 9-10)

**Week 9: Real-Time Sync**

- Supabase Realtime subscription setup
- Offline-first architecture (save to local DB first)
- Sync queue (pending operations)
- Conflict resolution logic (last-write-wins)
- Sync indicator UI
- Background sync (when app returns to foreground)
- Device management (5 device limit)

**Week 10: Duplicate Detection & Edge Cases**

- URL normalization function
- Duplicate detection logic
- Duplicate alert UI
- "Save anyway" flow
- Error handling (network, timeouts)
- Retry logic (exponential backoff)
- Offline save queue
- Edge case testing

**Deliverable:** Stable, syncing mobile app ready for beta

---

### Phase 4: Browser Extensions (Weeks 11-12)

**Week 11: Extension Popup (Save + Browse Modes)**

- Chrome extension boilerplate (Manifest V3)
- Extension authentication (token storage)
- **Save Mode UI** (React):
    - Current page detection
    - Metadata extraction
    - Tag input with suggestions
    - Note field
    - Status toggle
    - Save button + success feedback
- **Browse Mode UI** (React):
    - Sidebar (categories, filters, tags)
    - Main area (link cards, 1-column grid)
    - Search bar (real-time filtering)
    - Infinite scroll within popup
    - Quick actions (open, edit, delete)
- Mode switching (Save ↔ Browse)
- Keyboard shortcut (Cmd/Ctrl+Shift+S)
- IndexedDB cache (last 100 links)
- Real-time sync (Supabase Realtime)

**Week 12: Firefox Port + Polish**

- Firefox manifest (V2/V3 hybrid)
- WebExtension Polyfill integration
- Firefox-specific testing
- Extension badge (unread count)
- Performance optimization (virtual scrolling)
- Animations (Framer Motion)
- Error handling (offline mode, API failures)
- Cross-browser testing (Chrome, Firefox, Edge, Brave)

**Deliverable:** Extensions ready for Chrome Web Store, Firefox Add-ons, Edge Add-ons

---

### Phase 5: Beta Testing (Weeks 13-14)

**Week 13: Beta Launch**

- TestFlight setup (iOS)
- Play Store Beta setup (Android)
- Recruit 50 beta testers
- Bug tracking system (Linear or GitHub Issues)
- Crash reporting (Sentry)
- Analytics setup (PostHog or Mixpanel)
- User feedback collection

**Week 14: Bug Fixes & Polish**

- Fix critical bugs (crashes, data loss)
- Performance optimization
- UI polish (animations, transitions)
- Accessibility testing
- User feedback implementation
- App Store assets (screenshots, video, description)

**Deliverable:** Production-ready app with <10 known bugs

---

### Phase 6: Launch Preparation (Weeks 15-16)

**Week 15: Marketing & Launch Assets**

- Landing page (Next.js + Tailwind)
- Demo video (2 minutes)
- App Store listing (copy, screenshots, preview video)
- Play Store listing
- Chrome Web Store listing
- Firefox Add-ons listing
- Edge Add-ons listing
- ProductHunt page
- Press kit (logo, screenshots, description)
- Social media content

**Week 16: Launch Week**

- App Store submission (iOS, 7-day review)
- Play Store submission (Android, 3-day review)
- Chrome Web Store submission (1-3 day review)
- Firefox Add-ons submission (1-7 day review)
- Edge Add-ons submission (1-3 day review)
- ProductHunt launch (Tuesday or Wednesday)
- Reddit posts (scheduled)
- Email waitlist (launch announcement)
- Monitor analytics
- Respond to user feedback

**Deliverable:** Public launch across all platforms, 500+ signups in first week

---

## Database Schema (Supabase PostgreSQL)

### Table: users

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  settings JSONB DEFAULT '{
    "theme": "system",
    "default_view": "grid",
    "default_status": "reference"
  }'
);
```

### Table: links

```sql
CREATE TABLE links (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  normalized_url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  domain TEXT,
  note TEXT CHECK (LENGTH(note) <= 200),
  status TEXT DEFAULT 'reference' CHECK (status IN ('unread', 'reference')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  opened_at TIMESTAMPTZ,
  
  CONSTRAINT unique_user_url UNIQUE (user_id, normalized_url)
);

-- Indexes for performance
CREATE INDEX idx_links_user_created ON links(user_id, created_at DESC);
CREATE INDEX idx_links_status ON links(user_id, status);
CREATE INDEX idx_links_normalized_url ON links(user_id, normalized_url);

-- Full-text search
CREATE INDEX idx_links_fts ON links USING GIN (
  to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(note, '') || ' ' || COALESCE(url, ''))
);
```

### Table: tags

```sql
CREATE TABLE tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_user_tag UNIQUE (user_id, LOWER(name))
);

CREATE INDEX idx_tags_user ON tags(user_id, usage_count DESC);
```

### Table: spaces

```sql
CREATE TABLE spaces (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (LENGTH(name) BETWEEN 1 AND 50),
  color TEXT NOT NULL,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT unique_user_space_name UNIQUE (user_id, LOWER(name))
);

CREATE INDEX idx_spaces_user ON spaces(user_id, created_at DESC);

-- Insert default spaces for new users (trigger)
CREATE OR REPLACE FUNCTION create_default_spaces()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO spaces (user_id, name, color, is_default)
  VALUES 
    ([NEW.id](http://NEW.id), 'Unread', '#9333EA', true),  -- Purple
    ([NEW.id](http://NEW.id), 'Reference', '#DC2626', true); -- Red
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_default_spaces_trigger
AFTER INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION create_default_spaces();
```

### Table: links (Updated with space_id)

```sql
CREATE TABLE links (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  space_id UUID REFERENCES spaces(id) ON DELETE SET NULL,  -- NEW: Link to space (nullable)
  url TEXT NOT NULL,
  normalized_url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  domain TEXT,
  note TEXT CHECK (LENGTH(note) <= 200),
  status TEXT DEFAULT 'reference' CHECK (status IN ('unread', 'reference')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  opened_at TIMESTAMPTZ,
  
  CONSTRAINT unique_user_url UNIQUE (user_id, normalized_url)
);

-- Indexes for performance
CREATE INDEX idx_links_user_created ON links(user_id, created_at DESC);
CREATE INDEX idx_links_status ON links(user_id, status);
CREATE INDEX idx_links_normalized_url ON links(user_id, normalized_url);
CREATE INDEX idx_links_space ON links(user_id, space_id);  -- NEW: Index for space filtering

-- Full-text search
CREATE INDEX idx_links_fts ON links USING GIN (
  to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(note, '') || ' ' || COALESCE(url, ''))
);
```

---

## Next Steps

**Immediate Actions (This Week):**

1. ☐ Review this document with design team
2. ☐ Validate technical decisions with development team
3. ☐ Conduct user interviews (10-15 users)
4. ☐ Create high-fidelity mockups (Figma)
5. ☐ Set up Supabase project
6. ☐ Begin Phase 1 development (Week 1)

**Week 1 Priorities:**

1. Supabase setup + database schema
2. Flutter project + design system
3. Authentication (email + Google)
4. Basic save flow (local only, no sync)

**First Demo Target (Week 4):**

- Users can sign up
- Users can save a link from mobile share sheet
- Link appears in app with thumbnail

**MVP Launch Target: 16 Weeks from Start**

- Full mobile app (iOS + Android)
- Browser extension (Chrome, Firefox, Edge, Brave)
- Real-time sync
- All core features working
- 50 beta testers validated

---

*Document Version: 1.0*

*Created: November 2025*

*Author: Product Management*

*Review Status: Ready for Team Review*

*Total Pages: ~50 pages of comprehensive documentation*