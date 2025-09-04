class AttendanceData {
  final int userId;
  final String attendanceType;
  final String date;
  final int type; // 1 = check in, 2 = check out
  final String? timeIn;
  final String? timeOut;
  final String statusPlace;
  final String statusTime;
  final String? delay;

  AttendanceData({
    required this.userId,
    required this.attendanceType,
    required this.date,
    required this.type,
    this.timeIn,
    this.timeOut,
    required this.statusPlace,
    required this.statusTime,
    this.delay,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      userId: json['user_id'] ?? 0,
      attendanceType: json['attandence_type'] ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? 1,
      timeIn: json['time_in'],
      timeOut: json['time_out'],
      statusPlace: json['status_place'] ?? '',
      statusTime: json['status_time'] ?? '',
      delay: json['delay'],
    );
  }

  String get actionText => type == 1 ? 'Check In' : 'Check Out';
  String get timeText => type == 1 ? (timeIn ?? '') : (timeOut ?? '');

  String get statusText {
    if (statusTime == 'ontime') return 'ON TIME';
    if (statusTime == 'late') return 'LATE';
    return statusTime.toUpperCase();
  }
}
