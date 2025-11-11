import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// A widget for displaying error messages with optional retry
///
/// Use this when an API call fails or something goes wrong.
///
/// Example:
/// ```dart
/// if (hasError) {
///   return ErrorView(
///     message: 'Failed to load data',
///     onRetry: () => fetchData(),
///   );
/// }
/// ```
class ErrorView extends StatelessWidget {
  /// The error message to display
  final String message;

  /// Optional callback when user taps retry button
  final VoidCallback? onRetry;

  /// Optional icon to show above the message
  final IconData icon;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AnchorSpacing.screenPadding,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              icon,
              size: 64,
              color: AnchorColors.error,
            ),
            AnchorSpacing.verticalMd,

            // Error message
            Text(
              message,
              style: AnchorTypography.bodyLarge.copyWith(
                color: AnchorColors.gray700,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button (if callback provided)
            if (onRetry != null) ...[
              AnchorSpacing.verticalLg,
              AnchorButton(
                label: 'Try Again',
                onPressed: onRetry!,
                type: AnchorButtonType.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A compact error message widget for inline use
///
/// Use this for showing errors within a form or smaller section.
///
/// Example:
/// ```dart
/// if (hasError) {
///   return ErrorMessage(message: 'Invalid email address');
/// }
/// ```
class ErrorMessage extends StatelessWidget {
  /// The error message to display
  final String message;

  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AnchorColors.error.withOpacity(0.1),
        borderRadius: AnchorSpacing.radiusMd,
        border: Border.all(
          color: AnchorColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: AnchorColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AnchorTypography.bodyMedium.copyWith(
                color: AnchorColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
