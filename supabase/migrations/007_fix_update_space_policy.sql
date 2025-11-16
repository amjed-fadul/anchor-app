-- ============================================
-- FIX: Update Space RLS Policy
-- ============================================
-- Problem: The WITH CHECK subquery was ambiguous and returned multiple rows
-- Error: "more than one row returned by a subquery used as an expression"
--
-- Root Cause:
-- The original policy had: AND is_default = (SELECT is_default FROM spaces WHERE id = spaces.id)
-- This WHERE clause was ambiguous and matched multiple rows
--
-- Solution:
-- Use a trigger instead to enforce is_default immutability
-- Keep the RLS policy simple
-- ============================================

-- Drop the old policy
DROP POLICY IF EXISTS "Users can update own spaces" ON spaces;

-- Create new, simpler policy
-- Users can update their own spaces (name and color only)
CREATE POLICY "Users can update own spaces"
ON spaces
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Create trigger to prevent changing is_default flag
CREATE OR REPLACE FUNCTION prevent_default_flag_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Check if is_default is being changed
  IF OLD.is_default != NEW.is_default THEN
    RAISE EXCEPTION 'Cannot change is_default flag. Default spaces cannot be converted to custom spaces and vice versa.';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger
CREATE TRIGGER prevent_default_flag_change_trigger
  BEFORE UPDATE ON spaces
  FOR EACH ROW
  EXECUTE FUNCTION prevent_default_flag_change();

-- ============================================
-- Comments
-- ============================================
COMMENT ON FUNCTION prevent_default_flag_change() IS 'Prevents changing the is_default flag on spaces. Ensures default spaces (Unread/Reference) stay default and custom spaces stay custom.';
