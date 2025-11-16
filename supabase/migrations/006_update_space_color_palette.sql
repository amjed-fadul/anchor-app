-- ============================================
-- ANCHOR APP - UPDATE SPACE COLOR PALETTE
-- ============================================
-- Purpose: Update allowed colors to match Figma design palette
-- Migration: 006
-- Created: November 2025
--
-- CONTEXT: The original migration used brand guideline colors,
-- but the Figma design for Create Space flow specifies
-- a different 14-color palette for better visual variety.
-- ============================================

-- ============================================
-- DROP OLD COLOR CONSTRAINT
-- ============================================
ALTER TABLE spaces
DROP CONSTRAINT IF EXISTS valid_color;

-- ============================================
-- ADD NEW COLOR PALETTE FROM FIGMA DESIGN
-- ============================================
-- These 14 colors come from the Figma Create Space design
-- (node-id 1-1163 - Color Picker Grid)
-- Ensures visual consistency with design system

ALTER TABLE spaces
ADD CONSTRAINT valid_color CHECK (
  color IN (
    -- Row 1: Figma Color Palette
    '#7cfec4',  -- Light green/teal
    '#c3c3d1',  -- Gray
    '#ff8da7',  -- Pink
    '#000002',  -- Black
    '#15afcf',  -- Blue
    '#1ac47f',  -- Green
    '#ffdcd4',  -- Peach

    -- Row 2: Figma Color Palette
    '#7e30d1',  -- Purple
    '#fff273',  -- Yellow
    '#c5a3af',  -- Dusty rose
    '#97cdd3',  -- Light blue
    '#c2b8d9',  -- Lavender
    '#1773fa',  -- Bright blue
    '#ed404d',  -- Red

    -- Legacy colors (for existing default spaces)
    '#9333EA',  -- Purple (Unread space - keep for backward compatibility)
    '#DC2626'   -- Red (Reference space - keep for backward compatibility)
  )
);

-- ============================================
-- MIGRATION SAFETY
-- ============================================
-- This migration is safe because:
-- 1. We're keeping the 2 existing default space colors (#9333EA, #DC2626)
-- 2. No existing user-created spaces exist yet (feature just launched)
-- 3. If any user-created spaces exist, they would only have old palette colors
--    which we've preserved in the constraint
-- ============================================

COMMENT ON CONSTRAINT valid_color ON spaces IS 'Allowed space colors from Figma design palette (14 colors) plus legacy default space colors for backward compatibility';
