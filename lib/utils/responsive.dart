import 'package:flutter/material.dart';

/// Utility class for responsive design
/// Provides methods to adapt sizes, padding, font sizes, etc. based on screen size
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late bool isSmallScreen;
  static late bool isMediumScreen;
  static late bool isLargeScreen;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Screen size categories
    // Small: < 600px width (phones)
    // Medium: 600-900px (tablets)
    // Large: > 900px (desktop/tablets)
    isSmallScreen = screenWidth < 600;
    isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    isLargeScreen = screenWidth >= 900;
  }

  // Responsive font sizes
  static double fontSize({
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallScreen) return small;
    if (isMediumScreen) return medium;
    return large;
  }

  // Responsive padding/margin
  static double size({
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallScreen) return small;
    if (isMediumScreen) return medium;
    return large;
  }

  // Convenience methods for common sizes
  static double h(double percentage) => screenHeight * (percentage / 100);
  static double w(double percentage) => screenWidth * (percentage / 100);

  // Title font size (responsive)
  static double get titleFontSize => fontSize(
    small: 24,
    medium: 28,
    large: 32,
  );

  // Subtitle font size (responsive)
  static double get subtitleFontSize => fontSize(
    small: 14,
    medium: 16,
    large: 18,
  );

  // Body text font size (responsive)
  static double get bodyFontSize => fontSize(
    small: 13,
    medium: 14,
    large: 15,
  );

  // Button font size (responsive)
  static double get buttonFontSize => fontSize(
    small: 14,
    medium: 15,
    large: 16,
  );

  // Small text (captions) font size
  static double get smallFontSize => fontSize(
    small: 11,
    medium: 12,
    large: 13,
  );

  // Common spacing values
  static double get paddingSmall => size(
    small: 12,
    medium: 16,
    large: 20,
  );

  static double get paddingMedium => size(
    small: 16,
    medium: 20,
    large: 24,
  );

  static double get paddingLarge => size(
    small: 20,
    medium: 24,
    large: 32,
  );

  // Button sizing
  static double get buttonHeight => size(
    small: 48,
    medium: 52,
    large: 56,
  );

  static double get buttonWidth => size(
    small: 100,
    medium: 140,
    large: 180,
  );

  // Continue button width
  static double get continueButtonWidth => size(
    small: 160,
    medium: 180,
    large: 200,
  );

  // Back button width
  static double get backButtonWidth => size(
    small: 80,
    medium: 90,
    large: 100,
  );

  // Border radius
  static double get borderRadiusSmall => size(
    small: 16,
    medium: 20,
    large: 24,
  );

  static double get borderRadiusMedium => size(
    small: 22,
    medium: 26,
    large: 30,
  );

  static double get borderRadiusLarge => size(
    small: 28,
    medium: 32,
    large: 34,
  );

  // Icon sizes
  static double get iconSizeSmall => size(
    small: 18,
    medium: 20,
    large: 24,
  );

  static double get iconSizeMedium => size(
    small: 24,
    medium: 28,
    large: 32,
  );

  // Max width for content
  static double get maxContentWidth => size(
    small: 100,
    medium: 600,
    large: 900,
  );

  // Screen type helper
  static String get screenType {
    if (isSmallScreen) return 'small';
    if (isMediumScreen) return 'medium';
    return 'large';
  }
}
