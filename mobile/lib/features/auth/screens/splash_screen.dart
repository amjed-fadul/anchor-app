import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      body: Container(
        // Horizontal gradient background: lime green to cyan
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.02, 0.81],
            colors: [
              Color(0xFF94F533), // Lime green at 2%
              Color(0xFF2AD0CA), // Cyan at 81%
            ],
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App stack icon SVG
              SvgPicture.asset(
                'assets/images/app_stack_icon.svg',
                width: 48,
                height: 48,
              ),
              const SizedBox(width: 16),
              Text(
                'Anchor',
                style: AnchorTypography.displayLarge.copyWith(
                  color: AnchorColors.white,
                  fontSize: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
