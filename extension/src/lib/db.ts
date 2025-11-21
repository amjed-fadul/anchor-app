import { supabase } from './supabase';

export interface Link {
    id: string;
    url: string;
    title: string | null;
    description: string | null;
    thumbnail_url: string | null;
    domain: string | null;
    note: string | null;
    space_id: string | null;
    created_at: string;
    updated_at: string;
    opened_at: string | null;
    tags?: string[];
}

export interface Space {
    id: string;
    name: string;
    color: string;
}

export interface Tag {
    id: string;
    name: string;
    color: string;
}

// 14-color palette matching mobile app
const TAG_COLORS = [
    '#9b87f5', '#f97066', '#fb923c', '#facc15', '#4ade80',
    '#2dd4bf', '#22d3ee', '#60a5fa', '#a78bfa', '#f472b6',
    '#a3a3a3', '#78716c', '#1e3a5f', '#0d9488',
];

function getRandomTagColor(): string {
    return TAG_COLORS[Math.floor(Math.random() * TAG_COLORS.length)];
}

export const db = {
    // Fetch all links for the current user
    async getLinks(spaceId?: string | null): Promise<Link[]> {
        let query = supabase
            .from('links')
            .select(`
        id,
        url,
        title,
        description,
        thumbnail_url,
        domain,
        note,
        space_id,
        created_at,
        updated_at,
        opened_at,
        link_tags(tag_id, tags(name))
      `)
            .order('created_at', { ascending: false });

        // Filter by space if provided
        if (spaceId !== undefined) {
            if (spaceId === null) {
                query = query.is('space_id', null);
            } else {
                query = query.eq('space_id', spaceId);
            }
        }

        const { data, error } = await query;

        if (error) {
            console.error('Error fetching links:', error);
            throw error;
        }

        // Transform the data to include tags as an array
        return (data || []).map((link: any) => ({
            ...link,
            tags: link.link_tags?.map((lt: any) => lt.tags?.name).filter(Boolean) || [],
        }));
    },

    // Fetch all spaces for the current user
    async getSpaces(): Promise<Space[]> {
        const { data, error } = await supabase
            .from('spaces')
            .select('id, name, color')
            .order('is_default', { ascending: false })
            .order('name', { ascending: true });

        if (error) {
            console.error('Error fetching spaces:', error);
            throw error;
        }

        return data || [];
    },

    // Create a new link
    async createLink(params: {
        url: string;
        normalizedUrl: string;
        title?: string | null;
        description?: string | null;
        thumbnailUrl?: string | null;
        domain?: string | null;
        note?: string | null;
        spaceId?: string | null;
        tagIds?: string[];
    }): Promise<Link> {
        // Get current user (required for RLS)
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            throw new Error('User must be authenticated to create links');
        }

        const { data, error } = await supabase
            .from('links')
            .insert({
                user_id: user.id, // Required for RLS policy
                url: params.url,
                normalized_url: params.normalizedUrl,
                title: params.title,
                description: params.description,
                thumbnail_url: params.thumbnailUrl,
                domain: params.domain,
                note: params.note,
                space_id: params.spaceId,
            })
            .select()
            .single();

        if (error) {
            console.error('Error creating link:', error);
            throw error;
        }

        // Add tags to the link if provided
        if (params.tagIds && params.tagIds.length > 0) {
            await db.addTagsToLink(data.id, params.tagIds);
        }

        return {
            id: data.id,
            url: data.url,
            title: data.title,
            description: data.description,
            thumbnail_url: data.thumbnail_url,
            domain: data.domain,
            note: data.note,
            space_id: data.space_id,
            created_at: data.created_at,
            updated_at: data.updated_at,
            opened_at: data.opened_at,
            tags: [],
        };
    },

    // Fetch all tags for the current user
    async getTags(): Promise<Tag[]> {
        const { data, error } = await supabase
            .from('tags')
            .select('id, name, color')
            .order('name', { ascending: true });

        if (error) {
            console.error('Error fetching tags:', error);
            throw error;
        }

        return data || [];
    },

    // Get or create a tag by name
    async getOrCreateTag(name: string): Promise<Tag> {
        const trimmedName = name.trim().toLowerCase();

        // Get current user
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
            throw new Error('User must be authenticated to create tags');
        }

        // First try to find existing tag (case-insensitive)
        const { data: existing } = await supabase
            .from('tags')
            .select('id, name, color')
            .ilike('name', trimmedName)
            .single();

        if (existing) {
            return existing;
        }

        // Create new tag with random color
        const { data, error } = await supabase
            .from('tags')
            .insert({
                user_id: user.id,
                name: trimmedName,
                color: getRandomTagColor(),
            })
            .select('id, name, color')
            .single();

        if (error) {
            console.error('Error creating tag:', error);
            throw error;
        }

        return data;
    },

    // Link tags to a link (after link is created)
    async addTagsToLink(linkId: string, tagIds: string[]): Promise<void> {
        if (!tagIds.length) return;

        const { error } = await supabase
            .from('link_tags')
            .insert(
                tagIds.map(tagId => ({
                    link_id: linkId,
                    tag_id: tagId,
                }))
            );

        if (error) {
            console.error('Error linking tags:', error);
            throw error;
        }
    },

    // Get relative time string (e.g., "2h ago", "1d ago")
    getRelativeTime(timestamp: string): string {
        const now = new Date();
        const past = new Date(timestamp);
        const diffMs = now.getTime() - past.getTime();
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMins / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffMins < 1) return 'just now';
        if (diffMins < 60) return `${diffMins}m ago`;
        if (diffHours < 24) return `${diffHours}h ago`;
        if (diffDays < 7) return `${diffDays}d ago`;
        return past.toLocaleDateString();
    },

    // Get link counts per space
    async getLinkCounts(): Promise<{ all: number; unsorted: number; bySpace: Record<string, number> }> {
        const { data, error } = await supabase
            .from('links')
            .select('id, space_id');

        if (error) {
            console.error('Error fetching link counts:', error);
            return { all: 0, unsorted: 0, bySpace: {} };
        }

        const links = data || [];
        const bySpace: Record<string, number> = {};
        let unsorted = 0;

        links.forEach((link: any) => {
            if (link.space_id) {
                bySpace[link.space_id] = (bySpace[link.space_id] || 0) + 1;
            } else {
                unsorted++;
            }
        });

        return {
            all: links.length,
            unsorted,
            bySpace,
        };
    },
};
