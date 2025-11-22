-- Migration: Fix Default Spaces Trigger Table
-- Date: 2025-11-20
-- Problem: create_default_spaces_trigger attached to auth.users instead of public.users
--          This causes new signups to fail silently with no default spaces created.
-- Root Cause: Migration 009 accidentally attached trigger to wrong table when recreating
--             Trigger fires on auth.users INSERT, but public.users doesn't exist yet,
--             so foreign key constraint fails when trying to INSERT into spaces.
-- Solution: Move trigger from auth.users back to public.users (where it belongs)
-- Impact: After this fix, new signups will automatically get default spaces

-- BEFORE STATE:
-- 1. User signs up → auth.users INSERT
-- 2. create_default_spaces_trigger fires (on auth.users)
--    → Tries to create spaces
--    → Foreign key check: public.users.id exists? NO!
--    → Constraint violation (caught by EXCEPTION block)
--    → Spaces NOT created ❌
-- 3. handle_new_user_trigger fires
--    → Creates public.users record ✅
-- RESULT: User has auth + public.users but NO spaces! 🚨

-- AFTER STATE:
-- 1. User signs up → auth.users INSERT
-- 2. handle_new_user_trigger fires (on auth.users)
--    → Creates public.users record ✅
-- 3. public.users INSERT triggers:
--    → create_default_spaces_trigger fires (on public.users)
--    → Foreign key check: public.users.id exists? YES! ✅
--    → Creates Unread + Reference spaces ✅
-- RESULT: User has auth + public.users + 2 default spaces! ✅

-- Step 1: Drop the incorrectly placed trigger from auth.users
DROP TRIGGER IF EXISTS create_default_spaces_trigger ON auth.users;

-- Step 2: Recreate the trigger on the CORRECT table (public.users)
CREATE TRIGGER create_default_spaces_trigger
  AFTER INSERT ON public.users  -- ✅ CORRECT: public.users, not auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_spaces_for_user();

-- Step 3: Grant necessary permissions (trigger runs as SECURITY DEFINER)
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT INSERT ON spaces TO authenticated;

-- Step 4: Verification - Check trigger is on correct table
DO $$
DECLARE
  trigger_on_public_users INTEGER;
  trigger_on_auth_users INTEGER;
BEGIN
  -- Check if trigger exists on public.users (should be 1)
  SELECT COUNT(*) INTO trigger_on_public_users
  FROM pg_trigger t
  JOIN pg_class c ON t.tgrelid = c.oid
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE t.tgname = 'create_default_spaces_trigger'
  AND c.relname = 'users'
  AND n.nspname = 'public';

  -- Check if trigger exists on auth.users (should be 0)
  SELECT COUNT(*) INTO trigger_on_auth_users
  FROM pg_trigger t
  JOIN pg_class c ON t.tgrelid = c.oid
  JOIN pg_namespace n ON c.relnamespace = n.oid
  WHERE t.tgname = 'create_default_spaces_trigger'
  AND c.relname = 'users'
  AND n.nspname = 'auth';

  IF trigger_on_public_users = 1 AND trigger_on_auth_users = 0 THEN
    RAISE NOTICE '✅ SUCCESS: Trigger create_default_spaces_trigger is now on public.users (correct!)';
  ELSIF trigger_on_auth_users > 0 THEN
    RAISE WARNING '❌ FAILED: Trigger still on auth.users! Manual cleanup needed.';
  ELSE
    RAISE WARNING '⚠️ WARNING: Trigger not found on any table!';
  END IF;
END $$;

-- Step 5: Diagnostic - Show all trigger configurations
SELECT
  t.tgname as trigger_name,
  n.nspname || '.' || c.relname as full_table_name,
  c.relname as table_name,
  n.nspname as schema_name,
  CASE WHEN t.tgenabled = 'O' THEN 'Enabled' ELSE 'Disabled' END as status,
  p.proname as function_name,
  CASE
    WHEN t.tgname = 'create_default_spaces_trigger' AND n.nspname = 'public' THEN '✅ CORRECT'
    WHEN t.tgname = 'create_default_spaces_trigger' AND n.nspname = 'auth' THEN '❌ WRONG TABLE'
    ELSE '✅ OK'
  END as validation
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_namespace n ON c.relnamespace = n.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname IN ('handle_new_user_trigger', 'create_default_spaces_trigger')
ORDER BY t.tgname, n.nspname;
