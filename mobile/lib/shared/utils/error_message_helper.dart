import 'package:supabase_flutter/supabase_flutter.dart';

/// Error Message Helper
///
/// Converts technical Supabase exceptions into user-friendly error messages.
///
/// Problem: Supabase throws errors like:
/// "AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)"
///
/// This helper sanitizes them to:
/// "Invalid email or password. Please try again."
///
/// Usage:
/// ```dart
/// try {
///   await authService.signIn(email: email, password: password);
/// } catch (e) {
///   setState(() {
///     _errorMessage = ErrorMessageHelper.getReadableMessage(e);
///   });
/// }
/// ```
class ErrorMessageHelper {
  /// Convert any exception into a user-friendly error message
  ///
  /// Handles:
  /// - AuthException (Supabase auth errors)
  /// - AuthApiException (Supabase API errors)
  /// - Network errors (timeouts, connection failures)
  /// - Generic exceptions
  ///
  /// Returns a clear, actionable message that helps users understand
  /// what went wrong and how to fix it.
  static String getReadableMessage(dynamic error) {
    // If error is null, return generic message
    if (error == null) {
      return 'Something went wrong. Please try again.';
    }

    // Handle AuthException (Supabase auth errors)
    if (error is AuthException) {
      return _parseAuthException(error);
    }

    // Handle error strings that contain AuthException or AuthApiException
    // (Sometimes exceptions are converted to string before reaching here)
    final errorString = error.toString();

    // Check if it's an AuthException string
    if (errorString.contains('AuthException') ||
        errorString.contains('AuthApiException')) {
      return _parseAuthExceptionString(errorString);
    }

    // Handle network/connection errors
    if (errorString.toLowerCase().contains('network') ||
        errorString.toLowerCase().contains('connection') ||
        errorString.toLowerCase().contains('timeout') ||
        errorString.toLowerCase().contains('failed host lookup')) {
      return 'Connection error. Please check your internet and try again.';
    }

    // Handle timeout errors
    if (errorString.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    // If the error string is already user-friendly (doesn't contain technical details),
    // return it as-is
    if (errorString.trim().isNotEmpty &&
        !errorString.contains('Exception') &&
        !errorString.contains('error:') &&
        !errorString.contains('Error:') &&
        errorString.length < 100) {
      return errorString;
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  /// Parse AuthException object and return user-friendly message
  static String _parseAuthException(AuthException error) {
    final message = error.message.toLowerCase();
    final statusCode = error.statusCode;

    // Check error message for specific patterns
    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }

    if (message.contains('email already') ||
        message.contains('user already registered')) {
      return 'This email is already registered. Try logging in instead.';
    }

    if (message.contains('weak password') || message.contains('password')) {
      return 'Password must be at least 6 characters long.';
    }

    if (message.contains('user not found') ||
        message.contains('email not found')) {
      return 'No account found with this email address.';
    }

    if (message.contains('invalid grant') ||
        message.contains('session') ||
        message.contains('expired')) {
      return 'This link has expired. Please request a new one.';
    }

    if (message.contains('rate limit') ||
        message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    if (message.contains('email not confirmed') ||
        message.contains('not verified')) {
      return 'Please verify your email address before signing in.';
    }

    // If status code is 400, it's usually a validation error
    if (statusCode == '400') {
      return 'Invalid request. Please check your information and try again.';
    }

    // If status code is 401, it's an authentication error
    if (statusCode == '401') {
      return 'Authentication failed. Please try again.';
    }

    // If status code is 500, it's a server error
    if (statusCode == '500' || statusCode == '503') {
      return 'Server error. Please try again later.';
    }

    // If we have a message from Supabase, use it (it's usually already user-friendly)
    if (error.message.isNotEmpty && error.message.length < 100) {
      return error.message;
    }

    return 'Authentication error. Please try again.';
  }

  /// Parse AuthException string (when exception was converted to string)
  ///
  /// Example input:
  /// "AuthApiException(message: Invalid login credentials, statusCode: 400, code: invalid_credentials)"
  ///
  /// This method extracts the error code and maps it to a friendly message.
  static String _parseAuthExceptionString(String errorString) {
    // Extract error code if present
    // Pattern: "code: something)" or "code: something,"
    final codeMatch = RegExp(r'code:\s*([^,)]+)').firstMatch(errorString);
    if (codeMatch != null) {
      final code = codeMatch.group(1)?.trim().toLowerCase();

      // Map error codes to friendly messages
      switch (code) {
        case 'invalid_credentials':
        case 'invalid_grant':
          return 'Invalid email or password. Please try again.';

        case 'email_exists':
        case 'user_already_registered':
          return 'This email is already registered. Try logging in instead.';

        case 'weak_password':
          return 'Password must be at least 6 characters long.';

        case 'user_not_found':
        case 'email_not_found':
          return 'No account found with this email address.';

        case 'session_expired':
        case 'token_expired':
          return 'This link has expired. Please request a new one.';

        case 'rate_limit_exceeded':
          return 'Too many attempts. Please wait a moment and try again.';

        case 'email_not_confirmed':
          return 'Please verify your email address before signing in.';
      }
    }

    // Extract message if present
    // Pattern: "message: something, statusCode"
    final messageMatch =
        RegExp(r'message:\s*([^,)]+)').firstMatch(errorString);
    if (messageMatch != null) {
      final message = messageMatch.group(1)?.trim();
      if (message != null && message.isNotEmpty && message.length < 100) {
        // If message is already user-friendly, return it
        if (!message.contains('Exception') && !message.contains('error:')) {
          return message;
        }
      }
    }

    // Check for specific keywords in the full string
    final lowerError = errorString.toLowerCase();

    if (lowerError.contains('invalid login') ||
        lowerError.contains('invalid credentials')) {
      return 'Invalid email or password. Please try again.';
    }

    if (lowerError.contains('email already') ||
        lowerError.contains('already registered')) {
      return 'This email is already registered. Try logging in instead.';
    }

    if (lowerError.contains('weak password')) {
      return 'Password must be at least 6 characters long.';
    }

    if (lowerError.contains('user not found') ||
        lowerError.contains('email not found')) {
      return 'No account found with this email address.';
    }

    if (lowerError.contains('expired') || lowerError.contains('invalid grant')) {
      return 'This link has expired. Please request a new one.';
    }

    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }

    // Generic auth error fallback
    return 'Authentication error. Please try again.';
  }
}
