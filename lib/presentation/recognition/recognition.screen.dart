// File: lib/presentation/recognition/recognition_screen.dart (Responsive Version)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../../utils/theme/app_color.dart';
import '../../utils/helpers/responsive_helper.dart';
import '../../utils/widgets/enhanced_face_overlay_painter.dart';
import 'controllers/recognition.controller.dart';

class RecognitionScreen extends GetView<RecognitionController> {
  const RecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Employee Face Recognition',
          style: TextStyle(
            fontSize: ScaleResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        toolbarHeight: ScaleResponsiveHelper.scale(context, 56),
        actions: [
          Padding(
            padding: ScaleResponsiveHelper.getSymmetricPadding(
              context,
              horizontal: 8,
            ),
            child: IconButton(
              icon: Icon(
                Icons.pause,
                size: ScaleResponsiveHelper.getIconSize(context, 24),
              ),
              onPressed: () {
                if (controller.isInitialized.value) {
                  controller.toggleDetection();
                }
              },
              tooltip: 'Toggle Detection',
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return _buildLoadingView(context);
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorView(context);
        }

        return _buildCameraView(context);
      }),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: ScaleResponsiveHelper.scale(context, 60),
            height: ScaleResponsiveHelper.scale(context, 60),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColor.kCyanPrimary),
              strokeWidth: ScaleResponsiveHelper.scale(context, 4),
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
          Text(
            'Initializing Camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 10)),
          Text(
            'Loading employee database',
            style: TextStyle(
              color: Colors.white70,
              fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: ScaleResponsiveHelper.getAllPadding(context, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ScaleResponsiveHelper.getIconSize(context, 64),
              color: Colors.red,
            ),
            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScaleResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 10)),
            Text(
              controller.errorMessage.value,
              style: TextStyle(
                color: Colors.white70,
                fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 30)),
            SizedBox(
              width: ScaleResponsiveHelper.scale(context, 120),
              height: ScaleResponsiveHelper.scale(context, 48),
              child: ElevatedButton(
                onPressed: controller.onInit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.kCyanPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ScaleResponsiveHelper.getBorderRadius(context, 8),
                    ),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(BuildContext context) {
    return Stack(
      children: [
        // Camera preview
        _buildCameraPreview(context),

        // Face detection overlay with employee names
        _buildFaceOverlay(context),

        // Control buttons
        Positioned(
          left: ScaleResponsiveHelper.getSpacing(context, 16),
          top: ScaleResponsiveHelper.getSpacing(context, 16),
          child: _buildRecognitionToggleButton(context),
        ),

        // Info overlay
        _buildInfoOverlay(context),

        // Auto attendance countdown
        Obx(
          () => controller.autoAttendanceCountdown.value > 0
              ? _buildAutoAttendanceCountdown(context)
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCameraPreview(BuildContext context) {
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
                SizedBox(
                  width: ScaleResponsiveHelper.scale(context, 40),
                  height: ScaleResponsiveHelper.scale(context, 40),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: ScaleResponsiveHelper.scale(context, 3),
                  ),
                ),
                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),
                Text(
                  'Initializing Camera...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                  ),
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
        child: _buildProperCameraPreview(context, controller),
      );
    });
  }

  Widget _buildProperCameraPreview(
    BuildContext context,
    CameraController controller,
  ) {
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

  Widget _buildFaceOverlay(BuildContext context) {
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

  Rect _transformFaceRect(int faceIndex) {
    if (faceIndex >= controller.faces.length) return Rect.zero;

    final face = controller.faces[faceIndex];
    return face.boundingBox;
  }

  Widget _buildRecognitionToggleButton(BuildContext context) {
    final buttonSize = ScaleResponsiveHelper.scale(context, 50);

    return Obx(
      () => Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(context, 25),
          ),
        ),
        child: IconButton(
          icon: Icon(
            controller.isRecognitionEnabled.value
                ? Icons.face_retouching_natural
                : Icons.face_retouching_off,
            color: controller.isRecognitionEnabled.value
                ? AppColor.kSuccessGreen
                : Colors.grey,
            size: ScaleResponsiveHelper.getIconSize(context, 24),
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

  Widget _buildInfoOverlay(BuildContext context) {
    final bottomPadding = controller.showAttendanceButton.value
        ? ScaleResponsiveHelper.scale(context, 180)
        : ScaleResponsiveHelper.scale(context, 100);

    return Positioned(
      left: ScaleResponsiveHelper.getSpacing(context, 16),
      right: ScaleResponsiveHelper.getSpacing(context, 16),
      bottom: bottomPadding,
      child: Container(
        padding: ScaleResponsiveHelper.getAllPadding(context, 16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(
            ScaleResponsiveHelper.getBorderRadius(context, 12),
          ),
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
                    width: ScaleResponsiveHelper.scale(context, 12),
                    height: ScaleResponsiveHelper.scale(context, 12),
                    decoration: BoxDecoration(
                      color: controller.isDetecting.value
                          ? AppColor.kSuccessGreen
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ScaleResponsiveHelper.getSpacing(context, 8)),
                  Flexible(
                    child: Text(
                      controller.detectionStats.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 4)),

            // Recognition stats
            Obx(
              () => controller.recognitionStats.isNotEmpty
                  ? Text(
                      controller.recognitionStats.value,
                      style: TextStyle(
                        color: AppColor.kSuccessGreen,
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          14,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 8)),

            // Employee database info
            Obx(
              () => Text(
                '${controller.employeeService.employeesWithEmbedding.length} employees in database',
                style: TextStyle(
                  color: AppColor.kCyanPrimary,
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 11),
                ),
              ),
            ),

            // Camera info
            Obx(
              () => Text(
                controller.cameraInfo.value,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: ScaleResponsiveHelper.getFontSize(context, 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoAttendanceCountdown(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            padding: ScaleResponsiveHelper.getAllPadding(context, 24),
            margin: ScaleResponsiveHelper.getSymmetricPadding(
              context,
              horizontal: 32,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.kCyanPrimary, AppColor.kCyanSecondary],
              ),
              borderRadius: BorderRadius.circular(
                ScaleResponsiveHelper.getBorderRadius(context, 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColor.kCyanPrimary.withValues(alpha: 0.4),
                  blurRadius: ScaleResponsiveHelper.scale(context, 20),
                  spreadRadius: ScaleResponsiveHelper.scale(context, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Countdown circle
                Container(
                  width: ScaleResponsiveHelper.scale(context, 100),
                  height: ScaleResponsiveHelper.scale(context, 100),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: ScaleResponsiveHelper.scale(context, 10),
                        spreadRadius: ScaleResponsiveHelper.scale(context, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Obx(
                      () => Text(
                        controller.autoAttendanceCountdown.value.toString(),
                        style: TextStyle(
                          fontSize: ScaleResponsiveHelper.getFontSize(
                            context,
                            48,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColor.kCyanPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 20)),

                // Employee info
                if (controller.pendingEmployee != null) ...[
                  Text(
                    'Employee Detected',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(context, 8),
                  ),
                  Text(
                    controller.pendingEmployee!.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(context, 4),
                  ),
                  Text(
                    controller.pendingEmployee!.departmentName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                    ),
                  ),
                  SizedBox(
                    height: ScaleResponsiveHelper.getSpacing(context, 20),
                  ),
                ],

                // Auto message
                Text(
                  'Proceeding to attendance in...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: ScaleResponsiveHelper.getFontSize(context, 14),
                  ),
                ),

                SizedBox(height: ScaleResponsiveHelper.getSpacing(context, 16)),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: ScaleResponsiveHelper.scale(context, 48),
                  child: ElevatedButton(
                    onPressed: controller.cancelAutoAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ScaleResponsiveHelper.getBorderRadius(context, 8),
                        ),
                        side: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScaleResponsiveHelper.getFontSize(
                          context,
                          14,
                        ),
                      ),
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
