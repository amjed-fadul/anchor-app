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

  // Position constants
  static const double topPosition = 180.0;
  static const double centerPosition = 262.0;
  static const double bottomPosition = 354.0;

  // Style constants
  static const double inactiveFontSize = 32.0;
  static const double activeFontSize = 40.0;
  static const Color activeColor = Color(0xFF1E1E1E);
  static const Color inactiveColor = Color(0xFFE9E9E9);

  @override
  void initState() {
    super.initState();

    // Set up animation controller for 6-second duration (2s per word)
    // Loop continuously
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 6000),
      vsync: this,
    )..repeat();
  }

  // Helper method to calculate position, size, color, and icon opacity for each word
  Map<String, dynamic> _getWordStyle(double animationValue, int wordIndex) {
    // wordIndex: 0=Anchor, 1=Instant, 2=Find
    // Determine which "cycle" position this word is in (0=center, 1=bottom, 2=top)

    // Calculate the offset for this word (each word starts at a different phase)
    double phase = (animationValue + (wordIndex / 3.0)) % 1.0;

    double position;
    double fontSize;
    Color color;
    double iconOpacity;

    // Smooth transitions using curves
    if (phase < 0.33) {
      // At center position
      position = centerPosition;
      fontSize = activeFontSize;
      color = activeColor;
      iconOpacity = 1.0;
    } else if (phase < 0.5) {
      // Transitioning from center to bottom
      double t = (phase - 0.33) / 0.17;
      t = Curves.easeInOutCubic.transform(t);
      position = centerPosition + (bottomPosition - centerPosition) * t;
      fontSize = activeFontSize + (inactiveFontSize - activeFontSize) * t;
      color = Color.lerp(activeColor, inactiveColor, t)!;
      iconOpacity = 1.0 - t;
    } else if (phase < 0.66) {
      // At bottom position
      position = bottomPosition;
      fontSize = inactiveFontSize;
      color = inactiveColor;
      iconOpacity = 0.0;
    } else if (phase < 0.66 + 0.17) {
      // Transitioning from bottom to top (with invisible wrap)
      double t = (phase - 0.66) / 0.17;
      t = Curves.easeInOutCubic.transform(t);
      // Fade out at bottom, fade in at top
      if (t < 0.5) {
        // Fading out at bottom
        position = bottomPosition;
        fontSize = inactiveFontSize;
        color = Color.lerp(inactiveColor, Colors.transparent, t * 2)!;
        iconOpacity = 0.0;
      } else {
        // Fading in at top
        position = topPosition;
        fontSize = inactiveFontSize;
        color = Color.lerp(Colors.transparent, inactiveColor, (t - 0.5) * 2)!;
        iconOpacity = 0.0;
      }
    } else {
      // Transitioning from top to center
      double t = (phase - (0.66 + 0.17)) / (1.0 - 0.66 - 0.17);
      t = Curves.easeInOutCubic.transform(t);
      position = topPosition + (centerPosition - topPosition) * t;
      fontSize = inactiveFontSize + (activeFontSize - inactiveFontSize) * t;
      color = Color.lerp(inactiveColor, activeColor, t)!;
      iconOpacity = t;
    }

    return {
      'position': position,
      'fontSize': fontSize,
      'color': color,
      'iconOpacity': iconOpacity,
    };
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
                // Animated carousel words
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final animValue = _animationController.value;

                    // Get styles for each word (0=Anchor, 1=Instant, 2=Find)
                    final anchorStyle = _getWordStyle(animValue, 0);
                    final instantStyle = _getWordStyle(animValue, 1);
                    final findStyle = _getWordStyle(animValue, 2);

                    return Stack(
                      children: [
                        // Anchor word
                        Positioned(
                          left: 37,
                          top: anchorStyle['position'],
                          child: Row(
                            children: [
                              // Icon (only visible when at center)
                              if (anchorStyle['iconOpacity'] > 0)
                                Opacity(
                                  opacity: anchorStyle['iconOpacity'],
                                  child: SvgPicture.asset(
                                    'assets/images/app_stack_icon.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                              if (anchorStyle['iconOpacity'] > 0)
                                const SizedBox(width: 12),
                              // Text
                              Text(
                                'Anchor',
                                style: TextStyle(
                                  fontSize: anchorStyle['fontSize'],
                                  fontWeight: anchorStyle['fontSize'] > 35
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: anchorStyle['color'],
                                  letterSpacing: anchorStyle['fontSize'] > 35
                                      ? -0.44
                                      : -0.352,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Instant word
                        Positioned(
                          left: 37,
                          top: instantStyle['position'],
                          child: Row(
                            children: [
                              // Icon (only visible when at center)
                              if (instantStyle['iconOpacity'] > 0)
                                Opacity(
                                  opacity: instantStyle['iconOpacity'],
                                  child: SvgPicture.asset(
                                    'assets/images/instant_icon.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                              if (instantStyle['iconOpacity'] > 0)
                                const SizedBox(width: 12),
                              // Text
                              Text(
                                'Instant',
                                style: TextStyle(
                                  fontSize: instantStyle['fontSize'],
                                  fontWeight: instantStyle['fontSize'] > 35
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: instantStyle['color'],
                                  letterSpacing: instantStyle['fontSize'] > 35
                                      ? -0.44
                                      : -0.352,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Find word
                        Positioned(
                          left: 37,
                          top: findStyle['position'],
                          child: Row(
                            children: [
                              // Icon (only visible when at center)
                              if (findStyle['iconOpacity'] > 0)
                                Opacity(
                                  opacity: findStyle['iconOpacity'],
                                  child: SvgPicture.asset(
                                    'assets/images/find_icon.svg',
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                              if (findStyle['iconOpacity'] > 0)
                                const SizedBox(width: 12),
                              // Text
                              Text(
                                'Find',
                                style: TextStyle(
                                  fontSize: findStyle['fontSize'],
                                  fontWeight: findStyle['fontSize'] > 35
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: findStyle['color'],
                                  letterSpacing: findStyle['fontSize'] > 35
                                      ? -0.44
                                      : -0.352,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
