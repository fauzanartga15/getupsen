// Data models
class UserAttendanceStatus {
  final bool canCheckin;
  final bool canCheckout;
  final String lastAction;
  final String? lastActionTime;

  UserAttendanceStatus({
    required this.canCheckin,
    required this.canCheckout,
    required this.lastAction,
    this.lastActionTime,
  });

  factory UserAttendanceStatus.fromJson(Map<String, dynamic> json) {
    return UserAttendanceStatus(
      canCheckin: json['can_checkin'] ?? false,
      canCheckout: json['can_checkout'] ?? false,
      lastAction: json['last_action'] ?? 'none',
      lastActionTime: json['last_action_time'],
    );
  }

  String get nextAction {
    if (canCheckin) return 'Check In';
    if (canCheckout) return 'Check Out';
    return 'No Action Available';
  }

  bool get canPerformAttendance => canCheckin || canCheckout;
}
