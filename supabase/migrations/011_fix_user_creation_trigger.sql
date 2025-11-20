-- Migration: Fix User Creation Trigger Error Handling
-- Date: 2025-11-20
-- Problem: handle_new_user() trigger only handles ID conflicts (ON CONFLICT (id) DO NOTHING)
--          but does NOT handle email conflicts, causing signup to fail with
--          "duplicate key violates unique constraint users_email_key"
-- Root Cause: public.users table has UNIQUE constraint on BOTH id and email
--             Trigger only handles one constraint (id), not both
-- Solution: Add comprehensive error handling with EXCEPTION block
--           Change DO NOTHING → DO UPDATE to handle both constraints
--           Add SECURITY DEFINER and search_path for security

-- Drop and recreate the function with comprehensive error handling
DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER -- Required to bypass RLS during trigger execution
SET search_path = public -- Prevents search path attacks
AS $$
BEGIN
  -- Insert user record with conflict handling
  -- ON CONFLICT (id): If same user ID exists, update email (handles re-signup edge case)
  -- EXCEPTION block: Catches email unique_violation if different user has that email
  INSERT INTO public.users (id, email, created_at, updated_at)
  VALUES (
    NEW.id,                    -- Same UUID from auth.users
    NEW.email,                 -- Copy email from auth
    NOW(),                     -- Set created_at
    NOW()                      -- Set updated_at
  )
  ON CONFLICT (id) DO UPDATE
  SET
    email = EXCLUDED.email,    -- Update email if changed
    updated_at = NOW();        -- Update timestamp

  RETURN NEW;

EXCEPTION
  WHEN unique_violation THEN
    -- This catches the case where email already exists for a DIFFERENT user
    -- (Orphaned record with different ID but same email)
    -- Log warning but don't fail user signup
    RAISE WARNING 'Email % already exists for different user. User creation in public.users skipped but signup continues.', NEW.email;
    RETURN NEW; -- Continue signup even if public.users insert fails

  WHEN OTHERS THEN
    -- Catch any other unexpected errors
    -- Log error but don't fail user signup
    RAISE WARNING 'Failed to create user record % (email: %): %', NEW.id, NEW.email, SQLERRM;
    RETURN NEW; -- Continue signup even if public.users insert fails
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger (it was dropped when we dropped the function CASCADE)
DROP TRIGGER IF EXISTS handle_new_user_trigger ON auth.users;

CREATE TRIGGER handle_new_user_trigger
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- Grant execute permission to required roles
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO service_role;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO supabase_auth_admin;

-- VERIFICATION: Check trigger is properly configured
DO $$
DECLARE
  trigger_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO trigger_count
  FROM pg_trigger
  WHERE tgname = 'handle_new_user_trigger';

  IF trigger_count = 0 THEN
    RAISE WARNING 'Trigger handle_new_user_trigger was not created!';
  ELSE
    RAISE NOTICE 'Trigger handle_new_user_trigger created successfully';
  END IF;
END $$;

-- DIAGNOSTIC: Show trigger configuration
SELECT
  tgname as trigger_name,
  tgenabled as enabled,
  tgtype as type
FROM pg_trigger
WHERE tgname = 'handle_new_user_trigger';
