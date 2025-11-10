import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../spacing/spacing.dart';
import '../typography/typography.dart';

/// Anchor App Button Styles
/// Defines button styling for consistent UI
class AnchorButtonStyles {
  AnchorButtonStyles._(); // Private constructor

  // ============================================
  // PRIMARY BUTTON (Filled)
  // ============================================

  /// Primary button style - Anchor Teal background
  /// Used for: Main CTAs, primary actions
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: AnchorSpacing.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusSM,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(88, 44), // Material Design minimum
  );

  /// Primary button style - Large variant
  static ButtonStyle primaryLarge = ElevatedButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: AnchorSpacing.symmetric(horizontal: AnchorSpacing.xl, vertical: AnchorSpacing.md),
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusMD,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(120, 52),
  );

  /// Primary button style - Small variant
  static ButtonStyle primarySmall = ElevatedButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: AnchorSpacing.buttonPaddingSmall,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusXS,
    ),
    textStyle: AnchorTypography.labelMedium,
    minimumSize: const Size(64, 36),
  );

  // ============================================
  // SECONDARY BUTTON (Outlined)
  // ============================================

  /// Secondary button style - Outlined with Anchor Teal border
  /// Used for: Secondary actions, cancel buttons
  static ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AnchorColors.anchorTeal,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: AnchorColors.anchorTeal, width: 1.5),
    padding: AnchorSpacing.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusSM,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(88, 44),
  );

  /// Secondary button style - Large variant
  static ButtonStyle secondaryLarge = OutlinedButton.styleFrom(
    foregroundColor: AnchorColors.anchorTeal,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: AnchorColors.anchorTeal, width: 1.5),
    padding: AnchorSpacing.symmetric(horizontal: AnchorSpacing.xl, vertical: AnchorSpacing.md),
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusMD,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(120, 52),
  );

  /// Secondary button style - Small variant
  static ButtonStyle secondarySmall = OutlinedButton.styleFrom(
    foregroundColor: AnchorColors.anchorTeal,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: AnchorColors.anchorTeal, width: 1.5),
    padding: AnchorSpacing.buttonPaddingSmall,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusXS,
    ),
    textStyle: AnchorTypography.labelMedium,
    minimumSize: const Size(64, 36),
  );

  // ============================================
  // TERTIARY BUTTON (Text)
  // ============================================

  /// Tertiary button style - Text only
  /// Used for: Less important actions, inline links
  static ButtonStyle tertiary = TextButton.styleFrom(
    foregroundColor: AnchorColors.anchorTeal,
    backgroundColor: Colors.transparent,
    padding: AnchorSpacing.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusSM,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(64, 44),
  );

  /// Tertiary button style - Small variant
  static ButtonStyle tertiarySmall = TextButton.styleFrom(
    foregroundColor: AnchorColors.anchorTeal,
    backgroundColor: Colors.transparent,
    padding: AnchorSpacing.buttonPaddingSmall,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusXS,
    ),
    textStyle: AnchorTypography.labelMedium,
    minimumSize: const Size(48, 36),
  );

  // ============================================
  // DESTRUCTIVE BUTTON (Error state)
  // ============================================

  /// Destructive button style - Red background
  /// Used for: Delete actions, destructive operations
  static ButtonStyle destructive = ElevatedButton.styleFrom(
    backgroundColor: AnchorColors.error,
    foregroundColor: AnchorColors.white,
    elevation: 0,
    shadowColor: Colors.transparent,
    padding: AnchorSpacing.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusSM,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(88, 44),
  );

  /// Destructive button style - Outlined variant
  static ButtonStyle destructiveOutlined = OutlinedButton.styleFrom(
    foregroundColor: AnchorColors.error,
    backgroundColor: Colors.transparent,
    side: const BorderSide(color: AnchorColors.error, width: 1.5),
    padding: AnchorSpacing.buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusSM,
    ),
    textStyle: AnchorTypography.labelLarge,
    minimumSize: const Size(88, 44),
  );

  // ============================================
  // ICON BUTTON STYLES
  // ============================================

  /// Icon button style - Circular with no background
  static ButtonStyle iconButton = IconButton.styleFrom(
    foregroundColor: AnchorColors.anchorSlate,
    backgroundColor: Colors.transparent,
    padding: AnchorSpacing.allXS,
    minimumSize: const Size(40, 40),
    shape: const CircleBorder(),
  );

  /// Icon button style - With light background
  static ButtonStyle iconButtonFilled = IconButton.styleFrom(
    foregroundColor: AnchorColors.anchorSlate,
    backgroundColor: AnchorColors.gray100,
    padding: AnchorSpacing.allXS,
    minimumSize: const Size(40, 40),
    shape: const CircleBorder(),
  );

  /// Icon button style - With primary color
  static ButtonStyle iconButtonPrimary = IconButton.styleFrom(
    foregroundColor: AnchorColors.white,
    backgroundColor: AnchorColors.anchorTeal,
    padding: AnchorSpacing.allXS,
    minimumSize: const Size(40, 40),
    shape: const CircleBorder(),
  );

  // ============================================
  // CHIP STYLES (Used for tags and spaces)
  // ============================================

  /// Get chip theme data
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AnchorColors.gray100,
    deleteIconColor: AnchorColors.gray600,
    disabledColor: AnchorColors.gray200,
    selectedColor: AnchorColors.anchorTeal,
    secondarySelectedColor: AnchorColors.anchorTeal,
    padding: AnchorSpacing.symmetric(
      horizontal: AnchorSpacing.sm,
      vertical: AnchorSpacing.xxs,
    ),
    labelPadding: EdgeInsets.zero,
    labelStyle: AnchorTypography.tag,
    secondaryLabelStyle: AnchorTypography.tag.copyWith(
      color: AnchorColors.white,
    ),
    brightness: Brightness.light,
    elevation: 0,
    pressElevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusFull,
    ),
  );

  // ============================================
  // FLOATING ACTION BUTTON STYLES
  // ============================================

  /// FAB style - Primary (for main action like "Save Link")
  static ButtonStyle fab = FloatingActionButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 4,
    shape: const CircleBorder(),
    minimumSize: const Size(56, 56),
  );

  /// FAB style - Extended (with text)
  static ButtonStyle fabExtended = FloatingActionButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: AnchorSpacing.radiusMD,
    ),
    padding: AnchorSpacing.symmetric(
      horizontal: AnchorSpacing.md,
      vertical: AnchorSpacing.md,
    ),
  );

  /// FAB style - Small variant
  static ButtonStyle fabSmall = FloatingActionButton.styleFrom(
    backgroundColor: AnchorColors.anchorTeal,
    foregroundColor: AnchorColors.white,
    elevation: 4,
    shape: const CircleBorder(),
    minimumSize: const Size(40, 40),
  );
}
