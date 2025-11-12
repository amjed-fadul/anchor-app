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
import '../../features/home/screens/home_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'go_router_refresh_stream.dart';

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
    print('🔷 [ROUTER] getInitialLocation() called');

    // CRITICAL FIX: Use authService directly instead of providers
    // This gives us synchronous access to the current session without
    // waiting for streams to emit.
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;
    final session = authService.currentSession;

    print('  - user: ${user?.email ?? 'null'}');
    print('  - session exists: ${session != null}');

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
      print('  - authState.hasValue: ${authState.hasValue}');

      // Check both the stream (if it has emitted) and the session metadata
      final isRecoveryFromStream = authState.value?.event == AuthChangeEvent.passwordRecovery;
      print('  - isRecovery from stream: $isRecoveryFromStream');

      // Additional check: if we just processed a deep link, the session might have
      // special metadata. Supabase sets this during recovery flow.
      final hasRecoveryMetadata = user.recoverySentAt != null;
      print('  - hasRecoveryMetadata (recoverySentAt): $hasRecoveryMetadata');

      final isRecovery = isRecoveryFromStream || hasRecoveryMetadata;
      print('  - isRecovery (final): $isRecovery');

      if (isRecovery == true) {
        // Recovery session: take user to reset password screen
        print('  ✅ Returning /reset-password (recovery session)');
        return '/reset-password';
      }

      // Normal authenticated session: go to home
      print('  ✅ Returning /home (normal session)');
      return '/home';
    }

    // Not authenticated: start at splash
    print('  ✅ Returning / (splash - no user)');
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
      print('🔷 [ROUTER] redirect() called for path: $path');

      // Re-read auth state on each redirect (not watched, so no rebuild)
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      print('  - isAuthenticated: $isAuthenticated');

      // Allow reset-password for authenticated users
      // (they're authenticated via recovery session from email link)
      if (path == '/reset-password') {
        print('  ✅ Allowing /reset-password (no redirect)');
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

        print('  - Checking recovery session:');
        print('    - user exists: ${user != null}');
        print('    - session exists: ${session != null}');
        print('    - recoverySentAt: ${user?.recoverySentAt}');
        print('    - isRecovery: $isRecovery');

        if (isRecovery) {
          // Recovery session detected: redirect to reset password screen
          print('  🔀 Redirecting to /reset-password (recovery session on /login)');
          return '/reset-password';
        }

        // Normal case: allow login screen access
        print('  ✅ Allowing /login (no redirect)');
        return null;
      }

      // If user is authenticated and tries to access OTHER auth screens,
      // redirect to home
      if (isAuthenticated && _isAuthRoute(path)) {
        print('  🔀 Redirecting to /home (authenticated user on auth screen)');
        return '/home';
      }

      // If user is not authenticated and tries to access protected routes,
      // redirect to onboarding
      if (!isAuthenticated && _isProtectedRoute(path)) {
        print('  🔀 Redirecting to /onboarding (unauthenticated user on protected route)');
        return '/onboarding';
      }

      // No redirect needed
      print('  ✅ No redirect needed');
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
      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) => const MaterialPage(
          child: HomeScreen(),
        ),
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
  return path.startsWith('/home');
}
