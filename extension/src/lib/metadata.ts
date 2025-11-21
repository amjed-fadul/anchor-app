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
        console.log('🔍 [METADATA] Starting fetch for:', url);
        console.log('🔍 [METADATA] Supabase URL:', import.meta.env.VITE_SUPABASE_URL);

        const { data, error } = await supabase.functions.invoke('fetch-metadata', {
            body: { url },
        });

        console.log('🔍 [METADATA] Response data:', data);
        console.log('🔍 [METADATA] Response error:', error);

        if (error) {
            console.error('❌ [METADATA] Edge function error:', error);
            throw new Error(`Edge Function error: ${error.message || JSON.stringify(error)}`);
        }

        if (data?.error) {
            console.error('❌ [METADATA] Data contains error:', data.error);
            throw new Error(`Metadata fetch error: ${data.error}`);
        }

        if (!data) {
            throw new Error('No data returned from Edge Function');
        }

        console.log('✅ [METADATA] Successfully fetched:', data);
        return data as LinkMetadata;
    } catch (error: any) {
        console.error('❌ [METADATA] Failed to fetch metadata:', error);
        console.error('❌ [METADATA] Error stack:', error.stack);

        // Re-throw the error so we can see it in the UI
        throw new Error(`Metadata fetch failed: ${error.message || 'Unknown error'}`);
    }
}
