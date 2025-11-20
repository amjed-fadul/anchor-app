-- Migration: Fix Default Spaces Trigger Error Handling
-- Date: 2025-11-20
-- Problem: create_default_spaces_for_user() trigger lacks error handling
--          causing "Server error" during signup if spaces already exist
-- Solution: Add ON CONFLICT DO NOTHING to make trigger idempotent

-- Drop and recreate the function with error handling
DROP FUNCTION IF EXISTS create_default_spaces_for_user() CASCADE;

CREATE OR REPLACE FUNCTION create_default_spaces_for_user()
RETURNS TRIGGER
SECURITY DEFINER -- Required to bypass RLS during trigger execution
SET search_path = public
AS $$
BEGIN
  -- Create "Unread" space (purple, #9333EA)
  -- ON CONFLICT: If space with same user_id and name already exists, do nothing
  INSERT INTO spaces (user_id, name, color, is_default)
  VALUES (NEW.id, 'Unread', '#9333EA', true)
  ON CONFLICT (user_id, LOWER(name)) DO NOTHING;

  -- Create "Reference" space (red, #DC2626)
  -- ON CONFLICT: If space with same user_id and name already exists, do nothing
  INSERT INTO spaces (user_id, name, color, is_default)
  VALUES (NEW.id, 'Reference', '#DC2626', true)
  ON CONFLICT (user_id, LOWER(name)) DO NOTHING;

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail user creation
    RAISE WARNING 'Failed to create default spaces for user %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the trigger (it was dropped when we dropped the function CASCADE)
DROP TRIGGER IF EXISTS create_default_spaces_trigger ON auth.users;

CREATE TRIGGER create_default_spaces_trigger
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_default_spaces_for_user();

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_default_spaces_for_user() TO authenticated;
GRANT EXECUTE ON FUNCTION create_default_spaces_for_user() TO service_role;

-- Test: Verify trigger is properly configured
-- SELECT tgname, tgtype, tgenabled FROM pg_trigger WHERE tgname = 'create_default_spaces_trigger';
