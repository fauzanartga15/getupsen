// File: lib/presentation/confirmation/controllers/confirmation.controller.dart
import 'dart:async';
import 'package:get/get.dart';

import '../../../data/models/employee_model.dart';
import '../../../data/models/attendance_result_model.dart';
import '../../../data/models/user_attendance_status_model.dart';
import '../../../infrastructure/navigation/routes.dart';

class ConfirmationController extends GetxController {
  // Data from arguments
  EmployeeModel? employee;
  AttendanceResult? attendanceResult;
  UserAttendanceStatus? userStatus;
  double confidence = 0.0;

  // Reactive countdown
  var countdown = 15.obs;
  Timer? _countdownTimer;
  Timer? _autoRedirectTimer;

  // Computed countdown progress for circular indicator
  double get countdownProgress => countdown.value / 15.0;

  @override
  void onInit() {
    super.onInit();
    _loadArguments();
    _startCountdown();
  }

  @override
  void onClose() {
    _autoRedirectTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }

  void _loadArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    employee = args['employee'] as EmployeeModel?;
    attendanceResult = args['attendanceResult'] as AttendanceResult?;
    userStatus = args['userStatus'] as UserAttendanceStatus?;
    confidence = (args['confidence'] as double?) ?? 0.0;

    print("✅ Confirmation loaded:");
    print("   Employee: ${employee?.name}");
    print("   Attendance Status: ${attendanceResult?.status}");
    print("   Confidence: ${confidence.toStringAsFixed(1)}%");
    print("   Message: ${attendanceResult?.message}");
  }

  void _startCountdown() {
    // Start auto redirect timer (10 seconds)
    _autoRedirectTimer = Timer(const Duration(seconds: 15), () {
      if (Get.currentRoute.contains('confirmation')) {
        _navigateToHome();
      }
    });

    // Start countdown timer (update every second)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        _navigateToHome();
      }
      print("Countdown started: ${countdown.value}");
    });
  }

  void _navigateToHome() {
    print("🏠 Navigating to home from confirmation");
    Get.offAllNamed(Routes.HOME);
  }

  void cancelAutoRedirect() {
    print("⏸️ Auto redirect cancelled");
    _autoRedirectTimer?.cancel();
    _countdownTimer?.cancel();
  }

  // // Helper methods for UI
  // String get employeeName => employee?.name ?? 'Unknown Employee';

  // String get employeePosition => employee?.positionName ?? 'Unknown Position';

  // String get employeeDepartment =>
  //     employee?.departmentName ?? 'Unknown Department';

  // String get companyName => employee?.company.name ?? 'Unknown Company';

  // String get attendanceAction =>
  //     attendanceResult?.attendance?.actionText ?? 'Check In';

  // String get attendanceStatus =>
  //     attendanceResult?.attendance?.statusText ?? 'PROCESSED';

  // String get attendanceMessage =>
  //     attendanceResult?.message ?? 'Attendance recorded successfully';

  // bool get isAttendanceSuccess => attendanceResult?.status ?? false;

  // // Format confidence as percentage string
  // String get confidenceText => '${confidence.toStringAsFixed(1)}%';

  // // Get next action if available
  // String? get nextAction =>
  //     attendanceResult?.nextAction ?? userStatus?.nextAction;

  // // Get time stamp for attendance
  // String get timeStamp {
  //   final now = DateTime.now();
  //   return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  // }

  // String get dateStamp {
  //   final now = DateTime.now();
  //   return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  // }
}
