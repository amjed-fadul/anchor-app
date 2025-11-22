-- Migration: Fix Tags RLS Policy - Prevent Cross-User Tag Access
-- Date: 2025-11-20
-- Problem: Tags created by one user were visible to ALL other users
--          Critical privacy breach - users could see each other's organizational tags
-- Root Cause: Single "FOR ALL" RLS policy not enforcing SELECT operations properly
--             PostgreSQL RLS has known issues with blanket FOR ALL policies where
--             the USING clause may not be enforced consistently across all operations
-- Solution: Split into 4 explicit policies (SELECT, INSERT, UPDATE, DELETE)
--           Matches the secure pattern used in links table (migration 003)
-- Impact: Eliminates cross-user tag visibility, restores proper data isolation

-- BEFORE STATE:
-- User A creates tag "personal-tag" in their account
-- User B logs in and sees User A's "personal-tag" in their tag list
-- Result: Privacy breach - all tags visible to all users! 🚨

-- AFTER STATE:
-- User A creates tag "personal-tag" in their account
-- User B logs in and sees ONLY their own tags
-- Result: Proper data isolation - users only see their own tags ✅

-- Step 1: Remove the problematic blanket policy
DROP POLICY IF EXISTS "Users can manage own tags" ON tags;

-- Step 2: Create explicit SELECT policy (fixes the leak!)
CREATE POLICY "Users can view own tags"
ON tags
FOR SELECT
USING (auth.uid() = user_id);

-- Step 3: Create explicit INSERT policy
CREATE POLICY "Users can create own tags"
ON tags
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Step 4: Create explicit UPDATE policy
CREATE POLICY "Users can update own tags"
ON tags
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Step 5: Create explicit DELETE policy
CREATE POLICY "Users can delete own tags"
ON tags
FOR DELETE
USING (auth.uid() = user_id);

-- Step 6: Add policy descriptions for documentation
COMMENT ON POLICY "Users can view own tags" ON tags
IS 'RLS: Users can only SELECT their own tags (prevents cross-user tag leaks)';

COMMENT ON POLICY "Users can create own tags" ON tags
IS 'RLS: Users can only INSERT tags with their own user_id';

COMMENT ON POLICY "Users can update own tags" ON tags
IS 'RLS: Users can only UPDATE their own tags';

COMMENT ON POLICY "Users can delete own tags" ON tags
IS 'RLS: Users can only DELETE their own tags';

-- Step 7: Verification - Check policies are created correctly
DO $$
DECLARE
  policy_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO policy_count
  FROM pg_policies
  WHERE tablename = 'tags';

  IF policy_count = 4 THEN
    RAISE NOTICE '✅ SUCCESS: 4 explicit RLS policies created for tags table';
  ELSE
    RAISE WARNING '⚠️ WARNING: Expected 4 policies, found %', policy_count;
  END IF;
END $$;

-- Step 8: Display current policies for verification
SELECT
  policyname AS policy_name,
  cmd AS operation,
  qual AS using_clause,
  with_check AS with_check_clause
FROM pg_policies
WHERE tablename = 'tags'
ORDER BY cmd;
