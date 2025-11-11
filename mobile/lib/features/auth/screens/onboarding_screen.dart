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

  // Icon opacity animations for each word
  late Animation<double> _anchorIconOpacity;
  late Animation<double> _instantIconOpacity;
  late Animation<double> _findIconOpacity;

  // Text color animations for each word
  late Animation<Color?> _anchorTextColor;
  late Animation<Color?> _instantTextColor;
  late Animation<Color?> _findTextColor;

  @override
  void initState() {
    super.initState();

    // Set up animation controller for 6-second duration (2s per word)
    // Loop continuously
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();

    // Active color (dark) and inactive color (light gray)
    const activeColor = Color(0xFF1E1E1E);
    const inactiveColor = Color(0xFFE9E9E9);

    // ANCHOR animations (active 0.0-0.33)
    _anchorIconOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 57),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
    ]).animate(_animationController);

    _anchorTextColor = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: activeColor), weight: 33),
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: inactiveColor), weight: 5),
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: inactiveColor), weight: 57),
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: activeColor), weight: 5),
    ]).animate(_animationController);

    // INSTANT animations (active 0.33-0.66)
    _instantIconOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 28),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 29),
    ]).animate(_animationController);

    _instantTextColor = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: inactiveColor), weight: 28),
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: activeColor), weight: 5),
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: activeColor), weight: 33),
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: inactiveColor), weight: 5),
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: inactiveColor), weight: 29),
    ]).animate(_animationController);

    // FIND animations (active 0.66-1.0)
    _findIconOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 61),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 33),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(_animationController);

    _findTextColor = TweenSequence<Color?>([
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: inactiveColor), weight: 61),
      TweenSequenceItem(tween: ColorTween(begin: inactiveColor, end: activeColor), weight: 5),
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: activeColor), weight: 33),
      TweenSequenceItem(tween: ColorTween(begin: activeColor, end: inactiveColor), weight: 1),
    ]).animate(_animationController);
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
                // "Instant" text with animated icon and color
                Positioned(
                  left: 37,
                  top: 180,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Instant icon - fades in/out
                          Opacity(
                            opacity: _instantIconOpacity.value,
                            child: SvgPicture.asset(
                              'assets/images/instant_icon.svg',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          SizedBox(width: _instantIconOpacity.value > 0 ? 12 : 0),
                          // Instant text with animated color
                          Text(
                            'Instant',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: _instantTextColor.value,
                              letterSpacing: -0.352,
                              height: 1.2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // "Anchor" text with animated icon and color
                Positioned(
                  left: 37,
                  top: 262,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Anchor icon - fades in/out
                          Opacity(
                            opacity: _anchorIconOpacity.value,
                            child: SvgPicture.asset(
                              'assets/images/app_stack_icon.svg',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          SizedBox(width: _anchorIconOpacity.value > 0 ? 12 : 0),
                          // Anchor text with animated color
                          Text(
                            'Anchor',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: _anchorTextColor.value,
                              letterSpacing: -0.44,
                              height: 1.2,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // "Find" text with animated icon and color
                Positioned(
                  left: 37,
                  top: 354,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Find icon - fades in/out
                          Opacity(
                            opacity: _findIconOpacity.value,
                            child: SvgPicture.asset(
                              'assets/images/find_icon.svg',
                              width: 32,
                              height: 32,
                            ),
                          ),
                          SizedBox(width: _findIconOpacity.value > 0 ? 12 : 0),
                          // Find text with animated color
                          Text(
                            'Find',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: _findTextColor.value,
                              letterSpacing: -0.352,
                              height: 1.2,
                            ),
                          ),
                        ],
                      );
                    },
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
