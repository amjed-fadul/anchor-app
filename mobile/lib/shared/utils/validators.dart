// Validation utilities for form inputs
//
// These validators return `null` if the input is valid,
// or an error message string if the input is invalid.
//
// This follows Flutter's FormField validator pattern.

class Validators {
  // Private constructor to prevent instantiation
  // This class only contains static utility methods
  Validators._();

  /// Validates an email address
  ///
  /// Returns:
  /// - `null` if email is valid
  /// - Error message string if invalid
  ///
  /// Rules:
  /// - Cannot be empty
  /// - Must contain @ symbol
  /// - Must have text before and after @
  /// - Must have a domain extension (.com, .org, etc.)
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.email('test@example.com');
  /// if (error != null) {
  ///   print('Invalid email: $error');
  /// }
  /// ```
  static String? email(String? value) {
    // Check if empty or null
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Trim whitespace
    final email = value.trim();

    // Basic email validation using regex
    // Pattern explanation:
    // ^          - Start of string
    // [^@]+      - One or more characters that are not @
    // @          - Literal @ symbol
    // [^@]+      - One or more characters that are not @
    // \.         - Literal dot
    // [^@]+      - One or more characters that are not @
    // $          - End of string
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null; // Email is valid
  }

  /// Validates a password
  ///
  /// Returns:
  /// - `null` if password is valid
  /// - Error message string if invalid
  ///
  /// Rules:
  /// - Cannot be empty
  /// - Minimum 6 characters (Supabase requirement)
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.password('mypass123');
  /// if (error == null) {
  ///   print('Password is valid!');
  /// }
  /// ```
  static String? password(String? value) {
    // Check if empty or null
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    // Check minimum length
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null; // Password is valid
  }

  /// Validates that a value is not empty
  ///
  /// Returns:
  /// - `null` if value is not empty
  /// - Error message string if empty
  ///
  /// Useful for required fields that don't need specific format validation.
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.required('John Doe', 'Name');
  /// ```
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that two password fields match
  ///
  /// Returns:
  /// - `null` if passwords match
  /// - Error message string if they don't match
  ///
  /// Useful for "confirm password" fields.
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.confirmPassword('pass123', 'pass123');
  /// ```
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates a URL
  ///
  /// Returns:
  /// - `null` if URL is valid
  /// - Error message string if invalid
  ///
  /// Useful for validating link URLs in the app.
  ///
  /// Example:
  /// ```dart
  /// final error = Validators.url('https://example.com');
  /// ```
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }

    final url = value.trim();

    // Basic URL validation
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(url)) {
      return 'Please enter a valid URL';
    }

    return null;
  }
}
