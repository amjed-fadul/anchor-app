import { supabase } from './supabase';

export interface LinkMetadata {
    title: string;
    description: string | null;
    thumbnailUrl: string | null;
    domain: string;
}

/**
 * Check if URL is a YouTube video
 */
function isYouTubeUrl(url: string): boolean {
    return /^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\//i.test(url);
}

/**
 * Extract video ID from YouTube URL
 */
function extractYouTubeVideoId(url: string): string | null {
    // youtube.com/watch?v=VIDEO_ID
    const watchMatch = url.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
    if (watchMatch) return watchMatch[1];

    // youtu.be/VIDEO_ID
    const shortMatch = url.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/);
    if (shortMatch) return shortMatch[1];

    // youtube.com/embed/VIDEO_ID
    const embedMatch = url.match(/\/embed\/([a-zA-Z0-9_-]{11})/);
    if (embedMatch) return embedMatch[1];

    return null;
}

/**
 * Fetch YouTube metadata using oEmbed API (official, guaranteed to work)
 */
async function fetchYouTubeMetadata(url: string): Promise<LinkMetadata | null> {
    try {
        console.log('🎬 [METADATA] Trying YouTube oEmbed API...');
        const oembedUrl = `https://www.youtube.com/oembed?url=${encodeURIComponent(url)}&format=json`;

        const response = await fetch(oembedUrl);
        if (!response.ok) {
            console.log('⚠️ [METADATA] YouTube oEmbed failed:', response.status);
            return null;
        }

        const data = await response.json();
        console.log('🟢 [METADATA] YouTube oEmbed data:', data);

        // Extract video ID for thumbnail
        const videoId = extractYouTubeVideoId(url);
        const thumbnailUrl = videoId
            ? `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`
            : data.thumbnail_url;

        return {
            title: data.title || 'YouTube Video',
            description: data.author_name ? `By ${data.author_name}` : null,
            thumbnailUrl,
            domain: 'youtube.com',
        };
    } catch (error) {
        console.error('❌ [METADATA] YouTube oEmbed error:', error);
        return null;
    }
}

/**
 * Extract metadata from HTML string using regex (browser-safe, no DOM needed)
 */
