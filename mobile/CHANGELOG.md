# Changelog

All notable changes, bug fixes, and improvements to the Anchor App mobile application.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Fixed

#### Signup Flow - Success Message Instead of Navigation (2025-11-13)
- **Problem**: After successful signup, user was redirected to `/onboarding` instead of seeing confirmation instructions
- **Root Cause**: Code tried to navigate to `/home` but user wasn't authenticated yet (email confirmation required)
- **Solution**:
  - Show "Check your email!" success message with clear instructions
  - User stays on signup screen (no navigation)
  - "Go to Sign In" button for manual navigation to login
  - "Try again" button to reset form
- **Files Changed**:
  - `lib/features/auth/screens/signup_email_screen.dart`
  - `lib/features/auth/screens/login_screen.dart`
- **Result**: ✅ No unwanted redirect to onboarding, clear UX for email confirmation

#### Email Confirmation Deep Link (2025-11-13)
- **Problem**: Signup confirmation emails contained `localhost:3000` link that opened in browser
- **Root Cause**: Supabase Site URL was set to localhost (development default)
- **Solution**:
  - Verified deep link configured in Supabase: `io.supabase.flutterquickstart://login-callback/`
  - Deep link opens mobile app (not browser)
  - User automatically authenticated when clicking link
- **Configuration**: Supabase Dashboard → Authentication → URL Configuration
- **Result**: ✅ Email link opens app and auto-logs in user

#### Critical Auth Race Conditions (2025-11-13 - Earlier)
- **Problem**: Multiple race conditions in authentication flows
- **Solutions**:
  1. **Password Reset Flow**: Fixed redirect timing in splash screen
  2. **Signup/Login Timing**: Added event-driven navigation (later removed for success message approach)
  3. **BuildContext Async Gap**: Fixed async navigation in onboarding screen
- **Files Changed**:
  - `lib/features/auth/screens/reset_password_screen.dart`
  - `lib/features/auth/screens/onboarding_screen.dart`
- **Result**: ✅ Proper auth state management, no premature redirects

### Added

#### Comprehensive Test Coverage (2025-11-13)
- **DeepLinkService Tests**: 10 tests (9 passing, 1 skipped for native platform)
  - Password reset link processing
  - OAuth callbacks
  - URI scheme validation
  - Error handling
  - Security (replay attacks, malformed URIs)
- **SplashScreen Tests**: 12 tests (8 passing, 4 with known mocktail limitation)
  - Branding rendering
  - Navigation for all auth states
  - Timer behavior
  - Recovery session detection
- **Files Added**:
  - `test/core/services/deep_link_service_test.dart`
  - `test/features/auth/screens/splash_screen_test.dart`
- **Result**: ✅ 22 new tests for critical authentication components

#### Centralized Logging Framework (2025-11-13)
- **Replaced**: 70 `print()` statements with proper logger
- **Added**: `lib/core/utils/app_logger.dart`
  - Configured log levels (trace, debug, info, warning, error)
  - Development vs production logging
  - Emoji indicators for easy scanning
- **Files Updated**:
  - `lib/core/router/app_router.dart` (23 replacements)
  - `lib/core/services/deep_link_service.dart` (23 replacements)
  - `lib/features/auth/screens/splash_screen.dart` (24 replacements)
- **Result**: ✅ Better debugging, structured logs, production-ready logging

### Changed

#### Login Screen Navigation (2025-11-13)
- **Before**: Manually navigated to `/home` after login
- **After**: Let router's `refreshListenable` handle navigation automatically
- **Benefit**: Cleaner code, consistent with auth state management
- **File**: `lib/features/auth/screens/login_screen.dart`

### Improved

#### Code Quality Metrics (2025-11-13)
- **Before**: 79 analyzer warnings
- **After**: 0 analyzer warnings ✅
- **Fixes Applied**:
  - Added `library;` directive to 9 test files (fixed dangling doc comments)
  - Removed unused imports across multiple files
  - Fixed sealed class violations
  - Removed unused variables
- **Result**: ✅ Clean codebase, production-ready code quality

---

## Previous Work (Before Changelog)

### Authentication System
- Email/password signup and login
- Password reset with email confirmation
- OAuth integration (Google)
- Session management with Supabase
- Deep linking for auth flows

### Core Features
- Onboarding screens (shown once, never again)
- Splash screen with branding
- Router with auth-based redirects
- Design system with reusable components

### Testing Infrastructure
- Test helpers and mocks (`test/helpers/`)
- Validator tests (20 tests)
- AuthService tests (11 tests)
- Router redirect tests (12 tests)
- **Total: 75+ tests**

---

## How to Use This Changelog

**When fixing a bug:**
1. Add entry under `### Fixed` with date
2. Include: Problem, Root Cause, Solution, Files Changed, Result

**When adding a feature:**
1. Add entry under `### Added` with date
2. Include: What it does, Why it's needed, Files Added/Changed

**When refactoring:**
1. Add entry under `### Changed` with date
2. Include: Before, After, Benefit

**Before releasing:**
1. Move entries from `[Unreleased]` to new version section
2. Add version number and release date
3. Create new `[Unreleased]` section

---

## Notes

- All dates in YYYY-MM-DD format
- All changes documented with context for future reference
- Links to relevant commits in git history for detailed changes
- Focus on **why** changes were made, not just **what** changed
