// File: lib/presentation/home/controllers/home.controller.dart (Updated)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../utils/snackbar_helper.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Auth service
  final AuthService _authService = AuthService.instance;

  // Animation controllers
  late AnimationController pulseController;
  late AnimationController glowController;
  late Animation<double> pulseAnimation;
  late Animation<double> glowAnimation;

  // Reactive variables
  var currentTime = ''.obs;
  var presentCount = 42.obs;
  var checkedInCount = 38.obs;
  var checkedOutCount = 15.obs;

  // Recent activity mock data
  var recentActivities = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupAnimations();
    _updateTime();
    _loadMockData();
  }

  void _setupAnimations() {
    pulseController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    glowController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut));
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final amPm = now.hour >= 12 ? 'PM' : 'AM';

    currentTime.value =
        '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $amPm';

    // Update setiap menit
    Future.delayed(Duration(minutes: 1), _updateTime);
  }

  void _loadMockData() {
    // Mock recent activities
    recentActivities.assignAll([
      {
        'name': 'John Doe - IT Department',
        'details': '✓ Checked in at 08:15 AM (On time)',
        'statusColor': 'green',
      },
      {
        'name': 'Jane Smith - HR',
        'details': '✓ Checked in at 08:23 AM (On time)',
        'statusColor': 'green',
      },
      {
        'name': 'Mike Johnson - Marketing',
        'details': '⏰ Checked in at 08:35 AM (Late)',
        'statusColor': 'orange',
      },
    ]);
  }

  // Navigation methods
  void goToFaceRecognition() {
    Get.toNamed(Routes.RECOGNITION);
  }

  // Profile & menu methods
  void showProfile() {
    final user = _authService.currentUser.value;
    if (user == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF26A69A), Color(0xFF009688)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Profile Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Profile info
              _buildProfileItem('Name', user.name),
              _buildProfileItem('Email', user.email),
              _buildProfileItem(
                'Phone',
                user.phone.isNotEmpty ? user.phone : 'Not provided',
              ),
              _buildProfileItem('Role', user.role),
              _buildProfileItem('Company ID', user.companyId.toString()),

              SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSettings() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.settings, color: Color(0xFF26A69A)),
                  SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Settings options
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera Settings'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  SnackbarHelper.showInfo('Camera settings coming soon');
                },
              ),
              ListTile(
                leading: Icon(Icons.face),
                title: Text('Face Recognition'),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.back();
                  SnackbarHelper.showInfo(
                    'Face recognition settings coming soon',
                  );
                },
              ),

              SizedBox(height: 10),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF26A69A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Logout Confirmation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Text(
                'Are you sure you want to logout from the attendance system?',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),

              SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          Get.back(); // Close dialog
                          await _authService.logout();
                          SnackbarHelper.showSuccess('Logged out successfully');
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Getters for user data
  String get userName => _authService.currentUser.value?.name ?? 'User';
  String get userInitials =>
      _authService.currentUser.value?.name
          .split(' ')
          .take(2)
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join() ??
      'EG';

  @override
  void onClose() {
    pulseController.dispose();
    glowController.dispose();
    super.onClose();
  }
}
