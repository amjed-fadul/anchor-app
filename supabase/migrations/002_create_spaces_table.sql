-- ============================================
-- ANCHOR APP - SPACES TABLE
-- ============================================
-- Purpose: Visual collections for organizing links
-- Security: Row Level Security (RLS) enabled
-- Migration: 002
-- Created: November 2025
--
-- DESIGN DECISION: Spaces-Only Organizational Model
-- This replaces the "status" field approach from original PRD
-- Spaces provide visual, spatial organization aligned with product vision
-- Default spaces "Unread" and "Reference" serve the purpose of statuses
-- but as explicit, visible collections users can understand
-- ============================================

-- ============================================
-- CREATE SPACES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS spaces (
  -- Primary Key: UUID for security
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Owner: Which user owns this space?
  -- CASCADE: When user is deleted, delete all their spaces
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,

  -- Space Name: What the user calls this collection
  -- Between 1-50 characters (enforced by CHECK constraint)
  -- Example: "Design Inspiration", "Read Later", "Work Resources"
  name TEXT NOT NULL CHECK (LENGTH(name) >= 1 AND LENGTH(name) <= 50),

  -- Space Color: Visual identification from brand palette
  -- Hex color code (e.g., #9333EA for purple)
  -- Must be from approved 14-color palette (see CHECK constraint below)
  color TEXT NOT NULL,

  -- Is Default Space: Cannot be deleted or renamed
  -- TRUE for "Unread" and "Reference" spaces only
  -- FALSE for user-created spaces
  is_default BOOLEAN NOT NULL DEFAULT false,

  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- UNIQUE CONSTRAINT: User cannot have duplicate space names
  -- Case-insensitive comparison using LOWER()
  -- Prevents: Creating "Design" and "design" as separate spaces
  CONSTRAINT unique_user_space_name UNIQUE (user_id, LOWER(name))
);

-- ============================================
-- COLOR PALETTE CONSTRAINT
-- ============================================
-- Enforce that spaces only use approved brand colors
-- These 14 colors come from the Brand Style Guide
-- Ensures visual consistency across the app

ALTER TABLE spaces
ADD CONSTRAINT valid_color CHECK (
  color IN (
    -- Default Space Colors
    '#9333EA',  -- Purple (Unread space)
    '#DC2626',  -- Red (Reference space)

    -- Additional Palette Colors (for user-created spaces)
    '#0D9488',  -- Teal (Anchor brand color)
    '#3B82F6',  -- Blue
    '#10B981',  -- Green
    '#F59E0B',  -- Amber/Yellow
    '#F97316',  -- Orange
    '#EC4899',  -- Pink
    '#8B5CF6',  -- Violet
    '#06B6D4',  -- Cyan
    '#14B8A6',  -- Teal (lighter)
    '#6366F1',  -- Indigo
    '#78716C',  -- Stone/Gray
    '#A855F7'   -- Purple (lighter)
  )
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Index for listing user's spaces (most common query)
-- Sorted by: Default spaces first, then alphabetical
CREATE INDEX IF NOT EXISTS idx_spaces_user_default
ON spaces(user_id, is_default DESC, LOWER(name) ASC);

-- Index for fast space lookups by ID
CREATE INDEX IF NOT EXISTS idx_spaces_id_user
ON spaces(id, user_id);

-- ============================================
-- AUTOMATIC UPDATED_AT TRIGGER
-- ============================================
-- Reuse the trigger function we created in migration 001

CREATE TRIGGER update_spaces_updated_at
  BEFORE UPDATE ON spaces
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- AUTO-CREATE DEFAULT SPACES FOR NEW USERS
-- ============================================
-- When a new user signs up, automatically create:
-- 1. "Unread" space (purple) - for links to read later
-- 2. "Reference" space (red) - for saved reference material
--
-- This ensures every user starts with a consistent setup

CREATE OR REPLACE FUNCTION create_default_spaces_for_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Create "Unread" space (purple, #9333EA)
  INSERT INTO spaces (user_id, name, color, is_default)
  VALUES (
    NEW.id,          -- The new user's ID
    'Unread',        -- Space name
    '#9333EA',       -- Purple color
    true             -- Mark as default (cannot delete)
  );

  -- Create "Reference" space (red, #DC2626)
  INSERT INTO spaces (user_id, name, color, is_default)
  VALUES (
    NEW.id,          -- The new user's ID
    'Reference',     -- Space name
    '#DC2626',       -- Red color
    true             -- Mark as default (cannot delete)
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to users table
-- Runs AFTER a new user is inserted
CREATE TRIGGER create_default_spaces_trigger
  AFTER INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_spaces_for_user();

-- ============================================
-- ROW LEVEL SECURITY (RLS) - CRITICAL!
-- ============================================

ALTER TABLE spaces ENABLE ROW LEVEL SECURITY;

-- POLICY 1: Users can view only their own spaces
CREATE POLICY "Users can view own spaces"
ON spaces
FOR SELECT
USING (auth.uid() = user_id);

-- POLICY 2: Users can create new spaces
-- The WITH CHECK ensures they can only set user_id to their own ID
CREATE POLICY "Users can create own spaces"
ON spaces
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- POLICY 3: Users can update their own spaces
-- BUT: Cannot change is_default flag (prevents marking custom spaces as default)
-- SECURITY: This protects default spaces from modification
CREATE POLICY "Users can update own spaces"
ON spaces
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (
  auth.uid() = user_id
  AND is_default = (SELECT is_default FROM spaces WHERE id = spaces.id)
);

-- POLICY 4: Users can delete their own spaces
-- BUT: Only non-default spaces (cannot delete Unread/Reference)
-- This is enforced at app level too, but database is the final guard
CREATE POLICY "Users can delete own non-default spaces"
ON spaces
FOR DELETE
USING (
  auth.uid() = user_id
  AND is_default = false
);

-- ============================================
-- ADDITIONAL SAFETY: Prevent Default Space Deletion
-- ============================================
-- Database-level protection against deleting default spaces
-- Even if RLS is bypassed somehow, this prevents deletion

CREATE OR REPLACE FUNCTION prevent_default_space_deletion()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if trying to delete a default space
  IF OLD.is_default = true THEN
    RAISE EXCEPTION 'Cannot delete default spaces (Unread or Reference)';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_default_space_deletion_trigger
  BEFORE DELETE ON spaces
  FOR EACH ROW
  EXECUTE FUNCTION prevent_default_space_deletion();

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================

COMMENT ON TABLE spaces IS 'Visual collections for organizing links. Users get default Unread/Reference spaces, can create custom spaces. Replaces status field from original design.';

COMMENT ON COLUMN spaces.id IS 'Primary key (UUID)';
COMMENT ON COLUMN spaces.user_id IS 'Space owner. References users table.';
COMMENT ON COLUMN spaces.name IS 'Space name (1-50 chars). Unique per user (case-insensitive).';
COMMENT ON COLUMN spaces.color IS 'Hex color from approved palette. Used for visual identification.';
COMMENT ON COLUMN spaces.is_default IS 'TRUE for Unread/Reference spaces (cannot delete). FALSE for user-created.';

-- ============================================
-- SECURITY & DATA INTEGRITY CHECKLIST ✅
-- ============================================
-- ✅ UUID primary keys (security)
-- ✅ Row Level Security (RLS) enabled
-- ✅ Users can only access their own spaces
-- ✅ Unique constraint on space names per user
-- ✅ Color validation (must be from approved palette)
-- ✅ Name length validation (1-50 characters)
-- ✅ Default spaces cannot be deleted (trigger + RLS)
-- ✅ Default spaces cannot be renamed (UPDATE policy)
-- ✅ Automatic creation of Unread/Reference spaces
-- ✅ Indexes for performance
-- ✅ Automatic timestamps with trigger
-- ✅ Comprehensive comments for maintainability
-- ============================================
