-- Migration: Add metadata tracking fields to links table
-- Purpose: Track metadata fetch attempts and status for background retry logic
-- Date: 2025-11-19

-- Add metadata tracking fields to links table
ALTER TABLE links
ADD COLUMN IF NOT EXISTS metadata_fetch_attempts INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS last_metadata_attempt_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS metadata_complete BOOLEAN NOT NULL DEFAULT FALSE;

-- Create index for efficient querying of links with incomplete metadata
CREATE INDEX IF NOT EXISTS idx_links_incomplete_metadata
ON links(metadata_complete, metadata_fetch_attempts, last_metadata_attempt_at)
WHERE metadata_complete = FALSE AND metadata_fetch_attempts < 3;

-- Backfill existing links
-- Set metadata_complete = TRUE for links that have title (assume metadata was fetched successfully)
-- Set metadata_fetch_attempts = 1 for existing links (assume they were attempted once)
UPDATE links
SET
  metadata_complete = (title IS NOT NULL AND title != domain),
  metadata_fetch_attempts = 1,
  last_metadata_attempt_at = created_at
WHERE metadata_fetch_attempts = 0;

-- Add comment to explain the fields
COMMENT ON COLUMN links.metadata_fetch_attempts IS
'Number of times metadata fetch has been attempted (max 3)';

COMMENT ON COLUMN links.last_metadata_attempt_at IS
'Timestamp of last metadata fetch attempt';

COMMENT ON COLUMN links.metadata_complete IS
'TRUE if metadata was successfully fetched, FALSE if fetch failed or pending retry';
