import 'package:app_links/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Deep Link Handler Service
///
/// Manually processes deep links for:
/// - Password recovery (from email reset links)
/// - OAuth callbacks (Google, Apple sign-in)
/// - Magic links (passwordless login)
///
/// **Why Manual Processing?**
///
/// Supabase's automatic deep link handling (`detectSessionInUri: true`)
/// causes a race condition where the router initializes BEFORE the auth
/// state change event is emitted. This results in:
/// - Router sees `isAuthenticated = false`
/// - Redirects to `/onboarding` instead of `/reset-password`
///
/// By manually processing deep links, we ensure the session is created
/// BEFORE the router reads auth state, so navigation works correctly.
///
/// **How It Works:**
///
/// 1. App launches from deep link (or receives one while running)
/// 2. This service catches the link BEFORE the app starts
/// 3. Extracts the recovery/OAuth token from the URI
/// 4. Calls `getSessionFromUrl()` to create authenticated session
/// 5. Waits for session to be stored locally
/// 6. Then allows router to initialize (which now sees authenticated user)
///
/// **Example Flow (Password Reset):**
/// ```
/// User clicks: io.supabase.flutterquickstart://reset-password/?token=abc123...
///      ↓
/// DeepLinkService catches link
///      ↓
/// Calls getSessionFromUrl(uri)
///      ↓
/// Supabase creates recovery session (user is now authenticated)
///      ↓
/// Router initializes
///      ↓
/// Router sees isAuthenticated = true, isRecovery = true
///      ↓
/// Navigates to /reset-password ✅
/// ```
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final SupabaseClient _supabase;

  DeepLinkService([SupabaseClient? client]) : _supabase = client ?? supabase;

  /// Initialize deep link handling
  ///
  /// This should be called once in main.dart BEFORE the app runs.
  /// It processes the initial deep link (if app was closed) and
  /// sets up a listener for future deep links (if app is running).
  ///
  /// **When to call:**
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await initializeSupabase();
  ///
  ///   // Process deep links BEFORE app runs
  ///   final deepLinkService = DeepLinkService();
  ///   await deepLinkService.initialize();
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initialize() async {
    print('🔗 [DEEP_LINK] Initializing deep link service');

    // Handle initial deep link (when app was closed and opened via link)
    // This is the most common scenario for password reset
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      print('🔗 [DEEP_LINK] Found initial deep link: $initialUri');
      await _handleDeepLink(initialUri);
    } else {
      print('🔗 [DEEP_LINK] No initial deep link found (normal app launch)');
    }

    // Listen for deep links while app is running
    // This handles the case where user gets the email while app is open
    _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('🔗 [DEEP_LINK] Received deep link while app running: $uri');
        _handleDeepLink(uri);
      },
      onError: (Object error) {
        print('🔗 [DEEP_LINK] ❌ Error receiving deep link: $error');
      },
    );

    print('🔗 [DEEP_LINK] Deep link service initialized ✅');
  }

  /// Process a deep link URI
  ///
  /// Extracts the recovery token or OAuth token from the URI
  /// and creates a Supabase session.
  ///
  /// **Security Note:**
  /// Only processes URIs with our app's custom scheme to prevent
  /// malicious links from being processed.
  ///
  /// **What this does:**
  /// 1. Validates the URI scheme
  /// 2. Calls `getSessionFromUrl()` which:
  ///    - Parses the recovery/OAuth token from URI
  ///    - Exchanges token for authenticated session
  ///    - Emits `AuthChangeEvent.passwordRecovery` event
  ///    - Stores session locally (persisted)
  /// 3. Logs the result
  ///
  /// **Supported URI formats:**
  /// - Password recovery: `io.supabase.flutterquickstart://reset-password/?token=...`
  /// - OAuth callback: `io.supabase.flutterquickstart://login-callback/?access_token=...`
  /// - Magic link: `io.supabase.flutterquickstart://login-callback/?token=...`
  Future<void> _handleDeepLink(Uri uri) async {
    print('🔗 [DEEP_LINK] Processing URI');
    print('  - Full URI: ${uri.toString()}');
    print('  - Scheme: ${uri.scheme}');
    print('  - Host: ${uri.host}');
    print('  - Path: ${uri.path}');
    print('  - Has token: ${uri.queryParameters.containsKey('token')}');
    print('  - Has access_token: ${uri.queryParameters.containsKey('access_token')}');

    // Only process URIs from our app scheme (security measure)
    if (uri.scheme != 'io.supabase.flutterquickstart') {
      print('🔗 [DEEP_LINK] ❌ Invalid scheme "${uri.scheme}", ignoring');
      print('  Expected: io.supabase.flutterquickstart');
      return;
    }

    try {
      print('🔗 [DEEP_LINK] Calling getSessionFromUrl()...');

      // Use Supabase's getSessionFromUrl to extract and create session
      // This method:
      // 1. Parses the recovery/OAuth token from the URI
      // 2. Exchanges it for an authenticated session with Supabase
      // 3. Emits AuthChangeEvent.passwordRecovery (or signedIn for OAuth)
      // 4. Stores the session locally for persistence
      final response = await _supabase.auth.getSessionFromUrl(uri);

      print('🔗 [DEEP_LINK] ✅ Session created from deep link');
      print('  - User email: ${response.session.user.email}');
      print('  - User ID: ${response.session.user.id}');
      print('  - Session expires: ${response.session.expiresAt}');

      // Small delay to ensure auth state propagates through streams
      // This gives the authStateProvider time to receive the event
      await Future.delayed(const Duration(milliseconds: 100));
      print('🔗 [DEEP_LINK] Auth state should now be available to router');

    } catch (e) {
      print('🔗 [DEEP_LINK] ❌ Error creating session from URL');
      print('  Error type: ${e.runtimeType}');
      print('  Error message: $e');

      // Don't rethrow - we don't want to crash the app if deep link is invalid
      // Common errors:
      // - Token expired
      // - Token already used
      // - Invalid token format
      // - Network error

      // User will see an error when they try to use the app
      // (e.g., "Session expired, please request a new reset link")
    }
  }
}
