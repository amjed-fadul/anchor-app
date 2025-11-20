import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../shared/utils/error_message_helper.dart';
import '../../../shared/utils/validators.dart';
import '../../../shared/widgets/error_view.dart';
import '../providers/auth_provider.dart';

/// Login screen
///
/// Allows existing users to sign in with email and password.
/// On successful login, user is automatically navigated to home screen.
///
/// Features:
/// - Email and password fields with validation
/// - "Forgot password?" link
/// - Loading state during login
/// - Error message display
/// - "Sign up" link for new users
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  // Error message
  String? _errorMessage;

  // Field-specific error messages
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validate all fields
  bool _validateFields() {
    setState(() {
      _emailError = Validators.email(_emailController.text);
      _passwordError = Validators.password(_passwordController.text);
    });

    return _emailError == null && _passwordError == null;
  }

  /// Handle form submission
  Future<void> _handleLogin() async {
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

      // Attempt to sign in
      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // SUCCESS: User is logged in
      // Let the router's refreshListenable handle navigation automatically
      // The auth state change will trigger router redirect to /home
      // No manual navigation needed!

      // Just clear loading state - router will handle the rest
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle login errors
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorMessageHelper.getReadableMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        // No back button - prevents confusing navigation to onboarding
        // Users can navigate using "Sign up" link at bottom if needed
        automaticallyImplyLeading: false,
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
                  'Welcome back',
                  style: AnchorTypography.headlineMedium.copyWith(
                    color: AnchorColors.anchorSlate,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to your account to continue',
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
                  prefixIcon: SvgPicture.asset(
                    'assets/images/mail-02.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                  hintText: 'Enter your password',
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

                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            context.push('/forgot-password');
                          },
                    child: Text(
                      'Forgot password?',
                      style: AnchorTypography.bodySmall.copyWith(
                        color: AnchorColors.anchorTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Error message display
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessage(message: _errorMessage!),
                ],

                const SizedBox(height: 24),

                // Sign in button
                AnchorButton(
                  label: 'Sign In',
                  onPressed: _isLoading ? null : _handleLogin,
                  isLoading: _isLoading,
                  fullWidth: true,
                  size: AnchorButtonSize.large,
                ),

                const SizedBox(height: 24),

                // Sign up link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AnchorTypography.bodyMedium.copyWith(
                          color: AnchorColors.gray600,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.go('/signup');
                              },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign up',
                          style: AnchorTypography.bodyMedium.copyWith(
                            color: AnchorColors.anchorTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
