library;

/// ForgotPasswordScreen Widget Tests
///
/// These tests verify that the Forgot Password screen UI works correctly.
/// This is the first step in the password reset flow - users enter their
/// email to receive a reset link.
///
/// 🎓 Learning: Simpler Widget Testing
///
/// This screen is simpler than ResetPasswordScreen because:
/// - Only one input field (email)
/// - No password matching logic
/// - Straightforward success state
///
/// But it still has critical functionality to test:
/// - Email validation
/// - Error handling
/// - Success confirmation
/// - Resend functionality

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import '../../../helpers/mock_supabase_client.dart';

/// Main test suite
void main() {
  /// Setup runs before EACH test
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  /// Helper function to pump the widget with providers
  ///
  /// Creates a test environment with mocked auth service
  Future<void> pumpForgotPasswordScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );

    // Wait for initial build
    await tester.pumpAndSettle();
  }

  /// ==========================================
  /// TEST GROUP: Initial Rendering
  /// ==========================================
  ///
  /// Tests that the screen renders correctly on first load.
  group('Initial Rendering', () {
    /// Test #1: Screen Renders with All Elements
    ///
    /// 🎓 Learning: Testing Initial State
    ///
    /// When a screen loads, users should see:
    /// - Clear heading explaining what to do
    /// - Input field with helpful placeholder
    /// - Submit button
    /// - Navigation options (back to login)
    testWidgets('renders form with all elements', (WidgetTester tester) async {
      // ARRANGE & ACT
      await pumpForgotPasswordScreen(tester);

      // ASSERT: Check that key elements are present
      expect(find.text('Reset your password'), findsOneWidget,
          reason: 'Should show heading');
      expect(
        find.textContaining('Enter your email address'),
        findsOneWidget,
        reason: 'Should show instruction text',
      );
      expect(find.text('Email'), findsOneWidget,
          reason: 'Should show email field label');
      expect(find.text('Send Reset Link'), findsOneWidget,
          reason: 'Should show submit button');
      expect(find.text('Back to Login'), findsOneWidget,
          reason: 'Should show back to login link');
    });

    /// Test #2: AppBar Renders with Back Button
    testWidgets('renders app bar with back button',
        (WidgetTester tester) async {
      // ARRANGE & ACT
      await pumpForgotPasswordScreen(tester);

      // ASSERT
      expect(find.text('Reset Password'), findsOneWidget,
          reason: 'AppBar should show title');
      expect(find.byIcon(Icons.arrow_back), findsOneWidget,
          reason: 'AppBar should have back button');
    });
  });

  /// ==========================================
  /// TEST GROUP: Form Validation
  /// ==========================================
  ///
  /// Tests that email validation works correctly.
  group('Form Validation', () {
    /// Test #3: Shows Error for Invalid Email
    ///
    /// 🎓 Learning: Email Validation Testing
    ///
    /// Invalid emails should be caught BEFORE calling the API.
    /// This saves network requests and gives instant feedback.
    testWidgets('shows validation error for invalid email',
        (WidgetTester tester) async {
      // ARRANGE
      await pumpForgotPasswordScreen(tester);

      // ACT: Enter invalid email and submit
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'notanemail'); // Missing @

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // ASSERT: Should show validation error
      expect(
        find.textContaining('valid'),
        findsOneWidget,
        reason: 'Should show invalid email error',
      );
    });

    /// Test #4: Shows Error for Empty Email
    testWidgets('shows validation error for empty email',
        (WidgetTester tester) async {
      // ARRANGE
      await pumpForgotPasswordScreen(tester);

      // ACT: Submit without entering email
      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // ASSERT: Should show required error
      expect(
        find.textContaining('required'),
        findsOneWidget,
        reason: 'Should show required field error',
      );
    });

    /// Test #5: Validation Passes for Valid Email
    ///
    /// Happy path: valid email should trigger the API call.
    testWidgets('validation passes with valid email',
        (WidgetTester tester) async {
      // ARRANGE: Mock successful email send
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await pumpForgotPasswordScreen(tester);

      // ACT: Enter valid email and submit
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'user@example.com');

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pump(); // Start async operation

      // ASSERT: Should call resetPassword (no validation errors)
      verify(() => mockAuthService.resetPassword(
            email: 'user@example.com',
          )).called(1);
    });
  });

  /// ==========================================
  /// TEST GROUP: Password Reset Flow
  /// ==========================================
  ///
  /// Tests the email sending operation and its states.
  group('Password Reset Flow', () {
    /// Test #6: Calls resetPassword with Correct Email
    ///
    /// Critical: The service must be called with the EXACT email
    /// the user entered (trimmed of whitespace).
    testWidgets('calls resetPassword with trimmed email',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await pumpForgotPasswordScreen(tester);

      // ACT: Enter email with spaces (users often do this accidentally)
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, '  user@example.com  '); // Spaces!

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pump();

      // ASSERT: Should call with TRIMMED email
      verify(() => mockAuthService.resetPassword(
            email: 'user@example.com', // No spaces
          )).called(1);
    });

    /// Test #7: Shows Success View After Email Sent
    ///
    /// 🎓 Learning: Success State Testing
    ///
    /// After email sends successfully, users should see:
    /// - Confirmation message
    /// - Their email address (so they know where to check)
    /// - Option to go back to login
    /// - Option to resend if needed
    testWidgets('shows success view after email sent successfully',
        (WidgetTester tester) async {
      // ARRANGE
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await pumpForgotPasswordScreen(tester);

      // ACT: Send reset email
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'user@example.com');

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // ASSERT: Success view should be shown
      expect(find.text('Check your email'), findsOneWidget,
          reason: 'Should show success heading');
      expect(
        find.textContaining('We\'ve sent a password reset link to'),
        findsOneWidget,
        reason: 'Should show success message',
      );
      expect(find.text('user@example.com'), findsOneWidget,
          reason: 'Should show the email address');
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget,
          reason: 'Should show success icon');
    });

    /// Test #8: Shows Error Message When Email Send Fails
    ///
    /// Network failures, invalid emails (server-side), etc. should
    /// show helpful error messages.
    testWidgets('shows error message when email send fails',
        (WidgetTester tester) async {
      // ARRANGE: Mock failure
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenThrow(Exception('Network error'));

      await pumpForgotPasswordScreen(tester);

      // ACT: Try to send email
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'user@example.com');

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // ASSERT: Error should be displayed
      expect(find.text('Network error'), findsOneWidget,
          reason: 'Should show error message');
      expect(find.byIcon(Icons.error_outline), findsOneWidget,
          reason: 'Should show error icon');
    });
  });

  /// ==========================================
  /// TEST GROUP: Success View Interactions
  /// ==========================================
  ///
  /// Tests the success screen functionality.
  group('Success View', () {
    /// Test #9: Resend Button Returns to Form
    ///
    /// 🎓 Learning: State Transitions
    ///
    /// Sometimes users don't receive the email:
    /// - Spam folder
    /// - Typo in email address
    /// - Email service delays
    ///
    /// The "Resend" button should let them try again without
    /// refreshing the whole screen.
    testWidgets('resend button returns to form view',
        (WidgetTester tester) async {
      // ARRANGE: Get to success state first
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await pumpForgotPasswordScreen(tester);

      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'user@example.com');

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify we're on success screen
      expect(find.text('Check your email'), findsOneWidget);

      // ACT: Tap resend button
      final resendButton = find.text('Didn\'t receive the email? Resend');
      await tester.tap(resendButton);
      await tester.pumpAndSettle();

      // ASSERT: Should be back on form view
      expect(find.text('Reset your password'), findsOneWidget,
          reason: 'Should show form heading again');
      expect(find.text('Send Reset Link'), findsOneWidget,
          reason: 'Should show submit button again');

      // Email field should still have the email (for convenience)
      expect(find.text('user@example.com'), findsOneWidget,
          reason: 'Email should be preserved in field');
    });

    /// Test #10: Back to Login Button Present
    ///
    /// Users should be able to navigate back to login from success screen.
    testWidgets('back to login button shown on success screen',
        (WidgetTester tester) async {
      // ARRANGE: Get to success state
      when(() => mockAuthService.resetPassword(
            email: any(named: 'email'),
          )).thenAnswer((_) async {});

      await pumpForgotPasswordScreen(tester);

      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'user@example.com');

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // ASSERT: Back to Login button should be present
      // Note: There are TWO "Back to Login" buttons:
      // 1. On the form view (TextButton)
      // 2. On the success view (AnchorButton)
      expect(
        find.text('Back to Login'),
        findsOneWidget, // Only the success view one should be visible now
        reason: 'Should show Back to Login button on success screen',
      );
    });
  });

  /// ==========================================
  /// TEST GROUP: Error Clearing Behavior
  /// ==========================================
  ///
  /// Tests that errors clear when user starts typing.
  group('Error Clearing', () {
    /// Test #11: Clears Email Error When User Types
    ///
    /// Good UX: Clear validation errors as soon as user tries to fix them.
    testWidgets('clears email error when user starts typing',
        (WidgetTester tester) async {
      // ARRANGE: Create error state
      await pumpForgotPasswordScreen(tester);

      // Trigger validation error
      final emailField = find.widgetWithText(TextField, 'your@email.com');
      await tester.enterText(emailField, 'invalid'); // No @

      final submitButton = find.text('Send Reset Link');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify error is shown (use more specific text)
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // ACT: Start typing to fix the error
      await tester.enterText(emailField, 'user@example.com'); // Valid now
      await tester.pump();

      // ASSERT: Error message should be cleared
      expect(find.text('Please enter a valid email'), findsNothing,
          reason: 'Error should clear when user types');
    });
  });
}

