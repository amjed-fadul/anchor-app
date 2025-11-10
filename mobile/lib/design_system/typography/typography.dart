import 'package:flutter/material.dart';
import '../colors/colors.dart';

/// Anchor App Typography System
/// Based on Geist font family and Material Design 3
class AnchorTypography {
  AnchorTypography._(); // Private constructor

  // ============================================
  // FONT FAMILY
  // ============================================

  /// Primary font family - Geist
  /// Fallback to system default if Geist not available
  static const String fontFamily = 'Geist';

  // ============================================
  // DISPLAY STYLES (Large headings)
  // ============================================

  /// Display Large - Used for hero sections and major headings
  /// Size: 57px, Weight: 700 (Bold)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AnchorColors.anchorSlate,
  );

  /// Display Medium - Used for section headings
  /// Size: 45px, Weight: 700 (Bold)
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Display Small - Used for card headings
  /// Size: 36px, Weight: 600 (SemiBold)
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    height: 1.22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  // ============================================
  // HEADLINE STYLES (Page titles)
  // ============================================

  /// Headline Large - Used for page titles
  /// Size: 32px, Weight: 600 (SemiBold)
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Headline Medium - Used for screen titles
  /// Size: 28px, Weight: 600 (SemiBold)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Headline Small - Used for section titles
  /// Size: 24px, Weight: 600 (SemiBold)
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.33,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  // ============================================
  // TITLE STYLES (Card titles, list items)
  // ============================================

  /// Title Large - Used for prominent card titles
  /// Size: 22px, Weight: 500 (Medium)
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Title Medium - Used for card titles
  /// Size: 16px, Weight: 500 (Medium)
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: AnchorColors.anchorSlate,
  );

  /// Title Small - Used for small card titles
  /// Size: 14px, Weight: 500 (Medium)
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AnchorColors.anchorSlate,
  );

  // ============================================
  // BODY STYLES (Main content text)
  // ============================================

  /// Body Large - Used for prominent body text
  /// Size: 16px, Weight: 400 (Regular)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AnchorColors.gray700,
  );

  /// Body Medium - Used for regular body text (most common)
  /// Size: 14px, Weight: 400 (Regular)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AnchorColors.gray700,
  );

  /// Body Small - Used for secondary body text
  /// Size: 12px, Weight: 400 (Regular)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AnchorColors.gray600,
  );

  // ============================================
  // LABEL STYLES (Buttons, tabs, chips)
  // ============================================

  /// Label Large - Used for prominent buttons
  /// Size: 14px, Weight: 500 (Medium)
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AnchorColors.anchorSlate,
  );

  /// Label Medium - Used for regular buttons and tabs
  /// Size: 12px, Weight: 500 (Medium)
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AnchorColors.anchorSlate,
  );

  /// Label Small - Used for small buttons and chips
  /// Size: 11px, Weight: 500 (Medium)
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.45,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AnchorColors.gray600,
  );

  // ============================================
  // CUSTOM ANCHOR STYLES
  // ============================================

  /// Link text style - Used for clickable links
  static const TextStyle link = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    color: AnchorColors.anchorTeal,
    decoration: TextDecoration.underline,
  );

  /// Link title - Used for saved link titles in cards
  static const TextStyle linkTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Link domain - Used for showing domain names
  static const TextStyle linkDomain = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AnchorColors.gray500,
  );

  /// Note text - Used for user notes on links
  static const TextStyle note = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AnchorColors.gray600,
    fontStyle: FontStyle.italic,
  );

  /// Tag text - Used for tag chips
  static const TextStyle tag = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AnchorColors.anchorSlate,
  );

  /// Space name - Used for space labels
  static const TextStyle spaceName = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.42,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AnchorColors.anchorSlate,
  );

  /// Empty state - Used for empty state messages
  static const TextStyle emptyState = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AnchorColors.gray500,
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get text theme for MaterialApp
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
