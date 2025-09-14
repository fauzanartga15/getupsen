// File: lib/utils/dialog_utils.dart
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/models/employee_model.dart';
import '../infrastructure/navigation/routes.dart';
import 'helpers/responsive_helper.dart';
import 'theme/app_color.dart';

class DialogUtils {
  DialogUtils._(); // Private constructor untuk prevent instantiation

  /// Show loading dialog dengan style modern
  static void showLoading({
    String? message,
    String? subtitle,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _LoadingDialogContent(
          message: message ?? 'Sedang memproses...',
          subtitle: subtitle ?? 'Mohon tunggu sebentar',
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: AppColor.kTextDark.withValues(alpha: 0.5),
    );
  }

  /// Show simple loading dialog
  static void showSimpleLoading({
    String? message,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _SimpleLoadingContent(message: message ?? 'Loading...'),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.6),
    );
  }

  /// Show premium loading dialog with glassmorphism
  static void showPremiumLoading({
    String? message,
    String? subtitle,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _PremiumLoadingContent(
          message: message ?? 'Sedang memproses...',
          subtitle: subtitle ?? 'Mohon tunggu sebentar',
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: AppColor.kTextDark.withValues(alpha: 0.7),
    );
  }

  /// Hide loading dialog
  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show success dialog
  static void showSuccess({
    required String message,
    String? title,
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: _SuccessDialogContent(
          title: title ?? 'Berhasil!',
          message: message,
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Show error dialog
  static void showError({
    required String message,
    String? title,
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: _ErrorDialogContent(
          title: title ?? 'Error!',
          message: message,
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Show confirmation dialog
  static void showConfirmation({
    required String message,
    String? title,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: _ConfirmationDialogContent(
          title: title ?? 'Konfirmasi',
          message: message,
          confirmText: confirmText ?? 'Ya',
          cancelText: cancelText ?? 'Tidak',
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
      ),
    );
  }

  // Show camera error dialog with troubleshooting tips
  static void showCameraErrorDialog({
    required String errorMessage,
    VoidCallback? onRetry,
    bool barrierDismissible = false,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
          ),
        ),
        child: Container(
          width: ScaleResponsiveHelper.scaleWidth(Get.context!, 350),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
          ),
          padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.red.shade100],
            ),
            borderRadius: BorderRadius.circular(
              ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: ScaleResponsiveHelper.scale(Get.context!, 80),
                height: ScaleResponsiveHelper.scale(Get.context!, 80),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: ScaleResponsiveHelper.getIconSize(Get.context!, 40),
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 16),
              ),

              Text(
                'Camera Error',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(Get.context!, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 8),
              ),

              Text(
                errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(Get.context!, 14),
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 16),
              ),

              // Suggestions container
              Container(
                padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ScaleResponsiveHelper.getBorderRadius(Get.context!, 8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Troubleshooting Tips:',
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          Get.context!,
                          12,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    SizedBox(
                      height: ScaleResponsiveHelper.getSpacing(Get.context!, 4),
                    ),
                    Text(
                      '• Check camera permissions\n• Close other camera apps\n• Restart the application',
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          Get.context!,
                          11,
                        ),
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: ScaleResponsiveHelper.scale(Get.context!, 48),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          if (onRetry != null) {
                            onRetry(); // Callback untuk retry
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              ScaleResponsiveHelper.getBorderRadius(
                                Get.context!,
                                8,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ScaleResponsiveHelper.getFontSize(
                              Get.context!,
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showAlreadyCompletedDialog({
    required EmployeeModel employee,
    VoidCallback? onBackToHome,
    VoidCallback? onRestartDetection,
    bool autoCloseAfter5Seconds = true,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
          ),
        ),
        child: Container(
          width: ScaleResponsiveHelper.scaleWidth(Get.context!, 350),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
          ),
          padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade50, Colors.orange.shade100],
            ),
            borderRadius: BorderRadius.circular(
              ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Employee avatar
              Container(
                width: ScaleResponsiveHelper.scale(Get.context!, 80),
                height: ScaleResponsiveHelper.scale(Get.context!, 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    employee.name.split(' ').take(2).map((e) => e[0]).join(),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: ScaleResponsiveHelper.getFontSize(
                        Get.context!,
                        24,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 16),
              ),

              Text(
                'Attendance Complete',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(Get.context!, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 8),
              ),

              Text(
                '${employee.name}\n${employee.departmentName}',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(Get.context!, 14),
                  color: Colors.orange.shade700,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 16),
              ),

              // Message container
              Container(
                padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    ScaleResponsiveHelper.getBorderRadius(Get.context!, 8),
                  ),
                ),
                child: Text(
                  'You have already completed attendance for today',
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(
                      Get.context!,
                      12,
                    ),
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
              ),

              // Back button
              SizedBox(
                width: double.infinity,
                height: ScaleResponsiveHelper.scale(Get.context!, 48),
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    if (onBackToHome != null) {
                      onBackToHome();
                    } else {
                      // Default behavior
                      Get.offAndToNamed(Routes.HOME);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ScaleResponsiveHelper.getBorderRadius(Get.context!, 8),
                      ),
                    ),
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: ScaleResponsiveHelper.getFontSize(
                        Get.context!,
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Auto close and redirect after 5 seconds (if enabled)
    if (autoCloseAfter5Seconds) {
      Timer(Duration(seconds: 5), () {
        if (Get.isDialogOpen ?? false) {
          Get.back();
          if (onRestartDetection != null) {
            onRestartDetection();
          }
        }
      });
    }
  }
}

// =============================================================================
// PRIVATE WIDGET COMPONENTS
// =============================================================================

class _LoadingDialogContent extends StatelessWidget {
  final String message;
  final String subtitle;

  const _LoadingDialogContent({required this.message, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScaleResponsiveHelper.getAllPadding(context, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColor.kBackgroundLight.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
            offset: Offset(0, ScaleResponsiveHelper.scale(context, 10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScaleResponsiveHelper.scale(context, 60),
            height: ScaleResponsiveHelper.scale(context, 60),
            decoration: BoxDecoration(
              gradient: AppColor.kPrimaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.kPrimaryColor.withValues(alpha: 0.3),
                  blurRadius: ScaleResponsiveHelper.scale(context, 15),
                  offset: Offset(0, ScaleResponsiveHelper.scale(context, 5)),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(ScaleResponsiveHelper.scale(context, 12)),
              child: CircularProgressIndicator(
                strokeWidth: ScaleResponsiveHelper.scale(context, 3),
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
          Text(
            message,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColor.kTextPrimary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
              color: AppColor.kTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
          _AnimatedDots(),
        ],
      ),
    );
  }
}

class _SimpleLoadingContent extends StatelessWidget {
  final String message;

  const _SimpleLoadingContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleResponsiveHelper.scaleWidth(context, 280),
      padding: ScaleResponsiveHelper.getAllPadding(context, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
            offset: Offset(0, ScaleResponsiveHelper.scale(context, 10)),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            strokeWidth: ScaleResponsiveHelper.scale(context, 3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.kPrimaryColor),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w500,
              color: AppColor.kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumLoadingContent extends StatelessWidget {
  final String message;
  final String subtitle;

  const _PremiumLoadingContent({required this.message, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ScaleResponsiveHelper.getAllPadding(context, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            AppColor.kBackgroundLight.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 32),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: ScaleResponsiveHelper.scale(context, 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 60),
            offset: Offset(0, ScaleResponsiveHelper.scale(context, 30)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 32),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: ScaleResponsiveHelper.getAllPadding(context, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: ScaleResponsiveHelper.scale(context, 80),
                  height: ScaleResponsiveHelper.scale(context, 80),
                  decoration: BoxDecoration(
                    gradient: AppColor.kPrimaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                        blurRadius: ScaleResponsiveHelper.scale(context, 20),
                        offset: Offset(
                          0,
                          ScaleResponsiveHelper.scale(context, 8),
                        ),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      ScaleResponsiveHelper.scale(context, 20),
                    ),
                    child: CircularProgressIndicator(
                      strokeWidth: ScaleResponsiveHelper.scale(context, 3),
                      backgroundColor: Colors.white.withValues(alpha: 0.4),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 28)),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColor.kPrimaryGradient.createShader(bounds),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 20),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 12)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                    color: AppColor.kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  @override
  __AnimatedDotsState createState() => __AnimatedDotsState();
}

class __AnimatedDotsState extends State<_AnimatedDots>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animValue = (_animationController.value - delay).clamp(
              0.0,
              1.0,
            );
            final scale = (math.sin(animValue * math.pi) * 0.5) + 0.5;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: ScaleResponsiveHelper.scale(context, 3),
              ),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: ScaleResponsiveHelper.scale(context, 6),
                  height: ScaleResponsiveHelper.scale(context, 6),
                  decoration: BoxDecoration(
                    gradient: AppColor.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// Success, Error, dan Confirmation dialog components bisa ditambahkan di sini
class _SuccessDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onPressed;

  const _SuccessDialogContent({
    required this.title,
    required this.message,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScaleResponsiveHelper.getAllPadding(context, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.kSuccessGreen.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScaleResponsiveHelper.scale(context, 60),
            height: ScaleResponsiveHelper.scale(context, 60),
            decoration: BoxDecoration(
              color: AppColor.kSuccessGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: ScaleResponsiveHelper.scale(context, 30),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: AppColor.kTextPrimary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
              color: AppColor.kTextSecondary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
          ElevatedButton(
            onPressed: onPressed ?? () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kSuccessGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ScaleResponsiveHelper.getBorderRadius(context, 12),
                ),
              ),
              padding: ScaleResponsiveHelper.getSymmetricPadding(
                context,
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onPressed;

  const _ErrorDialogContent({
    required this.title,
    required this.message,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScaleResponsiveHelper.getAllPadding(context, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScaleResponsiveHelper.scale(context, 60),
            height: ScaleResponsiveHelper.scale(context, 60),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: ScaleResponsiveHelper.scale(context, 30),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: AppColor.kTextPrimary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
              color: AppColor.kTextSecondary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
          ElevatedButton(
            onPressed: onPressed ?? () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ScaleResponsiveHelper.getBorderRadius(context, 12),
                ),
              ),
              padding: ScaleResponsiveHelper.getSymmetricPadding(
                context,
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              'OK',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationDialogContent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _ConfirmationDialogContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ScaleResponsiveHelper.getAllPadding(context, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.kPrimaryColor.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: ScaleResponsiveHelper.scale(context, 60),
            height: ScaleResponsiveHelper.scale(context, 60),
            decoration: BoxDecoration(
              gradient: AppColor.kPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              color: Colors.white,
              size: ScaleResponsiveHelper.scale(context, 30),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
          Text(
            title,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: AppColor.kTextPrimary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
              color: AppColor.kTextSecondary,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancel ?? () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kNeutralLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ScaleResponsiveHelper.getBorderRadius(context, 12),
                      ),
                    ),
                    padding: ScaleResponsiveHelper.getSymmetricPadding(
                      context,
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: AppColor.kTextSecondary,
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm ?? () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ScaleResponsiveHelper.getBorderRadius(context, 12),
                      ),
                    ),
                    padding: ScaleResponsiveHelper.getSymmetricPadding(
                      context,
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
