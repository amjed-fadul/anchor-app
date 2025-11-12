import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app launch
///
/// Displays the Anchor logo while checking authentication status.
/// After a brief delay, navigates to one of:
/// - Reset password screen (if recovery session from email link)
/// - Home screen (if authenticated normally)
/// - Onboarding screen (if not authenticated)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;
  Timer? _minimumDisplayTimer;
  Timer? _maximumTimeoutTimer;

  @override
  void initState() {
    super.initState();

    print('🔷 [SPLASH] Initializing splash screen');

    // CRITICAL FIX: Use event-driven navigation instead of fixed timer
    // This prevents race condition when deep links arrive while app is running
    //
    // **The Problem:**
    // When a password reset link arrives while the app is ALREADY RUNNING:
    // - Deep link processing starts (network call to exchange PKCE code)
    // - Old fixed 2-second timer completes before session is created
    // - Splash navigates to /onboarding (wrong!) because session doesn't exist yet
    // - Session creation completes (too late)
    //
    // **The Solution:**
    // - Listen for auth state changes (emitted when session is created)
    // - Navigate when auth state stabilizes (after session exists)
    // - Keep 1-second minimum for branding (UX)
    // - Add 5-second maximum timeout as fallback
    //
    // **How it works:**
    // 1. Minimum timer (1s) ensures we show splash for branding
    // 2. Auth state listener waits for session creation from deep link
    // 3. When both conditions met → navigate to correct screen
    // 4. Maximum timer (5s) prevents getting stuck if auth state never settles

    // Minimum display time for branding (1 second)
    _minimumDisplayTimer = Timer(const Duration(seconds: 1), () {
      print('🔷 [SPLASH] Minimum display time elapsed (1s)');
      // Check if we should navigate now (if auth state already settled)
      _checkAndNavigate();
    });

    // Maximum timeout to prevent getting stuck (5 seconds)
    _maximumTimeoutTimer = Timer(const Duration(seconds: 5), () {
      print('🔷 [SPLASH] ⚠️ Maximum timeout reached (5s), forcing navigation');
      _navigate();
    });

    // Listen for auth state changes (triggered when session is created from deep link)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(
        authStateProvider,
        (previous, next) {
          print('🔷 [SPLASH] Auth state changed');
          print('  - Previous: ${previous?.valueOrNull?.event}');
          print('  - Next: ${next.valueOrNull?.event}');

          // When auth state changes, check if we should navigate
          next.whenData((authState) {
            _checkAndNavigate();
          });
        },
      );

      // Also check immediately in case auth state is already available
      // (for normal app launches, not from deep link)
      final currentAuthState = ref.read(authStateProvider);
      if (currentAuthState.hasValue) {
        print('🔷 [SPLASH] Auth state already available on init');
        _checkAndNavigate();
      }
    });
  }

  /// Check if we should navigate based on timing and auth state
  void _checkAndNavigate() {
    // Only navigate if minimum display time has elapsed
    if (_minimumDisplayTimer?.isActive ?? true) {
      print('🔷 [SPLASH] Waiting for minimum display time');
      return;
    }

    // Navigate now
    _navigate();
  }

  /// Navigate to appropriate screen based on auth state
  void _navigate() {
    // Prevent duplicate navigation
    if (_hasNavigated || !mounted) {
      return;
    }

    _hasNavigated = true;

    // Cancel timers
    _minimumDisplayTimer?.cancel();
    _maximumTimeoutTimer?.cancel();

    print('🔷 [SPLASH] Navigation decision time');

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    print('  - isAuthenticated: $isAuthenticated');

    final isRecovery = ref.read(isRecoverySessionProvider);
    print('  - isRecovery: $isRecovery');

    // Navigate to appropriate screen
    if (isAuthenticated) {
      if (isRecovery) {
        // Recovery session: take user to reset password screen
        print('  ✅ Navigating to /reset-password (recovery session)');
        context.go('/reset-password');
      } else {
        // Normal authenticated session: go to home
        print('  ✅ Navigating to /home (normal session)');
        context.go('/home');
      }
    } else {
      // Not authenticated: go to onboarding
      print('  ✅ Navigating to /onboarding (not authenticated)');
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _minimumDisplayTimer?.cancel();
    _maximumTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Clean white background instead of gradient
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App stack icon SVG - slightly larger
            SvgPicture.asset(
              'assets/images/app_stack_icon.svg',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 16),
            // Dark text instead of white, with tighter letter spacing
            Text(
              'Anchor',
              style: AnchorTypography.displayLarge.copyWith(
                color: const Color(0xFF1E1E1E), // Dark gray
                fontSize: 40, // Reduced from 48
                letterSpacing: -0.44, // Tighter spacing
              ),
            ),
          ],
        ),
      ),
    );
  }
}
