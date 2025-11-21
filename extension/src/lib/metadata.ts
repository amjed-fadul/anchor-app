import { supabase } from './supabase';

export interface LinkMetadata {
    title: string;
    description: string | null;
    thumbnailUrl: string | null;
    domain: string;
}

/**
 * Fetch metadata for a URL using Supabase Edge Function
 * 
 * This bypasses CORS restrictions by making the request server-side
 */
export async function fetchMetadata(url: string): Promise<LinkMetadata> {
    try {
        const { data, error } = await supabase.functions.invoke('fetch-metadata', {
            body: { url },
        });

        if (error) {
            console.error('Edge function error:', error);
            throw error;
        }

        if (data.error) {
            console.error('Metadata fetch error:', data.error);
            throw new Error(data.error);
        }

        return data as LinkMetadata;
    } catch (error) {
        console.error('Failed to fetch metadata:', error);
        // Fallback: extract domain as title
        const domain = new URL(url).hostname.replace(/^www\./, '');
        return {
            title: domain,
            description: null,
            thumbnailUrl: null,
            domain,
        };
    }
}
