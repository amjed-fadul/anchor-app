import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// A full-screen loading overlay
///
/// Use this when you want to block all user interaction
/// while something is loading (like signing in, creating account, etc.)
///
/// Example:
/// ```dart
/// if (isLoading) {
///   return const LoadingOverlay();
/// }
/// ```
class LoadingOverlay extends StatelessWidget {
  /// Optional message to show below the spinner
  final String? message;

  const LoadingOverlay({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AnchorColors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular loading spinner
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AnchorColors.anchorTeal,
              ),
            ),

            // Optional message
            if (message != null) ...[
              AnchorSpacing.verticalMd,
              Text(
                message!,
                style: AnchorTypography.bodyMedium.copyWith(
                  color: AnchorColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small inline loading indicator
///
/// Use this for inline loading states (like inside a button).
///
/// Example:
/// ```dart
/// child: isLoading ? const LoadingIndicator() : const Text('Submit')
/// ```
class LoadingIndicator extends StatelessWidget {
  /// Size of the spinner
  final double size;

  /// Color of the spinner
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AnchorColors.anchorTeal,
        ),
      ),
    );
  }
}
