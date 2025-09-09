// File: lib/presentation/confirmation/confirmation.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_color.dart';
import '../../data/models/employee_model.dart';
import '../../infrastructure/navigation/routes.dart';
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
        child: SafeArea(
          child: SingleChildScrollView(
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
                    _buildSuccessBadge(),
                    const SizedBox(height: 20),

                    // Animated Success Icon with Countdown
                    _buildSuccessIcon(),
                    const SizedBox(height: 20),

                    // Company Info Card
                    _buildCompanyCard(),
                    const SizedBox(height: 20),

                    // Employee Card
                    _buildEmployeeCard(),
                    const SizedBox(height: 20),

                    // Attendance Details Card
                    _buildAttendanceCard(),
                    const SizedBox(height: 30),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 15),

                    // Auto Redirect Info
                    Obx(
                      () => controller.countdown.value > 0
                          ? _buildAutoRedirectInfo()
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColor.kGradientSuccess),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColor.kSuccessGreen.withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                controller.attendanceResult?.status == true
                    ? 'Attendance Successful'
                    : 'Attendance Failed',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${controller.confidence.toStringAsFixed(1)}%  Face Match',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessIcon() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Progress Ring
          Obx(
            () => SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: controller.countdownProgress,
                strokeWidth: 4,
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
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
                    size: 32,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.countdown}',
                    style: GoogleFonts.poppins(
                      color: controller.countdown <= 3
                          ? Colors.red.shade400
                          : AppColor.kCyanSecondary,
                      fontSize: 12,
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

  Widget _buildCompanyCard() {
    final employee = controller.employee;
    if (employee == null) return SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Company Logo/Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColor.kGradientCyanVibrant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.business, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Company Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.company.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColor.kTextDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  employee.cabang?.name ?? 'Main Office',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColor.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.kSuccessGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColor.kSuccessGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'VERIFIED',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColor.kSuccessGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
    final employee = controller.employee;
    if (employee == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 35,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Employee Photo
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: employee.imageUrl != null && employee.imageUrl!.isNotEmpty
                  ? Image.network(
                      employee.fullImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(employee),
                    )
                  : _buildDefaultAvatar(employee),
            ),
          ),
          const SizedBox(height: 16),

          // Employee Name
          Text(
            employee.name,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.kTextDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Employee ID
          Text(
            'ID: ${employee.nip}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColor.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Position & Department
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.kCyanPrimary.withValues(alpha: 0.1),
                  AppColor.kCyanSecondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColor.kCyanPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _buildEmployeeInfoRow('Position', employee.positionName),
                const SizedBox(height: 8),
                _buildEmployeeInfoRow('Department', employee.departmentName),
                const SizedBox(height: 8),
                _buildEmployeeInfoRow('Shift', employee.shiftName),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(EmployeeModel employee) {
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
            fontSize: 28,
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

  Widget _buildEmployeeInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
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

  Widget _buildAttendanceCard() {
    final result = controller.attendanceResult;
    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final dateString =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColor.kGradientCyanVibrant,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.access_time, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Attendance Details',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColor.kTextDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Attendance Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.kNeutralLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildAttendanceInfoRow(
                  'Action',
                  result?.attendance!.actionText ?? 'attendance',
                ),
                const SizedBox(height: 12),
                _buildAttendanceInfoRow('Time', timeString),
                const SizedBox(height: 12),
                _buildAttendanceInfoRow('Date', dateString),
                const SizedBox(height: 12),
                _buildAttendanceInfoRow(
                  'Status',
                  result?.attendance!.statusText ?? 'ON TIME',
                ),
                if (result?.nextAction != null) ...[
                  const SizedBox(height: 12),
                  _buildAttendanceInfoRow('Next Action', result!.nextAction!),
                ],
              ],
            ),
          ),

          // Success Message
          if (result!.message.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.status
                    ? AppColor.kSuccessGreen.withValues(alpha: 0.1)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
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
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.message,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
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

  Widget _buildAttendanceInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColor.kTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColor.kCyanSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Back to Recognition Button
        // Expanded(
        //   child: Container(
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: MaterialButton(
        //       onPressed: () {
        //         controller.cancelAutoRedirect();
        //         Get.back();
        //       },
        //       padding: const EdgeInsets.symmetric(vertical: 15),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Text(
        //         'Back',
        //         style: GoogleFonts.poppins(
        //           color: Colors.white,
        //           fontSize: 14,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // const SizedBox(width: 16),
        // Continue to Home Button
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColor.kGradientCyanVibrant,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: MaterialButton(
              onPressed: () {
                controller.cancelAutoRedirect();
                Get.offAllNamed(Routes.HOME);
              },
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Continue to Home',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAutoRedirectInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.home,
            color: Colors.white.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Obx(
            () => Text(
              'Returning to home in ${controller.countdown.value}s...',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
