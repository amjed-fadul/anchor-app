import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  // Convert auth state stream to a listenable that GoRouter can monitor
  // This allows GoRouter to refresh redirect logic without rebuilding
  final authState = ref.watch(authStateProvider);
  final refreshListenable = GoRouterRefreshStream(
    authState.when(
      data: (state) => Stream.value(state),
      loading: () => Stream.value(null),
      error: (_, __) => Stream.value(null),
    ),
  );

  /// Determine initial route based on current auth state
  ///
  /// Handles three scenarios:
  /// 1. Recovery session (from password reset email) → /reset-password
  /// 2. Normal authenticated session → /home
  /// 3. Not authenticated → / (splash)
  String getInitialLocation() {
    final user = ref.read(currentUserProvider);

    // Check if user is authenticated
    if (user != null) {
      // Check if this is a password recovery session
      // (user clicked reset link in email)
      final isRecovery = ref.read(isRecoverySessionProvider);

      if (isRecovery) {
        // Recovery session: take user to reset password screen
        return '/reset-password';
      }

      // Normal authenticated session: go to home
      return '/home';
    }

    // Not authenticated: start at splash
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

      // Re-read auth state on each redirect (not watched, so no rebuild)
      final isAuthenticated = ref.read(isAuthenticatedProvider);

      // Allow reset-password for authenticated users
      // (they're authenticated via recovery session from email link)
      if (path == '/reset-password') {
        return null; // Don't redirect
      }

      // ALSO allow /login for authenticated users after password reset
      // This enables users with recovery sessions to explicitly log in
      // with their NEW password, providing better UX and confirmation
      // that the password change worked
      if (path == '/login') {
        return null; // Don't redirect - allow access to login screen
      }

      // If user is authenticated and tries to access OTHER auth screens,
      // redirect to home
      if (isAuthenticated && _isAuthRoute(path)) {
        return '/home';
      }

      // If user is not authenticated and tries to access protected routes,
      // redirect to onboarding
      if (!isAuthenticated && _isProtectedRoute(path)) {
        return '/onboarding';
      }

      // No redirect needed
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
