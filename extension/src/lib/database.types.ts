/**
 * Database types generated from Supabase schema
 * Matches the mobile app's Supabase database structure
 */

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      links: {
        Row: {
          id: string
          user_id: string
          space_id: string | null
          url: string
          normalized_url: string
          title: string
          description: string | null
          thumbnail_url: string | null
          domain: string
          note: string | null
          created_at: string
          updated_at: string
          opened_at: string | null
        }
        Insert: {
          id?: string
          user_id: string
          space_id?: string | null
          url: string
          normalized_url: string
          title: string
          description?: string | null
          thumbnail_url?: string | null
          domain: string
          note?: string | null
          created_at?: string
          updated_at?: string
          opened_at?: string | null
        }
        Update: {
          id?: string
          user_id?: string
          space_id?: string | null
          url?: string
          normalized_url?: string
          title?: string
          description?: string | null
          thumbnail_url?: string | null
          domain?: string
          note?: string | null
          created_at?: string
          updated_at?: string
          opened_at?: string | null
        }
      }
      spaces: {
        Row: {
          id: string
          user_id: string
          name: string
          color: string
          is_default: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          color: string
          is_default?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          color?: string
          is_default?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      tags: {
        Row: {
          id: string
          user_id: string
          name: string
          color: string
          usage_count: number
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          color: string
          usage_count?: number
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          color?: string
          usage_count?: number
          created_at?: string
          updated_at?: string
        }
      }
      link_tags: {
        Row: {
          link_id: string
          tag_id: string
          created_at: string
        }
        Insert: {
          link_id: string
          tag_id: string
          created_at?: string
        }
        Update: {
          link_id?: string
          tag_id?: string
          created_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
  }
}
