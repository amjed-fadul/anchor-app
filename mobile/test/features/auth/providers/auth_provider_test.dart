/// Auth Provider Unit Tests
///
/// These tests verify that our Riverpod authentication providers work correctly.
/// Providers are the "glue" between services and UI - they make data available
/// to widgets and automatically update the UI when data changes.
///
/// 🎓 Learning: Testing Providers vs Testing Services
///
/// Real-World Analogy:
/// Imagine a restaurant:
/// - The kitchen (AuthService) prepares the food ← We tested this
/// - The waiter (Provider) brings food to customers ← We're testing THIS
/// - The customers (Widgets) consume the food ← We'll test this later
///
/// We need to test that the waiter brings the right food to the right table!
///
/// Why test providers?
/// - They transform data from services into formats widgets need
/// - They handle state changes and trigger UI rebuilds
/// - Critical logic lives here (like isRecoverySessionProvider!)

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/providers/auth_provider.dart';
import 'package:mobile/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../helpers/mock_supabase_client.dart';

/// Main test suite
void main() {
  /// ==========================================
  /// TEST GROUP: authServiceProvider
  /// ==========================================
  ///
  /// This provider creates an AuthService instance.
  /// We test that it can be overridden with a mock for testing.
  group('authServiceProvider', () {
    /// Test #1: Provider Can Be Overridden with Mock
    ///
    /// 🎓 Learning: Testing Provider Overrides
    ///
    /// In tests, we override providers with mocks instead of using
    /// real implementations. This test verifies that pattern works.
    ///
    /// Note: We can't test the real authServiceProvider without
    /// initializing Supabase, which we don't want to do in unit tests.
    /// Instead, we test that we CAN override it (which is what we do
    /// in all our other tests anyway).
    test('can be overridden with mock AuthService', () {
      // ARRANGE: Create a mock AuthService
      final mockAuthService = MockAuthService();

      // Create container with override
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );

      // Ensure container is disposed after test
      addTearDown(container.dispose);

      // ACT: Read the provider
      final authService = container.read(authServiceProvider);

      // ASSERT: Check it returns our mock
      expect(authService, equals(mockAuthService));
      expect(authService, isA<AuthService>());
    });
  });

  /// ==========================================
  /// TEST GROUP: currentUserProvider
  /// ==========================================
  ///
  /// This provider returns the currently logged-in user (or null).
  /// It depends on authStateProvider, which is a stream.
  group('currentUserProvider', () {
    /// Test Setup
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockAuthService mockAuthService;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockAuthService = MockAuthService();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    });

    /// Test #1: Returns Null When No User Logged In
    ///
    /// 🎓 Learning: Testing Derived State
    ///
    /// currentUserProvider doesn't talk to Supabase directly.
    /// It reads from authStateProvider, which reads from authService.
    ///
    /// To test this chain, we need to mock the entire flow:
    /// authService → authStateProvider → currentUserProvider
    test('returns null when user is not authenticated', () async {
      // ARRANGE: Create stream that emits "logged out" state
      //
      // When no one is logged in, Supabase emits an AuthState
      // with event=signedOut and session=null
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedOut,
          null, // No session = no user
        ),
      );

      // Mock the authService to return our stream
      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      // Create container with mocked authService
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      // ACT: Read the current user
      final user = container.read(currentUserProvider);

      // ASSERT: Should be null (no user logged in)
      expect(user, isNull);
    });

    /// Test #2: Returns User When Authenticated
    ///
    /// Now test the opposite: what happens when someone IS logged in?
    test('returns user when authenticated', () async {
      // ARRANGE: Create a mock user
      final mockUser = createMockUser(
        id: 'user-123',
        email: 'test@example.com',
      );

      final mockSession = createMockSession(user: mockUser);

      // Create stream with signedIn event and active session
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedIn,
          mockSession, // Has session = user is logged in
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Wait for the stream to emit
      //
      // 🎓 Learning: Async Provider Testing
      // StreamProviders are async. We need to wait for the stream
      // to emit a value before reading dependent providers.
      await container.read(authStateProvider.future);

      // ACT: Read the current user
      final user = container.read(currentUserProvider);

      // ASSERT: Should return our mock user
      expect(user, isNotNull);
      expect(user?.id, 'user-123');
      expect(user?.email, 'test@example.com');
    });
  });

  /// ==========================================
  /// TEST GROUP: isAuthenticatedProvider
  /// ==========================================
  ///
  /// This provider returns a simple true/false: is user logged in?
  /// It depends on currentUserProvider.
  group('isAuthenticatedProvider', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    /// Test #1: Returns False When Not Logged In
    test('returns false when user is not authenticated', () async {
      // ARRANGE: No user logged in
      final authStateStream = Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedOut, null),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final isAuthenticated = container.read(isAuthenticatedProvider);

      // ASSERT
      expect(isAuthenticated, false);
    });

    /// Test #2: Returns True When Logged In
    test('returns true when user is authenticated', () async {
      // ARRANGE: User logged in
      final mockUser = createMockUser();
      final mockSession = createMockSession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, mockSession),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final isAuthenticated = container.read(isAuthenticatedProvider);

      // ASSERT
      expect(isAuthenticated, true);
    });
  });

  /// ==========================================
  /// TEST GROUP: currentAuthEventProvider
  /// ==========================================
  ///
  /// This provider returns the current auth event type.
  /// Events: signedIn, signedOut, passwordRecovery, tokenRefreshed, etc.
  group('currentAuthEventProvider', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    /// Test #1: Returns SignedIn Event
    test('returns signedIn event when user logs in', () async {
      // ARRANGE
      final mockUser = createMockUser();
      final mockSession = createMockSession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedIn, // This is the event we're testing!
          mockSession,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final authEvent = container.read(currentAuthEventProvider);

      // ASSERT
      expect(authEvent, AuthChangeEvent.signedIn);
    });

    /// Test #2: Returns SignedOut Event
    test('returns signedOut event when user logs out', () async {
      // ARRANGE
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedOut, // Logged out event
          null,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final authEvent = container.read(currentAuthEventProvider);

      // ASSERT
      expect(authEvent, AuthChangeEvent.signedOut);
    });

    /// Test #3: Returns PasswordRecovery Event
    ///
    /// 🎓 Learning: THE CRITICAL TEST!
    ///
    /// This is THE event that determines password reset flow!
    /// When user clicks reset link in email, Supabase emits
    /// AuthChangeEvent.passwordRecovery instead of signedIn.
    ///
    /// This event is what we use to detect recovery sessions.
    test('returns passwordRecovery event when user clicks reset link', () async {
      // ARRANGE: Recovery session (user clicked email link)
      final mockUser = createMockUser();
      final mockSession = createMockRecoverySession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.passwordRecovery, // THE KEY EVENT!
          mockSession,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final authEvent = container.read(currentAuthEventProvider);

      // ASSERT: Must be passwordRecovery event
      expect(authEvent, AuthChangeEvent.passwordRecovery,
          reason: 'Password recovery event must be detected for reset flow to work!');
    });
  });

  /// ==========================================
  /// TEST GROUP: isRecoverySessionProvider
  /// ==========================================
  ///
  /// 🎓 Learning: THE MOST CRITICAL PROVIDER FOR PASSWORD RESET!
  ///
  /// This provider determines if the user has a recovery session.
  /// It's used by:
  /// - Router to decide where to navigate
  /// - UI to show appropriate screens
  /// - Logic to handle password reset vs normal login
  ///
  /// This provider fixed our password reset bug!
  ///
  /// Bug Before Fix:
  /// - User clicks reset link → router sees "authenticated" → redirects to /home
  /// - User can't reset password! 😱
  ///
  /// After Fix (This Provider!):
  /// - User clicks reset link → router checks isRecoverySessionProvider
  /// - Provider returns true → router navigates to /reset-password
  /// - User can reset password! 🎉
  group('isRecoverySessionProvider', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    /// Test #1: Returns True for Recovery Session
    ///
    /// THE CRITICAL TEST! This must pass for password reset to work.
    test('returns true when user has recovery session (clicked reset link)', () async {
      // ARRANGE: User clicked password reset link in email
      //
      // Supabase creates a special "recovery session" and emits
      // AuthChangeEvent.passwordRecovery instead of signedIn
      final mockUser = createMockUser();
      final mockRecoverySession = createMockRecoverySession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.passwordRecovery, // Recovery event!
          mockRecoverySession,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT: Check if this is a recovery session
      final isRecovery = container.read(isRecoverySessionProvider);

      // ASSERT: MUST be true!
      expect(isRecovery, true,
          reason: 'Must return true for recovery sessions or password reset will break!');
    });

    /// Test #2: Returns False for Normal Login
    ///
    /// When user logs in normally (not from reset link),
    /// this should return false.
    test('returns false when user logs in normally (not recovery)', () async {
      // ARRANGE: Normal login (not password reset)
      final mockUser = createMockUser();
      final mockSession = createMockSession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedIn, // Normal signedIn event (not passwordRecovery)
          mockSession,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final isRecovery = container.read(isRecoverySessionProvider);

      // ASSERT: Should be false (normal login, not recovery)
      expect(isRecovery, false,
          reason: 'Normal login should not be treated as recovery session');
    });

    /// Test #3: Returns False When Logged Out
    ///
    /// When no one is logged in, this should also be false.
    test('returns false when user is logged out', () async {
      // ARRANGE: No user logged in
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.signedOut,
          null, // No session
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final isRecovery = container.read(isRecoverySessionProvider);

      // ASSERT: Should be false (no user at all)
      expect(isRecovery, false);
    });

    /// Test #4: Returns False for Token Refresh Event
    ///
    /// 🎓 Learning: Other Auth Events
    ///
    /// Supabase emits various events:
    /// - signedIn: User logged in
    /// - signedOut: User logged out
    /// - passwordRecovery: User clicked reset link (recovery session!)
    /// - tokenRefreshed: Session token was refreshed
    /// - userUpdated: User profile was updated
    ///
    /// We only care about passwordRecovery for recovery sessions.
    /// All other events should return false.
    test('returns false for token refresh event', () async {
      // ARRANGE: Token refresh (not recovery)
      final mockUser = createMockUser();
      final mockSession = createMockSession(user: mockUser);
      final authStateStream = Stream<AuthState>.value(
        AuthState(
          AuthChangeEvent.tokenRefreshed, // Token refresh event
          mockSession,
        ),
      );

      when(() => mockAuthService.authStateChanges).thenAnswer((_) => authStateStream);

      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authStateProvider.future);

      // ACT
      final isRecovery = container.read(isRecoverySessionProvider);

      // ASSERT: Should be false (not a recovery event)
      expect(isRecovery, false);
    });
  });
}

