// File: lib/presentation/confirmation/confirmation.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/employee_model.dart';
import '../../infrastructure/navigation/routes.dart';
import '../../utils/helpers/responsive_helper.dart';
import '../../utils/theme/app_color.dart';
import 'controllers/confirmation.controller.dart';

class ConfirmationScreen extends GetView<ConfirmationController> {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColor.kGradientBg,
            stops: [0.1, 0.5, 1.0],
          ),
        ),
        child: SafeArea(child: _buildScaledContent(context)),
      ),
    );
  }

  Widget _buildScaledContent(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 30.0,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Badge & Confidence
              _buildSuccessBadge(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

              // Animated Success Icon with Countdown
              _buildSuccessIcon(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

              // Company Info Card
              _buildCompanyCard(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

              // Employee Card
              _buildEmployeeCard(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

              // Attendance Details Card
              _buildAttendanceCard(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 30)),

              // Action Buttons
              _buildActionButtons(context),
              SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 15)),

              // Auto Redirect Info
              Obx(
                () => controller.countdown.value > 0
                    ? _buildAutoRedirectInfo(context)
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: ScaleResponsiveHelper.getSymmetricPadding(
            context,
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColor.kGradientSuccess),
            borderRadius: BorderRadius.circular(
              ScaleResponsiveHelper.getBorderRadius(context, 25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.kSuccessGreen.withValues(alpha: 0.4),
                blurRadius: ScaleResponsiveHelper.scale(context, 15),
                spreadRadius: ScaleResponsiveHelper.scale(context, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: ScaleResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 8)),
              Text(
                controller.attendanceResult?.status == true
                    ? 'Attendance Successful'
                    : 'Attendance Failed',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 12)),
        Container(
          padding: ScaleResponsiveHelper.getSymmetricPadding(
            context,
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(
              ScaleResponsiveHelper.getBorderRadius(context, 20),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${controller.confidence.toStringAsFixed(1)}% Face Match',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon(BuildContext context) {
    final iconSize = ScaleResponsiveHelper.scale(context, 120);
    final progressSize = ScaleResponsiveHelper.scale(context, 100);
    final innerSize = ScaleResponsiveHelper.scale(context, 80);

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Progress Ring
          Obx(
            () => SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                value: controller.countdownProgress,
                strokeWidth: ScaleResponsiveHelper.scale(context, 4),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  controller.countdown <= 3
                      ? Colors.red.shade300
                      : Colors.white,
                ),
              ),
            ),
          ),
          // Success Icon with Countdown
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: ScaleResponsiveHelper.scale(context, 20),
                  spreadRadius: ScaleResponsiveHelper.scale(context, 2),
                ),
              ],
            ),
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    controller.attendanceResult?.status == true
                        ? Icons.check
                        : Icons.close,
                    color: controller.attendanceResult?.status == true
                        ? AppColor.kSuccessGreen
                        : Colors.red.shade400,
                    size: ScaleResponsiveHelper.getIconSize(context, 32),
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(context, 2),
                  ),
                  Text(
                    '${controller.countdown}',
                    style: GoogleFonts.poppins(
                      color: controller.countdown <= 3
                          ? Colors.red.shade400
                          : AppColor.kCyanSecondary,
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context) {
    final employee = controller.employee;
    if (employee == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: ScaleResponsiveHelper.getAllPadding(context, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 20),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Company Logo/Icon
          Container(
            width: ScaleResponsiveHelper.scale(context, 50),
            height: ScaleResponsiveHelper.scale(context, 50),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColor.kGradientCyanVibrant,
              ),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 12),
              ),
            ),
            child: Icon(
              Icons.business,
              color: Colors.white,
              size: ScaleResponsiveHelper.getIconSize(context, 24),
            ),
          ),
          SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 16)),
          // Company Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.company.name,
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: AppColor.kTextDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 4)),
                Text(
                  employee.cabang?.name ?? 'Main Office',
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                    color: AppColor.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status Indicator
          Container(
            padding: ScaleResponsiveHelper.getSymmetricPadding(
              context,
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColor.kSuccessGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 8),
              ),
              border: Border.all(
                color: AppColor.kSuccessGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'VERIFIED',
              style: GoogleFonts.poppins(
                fontSize: ScaleResponsiveHelper.getFontSize(context, 10),
                fontWeight: FontWeight.bold,
                color: AppColor.kSuccessGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context) {
    final employee = controller.employee;
    if (employee == null) return SizedBox.shrink();

    final avatarSize = ScaleResponsiveHelper.scale(context, 90);

    return Container(
      width: double.infinity,
      padding: ScaleResponsiveHelper.getAllPadding(context, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 20),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 35),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Employee Photo
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: ScaleResponsiveHelper.scale(context, 20),
                  spreadRadius: ScaleResponsiveHelper.scale(context, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: employee.imageUrl != null && employee.imageUrl!.isNotEmpty
                  ? Image.network(
                      employee.fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(context, employee),
                    )
                  : _buildDefaultAvatar(context, employee),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),

          // Employee Name
          Text(
            employee.name,
            style: GoogleFonts.poppins(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: AppColor.kTextDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 4)),

          // Employee ID
          Text(
            'ID: ${employee.nip}',
            style: GoogleFonts.poppins(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
              color: AppColor.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),

          // Position & Department
          Container(
            width: double.infinity,
            padding: ScaleResponsiveHelper.getAllPadding(context, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.kCyanPrimary.withValues(alpha: 0.1),
                  AppColor.kCyanSecondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 12),
              ),
              border: Border.all(
                color: AppColor.kCyanPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _buildEmployeeInfoRow(
                  context,
                  'Position',
                  employee.positionName,
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
                _buildEmployeeInfoRow(
                  context,
                  'Department',
                  employee.departmentName,
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),
                _buildEmployeeInfoRow(context, 'Shift', employee.shiftName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context, EmployeeModel employee) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColor.kGradientCyanVibrant),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _getEmployeeInitials(employee.name),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: ScaleResponsiveHelper.getFontSize(context, 28),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getEmployeeInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0].substring(0, 2).toUpperCase();
    }
    return 'EM';
  }

  Widget _buildEmployeeInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 13),
              fontWeight: FontWeight.bold,
              color: AppColor.kCyanSecondary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final result = controller.attendanceResult;
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateString =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Container(
      width: double.infinity,
      padding: ScaleResponsiveHelper.getAllPadding(context, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 16),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: ScaleResponsiveHelper.scale(context, 25),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: ScaleResponsiveHelper.getAllPadding(context, 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColor.kGradientCyanVibrant,
                  ),
                  borderRadius: BorderRadius.circular(
                    ScaleResponsiveHelper.getBorderRadius(context, 8),
                  ),
                ),
                child: Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: ScaleResponsiveHelper.getIconSize(context, 20),
                ),
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),
              Text(
                'Attendance Details',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColor.kTextDark,
                ),
              ),
            ],
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),

          // Attendance Info
          Container(
            width: double.infinity,
            padding: ScaleResponsiveHelper.getAllPadding(context, 16),
            decoration: BoxDecoration(
              color: AppColor.kNeutralLight,
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 12),
              ),
            ),
            child: Column(
              children: [
                _buildAttendanceInfoRow(
                  context,
                  'Action',
                  result?.attendance!.actionText ?? 'attendance',
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 12)),
                _buildAttendanceInfoRow(context, 'Time', timeString),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 12)),
                _buildAttendanceInfoRow(context, 'Date', dateString),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 12)),
                _buildAttendanceInfoRow(
                  context,
                  'Status',
                  result?.attendance!.statusText ?? 'ON TIME',
                ),
                if (result?.nextAction != null) ...[
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(context, 12),
                  ),
                  _buildAttendanceInfoRow(
                    context,
                    'Next Action',
                    result!.nextAction!,
                  ),
                ],
              ],
            ),
          ),

          // Success Message
          if (result!.message.isNotEmpty) ...[
            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
            Container(
              width: double.infinity,
              padding: ScaleResponsiveHelper.getAllPadding(context, 12),
              decoration: BoxDecoration(
                color: result.status
                    ? AppColor.kSuccessGreen.withValues(alpha: 0.1)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(
                  ScaleResponsiveHelper.getBorderRadius(context, 8),
                ),
                border: Border.all(
                  color: result.status
                      ? AppColor.kSuccessGreen.withValues(alpha: 0.3)
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.status ? Icons.check_circle : Icons.error,
                    color: result.status
                        ? AppColor.kSuccessGreen
                        : Colors.red.shade600,
                    size: ScaleResponsiveHelper.getIconSize(context, 20),
                  ),
                  SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 8)),
                  Expanded(
                    child: Text(
                      result.message,
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          12,
                        ),
                        color: result.status
                            ? AppColor.kSuccessGreen
                            : Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 13),
            fontWeight: FontWeight.bold,
            color: AppColor.kCyanSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Continue to Home Button
        Expanded(
          flex: 2,
          child: Container(
            height: ScaleResponsiveHelper.scale(context, 48),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColor.kGradientCyanVibrant,
              ),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 12),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: ScaleResponsiveHelper.scale(context, 20),
                  spreadRadius: ScaleResponsiveHelper.scale(context, 1),
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: () {
                controller.cancelAutoRedirect();
                Get.offAllNamed(Routes.HOME);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ScaleResponsiveHelper.getBorderRadius(context, 12),
                ),
              ),
              child: Text(
                'Continue to Home',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoRedirectInfo(BuildContext context) {
    return Container(
      padding: ScaleResponsiveHelper.getSymmetricPadding(
        context,
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 20),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home,
            color: Colors.white.withValues(alpha: 0.8),
            size: ScaleResponsiveHelper.getIconSize(context, 16),
          ),
          SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 8)),
          Obx(
            () => Text(
              'Returning to home in ${controller.countdown.value}s...',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
