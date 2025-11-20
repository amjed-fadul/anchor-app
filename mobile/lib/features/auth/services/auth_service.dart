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
///
/// For testing, you can inject a mock SupabaseClient:
/// ```dart
/// final mockClient = MockSupabaseClient();
/// final authService = AuthService(mockClient);
/// ```
class AuthService {
  /// Get the Supabase client
  ///
  /// Accepts an optional client parameter for dependency injection (testing).
  /// If not provided, uses the global supabase singleton (production).
  final SupabaseClient _supabase;

  /// Create AuthService with optional Supabase client
  ///
  /// Parameters:
  /// - client: Optional SupabaseClient for testing. Uses global singleton if not provided.
  AuthService([SupabaseClient? client]) : _supabase = client ?? supabase;

  /// Sign up a new user with email, password, and display name
  ///
  /// Returns the authenticated user if successful.
  /// Throws an AuthException if signup fails.
  ///
  /// After successful signup:
  /// - User is automatically logged in
  /// - Display name is stored in user metadata
  /// - Default spaces are created via database trigger
  /// - Session is stored locally
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final user = await authService.signUp(
  ///     email: 'user@example.com',
  ///     password: 'password123',
  ///     displayName: 'John Doe',
  ///   );
  ///   print('Welcome ${user.email}!');
  /// } catch (e) {
  ///   print('Signup failed: $e');
  /// }
  /// ```
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName.trim(),
        },
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

  /// Update user password after reset
  ///
  /// This is called after the user clicks the reset link in their email
  /// and enters a new password in the app.
  ///
  /// Important: User must be authenticated (via deep link recovery session)
  /// before calling this method.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.updatePassword(newPassword: 'newpass123');
  ///   // Password updated successfully!
  /// } catch (e) {
  ///   print('Update failed: $e');
  /// }
  /// ```
  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to update password: $e');
    }
  }

  /// Delete the current user's account
  ///
  /// This permanently deletes the user account and all associated data.
  /// The deletion happens in two steps:
  /// 1. Call Edge Function to delete user from auth.users (using admin API)
  /// 2. Database CASCADE DELETE automatically removes all user data:
  ///    - All spaces
  ///    - All links
  ///    - All tags
  ///    - All link_tags relationships
  ///
  /// IMPORTANT: This action cannot be undone!
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await authService.deleteAccount();
  ///   // Account deleted! User is now logged out.
  /// } catch (e) {
  ///   print('Delete failed: $e');
  /// }
  /// ```
  Future<void> deleteAccount() async {
    try {
      // Get current user's JWT token for authentication
      final session = _supabase.auth.currentSession;
      if (session == null) {
        throw AuthException('No active session');
      }

      // Call Edge Function to delete user from auth.users
      // The Edge Function uses Supabase Admin API to delete the user
      // (Client SDK doesn't allow deleting your own account)
      final response = await _supabase.functions.invoke(
        'delete-account',
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      );

      // Check if deletion was successful
      if (response.status != 200) {
        throw AuthException(
          'Failed to delete account: ${response.data}',
        );
      }

      // Sign out locally (session is now invalid)
      await signOut();
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Unexpected error during account deletion: $e');
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
