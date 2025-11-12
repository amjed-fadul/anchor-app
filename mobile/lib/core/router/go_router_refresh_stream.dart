import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts a Stream to a ChangeNotifier (Listenable) for GoRouter
///
/// GoRouter's `refreshListenable` parameter only accepts Listenable objects,
/// not Streams. This class bridges that gap by converting any Stream into
/// a ChangeNotifier that GoRouter can listen to.
///
/// **Why This Is Needed:**
/// - GoRouter needs to refresh its redirect logic when auth state changes
/// - But we don't want to rebuild the entire router (causes navigation issues)
/// - Solution: Use `refreshListenable` to listen for changes without rebuilding
///
/// **How It Works:**
/// 1. Takes any Stream as input
/// 2. Listens to the stream
/// 3. Calls `notifyListeners()` whenever stream emits a new value
/// 4. GoRouter receives notification and re-runs redirect logic
/// 5. No router rebuild = smooth navigation!
///
/// **Usage:**
/// ```dart
/// final refreshListenable = GoRouterRefreshStream(
///   authStateProvider.stream,
/// );
///
/// GoRouter(
///   refreshListenable: refreshListenable,
///   redirect: (context, state) {
///     // This runs whenever stream emits, without rebuilding router
///   },
/// );
/// ```
///
/// **Real-World Analogy:**
/// Think of this like a doorbell:
/// - The Stream is people arriving at your door (auth events)
/// - The ChangeNotifier is the doorbell button
/// - GoRouter is you inside the house
/// - When someone arrives (stream emits), they press the doorbell (notifyListeners)
/// - You hear the bell (GoRouter refreshes) without rebuilding the house!
///
/// **Technical Details:**
/// - Extends ChangeNotifier (Flutter's Listenable implementation)
/// - Uses StreamSubscription to listen to the stream
/// - Converts stream to broadcast stream to allow multiple listeners
/// - Properly disposes subscription to prevent memory leaks
///
/// **Based On:**
/// This is a standard Flutter pattern recommended by:
/// - GoRouter documentation
/// - Riverpod + GoRouter best practices (Q Agency, 2024)
/// - Community solutions for auth state management
class GoRouterRefreshStream extends ChangeNotifier {
  /// Stream subscription that listens to auth state changes
  late final StreamSubscription<dynamic> _subscription;

  /// Creates a listenable from a stream
  ///
  /// **Parameters:**
  /// - `stream`: Any stream (typically auth state stream)
  ///
  /// **What Happens:**
  /// 1. Immediately calls notifyListeners() (initial notification)
  /// 2. Converts stream to broadcast (allows multiple listeners)
  /// 3. Listens to stream
  /// 4. On each stream event, calls notifyListeners()
  /// 5. GoRouter receives notification and refreshes
  ///
  /// **Example:**
  /// ```dart
  /// // Auth state stream from Supabase
  /// final authStream = supabase.auth.onAuthStateChange;
  ///
  /// // Convert to listenable
  /// final listenable = GoRouterRefreshStream(authStream);
  ///
  /// // Pass to GoRouter
  /// GoRouter(refreshListenable: listenable);
  /// ```
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Notify immediately when created (initial state)
    notifyListeners();

    // Listen to the stream
    _subscription = stream.asBroadcastStream().listen(
      // On each stream event, notify GoRouter to refresh
      (dynamic _) => notifyListeners(),
    );
  }

  /// Clean up the stream subscription when this object is disposed
  ///
  /// **Why This Matters:**
  /// - Prevents memory leaks
  /// - Stops listening to stream when no longer needed
  /// - Called automatically by Flutter when widget is disposed
  ///
  /// **When This Happens:**
  /// - When the app closes
  /// - When the router is replaced (shouldn't happen with our fix!)
  /// - When the provider holding this is disposed
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
