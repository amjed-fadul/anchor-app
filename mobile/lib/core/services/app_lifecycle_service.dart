library;

/// AppLifecycleService
///
/// Service for listening to app lifecycle events and triggering background tasks.
///
/// Why App Lifecycle Matters?
/// Apps have different states (foreground, background, paused, etc.).
/// We can trigger useful background tasks when the app state changes.
///
/// Real-World Analogy:
/// Think of this like automatic actions on your phone:
/// - When you unlock your phone → Check for new notifications
/// - When you open your email app → Sync new emails
/// - When Anchor app comes to foreground → Retry failed metadata fetches
///
/// How It Works:
/// 1. Listens to AppLifecycleState changes using WidgetsBindingObserver
/// 2. When app goes from background → foreground (resumed state)
/// 3. Triggers MetadataRetryService to retry incomplete metadata fetches
/// 4. Only retries if user is logged in

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/services/metadata_retry_service.dart';

/// AppLifecycleService - Manages app lifecycle events and triggers background tasks
class AppLifecycleService with WidgetsBindingObserver {
  final Ref _ref;
  bool _isInitialized = false;

  AppLifecycleService(this._ref);

  /// initialize - Start listening to lifecycle events
  ///
  /// Call this once in main.dart after app starts.
  /// Registers this service as a lifecycle observer.
  void initialize() {
    if (_isInitialized) return;

    debugPrint('🔵 [AppLifecycle] Initializing app lifecycle service');
    WidgetsBinding.instance.addObserver(this);
    _isInitialized = true;
  }

  /// dispose - Stop listening to lifecycle events
  ///
  /// Call this when app is shutting down (rare in Flutter apps).
  void dispose() {
    if (!_isInitialized) return;

    debugPrint('🔵 [AppLifecycle] Disposing app lifecycle service');
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  /// didChangeAppLifecycleState - Called by Flutter when app state changes
  ///
  /// This is an override from WidgetsBindingObserver.
  /// Flutter calls this automatically when app goes to background, foreground, etc.
  ///
  /// Lifecycle States:
  /// - resumed: App is visible and responding to user input (foreground)
  /// - inactive: App is in transition (e.g., phone call overlay)
  /// - paused: App is not visible (background)
  /// - detached: App is about to close
  ///
  /// We care about: paused → resumed (background → foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('🔵 [AppLifecycle] App state changed to: $state');

    // Trigger background retry when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// _onAppResumed - Called when app comes to foreground (private method)
  ///
  /// This method:
  /// 1. Checks if user is logged in
  /// 2. If logged in, triggers metadata retry for incomplete links
  /// 3. Runs in background (doesn't block UI)
  void _onAppResumed() {
    debugPrint('🟢 [AppLifecycle] App resumed - checking for metadata retries');

    // Get current user from auth provider
    final user = _ref.read(currentUserProvider);

    if (user == null) {
      debugPrint('⏭️ [AppLifecycle] No user logged in, skipping metadata retry');
      return;
    }

    debugPrint('🔵 [AppLifecycle] User logged in, triggering metadata retry for user ${user.id}');

    // Trigger metadata retry in background (don't await - fire and forget)
    // This runs asynchronously without blocking the UI
    _triggerMetadataRetry(user.id);
  }

  /// _triggerMetadataRetry - Trigger metadata retry in background (private method)
  ///
  /// This method runs asynchronously and doesn't block the UI.
  /// If retry fails, it's logged but doesn't crash the app.
  Future<void> _triggerMetadataRetry(String userId) async {
    try {
      final metadataRetryService = _ref.read(metadataRetryServiceProvider);
      final updatedCount = await metadataRetryService.retryIncompleteLinks(userId);

      if (updatedCount > 0) {
        debugPrint('🟢 [AppLifecycle] Metadata retry completed: $updatedCount links updated');
      }
    } catch (e) {
      // Don't crash app if retry fails - just log it
      debugPrint('🔴 [AppLifecycle] Metadata retry failed: $e');
    }
  }
}

/// Provider for AppLifecycleService instance
///
/// This is a singleton - only one AppLifecycleService exists for the whole app.
/// Must be initialized once in main.dart after app starts.
final appLifecycleServiceProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(ref);
});

/// 🎓 Learning Summary: App Lifecycle Management
///
/// **What is App Lifecycle?**
/// The different states an app goes through from launch to close.
/// Flutter provides hooks to run code when these states change.
///
/// **Real-World Analogy:**
/// Think of this like automatic actions in your daily routine:
/// - You arrive home → Lights turn on automatically (motion sensor)
/// - You leave home → Thermostat adjusts (saves energy)
/// - You open fridge → Light turns on (door sensor)
/// - Anchor app comes to foreground → Retry failed metadata (better UX)
///
/// **Why Lifecycle Management?**
/// 1. **Better UX**: Fix problems automatically when user returns
/// 2. **Resource Efficiency**: Run tasks at optimal times
/// 3. **Battery Saving**: Don't run tasks when app is in background
/// 4. **Network Efficiency**: Retry when network is likely available
///
/// **Common Lifecycle Patterns:**
/// - **resumed → paused**: User puts app in background
///   - Save state, pause animations, stop timers
/// - **paused → resumed**: User brings app to foreground
///   - Refresh data, resume animations, retry failed operations
/// - **detached**: App is closing
///   - Cleanup resources, save critical data
///
/// **Flutter Lifecycle States:**
/// ```
/// ┌─────────────────────────────────────────────┐
/// │  App Lifecycle States                       │
/// ├─────────────────────────────────────────────┤
/// │                                             │
/// │  inactive ←→ resumed ←→ paused ←→ detached │
/// │     ↑          ↑         ↑         ↑       │
/// │     │          │         │         │       │
/// │  Phone call  Foreground Background Closing │
/// │   overlay    (active)   (hidden)           │
/// │                                             │
/// └─────────────────────────────────────────────┘
/// ```
///
/// **Our Implementation:**
/// We use WidgetsBindingObserver to listen to lifecycle changes.
/// When app resumes (paused → resumed), we trigger metadata retry.
/// This happens automatically without user action - better UX!
///
/// **Integration:**
/// In main.dart:
/// ```dart
/// void main() {
///   runApp(
///     ProviderScope(
///       child: MyApp(),
///     ),
///   );
/// }
///
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Initialize lifecycle service once
///     ref.read(appLifecycleServiceProvider).initialize();
///
///     return MaterialApp(...);
///   }
/// }
/// ```
