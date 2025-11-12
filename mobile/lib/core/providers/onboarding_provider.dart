import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/onboarding_service.dart';

/// Provider for the OnboardingService instance
///
/// This creates a single instance of OnboardingService that's shared
/// across the entire app.
///
/// Usage:
/// ```dart
/// // In a ConsumerWidget or ConsumerStatefulWidget:
/// final onboardingService = ref.read(onboardingServiceProvider);
///
/// // Check if user has seen onboarding
/// final hasSeenIt = await onboardingService.hasSeenOnboarding();
///
/// // Mark onboarding as seen
/// await onboardingService.markOnboardingAsSeen();
/// ```
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});
