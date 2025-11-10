import 'package:flutter/material.dart';

/// Anchor App Brand Colors
/// Based on Brand Style Guide
class AnchorColors {
  AnchorColors._(); // Private constructor to prevent instantiation

  // ============================================
  // PRIMARY BRAND COLORS
  // ============================================

  /// Anchor Teal - Primary brand color
  /// Used for: Primary buttons, links, accents, selected states
  static const Color anchorTeal = Color(0xFF0D9488);

  /// Anchor Slate - Secondary brand color
  /// Used for: Text, dark backgrounds, headers
  static const Color anchorSlate = Color(0xFF2C3E50);

  // ============================================
  // GRAYSCALE PALETTE
  // ============================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color black = Color(0xFF000000);

  // ============================================
  // SPACE COLORS (14 approved colors)
  // ============================================
  // Used for space tags and visual organization

  /// Purple - Default "Unread" space color
  static const Color spacePurple = Color(0xFF9333EA);

  /// Red - Default "Reference" space color
  static const Color spaceRed = Color(0xFFDC2626);

  /// Blue
  static const Color spaceBlue = Color(0xFF2563EB);

  /// Green
  static const Color spaceGreen = Color(0xFF16A34A);

  /// Yellow
  static const Color spaceYellow = Color(0xFFEAB308);

  /// Orange
  static const Color spaceOrange = Color(0xFFEA580C);

  /// Pink
  static const Color spacePink = Color(0xFFDB2777);

  /// Teal (same as brand teal)
  static const Color spaceTeal = Color(0xFF0D9488);

  /// Indigo
  static const Color spaceIndigo = Color(0xFF4F46E5);

  /// Cyan
  static const Color spaceCyan = Color(0xFF0891B2);

  /// Lime
  static const Color spaceLime = Color(0xFF65A30D);

  /// Amber
  static const Color spaceAmber = Color(0xFFD97706);

  /// Fuchsia
  static const Color spaceFuchsia = Color(0xFFC026D3);

  /// Sky
  static const Color spaceSky = Color(0xFF0284C7);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  // Used for feedback, alerts, and status

  /// Success - Positive actions and confirmations
  static const Color success = Color(0xFF16A34A); // Green

  /// Warning - Caution and important notices
  static const Color warning = Color(0xFFEAB308); // Yellow

  /// Error - Errors and destructive actions
  static const Color error = Color(0xFFDC2626); // Red

  /// Info - Informational messages
  static const Color info = Color(0xFF2563EB); // Blue

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get space color by name
  /// Used when loading spaces from database
  static Color getSpaceColor(String colorHex) {
    // Remove # if present
    final hex = colorHex.replaceAll('#', '');

    // Convert hex to Color
    final hexValue = int.tryParse(hex, radix: 16);
    if (hexValue == null) return spacePurple; // Fallback

    return Color(0xFF000000 | hexValue);
  }

  /// Get all available space colors as list
  /// Used for space color picker
  static List<Color> get allSpaceColors => [
    spacePurple,
    spaceRed,
    spaceBlue,
    spaceGreen,
    spaceYellow,
    spaceOrange,
    spacePink,
    spaceTeal,
    spaceIndigo,
    spaceCyan,
    spaceLime,
    spaceAmber,
    spaceFuchsia,
    spaceSky,
  ];

  /// Convert Color to hex string (for database storage)
  /// Example: Color(0xFF9333EA) -> "9333EA"
  static String colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase();
  }
}