/// 🎓 Learning Summary: What We Learned From These Tests
///
/// **Widget Testing Patterns:**
/// - Simpler screen = simpler tests (only email validation vs password + confirm)
/// - Testing state transitions (form → success → form)
/// - Testing user convenience features (email preserved on resend)
///
/// **Critical Flows Tested:**
/// - Email validation (invalid, empty, valid)
/// - Email sending (success, failure)
/// - Success confirmation (shows user's email)
/// - Resend functionality (returns to form)
/// - Error clearing (good UX)
///
/// **What We're Testing:**
/// - ✅ Initial rendering with all elements
/// - ✅ AppBar and back button
/// - ✅ Email validation (invalid format)
/// - ✅ Email validation (empty field)
/// - ✅ Valid email passes validation
/// - ✅ Calls resetPassword with trimmed email
/// - ✅ Success view after email sent
/// - ✅ Error message on failure
/// - ✅ Resend button returns to form
/// - ✅ Back to Login button on success
/// - ✅ Error clearing on typing
///
/// **Running these tests:**
/// ```bash
/// # Run just these tests
/// flutter test test/features/auth/screens/forgot_password_screen_test.dart
///
/// # Run all tests
/// flutter test
/// ```
///
/// **Test Coverage:**
/// ✅ Initial Rendering: 2 tests
/// ✅ Form Validation: 3 tests
/// ✅ Password Reset Flow: 3 tests
/// ✅ Success View: 2 tests
/// ✅ Error Clearing: 1 test
/// ✅ Total: 11 new tests!
///
/// **Total Progress:**
/// ✅ Validators: 20 tests
/// ✅ AuthService: 11 tests
/// ✅ Router: 12 tests
/// ✅ Providers: 12 tests
/// ✅ ResetPasswordScreen: 11 tests
/// ✅ ForgotPasswordScreen: 11 tests
/// ✅ **Total: 77 tests!** 🎉
///
/// **Why These Tests Matter:**
/// - ForgotPasswordScreen is the entry point for password reset
/// - Tests ensure users can REQUEST a reset link reliably
/// - Tests verify good UX (error clearing, email preserved on resend)
/// - Completes the password reset flow testing (forgot → email → reset)
///
/// **Next:**
/// Run these tests and see them pass! All unit and widget tests complete!
