/// Test Provider Helpers for Riverpod
///
/// This file helps us test Riverpod providers and widgets that use providers.
/// Riverpod is our state management system, so we need special helpers to
/// test it properly.
///
/// Real-World Analogy:
/// Think of providers like electrical outlets in a house. Normally, widgets
/// "plug in" to real providers to get their data. In tests, we want to use
/// "fake outlets" (test providers) that give us controlled, predictable data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';

/// Creates a ProviderContainer for testing
///
/// A ProviderContainer is like a "box" that holds all your providers.
/// In tests, we create our own box with fake providers so we can control
/// what data widgets receive.
///
/// Parameters:
/// - overrides: List of providers to replace with test versions
///
/// Example usage:
/// ```dart
/// final container = createTestProviderContainer(
///   overrides: [
///     authServiceProvider.overrideWithValue(mockAuthService),
///   ],
/// );
/// ```
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(
    overrides: overrides,
  );
}

/// Creates a ProviderScope widget for widget testing
///
/// When testing widgets that use providers, we need to wrap them in a
/// ProviderScope. This is like creating a "test environment" where our
/// widget can access the fake providers we set up.
///
/// Parameters:
/// - child: The widget you're testing
/// - overrides: Providers to replace with test versions
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(
///   createTestProviderScope(
///     overrides: [
///       authServiceProvider.overrideWithValue(mockAuthService),
///     ],
///     child: LoginScreen(),
///   ),
/// );
/// ```
Widget createTestProviderScope({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Creates a test-friendly AuthService
///
/// In real code, AuthService talks to Supabase. In tests, we want to control
/// exactly what it returns without hitting real servers.
///
/// This is a mock that you can configure in your tests.
///
/// Example usage:
/// ```dart
/// final mockAuthService = createMockAuthService();
/// // Configure what methods should return
/// when(() => mockAuthService.updatePassword(newPassword: any(named: 'newPassword')))
///     .thenAnswer((_) async => {});
/// ```
///
/// NOTE: This returns a real class you need to mock with mocktail separately.
/// This helper is here to document the pattern, not to create the mock itself.
/// See auth_service_test.dart for examples of actually mocking AuthService.

/// Test Helpers for Auth State
///
/// These helpers create fake auth states for testing different scenarios.

/// Creates a mock "logged in" auth state
///
/// Use this when you need to test what happens when a user is logged in.
///
/// Example:
/// ```dart
/// final container = createTestProviderContainer(
///   overrides: [
///     authStateProvider.overrideWith(
///       (ref) => Stream.value(createLoggedInAuthState()),
///     ),
///   ],
/// );
/// ```
// Note: We can't easily mock AuthState here since it's from Supabase
// Instead, in actual tests, we'll override the authServiceProvider directly

/// Common Provider Overrides for Different Test Scenarios
///
/// These are pre-configured sets of overrides for common testing situations.

/// Get overrides for a "logged out" user test scenario
///
/// Use this when testing what happens for unauthenticated users.
///
/// Example:
/// ```dart
/// await tester.pumpWidget(
///   createTestProviderScope(
///     overrides: getLoggedOutOverrides(mockAuthService),
///     child: LoginScreen(),
///   ),
/// );
/// ```
List<Override> getLoggedOutOverrides(AuthService mockAuthService) {
  return [
    authServiceProvider.overrideWithValue(mockAuthService),
    // Add more overrides as needed
  ];
}

/// Get overrides for a "logged in" user test scenario
///
/// Use this when testing authenticated user functionality.
List<Override> getLoggedInOverrides(AuthService mockAuthService) {
  return [
    authServiceProvider.overrideWithValue(mockAuthService),
    // Add more overrides as needed
  ];
}

/// Get overrides for a "recovery session" test scenario
///
/// Use this when testing the password reset flow where user
/// has a temporary session from clicking email link.
List<Override> getRecoverySessionOverrides(AuthService mockAuthService) {
  return [
    authServiceProvider.overrideWithValue(mockAuthService),
    // Add more overrides as needed
  ];
}

/// Pumps a widget and waits for all async operations to complete
///
/// In Flutter tests, async operations don't complete immediately.
/// This helper pumps the widget (renders it) and then waits for
/// all pending operations to finish.
///
/// Use this instead of tester.pump() when your widget does async work.
///
/// Example:
/// ```dart
/// await pumpAndSettle(tester, MyWidget());
/// // Now you can verify the widget's final state
/// ```
Future<void> pumpAndSettle(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle(); // Wait for all animations and async work
}