function extractMetadataFromHtml(html: string, url: string): Partial<LinkMetadata> {
    const result: Partial<LinkMetadata> = {};

    // Helper to get meta tag content
    const getMetaContent = (property: string, name?: string): string | undefined => {
        // Try property attribute
        const propRegex = new RegExp(`<meta[^>]*property=["']${property}["'][^>]*content=["']([^"']+)["']`, 'i');
        let match = propRegex.exec(html);
        if (match) return match[1];

        // Try content before property
        const propRegex2 = new RegExp(`<meta[^>]*content=["']([^"']+)["'][^>]*property=["']${property}["']`, 'i');
        match = propRegex2.exec(html);
        if (match) return match[1];

        // Try name attribute
        if (name) {
            const nameRegex = new RegExp(`<meta[^>]*name=["']${name}["'][^>]*content=["']([^"']+)["']`, 'i');
            match = nameRegex.exec(html);
            if (match) return match[1];

            const nameRegex2 = new RegExp(`<meta[^>]*content=["']([^"']+)["'][^>]*name=["']${name}["']`, 'i');
            match = nameRegex2.exec(html);
            if (match) return match[1];
        }

        return undefined;
    };

    // Decode HTML entities
    const decodeEntities = (text: string): string => {
        return text
            .replace(/&amp;/g, '&')
            .replace(/&lt;/g, '<')
            .replace(/&gt;/g, '>')
            .replace(/&quot;/g, '"')
            .replace(/&#39;/g, "'")
            .replace(/&#x27;/g, "'");
    };

    // Extract title
    const ogTitle = getMetaContent('og:title');
    const twitterTitle = getMetaContent('twitter:title', 'twitter:title');
    const titleMatch = /<title[^>]*>([^<]+)<\/title>/i.exec(html);
    const htmlTitle = titleMatch ? titleMatch[1].trim() : undefined;

    result.title = ogTitle || twitterTitle || htmlTitle;
    if (result.title) result.title = decodeEntities(result.title);

    // Extract description
    const ogDesc = getMetaContent('og:description');
    const twitterDesc = getMetaContent('twitter:description', 'twitter:description');
    const metaDesc = getMetaContent('description', 'description');

    result.description = ogDesc || twitterDesc || metaDesc || null;
    if (result.description) result.description = decodeEntities(result.description);

    // Extract thumbnail
    const ogImage = getMetaContent('og:image');
    const twitterImage = getMetaContent('twitter:image', 'twitter:image');

    result.thumbnailUrl = ogImage || twitterImage || null;

    // Convert relative URLs to absolute
    if (result.thumbnailUrl && !result.thumbnailUrl.startsWith('http')) {
        if (result.thumbnailUrl.startsWith('//')) {
            result.thumbnailUrl = `https:${result.thumbnailUrl}`;
        } else {
            try {
                result.thumbnailUrl = new URL(result.thumbnailUrl, url).toString();
            } catch {
                // Invalid URL, leave as-is
            }
        }
    }

    return result;
}

/**
 * Fetch metadata directly from browser (uses extension's host_permissions)
 */
async function fetchDirectMetadata(url: string): Promise<LinkMetadata | null> {
    try {
        console.log('🌐 [METADATA] Trying direct browser fetch...');

        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 10000);

        const response = await fetch(url, {
            headers: {
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.9',
            },
            signal: controller.signal,
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
            console.log('⚠️ [METADATA] Direct fetch failed:', response.status);
            return null;
        }

        const html = await response.text();
        console.log(`🟢 [METADATA] Direct fetch received ${(html.length / 1024).toFixed(1)}KB`);

        const domain = new URL(url).hostname.replace(/^www\./, '');
        const extracted = extractMetadataFromHtml(html, url);

        return {
            title: extracted.title || domain,
            description: extracted.description || null,
            thumbnailUrl: extracted.thumbnailUrl || null,
            domain,
        };
    } catch (error: any) {
        if (error.name === 'AbortError') {
            console.log('⚠️ [METADATA] Direct fetch timed out');
        } else {
            console.error('❌ [METADATA] Direct fetch error:', error.message);
        }
        return null;
    }
}

/**
 * Fetch metadata using Supabase Edge Function (fallback)
 */
async function fetchEdgeFunctionMetadata(url: string): Promise<LinkMetadata | null> {
    try {
        console.log('☁️ [METADATA] Trying Edge Function...');

        const { data, error } = await supabase.functions.invoke('fetch-metadata', {
            body: { url },
        });

        if (error) {
            console.error('❌ [METADATA] Edge function error:', error);
            return null;
        }

        if (data?.error) {
            console.error('❌ [METADATA] Edge function returned error:', data.error);
            return null;
        }

        if (!data) {
            console.log('⚠️ [METADATA] No data from Edge Function');
            return null;
        }

        console.log('🟢 [METADATA] Edge Function succeeded:', data);
        return data as LinkMetadata;
    } catch (error: any) {
        console.error('❌ [METADATA] Edge Function failed:', error.message);
        return null;
    }
}

/**
 * Fetch metadata for a URL using multiple strategies
 *
 * Fallback chain:
 * 1. YouTube URLs → oEmbed API (official, guaranteed)
 * 2. Direct browser fetch (uses user's IP, not datacenter)
 * 3. Edge Function (server-side, may be blocked by some sites)
 * 4. Basic fallback (domain name only)
 */
export async function fetchMetadata(url: string): Promise<LinkMetadata> {
    const domain = new URL(url).hostname.replace(/^www\./, '');
    console.log('🔍 [METADATA] Starting metadata fetch for:', url);

    // Strategy 1: YouTube oEmbed (official API, always works)
    if (isYouTubeUrl(url)) {
        const youtubeData = await fetchYouTubeMetadata(url);
        if (youtubeData) {
            console.log('✅ [METADATA] YouTube oEmbed succeeded');
            return youtubeData;
        }
    }

    // Strategy 2: Direct browser fetch (uses extension permissions)
    const directData = await fetchDirectMetadata(url);
    if (directData && directData.title !== domain) {
        console.log('✅ [METADATA] Direct fetch succeeded');
        return directData;
    }

    // Strategy 3: Edge Function (server-side fallback)
    const edgeData = await fetchEdgeFunctionMetadata(url);
    if (edgeData) {
        console.log('✅ [METADATA] Edge Function succeeded');
        return edgeData;
    }

    // Strategy 4: Basic fallback
    console.log('⚠️ [METADATA] All strategies failed, using basic fallback');
    return {
        title: domain,
        description: null,
        thumbnailUrl: null,
        domain,
    };
}
