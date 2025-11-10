# Supabase Backend Setup Guide

**Last Updated:** November 2025

This guide walks you through setting up the Supabase backend for Anchor App. Supabase provides our PostgreSQL database, authentication, real-time subscriptions, and serverless functions.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Create Supabase Project](#create-supabase-project)
3. [Run Database Migrations](#run-database-migrations)
4. [Configure Authentication](#configure-authentication)
5. [Get API Credentials](#get-api-credentials)
6. [Test Your Setup](#test-your-setup)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, make sure you have:

- ✅ **Supabase Account** - [Sign up for free](https://supabase.com)
- ✅ **Internet Connection** - To access Supabase dashboard
- ✅ **Basic SQL Knowledge** - Helpful but not required

**Cost:** Supabase free tier is sufficient for development (500MB database, 1GB storage, 100K MAU)

---

## Create Supabase Project

### Step 1: Sign Up / Log In

1. Go to [supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"Sign In"**
3. Sign in with GitHub (recommended) or email

### Step 2: Create New Project

1. Click **"New Project"** button
2. Fill in project details:
   - **Name:** `anchor-app` (or your preferred name)
   - **Database Password:** Generate a strong password and **SAVE IT!** ⚠️
   - **Region:** Choose closest to you (e.g., `us-east-1`)
   - **Pricing Plan:** Free (sufficient for development)

3. Click **"Create new project"**
4. Wait 2-3 minutes for setup to complete

**⚠️ IMPORTANT:** Save your database password somewhere safe! You'll need it for direct database access.

---

## Run Database Migrations

Our database schema is defined in 3 migration files in `supabase/migrations/`. We need to run these in order.

### Option A: Using Supabase Dashboard (Easiest)

#### Migration 1: Users Table

1. In Supabase dashboard, go to **SQL Editor** (left sidebar)
2. Click **"New Query"**
3. Open the file: `supabase/migrations/001_create_users_table.sql`
4. Copy ALL the SQL code from that file
5. Paste it into the SQL Editor
6. Click **"Run"** (or press Cmd/Ctrl + Enter)
7. ✅ You should see: "Success. No rows returned"

**What this creates:**
- `users` table with UUID primary keys
- Row Level Security (RLS) policies
- Automatic timestamps
- User settings storage (JSONB)

#### Migration 2: Spaces Table

1. Click **"New Query"** again
2. Open the file: `supabase/migrations/002_create_spaces_table.sql`
3. Copy ALL the SQL code
4. Paste into SQL Editor
5. Click **"Run"**
6. ✅ Success!

**What this creates:**
- `spaces` table for organizing links
- Trigger that auto-creates "Unread" and "Reference" spaces for new users
- 14 approved brand colors constraint
- Protection against deleting default spaces

#### Migration 3: Links and Tags Tables

1. Click **"New Query"** one more time
2. Open the file: `supabase/migrations/003_create_links_and_tags_tables.sql`
3. Copy ALL the SQL code (it's long - 420 lines!)
4. Paste into SQL Editor
5. Click **"Run"**
6. ✅ Success!

**What this creates:**
- `links` table (bookmarks with space_id, no status field!)
- `tags` table (user-defined labels)
- `link_tags` junction table (many-to-many relationship)
- Full-text search index
- URL normalization function
- Automatic tag usage counting

### Option B: Using Supabase CLI (Advanced)

If you're comfortable with command line:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run all migrations
supabase db push

# Check status
supabase db diff
```

### Verify Migrations Ran Successfully

1. Go to **Table Editor** (left sidebar)
2. You should see 6 tables:
   - ✅ `users`
   - ✅ `spaces`
   - ✅ `links`
   - ✅ `tags`
   - ✅ `link_tags`
   - ✅ `auth.users` (created by Supabase automatically)

3. Click on `spaces` table
4. You should see it's empty (users will get default spaces when they sign up)

**If you see all tables → Success! 🎉**

---

## Configure Authentication

Supabase Auth is already enabled! We just need to configure the providers.

### Enable Email Authentication

1. Go to **Authentication** → **Providers** (left sidebar)
2. Find **Email** provider
3. Toggle it **ON** (if not already)
4. Configure settings:
   - ✅ Enable email confirmations: **ON** (recommended)
   - ✅ Enable email OTP: **OFF** (we'll use password)
   - ✅ Secure email change: **ON**

5. Click **"Save"**

### Enable Google OAuth (Optional but Recommended)

1. Still in **Authentication** → **Providers**
2. Find **Google** provider
3. Toggle it **ON**
4. You'll need:
   - Google Client ID
   - Google Client Secret

   **To get these:**
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project (or use existing)
   - Enable Google+ API
   - Create OAuth 2.0 credentials
   - Add authorized redirect URI from Supabase

5. Paste credentials into Supabase
6. Click **"Save"**

### Enable Apple Sign In (Optional, for iOS)

1. Find **Apple** provider
2. Toggle it **ON**
3. You'll need:
   - Services ID
   - Team ID
   - Key ID
   - Private Key

   **To get these:**
   - Go to [Apple Developer Portal](https://developer.apple.com)
   - Create App ID and Services ID
   - Generate private key
   - Follow Supabase's Apple setup guide

4. Paste credentials
5. Click **"Save"**

### Configure Email Templates (Optional)

1. Go to **Authentication** → **Email Templates**
2. Customize:
   - Confirmation email (when user signs up)
   - Magic link email (if using passwordless)
   - Password reset email

3. Use Anchor branding:
   - Subject: "Welcome to Anchor - Confirm your email"
   - Include Anchor logo (upload to Storage first)
   - Use brand colors: Teal (#0D9488) and Slate (#2C3E50)

---

## Get API Credentials

You'll need these to connect your Flutter app to Supabase.

### Step 1: Find Your Project Settings

1. Go to **Project Settings** (gear icon, bottom left)
2. Click **"API"** tab

### Step 2: Copy These Values

You'll see three important values:

#### 1. Project URL
```
https://your-project-ref.supabase.co
```
**What it's for:** Base URL for all API calls

#### 2. Anon Public Key (anon / public)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
**What it's for:** Public API key (safe to use in mobile app)
- Can only access data the user is allowed to see (RLS enforced!)
- Cannot bypass security policies

#### 3. Service Role Key (secret!)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
**What it's for:** Admin key that bypasses RLS
- ⚠️ **NEVER expose this in client-side code!**
- Only use server-side (Edge Functions, scripts)
- Can access all data (full admin privileges)

### Step 3: Create Environment File

**For Flutter app:**

1. In `mobile/` directory, create `.env` file:
   ```bash
   cd mobile
   touch .env
   ```

2. Add your credentials:
   ```env
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. ⚠️ **IMPORTANT:** `.env` is already in `.gitignore` (never commit secrets!)

4. Create `.env.example` template:
   ```env
   SUPABASE_URL=your_supabase_project_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

**For Browser Extension (later):**

Same process in `extension/` directory.

---

## Test Your Setup

Let's verify everything works!

### Test 1: Check Tables Exist

1. Go to **Table Editor**
2. Click on `users` table
3. It should be empty (no users yet)
4. Check the **Columns** tab:
   - ✅ id (uuid)
   - ✅ email (text)
   - ✅ created_at (timestamptz)
   - ✅ updated_at (timestamptz)
   - ✅ settings (jsonb)

### Test 2: Test Authentication

1. Go to **Authentication** → **Users**
2. Click **"Add user"** (manually create test user)
3. Enter:
   - Email: `test@example.com`
   - Password: `TestPassword123!`
   - ✅ Auto Confirm: ON

4. Click **"Create user"**
5. ✅ User should appear in list

### Test 3: Check Default Spaces Created

1. Go to **Table Editor** → `spaces`
2. You should see **2 spaces** for the test user:
   - "Unread" (purple, #9333EA)
   - "Reference" (red, #DC2626)

**If you see these → Your trigger is working! 🎉**

### Test 4: Test Row Level Security (RLS)

Let's make sure RLS is protecting data:

1. Go to **SQL Editor**
2. Run this query:
   ```sql
   -- Try to view all users (should fail without auth)
   SELECT * FROM users;
   ```

3. You should see: **"new row violates row-level security policy"**
4. ✅ This is GOOD! It means RLS is protecting data

5. Now try as authenticated user:
   ```sql
   -- Set the auth context to our test user
   SET request.jwt.claims TO '{"sub": "test-user-uuid-here"}';

   -- Now try again
   SELECT * FROM users WHERE id = auth.uid();
   ```

6. You should see the test user's data
7. ✅ RLS is working correctly!

### Test 5: Test Full-Text Search

1. Let's manually insert a test link:
   ```sql
   -- Insert test link (replace user_id with your test user's UUID)
   INSERT INTO links (user_id, url, normalized_url, title, note)
   VALUES (
     'your-test-user-uuid',
     'https://example.com',
     'https://example.com',
     'Example Website',
     'This is a test link for search'
   );
   ```

2. Now test search:
   ```sql
   SELECT * FROM links
   WHERE to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(note, ''))
   @@ to_tsquery('english', 'test');
   ```

3. ✅ Should return your test link

4. Clean up:
   ```sql
   DELETE FROM links WHERE url = 'https://example.com';
   DELETE FROM users WHERE email = 'test@example.com';
   ```

---

## Troubleshooting

### Problem: "permission denied for table users"

**Cause:** RLS is enabled but no auth context set

**Solution:**
- In app: Make sure user is authenticated before querying
- In SQL Editor: Can't query RLS tables directly (by design!)
- To bypass RLS in SQL Editor: Use Service Role key

### Problem: "relation users does not exist"

**Cause:** Migrations didn't run

**Solution:**
1. Go to **SQL Editor**
2. Check if tables exist: `SELECT * FROM information_schema.tables;`
3. If not, re-run migrations in order (001, 002, 003)

### Problem: "duplicate key value violates unique constraint"

**Cause:** Trying to insert duplicate data

**Solution:**
- Check unique constraints in schema
- For `users.email`: Each email must be unique
- For `spaces.name`: Each user can have space name only once
- For `links.normalized_url`: Each user can save URL only once

### Problem: Default spaces not created for new user

**Cause:** Trigger didn't run

**Solution:**
1. Check trigger exists:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'create_default_spaces_trigger';
   ```

2. If missing, re-run migration 002
3. Test by creating another user manually

### Problem: "Error: connect ECONNREFUSED"

**Cause:** Can't connect to Supabase

**Solution:**
- Check internet connection
- Verify Project URL is correct
- Check Supabase project is not paused (free tier pauses after inactivity)
- Go to dashboard and "Resume" project if needed

### Problem: Search not working

**Cause:** Full-text index not created

**Solution:**
1. Check index exists:
   ```sql
   SELECT indexname FROM pg_indexes WHERE tablename = 'links';
   ```

2. Should see `idx_links_fulltext_search`
3. If missing, re-run migration 003

---

## Next Steps

Now that Supabase is set up, you can:

1. ✅ **Initialize Flutter Project** - Set up mobile app
2. ✅ **Configure Supabase Client** - Connect app to backend
3. ✅ **Implement Authentication** - Sign up/login screens
4. ✅ **Build Save Flow** - Start saving links!

See `mobile/README.md` for Flutter setup instructions.

---

## Database Schema Reference

Quick reference of our tables:

| Table | Purpose | Key Fields |
|-------|---------|-----------|
| `users` | User accounts | id, email, settings |
| `spaces` | Collections (Unread, Reference, custom) | id, user_id, name, color, is_default |
| `links` | Saved bookmarks | id, user_id, space_id, url, note |
| `tags` | User-defined labels | id, user_id, name, usage_count |
| `link_tags` | Links ↔ Tags relationship | link_id, tag_id |

**All tables have Row Level Security (RLS) enabled!**

---

## Useful SQL Queries

### Count users
```sql
SELECT COUNT(*) FROM auth.users;
```

### List all spaces for a user
```sql
SELECT * FROM spaces
WHERE user_id = 'user-uuid-here'
ORDER BY is_default DESC, name ASC;
```

### List all links in Unread space
```sql
SELECT l.* FROM links l
JOIN spaces s ON l.space_id = s.id
WHERE l.user_id = 'user-uuid-here'
  AND s.name = 'Unread';
```

### Search links
```sql
SELECT * FROM links
WHERE user_id = 'user-uuid-here'
  AND to_tsvector('english', COALESCE(title, '') || ' ' || COALESCE(note, ''))
      @@ to_tsquery('english', 'search & terms');
```

### Get tag usage stats
```sql
SELECT name, usage_count
FROM tags
WHERE user_id = 'user-uuid-here'
ORDER BY usage_count DESC
LIMIT 10;
```

---

## Additional Resources

- **Supabase Docs:** https://supabase.com/docs
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **Row Level Security Guide:** https://supabase.com/docs/guides/auth/row-level-security
- **Full-Text Search:** https://supabase.com/docs/guides/database/full-text-search

---

## Support

**Issues with Supabase setup?**
- Check this README first
- Review `supabase/migrations/` SQL files (they have detailed comments)
- See `PRD/AMENDMENTS.md` for design decisions
- Check Supabase community forums

**Database questions?**
- All SQL files are heavily commented
- Check function definitions in migration files
- Review RLS policies for security rules

---

*Last updated: November 2025 - Phase 0 Foundation*
