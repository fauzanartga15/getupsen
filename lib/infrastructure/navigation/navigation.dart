import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'middlewares/auth_middleware.dart';
import 'routes.dart';

// File: lib/infrastructure/navigation/navigation.dart (Updated)

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    // Login Route (No middleware needed)
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),

    // Protected Routes (Require authentication)
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.RECOGNITION,
      page: () => const RecognitionScreen(),
      binding: RecognitionControllerBinding(),
      middlewares: [AuthMiddleware()],
    ),

    // Add more protected routes as needed
    // GetPage(
    //   name: Routes.ATTENDANCE_CARD,
    //   page: () => const AttendanceCardScreen(),
    //   binding: AttendanceCardControllerBinding(),
    //   middlewares: [AuthMiddleware()],
    // ),
    GetPage(
      name: Routes.ATTENDANCE_CONFIRMATION,
      page: () => const AttendanceConfirmationScreen(),
      binding: AttendanceConfirmationControllerBinding(),
    ),
  ];
}
