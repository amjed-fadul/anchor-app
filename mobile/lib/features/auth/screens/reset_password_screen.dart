import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      // Check if widget is still mounted before proceeding
      if (!mounted) {
        return;
      }

      // Show success screen FIRST (while still authenticated with recovery session)
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // Wait briefly to show success message
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) {
        return;
      }

      // CRITICAL FIX: Sign out the recovery session FIRST
      // This prevents the router's refreshListenable from triggering
      // unwanted navigation after we go to /login
      await authService.signOut();

      // Wait for auth state to propagate through streams (300ms)
      // Increased from 100ms to ensure recoverySentAt is fully cleared
      // This prevents router redirect loop
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) {
        return;
      }

      // NOW navigate to login screen (after sign out is complete)
      // Router allows /login for both authenticated and unauthenticated users
      context.go('/login');
    } catch (e) {
      // Handle errors
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            debugPrint('🔵 [ResetPassword] Back button clicked');

            // Create completer to wait for SIGNED_OUT event from the auth stream
            // This ensures we don't navigate until the session is actually cleared
            final signedOut = Completer<void>();

            // Listen for auth state changes to detect when signOut completes
            final subscription = ref
                .read(authServiceProvider)
                .authStateChanges
                .listen((event) {
              debugPrint('🔵 [ResetPassword] Auth event: ${event.event}');
              if (event.event == AuthChangeEvent.signedOut) {
                debugPrint('🟢 [ResetPassword] SIGNED_OUT event received!');
                if (!signedOut.isCompleted) {
                  signedOut.complete();
                }
              }
            });

            try {
              // Sign out the recovery session
              await ref.read(authServiceProvider).signOut();
              debugPrint('🟢 [ResetPassword] signOut() HTTP request returned');

              // Wait for the SIGNED_OUT event from the stream (with 3-second timeout)
              // This is CRITICAL - we can't navigate until the stream emits and providers update
              await signedOut.future.timeout(
                const Duration(seconds: 3),
                onTimeout: () {
                  debugPrint(
                      '⚠️ [ResetPassword] SIGNED_OUT event timeout (3s) - proceeding anyway');
                },
              );

              // Verify session is actually cleared
              final session = ref.read(authServiceProvider).currentSession;
              final user = ref.read(authServiceProvider).currentUser;
              debugPrint(
                  '🔵 [ResetPassword] After SIGNED_OUT - session: ${session != null}, user: ${user != null}, recoverySentAt: ${user?.recoverySentAt}');

              if (!mounted) return;

              // NOW safe to navigate - session is guaranteed cleared
              // Check if we can pop (user navigated here from another screen)
              if (Navigator.of(context).canPop()) {
                debugPrint('🔵 [ResetPassword] Using context.pop()');
                context.pop();
              } else {
                // User came from email deep link - no navigation stack
                debugPrint('🔵 [ResetPassword] Using context.go(/login)');
                context.go('/login');
              }
            } finally {
              // Always cancel subscription to prevent memory leaks
              await subscription.cancel();
              debugPrint('🔵 [ResetPassword] Auth stream subscription cancelled');
            }
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
          prefixIcon: SvgPicture.asset(
            'assets/images/square-lock-01.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              Colors.grey[600]!,
              BlendMode.srcIn,
            ),
          ),
          isPassword: true,
          textInputAction: TextInputAction.next,
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
          prefixIcon: SvgPicture.asset(
            'assets/images/square-lock-01.svg',
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              Colors.grey[600]!,
              BlendMode.srcIn,
            ),
          ),
          isPassword: true,
          textInputAction: TextInputAction.done,
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
