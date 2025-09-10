// File: lib/presentation/home/home_screen.dart (Scale Responsive Version)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/theme/app_color.dart';
import '../../utils/helpers/responsive_helper.dart';
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
        child: SafeArea(child: _buildScaledContent(context)),
      ),
      // Debug info in development mode
      // floatingActionButton: kDebugMode
      //     ? FloatingActionButton(
      //         mini: true,
      //         onPressed: () => _showDebugInfo(context),
      //         child: Icon(Icons.info),
      //       )
      //     : null,
    );
  }

  Widget _buildScaledContent(BuildContext context) {
    // Check if content needs scrolling
    final needsScroll = ScaleResponsiveHelper.needsScrolling(context);

    final content = Padding(
      padding: ScaleResponsiveHelper.getAllPadding(context, 20.0),
      child: Column(
        children: [
          // Header dengan time dan profile
          _buildHeader(context),

          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

          // Company header dengan user info
          _buildCompanyHeader(context),

          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 25)),

          // Stats grid
          _buildStatsGrid(context),

          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 25)),

          // Main action button (Face Recognition)
          _buildMainActionButton(context),

          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 25)),

          // Recent activity
          Expanded(child: _buildRecentActivity(context)),
        ],
      ),
    );

    // Wrap with scroll view if needed
    if (needsScroll) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(child: content),
        ),
      );
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: ScaleResponsiveHelper.getIconSize(context, 48),
        ), // Spacer
        // Time display
        Obx(
          () => Container(
            padding: ScaleResponsiveHelper.getSymmetricPadding(
              context,
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 8),
              ),
            ),
            child: Text(
              controller.currentTime.value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Profile button
        _buildProfileButton(context),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final buttonSize = ScaleResponsiveHelper.getIconSize(context, 48);
    final iconSize = ScaleResponsiveHelper.getIconSize(context, 24);

    return PopupMenuButton<String>(
      onSelected: _handleMenuSelection,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: ScaleResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: ScaleResponsiveHelper.getIconSize(context, 20),
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),
              Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                ),
              ),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                size: ScaleResponsiveHelper.getIconSize(context, 20),
                color: Colors.red,
              ),
              SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 12),
        ),
      ),
      offset: Offset(-20, ScaleResponsiveHelper.getSpacing(context, 50)),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColor.kGradientCyanVibrant),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.kPrimaryColor.withValues(alpha: 0.3),
              blurRadius: ScaleResponsiveHelper.getSpacing(context, 8),
              spreadRadius: ScaleResponsiveHelper.getSpacing(context, 1),
            ),
          ],
        ),
        child: Icon(Icons.person, color: Colors.white, size: iconSize),
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

  Widget _buildCompanyHeader(BuildContext context) {
    final avatarSize = ScaleResponsiveHelper.getIconSize(context, 80);
    final avatarRadius = ScaleResponsiveHelper.getBorderRadius(context, 20);
    final initialsSize = ScaleResponsiveHelper.getFontSize(context, 24);

    return Column(
      children: [
        // User avatar dengan glow animation
        AnimatedBuilder(
          animation: controller.glowAnimation,
          builder: (context, child) {
            return Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColor.kGradientMainAction,
                ),
                borderRadius: BorderRadius.circular(avatarRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kPrimaryColor.withValues(
                      alpha: controller.glowAnimation.value,
                    ),
                    blurRadius: ScaleResponsiveHelper.getSpacing(context, 25),
                    spreadRadius: ScaleResponsiveHelper.getSpacing(context, 2),
                  ),
                ],
              ),

              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "https://media.istockphoto.com/id/1216157391/id/vektor/desain-logo-huruf-abstrak-e.jpg?s=612x612&w=0&k=20&c=8pnn3QjF5AmHNJ6GqetPeS4uCaGCNFIg-UnAU6hPPRA=",
                    width: initialsSize * 2,
                    height: initialsSize * 2,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 15)),

        Text(
          'Welcome,',
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
            fontWeight: FontWeight.w500,
            color: AppColor.kTextPrimary,
          ),
        ),
        Text(
          controller.companyName,
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: AppColor.kPrimaryColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 5)),

        Text(
          'Employee Attendance Portal',
          style: GoogleFonts.poppins(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
            color: AppColor.kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final spacing = ScaleResponsiveHelper.getSpacing(context, 10);

    return Row(
      children: [
        Expanded(
          child: Obx(
            () => _buildStatCard(
              context,
              'PRESENT',
              controller.presentCount.value,
              AppColor.kSuccessGreen,
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              context,
              'CHECKED IN',
              controller.checkedInCount.value,
              AppColor.kAccentBlue,
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Obx(
            () => _buildStatCard(
              context,
              'CHECKED OUT',
              controller.checkedOutCount.value,
              AppColor.kStatusLate,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int number,
    Color color,
  ) {
    return Container(
      padding: ScaleResponsiveHelper.getAllPadding(context, 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 12),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: ScaleResponsiveHelper.getSpacing(context, 15),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number.toString(),
            style: GoogleFonts.poppins(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: AppColor.kPrimaryColor,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 5)),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: ScaleResponsiveHelper.getFontSize(context, 9),
              color: AppColor.kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context) {
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
                  padding: ScaleResponsiveHelper.getAllPadding(context, 25),
                  decoration: BoxDecoration(
                    gradient: AppColor.buttonGradient,
                    borderRadius: BorderRadius.circular(
                      ScaleResponsiveHelper.getBorderRadius(context, 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.kPrimaryColor.withValues(
                          alpha: controller.glowAnimation.value,
                        ),
                        blurRadius: ScaleResponsiveHelper.getSpacing(
                          context,
                          25,
                        ),
                        spreadRadius: ScaleResponsiveHelper.getSpacing(
                          context,
                          2,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: ScaleResponsiveHelper.getIconSize(context, 40),
                      ),
                      SizedBox(
                        height: ScaleResponsiveHelper.getSpacing(context, 10),
                      ),
                      Text(
                        'Face Recognition Ready',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            context,
                            18,
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: ScaleResponsiveHelper.getSpacing(context, 5),
                      ),
                      Text(
                        'Position your face to begin attendance',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            context,
                            12,
                          ),
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

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: GoogleFonts.poppins(
                fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: AppColor.kTextPrimary,
              ),
            ),
            // Add refresh button
            Obx(
              () => controller.isRefreshing.value
                  ? SizedBox(
                      width: ScaleResponsiveHelper.getIconSize(context, 16),
                      height: ScaleResponsiveHelper.getIconSize(context, 16),
                      child: CircularProgressIndicator(
                        strokeWidth: ScaleResponsiveHelper.scale(context, 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: ScaleResponsiveHelper.getIconSize(context, 18),
                      ),
                      onPressed: controller.onRefresh,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
            ),
          ],
        ),
        SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 10)),
        Expanded(
          child: Obx(() {
            // Show loading state
            if (controller.isLoadingDashboard.value &&
                controller.recentActivities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: ScaleResponsiveHelper.getSpacing(context, 8),
                    ),
                    Text(
                      'Loading activities...',
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          12,
                        ),
                        color: AppColor.kTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (controller.recentActivities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: ScaleResponsiveHelper.getIconSize(context, 48),
                      color: AppColor.kTextSecondary.withValues(alpha: 0.5),
                    ),
                    SizedBox(
                      height: ScaleResponsiveHelper.getSpacing(context, 8),
                    ),
                    Text(
                      'No recent activity',
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          14,
                        ),
                        color: AppColor.kTextSecondary,
                      ),
                    ),
                    SizedBox(
                      height: ScaleResponsiveHelper.getSpacing(context, 4),
                    ),
                    Text(
                      'Activities will appear here',
                      style: GoogleFonts.poppins(
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          12,
                        ),
                        color: AppColor.kTextSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show activity list
            return RefreshIndicator(
              onRefresh: controller.onRefresh,
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: controller.recentActivities.length,
                itemBuilder: (context, index) {
                  final activity = controller.recentActivities[index];
                  return _buildActivityItem(
                    context,
                    name: activity.displayName,
                    details: activity.details,
                    statusColor: _getColorFromString(activity.statusColor),
                    timestamp: activity.time,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String name,
    required String details,
    required Color statusColor,
    String? timestamp,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScaleResponsiveHelper.getSpacing(context, 8),
      ),
      padding: ScaleResponsiveHelper.getAllPadding(context, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScaleResponsiveHelper.getBorderRadius(context, 8),
        ),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: ScaleResponsiveHelper.getSpacing(context, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: ScaleResponsiveHelper.scale(context, 8),
            height: ScaleResponsiveHelper.scale(context, 8),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 12)),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextPrimary,
                  ),
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 2)),
                Text(
                  details,
                  style: GoogleFonts.poppins(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 11),
                    color: AppColor.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Timestamp
          if (timestamp != null) ...[
            SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 8)),
            Text(
              timestamp,
              style: GoogleFonts.poppins(
                fontSize: ScaleResponsiveHelper.getFontSize(context, 10),
                color: AppColor.kTextSecondary.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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

  /*
  void _showDebugInfo(BuildContext context) {
    final info = ScaleResponsiveHelper.getDeviceInfo(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scale Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Type: ${info['deviceType']}'),
            Text(
              'Screen Size: ${info['screenWidth'].toStringAsFixed(0)}x${info['screenHeight'].toStringAsFixed(0)}',
            ),
            Text('Scale Factor: ${info['scaleFactor'].toStringAsFixed(3)}'),
            Text('Width Scale: ${info['widthScale'].toStringAsFixed(3)}'),
            Text('Height Scale: ${info['heightScale'].toStringAsFixed(3)}'),
            SizedBox(height: 10),
            Text('Base Design: 375x812 (iPhone 11)'),
            Text(
              'Needs Scrolling: ${ScaleResponsiveHelper.needsScrolling(context)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
*/
}
