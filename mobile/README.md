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

## Project Structure

```
mobile/
├── lib/                          # Application source code
│   ├── main.dart                 # App entry point
│   ├── design_system/            # Design system components
│   │   ├── colors/               # Brand colors and space colors
│   │   ├── typography/           # Text styles and font system
│   │   ├── spacing/              # 8px-based spacing system
│   │   └── widgets/              # Reusable UI components
│   ├── features/                 # Feature modules (coming soon)
│   │   ├── auth/                 # Authentication (login, signup)
│   │   ├── home/                 # Home screen and navigation
│   │   ├── links/                # Link management (save, view, edit)
│   │   ├── spaces/               # Space management
│   │   └── tags/                 # Tag management
│   ├── services/                 # Business logic and API calls
│   │   ├── supabase/             # Supabase client and auth
│   │   ├── storage/              # Local storage with Hive
│   │   └── api/                  # API service layer
│   └── utils/                    # Helper functions and constants
│
├── test/                         # Unit and widget tests
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── pubspec.yaml                  # Dependencies and assets
└── README.md                     # This file
```

### Key Directories

**`lib/design_system/`** - Complete design system implementation
- `colors.dart` - Anchor Teal, Anchor Slate, 14 space colors
- `typography.dart` - Geist font system with Material Design 3 text styles
- `spacing.dart` - 8px-based spacing with helpers (padding, margins, gaps)
- `widgets/` - AnchorButton, button styles, and more reusable components

**`lib/features/`** - Feature-based architecture (coming soon)
- Each feature is self-contained with its own screens, logic, and state
- Uses Riverpod for state management
- Uses Go Router for navigation

**`lib/services/`** - Service layer (coming soon)
- Supabase integration for backend
- Hive for offline-first local storage
- HTTP client for API calls

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/amjed-fadul/anchor-app.git
cd anchor-app/mobile
```

### 2. Install Dependencies

```bash
flutter pub get
```

This will install all packages defined in `pubspec.yaml` including:
- Supabase Flutter (backend)
- Riverpod (state management)
- Go Router (navigation)
- Hive (local storage)
- And more...

### 3. Run on Android Emulator

**Start the emulator:**
```bash
# List available emulators
flutter emulators

# Launch Pixel 6 Pro emulator
flutter emulators --launch Pixel_6_Pro
```

**Run the app:**
```bash
flutter run
```

The app will build and launch on the emulator. Hot reload is enabled - press `r` to reload, `R` to restart.

### 4. Run on Physical Android Device

1. Enable **Developer Options** on your Android device
2. Enable **USB Debugging**
3. Connect device via USB
4. Verify connection: `flutter devices`
5. Run: `flutter run`

### 5. Run on iOS Simulator (macOS only)

**Requires Xcode installed**

```bash
# List available simulators
xcrun simctl list devices available

# Or use Flutter command
flutter devices

# Run on iOS
flutter run -d ios
```

---

## Design System Usage

The Anchor design system is fully implemented and ready to use. Import it in your Flutter files:

```dart
import 'package:mobile/design_system/design_system.dart';
```

### Colors

```dart
// Brand colors
Container(color: AnchorColors.anchorTeal)
Container(color: AnchorColors.anchorSlate)

// Grayscale
Container(color: AnchorColors.gray100)
Container(color: AnchorColors.gray900)

// Space colors (14 colors for visual organization)
Container(color: AnchorColors.spacePurple)  // Default "Unread"
Container(color: AnchorColors.spaceRed)     // Default "Reference"

// Semantic colors
Container(color: AnchorColors.success)  // Green
Container(color: AnchorColors.error)    // Red
Container(color: AnchorColors.warning)  // Yellow
```

### Typography

```dart
// Display styles (large headings)
Text('Welcome', style: AnchorTypography.displayLarge)

// Headlines (page titles)
Text('My Links', style: AnchorTypography.headlineMedium)

// Body text (most common)
Text('Description...', style: AnchorTypography.bodyMedium)

// Labels (buttons, tabs)
Text('Save', style: AnchorTypography.labelLarge)

// Custom Anchor styles
Text('example.com', style: AnchorTypography.linkDomain)
Text('My note here', style: AnchorTypography.note)
```

### Spacing

```dart
// Padding
Padding(
  padding: AnchorSpacing.allMD,  // 16px all sides
  child: Text('Content'),
)

// Vertical gaps
Column(
  children: [
    Text('Title'),
    AnchorSpacing.verticalSpaceMD,  // 16px gap
    Text('Body'),
  ],
)

// Horizontal gaps
Row(
  children: [
    Icon(Icons.star),
    AnchorSpacing.horizontalSpaceSM,  // 12px gap
    Text('Favorite'),
  ],
)

// Border radius
Container(
  decoration: BoxDecoration(
    borderRadius: AnchorSpacing.radiusSM,  // 8px
  ),
)
```

### Buttons

```dart
// Primary button
AnchorButton(
  label: 'Save Link',
  onPressed: () => print('Saved'),
  type: AnchorButtonType.primary,
)

// Secondary button
AnchorButton(
  label: 'Cancel',
  onPressed: () => Navigator.pop(context),
  type: AnchorButtonType.secondary,
)

// With icon
AnchorButton(
  label: 'Share',
  icon: Icons.share,
  onPressed: () => print('Share'),
)

// Loading state
AnchorButton(
  label: 'Saving...',
  onPressed: () {},
  isLoading: true,
)

// Icon button
AnchorIconButton(
  icon: Icons.favorite_border,
  onPressed: () => print('Liked'),
  tooltip: 'Like',
)
```

---
