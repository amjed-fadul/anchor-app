import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../typography/typography.dart';
import '../spacing/spacing.dart';

/// A custom text field widget that follows Anchor's design system.
///
/// This widget provides:
/// - Outlined border style (matches design system)
/// - Password visibility toggle for password fields
/// - Error state styling
/// - Consistent spacing and typography
///
/// Example usage:
/// ```dart
/// AnchorTextField(
///   label: 'Email',
///   hintText: 'Enter your email',
///   keyboardType: TextInputType.emailAddress,
///   onChanged: (value) => print(value),
/// )
/// ```
class AnchorTextField extends StatefulWidget {
  /// The label text displayed above the field
  final String label;

  /// Placeholder text shown inside the field
  final String? hintText;

  /// Error message to display below the field (shows red border when not null)
  final String? errorText;

  /// Whether this is a password field (enables visibility toggle)
  final bool isPassword;

  /// Keyboard type for the input
  final TextInputType? keyboardType;

  /// Text input action (done, next, etc.)
  final TextInputAction? textInputAction;

  /// Text editing controller
  final TextEditingController? controller;

  /// Called when the text changes
  final ValueChanged<String>? onChanged;

  /// Called when the user submits (presses enter/done)
  final ValueChanged<String>? onSubmitted;

  /// Whether the field is enabled
  final bool enabled;

  /// Maximum number of lines (1 for single line, more for text areas)
  final int maxLines;

  /// Auto-validate mode
  final AutovalidateMode? autovalidateMode;

  /// Prefix icon to display at the start of the field
  final Widget? prefixIcon;

  /// Whether the field is read-only (user cannot edit)
  final bool readOnly;

  /// Background color for the field (defaults to white, can be grey for readonly)
  final Color? backgroundColor;

  const AnchorTextField({
    super.key,
    required this.label,
    this.hintText,
    this.errorText,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.autovalidateMode,
    this.prefixIcon,
    this.readOnly = false,
    this.backgroundColor,
  });

  @override
  State<AnchorTextField> createState() => _AnchorTextFieldState();
}

class _AnchorTextFieldState extends State<AnchorTextField> {
  /// Tracks whether password is currently visible
  /// Starts as false (password hidden) for security
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    // Only obscure text if it's a password field
    _obscureText = widget.isPassword;
  }

  /// Toggles password visibility when the eye icon is tapped
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we have an error (used for styling)
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (always shown above the field)
        Text(
          widget.label,
          style: AnchorTypography.labelMedium.copyWith(
            color: hasError ? AnchorColors.error : AnchorColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
        AnchorSpacing.verticalSpaceXS, // 8px gap between label and field

        // The actual text field
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          maxLines: widget.maxLines,
          autovalidateMode: widget.autovalidateMode,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: AnchorTypography.bodyMedium.copyWith(
            color: AnchorColors.gray900,
          ),

          // Input decoration (border, hint, error styling)
          decoration: InputDecoration(
            // Hint text (placeholder)
            hintText: widget.hintText,
            hintStyle: AnchorTypography.bodyMedium.copyWith(
              color: AnchorColors.gray400,
            ),

            // Prefix icon (at the start of the field)
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  )
                : null,

            // Suffix icon (eye icon for password fields)
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      // Toggle between visible/hidden icon
                      _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AnchorColors.gray500,
                      size: 20,
                    ),
                    onPressed: _togglePasswordVisibility,
                  )
                : null,

            // Error text (shown below field when there's an error)
            errorText: hasError ? widget.errorText : null,
            errorStyle: AnchorTypography.labelSmall.copyWith(
              color: AnchorColors.error,
            ),
            errorMaxLines: 2,

            // Remove the default error border (we'll handle it ourselves)
            errorBorder: OutlineInputBorder(
              borderRadius: AnchorSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AnchorColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AnchorSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AnchorColors.error,
                width: 2.0,
              ),
            ),

            // Border styling for normal state
            enabledBorder: OutlineInputBorder(
              borderRadius: AnchorSpacing.radiusMD,
              borderSide: BorderSide(
                color: hasError ? AnchorColors.error : AnchorColors.gray300,
                width: 1.0,
              ),
            ),

            // Border styling when focused (user is typing)
            focusedBorder: OutlineInputBorder(
              borderRadius: AnchorSpacing.radiusMD,
              borderSide: BorderSide(
                color: hasError ? AnchorColors.error : AnchorColors.anchorTeal,
                width: 2.0,
              ),
            ),

            // Border styling when disabled
            disabledBorder: OutlineInputBorder(
              borderRadius: AnchorSpacing.radiusMD,
              borderSide: const BorderSide(
                color: AnchorColors.gray200,
                width: 1.0,
              ),
            ),

            // Content padding (space inside the field)
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            // Fill color (background of the field)
            filled: true,
            fillColor: widget.backgroundColor ??
                (widget.enabled && !widget.readOnly
                    ? AnchorColors.white
                    : AnchorColors.gray100),
          ),
        ),
      ],
    );
  }
}
