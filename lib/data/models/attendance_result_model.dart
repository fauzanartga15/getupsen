import 'package:flutter/material.dart';

import 'attendance_data_model.dart';
import 'company_data_model.dart';
import 'user_data_model.dart';

class AttendanceResult {
  final bool status;
  final String message;
  final String title;
  final String subtitle;
  final String statusColor;
  final bool showEmployeeCard;
  final double? similarity;
  final AttendanceData? attendance;
  final UserData? user;
  final CompanyData? companyInfo;
  final String? nextAction;
  final String? expectedCheckout;

  AttendanceResult({
    required this.status,
    required this.message,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    this.showEmployeeCard = false,
    this.similarity,
    this.attendance,
    this.user,
    this.companyInfo,
    this.nextAction,
    this.expectedCheckout,
  });

  factory AttendanceResult.fromJson(Map<String, dynamic> json) {
    return AttendanceResult(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      statusColor: json['status_color'] ?? '#EF4444',
      showEmployeeCard: json['show_employee_card'] ?? false,
      similarity: json['similarity']?.toDouble(),
      attendance: json['attendance'] != null
          ? AttendanceData.fromJson(json['attendance'])
          : null,
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      companyInfo: json['company_info'] != null
          ? CompanyData.fromJson(json['company_info'])
          : null,
      nextAction: json['next_action'],
      expectedCheckout: json['expected_checkout'],
    );
  }

  Color get statusColorValue {
    try {
      return Color(int.parse(statusColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return status ? Color(0xFF10B981) : Color(0xFFEF4444);
    }
  }

  bool get isSuccess => status;
}
