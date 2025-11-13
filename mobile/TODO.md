# TODO & Project Roadmap

**Last Updated:** 2025-11-13 16:30

This file tracks active tasks, planned features, known issues, and future ideas for the Anchor App.

**Format:**
- ✅ Completed
- 🚧 In Progress
- 📋 Planned (not started)
- 🐛 Known Issue
- 💡 Future Idea

---

## 🚧 Active Tasks

*Currently working on: Home Screen Implementation (started 2025-11-13 16:00)*

### Phase 2: Services (In Progress)
- 🚧 Write LinkService tests (TDD - RED) - Step 2.1
- 📋 Implement LinkService.getLinksWithTags() (TDD - GREEN) - Step 2.2

### Phase 3: Providers (Next)
- 📋 Create Link providers for state management - Step 3.1

### Phase 4: UI Components (Upcoming)
- 📋 Create TagBadge widget - Step 4.1
- 📋 Create LinkCard widget matching Figma design - Step 4.2
- 📋 Create SearchBar widget (visual only) - Step 4.3

### Phase 5: Home Screen UI (Upcoming)
- 📋 Implement home screen header with avatar and search - Step 5.1
- 📋 Implement link cards grid with GridView - Step 5.2
- 📋 Add loading skeleton for link cards - Step 5.3
- 📋 Add empty state for home screen - Step 5.4

### Phase 6: Navigation & Polish (Upcoming)
- 📋 Add FAB to home screen - Step 6.1
- 📋 Add bottom navigation bar to home screen - Step 6.2
- 📋 Add pull-to-refresh to home screen - Step 7.1
- 📋 Test responsive layout on multiple device sizes - Step 7.2
- 📋 Add tap to open link in browser - Step 7.3

---

## 📋 Planned Features

### High Priority
- 📋 Home screen implementation (saved links display)
- 📋 Add link functionality (save URLs)
- 📋 Spaces feature (organize links into categories)
- 📋 Tags feature (label and filter links)
- 📋 Settings screen (account management, preferences)

### Medium Priority
- 📋 Search functionality (find saved links)
- 📋 Link sharing (share saved links with others)
- 📋 Link preview generation (show thumbnails, titles)
- 📋 Offline support (access links without internet)

### Low Priority
- 📋 Dark mode support
- 📋 Import links from browser
- 📋 Export links to CSV/JSON
- 📋 Link analytics (track click counts)

---

## 🐛 Known Issues

*No known issues as of 2025-11-13 14:45*

---

## ✅ Recently Completed (Last 7 Days)

### 2025-11-13

**Phase 1: Data Models (16:00-16:30)**
- ✅ Created Link model with 8 comprehensive tests (16:10)
- ✅ Created Tag model with 6 comprehensive tests (16:20)
- ✅ All model tests passing (14 tests total)

**Documentation & Planning (15:00-16:00)**
- ✅ Created TODO.md for project planning and tracking (15:45)
- ✅ Updated CLAUDE.md with TODO.md maintenance instructions (15:50)
- ✅ Analyzed Figma design for home screen (16:00)
- ✅ Created detailed implementation plan (18 steps)

**Auth Fixes & Documentation (Earlier Today)**
- ✅ Fixed signup redirect to onboarding issue (14:37)
- ✅ Configured email confirmation deep link (14:40)
- ✅ Created CHANGELOG.md documentation (14:42)
- ✅ Updated CLAUDE.md with changelog maintenance instructions (14:44)
- ✅ Added timestamp format to changelog (14:45)
- ✅ Replaced 70 print() statements with logger package (13:45)
- ✅ Fixed 79 analyzer warnings → 0 warnings (13:48)
- ✅ Added DeepLinkService tests (10 tests) (13:30)
- ✅ Added SplashScreen tests (12 tests) (13:30)
- ✅ Fixed BuildContext async gap in onboarding screen (13:50)
- ✅ Fixed password reset flow race conditions (13:50)

---

## 💡 Future Ideas

*Ideas to consider for future releases:*

- 💡 Browser extension for easy link saving
- 💡 Collaboration features (shared spaces)
- 💡 AI-powered link categorization
- 💡 Integration with Notion, Evernote
- 💡 Mobile widget for quick link access
- 💡 Voice commands for adding links
- 💡 Smart notifications (remind about saved links)

---

## 📝 Notes

### Testing Strategy
- All new features must have unit tests (TDD approach)
- Test coverage goal: 80%+ for core features
- **Current test count: 97 tests** (83 auth/core + 14 models)

### Code Quality
- ✅ Maintain 0 analyzer warnings (currently 0)
- ✅ Use proper logging (no print statements)
- ✅ Follow Flutter/Dart style guide
- ✅ Document all public APIs

### Authentication Status
- ✅ Email/password signup working
- ✅ Email confirmation flow working
- ✅ Password reset working
- ✅ Deep linking configured
- ✅ Session management working
- 📋 OAuth (Google) - needs testing

### Data Models Status
- ✅ Link model (8 tests passing)
- ✅ Tag model (6 tests passing)
- 📋 Space model (not needed yet - will use existing structure)

### Database Status
- ✅ Supabase migrations applied
- ✅ Tables created: users, spaces, links, tags, link_tags
- ✅ RLS policies active
- ✅ Default spaces auto-create for new users

---

## 🔄 How to Use This File

**When starting a new task:**
1. Move item from "Planned Features" to "Active Tasks"
2. Add 🚧 emoji and today's date
3. Update "Last Updated" at top

**When completing a task:**
1. Move from "Active Tasks" to "Recently Completed"
2. Change 🚧 to ✅ and add completion time
3. Add entry to CHANGELOG.md with details
4. Update "Last Updated" at top

**When discovering a bug:**
1. Add to "Known Issues" section with 🐛 emoji
2. Include description and reproduction steps
3. Create GitHub issue if appropriate

**When planning ahead:**
1. Add to "Planned Features" with 📋 emoji
2. Assign priority level
3. Add any notes or requirements

**Weekly cleanup:**
1. Move old completed items (>7 days) to CHANGELOG.md
2. Re-prioritize planned features
3. Review future ideas for promotion to planned

---

## 🎯 Current Sprint Goals

**Sprint 1: Home Screen MVP (2025-11-13 to 2025-11-15)**

**Goal:** Build a working home screen that displays saved links from Supabase

**Deliverables:**
- ✅ Phase 1: Data models (Link, Tag) - COMPLETE
- 🚧 Phase 2: Services (LinkService) - IN PROGRESS
- 📋 Phase 3: State management (Providers)
- 📋 Phase 4: UI components (LinkCard, TagBadge, SearchBar)
- 📋 Phase 5: Home screen implementation
- 📋 Phase 6: Navigation & polish

**Success Criteria:**
- User can see list of saved links on home screen
- Links display with thumbnails, titles, notes, and tags
- Pull-to-refresh works
- Responsive on all device sizes
- All tests passing (target: 110+ tests)

**Estimated Completion:** 2025-11-15 (2 days remaining)

---

*This file is a living document - update it frequently as work progresses!*
