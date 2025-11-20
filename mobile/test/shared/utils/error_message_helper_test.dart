library;

/// Error Message Helper Unit Tests
///
/// These tests verify that technical Supabase exceptions are correctly
/// converted into user-friendly error messages.
///
/// Why This Matters:
/// - Users see errors like "AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)"
/// - We need to convert these to "Invalid email or password. Please try again."
/// - The ErrorMessageHelper does this sanitization
///
/// Test Coverage:
/// ✅ AuthException objects (real Supabase errors)
/// ✅ AuthException strings (when exception was toString'd)
/// ✅ Network errors (timeouts, connection failures)
/// ✅ Generic exceptions
/// ✅ Edge cases (null, empty, already user-friendly)

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/error_message_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  /// ==========================================
  /// TEST GROUP: AuthException Objects
  /// ==========================================
  ///
  /// Test handling of actual AuthException objects that Supabase throws.
  /// These are the most common errors users encounter.
  group('AuthException objects', () {
    test('converts invalid credentials error to user-friendly message', () {
      // ARRANGE: Create AuthException like Supabase would throw
      final error = AuthException('Invalid login credentials');

      // ACT: Convert to user-friendly message
      final result = ErrorMessageHelper.getReadableMessage(error);

      // ASSERT: Should be user-friendly
      expect(result, 'Invalid email or password. Please try again.');
    });

    test('converts email already exists error', () {
      final error = AuthException('User already registered');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'This email is already registered. Try logging in instead.');
    });

    test('converts weak password error', () {
      final error = AuthException('Password is too weak');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Password must be at least 6 characters long.');
    });

    test('converts user not found error', () {
      final error = AuthException('User not found');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'No account found with this email address.');
    });

    test('converts expired session error', () {
      final error = AuthException('Session expired');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'This link has expired. Please request a new one.');
    });

    test('converts rate limit error', () {
      final error = AuthException('Rate limit exceeded');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Too many attempts. Please wait a moment and try again.');
    });

    test('converts email not confirmed error', () {
      final error = AuthException('Email not confirmed');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Please verify your email address before signing in.');
    });
  });

  /// ==========================================
  /// TEST GROUP: AuthException Strings
  /// ==========================================
  ///
  /// Test handling of AuthException strings (when the exception was converted to string).
  /// This happens when catch blocks call e.toString() before passing to our helper.
  group('AuthException strings (toString)', () {
    test('parses AuthApiException string with invalid_credentials code', () {
      // ARRANGE: This is what AuthApiException.toString() looks like
      const error =
          'AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)';

      // ACT
      final result = ErrorMessageHelper.getReadableMessage(error);

      // ASSERT
      expect(result, 'Invalid email or password. Please try again.');
    });

    test('parses AuthApiException string with email_exists code', () {
      const error =
          'AuthApiException(message: User already registered, statusCode: 400, code: email_exists)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'This email is already registered. Try logging in instead.');
    });

    test('parses AuthApiException string with weak_password code', () {
      const error =
          'AuthApiException(message: Weak password, statusCode: 400, code: weak_password)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Password must be at least 6 characters long.');
    });

    test('parses AuthApiException string with user_not_found code', () {
      const error =
          'AuthApiException(message: User not found, statusCode: 404, code: user_not_found)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'No account found with this email address.');
    });

    test('parses AuthApiException string with session_expired code', () {
      const error =
          'AuthApiException(message: Session expired, statusCode: 401, code: session_expired)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'This link has expired. Please request a new one.');
    });

    test('parses AuthApiException string with rate_limit_exceeded code', () {
      const error =
          'AuthApiException(message: Too many requests, statusCode: 429, code: rate_limit_exceeded)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Too many attempts. Please wait a moment and try again.');
    });

    test('extracts user-friendly message from AuthException string', () {
      // Even if we don't recognize the code, we should extract the message
      const error =
          'AuthException(message: Invalid request format, statusCode: 400)';

      final result = ErrorMessageHelper.getReadableMessage(error);

      // Should use the message from the exception or a generic error
      expect(result.isNotEmpty, true);
      expect(result.contains('AuthException'), false); // Should NOT contain "AuthException"
    });
  });

  /// ==========================================
  /// TEST GROUP: Network Errors
  /// ==========================================
  ///
  /// Test handling of network and connection errors.
  /// These are common when users have poor internet or the server is down.
  group('Network errors', () {
    test('converts network error to user-friendly message', () {
      const error = 'NetworkException: Failed to connect';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Connection error. Please check your internet and try again.');
    });

    test('converts connection error', () {
      const error = 'Connection failed: unable to reach server';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Connection error. Please check your internet and try again.');
    });

    test('converts timeout error', () {
      const error = 'Request timeout after 10 seconds';

      final result = ErrorMessageHelper.getReadableMessage(error);

      // Could be either timeout message or connection error
      expect(
        result,
        anyOf(
          'Request timed out. Please try again.',
          'Connection error. Please check your internet and try again.',
        ),
      );
    });

    test('converts failed host lookup error', () {
      const error = 'SocketException: Failed host lookup: api.supabase.co';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Connection error. Please check your internet and try again.');
    });
  });

  /// ==========================================
  /// TEST GROUP: Generic Exceptions
  /// ==========================================
  ///
  /// Test handling of generic exceptions and edge cases.
  group('Generic exceptions', () {
    test('converts generic Exception to fallback message', () {
      final error = Exception('Something unexpected happened');

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Something went wrong. Please try again.');
    });

    test('handles null error', () {
      const error = null;

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Something went wrong. Please try again.');
    });

    test('handles empty string error', () {
      const error = '';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Something went wrong. Please try again.');
    });

    test('preserves user-friendly error messages', () {
      // If the error message is already user-friendly (short, no technical details),
      // we should preserve it
      const error = 'Invalid email format';

      final result = ErrorMessageHelper.getReadableMessage(error);

      // Should preserve the original message since it's already user-friendly
      expect(result, 'Invalid email format');
    });

    test('converts technical error strings to generic message', () {
      // Long technical error messages should be replaced with generic message
      const error =
          'Exception: Unexpected error occurred in _authenticateUser at line 42: NullPointerException...';

      final result = ErrorMessageHelper.getReadableMessage(error);

      expect(result, 'Something went wrong. Please try again.');
    });
  });

  /// ==========================================
  /// TEST GROUP: Error Message Quality
  /// ==========================================
  ///
  /// Verify that all error messages meet quality standards.
  group('Error message quality', () {
    test('all error messages are user-friendly (no technical jargon)', () {
      final errors = [
        AuthException('Invalid login credentials'),
        AuthException('User already registered'),
        AuthException('Password is too weak'),
        'AuthApiException(message: Invalid credentials, statusCode: 400, code: invalid_credentials)',
        'NetworkException: Connection failed',
        Exception('Generic error'),
      ];

      for (final error in errors) {
        final result = ErrorMessageHelper.getReadableMessage(error);

        // Error message should NOT contain technical terms
        expect(result.contains('Exception'), false,
            reason: 'Should not contain "Exception"');
        expect(result.contains('statusCode'), false,
            reason: 'Should not contain "statusCode"');
        expect(result.contains('code:'), false,
            reason: 'Should not contain "code:"');
        expect(result.contains('error:'), false,
            reason: 'Should not contain "error:"');

        // Error message should be readable (not empty, not too long)
        expect(result.isNotEmpty, true, reason: 'Error message should not be empty');
        expect(result.length, lessThan(150),
            reason: 'Error message should be concise');
      }
    });

    test('all error messages are actionable', () {
      final errors = [
        AuthException('Invalid login credentials'),
        AuthException('User already registered'),
        AuthException('Password is too weak'),
        'NetworkException: Connection failed',
      ];

      for (final error in errors) {
        final result = ErrorMessageHelper.getReadableMessage(error);

        // Error message should tell user what to do
        // Should contain words like: "try", "please", "check", or specific action
        expect(
          result.toLowerCase(),
          anyOf(
            contains('try'),
            contains('please'),
            contains('check'),
            contains('must'),
            contains('instead'),
          ),
          reason: 'Error message should be actionable: "$result"',
        );
      }
    });
  });
}

