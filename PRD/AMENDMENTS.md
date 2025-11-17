# Anchor PRD - Implementation Amendments

**Document Version:** 1.0
**Date:** November 2025
**Status:** Approved for Implementation
**Original PRD Version:** 2.0

---

## Executive Summary

This document records critical design decisions made during implementation that differ from the original Product Requirements Document (PRD). These amendments resolve conflicts found in the original specification and simplify the product architecture.

**Key Decision: Spaces-Only Organizational Model**

The implementation uses **Spaces** as the sole organizational mechanism, removing the separate `status` field from the database schema. This decision resolves multiple conflicts in the original PRD and provides a cleaner, more intuitive user experience.

---

## Table of Contents

1. [Why This Document Exists](#why-this-document-exists)
2. [Critical Conflicts Found](#critical-conflicts-found)
3. [Design Decision: Spaces-Only Model](#design-decision-spaces-only-model)
4. [Database Schema Changes](#database-schema-changes)
5. [Feature Changes](#feature-changes)
6. [Benefits of This Approach](#benefits-of-this-approach)
7. [Implementation Guidelines](#implementation-guidelines)
8. [Future Considerations](#future-considerations)

---

## Why This Document Exists

During Phase 0 (Foundation) implementation, a thorough analysis of the PRD revealed **9 critical conflicts and inconsistencies** that would cause:

- **Development Issues:** Conflicting requirements leading to unclear implementation
- **User Confusion:** Dual organizational systems (status + spaces) with overlapping purposes
- **Data Integrity Problems:** Links could exist in contradictory states
- **Performance Issues:** Unnecessary database fields and indexes

This document:
- ✅ Documents conflicts found in original PRD
- ✅ Explains resolution strategy (Spaces-Only model)
- ✅ Records design rationale for future reference
- ✅ Preserves original PRD as historical record
- ✅ Provides clear implementation guidance

---

## Critical Conflicts Found

### 1. Dual Organizational Systems (CRITICAL)

**Original PRD Specified:**
- **System 1:** `status` field with values `'unread'` or `'reference'` (database column)
- **System 2:** Default spaces named "Unread" (purple) and "Reference" (red)

**The Problem:**

A link could exist in four possible states instead of two:

| Scenario | Space | Status | Problem |
|----------|-------|--------|---------|
| 1 | Unread space | status = 'unread' | ✅ Consistent |
| 2 | Reference space | status = 'reference' | ✅ Consistent |
| 3 | Unread space | status = 'reference' | ❌ CONFLICT: "Unread" space but "Reference" status? |
| 4 | Reference space | status = 'unread' | ❌ CONFLICT: "Reference" space but "Unread" status? |
| 5 | Custom space (e.g., "Work") | status = 'unread' | ❌ AMBIGUOUS: What does "unread" mean in custom space? |

**User Confusion:**
- "My link is in the Reference space but marked as Unread?"
- "Do I filter by space or by status?"
- "What's the difference between Unread space and unread status?"

**PRD References:**
- Lines 1591, 1676: Database schema with status field
- Lines 592-594: Default spaces "Unread" and "Reference"
- Lines 853-862: "Toggle Status" feature
- Line 1406: "Status filter (unread/reference)"

---

### 2. "Toggle Status" Feature Conflict (CRITICAL)

**Original PRD Specified (Lines 853-862):**
```
AC7: Toggle Status
- GIVEN the link is "Reference"
- WHEN I tap the status badge (top right)
- THEN Status changes to "Unread"
- Badge updates: "Unread" (blue)
- Toast: "Marked as unread"
```

**The Problem:**

What happens when user toggles status for a link in a custom space?

**Scenario:**
1. User saves link to "Design Inspiration" space
2. User taps "Toggle Status" badge
3. What should happen?
   - **Option A:** Change status to 'unread', keep in "Design Inspiration" space
     - Problem: Link now has inconsistent state (custom space + unread status)
   - **Option B:** Move link to "Unread" space
     - Problem: User didn't intend to move it, just wanted to mark as unread
     - Violates "one space per link" rule

**Contradicts:** Line 774-783 (AC13: Link Can Only Be in One Space)

---

### 3. Database Schema Defined Twice (CRITICAL)

**Original PRD Contains:**
- **First Definition (Lines 1580-1608):** No `space_id` field, has `status` field
- **Second Definition (Lines 1665-1694):** Has both `space_id` AND `status` fields

**The Problem:**
- Which schema should developers implement?
- Is this showing evolution (V1 → V2)?
- Should both fields exist? (creates dual-system conflict)

**Impact:**
- Developer confusion
- Wasted database storage
- Slower queries (extra indexes)
- Unclear migration path

---

### 4. Filtering Ambiguity (IMPORTANT)

**Original PRD Specified:**
- Line 1406: "Status filter (unread/reference)"
- Lines 796-804: "Search Within Space" (space-scoped filtering)

**The Problem:**

Two ways to see "unread" links:
1. Navigate to "Unread" space (shows links where `space_id = unread_space_id`)
2. Apply "Status: Unread" filter (shows links where `status = 'unread'`)

**User Confusion:**
- "Why are results different between Unread space and Unread filter?"
- "Which one should I use?"
- Duplicate functionality

---

### 5. Default Settings Conflict (IMPORTANT)

**Original PRD Specified:**
- Line 1136: Settings allow "Default status (Unread / Reference)"
- Line 1573: User settings JSONB contains `"default_status": "reference"`
- Line 189: Save flow says "Space: None (unassigned by default)"
- Line 1591: Database default is `status = 'reference'`

**The Problem:**

Three conflicting defaults:
1. Database: `status = 'reference'`
2. User setting: Can choose `'unread'` or `'reference'`
3. Save flow: `space = NULL` (unassigned)

What happens when user sets default status = 'unread' but database defaults to 'reference'?

---

### 6. "Mark as Read" Undefined (IMPORTANT)

**Original PRD Mentioned:**
- Line 954: "Opening link = automatic mark as read (delightful automation)"
- Line 861: Toast message "Marked as unread"

**The Problem:**

What does "mark as read" mean?
- Change `status` from 'unread' to 'reference'?
- Move from "Unread" space to "Reference" space?
- Both?
- Neither (just update `opened_at` timestamp)?

**No specification for:**
- What happens to links in custom spaces when opened
- Whether this is automatic or manual
- How to undo if accidental

---

### 7-9. Minor Issues

7. **Extension Badge Ambiguity:** "Unread count" - count of what? (Line 1493)
8. **Duplicate Schema Definitions:** Same table defined twice (documentation issue)
9. **Naming Inconsistency:** "LinkSaver" instead of "Anchor" (Line 1117)

---

## Design Decision: Spaces-Only Model

### Resolution Strategy

**ELIMINATE the status field entirely.** Use Spaces as the ONLY organizational mechanism.

### Rationale

1. **Aligns with Product Vision**
   - Product name is "Anchor" - implies spatial, fixed points
   - Tagline: "Anchored! Find it anytime" - spatial metaphor
   - Spaces are visual, tangible collections (not abstract statuses)

2. **Simpler Mental Model**
   - ONE way to organize: move links between spaces
   - No confusion about status vs. space
   - Clear cause and effect: "I moved it to Reference space"

3. **Cleaner Architecture**
   - One organizational field (`space_id`) instead of two
   - Simpler database queries
   - Fewer indexes needed
   - No conflicting states possible

4. **Better UX**
   - Explicit actions: "Move to Unread" (not "Toggle status")
   - Visual organization: browse spaces like folders
   - Clear default: "Unread" and "Reference" spaces serve status purpose

5. **Easier Development**
   - No ambiguous "toggle status" feature
   - No dual-filtering logic
   - Clearer acceptance criteria
   - Saves 2-3 weeks of development time

---

## Database Schema Changes

### Original PRD Schema (Conflicted)

```sql
-- Version with BOTH space_id AND status
CREATE TABLE links (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  space_id UUID REFERENCES spaces(id),  -- Organization method 1
  url TEXT NOT NULL,
  normalized_url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  domain TEXT,
  note TEXT CHECK (LENGTH(note) <= 200),
  status TEXT DEFAULT 'reference' CHECK (status IN ('unread', 'reference')),  -- Organization method 2 ❌
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  opened_at TIMESTAMPTZ,

  CONSTRAINT unique_user_url UNIQUE (user_id, normalized_url)
);

-- Index on status ❌
CREATE INDEX idx_links_status ON links(user_id, status);
```

**Problems:**
- ❌ Two organizational fields: `space_id` AND `status`
- ❌ Four possible states instead of two
- ❌ Extra index needed for status filtering
- ❌ Conflicting defaults

### Implemented Schema (Clean)

```sql
-- Spaces-Only Model
CREATE TABLE links (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  space_id UUID REFERENCES spaces(id) ON DELETE SET NULL,  -- ✅ ONLY organizational field
  url TEXT NOT NULL,
  normalized_url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,
  domain TEXT,
  note TEXT CHECK (LENGTH(note) <= 200),
  -- ❌ NO STATUS FIELD
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  opened_at TIMESTAMPTZ,  -- ✅ Tracks when opened, doesn't move link

  CONSTRAINT unique_user_url UNIQUE (user_id, normalized_url)
);

-- Index on space_id ✅
CREATE INDEX idx_links_user_space ON links(user_id, space_id);
```

**Benefits:**
- ✅ One organizational field: `space_id` only
- ✅ Two clear states: unassigned or assigned to a space
- ✅ Simpler queries: no status checking needed
- ✅ `opened_at` tracks usage without moving links

### Spaces Table (Default Spaces)

```sql
CREATE TABLE spaces (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  color TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create default spaces for new users
CREATE TRIGGER create_default_spaces_trigger
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_spaces_for_user();

-- Function creates:
-- 1. "Unread" space (purple, #9333EA)
-- 2. "Reference" space (red, #DC2626)
```

**How it works:**
- Every user gets "Unread" and "Reference" spaces automatically
- These spaces serve the purpose of "unread" and "reference" statuses
- Users can create additional custom spaces
- Default spaces cannot be deleted (database-enforced)

---

## Feature Changes

### Removed Features

#### 1. Toggle Status Feature (Lines 853-862)
**Original:**
```
AC7: Toggle Status
- Tap status badge (top right)
- Status changes to "Unread"
- Toast: "Marked as unread"
```

**Replaced With:**
```
Move to Space Feature
- Long-press link card
- Context menu: "Move to Space"
- Select destination space (Unread, Reference, or custom)
- Toast: "Moved to [Space Name]"
```

**Why Better:**
- Explicit action (user chooses where to move)
- Works with custom spaces
- No ambiguous "toggle" behavior

---

#### 2. Status Filter (Line 1406)
**Original:**
```
Week 6: Filtering
- Status filter (unread/reference)
```

**Replaced With:**
```
Space Navigation
- Users navigate to spaces to filter
- Home screen shows all links (no status filter needed)
- Tag filter, domain filter, date filter remain
```

**Why Better:**
- One filtering mechanism (spaces)
- No confusion about space vs. status filtering
- Space navigation is more visual and intuitive

---

#### 3. Default Status Setting (Line 1136)
**Original:**
```
Settings → Preferences
- Default status (Unread / Reference)
```

**Replaced With:**
```
Settings → Preferences
- Default space (None / Unread / Reference / [Custom Spaces])
```

**Why Better:**
- Aligns with Spaces-Only model
- User can choose any space as default (not just Unread/Reference)
- Clearer what will happen when saving

---

#### 4. Automatic "Mark as Read" (Line 954)
**Original:**
```
Opening link = automatic mark as read (delightful automation)
```

**Replaced With:**
```
Opening link = update opened_at timestamp ONLY
- No automatic space movement
- User maintains control of organization
```

**Why Better:**
- Preserves user's organizational choices
- No unexpected link movements
- `opened_at` still tracks usage for analytics

---

### Modified Features

#### 1. Add Details Bottom Sheet - Space Tab
**Change:** Space selection uses default "Unread" and "Reference" spaces

**Original Behavior:**
- Select from: Unread, Reference, or custom spaces

**Implementation:**
- Same, but users understand these ARE the organizational states
- No separate "status" concept to explain

---

#### 2. Link Detail View
**Change:** No status badge to toggle

**Original:**
- Status badge (top right) - tappable to toggle

**Implementation:**
- Context menu action: "Move to Space"
- Shows which space link is currently in
- More explicit than ambiguous "toggle"

---

#### 3. Badge Counts
**Change:** Clarified what "unread" means

**Original:**
- "Unread count" (ambiguous)

**Implementation:**
- Badge shows count of links in "Unread" space
- Clear, specific, measurable

---

## Benefits of This Approach

### For Users

1. **Clearer Mental Model**
   - "My links are in spaces" (simple!)
   - Not: "My links have spaces AND statuses" (confusing)

2. **Visual Organization**
   - Browse spaces like folders
   - See spatial relationships
   - Aligns with "Anchor" product metaphor

3. **Explicit Control**
   - "Move to Reference space" is clear
   - Not: "Toggle status" (what does that mean?)

4. **No Contradictory States**
   - Link is in Unread space = it's unread (obvious!)
   - Can't be: In Reference space but status = 'unread' (wat?)

### For Developers

1. **Simpler Queries**
   ```sql
   -- ✅ One field to check
   WHERE space_id = unread_space_id

   -- ❌ Old way: Two fields to check
   WHERE (space_id = unread_space_id OR status = 'unread')
   ```

2. **Fewer Indexes**
   - One index on `space_id`
   - Not: Two indexes on `space_id` and `status`

3. **Clearer Acceptance Criteria**
   - "User can move link to space" (straightforward)
   - Not: "User can toggle status unless in custom space then..." (complex)

4. **Faster Development**
   - No dual-system logic
   - No edge cases for status + space conflicts
   - Estimated: **2-3 weeks saved**

### For Product

1. **Aligned with Vision**
   - "Anchor" = fixed points in space
   - Spaces are tangible, visual
   - Statuses are abstract, confusing

2. **Better Retention**
   - Users understand the system
   - Less abandonment due to confusion
   - Positive reviews

3. **Easier Onboarding**
   - "You have Unread and Reference spaces" (done!)
   - Not: "Links have statuses and can be in spaces..." (tutorial needed)

---

## Implementation Guidelines

### For Developers

#### Database Queries

**Getting links in Unread space:**
```sql
SELECT * FROM links
WHERE user_id = $1
  AND space_id = (SELECT id FROM spaces WHERE user_id = $1 AND name = 'Unread')
ORDER BY created_at DESC;
```

**Getting unassigned links:**
```sql
SELECT * FROM links
WHERE user_id = $1
  AND space_id IS NULL
ORDER BY created_at DESC;
```

**Moving link between spaces:**
```sql
UPDATE links
SET space_id = $2, updated_at = NOW()
WHERE id = $1 AND user_id = $3;
```

#### API Endpoints

**Save Link:**
```typescript
// Request body
{
  "url": "https://example.com",
  "space_id": null,  // Optional, can be UUID or null
  "note": "Great article",  // Optional
  "tags": ["design", "tutorial"]  // Optional
}

// Default behavior: space_id = null (unassigned)
// User can assign to space immediately OR later via "Add Details"
```

**Move to Space:**
```typescript
// Request body
{
  "link_id": "uuid",
  "space_id": "uuid"  // Can be null to unassign
}

// Response
{
  "success": true,
  "message": "Moved to Reference"
}
```

#### UI Components

**Space Indicator:**
```typescript
// Show which space link is in
<LinkCard>
  {link.space && (
    <SpaceBadge color={link.space.color}>
      {link.space.name}
    </SpaceBadge>
  )}
</LinkCard>
```

**Context Menu:**
```typescript
<ContextMenu>
  <MenuItem onClick={() => openMoveToSpaceModal()}>
    Move to Space
  </MenuItem>
  <MenuItem onClick={() => openLinkInBrowser()}>
    Open Link
  </MenuItem>
  <MenuItem onClick={() => deleteLink()}>
    Delete
  </MenuItem>
</ContextMenu>
```

---

### For Designers

#### Visual Indicators

**Space Colors:**
- Unread: Purple (#9333EA)
- Reference: Red (#DC2626)
- Custom: Any of 14 approved palette colors

**Badge Placement:**
- Top-left of link card thumbnail
- Small, rounded rectangle
- 24×24 color square + space name

**Empty States:**
```
Unread Space (empty):
  Icon: Purple anchor
  Title: "No unread links"
  Body: "Links you save will appear here"

Reference Space (empty):
  Icon: Red anchor
  Title: "No reference links"
  Body: "Move links here to keep them"
```

#### User Flows

**Moving a Link:**
1. Long-press link card
2. Context menu appears
3. Tap "Move to Space"
4. Bottom sheet slides up with space list (radio buttons)
5. Tap destination space
6. Toast: "Moved to [Space Name]"
7. Link animates to new position (if filtering by space)

**Creating Custom Space:**
1. Tap "Spaces" tab (bottom navigation)
2. Tap "+" button (top right)
3. Enter space name
4. Choose color from palette
5. Tap "Create"
6. Space appears in list
7. Can immediately assign links to it

---

## Future Considerations

### Features That Still Work

✅ **Tags System** - Orthogonal to spaces, works perfectly
✅ **Full-Text Search** - No dependency on status field
✅ **Duplicate Detection** - Based on normalized URL
✅ **Offline Sync** - Syncs `space_id` like any other field
✅ **Notes** - Independent of organization
✅ **opened_at Tracking** - Just a timestamp

### Potential Future Enhancements

#### 1. Smart Space Suggestions
```
When saving a link:
- AI suggests space based on content
- "This looks like a design article - save to 'Design Inspiration'?"
- User can accept or choose different space
```

#### 2. Space Templates
```
Predefined space sets for different use cases:
- Designer: "Inspiration", "Resources", "Clients"
- Developer: "Docs", "Tutorials", "Libraries"
- Researcher: "Papers", "Data", "Tools"
```

#### 3. Filtering & Sorting System (2025-11-17)

**Decision Status:** 💡 Deferred to Future Sprint

**User Need:**
Users with large link collections (100+ links) need better ways to find specific links beyond search. Common use cases include:
- "Show me what I saved this week" (time-based recall)
- "Show me all my unread design links" (combination filtering)
- "Sort by most recently opened" (recency prioritization)

**Proposed Solution:**

**Phase 1: Sort Options (Highest Priority)**
- Sort by Newest First / Oldest First (uses `createdAt`)
- Sort by Recently Opened (uses `openedAt`)
- Sort by Alphabetical (uses `title`)
- Implementation: Dropdown in header, persist preference locally
- Complexity: 🟢 LOW (2-3 hours)
- Rationale: Sorting solves 80% of time-based needs without filter UI complexity

**Phase 2: Time Range Filtering**
- Filter by date saved: Today / This Week / This Month / Older
- Uses `createdAt` field (when user saved the link)
- Optional future enhancement: Monthly granularity (Nov, Oct, Sep...)
- Complexity: 🟡 MEDIUM (1 day)
- Rationale: Complements search for "recent discovery" workflows

**Phase 3: Advanced Filters**
- Filter by Tags (multi-select) - Cross-space topical filtering
- Filter by Spaces (multi-select) - Cross-folder views
- Filter by Read Status (All / Unread / Read) - Uses `openedAt` null/not-null
- Filter by Domain - Group by website/source
- Filter by Note Status (Has notes / No notes)
- Complexity: 🟡 MEDIUM (1-2 days per filter)
- Rationale: Powerful when combined (e.g., "unread design links from this week")

**Why Not Now:**
1. **Existing organization sufficient for MVP**: Users already have Spaces (topical) and Tags (cross-cutting)
2. **Search covers most needs**: Real-time search by title/note/domain/tags handles 90% of use cases
3. **UI complexity**: Mobile filter UI requires careful design to avoid cluttering interface
4. **Premature optimization**: Better to validate need with real user behavior first

**Why Sorting First:**
- Minimal UI overhead (single dropdown)
- Solves time-based recall without filter complexity
- Low implementation cost, high perceived value
- Natural complement to existing search

**Implementation Strategy:**
- Start with client-side filtering (fast for <1000 links, O(n) complexity)
- Migrate to server-side when dataset grows (PostgreSQL full-text search, GIN indexes)
- Use bottom sheet for filter UI (mobile-friendly, doesn't clutter main view)
- Show active filters as dismissible chips
- Combine with existing search (filters apply to search results)

**Data Available for Filtering:**
```dart
Link fields:
  - createdAt: DateTime (when saved)
  - openedAt: DateTime? (last viewed, null = unread)
  - spaceId: String? (current folder)
  - title: String? (link title)
  - domain: String? (website domain)
  - note: String? (user annotation)
  - tags: List<Tag> (user-created labels)
```

**Alternative Considered:**
- **Status Field Addition**: Add `status` enum with values like 'unread', 'read', 'archived'
- **Rejected**: Conflicts with Spaces-Only model, creates dual organizational system (see Amendment #1)
- **Better Approach**: Use `openedAt` null/not-null for read status (simple, no schema change)

**Deferred Until:**
- After core features complete (network error handling, share extension)
- After gathering user behavior data (do users need filters? which ones?)
- After validating current search + spaces/tags organization is insufficient

**References:**
- TODO.md: Future Ideas section (detailed breakdown)
- User feedback (2025-11-17): Requested time/date filtering like Apple Finder

---

#### 4. Space Analytics
```
Show user insights:
- "You have 47 links in Unread - want to review?"
- "You haven't opened Reference in 2 weeks"
- "Your most-used space is 'Work' (123 links)"
```

#### 4. Bulk Operations
```
Select multiple links:
- "Move all to Reference"
- "Archive old links" (move to "Archive" space)
- "Share space" (export all links in space)
```

### What We're NOT Doing (And Why)

❌ **Adding Status Field Back**
- Would reintroduce all the conflicts
- Spaces already solve the use case

❌ **Nested Spaces**
- Adds complexity users don't need
- Flat structure is simpler

❌ **Smart Lists** (iOS Reminders-style)
- Would conflict with spaces
- Tags already provide flexible filtering

---

## Conclusion

The Spaces-Only model resolves all 9 conflicts found in the original PRD while providing a cleaner, more intuitive user experience. This decision:

✅ Aligns with product vision and name ("Anchor")
✅ Simplifies mental model (one organizational system)
✅ Eliminates conflicting states
✅ Reduces development time by 2-3 weeks
✅ Improves user comprehension and retention
✅ Makes codebase cleaner and more maintainable

**This is the right architectural decision for Anchor.**

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | November 2025 | Product & Engineering | Initial documentation of Spaces-Only model decision |

---

## Approval

**Approved By:** Product Owner
**Date:** November 2025
**Status:** ✅ Approved for Implementation

This amendment supersedes conflicting specifications in the original PRD (v2.0). When in doubt, follow this document for implementation guidance.

---

*For questions about this amendment, refer to the database schema comments in `supabase/migrations/` or contact the development team.*
