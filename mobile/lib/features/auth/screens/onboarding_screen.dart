import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../core/providers/onboarding_provider.dart';

/// Onboarding screen with animated carousel and synchronized descriptions
///
/// Features:
/// - Carousel with 3 words: "Anchor", "Instant", "Find" (with icons)
/// - Description text that changes in sync with carousel
/// - Smooth fade transitions between descriptions
/// - Gradient background (teal to green)
/// - "Get Started" call-to-action button
///
/// RESPONSIVE: Uses Column with Spacer for flexible layout across all device sizes
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late FixedExtentScrollController _scrollController;
  Timer? _autoScrollTimer;
  int _currentItem = 1000; // Start high for infinite scrolling
  int _currentDescriptionIndex = 0; // Track current description for text sync

  // The three words in carousel order with their descriptions
  final List<Map<String, String>> _carouselItems = [
    {
      'word': 'Anchor',
      'icon': 'assets/images/app_stack_icon.svg',
      'description': 'Not just saving links, creating anchors you can always return to.',
    },
    {
      'word': 'Instant',
      'icon': 'assets/images/instant_icon.svg',
      'description': 'Save from any app. Find it anytime. Add context when you have time.',
    },
    {
      'word': 'Find',
      'icon': 'assets/images/find_icon.svg',
      'description': 'Create collections that make sense to you. Everything stays where you put it.',
    },
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
                        // Sync description text with carousel position
                        setState(() {
                          _currentDescriptionIndex = index % _carouselItems.length;
                        });
                      },
                    ),
                  ),
                ),

                // Middle spacing - flexible (reduced to ensure button visibility on small screens)
                const Spacer(flex: 2),

                // Dynamic description text - synced with carousel
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: Text(
                        _carouselItems[_currentDescriptionIndex]['description']!,
                        key: ValueKey(_currentDescriptionIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2C3E50), // Anchor slate
                          letterSpacing: -0.2,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom spacing - flexible (smaller to keep button visible)
                const Spacer(flex: 1),

                // "Get Started" button - always visible
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      // Capture router before async operation to avoid context issues
                      final router = GoRouter.of(context);

                      // Mark onboarding as seen (so it won't show again)
                      final onboardingService = ref.read(onboardingServiceProvider);
                      await onboardingService.markOnboardingAsSeen();

                      // Navigate to signup screen using captured router
                      if (mounted) {
                        router.go('/signup');
                      }
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
