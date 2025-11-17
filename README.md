# ⚓ Anchor

**"Anchored! Find it anytime"**

> A modern link management app that helps you save links from anywhere and actually find them later by organizing into spaces and remembering why you saved them.

---

## 🎯 What is Anchor?

Anchor is a cross-platform bookmark manager designed for people who save lots of links but can never find them later. Unlike traditional bookmarks, Anchor:

- **Saves in under 1 second** from any app (no modals, no friction)
- **Organizes into visual spaces** (collections you can browse)
- **Remembers context** (add tags and notes when you have time)
- **Syncs instantly** across all your devices

### The Problem We're Solving

Users save links across multiple platforms (Telegram, Notes, browser bookmarks) but:
- Can never find them later
- Forget why the link was important
- End up with hundreds of unused saves
- Waste time searching
- Lose valuable information

### Our Solution

Anchor makes saving and finding links effortless:
1. Share from any app → Instant save (no modal)
2. Add context later (tags, notes, spaces) - optional!
3. Find anything with powerful search
4. Organize with visual spaces (not nested folders)

---

## ✨ Key Features

### MVP Features (Phase 1)
- ⚡ **Instant Save Flow** - Save links in <1 second from any app
- 🎨 **Visual Spaces** - Organize into collections (Unread, Reference, custom)
- 🏷️ **Smart Tags** - Auto-suggestions based on domain
- 📝 **Context Notes** - Add why you saved it (200 char limit)
- 🔍 **Full-Text Search** - Find anything by title, note, URL, or tag
- 🔄 **Real-Time Sync** - Instant sync across all devices
- 📱 **Offline-First** - Works without internet, syncs when online
- 🌓 **Dark Mode** - Beautiful light and dark themes

---

## 🛠️ Technology Stack

### Mobile App (iOS & Android)
- **Framework:** Flutter 3.x
- **Language:** Dart
- **State Management:** Riverpod
- **Local Database:** Hive (offline-first)
- **UI:** Custom widgets following brand guide

### Browser Extensions (Chrome, Firefox, Edge, Brave)
- **Framework:** React + TypeScript
- **Manifest:** V3 (modern)
- **Storage:** IndexedDB (offline caching)
- **Build:** Vite

### Backend
- **Platform:** Supabase
- **Database:** PostgreSQL with full-text search
- **Auth:** Supabase Auth (Email, Google, Apple)
- **Real-Time:** WebSocket subscriptions
- **Functions:** Edge Functions (Deno/TypeScript)
- **Storage:** Supabase Storage (thumbnails)

---

## 📁 Project Structure

```
anchor-app/
├── mobile/                 # Flutter mobile app (iOS + Android)
│   ├── lib/
│   │   ├── features/      # Feature modules (auth, save, browse, etc.)
│   │   ├── core/          # Shared utilities and services
│   │   └── design_system/ # UI components and styling
│   ├── ios/               # iOS native code
│   └── android/           # Android native code
│
├── extension/             # Browser extension (React)
│   ├── src/               # Source code
│   ├── public/            # Static assets
│   └── manifest.json      # Extension config
│
├── supabase/              # Backend configuration
│   ├── migrations/        # Database schema (SQL)
│   ├── functions/         # Edge Functions
│   └── seed/              # Test data
│
├── PRD/                   # Product documentation
│   ├── AMENDMENTS.md      # ⚠️ Critical design decisions
│   ├── Anchor - Product Management Documentation.md
│   └── Anchor — Brand Style Guide.md
│
├── CHANGELOG.md           # Development history
├── TODO.md                # Current tasks and roadmap
├── README.md              # This file
└── claude.md              # AI assistant working preferences
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have:
- **Flutter SDK** (3.0 or higher) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Xcode** (for iOS) or **Android Studio** (for Android)
- **Supabase Account** (free tier) - [Sign up](https://supabase.com)
- **Git** installed

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/amjed-fadul/anchor-app.git
   cd anchor-app
   ```

2. **Set up Supabase**
   - Create a new Supabase project
   - Run migrations in `supabase/migrations/`
   - Copy your project URL and anon key

3. **Configure mobile app**
   ```bash
   cd mobile
   cp .env.example .env
   # Edit .env with your Supabase credentials
   flutter pub get
   ```

4. **Run the app**
   ```bash
   # iOS
   flutter run -d ios

   # Android
   flutter run -d android
   ```

For detailed setup instructions, see:
- [`mobile/README.md`](mobile/README.md) - Mobile app setup
- [`supabase/README.md`](supabase/README.md) - Backend setup

---

## 📖 Documentation

