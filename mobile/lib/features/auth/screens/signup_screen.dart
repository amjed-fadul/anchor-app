import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';

/// Signup landing screen
///
/// First screen in the signup flow where users choose how to sign up:
/// - Continue with email (navigates to email form)
/// - Continue with Google (OAuth)
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background: green at top fading to white at bottom
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6],
            colors: [
              Color(0xFF2AD0CA), // Teal/cyan green
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top section with logo and tagline
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  children: [
                    // Anchor logo
                    SvgPicture.asset(
                      'assets/images/app_stack_icon.svg',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Find It Anytime',
                      style: AnchorTypography.bodyLarge.copyWith(
                        color: const Color(0xFF2C3E50), // Dark slate
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Main content
              Padding(
                padding: AnchorSpacing.screenPadding,
                child: Column(
                  children: [
                    // "Create an Account" heading
                    Text(
                      'Create an\nAccount',
                      style: AnchorTypography.displayLarge.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontSize: 48,
                        height: 1.2,
                        letterSpacing: -0.528,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Continue with email button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6400CD).withValues(alpha: 0.16),
                            offset: const Offset(0, 12),
                            blurRadius: 12,
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.push('/signup/email');
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Continue with email',
                              style: AnchorTypography.bodyLarge.copyWith(
                                color: AnchorColors.anchorTeal,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    // Continue with Google button
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC7C5CC), // Light gray border
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement Google sign-in
                            // Will connect to authService.signInWithGoogle()
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Google sign-in coming soon!'),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google icon placeholder
                              // TODO: Add actual Google icon
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Continue with Google',
                                style: AnchorTypography.bodyLarge.copyWith(
                                  color: const Color(0xFF2C3E50),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Footer - Sign in link
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Text(
                      'Already have an account?',
                      style: AnchorTypography.bodyMedium.copyWith(
                        color: const Color(0xFF2C3E50),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        context.go('/login');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Sign in here',
                        style: AnchorTypography.bodyMedium.copyWith(
                          color: const Color(0xFF2C3E50),
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
    );
  }
}
