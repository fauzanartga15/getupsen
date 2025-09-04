// File: lib/infrastructure/navigation/routes.dart (Updated)
import 'package:get/get.dart';
import '../../data/services/auth_service.dart';

class Routes {
  static Future<String> get initialRoute async {
    // Initialize AuthService first
    final authService = Get.put<AuthService>(AuthService(), permanent: true);
    authService.onInit();

    // Check if user is logged in
    if (authService.isLoggedIn.value) {
      print("🏠 User logged in - redirecting to HOME");
      return HOME;
    } else {
      print("🔐 User not logged in - redirecting to LOGIN");
      return LOGIN;
    }
  }

  static const LOGIN = '/login';
  static const HOME = '/home';
  static const RECOGNITION = '/recognition';
  static const ATTENDANCE_CARD = '/attendance-card';
}
