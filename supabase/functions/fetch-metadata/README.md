# Deploying the Fetch Metadata Edge Function

## Prerequisites
- Supabase CLI installed (`npm install -g supabase`)
- Authenticated with your Supabase project

## Deploy Command

```bash
cd /Users/amjedfadul/anchor-app
supabase functions deploy fetch-metadata
```

## What This Function Does

- Fetches HTML content from any URL
- Extracts Open Graph metadata (title, description, thumbnail)
- Bypasses CORS restrictions (runs server-side)
- Returns structured metadata to the extension

## Testing

After deployment, test it manually:

```bash
curl -X POST https://your-project-ref.supabase.co/functions/v1/fetch-metadata \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com"}'
```

## Environment

The function will be available at:
- Production: `https://your-project-ref.supabase.co/functions/v1/fetch-metadata`
- Local testing: `http://localhost:54321/functions/v1/fetch-metadata`
