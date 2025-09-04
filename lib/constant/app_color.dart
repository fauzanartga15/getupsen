import 'package:flutter/widgets.dart';

class AppColor {
  // Primary colors from mockup design
  static const kPrimaryColor = Color(0xFF26A69A);
  static const kPrimaryDark = Color(0xFF009688);
  static const kPrimaryDeep = Color(0xFF004D40);

  // Background gradients
  static const kBackgroundLight = Color(0xFFEDE9FE);
  static const kBackgroundMid = Color(0xFFEFF6FF);
  static const kBackgroundTeal = Color(0xFFE0F7FA);

  // Success colors - vibrant and wow
  static const kSuccessGreen = Color(0xFF10B981);
  static const kSuccessGreenDark = Color(0xFF059669);

  // Cyan theme - more vibrant and wow
  static const kCyanPrimary = Color(0xFF00BCD4); // Bright cyan
  static const kCyanSecondary = Color(0xFF0891B2); // Darker cyan
  static const kCyanDeep = Color(0xFF0E7490); // Deep cyan
  static const kCyanBright = Color(0xFF06B6D4); // Bright cyan variant

  // Accent colors
  static const kAccentPurple = Color(0xFF6B46C1);
  static const kAccentBlue = Color(0xFF3B82F6);
  static const kAccentCyan = Color(0xFF00BCD4);

  // Gradient combinations for wow effect
  static const kGradientMainAction = [
    Color(0xFF26A69A), // Teal primary
    Color(0xFF009688), // Teal secondary
    Color(0xFF004D40),
  ];

  static const kGradientCyanBright = [
    Color(0xFF06B6D4), // Sky-400
    Color(0xFF0891B2), // Sky-600
    Color(0xFF0E7490), // Sky-700
  ];

  static const kGradientCyanVibrant = [
    Color(0xFF26A69A),
    Color(0xFF009688),
    Color(0xFF004D40),
  ];

  static const kGradientSuccess = [
    Color(0xFF34D399), // Emerald-300
    Color(0xFF10B981), // Emerald-500
    Color(0xFF059669), // Emerald-600
  ];

  static const kGradientBg = [
    Color(0xFF26A69A), // Emerald-500
    Color(0xFF6B46C1), // Emerald-300
    Color(0xFF10B981), // Emerald-500
  ];

  static const kGradientHomeBg = [
    Color(0xFFEDE9FE), // Light purple
    Color(0xFFEFF6FF), // Light blue
    Color(0xFFE0F7FA), // Light teal
  ];

  // Text colors
  static const kTextPrimary = Color(0xFF334155);
  static const kTextSecondary = Color(0xFF64748B);
  static const kTextDark = Color(0xFF1E293B);

  // Neutral colors
  static const kNeutralLight = Color(0xFFF8FAFC);
  static const kNeutralBorder = Color(0xFF334155);

  // Status colors
  static const kStatusOnline = Color(0xFF10B981);
  static const kStatusActive = Color(0xFF3B82F6);
  static const kStatusLate = Color(0xFFF59E0B);
}
