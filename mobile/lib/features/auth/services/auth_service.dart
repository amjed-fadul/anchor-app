import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';

/// Authentication service
///
/// Handles all authentication operations with Supabase:
/// - Sign up with email/password
/// - Sign in with email/password
/// - Sign out
/// - Password reset
/// - Auth state changes
/// - Google Sign-In (OAuth)
///
/// This is the single source of truth for all auth operations.
class AuthService {
  /// Get the Supabase client
  final SupabaseClient _supabase = supabase;

  /// Sign up a new user with email and password
  ///
  /// Returns the authenticated user if successful.
  /// Throws an AuthException if signup fails.
  ///
  /// After successful signup:
  /// - User is automatically logged in
  /// - Default spaces are created via database trigger
  /// - Session is stored locally
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authService.signUp(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('Welcome ${user.email}!');
  /// } catch (e) {
  ///   print('Signup failed: $e');
  /// }
  /// ```
  Future<User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      // Check if user was created
      if (response.user == null) {
        throw AuthException('Failed to create account');
      }

      return response.user!;
    } on AuthException {
      // Re-throw auth exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap other exceptions
      throw AuthException('Unexpected error during signup: $e');
    }
  }

  /// Sign in an existing user with email and password
  ///
  /// Returns the authenticated user if successful.
  /// Throws an AuthException if login fails.
  ///
  /// Common errors:
  /// - Invalid credentials (wrong email/password)
  /// - Email not verified (if verification required)
  /// - Network error
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authService.signIn(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///   );
  ///   print('Welcome back ${user.email}!');
  /// } catch (e) {
  ///   print('Login failed: $e');
  /// }
  /// ```
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Check if login was successful
      if (response.user == null) {
        throw AuthException('Invalid credentials');
      }

      return response.user!;
    } on AuthException {
      // Re-throw auth exceptions as-is
      rethrow;
    } catch (e) {
      // Wrap other exceptions
      throw AuthException('Unexpected error during sign in: $e');
    }
  }

  /// Sign in with Google OAuth
  ///
  /// Opens a browser/webview for Google sign-in.
  /// Returns true if successful, false otherwise.
  ///
  /// Note: Requires Google OAuth configuration in Supabase dashboard.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final success = await authService.signInWithGoogle();
  ///   if (success) {
  ///     print('Google sign-in successful!');
  ///   }
  /// } catch (e) {
  ///   print('Google sign-in failed: $e');
  /// }
  /// ```
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error during Google sign-in: $e');
    }
  }

  /// Sign out the current user
  ///
  /// Clears the local session and logs the user out.
  ///
  /// Example:
  /// ```dart
  /// await authService.signOut();
  /// // User is now logged out
  /// ```
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error during sign out: $e');
    }
  }

  /// Send a password reset email
  ///
  /// Sends an email to the user with a link to reset their password.
  /// The user will click the link and be redirected to set a new password.
  ///
  /// Example:
  /// ```dart
  /// await authService.resetPassword(email: 'user@example.com');
  /// // Email sent! User should check their inbox.
  /// ```
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutterquickstart://reset-password/',
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error during password reset: $e');
    }
  }

  /// Get the currently logged in user
  ///
  /// Returns the User object if logged in, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final user = authService.currentUser;
  /// if (user != null) {
  ///   print('Logged in as ${user.email}');
  /// } else {
  ///   print('Not logged in');
  /// }
  /// ```
  User? get currentUser => _supabase.auth.currentUser;

  /// Get the current session
  ///
  /// Returns the Session object if logged in, null otherwise.
  /// The session contains the JWT token and other auth info.
  ///
  /// Example:
  /// ```dart
  /// final session = authService.currentSession;
  /// if (session != null) {
  ///   print('Session expires at ${session.expiresAt}');
  /// }
  /// ```
  Session? get currentSession => _supabase.auth.currentSession;

  /// Listen to authentication state changes
  ///
  /// This stream emits events whenever the user logs in or out.
  /// Use this to react to auth changes in your app.
  ///
  /// Example:
  /// ```dart
  /// authService.authStateChanges.listen((event) {
  ///   if (event.session != null) {
  ///     print('User logged in: ${event.session!.user.email}');
  ///   } else {
  ///     print('User logged out');
  ///   }
  /// });
  /// ```
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
