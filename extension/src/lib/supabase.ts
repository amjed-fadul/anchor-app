/**
 * Supabase client configuration for Anchor extension
 * Handles authentication and database connections
 */

import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables')
}

// Create Supabase client (without strict typing for flexibility)
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: {
      // Use chrome.storage.local for persistent auth storage
      getItem: async (key: string) => {
        const result = await chrome.storage.local.get([key])
        return result[key] || null
      },
      setItem: async (key: string, value: string) => {
        await chrome.storage.local.set({ [key]: value })
      },
      removeItem: async (key: string) => {
        await chrome.storage.local.remove([key])
      },
    },
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false, // Extension doesn't use URL-based auth
  },
})

/**
 * Get the current user session
 */
export async function getSession() {
  const { data, error } = await supabase.auth.getSession()
  if (error) throw error
  return data.session
}

/**
 * Get the current user
 */
export async function getUser() {
  const { data, error } = await supabase.auth.getUser()
  if (error) throw error
  return data.user
}

/**
 * Sign in with email and password
 */
export async function signIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) throw error
  return data
}

/**
 * Sign up with email and password
 */
export async function signUp(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })

  if (error) throw error
  return data
}

/**
 * Sign out
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

/**
 * Send password reset email
 */
export async function resetPassword(email: string) {
  const { data, error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${supabaseUrl}/auth/v1/verify`,
  })

  if (error) throw error
  return data
}
