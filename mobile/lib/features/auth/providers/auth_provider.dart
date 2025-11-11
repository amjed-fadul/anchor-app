import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

/// Provider for the AuthService instance
///
/// This creates a single instance of AuthService that's shared
/// across the entire app.
///
/// Usage:
/// ```dart
/// final authService = ref.read(authServiceProvider);
/// await authService.signIn(email: email, password: password);
/// ```
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider that listens to authentication state changes
///
/// This stream automatically emits events when:
/// - User logs in
/// - User logs out
/// - Session is refreshed
/// - Token expires
///
/// The UI will automatically rebuild when auth state changes.
///
/// Usage:
/// ```dart
/// final authState = ref.watch(authStateProvider);
/// authState.when(
///   data: (state) {
///     if (state.session != null) {
///       // User is logged in
///     } else {
///       // User is logged out
///     }
///   },
///   loading: () => CircularProgressIndicator(),
///   error: (err, stack) => Text('Error: $err'),
/// );
/// ```
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the current user
///
/// Returns the currently authenticated user, or null if not logged in.
/// Automatically updates when the user logs in or out.
///
/// Usage:
/// ```dart
/// final user = ref.watch(currentUserProvider);
/// if (user != null) {
///   Text('Welcome ${user.email}');
/// } else {
///   Text('Please log in');
/// }
/// ```
final currentUserProvider = Provider<User?>((ref) {
  // Watch the auth state
  final authState = ref.watch(authStateProvider);

  // Return the user from the auth state
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider that checks if a user is authenticated
///
/// Returns true if user is logged in, false otherwise.
/// Useful for route guards and conditional UI.
///
/// Usage:
/// ```dart
/// final isAuthenticated = ref.watch(isAuthenticatedProvider);
/// if (isAuthenticated) {
///   return HomeScreen();
/// } else {
///   return LoginScreen();
/// }
/// ```
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
