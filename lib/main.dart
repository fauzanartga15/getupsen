// File: lib/main.dart (Updated)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'data/services/attendance_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/employee_service.dart';
import 'data/services/location_service.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'utils/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AuthService first before determining initial routeprint("🚀 Initializing AuthService...");
  Get.put<AuthService>(AuthService(), permanent: true);
  Get.put<LocationService>(LocationService(), permanent: true);
  Get.put<EmployeeService>(EmployeeService(), permanent: true);
  Get.put<AttendanceService>(AttendanceService(), permanent: true);

  // 🔒 LOCK ORIENTATION TO PORTRAIT ONLY
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Wait for AuthService to load stored data
  await Future.delayed(Duration(milliseconds: 100));

  var initialRoute = await Routes.initialRoute;

  runApp(Main(initialRoute));
}

class Main extends StatelessWidget {
  final String initialRoute;
  const Main(this.initialRoute, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance Face Recognition',
      initialRoute: initialRoute,
      getPages: Nav.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: AppTheme.primaryPurple,
        scaffoldBackgroundColor: AppTheme.lightPrimary,
        appBarTheme: AppTheme.appBarTheme,
        snackBarTheme: AppTheme.snackBarTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppTheme.primaryButtonStyle,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppTheme.outlineButtonStyle,
        ),
      ),
    );
  }
}
