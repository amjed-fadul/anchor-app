import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding Tracking Service
///
/// Manages whether the user has seen the onboarding screen.
/// Uses SharedPreferences to persist this data across app restarts.
///
/// **Why we need this:**
/// - Onboarding should only show ONCE (first time user opens app)
/// - After that, returning users should go straight to login
/// - This prevents showing onboarding to:
///   - Users who logged out
///   - Users resetting their password
///   - Users who reinstalled the app on same device
///
/// **How it works:**
/// Think of SharedPreferences like a notepad attached to your fridge:
/// - First time: Check notepad → nothing written → Show onboarding
/// - User completes onboarding: Write "SEEN" on notepad
/// - Next time: Check notepad → sees "SEEN" → Skip onboarding
/// - Even if app closes: Notepad stays on fridge → "SEEN" is still there
///
/// **Usage:**
/// ```dart
/// final service = OnboardingService();
///
/// // Check if user has seen onboarding
/// if (await service.hasSeenOnboarding()) {
///   // Go to login
/// } else {
///   // Show onboarding
/// }
///
/// // After user completes onboarding
/// await service.markOnboardingAsSeen();
/// ```
class OnboardingService {
  // The key used to store the flag in SharedPreferences
  // Like the label on the notepad: "Has Seen Onboarding"
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  /// Check if the user has seen the onboarding screen
  ///
  /// Returns:
  /// - `true` if user has seen onboarding before
  /// - `false` if this is their first time (or they cleared app data)
  ///
  /// **Technical details:**
  /// - Reads from SharedPreferences (persistent storage)
  /// - Returns false by default if key doesn't exist
  /// - Async because reading from storage takes time
  ///
  /// Example:
  /// ```dart
  /// final hasSeenIt = await service.hasSeenOnboarding();
  /// if (hasSeenIt) {
  ///   print('Returning user!');
  /// } else {
  ///   print('First-time user!');
  /// }
  /// ```
  Future<bool> hasSeenOnboarding() async {
    // Get SharedPreferences instance (the notepad)
    final prefs = await SharedPreferences.getInstance();

    // Read the value from the notepad
    // If nothing is written (null), default to false (haven't seen it)
    final hasSeen = prefs.getBool(_hasSeenOnboardingKey) ?? false;

    return hasSeen;
  }

  /// Mark the onboarding as seen
  ///
  /// Call this after the user completes onboarding
  /// (e.g., when they tap "Get Started" button)
  ///
  /// **What this does:**
  /// - Writes `true` to SharedPreferences under the key 'has_seen_onboarding'
  /// - Data persists even after app closes or device restarts
  /// - Only cleared if user deletes app data or uninstalls app
  ///
  /// Example:
  /// ```dart
  /// // In OnboardingScreen, when user taps "Get Started"
  /// await service.markOnboardingAsSeen();
  /// context.go('/signup');
  /// ```
  Future<void> markOnboardingAsSeen() async {
    // Get SharedPreferences instance (the notepad)
    final prefs = await SharedPreferences.getInstance();

    // Write "true" to the notepad under the key 'has_seen_onboarding'
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }
}
