// File: lib/data/models/dashboard_model.dart

class DashboardStats {
  final String status;
  final String message;
  final DashboardData data;

  DashboardStats({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }
}

class DashboardData {
  final TodayStats today;
  final CurrentStatus currentStatus;
  final List<RecentActivity> recentActivities;

  DashboardData({
    required this.today,
    required this.currentStatus,
    required this.recentActivities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      today: TodayStats.fromJson(json['today'] ?? {}),
      currentStatus: CurrentStatus.fromJson(json['current_status'] ?? {}),
      recentActivities:
          (json['recent_activities'] as List?)
              ?.map((activity) => RecentActivity.fromJson(activity))
              .toList() ??
          [],
    );
  }
}

class TodayStats {
  final String date;
  final int totalEmployees;
  final int checkedIn;
  final int checkedOut;
  final int pendingCheckout;
  final int onTimePercentage;
  final int lateCount;
  final int earlyCheckout;
  final int absentCount;

  TodayStats({
    required this.date,
    required this.totalEmployees,
    required this.checkedIn,
    required this.checkedOut,
    required this.pendingCheckout,
    required this.onTimePercentage,
    required this.lateCount,
    required this.earlyCheckout,
    required this.absentCount,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      date: json['date'] ?? '',
      totalEmployees: json['total_employees'] ?? 0,
      checkedIn: json['checked_in'] ?? 0,
      checkedOut: json['checked_out'] ?? 0,
      pendingCheckout: json['pending_checkout'] ?? 0,
      onTimePercentage: json['on_time_percentage'] ?? 0,
      lateCount: json['late_count'] ?? 0,
      earlyCheckout: json['early_checkout'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
    );
  }
}

class CurrentStatus {
  final int onlineEmployees;
  final int inMeeting;
  final int onBreak;
  final int working;

  CurrentStatus({
    required this.onlineEmployees,
    required this.inMeeting,
    required this.onBreak,
    required this.working,
  });

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
      onlineEmployees: json['online_employees'] ?? 0,
      inMeeting: json['in_meeting'] ?? 0,
      onBreak: json['on_break'] ?? 0,
      working: json['working'] ?? 0,
    );
  }
}

class RecentActivity {
  final int userId;
  final String name;
  final String action;
  final String time;
  final String status;
  final String department;

  RecentActivity({
    required this.userId,
    required this.name,
    required this.action,
    required this.time,
    required this.status,
    required this.department,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      action: json['action'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      department: json['department'] ?? '',
    );
  }

  // Helper methods untuk UI
  String get displayName => '$name - $department';

  String get actionIcon {
    switch (action.toLowerCase()) {
      case 'checkin':
        return '✓';
      case 'checkout':
        return '✓';
      case 'absen':
        return '📋';
      default:
        return '•';
    }
  }

  String get actionText {
    switch (action.toLowerCase()) {
      case 'checkin':
        return 'Checked in';
      case 'checkout':
        return 'Checked out';
      case 'absen':
        return 'Checked out';
      default:
        return action;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'ontime':
        return 'On time';
      case 'late':
        return 'Late';
      case 'early':
        return 'Early';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'ontime':
        return 'green';
      case 'late':
        return 'orange';
      case 'early':
        return 'blue';
      default:
        return 'gray';
    }
  }

  String get details => '$actionIcon $actionText at $time ($statusText)';
}
