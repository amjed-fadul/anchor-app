import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Forgot password screen
///
/// Allows users to reset their password by:
/// - Entering their email
/// - Receiving a reset link via email
///
/// Features:
/// - Email field with validation
/// - Loading state during email send
/// - Error message display
/// - Success state showing confirmation message
/// - "Back to Login" navigation
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controller for email field
  final _emailController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // Field-specific error message
  String? _emailError;

  // Success state - unique to this screen
  bool _isSuccess = false;

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    _emailController.dispose();
    super.dispose();
  }

  /// Validate email field
  bool _validateFields() {
    setState(() {
      _emailError = Validators.email(_emailController.text);
    });

    return _emailError == null;
  }

  /// Handle password reset form submission
  Future<void> _handleResetPassword() async {
    // Clear any previous error messages
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_validateFields()) {
      return;
    }

    // Show loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Get auth service from provider
      final authService = ref.read(authServiceProvider);

      // Send password reset email
      await authService.resetPassword(
        email: _emailController.text.trim(),
      );

      // If we reach here, email was sent successfully
      // Show success state instead of navigating away
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      // Handle errors
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AnchorSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: _isSuccess ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  /// Build the email input form view
  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page heading
        Text(
          'Reset your password',
          style: AnchorTypography.headlineMedium.copyWith(
            color: AnchorColors.anchorSlate,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Enter your email address and we\'ll send you a link to reset your password',
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.gray600,
          ),
        ),

        const SizedBox(height: 32),

        // Email field
        AnchorTextField(
          controller: _emailController,
          label: 'Email',
          hintText: 'your@email.com',
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          enabled: !_isLoading,
          onChanged: (value) {
            // Clear error when user starts typing
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
            }
          },
        ),

        // Error message display
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AnchorColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AnchorColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: AnchorColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: AnchorTypography.bodySmall.copyWith(
                      color: AnchorColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Send reset link button
        AnchorButton(
          label: 'Send Reset Link',
          onPressed: _isLoading ? null : _handleResetPassword,
          isLoading: _isLoading,
          fullWidth: true,
          size: AnchorButtonSize.large,
        ),

        const SizedBox(height: 16),

        // Back to login link
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    context.go('/login');
                  },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Back to Login',
              style: AnchorTypography.bodyMedium.copyWith(
                color: AnchorColors.anchorTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the success view after email is sent
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),

        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AnchorColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AnchorColors.success,
          ),
        ),

        const SizedBox(height: 24),

        // Success heading
        Text(
          'Check your email',
          style: AnchorTypography.headlineMedium.copyWith(
            color: AnchorColors.anchorSlate,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Success message
        Text(
          'We\'ve sent a password reset link to',
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 4),

        // User's email
        Text(
          _emailController.text.trim(),
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.anchorSlate,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Back to login button
        AnchorButton(
          label: 'Back to Login',
          onPressed: () {
            context.go('/login');
          },
          fullWidth: true,
          size: AnchorButtonSize.large,
        ),

        const SizedBox(height: 16),

        // Resend email option
        TextButton(
          onPressed: () {
            // Reset to form view to allow resending
            setState(() {
              _isSuccess = false;
              _errorMessage = null;
              _emailError = null;
            });
          },
          child: Text(
            'Didn\'t receive the email? Resend',
            style: AnchorTypography.bodySmall.copyWith(
              color: AnchorColors.anchorTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
