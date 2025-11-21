/**
 * API functions for interacting with Supabase
 * Handles links, spaces, and tags CRUD operations
 */

import { supabase } from './supabase'
import type { Link, Space, Tag } from './types'

/**
 * Normalize URL for deduplication
 * Removes protocol, www, trailing slashes, and query params
 */
export function normalizeUrl(url: string): string {
  try {
    const urlObj = new URL(url)
    let normalized = urlObj.hostname + urlObj.pathname

    // Remove www.
    normalized = normalized.replace(/^www\./, '')

    // Remove trailing slash
    normalized = normalized.replace(/\/$/, '')

    return normalized.toLowerCase()
  } catch {
    return url.toLowerCase()
  }
}

/**
 * Get domain from URL
 */
export function getDomain(url: string): string {
  try {
    const urlObj = new URL(url)
    return urlObj.hostname.replace(/^www\./, '')
  } catch {
    return url
  }
}

// ============================================================================
// SPACES API
// ============================================================================

/**
 * Get all spaces for the current user
 */
export async function getSpaces(userId: string): Promise<Space[]> {
  const { data, error } = await supabase
    .from('spaces')
    .select('*')
    .eq('user_id', userId)
    .order('is_default', { ascending: false }) // Default spaces first
    .order('name', { ascending: true })

  if (error) throw error
  return data || []
}

/**
 * Get default "Unread" space
 */
export async function getUnreadSpace(userId: string): Promise<Space | null> {
  const { data, error } = await supabase
    .from('spaces')
    .select('*')
    .eq('user_id', userId)
    .eq('name', 'Unread')
    .eq('is_default', true)
    .single()

  if (error) {
    console.error('Error fetching Unread space:', error)
    return null
  }
  return data
}

/**
 * Create a new space
 */
export async function createSpace(
  userId: string,
  name: string,
  color: string
): Promise<Space> {
  const { data, error } = await supabase
    .from('spaces')
    .insert({
      user_id: userId,
      name,
      color,
      is_default: false,
    })
    .select()
    .single()

  if (error) throw error
  return data
}

// ============================================================================
// TAGS API
// ============================================================================

/**
 * Get all tags for the current user
 */
export async function getTags(userId: string): Promise<Tag[]> {
  const { data, error } = await supabase
    .from('tags')
    .select('*')
    .eq('user_id', userId)
    .order('usage_count', { ascending: false }) // Most used first
    .order('name', { ascending: true })

  if (error) throw error
  return data || []
}

/**
 * Create a new tag
 */
export async function createTag(userId: string, name: string): Promise<Tag> {
  const { data, error } = await supabase
    .from('tags')
    .insert({
      user_id: userId,
      name: name.toLowerCase().trim(),
      color: '#9ca3af', // Default gray color
      usage_count: 0,
    })
    .select()
    .single()

  if (error) throw error
  return data
}

/**
 * Find or create tag by name
 */
export async function findOrCreateTag(
  userId: string,
  tagName: string
): Promise<Tag> {
  const normalizedName = tagName.toLowerCase().trim()

  // Try to find existing tag
  const { data: existing } = await supabase
    .from('tags')
    .select('*')
    .eq('user_id', userId)
    .eq('name', normalizedName)
    .single()

  if (existing) {
    return existing
  }

  // Create new tag
  return await createTag(userId, normalizedName)
}

// ============================================================================
// LINKS API
// ============================================================================

/**
 * Save a new link
 */
export async function saveLink(params: {
  userId: string
  url: string
  title: string
  description?: string
  thumbnailUrl?: string
  spaceId?: string | null
  note?: string
  tags?: string[]
}): Promise<Link> {
  const {
    userId,
    url,
    title,
    description,
    thumbnailUrl,
    spaceId,
    note,
    tags = [],
  } = params

  // Create link
  const { data: link, error: linkError } = await supabase
    .from('links')
    .insert({
      user_id: userId,
      space_id: spaceId,
      url,
      normalized_url: normalizeUrl(url),
      title,
      description: description || null,
      thumbnail_url: thumbnailUrl || null,
      domain: getDomain(url),
      note: note || null,
    })
    .select()
    .single()

  if (linkError) throw linkError

  // Create tags and link_tags associations
  if (tags.length > 0) {
    const tagIds: string[] = []

    for (const tagName of tags) {
      const tag = await findOrCreateTag(userId, tagName)
      tagIds.push(tag.id)
    }

    // Insert link_tags associations
    const linkTagsData = tagIds.map((tagId) => ({
      link_id: link.id,
      tag_id: tagId,
    }))

    const { error: linkTagsError } = await supabase
      .from('link_tags')
      .insert(linkTagsData)

    if (linkTagsError) {
      console.error('Error creating link_tags:', linkTagsError)
      // Don't throw - link was created successfully
    }

    // Increment tag usage counts
    for (const tagId of tagIds) {
      const { data: tag } = await supabase
        .from('tags')
        .select('usage_count')
        .eq('id', tagId)
        .single()

      if (tag) {
        await supabase
          .from('tags')
          .update({ usage_count: tag.usage_count + 1 })
          .eq('id', tagId)
      }
    }
  }

  return link
}

/**
 * Get recent links for the current user
 */
export async function getRecentLinks(
  userId: string,
  limit: number = 30
): Promise<Link[]> {
  const { data, error } = await supabase
    .from('links')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit)

  if (error) throw error
  return data || []
}

/**
 * Get links count for Unread space (for badge)
 */
export async function getUnreadCount(userId: string): Promise<number> {
  const unreadSpace = await getUnreadSpace(userId)
  if (!unreadSpace) return 0

  const { count, error } = await supabase
    .from('links')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('space_id', unreadSpace.id)

  if (error) {
    console.error('Error getting unread count:', error)
    return 0
  }

  return count || 0
}

/**
 * Delete a link
 */
export async function deleteLink(linkId: string): Promise<void> {
  // Delete link_tags first (foreign key constraint)
  await supabase.from('link_tags').delete().eq('link_id', linkId)

  // Delete link
  const { error } = await supabase.from('links').delete().eq('id', linkId)

  if (error) throw error
}

/**
 * Update a link
 */
export async function updateLink(
  linkId: string,
  updates: {
    spaceId?: string | null
    note?: string
    tags?: string[]
  }
): Promise<Link> {
  const { spaceId, note, tags } = updates

  // Update link
  const { data: link, error: linkError } = await supabase
    .from('links')
    .update({
      space_id: spaceId,
      note: note || null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', linkId)
    .select()
    .single()

  if (linkError) throw linkError

  // Update tags if provided
  if (tags) {
    // Delete existing link_tags
    await supabase.from('link_tags').delete().eq('link_id', linkId)

    // Get user_id from link
    const userId = link.user_id

    // Create new tags and associations
    if (tags.length > 0) {
      const tagIds: string[] = []

      for (const tagName of tags) {
        const tag = await findOrCreateTag(userId, tagName)
        tagIds.push(tag.id)
      }

      const linkTagsData = tagIds.map((tagId) => ({
        link_id: linkId,
        tag_id: tagId,
      }))

      await supabase.from('link_tags').insert(linkTagsData)
    }
  }

  return link
}
