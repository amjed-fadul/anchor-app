# TODO & Project Roadmap

**Last Updated:** 2025-11-13

This file tracks active tasks, planned features, known issues, and future ideas for the Anchor App.

**Format:**
- ✅ Completed
- 🚧 In Progress
- 📋 Planned (not started)
- 🐛 Known Issue
- 💡 Future Idea

---

## 🚧 Active Tasks

*Currently working on:*

None - All recent tasks completed as of 2025-11-13 14:45

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
- Current test count: 75+ tests

### Code Quality
- Maintain 0 analyzer warnings
- Use proper logging (no print statements)
- Follow Flutter/Dart style guide
- Document all public APIs

### Authentication Status
- ✅ Email/password signup working
- ✅ Email confirmation flow working
- ✅ Password reset working
- ✅ Deep linking configured
- ✅ Session management working
- 📋 OAuth (Google) - needs testing

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

*No active sprint defined yet*

When ready to start building features, we'll define sprint goals here (1-2 week cycles).

---

*This file is a living document - update it frequently as work progresses!*
