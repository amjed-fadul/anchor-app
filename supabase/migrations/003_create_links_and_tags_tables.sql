-- ============================================
-- ANCHOR APP - LINKS, TAGS, AND JUNCTION TABLES
-- ============================================
-- Purpose: Store saved links, tags, and their relationships
-- Security: Row Level Security (RLS) enabled on all tables
-- Migration: 003
-- Created: November 2025
--
-- DESIGN DECISION: Spaces-Only Model (NO STATUS FIELD)
-- Links are organized ONLY by space_id (references spaces table)
-- No separate "status" field - spaces serve this purpose
-- Default "Unread" and "Reference" spaces replace status concept
-- This eliminates the status/spaces conflict found in original PRD
-- ============================================

-- ============================================
-- CREATE LINKS TABLE
-- ============================================
-- This is the core table - stores all bookmarked URLs

CREATE TABLE IF NOT EXISTS links (
  -- Primary Key: UUID for security
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Owner: Which user saved this link?
  -- CASCADE: Delete user → delete all their links
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Space Assignment: Which space does this link belong to?
  -- NULL = unassigned (appears in Home view only)
  -- NOT NULL = assigned to a specific space
  -- SET NULL: If space is deleted → link becomes unassigned
  -- NOTE: This is the ONLY organizational field (no status!)
  space_id UUID REFERENCES spaces(id) ON DELETE SET NULL,

  -- Original URL: The exact URL the user saved
  -- Example: "https://example.com/article?utm_source=twitter&ref=homepage"
  -- Stored for display and opening
  url TEXT NOT NULL,

  -- Normalized URL: URL with tracking params removed
  -- Example: "https://example.com/article"
  -- Used for duplicate detection (so utm_source=twitter vs facebook count as same URL)
  -- Normalization rules: remove utm_*, fbclid, gclid, ref, www., trailing slash
  normalized_url TEXT NOT NULL,

  -- Metadata: Extracted from webpage (async, may be NULL initially)
  -- Extracted by Edge Function after save
  title TEXT,
  description TEXT,
  thumbnail_url TEXT,  -- URL to og:image or screenshot
  domain TEXT,         -- Parsed from URL (e.g., "example.com")

  -- User's Note: Why did they save this? (optional)
  -- Max 200 characters (enforced by CHECK constraint)
  -- Example: "Great example of minimal design for client project"
  note TEXT CHECK (LENGTH(note) <= 200),

  -- Timestamps: When was this link saved/updated/opened?
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- Opened At: When did user last open this link?
  -- NULL = never opened
  -- NOT NULL = timestamp of last open
  -- IMPORTANT: Does NOT automatically move link to different space!
  -- Just tracks usage for analytics and "recently opened" features
  opened_at TIMESTAMPTZ DEFAULT NULL,

  -- UNIQUE CONSTRAINT: One URL per user (prevents duplicates)
  -- Uses normalized_url (not original url)
  -- So "example.com?utm=1" and "example.com?utm=2" count as duplicate
  CONSTRAINT unique_user_normalized_url UNIQUE (user_id, normalized_url)
);

-- ============================================
-- INDEXES FOR LINKS TABLE (PERFORMANCE!)
-- ============================================
-- Without indexes, queries scan every row (slow!)
-- With indexes, queries are instant (like book index)

-- Index 1: List user's links sorted by newest first
-- Most common query: "Show me my recent links"
CREATE INDEX IF NOT EXISTS idx_links_user_created
ON links(user_id, created_at DESC);

-- Index 2: Filter links by space
-- Common query: "Show me links in Unread space"
CREATE INDEX IF NOT EXISTS idx_links_user_space
ON links(user_id, space_id);

-- Index 3: Find link by normalized URL (duplicate detection)
-- Used when saving: "Does user already have this URL?"
CREATE INDEX IF NOT EXISTS idx_links_user_normalized_url
ON links(user_id, normalized_url);

-- Index 4: Full-Text Search (THE POWER FEATURE!)
-- GIN index enables fast searching across title, note, and URL
-- PostgreSQL's to_tsvector converts text to searchable format
-- Example search: "design system" finds any link with those words
CREATE INDEX IF NOT EXISTS idx_links_fulltext_search
ON links USING GIN (
  to_tsvector('english',
    COALESCE(title, '') || ' ' ||
    COALESCE(note, '') || ' ' ||
    COALESCE(url, '')
  )
);

-- Index 5: Recently opened links
-- For "Continue where you left off" feature
CREATE INDEX IF NOT EXISTS idx_links_user_opened
ON links(user_id, opened_at DESC NULLS LAST);

-- ============================================
-- AUTOMATIC UPDATED_AT TRIGGER
-- ============================================
-- Reuse trigger function from migration 001

