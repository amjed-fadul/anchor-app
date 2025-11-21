/**
 * TypeScript types for Anchor extension
 * Matches the mobile app's Supabase database schema
 */

export interface Link {
  id: string
  user_id: string
  space_id: string | null
  url: string
  normalized_url: string
  title: string
  description: string | null
  thumbnail_url: string | null
  domain: string
  note: string | null // Max 200 characters
  created_at: string
  updated_at: string
  opened_at: string | null
}

export interface Space {
  id: string
  user_id: string
  name: string
  color: SpaceColor
  is_default: boolean
  created_at: string
  updated_at: string
}

export interface Tag {
  id: string
  user_id: string
  name: string
  color: string
  usage_count: number
  created_at: string
  updated_at: string
}

export interface LinkTag {
  link_id: string
  tag_id: string
  created_at: string
}

// 14-color palette for spaces (matching mobile app)
export type SpaceColor =
  | 'purple'
  | 'red'
  | 'orange'
  | 'yellow'
  | 'green'
  | 'teal'
  | 'blue'
  | 'indigo'
  | 'pink'
  | 'gray'
  | 'brown'
  | 'olive'
  | 'navy'
  | 'maroon'

export const SPACE_COLORS: Record<SpaceColor, string> = {
  purple: '#9b87f5',
  red: '#f97066',
  orange: '#fb923c',
  yellow: '#fbbf24',
  green: '#4ade80',
  teal: '#2dd4bf',
  blue: '#60a5fa',
  indigo: '#818cf8',
  pink: '#f472b6',
  gray: '#9ca3af',
  brown: '#a16207',
  olive: '#84cc16',
  navy: '#3b82f6',
  maroon: '#dc2626',
}

// User profile
export interface User {
  id: string
  email: string
  created_at: string
  updated_at: string
}

// Auth session
export interface Session {
  access_token: string
  refresh_token: string
  expires_at: number
  user: User
}

// Extension-specific types
export interface PageMetadata {
  url: string
  title: string
  description: string
  thumbnail: string
  domain: string
}

export interface SaveLinkForm {
  space_id: string | null
  tags: string[]
  note: string
}
