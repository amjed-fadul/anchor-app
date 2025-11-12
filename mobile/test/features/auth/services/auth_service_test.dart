/// AuthService Unit Tests
///
/// These tests verify that our authentication service methods work correctly.
/// AuthService is more complex than validators because it:
/// - Talks to external services (Supabase)
/// - Performs async operations
/// - Can fail in various ways (network errors, auth errors, etc.)
///
/// 🎓 Learning: Testing with Mocks
///
/// Real-World Analogy:
/// Imagine testing a chef's recipe. You don't want to buy real expensive
/// ingredients every time you test! Instead, you use "mock ingredients"
/// (fake vegetables, etc.) to practice the cooking steps.
///
/// In our tests:
/// - Real Supabase = Expensive, slow, requires internet
/// - Mock Supabase = Free, instant, always available
///
/// We use "mocktail" to create fake Supabase objects that respond
/// exactly how we tell them to. This lets us test all scenarios:
/// success, failure, network errors, etc.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../helpers/mock_supabase_client.dart';

/// Main test suite
///
/// We use setUpAll to register fallback values for mocktail.
/// This is required when mocking methods that take custom objects as parameters.
void main() {
  /// 🎓 Learning: Test Setup
  ///
  /// setUpAll runs ONCE before all tests in this file.
  /// We use it to register "fallback values" - default values mocktail
  /// should use when it sees certain parameter types.
  ///
  /// Without this, mocktail gets confused when we use `any()` matcher
  /// for custom classes like UserAttributes.
  setUpAll(() {
    // Register a fallback UserAttributes object
    // This tells mocktail: "When you see UserAttributes in any(), use this"
    registerFallbackValue(
      UserAttributes(password: 'fallback-password'),
    );
  });

  /// ==========================================
  /// TEST GROUP: updatePassword() Method
  /// ==========================================
  ///
  /// This is the critical method we fixed in the password reset flow!
  /// It takes a new password and updates it in Supabase.
  ///
  /// What we're testing:
  /// ✅ Success case: Password updates without error
  /// ❌ Failure cases: Various errors that can occur
  group('updatePassword', () {
    /// Test Setup (runs before EACH test in this group)
    ///
    /// 🎓 Learning: setUp vs setUpAll
    /// - setUpAll: Runs ONCE before all tests (for global setup)
    /// - setUp: Runs BEFORE EACH test (for per-test setup)
    ///
    /// We use setUp because each test needs a fresh AuthService
    /// with a clean mock Supabase client.
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late AuthService authService;

    setUp(() {
      // Create fresh mock objects for each test
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();

      // Connect the mocks: mockSupabaseClient.auth returns mockAuth
      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

      // Create AuthService with our mock client
      authService = AuthService(mockSupabaseClient);
    });

    /// Test #1: Success - Password Updates Successfully
    ///
    /// 🎓 Learning: Testing Async Functions
    ///
    /// Notice the test function is marked `async` and we use `await`.
    /// This is because AuthService.updatePassword() is async (returns Future).
    ///
    /// Pattern for testing async:
    /// 1. Set up mocks to return specific values
    /// 2. Call the async method with await
    /// 3. Assert the result
    test('successfully updates password when auth succeeds', () async {
      // ARRANGE: Set up mock to return success
      //
      // 🎓 Learning: Stubbing with mocktail
      //
      // `when(() => mockAuth.updateUser(any()))` means:
      // "When someone calls mockAuth.updateUser with ANY parameter..."
      //
      // `.thenAnswer((_) async => ...)` means:
      // "...respond with this value"
      //
      // We use `thenAnswer` (not `thenReturn`) for async methods
      // because we need to return a Future.
      final mockUser = createMockUser(email: 'test@example.com');
      final mockResponse = createMockUserResponse(user: mockUser);

      when(() => mockAuth.updateUser(any()))
          .thenAnswer((_) async => mockResponse);

      // ACT: Call the method we're testing
      //
      // If this throws an exception, the test fails.
      // If it completes without error, the test continues.
      await authService.updatePassword(newPassword: 'newPassword123');

      // ASSERT: Verify the operation completed successfully
      //
      // 🎓 Learning: Verification with mocktail
      //
      // `verify(() => mockAuth.updateUser(...))` checks:
      // "Was mockAuth.updateUser actually called?"
      //
      // `.called(1)` means: "It should have been called exactly once"
      //
      // This ensures our AuthService actually tried to update the password!
      verify(
        () => mockAuth.updateUser(
          any(that: isA<UserAttributes>()),
        ),
      ).called(1);
    });

    /// Test #2: Failure - AuthException Thrown
    ///
    /// 🎓 Learning: Testing Error Cases
    ///
    /// It's CRITICAL to test what happens when things go wrong!
    /// In real apps, network fails, sessions expire, servers have issues.
    ///
    /// We want to ensure AuthService properly handles and re-throws errors
    /// so the UI can show appropriate messages to users.
    test('throws AuthException when Supabase returns auth error', () async {
      // ARRANGE: Set up mock to throw an error
      //
      // 🎓 Learning: Stubbing Errors
      //
      // `.thenThrow()` makes the mock throw an exception instead of
      // returning a value. This simulates Supabase rejecting the password.
      final authException = createMockAuthException(
        message: 'Invalid session',
        statusCode: '401',
      );

      when(() => mockAuth.updateUser(any())).thenThrow(authException);

      // ACT & ASSERT: Expect the method to throw
      //
      // 🎓 Learning: Testing Exceptions
      //
      // `expectLater()` is used for async operations.
      // `throwsA()` checks that an exception is thrown.
      // `isA<AuthException>()` checks it's specifically an AuthException.
      //
      // This verifies that:
      // 1. The method doesn't silently swallow the error
      // 2. The error type is preserved (AuthException, not generic Exception)
      await expectLater(
        () => authService.updatePassword(newPassword: 'newPassword123'),
        throwsA(isA<AuthException>()),
      );

      // Verify the method tried to call Supabase
      verify(() => mockAuth.updateUser(any())).called(1);
    });

    /// Test #3: Failure - Session Expired
    ///
    /// This simulates what happens when a user's password reset link expired.
    /// The recovery session is no longer valid, so Supabase rejects the request.
    test('throws AuthException when session is expired', () async {
      // ARRANGE: Simulate expired session error
      final expiredSessionException = createMockAuthException(
        message: 'Session expired',
        statusCode: '401',
      );

      when(() => mockAuth.updateUser(any())).thenThrow(expiredSessionException);

      // ACT & ASSERT
      await expectLater(
        () => authService.updatePassword(newPassword: 'newPassword123'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Test #4: Failure - Network Error
    ///
    /// 🎓 Learning: Testing Different Error Types
    ///
    /// Not all errors are AuthExceptions! Sometimes:
    /// - Network is down
    /// - Timeout occurs
    /// - Server is unavailable
    ///
    /// These throw generic Exceptions, not AuthExceptions.
    /// We need to test that our code handles ALL error types.
    test('throws Exception when network error occurs', () async {
      // ARRANGE: Simulate network failure
      //
      // Note: We throw a generic Exception, not AuthException
      when(() => mockAuth.updateUser(any()))
          .thenThrow(Exception('Network error'));

      // ACT & ASSERT: Should throw an Exception (not necessarily AuthException)
      await expectLater(
        () => authService.updatePassword(newPassword: 'newPassword123'),
        throwsException,
      );
    });

    /// Test #5: Edge Case - Empty Password
    ///
    /// 🎓 Learning: Testing Parameter Validation
    ///
    /// What happens if someone passes an empty password?
    /// This shouldn't happen (validators catch it), but we should test it anyway.
    ///
    /// Defensive programming: Validate inputs even if you think they're validated elsewhere!
    test('attempts to update even with empty password (validation should happen before this)',
        () async {
      // ARRANGE
      final mockUser = createMockUser();
      final mockResponse = createMockUserResponse(user: mockUser);

      when(() => mockAuth.updateUser(any()))
          .thenAnswer((_) async => mockResponse);

      // ACT: Try to update with empty password
      //
      // This won't throw an error at the service level (that's the validator's job).
      // But we verify the service at least tries to call Supabase.
      await authService.updatePassword(newPassword: '');

      // ASSERT: Verify the call was made (even though it probably shouldn't be!)
      verify(() => mockAuth.updateUser(any())).called(1);
    });
  });

  /// ==========================================
  /// TEST GROUP: resetPassword() Method
  /// ==========================================
  ///
  /// This method sends the password reset email.
  /// It's the FIRST step in the password reset flow!
  ///
  /// User clicks "Forgot Password" → enters email → this method is called
  /// → Supabase sends email with reset link
  group('resetPassword', () {
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late AuthService authService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      authService = AuthService(mockSupabaseClient);
    });

    /// Test #1: Success - Email Sent Successfully
    ///
    /// This is the happy path: user enters email, email gets sent.
    test('successfully sends password reset email', () async {
      // ARRANGE: Mock successful email send
      //
      // resetPasswordForEmail returns void (no return value),
      // so we just need to make sure it doesn't throw.
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      // ACT: Call the method
      await authService.resetPassword(email: 'test@example.com');

      // ASSERT: Verify Supabase was called with correct email
      //
      // 🎓 Learning: Argument Matching
      //
      // We can verify the EXACT arguments that were passed:
      verify(
        () => mockAuth.resetPasswordForEmail(
          'test@example.com',
          redirectTo: any(named: 'redirectTo'),
        ),
      ).called(1);
    });

    /// Test #2: Success - Redirect URL is Correct
    ///
    /// 🎓 Learning: Testing Important Details
    ///
    /// The redirect URL is CRITICAL! It tells Supabase where to send
    /// users after they click the reset link.
    ///
    /// If this is wrong, users click the link but end up on the wrong screen!
    test('includes correct redirect URL for deep linking', () async {
      // ARRANGE
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      // ACT
      await authService.resetPassword(email: 'test@example.com');

      // ASSERT: Check the redirect URL is our deep link
      //
      // 🎓 Learning: Captured Arguments
      //
      // We can capture arguments to inspect them in detail.
      // This is useful for checking complex parameters.
      verify(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: 'io.supabase.flutterquickstart://reset-password/',
        ),
      ).called(1);
    });

    /// Test #3: Failure - Invalid Email
    ///
    /// What happens if user enters an invalid email?
    /// Supabase should reject it.
    test('throws AuthException when email is invalid', () async {
      // ARRANGE: Simulate Supabase rejecting invalid email
      final authException = createMockAuthException(
        message: 'Invalid email',
        statusCode: '400',
      );

      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(authException);

      // ACT & ASSERT
      await expectLater(
        () => authService.resetPassword(email: 'not-an-email'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Test #4: Failure - Email Not Found
    ///
    /// 🎓 Learning: Security Consideration
    ///
    /// Interesting question: Should the app tell users "email not found"?
    ///
    /// Security best practice: NO!
    /// - If you say "email not found", attackers can discover which emails are registered
    /// - Better: Always say "if that email exists, we sent a reset link"
    ///
    /// However, Supabase might still throw an error. We test how we handle it.
    test('handles case when email does not exist in database', () async {
      // ARRANGE: Simulate email not found
      //
      // Note: Some systems throw errors, others silently succeed.
      // Check your Supabase settings!
      final notFoundException = createMockAuthException(
        message: 'User not found',
        statusCode: '404',
      );

      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(notFoundException);

      // ACT & ASSERT
      await expectLater(
        () => authService.resetPassword(email: 'nonexistent@example.com'),
        throwsA(isA<AuthException>()),
      );
    });

    /// Test #5: Failure - Network Error
    test('throws Exception when network fails during email send', () async {
      // ARRANGE: Simulate network failure
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenThrow(Exception('Network error'));

      // ACT & ASSERT
      await expectLater(
        () => authService.resetPassword(email: 'test@example.com'),
        throwsException,
      );
    });

    /// Test #6: Edge Case - Empty Email
    ///
    /// Like empty password, this should be caught by validators.
    /// But let's test the service handles it gracefully.
    test('attempts to send reset email even with empty email', () async {
      // ARRANGE: Mock might reject or accept (depends on Supabase)
      when(
        () => mockAuth.resetPasswordForEmail(
          any(),
          redirectTo: any(named: 'redirectTo'),
        ),
      ).thenAnswer((_) async {});

      // ACT: Try with empty email
      await authService.resetPassword(email: '');

      // ASSERT: Verify the attempt was made
      verify(
        () => mockAuth.resetPasswordForEmail(
          '',
          redirectTo: any(named: 'redirectTo'),
        ),
      ).called(1);
    });
  });
}

/// 🎓 Learning Summary: What We Learned From These Tests
///
/// **Mocking Concepts:**
/// - Creating mock objects with mocktail
/// - Stubbing methods with when().thenAnswer()
/// - Stubbing errors with when().thenThrow()
/// - Verifying calls with verify()
/// - Checking call counts with .called(n)
///
/// **Testing Async Code:**
/// - Marking tests as async
/// - Using await in tests
/// - Testing Future-returning functions
/// - Using expectLater for async assertions
///
/// **Error Handling:**
/// - Testing success cases
/// - Testing specific error types (AuthException)
/// - Testing generic errors (Exception)
/// - Testing edge cases (empty strings, network failures)
///
/// **Why These Tests Matter:**
/// - updatePassword is critical for password reset flow
/// - resetPassword is the entry point for forgot password
/// - These methods talk to external services (Supabase)
/// - Network can fail, sessions expire, users make mistakes
/// - Tests ensure we handle ALL these scenarios gracefully
///
/// **Running these tests:**
/// ```bash
/// # Run just these tests
/// flutter test test/features/auth/services/auth_service_test.dart
///
/// # Run with verbose output
/// flutter test test/features/auth/services/auth_service_test.dart --reporter expanded
///
/// # Run and watch for changes
/// flutter test test/features/auth/services/auth_service_test.dart --watch
/// ```
///
/// **Test Coverage:**
/// ✅ updatePassword: 5 test cases
/// ✅ resetPassword: 6 test cases
/// ✅ Total: 11 test cases
///
/// These 11 tests give us confidence that AuthService handles
/// the password reset flow correctly in ALL scenarios!
///
/// **Next:**
/// Run the tests and watch them pass! (Or fail, then fix them - TDD!)