CREATE TRIGGER update_links_updated_at
  BEFORE UPDATE ON links
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS) FOR LINKS
-- ============================================

ALTER TABLE links ENABLE ROW LEVEL SECURITY;

-- POLICY 1: Users can view only their own links
CREATE POLICY "Users can view own links"
ON links
FOR SELECT
USING (auth.uid() = user_id);

-- POLICY 2: Users can create new links
-- Ensures user_id is set to authenticated user
CREATE POLICY "Users can create own links"
ON links
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- POLICY 3: Users can update their own links
-- Allows editing note, moving between spaces, etc.
CREATE POLICY "Users can update own links"
ON links
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- POLICY 4: Users can delete their own links
CREATE POLICY "Users can delete own links"
ON links
FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- CREATE TAGS TABLE
-- ============================================
-- Tags are user-defined labels for organizing links
-- Example tags: "design", "tutorial", "work", "inspiration"

CREATE TABLE IF NOT EXISTS tags (
  -- Primary Key: UUID
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Owner: Which user created this tag?
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Tag Name: The actual tag text
  -- Stored in lowercase for case-insensitive matching
  -- Example: "design-system" (not "Design System")
  name TEXT NOT NULL,

  -- Tag Color: Visual identification (auto-generated from name hash)
  -- Hex color code (e.g., #0D9488)
  -- Consistent per tag name (always same color for same name)
  color TEXT NOT NULL,

  -- Usage Count: How many links have this tag?
  -- Incremented/decremented when links are tagged/untagged
  -- Used for tag suggestions (show popular tags first)
  usage_count INTEGER NOT NULL DEFAULT 0,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- UNIQUE CONSTRAINT: Case-insensitive tag names per user
-- ============================================
-- User cannot have duplicate tag names (case-insensitive)
-- Prevents: "Design" and "design" as separate tags
CREATE UNIQUE INDEX IF NOT EXISTS unique_user_tag_name_lower
ON tags(user_id, LOWER(name));

-- ============================================
-- INDEXES FOR TAGS TABLE
-- ============================================

-- Index 1: List user's tags sorted by popularity
-- Used for tag suggestions and autocomplete
CREATE INDEX IF NOT EXISTS idx_tags_user_usage
ON tags(user_id, usage_count DESC);

-- Index 2: Find tag by name (for autocomplete)
CREATE INDEX IF NOT EXISTS idx_tags_user_name
ON tags(user_id, LOWER(name));

-- ============================================
-- ROW LEVEL SECURITY (RLS) FOR TAGS
-- ============================================

ALTER TABLE tags ENABLE ROW LEVEL SECURITY;

-- Users can view, create, update, and delete their own tags
CREATE POLICY "Users can manage own tags"
ON tags
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ============================================
-- CREATE LINK_TAGS JUNCTION TABLE
-- ============================================
-- Many-to-Many relationship between links and tags
-- One link can have multiple tags
-- One tag can be on multiple links
-- Example: Link "CSS Grid Tutorial" might have tags: "css", "tutorial", "design"

CREATE TABLE IF NOT EXISTS link_tags (
  -- Composite Primary Key (link_id + tag_id)
  -- Prevents duplicate tag assignments
  link_id UUID NOT NULL REFERENCES links(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,

  -- Timestamp: When was this tag added to this link?
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- PRIMARY KEY: Combination must be unique
  -- Cannot tag same link with same tag twice
  PRIMARY KEY (link_id, tag_id)
);

-- ============================================
-- INDEXES FOR LINK_TAGS JUNCTION TABLE
-- ============================================

-- Index 1: Find all tags for a link (forward lookup)
-- Query: "What tags does this link have?"
CREATE INDEX IF NOT EXISTS idx_link_tags_link
ON link_tags(link_id);

-- Index 2: Find all links with a tag (reverse lookup)
-- Query: "Show me all links tagged 'design'"
CREATE INDEX IF NOT EXISTS idx_link_tags_tag
ON link_tags(tag_id);

-- ============================================
-- AUTOMATIC TAG USAGE COUNT UPDATES
-- ============================================
-- Automatically increment/decrement usage_count when tags are added/removed

-- Function: Increment usage count when tag is added to link
CREATE OR REPLACE FUNCTION increment_tag_usage()
RETURNS TRIGGER AS $$
BEGIN
  -- Increase the tag's usage_count by 1
  UPDATE tags
  SET usage_count = usage_count + 1
  WHERE id = NEW.tag_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function: Decrement usage count when tag is removed from link
CREATE OR REPLACE FUNCTION decrement_tag_usage()
RETURNS TRIGGER AS $$
BEGIN
  -- Decrease the tag's usage_count by 1
  UPDATE tags
  SET usage_count = usage_count - 1
  WHERE id = OLD.tag_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Run increment on INSERT
CREATE TRIGGER increment_tag_usage_trigger
  AFTER INSERT ON link_tags
  FOR EACH ROW
  EXECUTE FUNCTION increment_tag_usage();

-- Trigger: Run decrement on DELETE
CREATE TRIGGER decrement_tag_usage_trigger
  AFTER DELETE ON link_tags
  FOR EACH ROW
  EXECUTE FUNCTION decrement_tag_usage();

-- ============================================
-- ROW LEVEL SECURITY (RLS) FOR LINK_TAGS
-- ============================================
-- Security for junction table is tricky!
-- Must ensure user owns BOTH the link AND the tag

ALTER TABLE link_tags ENABLE ROW LEVEL SECURITY;

-- POLICY 1: Users can view link-tag relationships for their own links
CREATE POLICY "Users can view own link tags"
ON link_tags
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM links
    WHERE links.id = link_tags.link_id
    AND links.user_id = auth.uid()
  )
);

-- POLICY 2: Users can add tags to their own links
CREATE POLICY "Users can create own link tags"
ON link_tags
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM links
    WHERE links.id = link_tags.link_id
    AND links.user_id = auth.uid()
  )
  AND EXISTS (
    SELECT 1 FROM tags
    WHERE tags.id = link_tags.tag_id
    AND tags.user_id = auth.uid()
  )
);

