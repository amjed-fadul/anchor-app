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
