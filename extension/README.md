# Anchor Browser Extension

Save links from any webpage to Anchor. Organize into spaces, add tags & notes. Sync with the mobile app.

## Features

- 🚀 **One-click save** - Save current page with keyboard shortcut (Cmd/Ctrl+Shift+S)
- 📁 **Organize with Spaces** - Unread, Reference, or custom spaces
- 🏷️ **Tag and note** - Add tags with auto-complete and notes (200 chars)
- 🔄 **Real-time sync** - Changes sync instantly with mobile app
- 🔍 **Quick search** - Find saved links by title, note, domain, or URL
- 📱 **Cross-platform** - Works with the Anchor mobile app (iOS & Android)

## Tech Stack

- **Framework:** React 18 + TypeScript
- **Build Tool:** Vite with CRXJS plugin
- **Backend:** Supabase (Auth, Database, Realtime)
- **Styling:** Tailwind CSS
- **State:** Zustand
- **Storage:** IndexedDB (Dexie.js)
- **Icons:** Lucide React

## Development

### Prerequisites

- Node.js 18+ and npm
- Chrome browser (for testing)
- Anchor mobile app Supabase credentials

### Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Create `.env` file:**
   ```bash
   cp .env.example .env
   ```

3. **Add Supabase credentials:**
   ```env
   VITE_SUPABASE_URL=your_supabase_url
   VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Start development server:**
   ```bash
   npm run dev
   ```

5. **Load extension in Chrome:**
   - Open Chrome and go to `chrome://extensions/`
   - Enable "Developer mode" (toggle in top-right)
   - Click "Load unpacked"
   - Select the `extension/dist` folder

### Build for Production

```bash
npm run build
```

The production-ready extension will be in `dist/` directory.

### Testing

1. **In Chrome:**
   - Navigate to any webpage
   - Click the Anchor icon in toolbar (or press Cmd/Ctrl+Shift+S)
   - Extension popup should open

2. **Test features:**
   - Sign in with Google
   - Save current page
   - Browse saved links
   - Search functionality
   - Real-time sync (save on mobile, see in extension)

## Project Structure

```
extension/
├── src/
│   ├── background/         # Service worker
│   │   └── index.ts       # Background tasks, auth, sync
│   ├── content/           # Content scripts
│   │   └── index.ts       # Page metadata extraction
│   ├── lib/               # Shared utilities
│   │   ├── supabase.ts    # Supabase client
│   │   ├── db.ts          # IndexedDB wrapper
│   │   └── types.ts       # TypeScript types
│   ├── popup/             # Popup UI components
│   │   ├── SaveMode.tsx   # Save current page form
│   │   ├── BrowseMode.tsx # Browse saved links
│   │   └── Auth.tsx       # Authentication UI
│   ├── App.tsx            # Main app component
│   ├── main.tsx           # React entry point
│   ├── index.css          # Global styles
│   └── manifest.json      # Chrome extension manifest
├── public/
│   └── icons/             # Extension icons
├── index.html             # Popup HTML
├── package.json
├── vite.config.ts
└── README.md
```

## Chrome Extension Permissions

- **storage** - Save user preferences and cached links
- **tabs** - Detect current page URL and title
- **contextMenus** - Right-click to save links
- **notifications** - Show save confirmations
- **host_permissions** - Extract metadata from web pages

## Keyboard Shortcuts

- **Cmd/Ctrl+Shift+S** - Open extension and save current page

## Browser Support

- ✅ **Chrome** (primary target)
- ✅ **Edge, Brave** (Chromium-based, same codebase)
- 🔜 **Firefox** (requires Manifest V2 compatibility layer)

## Architecture

### Data Flow

```
Webpage → Content Script → Background Worker → Supabase → Mobile App
                ↓                    ↓
            Metadata           Auth + Sync
```

### Sync Strategy

1. **Optimistic UI** - Show success immediately
2. **Background queue** - Send to Supabase asynchronously
3. **Real-time updates** - Subscribe to changes from mobile app
4. **Offline support** - Queue saves when offline, sync when back online

## Roadmap

### Phase 1: Foundation (Week 1-2) ✅
- [x] Project setup (React + Vite + TypeScript)
- [x] Manifest V3 configuration
- [x] Basic UI shell
- [ ] Google OAuth authentication
- [ ] Supabase client setup

### Phase 2: Save Flow (Week 3-4)
- [ ] Current page detection
- [ ] Metadata extraction
- [ ] Save form UI (space, tags, note)
- [ ] Supabase integration
- [ ] Success feedback

### Phase 3: Browse Mode (Week 5-6)
- [ ] Link list view
- [ ] Real-time sync
- [ ] IndexedDB cache
- [ ] Search functionality
- [ ] Context menu actions

### Phase 4: Polish & Launch (Week 7-8)
- [ ] Badge count (Unread space)
- [ ] Offline queue
- [ ] Performance optimization
- [ ] Chrome Web Store submission
- [ ] Cross-browser testing

## Contributing

This is part of the Anchor app project. See the main repo README for contribution guidelines.

## License

Proprietary - All rights reserved

---

**Made with ❤️ by the Anchor team**
