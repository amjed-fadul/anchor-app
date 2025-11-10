# Anchor Mobile App

**Last Updated:** November 2025 | **Status:** Phase 0 - Foundation

---

## What is This?

This is the Flutter mobile application for **Anchor** - your visual bookmark manager. Anchor helps you save, organize, and rediscover web content through an intuitive mobile experience.

Built with Flutter for cross-platform support (iOS & Android), this app provides:
- Fast, native performance on mobile devices
- Beautiful, consistent UI following Material Design 3
- Seamless sync with Supabase backend
- Offline-first architecture with local caching

## Current Status

**Phase 0: Foundation** ✅ In Progress
- ✅ Project structure created
- ✅ Core dependencies added (Supabase, Riverpod, Go Router, Hive)
- ✅ Design system implemented (colors, typography, spacing, buttons)
- 🚧 Backend integration (next step)
- 🚧 Authentication flow (next step)
- 🚧 Link saving functionality (next step)

---

## Prerequisites

Before you start, make sure you have the following installed:

### Required

**1. Flutter SDK (3.35.7 or higher)**
- Installation: `brew install --cask flutter` (macOS)
- Or follow [official Flutter installation guide](https://docs.flutter.dev/get-started/install)
- Verify: `flutter --version`

**2. Android Studio**
- Download from [developer.android.com](https://developer.android.com/studio)
- Includes Android SDK and Android emulator
- Install Flutter plugin: **Preferences → Plugins → Search "Flutter"**

**3. Git**
- Should already be installed on macOS
- Verify: `git --version`

### Optional (for iOS development)

**4. Xcode (macOS only)**
- Download from Mac App Store (15GB+)
- Required for iOS development and testing
- Includes iOS Simulator
- Command Line Tools: `xcode-select --install`

### Verify Installation

Run Flutter doctor to check your setup:
```bash
flutter doctor
```

You should see checkmarks (✓) for:
- ✓ Flutter (Channel stable, 3.35.7)
- ✓ Android toolchain - develop for Android devices
- ✓ Android Studio (version 2024.x)

---
