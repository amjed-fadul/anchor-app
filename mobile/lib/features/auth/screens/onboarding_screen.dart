import 'package:flutter/material.dart';
import '../../../design_system/design_system.dart';

/// Onboarding carousel screen
///
/// Shows 3 cards explaining the app:
/// 1. Save Anywhere
/// 2. Organize Visually
/// 3. Find Instantly
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Onboarding',
              style: AnchorTypography.displaySmall,
            ),
            AnchorSpacing.verticalSpaceMD,
            Text(
              'We\'ll build the carousel here',
              style: AnchorTypography.bodyMedium.copyWith(
                color: AnchorColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
