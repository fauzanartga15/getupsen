// File: lib/data/models/user_attendance_status_model.dart
//melihat status clock in & clock out user
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
    // FIX: Handle boolean conversion properly
    // API might send boolean as string or actual boolean
    bool parseBoolean(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      if (value is int) return value == 1;
      return false;
    }

    // Debug logging
    print("📌 DEBUG: Raw JSON data:");
    print(
      "   can_checkin raw: ${json['can_checkin']} (type: ${json['can_checkin'].runtimeType})",
    );
    print(
      "   can_checkout raw: ${json['can_checkout']} (type: ${json['can_checkout'].runtimeType})",
    );

    final canCheckinValue = parseBoolean(json['can_checkin']);
    final canCheckoutValue = parseBoolean(json['can_checkout']);

    print("📌 DEBUG: After parsing:");
    print("   canCheckin: $canCheckinValue");
    print("   canCheckout: $canCheckoutValue");

    return UserAttendanceStatus(
      canCheckin: canCheckinValue,
      canCheckout: canCheckoutValue,
      lastAction: json['last_action']?.toString() ?? 'none',
      lastActionTime: json['last_action_time']?.toString(),
    );
  }

  String get nextAction {
    if (canCheckin) return 'Check In';
    if (canCheckout) return 'Check Out';
    return 'No Action Available';
  }

  bool get canPerformAttendance => canCheckin || canCheckout;

  @override
  String toString() {
    return 'UserAttendanceStatus(canCheckin: $canCheckin, canCheckout: $canCheckout, lastAction: $lastAction)';
  }
}
