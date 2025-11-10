import 'package:flutter/material.dart';
import 'button_styles.dart';

/// Button type enum for AnchorButton
enum AnchorButtonType {
  primary,
  secondary,
  tertiary,
  destructive,
  destructiveOutlined,
}

/// Button size enum for AnchorButton
enum AnchorButtonSize {
  small,
  medium,
  large,
}

/// Anchor Button Widget
/// A consistent button component that follows Anchor design system
///
/// Usage:
/// ```dart
/// AnchorButton(
///   label: 'Save',
///   onPressed: () => print('Saved'),
///   type: AnchorButtonType.primary,
/// )
/// ```
class AnchorButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button type (primary, secondary, tertiary, etc.)
  final AnchorButtonType type;

  /// Button size (small, medium, large)
  final AnchorButtonSize size;

  /// Optional icon to display before text
  final IconData? icon;

  /// Optional icon to display after text
  final IconData? trailingIcon;

  /// Whether button should take full width
  final bool fullWidth;

  /// Whether button is in loading state
  final bool isLoading;

  const AnchorButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AnchorButtonType.primary,
    this.size = AnchorButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.fullWidth = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Build button content
    Widget buttonContent = _buildButtonContent();

    // Wrap with full width if needed
    if (fullWidth) {
      buttonContent = SizedBox(
        width: double.infinity,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  /// Get button style based on type and size
  ButtonStyle _getButtonStyle() {
    switch (type) {
      case AnchorButtonType.primary:
        switch (size) {
          case AnchorButtonSize.small:
            return AnchorButtonStyles.primarySmall;
          case AnchorButtonSize.medium:
            return AnchorButtonStyles.primary;
          case AnchorButtonSize.large:
            return AnchorButtonStyles.primaryLarge;
        }

      case AnchorButtonType.secondary:
        switch (size) {
          case AnchorButtonSize.small:
            return AnchorButtonStyles.secondarySmall;
          case AnchorButtonSize.medium:
            return AnchorButtonStyles.secondary;
          case AnchorButtonSize.large:
            return AnchorButtonStyles.secondaryLarge;
        }

      case AnchorButtonType.tertiary:
        switch (size) {
          case AnchorButtonSize.small:
            return AnchorButtonStyles.tertiarySmall;
          case AnchorButtonSize.medium:
          case AnchorButtonSize.large:
            return AnchorButtonStyles.tertiary;
        }

      case AnchorButtonType.destructive:
        return AnchorButtonStyles.destructive;

      case AnchorButtonType.destructiveOutlined:
        return AnchorButtonStyles.destructiveOutlined;
    }
  }

  /// Build button content with icon and loading state
  Widget _buildButtonContent() {
    // Show loading indicator if loading
    if (isLoading) {
      return _buildButton(
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Build content with icons if provided
    List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(const SizedBox(width: 8));
    }

    children.add(Text(label));

    if (trailingIcon != null) {
      children.add(const SizedBox(width: 8));
      children.add(Icon(trailingIcon, size: _getIconSize()));
    }

    return _buildButton(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }

  /// Build appropriate button widget based on type
  Widget _buildButton({required Widget child}) {
    final style = _getButtonStyle();

    switch (type) {
      case AnchorButtonType.primary:
      case AnchorButtonType.destructive:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );

      case AnchorButtonType.secondary:
      case AnchorButtonType.destructiveOutlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );

      case AnchorButtonType.tertiary:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
    }
  }

  /// Get icon size based on button size
  double _getIconSize() {
    switch (size) {
      case AnchorButtonSize.small:
        return 16;
      case AnchorButtonSize.medium:
        return 20;
      case AnchorButtonSize.large:
        return 24;
    }
  }
}

/// Icon Button Widget
/// A simple icon-only button following Anchor design system
///
/// Usage:
/// ```dart
/// AnchorIconButton(
///   icon: Icons.favorite,
///   onPressed: () => print('Liked'),
/// )
/// ```
class AnchorIconButton extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Whether to show filled background
  final bool filled;

  /// Whether to use primary color
  final bool primary;

  /// Custom tooltip
  final String? tooltip;

  const AnchorIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.primary = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = primary
        ? AnchorButtonStyles.iconButtonPrimary
        : filled
            ? AnchorButtonStyles.iconButtonFilled
            : AnchorButtonStyles.iconButton;

    final button = IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      style: style,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
