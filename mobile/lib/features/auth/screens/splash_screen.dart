import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app launch
///
/// Displays the Anchor logo while checking authentication status.
/// After a brief delay, navigates to either:
/// - Onboarding screen (if not authenticated)
/// - Home screen (if authenticated)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait 2 seconds then navigate based on auth status
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      // Check if user is authenticated
      final isAuthenticated = ref.read(isAuthenticatedProvider);

      // Navigate to appropriate screen
      if (isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.white,
      body: Stack(
        children: [
          // Gradient background - positioned to cover bottom portion only
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
          // Content centered on screen
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App stack icon from Figma
                Image.asset(
                  'assets/images/app_stack_icon.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Anchor',
                  style: AnchorTypography.displayLarge.copyWith(
                    color: AnchorColors.anchorSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
