import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/onboarding_service.dart';

/// Unit tests for OnboardingService
///
/// Tests the onboarding tracking functionality:
/// - Check if user has seen onboarding (first time = false)
/// - Mark onboarding as seen (sets flag to true)
/// - Check again after marking (should be true)
///
/// Uses SharedPreferences for persistent storage across app restarts
void main() {
  // Set up test environment before each test
  setUp(() async {
    // Clear all SharedPreferences before each test
    // This ensures tests are isolated and don't affect each other
    SharedPreferences.setMockInitialValues({});
  });

  group('OnboardingService', () {
    test('hasSeenOnboarding returns false for first-time user', () async {
      // Arrange: Create service instance
      final service = OnboardingService();

      // Act: Check if user has seen onboarding
      final hasSeenOnboarding = await service.hasSeenOnboarding();

      // Assert: Should be false (first time user)
      expect(hasSeenOnboarding, false);
    });

    test('markOnboardingAsSeen sets the flag to true', () async {
      // Arrange: Create service instance
      final service = OnboardingService();

      // Act: Mark onboarding as seen
      await service.markOnboardingAsSeen();

      // Assert: Check the flag was set
      final hasSeenOnboarding = await service.hasSeenOnboarding();
      expect(hasSeenOnboarding, true);
    });

    test('hasSeenOnboarding persists across service instances', () async {
      // Arrange: Create first service instance and mark onboarding as seen
      final service1 = OnboardingService();
      await service1.markOnboardingAsSeen();

      // Act: Create a NEW service instance (simulates app restart)
      final service2 = OnboardingService();
      final hasSeenOnboarding = await service2.hasSeenOnboarding();

      // Assert: Flag should still be true (persisted)
      expect(hasSeenOnboarding, true);
    });

    test('hasSeenOnboarding returns true when flag is set', () async {
      // Arrange: Manually set the SharedPreferences value
      // (simulates existing data from previous app session)
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
      });
      final service = OnboardingService();

      // Act: Check if user has seen onboarding
      final hasSeenOnboarding = await service.hasSeenOnboarding();

      // Assert: Should be true (flag was already set)
      expect(hasSeenOnboarding, true);
    });

    test('hasSeenOnboarding returns false when flag is explicitly false', () async {
      // Arrange: Manually set the SharedPreferences value to false
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': false,
      });
      final service = OnboardingService();

      // Act: Check if user has seen onboarding
      final hasSeenOnboarding = await service.hasSeenOnboarding();

      // Assert: Should be false
      expect(hasSeenOnboarding, false);
    });
  });
}
