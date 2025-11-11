import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// Utilities for showing snackbar messages (toast notifications)
///
/// These are temporary messages that appear at the bottom of the screen
/// and automatically disappear after a few seconds.
///
/// Example:
/// ```dart
/// SnackbarUtils.showSuccess(
///   context,
///   'Account created successfully!',
/// );
/// ```
class SnackbarUtils {
  // Private constructor to prevent instantiation
  SnackbarUtils._();

  /// Show a success message (green background)
  ///
  /// Use this for positive actions like:
  /// - Account created
  /// - Link saved
  /// - Settings updated
  static void showSuccess(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AnchorColors.success,
      icon: Icons.check_circle,
    );
  }

  /// Show an error message (red background)
  ///
  /// Use this for errors like:
  /// - Login failed
  /// - Network error
  /// - Invalid input
  static void showError(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AnchorColors.error,
      icon: Icons.error,
    );
  }

  /// Show an info message (blue background)
  ///
  /// Use this for informational messages like:
  /// - Password reset link sent
  /// - Check your email
  /// - Loading complete
  static void showInfo(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AnchorColors.info,
      icon: Icons.info,
    );
  }

  /// Show a warning message (orange background)
  ///
  /// Use this for warnings like:
  /// - Unsaved changes
  /// - Slow connection
  /// - Feature unavailable
  static void showWarning(BuildContext context, String message) {
    _showSnackbar(
      context,
      message,
      backgroundColor: AnchorColors.warning,
      icon: Icons.warning,
    );
  }

  /// Internal method to show the snackbar
  static void _showSnackbar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove any existing snackbar first
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // Show the new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: AnchorColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AnchorTypography.bodyMedium.copyWith(
                  color: AnchorColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AnchorSpacing.radiusMD,
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: AnchorColors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
