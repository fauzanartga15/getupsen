// File: lib/presentation/home/home.screen.dart (Updated)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constant/app_color.dart';
import 'controllers/home.controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColor.kGradientHomeBg,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header dengan time dan profile
                _buildHeader(),

                SizedBox(height: 20),

                // Company header dengan user info
                _buildCompanyHeader(),

                SizedBox(height: 25),

                // Stats grid
                _buildStatsGrid(),

                SizedBox(height: 25),

                // Main action button (Face Recognition)
                _buildMainActionButton(),

                SizedBox(height: 25),

                // Recent activity
                Expanded(child: _buildRecentActivity()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 48), // Spacer
        // Time display
        Obx(
          () => Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.currentTime.value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Profile button
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildProfileButton() {
    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: 12),
              Text('Profile', style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: 12),
              Text('Settings', style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: Offset(-20, 50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColor.kGradientCyanVibrant),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.kPrimaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(Icons.person, color: Colors.white, size: 24),
      ),
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'profile':
        controller.showProfile();
        break;
      case 'settings':
        controller.showSettings();
        break;
      case 'logout':
        controller.showLogoutConfirmation();
        break;
    }
  }

  Widget _buildCompanyHeader() {
    return Column(
      children: [
        // User avatar dengan glow animation
        AnimatedBuilder(
          animation: controller.glowAnimation,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColor.kGradientMainAction,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kPrimaryColor.withValues(
                      alpha: controller.glowAnimation.value,
                    ),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  controller.userInitials,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 15),

        Text(
          'Welcome, ${controller.userName}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextPrimary,
          ),
        ),

        SizedBox(height: 5),

        Text(
          'Employee Attendance Portal',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColor.kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildStatCard(
              'PRESENT',
              controller.presentCount.value,
              AppColor.kSuccessGreen,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              'CHECKED IN',
              controller.checkedInCount.value,
              AppColor.kAccentBlue,
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              'CHECKED OUT',
              controller.checkedOutCount.value,
              AppColor.kStatusLate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int number, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColor.kPrimaryColor,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: AppColor.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    return AnimatedBuilder(
      animation: controller.pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: controller.pulseAnimation.value,
          child: GestureDetector(
            onTap: controller.goToFaceRecognition,
            child: AnimatedBuilder(
              animation: controller.glowAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColor.kGradientMainAction,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.kPrimaryColor.withValues(
                          alpha: controller.glowAnimation.value,
                        ),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Face Recognition Ready',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Position your face to begin attendance',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColor.kTextPrimary,
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemCount: controller.recentActivities.length,
              itemBuilder: (context, index) {
                final activity = controller.recentActivities[index];
                return _buildActivityItem(
                  name: activity['name'],
                  details: activity['details'],
                  statusColor: _getColorFromString(activity['statusColor']),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String details,
    required Color statusColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColor.kTextDark,
            ),
          ),
          SizedBox(height: 2),
          Text(
            details,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColor.kTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return AppColor.kSuccessGreen;
      case 'orange':
        return AppColor.kStatusLate;
      case 'blue':
        return AppColor.kAccentBlue;
      default:
        return AppColor.kTextSecondary;
    }
  }
}
