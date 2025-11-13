import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

      // CRITICAL FIX: Wait for auth state to update before navigating
      // Without this, the router's redirect() sees isAuthenticated: false
      // and redirects the user to /onboarding instead of /home!
      //
      // This is the same race condition we fixed in the password reset flow.
      // Supabase's signUp() returns immediately, but the auth state stream
      // takes a moment to emit the SIGNED_IN event. We must wait for it.
      await authService.authStateChanges
          .firstWhere(
            (state) => state.event == AuthChangeEvent.signedIn,
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Signup timeout: Auth state did not update');
            },
          );

      // If we reach here, signup was successful AND auth state has updated
      // User is automatically logged in by Supabase
      // Navigate to home screen
      if (mounted) {
        context.go('/home');
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