-- POLICY 3: Users can remove tags from their own links
CREATE POLICY "Users can delete own link tags"
ON link_tags
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM links
    WHERE links.id = link_tags.link_id
    AND links.user_id = auth.uid()
  )
);

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE links IS 'Saved links (bookmarks). Organized by space_id only (no status field). RLS enabled.';
COMMENT ON COLUMN links.space_id IS 'Which space this link belongs to. NULL = unassigned. This is the ONLY organizational field.';
COMMENT ON COLUMN links.url IS 'Original URL as saved by user (with tracking params).';
COMMENT ON COLUMN links.normalized_url IS 'URL with tracking params removed. Used for duplicate detection.';
COMMENT ON COLUMN links.note IS 'User note (max 200 chars). Why they saved this link.';
COMMENT ON COLUMN links.opened_at IS 'Last opened timestamp. NULL = never opened. Does NOT move link to different space.';

COMMENT ON TABLE tags IS 'User-defined tags for organizing links. RLS enabled.';
COMMENT ON COLUMN tags.usage_count IS 'How many links have this tag. Auto-updated via triggers.';

COMMENT ON TABLE link_tags IS 'Many-to-many relationship between links and tags. RLS enabled.';

-- ============================================
-- HELPER FUNCTION: URL NORMALIZATION
-- ============================================
-- This function normalizes URLs for duplicate detection
-- Called by app before saving, but defined here for reference

CREATE OR REPLACE FUNCTION normalize_url(original_url TEXT)
RETURNS TEXT AS $$
DECLARE
  normalized TEXT;
BEGIN
  -- Start with original URL
  normalized := original_url;

  -- Remove common tracking parameters
  -- utm_source, utm_medium, fbclid, gclid, ref, etc.
  normalized := regexp_replace(normalized, '[?&](utm_[^&]+|fbclid=[^&]+|gclid=[^&]+|ref=[^&]+|source=[^&]+)', '', 'g');

  -- Remove www. subdomain
  normalized := regexp_replace(normalized, '^(https?://)www\.', '\1', 'i');

  -- Remove trailing slash
  normalized := regexp_replace(normalized, '/$', '');

  -- Lowercase the entire URL for consistency
  normalized := LOWER(normalized);

  -- Remove fragment (#section)
  normalized := regexp_replace(normalized, '#.*$', '');

  RETURN normalized;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION normalize_url IS 'Normalizes URLs by removing tracking params, www., trailing slash, etc. Used for duplicate detection.';

-- ============================================
-- SECURITY & DATA INTEGRITY CHECKLIST ✅
-- ============================================
-- ✅ NO STATUS FIELD (Spaces-Only model implemented!)
-- ✅ space_id is ONLY organizational field
-- ✅ UUID primary keys on all tables
-- ✅ Row Level Security (RLS) enabled on all tables
-- ✅ Users can only access their own data
-- ✅ Cascade delete (delete user → delete all data)
-- ✅ Unique constraints prevent duplicates
-- ✅ Foreign keys maintain referential integrity
-- ✅ Indexes for fast queries
-- ✅ Full-text search with GIN index
-- ✅ Automatic tag usage counting
-- ✅ URL normalization for duplicate detection
-- ✅ Note length validation (200 char limit)
-- ✅ opened_at tracking (no automatic space moves)
-- ✅ Comprehensive comments for maintainability
-- ✅ Clean, secure, performant schema
-- ============================================
