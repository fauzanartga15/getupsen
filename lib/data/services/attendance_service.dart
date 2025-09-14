// File: lib/data/services/attendance_service.dart (Key parts - enhanced)
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../infrastructure/navigation/routes.dart';
import '../models/attendance_result_model.dart';
import '../../config.dart';
import '../models/user_attendance_status_model.dart';
import 'auth_service.dart';
import 'location_service.dart';

class AttendanceService extends GetxService {
  final AuthService _authService = AuthService.instance;
  final LocationService _locationService = LocationService.instance;

  // Get user attendance status with enhanced debugging
  Future<UserAttendanceStatus?> getUserStatus(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final authToken = _authService.authToken.value;
      if (kDebugMode) print("🔑 Auth token valid: ${authToken.isNotEmpty}");

      if (authToken.isEmpty) {
        if (kDebugMode) print("❌ Auth token is empty!");
        return null;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}tablet/user-status/$userId'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) print("📊 User status API Response:");
      if (kDebugMode) print("   URL: ${baseUrl}tablet/user-status/$userId");
      if (kDebugMode) print("   Status Code: ${response.statusCode}");
      if (kDebugMode) print("   Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Enhanced debugging
        if (kDebugMode) print("🔍 Decoded JSON structure:");
        if (kDebugMode) print("   Root keys: ${data.keys.toList()}");
        if (kDebugMode) print("   Status: ${data['status']}");

        if (data['status'] == 'success' && data['data'] != null) {
          final statusData = data['data'];

          if (kDebugMode) print("🔍 Status data structure:");
          if (kDebugMode) print("   Keys: ${statusData.keys.toList()}");
          if (kDebugMode)
            print(
              "   can_checkin: ${statusData['can_checkin']} (${statusData['can_checkin'].runtimeType})",
            );
          if (kDebugMode)
            print(
              "   can_checkout: ${statusData['can_checkout']} (${statusData['can_checkout'].runtimeType})",
            );
          if (kDebugMode) print("   last_action: ${statusData['last_action']}");
          if (kDebugMode)
            print("   last_action_time: ${statusData['last_action_time']}");

          final userStatus = UserAttendanceStatus.fromJson(statusData);

          if (kDebugMode) print("✅ UserAttendanceStatus created:");
          if (kDebugMode) print("   canCheckin: ${userStatus.canCheckin}");
          if (kDebugMode) print("   canCheckout: ${userStatus.canCheckout}");
          if (kDebugMode)
            print(
              "   canPerformAttendance: ${userStatus.canPerformAttendance}",
            );
          if (kDebugMode) print("   nextAction: ${userStatus.nextAction}");

          return userStatus;
        } else {
          if (kDebugMode) print("❌ Invalid response structure or status");
          return null;
        }
      } else if (response.statusCode == 401) {
        if (kDebugMode) print("❌ Token expired or invalid - need to re-login");
        _authService.logout();
        Get.offAllNamed(Routes.LOGIN);
        return null;
      }

      if (kDebugMode)
        print("❌ Failed to get user status - Status: ${response.statusCode}");
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) print("❌ Error getting user status: $e");
      if (kDebugMode) print("❌ Stack trace: $stackTrace");
      return null;
    }
  }

  // Check in user dengan validasi tambahan
  Future<AttendanceResult?> checkIn(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      // Use local time (WIB/Indonesia)
      final now = DateTime.now();
      // Note: Jika server sudah expect WIB, tidak perlu add 7 hours
      // final jakartaTime = now.add(Duration(hours: 7));
      final jakartaTime = now; // Gunakan waktu lokal device

      // Get current location
      final position = await _locationService.getCurrentLocationWithRetry();

      final body = {
        'user_id': userId,
        'date':
            '${jakartaTime.year}-${jakartaTime.month.toString().padLeft(2, '0')}-${jakartaTime.day.toString().padLeft(2, '0')}',
        'time_in':
            '${jakartaTime.hour.toString().padLeft(2, '0')}:${jakartaTime.minute.toString().padLeft(2, '0')}:${jakartaTime.second.toString().padLeft(2, '0')}',
      };

      if (kDebugMode) print("📤 Check-in Request:");
      if (kDebugMode) print("   URL: ${baseUrl}checkin-public");
      if (kDebugMode) print("   User ID: $userId");
      if (kDebugMode) print("   Date: ${body['date']}");
      if (kDebugMode) print("   Time In: ${body['time_in']}");
      if (kDebugMode) print("   Full Body: ${jsonEncode(body)}");

      // 4. Add location if available
      if (position != null) {
        body['latlon_in'] = "${position.latitude}, ${position.longitude}";

        // body['accuracy'] = position.accuracy; // Optional: tambahan info akurasi
        if (kDebugMode)
          print(
            "📍 Location added: ${position.latitude}, ${position.longitude}",
          );
      } else {
        if (kDebugMode) print("⚠️ No location data available for check-in");
        // Optional: bisa return error atau lanjut tanpa lokasi
      }

      final response = await http.post(
        Uri.parse('${baseUrl}checkin-public'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) print("📥 Check-in Response:");
      if (kDebugMode) print("   Status Code: ${response.statusCode}");
      if (kDebugMode) print("   Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        if (kDebugMode) print("✅ Check-in successful:");
        if (kDebugMode) print("   Status: ${result.status}");
        if (kDebugMode) print("   Message: ${result.message}");
        if (kDebugMode) print("   Title: ${result.title}");

        return result;
      } else if (response.statusCode == 400) {
        // 400 might mean already checked in
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        if (kDebugMode) print("⚠️ Check-in returned 400:");
        if (kDebugMode) print("   Message: ${result.message}");

        return result;
      } else {
        if (kDebugMode)
          print(
            "❌ Check-in failed with unexpected status: ${response.statusCode}",
          );
        return AttendanceResult(
          status: false,
          message: 'Check-in failed: Server returned ${response.statusCode}',
          title: 'Error',
          subtitle: 'Please try again',
          statusColor: '#EF4444',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print("❌ Exception during check-in: $e");
      if (kDebugMode) print("❌ Stack trace: $stackTrace");
      return AttendanceResult(
        status: false,
        message: 'Check-in failed: ${e.toString()}',
        title: 'Error',
        subtitle: 'Please try again',
        statusColor: '#EF4444',
      );
    }
  }

  // Check out user dengan validasi tambahan
  Future<AttendanceResult?> checkOut(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      // waktu
      final now = DateTime.now();
      final jakartaTime = now; //server sudah set otomatis

      // 2. Get current location
      final position = await _locationService.getCurrentLocationWithRetry();

      final body = {
        'user_id': userId,
        'date':
            '${jakartaTime.year}-${jakartaTime.month.toString().padLeft(2, '0')}-${jakartaTime.day.toString().padLeft(2, '0')}',
        'time_out':
            '${jakartaTime.hour.toString().padLeft(2, '0')}:${jakartaTime.minute.toString().padLeft(2, '0')}:${jakartaTime.second.toString().padLeft(2, '0')}',
      };

      if (kDebugMode) print("📤 Check-out Request:");
      if (kDebugMode) print("   URL: ${baseUrl}checkout-public");
      if (kDebugMode) print("   User ID: $userId");
      if (kDebugMode) print("   Date: ${body['date']}");
      if (kDebugMode) print("   Time Out: ${body['time_out']}");

      //Add location if available
      if (position != null) {
        body['latlon_out'] = "${position.latitude}, ${position.longitude}";

        // body['accuracy'] = position.accuracy;
        if (kDebugMode)
          print(
            "📍 Location added: ${position.latitude}, ${position.longitude}",
          );
      } else {
        if (kDebugMode) print("⚠️ No location data available for check-out");
      }

      final response = await http.post(
        Uri.parse('${baseUrl}checkout-public'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) print("📥 Check-out Response:");
      if (kDebugMode) print("   Status Code: ${response.statusCode}");
      if (kDebugMode) print("   Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        if (kDebugMode) print("✅ Check-out successful");
        return result;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        if (kDebugMode) print("⚠️ Check-out returned 400: ${result.message}");
        return result;
      } else {
        if (kDebugMode)
          print("❌ Check-out failed with status: ${response.statusCode}");
        return AttendanceResult(
          status: false,
          message: 'Check-out failed: Server returned ${response.statusCode}',
          title: 'Error',
          subtitle: 'Please try again',
          statusColor: '#EF4444',
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) print("❌ Exception during check-out: $e");
      if (kDebugMode) print("❌ Stack trace: $stackTrace");
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
