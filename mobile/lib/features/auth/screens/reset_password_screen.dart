import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Reset password screen
///
/// Allows users to set a new password after clicking the reset link in their email.
///
/// Features:
/// - Password field with visibility toggle
/// - Confirm password field
/// - Validation (min 6 chars, matching passwords)
/// - Loading state during password update
/// - Error message display
/// - Success state with confirmation
/// - Automatic navigation to login after success
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for password fields
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // Field-specific error messages
  String? _passwordError;
  String? _confirmPasswordError;

  // Success state - unique to this screen
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();

    // Check if we have a valid recovery session after widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(authServiceProvider).currentSession;

      if (session == null) {
        // No session = invalid/expired link
        setState(() {
          _errorMessage =
              'This reset link is invalid or has expired. Please request a new one.';
        });
      }
    });
  }

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate all fields
  bool _validateFields() {
    setState(() {
      _passwordError = Validators.password(_passwordController.text);
      _confirmPasswordError = Validators.confirmPassword(
        _passwordController.text,
        _confirmPasswordController.text,
      );
    });

    return _passwordError == null && _confirmPasswordError == null;
  }

  /// Handle password update form submission
  Future<void> _handleUpdatePassword() async {
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

      // Update the password
      await authService.updatePassword(
        newPassword: _passwordController.text,
      );

      // Sign out to clear the recovery session
      // This prevents the router from detecting the old recovery session
      // and redirecting back to reset password on next login
      await authService.signOut();

      // If we reach here, password was updated successfully
      // Show success state instead of navigating away
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Auto-navigate to login after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/login');
        }
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
            context.go('/login');
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

  /// Build the password input form view
  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page heading
        Text(
          'Create new password',
          style: AnchorTypography.headlineMedium.copyWith(
            color: AnchorColors.anchorSlate,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Enter your new password below',
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.gray600,
          ),
        ),

        const SizedBox(height: 32),

        // Password field
        AnchorTextField(
          controller: _passwordController,
          label: 'New Password',
          hintText: 'At least 6 characters',
          isPassword: true,
          errorText: _passwordError,
          enabled: !_isLoading,
          onChanged: (value) {
            // Clear error when user starts typing
            if (_passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            }
          },
        ),

        const SizedBox(height: 16),

        // Confirm password field
        AnchorTextField(
          controller: _confirmPasswordController,
          label: 'Confirm New Password',
          hintText: 'Re-enter your password',
          isPassword: true,
          errorText: _confirmPasswordError,
          enabled: !_isLoading,
          onChanged: (value) {
            // Clear error when user starts typing
            if (_confirmPasswordError != null) {
              setState(() {
                _confirmPasswordError = null;
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

        // Update password button
        AnchorButton(
          label: 'Update Password',
          onPressed: _isLoading ? null : _handleUpdatePassword,
          isLoading: _isLoading,
          fullWidth: true,
          size: AnchorButtonSize.large,
        ),
      ],
    );
  }

  /// Build the success view after password is updated
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
          'Password updated!',
          style: AnchorTypography.headlineMedium.copyWith(
            color: AnchorColors.anchorSlate,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Success message
        Text(
          'Your password has been successfully updated',
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // Go to login button
        AnchorButton(
          label: 'Go to Login',
          onPressed: () {
            context.go('/login');
          },
          fullWidth: true,
          size: AnchorButtonSize.large,
        ),

        const SizedBox(height: 16),

        // Auto-redirect message
        Text(
          'Redirecting to login in 2 seconds...',
          style: AnchorTypography.bodySmall.copyWith(
            color: AnchorColors.gray600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
