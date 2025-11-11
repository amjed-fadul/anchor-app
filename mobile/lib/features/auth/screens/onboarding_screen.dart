import 'dart:async';
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
  late FixedExtentScrollController _scrollController;
  Timer? _autoScrollTimer;
  int _currentItem = 1000; // Start high for infinite scrolling

  // The three words in carousel order
  final List<Map<String, String>> _carouselItems = [
    {'word': 'Anchor', 'icon': 'assets/images/app_stack_icon.svg'},
    {'word': 'Instant', 'icon': 'assets/images/instant_icon.svg'},
    {'word': 'Find', 'icon': 'assets/images/find_icon.svg'},
  ];

  // Style constants
  static const double activeFontSize = 40.0;
  static const Color activeColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();

    // Initialize FixedExtentScrollController for ListWheelScrollView
    _scrollController = FixedExtentScrollController(initialItem: _currentItem);

    // Start auto-scroll timer
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _currentItem++;
      _scrollController.animateToItem(
        _currentItem,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
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
          // Content with iOS picker-style carousel
          SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                // iOS-style ListWheelScrollView carousel
                Positioned(
                  left: 0,
                  top: 140,
                  right: 0,
                  height: 300,
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 100.0, // Height of each item slot
                    diameterRatio: 1.5, // Controls curvature (smaller = more curved)
                    perspective: 0.003, // 3D depth effect
                    offAxisFraction: 0.0, // Keep items centered
                    useMagnifier: false, // We'll handle scaling manually
                    physics: const FixedExtentScrollPhysics(),
                    overAndUnderCenterOpacity: 0.3, // Fade out non-centered items to prevent text clashing
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: List.generate(_carouselItems.length, (index) {
                        final item = _carouselItems[index];
                        return Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                item['icon']!,
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['word']!,
                                style: const TextStyle(
                                  fontSize: activeFontSize,
                                  fontWeight: FontWeight.w700,
                                  color: activeColor,
                                  letterSpacing: -0.44,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    onSelectedItemChanged: (index) {
                      // Optional: track selected item
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
