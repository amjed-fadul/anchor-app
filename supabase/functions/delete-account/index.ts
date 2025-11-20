// ============================================
// ANCHOR APP - DELETE ACCOUNT EDGE FUNCTION
// ============================================
// Purpose: Permanently delete user account and all associated data
// Security: Requires valid JWT token, can only delete own account
// Created: November 2025
//
// HOW IT WORKS:
// 1. User calls this function with their JWT token
// 2. Function verifies JWT and extracts user ID
// 3. Function uses Supabase Admin API to delete user from auth.users
// 4. Database CASCADE DELETE automatically removes all user data:
//    - All spaces (ON DELETE CASCADE from users table)
//    - All links (ON DELETE CASCADE from users table)
//    - All tags (ON DELETE CASCADE from users table)
//    - All link_tags (ON DELETE CASCADE from links and tags)
//
// IMPORTANT: This action cannot be undone!
// ============================================

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

// CORS headers for browser requests
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Step 1: Get JWT token from request headers
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // Extract token (format: "Bearer <token>")
    const token = authHeader.replace('Bearer ', '')

    // Step 2: Create Supabase client with user's JWT
    // This verifies the token and gives us the user's ID
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
      }
    )

    // Step 3: Get the authenticated user from the JWT
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser(token)

    if (userError || !user) {
      console.error('❌ Failed to verify user:', userError)
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`🔷 User ${user.id} (${user.email}) requested account deletion`)

    // Step 4: Create Supabase Admin client
    // This has elevated permissions to delete users from auth.users
    // (Regular client can't delete users - only admin can)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // Step 5: Delete the user from auth.users
    // This triggers CASCADE DELETE on all user data:
    // - spaces table: user_id ON DELETE CASCADE
    // - links table: user_id ON DELETE CASCADE
    // - tags table: user_id ON DELETE CASCADE
    // - link_tags table: ON DELETE CASCADE from links and tags
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(
      user.id
    )

    if (deleteError) {
      console.error('❌ Failed to delete user:', deleteError)
      return new Response(
        JSON.stringify({ error: `Failed to delete account: ${deleteError.message}` }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    console.log(`✅ Successfully deleted user ${user.id} (${user.email})`)

    // Step 6: Return success response
    return new Response(
      JSON.stringify({
        success: true,
        message: 'Account deleted successfully',
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  } catch (error) {
    console.error('❌ Unexpected error:', error)
    return new Response(
      JSON.stringify({ error: `Unexpected error: ${error.message}` }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
