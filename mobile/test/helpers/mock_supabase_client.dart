library;

/// Mock Supabase Client for Testing
///
/// This file contains mock versions of Supabase classes that we use in tests.
/// Instead of hitting the real Supabase server (slow, requires internet,
/// costs money), we create "fake" versions that respond instantly and exactly
/// how we want them to for testing.
///
/// Think of it like a flight simulator for pilots - it acts like a real plane
/// but is much safer and cheaper to practice with!

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile/features/auth/services/auth_service.dart';

/// Mock SupabaseClient
///
/// This is the main Supabase client that all our services use.
/// By mocking it, we can control what it returns in our tests.
///
/// Example usage in tests:
/// ```dart
/// final mockClient = MockSupabaseClient();
/// final mockAuth = MockGoTrueClient();
/// when(() => mockClient.auth).thenReturn(mockAuth);
/// ```
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock GoTrueClient (Auth)
///
/// This handles all authentication operations in Supabase.
/// We mock it to simulate login, signup, password reset, etc.
///
/// Example usage:
/// ```dart
/// final mockAuth = MockGoTrueClient();
/// when(() => mockAuth.updateUser(any()))
///     .thenAnswer((_) async => UserResponse(user: mockUser));
/// ```
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Mock AuthResponse
///
/// This is what Supabase returns after successful auth operations.
/// We use it to simulate successful login/signup.
class MockAuthResponse extends Mock implements AuthResponse {}

/// Mock UserResponse
///
/// Returned after user updates (like password change).
class MockUserResponse extends Mock implements UserResponse {}

/// Mock User
///
/// Represents an authenticated user in Supabase.
/// We mock it to simulate a logged-in user.
class MockUser extends Mock implements User {}

/// Mock Session
///
/// Represents an active auth session.
/// Used to simulate logged-in state or recovery sessions.
class MockSession extends Mock implements Session {}

/// Mock AuthException
///
/// Supabase throws these when auth operations fail.
/// We mock them to test error handling.
class MockAuthException extends Mock implements AuthException {}

/// Mock AuthService
///
/// This mocks our AuthService class for testing providers and widgets.
/// Use this when you need to control what AuthService returns without
/// hitting the real Supabase backend.
///
/// Example usage:
/// ```dart
/// final mockAuthService = MockAuthService();
/// when(() => mockAuthService.authStateChanges)
///     .thenAnswer((_) => Stream.value(authState));
/// ```
class MockAuthService extends Mock implements AuthService {}

/// Helper Functions for Creating Common Test Data
///
/// These make it easier to create realistic test data without
/// repeating ourselves in every test file.

/// Fake User implementation for testing
///
/// Unlike MockUser which requires stubbing with when(), FakeUser
/// has real implementations that can be used directly.
/// This avoids "Cannot call when() within a stub response" errors.
class FakeUser extends Fake implements User {
  @override
  final String id;

  @override
  final String? email;

  @override
  final String createdAt;

  FakeUser({
    String? id,
    this.email,
  })  : id = id ?? 'test-user-id-123',
        createdAt = DateTime.now().toIso8601String();
}

/// Creates a fake user with typical properties
///
/// Use this in tests where you need a "logged in" user.
/// You can customize the email, id, etc.
///
/// Example:
/// ```dart
/// final testUser = createMockUser(email: 'test@example.com');
/// ```
User createMockUser({
  String? id,
  String? email,
}) {
  return FakeUser(id: id, email: email);
}

/// Fake Session implementation for testing
///
/// Unlike MockSession which requires stubbing, FakeSession has
/// real implementations that can be used directly.
class FakeSession extends Fake implements Session {
  @override
  final User user;

  @override
  final String accessToken;

  FakeSession({
    User? user,
    String? accessToken,
  })  : user = user ?? FakeUser(),
        accessToken = accessToken ?? 'mock-access-token-abc123';
}

/// Creates a fake session (logged-in state)
///
/// Use this when you need to simulate a user being logged in.
///
/// Example:
/// ```dart
/// final testSession = createMockSession();
/// when(() => mockAuth.currentSession).thenReturn(testSession);
/// ```
Session createMockSession({
  User? user,
  String? accessToken,
}) {
  return FakeSession(user: user, accessToken: accessToken);
}

/// Creates a mock recovery session (for password reset)
///
/// This simulates the special temporary session you get when
/// clicking a password reset link in your email.
///
/// Example:
/// ```dart
/// final recoverySession = createMockRecoverySession();
/// // Now test what happens during password reset
/// ```
Session createMockRecoverySession({User? user}) {
  // A recovery session is just a regular session, but the context
  // in which it's used (password recovery flow) is what makes it special
  return createMockSession(user: user);
}

/// Creates a mock successful UserResponse
///
/// This is what we get back when password update succeeds.
///
/// Example:
/// ```dart
/// when(() => mockAuth.updateUser(any())).thenAnswer(
///   (_) async => createMockUserResponse(user: testUser),
/// );
/// ```
UserResponse createMockUserResponse({User? user}) {
  final response = MockUserResponse();
  when(() => response.user).thenReturn(user ?? createMockUser());
  return response;
}

/// Creates a mock AuthException (for testing errors)
///
/// Use this to simulate what happens when Supabase operations fail.
///
/// Example:
/// ```dart
/// when(() => mockAuth.updateUser(any())).thenThrow(
///   createMockAuthException(message: 'Invalid session'),
/// );
/// ```
AuthException createMockAuthException({
  String message = 'Auth error',
  String statusCode = '400',
}) {
  return AuthException(message, statusCode: statusCode);
}
