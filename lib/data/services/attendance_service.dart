// File: lib/data/services/attendance_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../infrastructure/navigation/routes.dart';
import '../models/attendance_result_model.dart';
import '../../config.dart';
import '../models/user_attendance_status_model.dart';
import 'auth_service.dart';

class AttendanceService extends GetxService {
  final AuthService _authService = AuthService.instance;

  // Get user attendance status
  // Get user attendance status - TAMBAH DEBUG
  Future<UserAttendanceStatus?> getUserStatus(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      // DEBUG: Cek auth token
      final authToken = _authService.authToken.value;
      print("🔑 DEBUG: Auth token length: ${authToken.length}");
      print(
        "🔑 DEBUG: Auth token: ${authToken.substring(0, min(50, authToken.length))}...",
      );
      print(
        "🔑 DEBUG: AuthService isLoggedIn: ${_authService.isLoggedIn.value}",
      );
      print("🔑 DEBUG: Current user: ${_authService.currentUser.value?.name}");

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

      print("📊 User status API call: ${baseUrl}tablet/user-status/$userId");
      print("📊 User status response: ${response.statusCode}");
      print("📊 Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 Parsed data: $data");

        if (data['status'] == 'success' && data['data'] != null) {
          final statusData = data['data'];
          print("🔍 Status data: $statusData");

          final userStatus = UserAttendanceStatus.fromJson(statusData);
          print(
            "🔍 Created UserAttendanceStatus: canCheckin=${userStatus.canCheckin}, canCheckout=${userStatus.canCheckout}",
          );

          return userStatus;
        }
      } else if (response.statusCode == 401) {
        print("❌ Token expired or invalid - need to re-login");
        // Optional: Auto logout and redirect to login
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

  // Check in user - FIX TANGGAL
  Future<AttendanceResult?> checkIn(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final now = DateTime.now();
      final jakartaTime = now.add(Duration(hours: 7)); // WIB timezone

      final body = {
        'user_id': userId,
        'date':
            '${jakartaTime.year}-${jakartaTime.month.toString().padLeft(2, '0')}-${jakartaTime.day.toString().padLeft(2, '0')}',
        'time_in':
            '${jakartaTime.hour.toString().padLeft(2, '0')}:${jakartaTime.minute.toString().padLeft(2, '0')}:${jakartaTime.second.toString().padLeft(2, '0')}',
      };

      print("📤 Check-in API call: ${baseUrl}checkin-public");
      print("📤 Check-in request body: $body");
      print("📤 Current Jakarta time: $jakartaTime");

      final response = await http.post(
        Uri.parse('${baseUrl}checkin-public'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 Check-in response: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print(
          "✅ Check-in result parsed: status=${result.status}, message=${result.message}",
        );
        return result;
      } else {
        print("❌ Check-in failed with status: ${response.statusCode}");
        return AttendanceResult(
          status: false,
          message: 'Check-in failed with status ${response.statusCode}',
          title: 'Error',
          subtitle: 'Please try again',
          statusColor: '#EF4444',
        );
      }
    } catch (e, stackTrace) {
      print("❌ Error checking in: $e");
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

  // Check out user - FIX TANGGAL
  Future<AttendanceResult?> checkOut(int userId) async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      final now = DateTime.now();
      final jakartaTime = now.add(Duration(hours: 7)); // WIB timezone

      final body = {
        'user_id': userId,
        'date':
            '${jakartaTime.year}-${jakartaTime.month.toString().padLeft(2, '0')}-${jakartaTime.day.toString().padLeft(2, '0')}',
        'time_out':
            '${jakartaTime.hour.toString().padLeft(2, '0')}:${jakartaTime.minute.toString().padLeft(2, '0')}:${jakartaTime.second.toString().padLeft(2, '0')}',
      };

      print("📤 Check-out API call: ${baseUrl}checkout-public");
      print("📤 Check-out request body: $body");
      print("📤 Current Jakarta time: $jakartaTime");

      final response = await http.post(
        Uri.parse('${baseUrl}checkout-public'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print("📥 Check-out response: ${response.statusCode}");
      print("📥 Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final result = AttendanceResult.fromJson(data);

        print(
          "✅ Check-out result parsed: status=${result.status}, message=${result.message}",
        );
        return result;
      } else {
        print("❌ Check-out failed with status: ${response.statusCode}");
        return AttendanceResult(
          status: false,
          message: 'Check-out failed with status ${response.statusCode}',
          title: 'Error',
          subtitle: 'Please try again',
          statusColor: '#EF4444',
        );
      }
    } catch (e, stackTrace) {
      print("❌ Error checking out: $e");
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
