import '../models/attendance_result_model.dart';
import '../models/employee_model.dart';
import '../models/user_attendance_status_model.dart';

class ConfirmationHelper {
  EmployeeModel? employee;
  AttendanceResult? attendanceResult;
  UserAttendanceStatus? userStatus;
  double confidence = 0.0;

  // Helper methods for UI
  String get employeeName => employee?.name ?? 'Unknown Employee';

  String get employeePosition => employee?.positionName ?? 'Unknown Position';

  String get employeeDepartment =>
      employee?.departmentName ?? 'Unknown Department';

  String get companyName => employee?.company.name ?? 'Unknown Company';

  String get attendanceAction =>
      attendanceResult?.attendance?.actionText ?? 'Check In';

  String get attendanceStatus =>
      attendanceResult?.attendance?.statusText ?? 'PROCESSED';

  String get attendanceMessage =>
      attendanceResult?.message ?? 'Attendance recorded successfully';

  bool get isAttendanceSuccess => attendanceResult?.status ?? false;

  // Format confidence as percentage string
  String get confidenceText => '${confidence.toStringAsFixed(1)}%';

  // Get next action if available
  String? get nextAction =>
      attendanceResult?.nextAction ?? userStatus?.nextAction;

  // Get time stamp for attendance
  String get timeStamp {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  String get dateStamp {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}
