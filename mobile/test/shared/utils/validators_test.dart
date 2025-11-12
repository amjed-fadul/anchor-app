library;

/// Validators Unit Tests
///
/// These tests verify that our form validation functions work correctly.
/// Validators are the EASIEST type of code to test because they're "pure functions":
///
/// Input → Function → Output
///
/// No databases, no network, no complicated state. Just simple logic!
///
/// Real-World Analogy:
/// Testing a calculator. You give it 2+2, it should return 4.
/// If it returns 5, the test fails. Simple!

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/shared/utils/validators.dart';

/// Main test function
///
/// Think of this as a "test suite" - a collection of related tests.
/// We use `group()` to organize tests by what they're testing.
void main() {
  /// ==========================================
  /// EMAIL VALIDATOR TESTS
  /// ==========================================
  ///
  /// The email validator should:
  /// - Return null (no error) for valid emails
  /// - Return error message for invalid emails
  /// - Return error message for empty/null emails
  group('Email Validator', () {
    /// Test #1: Valid Email
    ///
    /// 🎓 Learning: The Arrange-Act-Assert Pattern
    /// This is the most common pattern in testing:
    ///
    /// 1. ARRANGE: Set up test data
    /// 2. ACT: Call the function being tested
    /// 3. ASSERT: Check the result matches what we expect
    test('returns null for valid email', () {
      // ARRANGE: Create test data
      const validEmail = 'user@example.com';

      // ACT: Call the validator
      final result = Validators.email(validEmail);

      // ASSERT: Check the result
      // null = no error = validation passed ✅
      expect(result, null);
    });

    /// Test #2: Multiple Valid Emails
    ///
    /// 🎓 Learning: Testing Multiple Cases
    /// It's good practice to test various valid inputs to make sure
    /// the function handles different formats correctly.
    test('returns null for various valid email formats', () {
      // List of different valid email formats
      const validEmails = [
        'simple@example.com',
        'user.name@example.com',
        'user+tag@example.co.uk',
        'user_123@test-domain.com',
      ];

      // Test each one
      for (final email in validEmails) {
        final result = Validators.email(email);
        expect(result, null,
            reason: '$email should be valid'); // Add reason to help debug
      }
    });

    /// Test #3: Invalid Email - Missing @
    ///
    /// 🎓 Learning: Testing Error Cases
    /// Testing errors is just as important as testing success!
    /// We want to make sure bad inputs are caught.
    test('returns error message for email missing @ symbol', () {
      // ARRANGE
      const invalidEmail = 'userexample.com'; // Missing @

      // ACT
      final result = Validators.email(invalidEmail);

      // ASSERT
      // Should return an error message, not null
      expect(result, isNotNull); // Result should exist
      expect(result, contains('valid')); // Should mention it's invalid
    });

    /// Test #4: Invalid Email - No Domain
    test('returns error message for email without domain', () {
      const invalidEmail = 'user@';

      final result = Validators.email(invalidEmail);

      expect(result, isNotNull);
      expect(result, contains('valid'));
    });

    /// Test #5: Empty Email
    ///
    /// 🎓 Learning: Edge Cases
    /// "Edge cases" are unusual inputs that might break your code.
    /// Empty strings, nulls, very long strings, special characters, etc.
    /// Always test edge cases!
    test('returns error message for empty email', () {
      const emptyEmail = '';

      final result = Validators.email(emptyEmail);

      expect(result, isNotNull);
      expect(result, contains('required')); // Should say it's required
    });

    /// Test #6: Null Email
    test('returns error message for null email', () {
      const String? nullEmail = null;

      final result = Validators.email(nullEmail);

      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    /// Test #7: Email with Spaces (Automatically Trimmed)
    ///
    /// 🎓 Learning: Good UX vs Strict Validation
    /// Our validator is smart - it TRIMS spaces automatically!
    /// This means " user@example.com " is treated as "user@example.com"
    /// This is good UX - users often accidentally add spaces.
    test('returns null for email with spaces (trimmed automatically)', () {
      const emailWithSpaces = ' user@example.com ';

      final result = Validators.email(emailWithSpaces);

      // The validator trims spaces, so this should pass ✅
      expect(result, null);
    });
  });

  /// ==========================================
  /// PASSWORD VALIDATOR TESTS
  /// ==========================================
  ///
  /// The password validator should:
  /// - Return null for passwords with 6+ characters
  /// - Return error for passwords < 6 characters
  /// - Return error for empty/null passwords
  group('Password Validator', () {
    /// Test #1: Valid Password (Minimum Length)
    test('returns null for password with exactly 6 characters', () {
      // ARRANGE: Create minimum valid password
      const validPassword = '123456'; // Exactly 6 chars

      // ACT
      final result = Validators.password(validPassword);

      // ASSERT
      expect(result, null); // Should pass
    });

    /// Test #2: Valid Password (Longer)
    test('returns null for password longer than 6 characters', () {
      const validPassword = 'MySecurePassword123!';

      final result = Validators.password(validPassword);

      expect(result, null);
    });

    /// Test #3: Invalid Password (Too Short)
    ///
    /// 🎓 Learning: Testing Boundary Conditions
    /// The requirement is "at least 6 characters".
    /// We should test:
    /// - 5 characters (should fail)
    /// - 6 characters (should pass) ← We did this above
    /// - 7+ characters (should pass)
    ///
    /// These are called "boundary conditions" - the edges of what's valid.
    test('returns error message for password with 5 characters', () {
      const shortPassword = '12345'; // Only 5 chars

      final result = Validators.password(shortPassword);

      expect(result, isNotNull);
      expect(result, contains('6')); // Should mention minimum length
    });

    /// Test #4: Invalid Password (Way Too Short)
    test('returns error message for very short password', () {
      const veryShortPassword = '12';

      final result = Validators.password(veryShortPassword);

      expect(result, isNotNull);
      expect(result, contains('6'));
    });

    /// Test #5: Empty Password
    test('returns error message for empty password', () {
      const emptyPassword = '';

      final result = Validators.password(emptyPassword);

      expect(result, isNotNull);
      expect(result, contains('required'));
    });

    /// Test #6: Null Password
    test('returns error message for null password', () {
      const String? nullPassword = null;

      final result = Validators.password(nullPassword);

      expect(result, isNotNull);
      expect(result, contains('required'));
    });
  });

  /// ==========================================
  /// CONFIRM PASSWORD VALIDATOR TESTS
  /// ==========================================
  ///
  /// The confirmPassword validator should:
  /// - Return null when passwords match
  /// - Return error when passwords don't match
  /// - Return error when confirm password is empty/null
  group('Confirm Password Validator', () {
    /// Test #1: Matching Passwords
    test('returns null when passwords match', () {
      // ARRANGE
      const password = 'MyPassword123';
      const confirmPassword = 'MyPassword123';

      // ACT
      final result = Validators.confirmPassword(password, confirmPassword);

      // ASSERT
      expect(result, null); // Should pass
    });

    /// Test #2: Non-Matching Passwords
    ///
    /// 🎓 Learning: Testing Related Functions
    /// confirmPassword depends on TWO inputs: original and confirmation.
    /// We need to test all combinations:
    /// - Both same ✅
    /// - Different ❌
    /// - One empty ❌
    /// - Both empty ❌
    test('returns error message when passwords do not match', () {
      const password = 'MyPassword123';
      const confirmPassword = 'DifferentPassword456';

      final result = Validators.confirmPassword(password, confirmPassword);

      expect(result, isNotNull);
      expect(result, contains('match')); // Should say they don't match
    });

    /// Test #3: Case Sensitivity
    ///
    /// 🎓 Learning: Test Assumptions
    /// Should "Password" and "password" be considered different?
    /// YES! Passwords are case-sensitive.
    /// Write a test to verify this assumption.
    test('returns error when passwords differ only in case', () {
      const password = 'MyPassword';
      const confirmPassword = 'mypassword'; // Different case

      final result = Validators.confirmPassword(password, confirmPassword);

      expect(result, isNotNull); // Should fail - passwords are case-sensitive
    });

    /// Test #4: Empty Confirmation
    test('returns error message when confirm password is empty', () {
      const password = 'MyPassword123';
      const confirmPassword = '';

      final result = Validators.confirmPassword(password, confirmPassword);

      expect(result, isNotNull);
      expect(result, contains('confirm')); // "Please confirm your password"
    });

    /// Test #5: Null Confirmation
    test('returns error message when confirm password is null', () {
      const password = 'MyPassword123';
      const String? confirmPassword = null;

      final result = Validators.confirmPassword(password, confirmPassword);

      expect(result, isNotNull);
      expect(result, contains('confirm')); // "Please confirm your password"
    });

    /// Test #6: Both Empty
    ///
    /// 🎓 Learning: Edge Cases Can Be Surprising
    /// What should happen if BOTH passwords are empty?
    /// Logically, they "match" (both empty), but we probably want
    /// an error since the user hasn't filled in anything!
    ///
    /// This test documents the expected behavior.
    test('returns error when both passwords are empty', () {
      const password = '';
      const confirmPassword = '';

      final result = Validators.confirmPassword(password, confirmPassword);

      // Should return error because confirmation is empty (required field)
      expect(result, isNotNull);
    });

    /// Test #7: Whitespace Handling
    ///
    /// 🎓 Learning: Test User Mistakes
    /// Users might accidentally add spaces. Should "password " and "password"
    /// be considered the same? Probably not!
    test('returns error when passwords differ due to whitespace', () {
      const password = 'MyPassword123';
      const confirmPassword = 'MyPassword123 '; // Extra space

      final result = Validators.confirmPassword(password, confirmPassword);

      // Passwords should NOT match (whitespace matters in passwords)
      expect(result, isNotNull);
    });
  });
}

/// 🎓 Learning Summary: What We Learned From These Tests
///
/// 1. **Arrange-Act-Assert Pattern**: Set up data, call function, check result
/// 2. **Test Both Success and Failure**: Valid AND invalid inputs
/// 3. **Edge Cases Matter**: null, empty, spaces, boundaries (5 vs 6 chars)
/// 4. **Descriptive Test Names**: test('returns error when X happens')
/// 5. **Pure Functions Are Easy to Test**: No mocking, no setup, just input→output
///
/// Running these tests:
/// ```bash
/// # Run just this file
/// flutter test test/shared/utils/validators_test.dart
///
/// # Run all tests
/// flutter test
///
/// # Run with verbose output
/// flutter test --reporter expanded
/// ```
///
/// What we tested:
/// ✅ 7 email validation scenarios
/// ✅ 6 password validation scenarios
/// ✅ 7 confirm password scenarios
/// ✅ Total: 20 test cases!
///
/// These 20 tests give us confidence that our validators work correctly
/// in ALL scenarios, not just the "happy path" (valid input).
///
/// Next steps:
/// - Run `flutter test` to see these tests pass
/// - Try breaking a validator on purpose to see tests fail (learning!)
/// - Move on to testing more complex code (AuthService)
