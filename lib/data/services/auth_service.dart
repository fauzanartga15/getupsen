// File: lib/data/services/auth_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../infrastructure/navigation/routes.dart';
import '../models/user_model.dart';
import '../../config.dart';

class AuthService extends GetxService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService();
    return _instance!;
  }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _companyIdKey = 'company_id';

  // Reactive user data
  var currentUser = Rxn<UserModel>();
  var authToken = ''.obs;
  var companyId = 0.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStoredAuth();
  }

  // Load stored authentication data
  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);
      final storedCompanyId = prefs.getInt(_companyIdKey);

      if (token != null && userData != null) {
        authToken.value = token;
        companyId.value = storedCompanyId ?? 0;

        final userJson = jsonDecode(userData);
        currentUser.value = UserModel.fromJson(userJson);
        isLoggedIn.value = true;

        print("✅ Loaded stored auth: ${currentUser.value?.name}");
      }
    } catch (e) {
      print("❌ Error loading stored auth: $e");
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(String token, UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setInt(_companyIdKey, user.companyId);

      authToken.value = token;
      currentUser.value = user;
      companyId.value = user.companyId;
      isLoggedIn.value = true;

      await Future.delayed(Duration(milliseconds: 50));

      print("✅ Auth data saved: ${user.name}");
    } catch (e) {
      print("❌ Error saving auth data: $e");
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    try {
      print("🔐 Attempting login for: $email");

      final config = ConfigEnvironments.getEnvironments();
      final url = Uri.parse('${config['url']}login-tablet');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 30));

      print("📡 Login response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Login successful");

        // Parse user data
        final user = UserModel.fromJson(data['user']);
        final token = data['token'] as String;

        // Save authentication data
        await _saveAuthData(token, user);

        // Auto navigate setelah login sukses
        Get.offAllNamed(Routes.HOME);

        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      print("❌ Login error: $e");

      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Network error');
      }

      rethrow;
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      print("🚪 Logging out user: ${currentUser.value?.name}");

      final prefs = await SharedPreferences.getInstance();

      // Clear stored data
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_companyIdKey);

      // Reset reactive variables
      authToken.value = '';
      currentUser.value = null;
      companyId.value = 0;
      isLoggedIn.value = false;

      print("✅ Logout successful");
    } catch (e) {
      print("❌ Logout error: $e");
    }
  }

  // Check if token is valid (optional - for future API validation)
  Future<bool> validateToken() async {
    if (authToken.value.isEmpty) return false;

    try {
      // TODO: Add API call to validate token
      // For now, just check if token exists
      return authToken.value.isNotEmpty;
    } catch (e) {
      print("❌ Token validation error: $e");
      return false;
    }
  }

  // Get authorization header for API calls
  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${authToken.value}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
