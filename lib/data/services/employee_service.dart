// File: lib/data/services/employee_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/employee_model.dart';
import '../../config.dart';
import 'auth_service.dart';

class EmployeeService extends GetxService {
  static const String _employeesKey = 'cached_employees';
  static const String _lastSyncKey = 'last_employee_sync';
  static const int _syncIntervalHours = 1;

  final AuthService _authService = AuthService.instance;

  // Reactive variables
  var employees = <EmployeeModel>[].obs;
  var employeesWithEmbedding = <EmployeeModel>[].obs;
  var lastSyncTime = Rxn<DateTime>();
  var isLoading = false.obs;
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedEmployees();
    _checkAutoSync();
  }

  // Load cached employees from local storage
  Future<void> _loadCachedEmployees() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_employeesKey);
      final lastSyncString = prefs.getString(_lastSyncKey);

      if (cachedData != null) {
        final List<dynamic> employeesJson = jsonDecode(cachedData);
        final List<EmployeeModel> cachedEmployees = employeesJson
            .map((json) => EmployeeModel.fromJson(json))
            .toList();

        employees.assignAll(cachedEmployees);
        employeesWithEmbedding.assignAll(
          cachedEmployees.where((emp) => emp.hasFaceEmbedding).toList(),
        );

        print("✅ Loaded ${cachedEmployees.length} cached employees");
        print(
          "✅ ${employeesWithEmbedding.length} employees with face embedding",
        );
      }

      if (lastSyncString != null) {
        lastSyncTime.value = DateTime.tryParse(lastSyncString);
      }
    } catch (e) {
      print("❌ Error loading cached employees: $e");
    }
  }

  // Save employees to local storage
  Future<void> _saveEmployeesToCache(List<EmployeeModel> employeesList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeesJson = employeesList.map((emp) => emp.toJson()).toList();

      await prefs.setString(_employeesKey, jsonEncode(employeesJson));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());

      lastSyncTime.value = DateTime.now();
      print("✅ Saved ${employeesList.length} employees to cache");
    } catch (e) {
      print("❌ Error saving employees to cache: $e");
    }
  }

  // Check if auto sync is needed
  void _checkAutoSync() {
    // Wait for auth token
    if (_authService.authToken.value.isEmpty) {
      print("⏰ Waiting for auth token...");
      Future.delayed(Duration(seconds: 1), _checkAutoSync);
      return;
    }

    final lastSync = lastSyncTime.value;
    if (lastSync == null) {
      // No previous sync, sync immediately
      print("🔄 First time sync...");
      syncEmployees();
      return;
    }

    final hoursSinceLastSync = DateTime.now().difference(lastSync).inHours;

    if (hoursSinceLastSync >= _syncIntervalHours) {
      print("🔄 Auto sync triggered - ${hoursSinceLastSync}h since last sync");
      syncEmployees();
    } else {
      print("✅ Sync not needed - ${hoursSinceLastSync}h since last sync");
    }
  }

  // Sync employees from server
  Future<bool> syncEmployees() async {
    if (isSyncing.value) return false;
    print("🔄 Starting employee sync...");

    try {
      isSyncing(true);
      print("🔄 Starting employee sync...");

      final config = ConfigEnvironments.getEnvironments();
      final baseUrl = config['url']!;
      print("🌐 Base URL: $baseUrl"); // DEBUG
      print("🔑 Auth token: ${_authService.authToken.value}"); // DEBUG

      // Fetch all users from company
      final usersResponse = await http.get(
        Uri.parse('${baseUrl}users'),
        headers: {
          'Authorization': 'Bearer ${_authService.authToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print("📡 Users API response: ${usersResponse.statusCode}"); // DEBUG
      print("📡 Response body: ${usersResponse.body} "); //Coba lagi

      if (usersResponse.statusCode == 200) {
        final usersData = jsonDecode(usersResponse.body);

        if (usersData['status'] == 'Success') {
          final List<dynamic> usersJson = usersData['data'];
          final List<EmployeeModel> allEmployees = usersJson
              .map((json) => EmployeeModel.fromJson(json))
              .toList();

          // Update reactive variables
          employees.assignAll(allEmployees);
          employeesWithEmbedding.assignAll(
            allEmployees.where((emp) => emp.hasFaceEmbedding).toList(),
          );

          // Cache employees
          await _saveEmployeesToCache(allEmployees);

          print("✅ Synced ${allEmployees.length} employees from server");
          print(
            "✅ ${employeesWithEmbedding.length} employees with face embedding",
          );

          return true;
        }
      }

      print("❌ Failed to sync employees - Status: ${usersResponse.statusCode}");
      return false;
    } catch (e) {
      print("❌ Error syncing employees: $e");
      return false;
    } finally {
      isSyncing(false);
    }
  }

  // Get employee by ID
  EmployeeModel? getEmployeeById(int id) {
    try {
      return employees.firstWhere((emp) => emp.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get employees with face embedding
  List<EmployeeModel> getEmployeesWithEmbedding() {
    return employeesWithEmbedding.toList();
  }

  // Search employee by face embedding similarity
  Map<String, dynamic>? findEmployeeByEmbedding(
    List<double> queryEmbedding,
    double confidenceThreshold,
  ) {
    if (queryEmbedding.isEmpty || employeesWithEmbedding.isEmpty) return null;

    double highestSimilarity = 0.0;
    EmployeeModel? bestMatch;

    for (final employee in employeesWithEmbedding) {
      final employeeEmbedding = employee.embeddingVector;
      if (employeeEmbedding.isEmpty) continue;

      final similarity = _calculateCosineSimilarity(
        queryEmbedding,
        employeeEmbedding,
      );

      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        bestMatch = employee;
      }
    }

    // Convert similarity to percentage
    final confidencePercentage = ((highestSimilarity + 1.0) / 2.0 * 100.0)
        .clamp(0.0, 100.0);

    if (bestMatch != null && confidencePercentage >= confidenceThreshold) {
      print(
        "✅ Employee found: ${bestMatch.name} (${confidencePercentage.toStringAsFixed(1)}%)",
      );

      return {
        'employee': bestMatch,
        'confidence': confidencePercentage,
        'similarity': highestSimilarity,
      };
    }

    print("❌ No employee match found above ${confidenceThreshold}% threshold");
    return null;
  }

  // Calculate cosine similarity
  double _calculateCosineSimilarity(
    List<double> embedding1,
    List<double> embedding2,
  ) {
    if (embedding1.length != embedding2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      norm1 += embedding1[i] * embedding1[i];
      norm2 += embedding2[i] * embedding2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  // Get sync status info
  String getSyncStatusInfo() {
    if (lastSyncTime.value == null) {
      return 'Never synced';
    }

    final hoursSinceSync = DateTime.now()
        .difference(lastSyncTime.value!)
        .inHours;

    if (hoursSinceSync < 1) {
      final minutesSinceSync = DateTime.now()
          .difference(lastSyncTime.value!)
          .inMinutes;
      return 'Synced ${minutesSinceSync}m ago';
    }

    return 'Synced ${hoursSinceSync}h ago';
  }

  // Force refresh employees (manual sync)
  Future<bool> refreshEmployees() async {
    isLoading(true);
    final result = await syncEmployees();
    isLoading(false);
    return result;
  }

  // Clear cached employees (for testing/reset)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_employeesKey);
      await prefs.remove(_lastSyncKey);

      employees.clear();
      employeesWithEmbedding.clear();
      lastSyncTime.value = null;

      print("✅ Employee cache cleared");
    } catch (e) {
      print("❌ Error clearing employee cache: $e");
    }
  }
}