/// 🎓 Learning Summary: What We Learned From These Tests
///
/// **Testing Error Sanitization:**
/// - Convert technical exceptions to user-friendly messages
/// - Handle different error types (AuthException, strings, network errors)
/// - Preserve user-friendly messages, replace technical ones
/// - Provide fallback for unknown errors
///
/// **Error Message Quality:**
/// - No technical jargon (Exception, statusCode, code:)
/// - Clear and concise (< 150 characters)
/// - Actionable (tell user what to do)
/// - Consistent tone across all errors
///
/// **Why These Tests Matter:**
/// - Error messages are the first thing users see when something goes wrong
/// - Bad error messages frustrate users and increase support requests
/// - Good error messages help users solve problems themselves
/// - These tests ensure all errors are user-friendly
///
/// **Running these tests:**
/// ```bash
/// flutter test test/shared/utils/error_message_helper_test.dart
/// ```
///
/// **Test Coverage:**
/// ✅ AuthException objects: 7 test cases
/// ✅ AuthException strings: 7 test cases
/// ✅ Network errors: 4 test cases
/// ✅ Generic exceptions: 5 test cases
/// ✅ Quality checks: 2 test cases
/// ✅ Total: 25 test cases
///
/// These 25 tests give us confidence that ErrorMessageHelper converts
/// ALL error types to user-friendly messages!
