import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Email signup form screen
///
/// Second screen in the signup flow where users enter:
/// - Email address
/// - Password
/// - Confirm password
///
/// Upon successful signup, user is automatically logged in
/// and navigated to the home screen.
class SignupEmailScreen extends ConsumerStatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  ConsumerState<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends ConsumerState<SignupEmailScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Success state (after signup completes)
  bool _isSuccess = false;

  // Error message
  String? _errorMessage;

  // Field-specific error messages
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validate all fields
  bool _validateFields() {
    setState(() {
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.password(_passwordController.text);
      _confirmPasswordError = Validators.confirmPassword(
        _passwordController.text,
        _confirmPasswordController.text,
      );
    });

    return _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  /// Handle form submission
  Future<void> _handleSignup() async {
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

      // Attempt to sign up
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // SUCCESS: Supabase has sent confirmation email
      // Show success message instead of navigating
      // User needs to click email confirmation link before they can log in
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      // Handle signup errors
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
        title: const Text('Sign Up'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show success message if signup completed
                if (_isSuccess) ...[
                  // Success icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AnchorColors.anchorTeal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.email_outlined,
                        size: 40,
                        color: AnchorColors.anchorTeal,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Success heading
                  Text(
                    'Check your email!',
                    style: AnchorTypography.headlineMedium.copyWith(
                      color: AnchorColors.anchorSlate,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Success message
                  Text(
                    'We sent a confirmation link to',
                    style: AnchorTypography.bodyMedium.copyWith(
                      color: AnchorColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // User's email
                  Text(
                    _emailController.text,
                    style: AnchorTypography.bodyMedium.copyWith(
                      color: AnchorColors.anchorSlate,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Instructions
                  Text(
                    'Click the link in the email to confirm your account, then come back here to sign in.',
                    style: AnchorTypography.bodyMedium.copyWith(
                      color: AnchorColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Go to Sign In button
                  AnchorButton(
                    label: 'Go to Sign In',
                    onPressed: () => context.go('/login'),
                    fullWidth: true,
                    size: AnchorButtonSize.large,
                  ),

                  const SizedBox(height: 16),

                  // Didn't receive email link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isSuccess = false;
                          _isLoading = false;
                        });
                      },
                      child: Text(
                        'Try again',
                        style: AnchorTypography.bodyMedium.copyWith(
                          color: AnchorColors.anchorTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ]
                // Show signup form if not yet successful
                else ...[
                  // Page heading
                  Text(
                    'Create your account',
                    style: AnchorTypography.headlineMedium.copyWith(
                      color: AnchorColors.anchorSlate,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Enter your details below to get started',
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

                const SizedBox(height: 16),

                // Password field
                AnchorTextField(
                  controller: _passwordController,
                  label: 'Password',
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
                  label: 'Confirm Password',
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

                const SizedBox(height: 32),

                // Sign up button
                AnchorButton(
                  label: 'Sign Up',
                  onPressed: _isLoading ? null : _handleSignup,
                  isLoading: _isLoading,
                  fullWidth: true,
                  size: AnchorButtonSize.large,
                ),

                const SizedBox(height: 16),

                  // Terms and privacy text
                  Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy',
                    style: AnchorTypography.bodySmall.copyWith(
                      color: AnchorColors.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ], // End of else block (signup form)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
