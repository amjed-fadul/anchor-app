import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and client initialization
///
/// This file handles:
/// - Loading Supabase credentials from .env file
/// - Initializing the Supabase client
/// - Providing a global client instance for the app
///
/// Usage:
/// ```dart
/// // After initialization in main.dart:
/// final user = supabase.auth.currentUser;
/// ```

/// Initialize Supabase
///
/// This should be called once at app startup in main.dart
/// before the app runs.
///
/// What it does:
/// 1. Loads environment variables from .env file
/// 2. Gets Supabase URL and anon key
/// 3. Initializes Supabase client
/// 4. Sets up authentication persistence
///
/// Example:
/// ```dart
/// Future<void> main() async {
///   await initializeSupabase();
///   runApp(MyApp());
/// }
/// ```
Future<void> initializeSupabase() async {
  // Load environment variables from .env file
  // This file contains your Supabase URL and anon key
  await dotenv.load(fileName: '.env');

  // Get credentials from environment variables
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // Validate that credentials exist
  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw Exception('SUPABASE_URL not found in .env file');
  }

  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw Exception('SUPABASE_ANON_KEY not found in .env file');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    // Auth options for persistence
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // More secure auth flow
      // autoRefreshToken: true is the default
      // persistSession: true is the default (keeps user logged in)

      // CRITICAL: Disable automatic deep link detection
      // Why: Supabase's automatic processing causes a race condition where
      // the router initializes before the auth state change event is emitted.
      // We handle deep links manually in DeepLinkService instead.
      detectSessionInUri: false,
    ),
  );
}

/// Global Supabase client instance
///
/// Use this throughout your app to access Supabase services.
///
/// Examples:
/// ```dart
/// // Get current user
/// final user = supabase.auth.currentUser;
///
/// // Sign in
/// await supabase.auth.signInWithPassword(
///   email: 'user@example.com',
///   password: 'password',
/// );
///
/// // Query database
/// final data = await supabase.from('spaces').select();
/// ```
SupabaseClient get supabase => Supabase.instance.client;
