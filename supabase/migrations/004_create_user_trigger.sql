-- ============================================
-- ANCHOR APP - AUTO-CREATE USERS TRIGGER
-- ============================================
-- Purpose: Automatically create public.users record when auth.users is created
-- Security: Ensures referential integrity for foreign keys
-- Migration: 004
-- Created: November 2025
-- ============================================

-- Problem:
-- When users sign up via Supabase Auth, a record is created in auth.users
-- BUT no corresponding record is created in public.users
-- This causes foreign key violations when trying to insert links

-- Solution:
-- Create a trigger that listens to auth.users INSERT events
-- and automatically creates matching records in public.users

-- ============================================
-- CREATE TRIGGER FUNCTION
-- ============================================
-- This function runs automatically when a new user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new record into public.users
  -- Using the same ID from auth.users ensures consistency
  INSERT INTO public.users (id, email, created_at, updated_at)
  VALUES (
    NEW.id,                    -- Same UUID from auth.users
    NEW.email,                 -- Copy email from auth
    NOW(),                     -- Set created_at
    NOW()                      -- Set updated_at
  )
  ON CONFLICT (id) DO NOTHING; -- Skip if user already exists (idempotent)

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- CREATE TRIGGER
-- ============================================
-- Attach the trigger to auth.users table
-- Runs AFTER a new user is inserted via Supabase Auth
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- BACKFILL EXISTING USERS
-- ============================================
-- Create public.users records for any auth.users that already exist
-- This ensures existing users (like the one testing now) work immediately

INSERT INTO public.users (id, email, created_at, updated_at)
SELECT
  id,
  email,
  created_at,
  NOW() as updated_at
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.users)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================
COMMENT ON FUNCTION public.handle_new_user() IS
  'Automatically creates a public.users record when a user signs up via Supabase Auth. Ensures referential integrity for foreign keys.';

-- ============================================
-- VERIFY THE FIX
-- ============================================
-- After running this migration, check:
-- SELECT COUNT(*) FROM auth.users;        -- Should match
-- SELECT COUNT(*) FROM public.users;      -- Should match
-- Both counts should be equal!

-- ============================================
-- SECURITY CHECKLIST ✅
-- ============================================
-- ✅ Trigger runs AFTER INSERT (doesn't block signup)
-- ✅ ON CONFLICT DO NOTHING (idempotent, safe to re-run)
-- ✅ SECURITY DEFINER (runs with creator's permissions)
-- ✅ Backfill query handles existing users
-- ✅ Email copied from auth.users (single source of truth)
-- ✅ Same UUID used for both tables (maintains consistency)
-- ============================================
