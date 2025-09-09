// File: lib/data/services/dashboard_service.dart

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/dashboard_model.dart';
import '../../config.dart';
import 'auth_service.dart';

class DashboardService extends GetxService {
  final AuthService _authService = AuthService.instance;

  // Get dashboard statistics
  Future<DashboardStats?> getDashboardStats() async {
    try {
      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;

      print("📊 Fetching dashboard stats...");

      final response = await http
          .get(
            Uri.parse('${baseUrl}tablet/dashboard-stats'),
            headers: {
              'Authorization': 'Bearer ${_authService.authToken.value}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 30));

      print("📊 Dashboard API Response:");
      print("   Status Code: ${response.statusCode}");
      print("   Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dashboardStats = DashboardStats.fromJson(data);

        print("✅ Dashboard stats retrieved successfully");
        print(
          "   Recent activities count: ${dashboardStats.data.recentActivities.length}",
        );

        return dashboardStats;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - token expired");
        // Handle token expiry
        return null;
      } else {
        print(
          "❌ Failed to get dashboard stats - Status: ${response.statusCode}",
        );
        return null;
      }
    } catch (e) {
      print("❌ Error getting dashboard stats: $e");
      return null;
    }
  }

  // Get recent activities only (if you need just activities)
  Future<List<RecentActivity>> getRecentActivities() async {
    try {
      final dashboardStats = await getDashboardStats();
      return dashboardStats?.data.recentActivities ?? [];
    } catch (e) {
      print("❌ Error getting recent activities: $e");
      return [];
    }
  }
}
