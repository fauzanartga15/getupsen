// File: lib/data/services/attendance_service.dart (Key parts - enhanced)
import 'dart:convert';
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
      print("🔑 Auth token valid: ${authToken.isNotEmpty}");

      if (authToken.isEmpty) {
        print("❌ Auth token is empty!");
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

      print("📊 User status API Response:");
      print("   URL: ${baseUrl}tablet/user-status/$userId");
      print("   Status Code: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Enhanced debugging
        print("🔍 Decoded JSON structure:");
        print("   Root keys: ${data.keys.toList()}");
        print("   Status: ${data['status']}");

        if (data['status'] == 'success' && data['data'] != null) {
          final statusData = data['data'];

          print("🔍 Status data structure:");
          print("   Keys: ${statusData.keys.toList()}");
          print(
            "   can_checkin: ${statusData['can_checkin']} (${statusData['can_checkin'].runtimeType})",
          );
          print(
            "   can_checkout: ${statusData['can_checkout']} (${statusData['can_checkout'].runtimeType})",
          );
          print("   last_action: ${statusData['last_action']}");
          print("   last_action_time: ${statusData['last_action_time']}");

          final userStatus = UserAttendanceStatus.fromJson(statusData);

          print("✅ UserAttendanceStatus created:");
          print("   canCheckin: ${userStatus.canCheckin}");
          print("   canCheckout: ${userStatus.canCheckout}");
          print("   canPerformAttendance: ${userStatus.canPerformAttendance}");
          print("   nextAction: ${userStatus.nextAction}");

          return userStatus;
        } else {
          print("❌ Invalid response structure or status");
          return null;
        }
      } else if (response.statusCode == 401) {
        print("❌ Token expired or invalid - need to re-login");
        _authService.logout();
        Get.offAllNamed(Routes.LOGIN);
        return null;
      }

      print("❌ Failed to get user status - Status: ${response.statusCode}");
      return null;
    } catch (e, stackTrace) {
      print("❌ Error getting user status: $e");
      print("❌ Stack trace: $stackTrace");
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

      print("📤 Check-in Request:");
      print("   URL: ${baseUrl}checkin-public");
      print("   User ID: $userId");
      print("   Date: ${body['date']}");
      print("   Time In: ${body['time_in']}");
      print("   Full Body: ${jsonEncode(body)}");

      // 4. Add location if available
      if (position != null) {
        body['latlon_in'] = "${position.latitude}, ${position.longitude}";

        // body['accuracy'] = position.accuracy; // Optional: tambahan info akurasi
        print("📍 Location added: ${position.latitude}, ${position.longitude}");
      } else {
        print("⚠️ No location data available for check-in");
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

      print("📥 Check-in Response:");
      print("   Status Code: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print("✅ Check-in successful:");
        print("   Status: ${result.status}");
        print("   Message: ${result.message}");
        print("   Title: ${result.title}");

        return result;
      } else if (response.statusCode == 400) {
        // 400 might mean already checked in
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print("⚠️ Check-in returned 400:");
        print("   Message: ${result.message}");

        return result;
      } else {
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
      print("❌ Exception during check-in: $e");
      print("❌ Stack trace: $stackTrace");
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

      print("📤 Check-out Request:");
      print("   URL: ${baseUrl}checkout-public");
      print("   User ID: $userId");
      print("   Date: ${body['date']}");
      print("   Time Out: ${body['time_out']}");

      //Add location if available
      if (position != null) {
        body['latlon_out'] = "${position.latitude}, ${position.longitude}";

        // body['accuracy'] = position.accuracy;
        print("📍 Location added: ${position.latitude}, ${position.longitude}");
      } else {
        print("⚠️ No location data available for check-out");
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

      print("📥 Check-out Response:");
      print("   Status Code: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print("✅ Check-out successful");
        return result;
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print("⚠️ Check-out returned 400: ${result.message}");
        return result;
      } else {
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
      print("❌ Exception during check-out: $e");
      print("❌ Stack trace: $stackTrace");
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
