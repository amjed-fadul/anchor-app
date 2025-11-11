import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// Splash screen shown on app launch
///
/// Displays the Anchor logo while checking authentication status.
/// After a brief delay, navigates to either:
/// - Onboarding screen (if not authenticated)
/// - Home screen (if authenticated)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder (we'll add actual logo later)
            Icon(
              Icons.anchor,
              size: 80,
              color: AnchorColors.anchorTeal,
            ),
            AnchorSpacing.verticalSpaceMD,
            Text(
              'Anchor',
              style: AnchorTypography.displayLarge.copyWith(
                color: AnchorColors.anchorTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
