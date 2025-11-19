-- Fix existing links marked as complete when they only have fallback metadata
-- These links have title = domain (accounting for www prefix)

UPDATE links
SET metadata_complete = false,
    last_metadata_attempt_at = NOW() - INTERVAL '2 minutes'
WHERE metadata_complete = true
  AND (
    -- Title is just the domain
    LOWER(REPLACE(title, 'www.', '')) = LOWER(REPLACE(domain, 'www.', ''))
    -- AND no real metadata
    AND description IS NULL
    AND thumbnail_url IS NULL
  );
