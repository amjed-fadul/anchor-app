import 'package:flutter/material.dart';

/// Anchor App Spacing System
/// Based on 8px grid system for consistent spacing
class AnchorSpacing {
  AnchorSpacing._(); // Private constructor

  // ============================================
  // BASE UNIT
  // ============================================

  /// Base spacing unit (8px)
  /// All spacing values are multiples of this
  static const double baseUnit = 8.0;

  // ============================================
  // SPACING VALUES (8px increments)
  // ============================================

  /// 4px - Extra extra small (0.5x base)
  static const double xxs = baseUnit * 0.5; // 4px

  /// 8px - Extra small (1x base)
  static const double xs = baseUnit; // 8px

  /// 12px - Small (1.5x base)
  static const double sm = baseUnit * 1.5; // 12px

  /// 16px - Medium (2x base) - Most common spacing
  static const double md = baseUnit * 2; // 16px

  /// 24px - Large (3x base)
  static const double lg = baseUnit * 3; // 24px

  /// 32px - Extra large (4x base)
  static const double xl = baseUnit * 4; // 32px

  /// 40px - Extra extra large (5x base)
  static const double xxl = baseUnit * 5; // 40px

  /// 48px - Extra extra extra large (6x base)
  static const double xxxl = baseUnit * 6; // 48px

  /// 64px - Huge (8x base)
  static const double huge = baseUnit * 8; // 64px

  /// 80px - Extra huge (10x base)
  static const double extraHuge = baseUnit * 10; // 80px

  // ============================================
  // EDGE INSETS (Padding shortcuts)
  // ============================================

  /// No padding
  static const EdgeInsets zero = EdgeInsets.zero;

  /// 4px padding on all sides
  static const EdgeInsets allXXS = EdgeInsets.all(xxs);

  /// 8px padding on all sides
  static const EdgeInsets allXS = EdgeInsets.all(xs);

  /// 12px padding on all sides
  static const EdgeInsets allSM = EdgeInsets.all(sm);

  /// 16px padding on all sides (most common)
  static const EdgeInsets allMD = EdgeInsets.all(md);

  /// 24px padding on all sides
  static const EdgeInsets allLG = EdgeInsets.all(lg);

  /// 32px padding on all sides
  static const EdgeInsets allXL = EdgeInsets.all(xl);

  /// 40px padding on all sides
  static const EdgeInsets allXXL = EdgeInsets.all(xxl);

  // ============================================
  // HORIZONTAL PADDING
  // ============================================

  /// 8px horizontal padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);

  /// 12px horizontal padding
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);

  /// 16px horizontal padding (most common)
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);

  /// 24px horizontal padding
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  /// 32px horizontal padding
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // ============================================
  // VERTICAL PADDING
  // ============================================

  /// 8px vertical padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);

  /// 12px vertical padding
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);

  /// 16px vertical padding (most common)
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);

  /// 24px vertical padding
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  /// 32px vertical padding
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);

  // ============================================
  // SCREEN PADDING (Common patterns)
  // ============================================

  /// Screen edge padding - 16px horizontal, 16px vertical
  /// Use for: Main screen content
  static const EdgeInsets screenPadding = EdgeInsets.all(md);

  /// Screen edge padding - 16px horizontal, 24px vertical
  /// Use for: Screens with more vertical content
  static const EdgeInsets screenPaddingLarge = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  /// Card padding - 16px on all sides
  /// Use for: Card content
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card padding small - 12px on all sides
  /// Use for: Compact cards
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(sm);

  /// List item padding - 16px horizontal, 12px vertical
  /// Use for: List items
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Button padding - 24px horizontal, 12px vertical
  /// Use for: Primary buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  /// Button padding small - 16px horizontal, 8px vertical
  /// Use for: Small buttons
  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );

  /// Input padding - 16px horizontal, 12px vertical
  /// Use for: Text inputs
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Dialog padding - 24px on all sides
  /// Use for: Dialogs and modals
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  /// Bottom sheet padding - 16px horizontal, 24px vertical
  /// Use for: Bottom sheets
  static const EdgeInsets bottomSheetPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );

  // ============================================
  // SIZED BOXES (Vertical spacing)
  // ============================================

  /// 4px vertical space
  static const SizedBox verticalSpaceXXS = SizedBox(height: xxs);

  /// 8px vertical space
  static const SizedBox verticalSpaceXS = SizedBox(height: xs);

  /// 12px vertical space
  static const SizedBox verticalSpaceSM = SizedBox(height: sm);

  /// 16px vertical space (most common)
  static const SizedBox verticalSpaceMD = SizedBox(height: md);

  /// 24px vertical space
  static const SizedBox verticalSpaceLG = SizedBox(height: lg);

  /// 32px vertical space
  static const SizedBox verticalSpaceXL = SizedBox(height: xl);

  /// 40px vertical space
  static const SizedBox verticalSpaceXXL = SizedBox(height: xxl);

  /// 48px vertical space
  static const SizedBox verticalSpaceXXXL = SizedBox(height: xxxl);

  /// 64px vertical space
  static const SizedBox verticalSpaceHuge = SizedBox(height: huge);

  // ============================================
  // SIZED BOXES (Horizontal spacing)
  // ============================================

  /// 4px horizontal space
  static const SizedBox horizontalSpaceXXS = SizedBox(width: xxs);

  /// 8px horizontal space
  static const SizedBox horizontalSpaceXS = SizedBox(width: xs);

  /// 12px horizontal space
  static const SizedBox horizontalSpaceSM = SizedBox(width: sm);

  /// 16px horizontal space (most common)
  static const SizedBox horizontalSpaceMD = SizedBox(width: md);

  /// 24px horizontal space
  static const SizedBox horizontalSpaceLG = SizedBox(width: lg);

  /// 32px horizontal space
  static const SizedBox horizontalSpaceXL = SizedBox(width: xl);

  // ============================================
  // BORDER RADIUS (8px based)
  // ============================================

  /// 4px border radius - Small
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xxs));

  /// 8px border radius - Medium (most common)
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(xs));

  /// 12px border radius - Large
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(sm));

  /// 16px border radius - Extra large
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(md));

  /// 24px border radius - Extra extra large
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(lg));

  /// Full circle border radius (9999px)
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(9999));

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create custom padding with specified values
  /// All values should be multiples of 8px for consistency
  static EdgeInsets custom({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Create custom symmetric padding
  static EdgeInsets symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Validate spacing value (should be multiple of 4px)
  static bool isValidSpacing(double value) {
    return value % (baseUnit / 2) == 0;
  }

  /// Get nearest valid spacing value (rounds to nearest 4px)
  static double toValidSpacing(double value) {
    final halfBase = baseUnit / 2;
    return (value / halfBase).round() * halfBase;
  }
}
