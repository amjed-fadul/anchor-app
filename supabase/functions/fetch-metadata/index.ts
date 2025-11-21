import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { DOMParser } from "https://deno.land/x/deno_dom@v0.1.38/deno-dom-wasm.ts"

interface MetadataResponse {
    title: string
    description: string | null
    thumbnailUrl: string | null
    domain: string
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

        // Fetch the webpage
        const response = await fetch(url, {
            headers: {
                'User-Agent': 'Mozilla/5.0 (compatible; AnchorBot/1.0; +https://anchor.app)',
            },
            signal: AbortSignal.timeout(10000), // 10 second timeout
        })

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`)
        }

        const html = await response.text()
        const doc = new DOMParser().parseFromString(html, 'text/html')

        if (!doc) {
            throw new Error('Failed to parse HTML')
        }

        // Extract domain
        const domain = new URL(url).hostname.replace(/^www\./, '')

        // Extract title (priority: og:title > title tag > domain)
        let title = ''
        const ogTitle = doc.querySelector('meta[property="og:title"]')
        if (ogTitle) {
            title = ogTitle.getAttribute('content') || ''
        }
        if (!title) {
            const titleTag = doc.querySelector('title')
            title = titleTag?.textContent || ''
        }
        if (!title) {
            title = domain
        }

        // Extract description (priority: og:description > meta description)
        let description: string | null = null
        const ogDescription = doc.querySelector('meta[property="og:description"]')
        if (ogDescription) {
            description = ogDescription.getAttribute('content')
        }
        if (!description) {
            const metaDescription = doc.querySelector('meta[name="description"]')
            description = metaDescription?.getAttribute('content') || null
        }

        // Extract thumbnail (priority: og:image > twitter:image)
        let thumbnailUrl: string | null = null
        const ogImage = doc.querySelector('meta[property="og:image"]')
        if (ogImage) {
            thumbnailUrl = ogImage.getAttribute('content')
        }
        if (!thumbnailUrl) {
            const twitterImage = doc.querySelector('meta[name="twitter:image"]')
            thumbnailUrl = twitterImage?.getAttribute('content') || null
        }

        // Convert relative URLs to absolute
        if (thumbnailUrl && !thumbnailUrl.startsWith('http')) {
            if (thumbnailUrl.startsWith('//')) {
                thumbnailUrl = `${new URL(url).protocol}${thumbnailUrl}`
            } else {
                thumbnailUrl = new URL(thumbnailUrl, url).toString()
            }
        }

        const metadata: MetadataResponse = {
            title: title.trim(),
            description: description?.trim() || null,
            thumbnailUrl,
            domain,
        }

        console.log(`✅ Metadata extracted: ${metadata.title}`)

        return new Response(
            JSON.stringify(metadata),
            {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            }
        )
    } catch (error) {
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
