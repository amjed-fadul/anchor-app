import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { DOMParser } from "https://deno.land/x/deno_dom@v0.1.38/deno-dom-wasm.ts"

interface MetadataResponse {
    title: string
    description: string | null
    thumbnailUrl: string | null
    domain: string
}

// User-Agent rotation to avoid bot detection
const USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.1 Safari/605.1.15',
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
]

function getRandomUserAgent(): string {
    return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)]
}

// Extract JSON-LD structured data (works for YouTube, news sites, e-commerce, etc.)
function extractFromJsonLD(html: string): { title?: string; description?: string; thumbnailUrl?: string } {
    const result: { title?: string; description?: string; thumbnailUrl?: string } = {}

    // Find all JSON-LD script blocks using regex (faster than DOM parsing for this)
    const jsonLdRegex = /<script[^>]*type=["']application\/ld\+json["'][^>]*>([\s\S]*?)<\/script>/gi
    let match

    while ((match = jsonLdRegex.exec(html)) !== null) {
        try {
            const jsonStr = match[1].trim()
            const data = JSON.parse(jsonStr)

            // Handle array of JSON-LD objects
            const objects = Array.isArray(data) ? data : [data]

            for (const obj of objects) {
                // VideoObject (YouTube, Vimeo, etc.)
                if (obj['@type'] === 'VideoObject') {
                    result.title = result.title || obj.name
                    result.description = result.description || obj.description
                    result.thumbnailUrl = result.thumbnailUrl ||
                        (Array.isArray(obj.thumbnailUrl) ? obj.thumbnailUrl[0] : obj.thumbnailUrl) ||
                        obj.thumbnail?.url
                }

                // Article, NewsArticle, BlogPosting (news sites, blogs)
                if (['Article', 'NewsArticle', 'BlogPosting', 'WebPage'].includes(obj['@type'])) {
                    result.title = result.title || obj.headline || obj.name
                    result.description = result.description || obj.description
                    result.thumbnailUrl = result.thumbnailUrl ||
                        obj.image?.url ||
                        (Array.isArray(obj.image) ? obj.image[0]?.url || obj.image[0] : obj.image)
                }

                // Product (e-commerce sites)
                if (obj['@type'] === 'Product') {
                    result.title = result.title || obj.name
                    result.description = result.description || obj.description
                    result.thumbnailUrl = result.thumbnailUrl ||
                        obj.image?.url ||
                        (Array.isArray(obj.image) ? obj.image[0] : obj.image)
                }

                // Organization, WebSite (general fallback)
                if (['Organization', 'WebSite'].includes(obj['@type'])) {
                    result.title = result.title || obj.name
                    result.description = result.description || obj.description
                    result.thumbnailUrl = result.thumbnailUrl || obj.logo?.url || obj.logo
                }

                // Handle @graph structure (common in WordPress, etc.)
                if (obj['@graph'] && Array.isArray(obj['@graph'])) {
                    for (const graphItem of obj['@graph']) {
                        if (['Article', 'NewsArticle', 'BlogPosting', 'WebPage', 'VideoObject', 'Product'].includes(graphItem['@type'])) {
                            result.title = result.title || graphItem.headline || graphItem.name
                            result.description = result.description || graphItem.description
                            result.thumbnailUrl = result.thumbnailUrl ||
                                graphItem.image?.url ||
                                (Array.isArray(graphItem.image) ? graphItem.image[0]?.url || graphItem.image[0] : graphItem.image) ||
                                graphItem.thumbnailUrl
                        }
                    }
                }
            }
        } catch (e) {
            // JSON parse error - continue to next block
            console.log('⚠️ JSON-LD parse error (skipping block):', e.message)
        }
    }

    return result
}

// Extract meta tags using regex (faster for large HTML)
function extractMetaTagsRegex(html: string): {
    ogTitle?: string;
    ogDescription?: string;
    ogImage?: string;
    twitterTitle?: string;
    twitterDescription?: string;
    twitterImage?: string;
    metaDescription?: string;
    title?: string;
} {
    const result: any = {}

    // Helper to extract meta content
    const getMetaContent = (property: string, name?: string): string | undefined => {
        // Try property attribute (og:, etc.)
        const propRegex = new RegExp(`<meta[^>]*property=["']${property}["'][^>]*content=["']([^"']+)["']`, 'i')
        let match = propRegex.exec(html)
        if (match) return match[1]

        // Try content before property
        const propRegex2 = new RegExp(`<meta[^>]*content=["']([^"']+)["'][^>]*property=["']${property}["']`, 'i')
        match = propRegex2.exec(html)
        if (match) return match[1]

        // Try name attribute
        if (name) {
            const nameRegex = new RegExp(`<meta[^>]*name=["']${name}["'][^>]*content=["']([^"']+)["']`, 'i')
            match = nameRegex.exec(html)
            if (match) return match[1]

            const nameRegex2 = new RegExp(`<meta[^>]*content=["']([^"']+)["'][^>]*name=["']${name}["']`, 'i')
            match = nameRegex2.exec(html)
            if (match) return match[1]
        }

        return undefined
    }

    // Open Graph tags
    result.ogTitle = getMetaContent('og:title')
    result.ogDescription = getMetaContent('og:description')
    result.ogImage = getMetaContent('og:image')

    // Twitter Card tags
    result.twitterTitle = getMetaContent('twitter:title', 'twitter:title')
    result.twitterDescription = getMetaContent('twitter:description', 'twitter:description')
    result.twitterImage = getMetaContent('twitter:image', 'twitter:image')

    // Standard meta description
    result.metaDescription = getMetaContent('description', 'description')

    // Extract title tag
    const titleMatch = /<title[^>]*>([^<]+)<\/title>/i.exec(html)
    if (titleMatch) {
        result.title = titleMatch[1].trim()
    }

    return result
}

// Extract first H1 as fallback title
function extractH1(html: string): string | undefined {
    const h1Match = /<h1[^>]*>([^<]+)<\/h1>/i.exec(html)
    if (h1Match) {
        return h1Match[1].trim()
    }
    return undefined
}

// Decode HTML entities
function decodeHtmlEntities(text: string): string {
    return text
        .replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&#39;/g, "'")
        .replace(/&apos;/g, "'")
        .replace(/&#x27;/g, "'")
        .replace(/&#x2F;/g, '/')
        .replace(/&#(\d+);/g, (_, num) => String.fromCharCode(parseInt(num, 10)))
        .replace(/&#x([a-fA-F0-9]+);/g, (_, hex) => String.fromCharCode(parseInt(hex, 16)))
}

serve(async (req) => {
    // CORS headers
    const corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    }

    // Handle OPTIONS request for CORS
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { url } = await req.json()

        if (!url) {
            return new Response(
                JSON.stringify({ error: 'URL is required' }),
                {
                    status: 400,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                }
            )
        }

        console.log(`📡 Fetching metadata for: ${url}`)

        // Extract domain early (always works)
        const domain = new URL(url).hostname.replace(/^www\./, '')

        let html: string

        // Phase 1: Download HTML with 15-second timeout
        try {
            console.log('🔵 Starting HTML download...')
            const controller = new AbortController()
            const downloadTimeout = setTimeout(() => controller.abort(), 15000)

            const response = await fetch(url, {
                headers: {
                    'User-Agent': getRandomUserAgent(),
                    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                    'Accept-Encoding': 'gzip, deflate',
                    'Cache-Control': 'no-cache',
                },
                signal: controller.signal,
            })

            clearTimeout(downloadTimeout)

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`)
            }

            html = await response.text()
            console.log(`🟢 HTML downloaded: ${(html.length / 1024).toFixed(1)}KB`)

        } catch (downloadError: any) {
            console.error('🔴 Download failed:', downloadError.message)
            // Return basic fallback with just domain
            return new Response(
                JSON.stringify({
                    title: domain,
                    description: null,
                    thumbnailUrl: null,
                    domain,
                    fallback: true,
                    reason: `Download failed: ${downloadError.message}`
                }),
                {
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                }
            )
        }

        // Phase 2: Extract metadata with multi-source fallback
        let title: string | null = null
        let description: string | null = null
        let thumbnailUrl: string | null = null

        try {
            console.log('🔵 Starting metadata extraction...')

            // Source 1: JSON-LD (most reliable for modern sites)
            console.log('🔵 Trying JSON-LD extraction...')
            const jsonLdData = extractFromJsonLD(html)
            if (jsonLdData.title) {
                console.log('🟢 JSON-LD found title:', jsonLdData.title.substring(0, 50))
            }

            // Source 2: Meta tags via regex (faster than DOM for large pages)
            console.log('🔵 Trying meta tag extraction...')
            const metaTags = extractMetaTagsRegex(html)

            // Source 3: H1 fallback
            const h1Title = extractH1(html)

            // Build metadata with fallback chain
            // Title priority: og:title → JSON-LD → twitter:title → <title> → h1 → domain
            title = metaTags.ogTitle ||
                    jsonLdData.title ||
                    metaTags.twitterTitle ||
                    metaTags.title ||
                    h1Title ||
                    domain

            // Description priority: og:description → JSON-LD → twitter:description → meta description
            description = metaTags.ogDescription ||
                          jsonLdData.description ||
                          metaTags.twitterDescription ||
                          metaTags.metaDescription ||
                          null

            // Thumbnail priority: og:image → JSON-LD → twitter:image
            thumbnailUrl = metaTags.ogImage ||
                           jsonLdData.thumbnailUrl ||
                           metaTags.twitterImage ||
                           null

            // Decode HTML entities in extracted text
            if (title) title = decodeHtmlEntities(title)
            if (description) description = decodeHtmlEntities(description)

            console.log(`🟢 Extraction complete:`)
            console.log(`   Title: ${title?.substring(0, 50)}${title && title.length > 50 ? '...' : ''}`)
            console.log(`   Description: ${description ? 'Yes' : 'No'}`)
            console.log(`   Thumbnail: ${thumbnailUrl ? 'Yes' : 'No'}`)

        } catch (extractError: any) {
            console.error('🔴 Extraction error:', extractError.message)
            // Use domain as title if all extraction fails
            title = domain
        }

        // Convert relative URLs to absolute for thumbnail
        if (thumbnailUrl && !thumbnailUrl.startsWith('http')) {
            if (thumbnailUrl.startsWith('//')) {
                thumbnailUrl = `${new URL(url).protocol}${thumbnailUrl}`
            } else {
                thumbnailUrl = new URL(thumbnailUrl, url).toString()
            }
        }

        const metadata: MetadataResponse = {
            title: (title || domain).trim(),
            description: description?.trim() || null,
            thumbnailUrl,
            domain,
        }

        console.log(`✅ Metadata complete for: ${metadata.title}`)

        return new Response(
            JSON.stringify(metadata),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
        )
    } catch (error: any) {
        console.error('❌ Error fetching metadata:', error)

        return new Response(
            JSON.stringify({
                error: error.message || 'Failed to fetch metadata',
                fallback: true
            }),
            {
                status: 500,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
        )
    }
})
