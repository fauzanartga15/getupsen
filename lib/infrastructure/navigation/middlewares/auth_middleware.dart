// File: lib/infrastructure/navigation/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = AuthService.instance;

    // Jika user belum login dan mencoba akses selain login
    if (!authService.isLoggedIn.value && route != Routes.LOGIN) {
      print("🚫 Access denied - redirecting to login");
      return RouteSettings(name: Routes.LOGIN);
    }

    // Jika user sudah login dan mencoba akses login page
    if (authService.isLoggedIn.value && route == Routes.LOGIN) {
      print("✅ Already logged in - redirecting to home");
      return RouteSettings(name: Routes.HOME);
    }

    return null; // Allow access
  }
}

// Optional: Middleware khusus untuk admin only routes
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    if (!authService.isLoggedIn.value) {
      return RouteSettings(name: Routes.LOGIN);
    }

    // Check if user is admin
    final user = authService.currentUser.value;
    if (user == null || !user.isAdmin) {
      print("🚫 Admin access required");
      // Could redirect to unauthorized page or home
      return RouteSettings(name: Routes.HOME);
    }

    return null;
  }
}
