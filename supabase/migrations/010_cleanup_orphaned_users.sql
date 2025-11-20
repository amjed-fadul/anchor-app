-- Migration: Cleanup Orphaned Users
-- Date: 2025-11-20
-- Problem: Records exist in public.users without matching auth.users
--          causing "duplicate key violates unique constraint users_email_key"
--          when users try to sign up with those emails
-- Solution: Delete orphaned records to restore data consistency

-- DIAGNOSTIC: Show what will be deleted (run this first to review)
-- Uncomment the SELECT below to see orphaned records before deleting
/*
SELECT
  u.id,
  u.email,
  u.created_at,
  u.updated_at,
  'WILL BE DELETED' as status
FROM public.users u
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = u.id
)
ORDER BY u.created_at DESC;
*/

-- CLEANUP: Delete orphaned user records
-- These records have no corresponding auth.users entry
-- This will CASCADE delete:
--   - All spaces owned by orphaned users
--   - All links in those spaces
--   - All tags for those links

-- IMPORTANT: Temporarily disable the prevent_default_space_deletion_trigger
-- This trigger blocks deletion of "Unread" and "Reference" spaces
-- We need to bypass it to clean up orphaned users
ALTER TABLE spaces DISABLE TRIGGER prevent_default_space_deletion_trigger;

-- Now perform the cleanup
DELETE FROM public.users
WHERE id NOT IN (
  SELECT id FROM auth.users
);

-- Re-enable the trigger to restore protection
ALTER TABLE spaces ENABLE TRIGGER prevent_default_space_deletion_trigger;

-- VERIFICATION: Check that no orphaned records remain
-- This query should return 0
DO $$
DECLARE
  orphaned_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO orphaned_count
  FROM public.users u
  WHERE NOT EXISTS (
    SELECT 1 FROM auth.users au WHERE au.id = u.id
  );

  IF orphaned_count > 0 THEN
    RAISE WARNING 'Still found % orphaned records after cleanup!', orphaned_count;
  ELSE
    RAISE NOTICE 'Cleanup successful: 0 orphaned records remaining';
  END IF;
END $$;

-- DIAGNOSTIC: Show current data consistency status
-- Run this after cleanup to verify clean state
SELECT
  'Users in auth.users' as metric,
  COUNT(*) as count
FROM auth.users

UNION ALL

SELECT
  'Users in public.users' as metric,
  COUNT(*) as count
FROM public.users

UNION ALL

SELECT
  'Orphaned in public.users' as metric,
  COUNT(*) as count
FROM public.users u
WHERE NOT EXISTS (
  SELECT 1 FROM auth.users au WHERE au.id = u.id
)

UNION ALL

SELECT
  'Missing in public.users' as metric,
  COUNT(*) as count
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.users pu WHERE pu.id = au.id
);