/// 🎓 Learning Summary: What We Learned From These Tests
///
/// **Provider Testing Concepts:**
/// - Creating test ProviderContainers
/// - Overriding providers with mock implementations
/// - Testing provider dependencies (A depends on B depends on C)
/// - Handling async providers (StreamProvider)
/// - Using addTearDown to clean up containers
///
/// **Critical Provider: isRecoverySessionProvider**
/// - Detects AuthChangeEvent.passwordRecovery event
/// - Distinguishes recovery sessions from normal login
/// - Used by router to navigate correctly
/// - Fixed our password reset bug!
///
/// **What We're Testing:**
/// - ✅ authServiceProvider returns AuthService
/// - ✅ currentUserProvider returns user when logged in
/// - ✅ currentUserProvider returns null when logged out
/// - ✅ isAuthenticatedProvider returns true/false correctly
/// - ✅ currentAuthEventProvider detects different auth events
/// - ✅ isRecoverySessionProvider detects recovery sessions (CRITICAL!)
/// - ✅ isRecoverySessionProvider returns false for normal login
/// - ✅ isRecoverySessionProvider returns false when logged out
///
/// **Running these tests:**
/// ```bash
/// # Run just these tests
/// flutter test test/features/auth/providers/auth_provider_test.dart
///
/// # Run all tests
/// flutter test
/// ```
///
/// **Test Coverage:**
/// ✅ authServiceProvider: 1 test
/// ✅ currentUserProvider: 2 tests
/// ✅ isAuthenticatedProvider: 2 tests
/// ✅ currentAuthEventProvider: 3 tests
/// ✅ isRecoverySessionProvider: 4 tests (THE MOST IMPORTANT!)
/// ✅ Total: 12 new tests!
///
/// **Total Progress:**
/// ✅ Validators: 20 tests
/// ✅ AuthService: 11 tests
/// ✅ Router: 12 tests
/// ✅ Providers: 12 tests
/// ✅ **Total: 55 tests!** 🎉
///
/// **Why These Tests Matter:**
/// - Providers are the bridge between services and UI
/// - isRecoverySessionProvider is THE fix for our password reset bug
/// - These tests ensure the bug never comes back
/// - Testing provider chains ensures data flows correctly
///
/// **Next:**
/// Run these tests and watch them pass! Then on to widget tests.
