import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';

/// Onboarding screen with animated text and gradient background
///
/// Shows the Anchor brand with animated "Instant" and "Find" text
/// that fades in sequentially, along with the tagline "Find It Anytime"
/// and a call-to-action button.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _instantOpacity;
  late Animation<double> _findOpacity;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for 2-second duration
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // "Instant" fades in from 0 to 1 second
    _instantOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // "Find" fades in from 0.5 to 1.5 seconds
    _findOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation automatically
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.white,
      body: Stack(
        children: [
          // Gradient background - positioned to cover bottom portion only (matches Figma)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).size.height * 0.4, // Start gradient 40% down
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 1.0],
                  colors: [
                    // White/transparent at top (where "Find" text is)
                    Colors.white.withValues(alpha: 0.0),
                    // Bright cyan/turquoise in middle
                    const Color(0xFF00D4AA),
                    // Bright lime green at bottom
                    const Color(0xFF00FF85),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                // "Instant" text - fades in first
                Positioned(
                  left: 37,
                  top: 180,
                  child: FadeTransition(
                    opacity: _instantOpacity,
                    child: Text(
                      'Instant',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE9E9E9), // Light gray
                        letterSpacing: -0.352,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                // Anchor brand (logo + text)
                Positioned(
                  left: 37,
                  top: 262,
                  child: Row(
                    children: [
                      // App stack icon SVG
                      SvgPicture.asset(
                        'assets/images/app_stack_icon.svg',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      // "Anchor" text
                      const Text(
                        'Anchor',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E1E), // Almost black
                          letterSpacing: -0.44,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // "Find" text - fades in second
                Positioned(
                  left: 37,
                  top: 354,
                  child: FadeTransition(
                    opacity: _findOpacity,
                    child: Text(
                      'Find',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE9E9E9), // Light gray
                        letterSpacing: -0.352,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),

                // App icon display
                Positioned(
                  left: 26,
                  top: 564,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50), // Anchor slate
                        ),
                      ),
                    ),
                  ),
                ),

                // "Find It Anytime" tagline
                Positioned(
                  left: 26,
                  top: 630,
                  child: Text(
                    'Find It\nAnytime',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AnchorColors.anchorSlate, // #2C3E50
                      letterSpacing: -0.22,
                      height: 1.2,
                    ),
                  ),
                ),

                // "Get Started" button - centered at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  top: 746,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to signup screen
                        context.go('/signup');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AnchorColors.anchorTeal,
                            height: 1.43, // 20px line height / 14px font size
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
