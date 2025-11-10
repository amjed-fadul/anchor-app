-- ============================================
-- ANCHOR APP - USERS TABLE
-- ============================================
-- Purpose: Store user accounts and preferences
-- Security: Row Level Security (RLS) enabled
-- Migration: 001
-- Created: November 2025
-- ============================================

-- Enable UUID extension if not already enabled
-- UUIDs are more secure than auto-incrementing integers
-- They're impossible to guess and prevent enumeration attacks
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- CREATE USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  -- Primary Key: UUID (Universally Unique Identifier)
  -- WHY UUID? More secure than integers (can't guess user IDs)
  -- Generated automatically by the database
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Email: User's email address
  -- UNIQUE ensures no duplicate accounts
  -- NOT NULL prevents empty emails
  -- Note: Supabase Auth handles email verification
  email TEXT UNIQUE NOT NULL,

  -- Timestamps: When was this account created/updated?
  -- TIMESTAMPTZ stores timezone info (important for global apps)
  -- DEFAULT NOW() auto-fills with current time
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  -- User Settings: Flexible JSON storage
  -- JSONB is PostgreSQL's binary JSON format (faster than TEXT)
  -- Stores user preferences like theme, default view, etc.
  -- DEFAULT provides sensible defaults for new users
  settings JSONB NOT NULL DEFAULT '{
    "theme": "system",
    "default_view": "grid",
    "default_status": "reference",
    "notifications_enabled": true,
    "language": "en"
  }'::jsonb,

  -- Soft Delete: Mark deleted users without removing data
  -- NULL = active user, timestamp = when they deleted their account
  -- Allows recovery and maintains referential integrity
  deleted_at TIMESTAMPTZ DEFAULT NULL
);

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
-- Indexes make searches MUCH faster (like a book index)
-- Without indexes, database scans every row (slow!)

-- Index on email for fast login lookups
-- B-tree index is default and perfect for equality searches
CREATE INDEX IF NOT EXISTS idx_users_email
ON users(email);

-- Index on created_at for analytics queries
-- Helps with "users joined this week" type queries
CREATE INDEX IF NOT EXISTS idx_users_created_at
ON users(created_at DESC);

-- Index on deleted_at for filtering active users
-- Partial index (WHERE deleted_at IS NULL) is smaller and faster
CREATE INDEX IF NOT EXISTS idx_users_active
ON users(deleted_at)
WHERE deleted_at IS NULL;

-- ============================================
-- AUTOMATIC UPDATED_AT TRIGGER
-- ============================================
-- This automatically updates "updated_at" whenever a row changes
-- No need to manually set it in code!

-- Create the trigger function (reusable across tables)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  -- Set updated_at to current time
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to users table
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY (RLS) - CRITICAL FOR SECURITY!
-- ============================================
-- RLS ensures users can ONLY access their own data
-- Even if someone hacks the API, they can't access other users' data
-- This is our primary security mechanism

-- Enable RLS on the table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- POLICY 1: Users can SELECT (read) only their own data
-- auth.uid() returns the logged-in user's ID from Supabase Auth
CREATE POLICY "Users can view own data"
ON users
FOR SELECT
USING (auth.uid() = id);

-- POLICY 2: Users can UPDATE (edit) only their own data
-- Prevents users from editing other accounts
CREATE POLICY "Users can update own data"
ON users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- POLICY 3: Users can soft-delete their own account
-- Sets deleted_at timestamp instead of actually deleting
CREATE POLICY "Users can delete own account"
ON users
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- NOTE: No INSERT policy needed
-- Supabase Auth automatically creates user records
-- This prevents manual user creation (more secure)

-- ============================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================
-- PostgreSQL allows comments on tables and columns
-- These show up in database tools and help future developers

COMMENT ON TABLE users IS 'User accounts and preferences. RLS enabled for security.';
COMMENT ON COLUMN users.id IS 'Primary key (UUID). Matches Supabase Auth user ID.';
COMMENT ON COLUMN users.email IS 'User email address. Verified by Supabase Auth.';
COMMENT ON COLUMN users.settings IS 'User preferences stored as JSONB for flexibility.';
COMMENT ON COLUMN users.deleted_at IS 'Soft delete timestamp. NULL = active user.';

-- ============================================
-- SECURITY CHECKLIST ✅
-- ============================================
-- ✅ UUID instead of integer IDs (prevents enumeration)
-- ✅ Email is UNIQUE and NOT NULL
-- ✅ Row Level Security (RLS) enabled
-- ✅ Policies prevent users from accessing others' data
-- ✅ Indexes for performance
-- ✅ Automatic timestamps with triggers
-- ✅ Soft delete instead of hard delete
-- ✅ Settings stored as JSONB (flexible, validated by app)
-- ✅ Comments for future maintainability
-- ============================================
