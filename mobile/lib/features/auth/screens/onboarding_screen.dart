import 'dart:async';
import 'dart:ui' as ui;
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

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  Timer? _autoScrollTimer;

  // The three words in carousel order
  final List<Map<String, String>> _carouselItems = [
    {'word': 'Anchor', 'icon': 'assets/images/app_stack_icon.svg'},
    {'word': 'Instant', 'icon': 'assets/images/instant_icon.svg'},
    {'word': 'Find', 'icon': 'assets/images/find_icon.svg'},
  ];

  // Style constants
  static const double inactiveFontSize = 32.0;
  static const double activeFontSize = 40.0;
  static const Color activeColor = Color(0xFF1E1E1E);
  static const Color inactiveColor = Color(0xFFE9E9E9);

  @override
  void initState() {
    super.initState();

    // Initialize PageController with high initial page for infinite effect
    _pageController = PageController(
      initialPage: 999,
      viewportFraction: 0.4, // Show partial views of adjacent items
    );

    // Start auto-scroll timer
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        final nextPage = _pageController.page! + 1;
        _pageController.animateToPage(
          nextPage.toInt(),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
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
          // Content with carousel
          SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                // Vertical PageView carousel
                Positioned(
                  left: 37,
                  top: 180,
                  bottom: 400,
                  width: 320,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      final itemIndex = index % _carouselItems.length;
                      final item = _carouselItems[itemIndex];

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 0.0;
                          if (_pageController.position.haveDimensions) {
                            value = index.toDouble() - (_pageController.page ?? 0);
                          }

                          // Calculate scale and opacity based on distance from center
                          final double absValue = value.abs();
                          final double scale = ui.lerpDouble(1.0, 0.8, absValue.clamp(0.0, 1.0))!;
                          final double opacity = ui.lerpDouble(1.0, 0.3, absValue.clamp(0.0, 1.0))!;
                          final double fontSize = ui.lerpDouble(
                            activeFontSize,
                            inactiveFontSize,
                            absValue.clamp(0.0, 1.0),
                          )!;
                          final Color textColor = Color.lerp(
                            activeColor,
                            inactiveColor,
                            absValue.clamp(0.0, 1.0),
                          )!;

                          // Only show icon when item is centered
                          final bool showIcon = absValue < 0.2;

                          return Transform.scale(
                            scale: scale,
                            child: Opacity(
                              opacity: opacity,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon (only visible when centered)
                                    if (showIcon) ...[
                                      SvgPicture.asset(
                                        item['icon']!,
                                        width: 32,
                                        height: 32,
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    // Text
                                    Text(
                                      item['word']!,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: fontSize > 35
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: textColor,
                                        letterSpacing: fontSize > 35 ? -0.44 : -0.352,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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
