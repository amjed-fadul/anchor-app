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
/// This creates the router with auth state integration.
/// The router automatically rebuilds when auth state changes.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to rebuild router when user logs in/out
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // Helpful for development

    // Redirect logic based on authentication
    redirect: (context, state) {
      final path = state.matchedLocation;

      // Allow reset-password for authenticated users
      // (they're authenticated via recovery session from email link)
      if (path == '/reset-password') {
        return null; // Don't redirect
      }

      // If user is authenticated and tries to access auth screens,
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
