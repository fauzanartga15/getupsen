// File: lib/presentation/recognition/recognition.screen.dart (Enhanced)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../constant/app_color.dart';
import '../../data/services/attendance_service.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/enhanced_face_overlay_painter.dart';
import 'controllers/recognition.controller.dart';

class RecognitionScreen extends GetView<RecognitionController> {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Employee Face Recognition'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.pause),
            onPressed: () {
              if (controller.isInitialized.value) {
                controller.toggleDetection();
              }
            },
            tooltip: 'Toggle Detection',
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return _buildLoadingView();
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorView();
        }

        return _buildCameraView();
      }),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColor.kCyanPrimary),
          ),
          SizedBox(height: 20),
          Text(
            'Initializing Camera...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Loading employee database',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              controller.errorMessage.value,
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: controller.onInit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kCyanPrimary,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview
        _buildCameraPreview(),

        // Face detection overlay with employee names
        _buildFaceOverlay(),

        // Control buttons
        Positioned(right: 16, top: 16, child: _buildSwitchButton()),
        Positioned(left: 16, top: 16, child: _buildRecognitionToggleButton()),

        // Info overlay
        _buildInfoOverlay(),

        // NEW: Attendance button
        // Obx(
        //   () => controller.autoAttendanceCountdown.value > 0
        //       ? _buildAutoAttendanceCountdown()
        //       : SizedBox.shrink(),
        // ),

        // Di _buildCameraView() Stack children, tambahkan:
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.orange,
            onPressed: () async {
              print("=== API TEST START ===");

              // Test 1: Check employee data
              final employees =
                  controller.employeeService.employeesWithEmbedding;
              print("Employees loaded: ${employees.length}");
              for (var emp in employees.take(3)) {
                print("- ${emp.name} (ID: ${emp.id})");
              }

              // Test 2: Check auth token
              print("Auth token: ${Get.find<AuthService>().authToken.value}");

              // Test 3: Check user status API
              if (employees.isNotEmpty) {
                final testId = employees.first.id;
                print("Testing user status for ID: $testId");
                final attendanceService = Get.find<AttendanceService>();
                final status = await attendanceService.getUserStatus(testId);
                print("User status result: $status");
                if (status != null) {
                  print("Can checkin: ${status.canCheckin}");
                  print("Can checkout: ${status.canCheckout}");
                  print("Last action: ${status.lastAction}");
                }
              }

              print("=== API TEST END ===");
            },
            child: Icon(Icons.api, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      final controller = this.controller.cameraController;

      if (!this.controller.isInitialized.value ||
          controller == null ||
          !controller.value.isInitialized) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Initializing Camera...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        key: ValueKey('camera_${this.controller.isBackCamera.value}'),
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: _buildProperCameraPreview(controller),
      );
    });
  }

  Widget _buildProperCameraPreview(CameraController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenAspectRatio = screenWidth / screenHeight;
        var cameraAspectRatio = 9 / 16;
        final scaleFactor = 1.0;

        Widget cameraWidget;

        if (cameraAspectRatio > screenAspectRatio) {
          cameraWidget = Center(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: Transform.scale(
                scale: scaleFactor,
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenWidth / cameraAspectRatio,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          cameraWidget = Center(
            child: AspectRatio(
              aspectRatio: cameraAspectRatio,
              child: Transform.scale(
                scale: scaleFactor,
                child: OverflowBox(
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: SizedBox(
                      width: screenHeight * cameraAspectRatio,
                      height: screenHeight,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return cameraWidget;
      },
    );
  }

  // ENHANCED: Face overlay with employee names and selection
  Widget _buildFaceOverlay() {
    return Positioned.fill(
      child: Obx(() {
        if (controller.faces.isEmpty) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTapDown: (details) => _handleFaceTap(details),
          child: CustomPaint(
            painter: EnhancedFaceOverlayPainter(
              faces: controller.faces,
              imageSize: controller.imageSize,
              previewSize: controller.previewSize,
              faceNames: controller.faceNames,
              faceConfidences: controller.faceConfidences,
              isRecognized: controller.isRecognized,
              selectedFaceIndex: controller.selectedFaceIndex.value,
              isBackCamera: controller.isBackCamera.value,
            ),
          ),
        );
      }),
    );
  }

  // NEW: Handle face tap for selection
  void _handleFaceTap(TapDownDetails details) {
    final tapPosition = details.localPosition;

    // Find which face was tapped
    for (int i = 0; i < controller.faces.length; i++) {
      if (controller.recognizedEmployees[i] != null) {
        // Calculate face position on screen
        final faceRect = _transformFaceRect(i);
        if (faceRect.contains(tapPosition)) {
          controller.selectFace(i);
          break;
        }
      }
    }
  }

  // Helper to transform face coordinates
  Rect _transformFaceRect(int faceIndex) {
    if (faceIndex >= controller.faces.length) return Rect.zero;

    final face = controller.faces[faceIndex];
    // This is simplified - in real implementation, use same transform logic as painter
    return face.boundingBox;
  }

  Widget _buildSwitchButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        icon: Icon(Icons.flip_camera_ios, color: Colors.white, size: 24),
        onPressed: () {
          if (controller.isInitialized.value) {
            controller.switchCamera();
          }
        },
        tooltip: 'Switch Camera',
      ),
    );
  }

  Widget _buildRecognitionToggleButton() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(25),
        ),
        child: IconButton(
          icon: Icon(
            controller.isRecognitionEnabled.value
                ? Icons.face_retouching_natural
                : Icons.face_retouching_off,
            color: controller.isRecognitionEnabled.value
                ? AppColor.kSuccessGreen
                : Colors.grey,
            size: 24,
          ),
          onPressed: () {
            if (controller.isInitialized.value) {
              controller.toggleRecognition();
            }
          },
          tooltip: controller.isRecognitionEnabled.value
              ? 'Disable Recognition'
              : 'Enable Recognition',
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: controller.showAttendanceButton.value
          ? 180
          : 100, // Adjust for button
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Detection status
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: controller.isDetecting.value
                          ? AppColor.kSuccessGreen
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    controller.detectionStats.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4),

            // Recognition stats
            Obx(
              () => controller.recognitionStats.isNotEmpty
                  ? Text(
                      controller.recognitionStats.value,
                      style: TextStyle(
                        color: AppColor.kSuccessGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            SizedBox(height: 8),

            // Employee database info
            Obx(
              () => Text(
                '${controller.employeeService.employeesWithEmbedding.length} employees in database',
                style: TextStyle(color: AppColor.kCyanPrimary, fontSize: 11),
              ),
            ),

            // Camera info
            Obx(
              () => Text(
                controller.cameraInfo.value,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Attendance button

  Widget _buildAutoAttendanceCountdown() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(24),
            margin: EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.kCyanPrimary, AppColor.kCyanSecondary],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Countdown circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Obx(
                      () => Text(
                        controller.autoAttendanceCountdown.value.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColor.kCyanPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Employee info
                if (controller.pendingEmployee != null) ...[
                  Text(
                    'Employee Detected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.pendingEmployee!.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    controller.pendingEmployee!.departmentName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 20),
                ],

                // Auto message
                Text(
                  'Proceeding to attendance in...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),

                SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.cancelAutoAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
