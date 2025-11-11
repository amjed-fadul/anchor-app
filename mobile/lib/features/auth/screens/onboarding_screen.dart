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
///
/// RESPONSIVE: Uses Column with Spacer for flexible layout across all device sizes
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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

          // Content with iOS picker-style carousel - RESPONSIVE LAYOUT
          SafeArea(
            child: Column(
              children: [
                // Top spacing - flexible (reduced for small screens)
                const Spacer(flex: 1),

                // iOS-style ListWheelScrollView carousel - fixed height (reduced for small screens)
                SizedBox(
                  height: 280,
                  child: ClipRect(
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 120.0, // Height of each item slot
                      diameterRatio: 1.5, // Controls curvature
                      perspective: 0.003, // 3D depth effect
                      offAxisFraction: 0.0, // Keep items centered
                      useMagnifier: false,
                      physics: const FixedExtentScrollPhysics(),
                      overAndUnderCenterOpacity: 0.01, // Nearly invisible
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
                ),

                // Middle spacing - flexible (reduced to ensure button visibility on small screens)
                const Spacer(flex: 2),

                // App icon and tagline - left-aligned
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App icon
                        Container(
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

                        const SizedBox(height: 16),

                        // "Find It Anytime" tagline
                        Text(
                          'Find It\nAnytime',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: AnchorColors.anchorSlate, // #2C3E50
                            letterSpacing: -0.22,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom spacing - flexible (smaller to keep button visible)
                const Spacer(flex: 1),

                // "Get Started" button - always visible
                Center(
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

                // Fixed bottom padding to ensure button doesn't touch bottom edge
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
