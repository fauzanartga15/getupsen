// File: lib/presentation/home/controllers/home_controller.dart (Scale Responsive Version)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/dashboard_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/dashboard_service.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/services/location_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../utils/helpers/responsive_helper.dart';
import '../../../utils/helpers/snackbar_helper.dart';
import '../../../utils/theme/app_color.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  // Auth service
  final AuthService _authService = AuthService.instance;
  final LocationService _locationService = LocationService.instance;

  // dashboard Service
  final DashboardService _dashboardService = Get.find<DashboardService>();

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

  // Loading states
  var isLoadingDashboard = false.obs;
  var isRefreshing = false.obs;

  // Dashboard data
  var dashboardStats = Rxn<DashboardStats>();
  var recentActivities = <RecentActivity>[].obs;

  // Today stats (for other parts of dashboard)
  var totalEmployees = 0.obs;
  var checkedIn = 0.obs;
  var checkedOut = 0.obs;
  var absentCount = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    _setupAnimations();
    _updateTime();
    _locationService.getCurrentLocationWithRetry();

    //dashboard
    loadDashboardData();

    // Auto refresh every 30 seconds
    _startAutoRefresh();
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

  // Load dashboard data from API
  Future<void> loadDashboardData() async {
    try {
      isLoadingDashboard(true);
      print("📄 Loading dashboard data...");

      final stats = await _dashboardService.getDashboardStats();

      if (stats != null) {
        dashboardStats.value = stats;

        // Update recent activities
        recentActivities.assignAll(stats.data.recentActivities);

        // Update today stats
        final today = stats.data.today;
        totalEmployees.value = today.totalEmployees;
        checkedIn.value = today.checkedIn;
        checkedOut.value = today.checkedOut;
        absentCount.value = today.absentCount;

        print("✅ Dashboard data loaded successfully");
        print("   Recent activities: ${recentActivities.length}");
        print("   Total employees: ${totalEmployees.value}");
      } else {
        print("❌ Failed to load dashboard data");
        // Load fallback/mock data if needed
        _loadFallbackData();
      }
    } catch (e) {
      print("❌ Error loading dashboard data: $e");
      _loadFallbackData();
    } finally {
      isLoadingDashboard(false);
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboardData() async {
    try {
      isRefreshing(true);
      await loadDashboardData();
    } finally {
      isRefreshing(false);
    }
  }

  // Auto refresh every 30 seconds
  void _startAutoRefresh() {
    // Refresh data every 30 seconds
    Stream.periodic(Duration(seconds: 30)).listen((_) {
      if (!isLoadingDashboard.value && !isRefreshing.value) {
        loadDashboardData();
      }
    });
  }

  // Load fallback data when API fails
  void _loadFallbackData() {
    print("📄 Loading fallback data...");

    // Convert mock data to RecentActivity objects for consistency
    final mockActivities = [
      RecentActivity(
        userId: 1,
        name: 'John Doe',
        action: 'checkin',
        time: '08:15',
        status: 'ontime',
        department: 'IT Department',
      ),
      RecentActivity(
        userId: 2,
        name: 'Jane Smith',
        action: 'checkin',
        time: '08:23',
        status: 'ontime',
        department: 'HR',
      ),
      RecentActivity(
        userId: 3,
        name: 'Mike Johnson',
        action: 'checkin',
        time: '08:35',
        status: 'late',
        department: 'Marketing',
      ),
    ];

    recentActivities.assignAll(mockActivities);

    // Mock today stats
    totalEmployees.value = 10;
    checkedIn.value = 3;
    checkedOut.value = 0;
    absentCount.value = 7;
  }

  // Get formatted activity data for UI (backward compatibility)
  List<Map<String, dynamic>> get formattedActivities {
    return recentActivities.map((activity) {
      return {
        'name': activity.displayName,
        'details': activity.details,
        'statusColor': activity.statusColor,
      };
    }).toList();
  }

  // Manual refresh method (can be called from UI)
  Future<void> onRefresh() async {
    await refreshDashboardData();
  }

  // Navigation methods
  void goToFaceRecognition() {
    Get.toNamed(Routes.RECOGNITION);
  }

  // Scale Responsive Profile Dialog
  void showProfile() {
    final user = _authService.currentUser.value;
    if (user == null) return;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
          ),
        ),
        child: Container(
          width: ScaleResponsiveHelper.scaleWidth(Get.context!, 350),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: ScaleResponsiveHelper.getIconSize(
                          Get.context!,
                          40,
                        ),
                        height: ScaleResponsiveHelper.getIconSize(
                          Get.context!,
                          40,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColor.kGradientCyanVibrant,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: ScaleResponsiveHelper.getIconSize(
                            Get.context!,
                            20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: ScaleResponsiveHelper.getSpacing(
                          Get.context!,
                          12,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Profile Information',
                          style: GoogleFonts.poppins(
                            fontSize: ScaleResponsiveHelper.getFontSize(
                              Get.context!,
                              18,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColor.kTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                  ),

                  // Profile info
                  _buildProfileItem(Get.context!, 'Name', user.name),
                  _buildProfileItem(Get.context!, 'Email', user.email),
                  _buildProfileItem(
                    Get.context!,
                    'Phone',
                    user.phone.isNotEmpty ? user.phone : 'Not provided',
                  ),
                  _buildProfileItem(Get.context!, 'Role', user.role),
                  _buildProfileItem(
                    Get.context!,
                    'Company ID',
                    user.companyId.toString(),
                  ),

                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                  ),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    height: ScaleResponsiveHelper.scale(Get.context!, 48),
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScaleResponsiveHelper.getBorderRadius(
                              Get.context!,
                              8,
                            ),
                          ),
                        ),
                        elevation: ScaleResponsiveHelper.scale(Get.context!, 2),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            Get.context!,
                            14,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ScaleResponsiveHelper.getSpacing(context, 4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: ScaleResponsiveHelper.scale(context, 80),
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                color: AppColor.kTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                color: AppColor.kTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Scale Responsive Settings Dialog
  void showSettings() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
          ),
        ),
        child: Container(
          width: ScaleResponsiveHelper.scaleWidth(Get.context!, 350),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: AppColor.kPrimaryColor,
                        size: ScaleResponsiveHelper.getIconSize(
                          Get.context!,
                          24,
                        ),
                      ),
                      SizedBox(
                        width: ScaleResponsiveHelper.getSpacing(
                          Get.context!,
                          12,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Settings',
                          style: GoogleFonts.poppins(
                            fontSize: ScaleResponsiveHelper.getFontSize(
                              Get.context!,
                              18,
                            ),
                            fontWeight: FontWeight.bold,
                            color: AppColor.kTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                  ),

                  // Settings options
                  _buildSettingsItem(
                    Get.context!,
                    icon: Icons.camera_alt,
                    title: 'Camera Settings',
                    onTap: () {
                      Get.back();
                      SnackbarHelper.showInfo('Camera settings coming soon');
                    },
                  ),
                  _buildSettingsItem(
                    Get.context!,
                    icon: Icons.face,
                    title: 'Face Recognition',
                    onTap: () {
                      Get.back();
                      SnackbarHelper.showInfo(
                        'Face recognition settings coming soon',
                      );
                    },
                  ),
                  _buildSettingsItem(
                    Get.context!,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Get.back();
                      SnackbarHelper.showInfo(
                        'Notification settings coming soon',
                      );
                    },
                  ),

                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                  ),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    height: ScaleResponsiveHelper.scale(Get.context!, 48),
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ScaleResponsiveHelper.getBorderRadius(
                              Get.context!,
                              8,
                            ),
                          ),
                        ),
                        elevation: ScaleResponsiveHelper.scale(Get.context!, 2),
                      ),
                      child: Text(
                        'Close',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            Get.context!,
                            14,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScaleResponsiveHelper.getSpacing(context, 12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(context, 8),
          ),
          child: Container(
            padding: ScaleResponsiveHelper.getAllPadding(context, 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: ScaleResponsiveHelper.getIconSize(context, 20),
                  color: AppColor.kTextSecondary,
                ),
                SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 16)),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                      color: AppColor.kTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: ScaleResponsiveHelper.getIconSize(context, 16),
                  color: AppColor.kTextSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Scale Responsive Logout Confirmation Dialog
  void showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(Get.context!, 16),
          ),
        ),
        child: Container(
          width: ScaleResponsiveHelper.scaleWidth(Get.context!, 350),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.9,
          ),
          child: Padding(
            padding: ScaleResponsiveHelper.getAllPadding(Get.context!, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: ScaleResponsiveHelper.getAllPadding(
                        Get.context!,
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.logout,
                        color: Colors.red.shade600,
                        size: ScaleResponsiveHelper.getIconSize(
                          Get.context!,
                          20,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ScaleResponsiveHelper.getSpacing(Get.context!, 12),
                    ),
                    Expanded(
                      child: Text(
                        'Logout Confirmation',
                        style: GoogleFonts.poppins(
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            Get.context!,
                            18,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColor.kTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                ),

                Text(
                  'Are you sure you want to logout from the attendance system?',
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(
                      Get.context!,
                      14,
                    ),
                    color: AppColor.kTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                  height: ScaleResponsiveHelper.getSpacing(Get.context!, 20),
                ),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: ScaleResponsiveHelper.scale(Get.context!, 48),
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScaleResponsiveHelper.getBorderRadius(
                                  Get.context!,
                                  8,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: AppColor.kTextSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: ScaleResponsiveHelper.getFontSize(
                                Get.context!,
                                14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ScaleResponsiveHelper.getSpacing(Get.context!, 10),
                    ),
                    Expanded(
                      child: Container(
                        height: ScaleResponsiveHelper.scale(Get.context!, 48),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade400, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(
                            ScaleResponsiveHelper.getBorderRadius(
                              Get.context!,
                              8,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            Get.back(); // Close dialog
                            await _authService.logout();
                            SnackbarHelper.showSuccess(
                              'Logged out successfully',
                            );
                            Get.offAllNamed(Routes.LOGIN);
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                ScaleResponsiveHelper.getBorderRadius(
                                  Get.context!,
                                  8,
                                ),
                              ),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: ScaleResponsiveHelper.getFontSize(
                                Get.context!,
                                14,
                              ),
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
      ),
    );
  }

  // Getters for user data
  String get userName => _authService.currentUser.value?.name ?? 'User';

  String get companyName {
    final employeeService = Get.find<EmployeeService>();

    if (employeeService.employees.isNotEmpty) {
      return employeeService.employees.first.company.name;
    }

    return 'Company';
  }

  String get companyInitials =>
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
