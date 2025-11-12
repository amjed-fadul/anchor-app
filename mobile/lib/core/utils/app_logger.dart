library;

/// Application Logger
///
/// Provides centralized logging for the entire app.
/// Uses the logger package for better debugging with log levels.
///
/// **Benefits:**
/// - Multiple log levels (verbose, debug, info, warning, error)
/// - Pretty printing with colors in development
/// - Can be disabled in production builds
/// - Better than using print() statements
///
/// **Usage:**
/// ```dart
/// import 'package:mobile/core/utils/app_logger.dart';
///
/// // Debug level - for detailed debugging information
/// logger.d('User tapped button');
///
/// // Info level - for general information
/// logger.i('Password reset email sent');
///
/// // Warning level - for potential issues
/// logger.w('Session about to expire');
///
/// // Error level - for errors
/// logger.e('Failed to load data', error: e, stackTrace: stackTrace);
/// ```
///
/// **Log Levels:**
/// - `verbose` - Very detailed logs (not typically used)
/// - `debug` - Debugging information (most common)
/// - `info` - General informational messages
/// - `warning` - Warning messages for potential issues
/// - `error` - Error messages
/// - `wtf` - "What a Terrible Failure" - severe unexpected errors

import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Global logger instance
///
/// This is the logger you'll use throughout the app.
/// It's configured to show different levels based on build mode.
final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Don't include stack trace for cleaner logs
    errorMethodCount: 5, // Include stack trace for errors
    lineLength: 80, // Width of output
    colors: true, // Colorful logs in terminal
    printEmojis: true, // Include emojis for better visibility
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Show timestamp
  ),
  level: kDebugMode
      ? Level.debug // Show debug logs in development
      : Level.info, // Show only info and above in production
);

/// Debug logger for development-only logs
///
/// These logs will ONLY show in debug builds (when running from IDE).
/// Use this for verbose debugging that you don't want in production.
///
/// Example:
/// ```dart
/// debugLogger.d('Detailed debugging info here');
/// ```
final debugLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
  level: kDebugMode ? Level.trace : Level.off,
);
