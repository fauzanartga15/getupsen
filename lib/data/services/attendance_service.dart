// File: lib/data/services/attendance_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/attendance_data_model.dart';
import '../models/company_data_model.dart';
import '../../config.dart';
import '../models/user_data_model.dart';
import 'auth_service.dart';

class AttendanceService extends GetxService {
  final AuthService _authService = AuthService.instance;

  // Get user attendance status
  Future<UserAttendanceStatus?> getUserStatus(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final response = await http.get(
        Uri.parse('${baseUrl}tablet/user-status/$userId'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print("📊 User status response: ${response.statusCode}");
      print("📊 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Parsed data: $data"); // Debug tambahan

        if (data['status'] == 'success' && data['data'] != null) {
          final statusData = data['data'];
          print("🔍 Status data: $statusData"); // Debug tambahan

          final userStatus = UserAttendanceStatus.fromJson(statusData);
          print(
            "🔍 Created UserAttendanceStatus: $userStatus",
          ); // Debug tambahan

          return userStatus;
        }
      }

      return null;
    } catch (e, stackTrace) {
      print("❌ Error getting user status: $e");
      print("❌ Stack trace: $stackTrace");
      return null;
    }
  }

  // Check in user
  Future<AttendanceResult?> checkIn(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final now = DateTime.now();
      final body = {
        'user_id': userId,
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time_in':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      };

      print("📤 Check-in request: $body");

      final response = await http.post(
        Uri.parse('${baseUrl}checkin-public'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 Check-in response: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      final data = jsonDecode(response.body);
      return AttendanceResult.fromJson(data);
    } catch (e) {
      print("❌ Error checking in: $e");
      return AttendanceResult(
        status: false,
        message: 'Check-in failed: ${e.toString()}',
        title: 'Error',
        subtitle: 'Please try again',
        statusColor: '#EF4444',
      );
    }
  }

  // Check out user
  Future<AttendanceResult?> checkOut(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final now = DateTime.now();
      final body = {
        'user_id': userId,
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'time_out':
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      };

      print("📤 Check-out request: $body");

      final response = await http.post(
        Uri.parse('${baseUrl}checkout-public'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 Check-out response: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      final data = jsonDecode(response.body);
      return AttendanceResult.fromJson(data);
    } catch (e) {
      print("❌ Error checking out: $e");
      return AttendanceResult(
        status: false,
        message: 'Check-out failed: ${e.toString()}',
        title: 'Error',
        subtitle: 'Please try again',
        statusColor: '#EF4444',
      );
    }
  }
}

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