⚠️ **Important:** Read [PRD Amendments](PRD/AMENDMENTS.md) first to understand critical architectural decisions (Spaces-Only Model).

- **[Product Requirements Document](PRD/Anchor%20-%20Product%20Management%20Documentation.md)** - Complete feature specs, user stories, and acceptance criteria
- **[PRD Amendments](PRD/AMENDMENTS.md)** - ⚠️ **READ THIS FIRST** - Why we use Spaces instead of status field
- **[Brand Style Guide](PRD/Anchor%20—%20Brand%20Style%20Guide.md)** - Colors, typography, components, and design system
- **[Claude AI Preferences](claude.md)** - How we work with AI assistants on this project

---

## 🎨 Design System

Anchor follows a minimalist, professional design system:

- **Colors:** Anchor Slate (#2C3E50) + Anchor Teal (#0D9488)
- **Typography:** Geist font family (11px-48px scale)
- **Spacing:** 8px base unit system
- **Animations:** Quick and purposeful (100ms-400ms)
- **Success Gradient:** Green to Teal (celebration moments only)

See the [Brand Style Guide](PRD/Anchor%20—%20Brand%20Style%20Guide.md) for complete specifications.

---

## 📅 Development Roadmap

**Current Progress: ~70% Complete (Phase 5 of 6)**

### Phase 0: Foundation ✅ COMPLETE
- ✅ Project structure
- ✅ Database schema (PostgreSQL + Supabase)
- ✅ Design system (colors, typography, components)
- ✅ Flutter app skeleton

### Phase 1: Authentication ✅ COMPLETE
- ✅ Splash screen with auto-login
- ✅ Onboarding carousel with synchronized descriptions
- ✅ Sign up / Login flows
- ✅ Session management (persistent auth)
- ✅ Password reset flow

### Phase 2: Core Save Flow ✅ COMPLETE (Share Extension Deferred)
- ✅ Instant save confirmation (<1 second)
- ✅ Metadata extraction (title, description, favicon)
- ✅ URL shortener support (bit.ly, t.co, share.google)
- ✅ Offline support with queue sync
- ⏸️ iOS/Android share extension - **Deferred to Phase 6** (see [TODO.md](TODO.md))

### Phase 3: Browse & Search ✅ COMPLETE
- ✅ Home screen grid with visual link cards
- ✅ Tap to open links in browser
- ✅ Link detail view
- ✅ Edit/delete functionality
- ✅ Full-text search (backend ready, UI in progress)

### Phase 4: Organization ✅ COMPLETE
- ✅ Tags system with auto-complete
- ✅ Spaces system (Unread, Reference, custom spaces)
- ✅ Add details flow (tags, notes, space assignment)
- ✅ Move between spaces
- ✅ Color-coded space indicators

### Phase 5: Sync & Polish 🔄 IN PROGRESS (Current)
- ✅ Real-time sync across devices
- ✅ Settings screen (account, about, logout)
- 🔄 Bug fixes (19 test failures remaining - see [TODO.md](TODO.md))
- 🔄 UI polish and responsive design improvements

### Phase 6: Extensions & Share 📋 NOT STARTED
- Share extension integration (iOS + Android native)
- Chrome browser extension
- Firefox port
- Multi-browser support

**Estimated MVP Launch:** 2-4 weeks (Phase 5 polish + Phase 6 completion)

---

## 🎯 Success Metrics (First 90 Days Post-Launch)

*Note: App currently in beta development (Phase 5/6). Public launch date TBD.*

- **1,000** active users
- **10,000+** total links saved
- **35%+** week-1 retention rate
- **5+** saves per user per week
- **4.5+** app store rating
- **<3s** save time, **<500ms** search results

---

## 🤝 Contributing

The MVP is nearing completion (Phase 5/6). Contribution guidelines will be added before Phase 6 (Extensions).

For now, see:
- [CHANGELOG.md](CHANGELOG.md) - What's been done
- [TODO.md](TODO.md) - What's in progress
- [claude.md](claude.md) - How we work with AI assistants

---

## 📄 License

TBD - License will be determined before public launch.

---

## 📞 Contact

**Project Owner:** Amjed Fadul
**Repository:** [github.com/amjed-fadul/anchor-app](https://github.com/amjed-fadul/anchor-app)

---

## 🙏 Acknowledgments

- **Design System:** Inspired by minimalist principles
- **Fonts:** Geist by Vercel, IBM Plex Sans Arabic
- **Icons:** Lucide Icons (custom anchor symbol)
- **Backend:** Powered by Supabase

---

*Built with care for people who want to actually find their saved links.*

**Version:** 0.7.0 (Beta)
**Last Updated:** November 2025
