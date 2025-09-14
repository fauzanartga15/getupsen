// File: lib/utils/scale_responsive_helper.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScaleResponsiveHelper {
  // Base design size (iPhone 11/12 as reference)
  static const double baseWidth = 375.0;
  static const double baseHeight = 812.0;

  // Get scale factor based on screen size
  static double getScaleFactor(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate scale based on width (primary factor)
    final widthScale = size.width / baseWidth;

    // Calculate scale based on height (secondary factor)
    final heightScale = size.height / baseHeight;

    // Use minimum to ensure content fits, with some smart adjustments
    double scale = math.min(widthScale, heightScale);

    // Apply some smart scaling rules
    if (scale > 2.0) {
      // For very large screens, cap the scaling to avoid giant UI
      scale = 1.5 + (scale - 1.5) * 0.3;
    } else if (scale > 1.5) {
      // For tablet range, use more aggressive scaling
      scale = scale * 0.9;
    }

    // Ensure minimum scale
    scale = math.max(scale, 0.8);

    return scale;
  }

  // Get width scale factor
  static double getWidthScale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / baseWidth;
  }

  // Get height scale factor
  static double getHeightScale(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.height / baseHeight;
  }

  // Scale any value based on screen size
  static double scale(BuildContext context, double value) {
    return value * getScaleFactor(context);
  }

  // Scale width specifically
  static double scaleWidth(BuildContext context, double width) {
    return width * getWidthScale(context);
  }

  // Scale height specifically
  static double scaleHeight(BuildContext context, double height) {
    return height * getHeightScale(context);
  }

  // Font sizes with scaling
  static double getFontSize(BuildContext context, double baseFontSize) {
    return scale(context, baseFontSize);
  }

  // Icon sizes with scaling
  static double getIconSize(BuildContext context, double baseIconSize) {
    return scale(context, baseIconSize);
  }

  // Spacing with scaling
  static double getSpacing(BuildContext context, double baseSpacing) {
    return scale(context, baseSpacing);
  }

  // Border radius with scaling
  static double getBorderRadius(BuildContext context, double baseRadius) {
    return scale(context, baseRadius);
  }

  // Padding with scaling
  static EdgeInsets getPadding(BuildContext context, EdgeInsets basePadding) {
    final scaleFactor = getScaleFactor(context);
    return EdgeInsets.only(
      left: basePadding.left * scaleFactor,
      top: basePadding.top * scaleFactor,
      right: basePadding.right * scaleFactor,
      bottom: basePadding.bottom * scaleFactor,
    );
  }

  // Symmetric padding
  static EdgeInsets getSymmetricPadding(
    BuildContext context, {
    double horizontal = 0,
    double vertical = 0,
  }) {
    return getPadding(
      context,
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    );
  }

  // All padding
  static EdgeInsets getAllPadding(BuildContext context, double padding) {
    return getPadding(context, EdgeInsets.all(padding));
  }

  // Size with scaling
  static Size getSize(BuildContext context, Size baseSize) {
    final scaleFactor = getScaleFactor(context);
    return Size(baseSize.width * scaleFactor, baseSize.height * scaleFactor);
  }

  // Get device info for debugging
  static Map<String, dynamic> getDeviceInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleFactor = getScaleFactor(context);

    return {
      'screenWidth': size.width,
      'screenHeight': size.height,
      'scaleFactor': scaleFactor,
      'widthScale': getWidthScale(context),
      'heightScale': getHeightScale(context),
      'deviceType': _getDeviceType(context),
    };
  }

  static String _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 'Mobile';
    if (width < 1024) return 'Tablet';
    return 'Desktop';
  }

  // Check if screen needs scrolling
  static bool needsScrolling(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scaleFactor = getScaleFactor(context);

    // Calculate estimated content height after scaling
    final estimatedContentHeight = baseHeight * scaleFactor;

    return estimatedContentHeight > size.height;
  }

  // Get safe area insets scaled
  static EdgeInsets getScaledSafeArea(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;
    final scaleFactor = getScaleFactor(context);

    return EdgeInsets.only(
      top: safeArea.top * scaleFactor,
      bottom: safeArea.bottom * scaleFactor,
      left: safeArea.left * scaleFactor,
      right: safeArea.right * scaleFactor,
    );
  }
}

// Widget untuk debugging scale info
class ScaleDebugInfo extends StatelessWidget {
  const ScaleDebugInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = ScaleResponsiveHelper.getDeviceInfo(context);

    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.black.withValues(alpha: 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Debug Info:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Device: ${info['deviceType']}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Screen: ${info['screenWidth'].toStringAsFixed(0)}x${info['screenHeight'].toStringAsFixed(0)}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Scale: ${info['scaleFactor'].toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Width Scale: ${info['widthScale'].toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Height Scale: ${info['heightScale'].toStringAsFixed(2)}',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
