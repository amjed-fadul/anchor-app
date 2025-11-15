-- ============================================
-- ANCHOR APP - BACKFILL DEFAULT SPACES
-- ============================================
-- Purpose: Create default spaces for existing users who don't have any
-- Security: Ensures all users have Unread and Reference spaces
-- Migration: 005
-- Created: November 2025
--
-- PROBLEM:
-- The trigger in migration 002 only fires for NEW users inserted into public.users
-- Users who signed up BEFORE migration 002 was created don't have default spaces
-- Migration 004 backfilled public.users but used ON CONFLICT DO NOTHING
-- which prevented the spaces trigger from firing
--
-- SOLUTION:
-- Find all users without spaces and create defaults for them
-- ============================================

-- ============================================
-- BACKFILL DEFAULT SPACES FOR EXISTING USERS
-- ============================================
-- This query:
-- 1. Finds all users in public.users
-- 2. Checks if they have NO spaces
-- 3. Creates "Unread" and "Reference" spaces for them
-- 4. Uses ON CONFLICT to make it idempotent (safe to run multiple times)

DO $$
DECLARE
  user_record RECORD;
  space_count INT;
BEGIN
  -- Loop through all users
  FOR user_record IN
    SELECT id FROM public.users
  LOOP
    -- Check if this user has any spaces
    SELECT COUNT(*) INTO space_count
    FROM spaces
    WHERE user_id = user_record.id;

    -- If user has no spaces, create defaults
    IF space_count = 0 THEN
      -- Create "Unread" space (purple)
      INSERT INTO spaces (user_id, name, color, is_default, created_at, updated_at)
      VALUES (
        user_record.id,
        'Unread',
        '#9333EA',  -- Purple
        true,       -- Mark as default
        NOW(),
        NOW()
      )
      ON CONFLICT (user_id, LOWER(name)) DO NOTHING;

      -- Create "Reference" space (red)
      INSERT INTO spaces (user_id, name, color, is_default, created_at, updated_at)
      VALUES (
        user_record.id,
        'Reference',
        '#DC2626',  -- Red
        true,       -- Mark as default
        NOW(),
        NOW()
      )
      ON CONFLICT (user_id, LOWER(name)) DO NOTHING;

      RAISE NOTICE 'Created default spaces for user: %', user_record.id;
    ELSE
      RAISE NOTICE 'User % already has % spaces, skipping', user_record.id, space_count;
    END IF;
  END LOOP;
END $$;

-- ============================================
-- VERIFY THE BACKFILL
-- ============================================
-- After running this migration, verify:
-- 1. All users should have at least 2 spaces (Unread and Reference)
-- 2. No user should have 0 spaces

-- Check: How many users have 0 spaces? (Should be 0)
SELECT COUNT(DISTINCT u.id) as users_without_spaces
FROM public.users u
LEFT JOIN spaces s ON u.id = s.user_id
WHERE s.id IS NULL;

-- Check: How many users have default spaces?
SELECT COUNT(DISTINCT user_id) as users_with_defaults
FROM spaces
WHERE is_default = true;

-- Check: Total spaces per user
SELECT
  u.id as user_id,
  u.email,
  COUNT(s.id) as space_count,
  STRING_AGG(s.name, ', ' ORDER BY s.is_default DESC, s.name) as spaces
FROM public.users u
LEFT JOIN spaces s ON u.id = s.user_id
GROUP BY u.id, u.email
ORDER BY space_count ASC;

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================
COMMENT ON TABLE spaces IS 'Visual collections for organizing links. All users have default Unread/Reference spaces. Migration 005 backfills for existing users.';

-- ============================================
-- MIGRATION CHECKLIST ✅
-- ============================================
-- ✅ Idempotent (safe to run multiple times)
-- ✅ ON CONFLICT prevents duplicate spaces
-- ✅ Checks space_count before inserting
-- ✅ Creates both default spaces (Unread and Reference)
-- ✅ Uses correct colors from brand palette
-- ✅ Marks spaces as is_default = true
-- ✅ Verification queries included
-- ✅ RAISE NOTICE for debugging
-- ============================================
