import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/signup_email_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/spaces/screens/space_detail_screen.dart';
import '../../features/spaces/models/space_model.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'go_router_refresh_stream.dart';
import '../utils/app_logger.dart';

/// App routing configuration
///
/// Defines all app routes and handles navigation.
/// Uses GoRouter for declarative routing with auth guards.
///
/// Routes:
/// - / (splash) - Initial loading screen
/// - /onboarding - First-time user onboarding
/// - /login - Login screen
/// - /signup - Signup screen
/// - /forgot-password - Password reset screen
/// - /home - Main app screen (requires auth)

/// Provider for the GoRouter instance
///
/// This creates the router with auth state integration using refreshListenable.
/// The router LISTENS to auth changes WITHOUT rebuilding the entire instance.
///
/// **Critical Fix:**
/// Previously, we used `ref.watch(isAuthenticatedProvider)` which caused
/// the router provider to completely rebuild when auth state changed.
/// This caused navigation issues (e.g., redirecting to onboarding after
/// password reset).
///
/// **Solution:**
/// Use GoRouter's `refreshListenable` parameter to listen for auth changes
/// and re-run redirect logic WITHOUT rebuilding the router instance.
final routerProvider = Provider<GoRouter>((ref) {
  // CRITICAL FIX: Don't use ref.watch - it causes router to rebuild!
  // Instead, read the auth service and pass its continuous stream directly
  // to GoRouterRefreshStream. This allows redirect logic to refresh
  // WITHOUT rebuilding the entire router (which disposes widgets).
  final authService = ref.read(authServiceProvider);
  final refreshListenable = GoRouterRefreshStream(
    authService.authStateChanges,  // Real continuous stream from Supabase
  );

  /// Determine initial route based on current auth state
  ///
  /// Handles three scenarios:
  /// 1. Recovery session (from password reset email) → /reset-password
  /// 2. Normal authenticated session → /home
  /// 3. Not authenticated → / (splash)
  String getInitialLocation() {
    logger.d('🔷 [ROUTER] getInitialLocation() called');

    // CRITICAL FIX: Use authService directly instead of providers
    // This gives us synchronous access to the current session without
    // waiting for streams to emit.
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final session = authService.currentSession;

    logger.d('  - user: ${user?.email ?? 'null'}');
    logger.d('  - session exists: ${session != null}');

    // Check if user is authenticated
    if (user != null && session != null) {
      // Check if this is a password recovery session
      // (user clicked reset link in email)
      //
      // CRITICAL FIX: Check session metadata synchronously instead of
      // waiting for authStateProvider stream to emit. After the deep link
      // service processes the recovery token, the session will have the
      // user's app_metadata with recovery_sent_at field set.
      //
      // For Supabase recovery sessions:
      // - session.user.appMetadata contains 'provider' and other metadata
      // - We check if user has userMetadata['aud'] == 'authenticated' which
      //   indicates a valid session
      // - Recovery sessions are temporary, so we check the auth state value
      final authState = ref.read(authStateProvider);
      logger.d('  - authState.hasValue: ${authState.hasValue}');

      // Check both the stream (if it has emitted) and the session metadata
      final isRecoveryFromStream = authState.value?.event == AuthChangeEvent.passwordRecovery;
      logger.d('  - isRecovery from stream: $isRecoveryFromStream');

      // Additional check: if we just processed a deep link, the session might have
      // special metadata. Supabase sets this during recovery flow.
      final hasRecoveryMetadata = user.recoverySentAt != null;
      logger.d('  - hasRecoveryMetadata (recoverySentAt): $hasRecoveryMetadata');

      final isRecovery = isRecoveryFromStream || hasRecoveryMetadata;
      logger.d('  - isRecovery (final): $isRecovery');

      if (isRecovery == true) {
        // Recovery session: take user to reset password screen
        logger.d('  ✅ Returning /reset-password (recovery session)');
        return '/reset-password';
      }

      // Normal authenticated session: go to home
      logger.d('  ✅ Returning /home (normal session)');
      return '/home';
    }

    // Not authenticated: start at splash
    logger.d('  ✅ Returning / (splash - no user)');
    return '/';
  }

  return GoRouter(
    initialLocation: getInitialLocation(),
    debugLogDiagnostics: true,

    // CRITICAL: refreshListenable allows GoRouter to re-run redirect
    // when auth state changes WITHOUT rebuilding the router
    refreshListenable: refreshListenable,

    // Redirect logic based on authentication
    redirect: (context, state) {
      final path = state.matchedLocation;
      logger.d('🔷 [ROUTER] redirect() called for path: $path');

      // CRITICAL FIX: Read session directly (synchronous) instead of from provider (async stream)
      // This prevents race condition where signIn() completes but stream hasn't emitted yet
      final authService = ref.read(authServiceProvider);
      final isAuthenticated = authService.currentSession != null;
      logger.d('  - isAuthenticated: $isAuthenticated');

      // Allow reset-password for authenticated users
      // (they're authenticated via recovery session from email link)
      if (path == '/reset-password') {
        logger.d('  ✅ Allowing /reset-password (no redirect)');
        return null; // Don't redirect
      }

      // Handle /login screen access
      //
      // Allow /login for:
      // - Unauthenticated users (normal login flow)
      // - Authenticated users WITHOUT recovery session (after password reset completion)
      //
      // But REDIRECT recovery sessions to /reset-password:
      // - When user clicks password reset link, they get a recovery session
      // - They should be on /reset-password screen, not /login
      if (path == '/login') {
        // Check if user has a recovery session
        // CRITICAL: Check session DIRECTLY from auth service (synchronous)
        // NOT from provider (which depends on stream that may not have emitted yet)
        final authService = ref.read(authServiceProvider);
        final session = authService.currentSession;
        final user = authService.currentUser;

        // Recovery sessions have recoverySentAt metadata set by Supabase
        final isRecovery = user != null &&
                          session != null &&
                          user.recoverySentAt != null;

        logger.d('  - Checking recovery session:');
        logger.d('    - user exists: ${user != null}');
        logger.d('    - session exists: ${session != null}');
        logger.d('    - recoverySentAt: ${user?.recoverySentAt}');
        logger.d('    - isRecovery: $isRecovery');

        if (isRecovery) {
          // Recovery session detected: redirect to reset password screen
          logger.d('  🔀 Redirecting to /reset-password (recovery session on /login)');
          return '/reset-password';
        }

        // No recovery session: fall through to general auth redirect check below
        // This allows:
        // - Authenticated (normal) users: redirected to /home by general auth redirect
        // - Unauthenticated users: allowed to access /login
        logger.d('  ℹ️  No recovery session on /login, checking general auth redirect...');
      }

      // If user is authenticated and tries to access auth screens
      // (login, signup, forgot-password, onboarding), redirect to home
      // UNLESS they have a recovery session (handled above)
      if (isAuthenticated && _isAuthRoute(path)) {
        logger.d('  🔀 Redirecting to /home (authenticated user on auth screen)');
        return '/home';
      }

      // If user is not authenticated and tries to access protected routes,
      // redirect to onboarding
      if (!isAuthenticated && _isProtectedRoute(path)) {
        logger.d('  🔀 Redirecting to /onboarding (unauthenticated user on protected route)');
        return '/onboarding';
      }

      // No redirect needed
      logger.d('  ✅ No redirect needed');
      return null;
    },

    routes: [
      // Splash screen (initial route)
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) => const MaterialPage(
          child: SplashScreen(),
        ),
      ),

      // Onboarding screen
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => const MaterialPage(
          child: OnboardingScreen(),
        ),
      ),

      // Signup screen (landing page with options)
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => const MaterialPage(
          child: SignupScreen(),
        ),
      ),

      // Signup with email (form screen)
      GoRoute(
        path: '/signup/email',
        name: 'signup-email',
        pageBuilder: (context, state) => const MaterialPage(
          child: SignupEmailScreen(),
        ),
      ),

      // Login screen
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginScreen(),
        ),
      ),

      // Forgot password screen
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => const MaterialPage(
          child: ForgotPasswordScreen(),
        ),
      ),

      // Reset password screen (accessed via email link)
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        pageBuilder: (context, state) => const MaterialPage(
          child: ResetPasswordScreen(),
        ),
      ),

      // Home screen (requires authentication)
      // Now uses MainScaffold which provides bottom navigation with Home and Spaces tabs
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(
          child: MainScaffold(),
        ),
      ),

      // Settings screen (requires authentication)
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsScreen(),
        ),
      ),

      // Space Detail screen (requires authentication)
      // Shows all links in a specific space
      // The Space object is passed via state.extra
      GoRoute(
        path: '/spaces/:spaceId',
        name: 'space-detail',
        pageBuilder: (context, state) {
          final space = state.extra as Space;
          return MaterialPage(
            child: SpaceDetailScreen(space: space),
          );
        },
      ),
    ],
  );
});

/// Check if a route is an auth-related route
/// (routes that authenticated users shouldn't access)
bool _isAuthRoute(String path) {
  return path.startsWith('/onboarding') ||
      path.startsWith('/login') ||
      path.startsWith('/signup') ||
      path.startsWith('/forgot-password');
}

/// Check if a route requires authentication
bool _isProtectedRoute(String path) {
  return path.startsWith('/home') ||
      path.startsWith('/settings') ||
      path.startsWith('/spaces');
}
