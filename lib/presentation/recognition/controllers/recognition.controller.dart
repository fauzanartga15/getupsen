// File: lib/presentation/recognition/controllers/recognition.controller.dart (Fixed Version)
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:upsen_entrance/data/services/dialog_service.dart';

import '../../../data/models/attendance_result_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/attendance_service.dart';
import '../../../data/services/camera_service.dart';
import '../../../data/services/employee_service.dart';
import '../../../data/services/face_recognition_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/helpers/snackbar_helper.dart';

class RecognitionController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  final EmployeeService employeeService = Get.find<EmployeeService>();
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();
  late final FaceDetector _faceDetector;
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  // Reactive variables
  var isInitialized = false.obs;
  var isDetecting = false.obs;
  var faces = <Face>[].obs;
  var faceNames = <int, String>{}.obs;
  var faceConfidences = <int, double>{}.obs;
  var isRecognized = <int, bool>{}.obs;
  var recognizedEmployees = <int, EmployeeModel?>{}.obs;
  var selectedFaceIndex = (-1).obs; // TETAP ADA - untuk face selection
  var errorMessage = ''.obs;
  var detectionStats = ''.obs;

  // Camera info
  var cameraInfo = ''.obs;

  // Face recognition control
  var isRecognitionEnabled = true.obs;
  var recognitionStats = ''.obs;

  // Attendance button control
  var showAttendanceButton = false.obs;

  // Auto-attendance variables
  var isAutoAttendanceEnabled = true.obs;
  var autoAttendanceCountdown = 0.obs;
  EmployeeModel? pendingEmployee;

  // Session tracking to prevent immediate "already completed" dialog
  Set<int> processedEmployeesThisSession =
      {}; // Track employees processed in this session
  bool isReturningFromConfirmation =
      false; // Flag to detect return from confirmation

  // Cooldown management
  static const int attendanceCooldown = 30; // 30 second cooldown
  Map<int, DateTime> lastAttendanceTime =
      {}; // Track last attendance per employee

  //loading
  bool isProcessingAttendance = false;

  //reactive countdown
  Timer? _detectionTimer;
  Timer? _autoAttendanceTimer;

  // Detection control
  bool _isProcessingFrame = false;
  static const int detectionIntervalMs = 500;
  static const double confidenceThreshold = 75.0;
  double? currentEmployeeConfidence; // Store confidence for current employee

  @override
  void onInit() {
    super.onInit();
    _initializeFaceDetector();
    _initializeFaceRecognitionService();
    _initializeCamera();
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableContours: false,
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: true,
    );
    _faceDetector = FaceDetector(options: options);
    print("Face detector initialized");
  }

  Future<void> _initializeFaceRecognitionService() async {
    try {
      await _faceRecognitionService.loadModel();
    } catch (e) {
      // Handle error silently atau log ke service logging
      errorMessage('Failed to load face recognition model');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Initialize front camera only
      final success = await _cameraService.initializeFrontCamera();
      if (success) {
        isInitialized(true);
        _updateCameraInfo();
        _startDetection();
      } else {
        errorMessage('Failed to initialize front camera');
      }
    } catch (e) {
      final error = 'Camera error: ${e.toString()}';
      errorMessage(error);
      _showCameraErrorDialog(error);
    }
  }

  void _updateCameraInfo() {
    cameraInfo(_cameraService.getCameraInfo());
  }

  void _startDetection() {
    if (!isInitialized.value) return;
    isDetecting(true);

    _detectionTimer = Timer.periodic(
      Duration(milliseconds: detectionIntervalMs),
      (_) => _processFrameAndRecognition(),
    );

    print("Face detection and recognition started");
  }

  Future<void> _processFrameAndRecognition() async {
    if (_isProcessingFrame || !isInitialized.value) return;
    if (_cameraService.controller == null) return;

    try {
      _isProcessingFrame = true;

      // Take photo for detection and recognition
      final XFile imageFile = await _cameraService.controller!.takePicture();

      // Step 1: Face detection
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
      final List<Face> detectedFaces = await _faceDetector.processImage(
        inputImage,
      );

      faces.assignAll(detectedFaces);
      _updateDetectionStats(detectedFaces.length);

      // Step 2: Employee recognition
      if (isRecognitionEnabled.value &&
          detectedFaces.isNotEmpty &&
          _faceRecognitionService.isModelLoaded &&
          employeeService.employeesWithEmbedding.isNotEmpty) {
        await _recognizeAllEmployeeFaces(imageFile.path, detectedFaces);
      }

      // Cleanup
      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      _updateRecognitionStats();
      _updateAttendanceButton(); // Update button visibility
    } catch (e) {
      print("Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  Future<void> _recognizeAllEmployeeFaces(
    String imagePath,
    List<Face> detectedFaces,
  ) async {
    try {
      print(
        "Starting employee recognition for ${detectedFaces.length} faces...",
      );

      final imageBytes = await File(imagePath).readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return;

      for (int i = 0; i < detectedFaces.length; i++) {
        await _recognizeEmployeeFace(i, detectedFaces[i], originalImage);
      }
    } catch (e) {
      print("Employee recognition error: $e");
    }
  }

  Future<void> _recognizeEmployeeFace(
    int faceIndex,
    Face face,
    img.Image originalImage,
  ) async {
    try {
      // Skip if already high confidence
      if (faceConfidences[faceIndex] != null &&
          faceConfidences[faceIndex]! > 90.0) {
        return;
      }

      // Crop face
      final faceBytes = _cropFaceFromImage(face, originalImage);
      if (faceBytes == null) {
        _setUnknownFace(faceIndex);
        return;
      }

      // Generate embedding
      final embedding = await _faceRecognitionService.generateEmbedding(
        faceBytes,
      );
      if (embedding == null) {
        _setUnknownFace(faceIndex);
        return;
      }

      // Match with employees
      final matchResult = employeeService.findEmployeeByEmbedding(
        embedding,
        confidenceThreshold,
      );

      if (matchResult != null) {
        final employee = matchResult['employee'] as EmployeeModel;
        final confidence = matchResult['confidence'] as double;

        // Update face data
        faceNames[faceIndex] = employee.name;
        faceConfidences[faceIndex] = confidence;
        isRecognized[faceIndex] = true;
        recognizedEmployees[faceIndex] = employee;

        print(
          "Employee recognized: ${employee.name} (${confidence.toStringAsFixed(1)}%)",
        );

        // Trigger auto-attendance
        _triggerAutoAttendance(employee);
      } else {
        _setUnknownFace(faceIndex);
      }
    } catch (e) {
      print("Error recognizing employee face $faceIndex: $e");
      _setUnknownFace(faceIndex);
    }
  }

  Uint8List? _cropFaceFromImage(Face face, img.Image originalImage) {
    try {
      final boundingBox = face.boundingBox;

      final left = boundingBox.left.toInt().clamp(0, originalImage.width - 1);
      final top = boundingBox.top.toInt().clamp(0, originalImage.height - 1);
      final width = (boundingBox.width.toInt()).clamp(
        1,
        originalImage.width - left,
      );
      final height = (boundingBox.height.toInt()).clamp(
        1,
        originalImage.height - top,
      );

      final croppedFace = img.copyCrop(
        originalImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );
      final resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

      return Uint8List.fromList(img.encodeJpg(resizedFace));
    } catch (e) {
      print("Error cropping face: $e");
      return null;
    }
  }

  void _setUnknownFace(int faceIndex) {
    faceNames[faceIndex] = 'Face ${faceIndex + 1}';
    faceConfidences[faceIndex] = 0.0;
    isRecognized[faceIndex] = false;
    recognizedEmployees[faceIndex] = null;
  }

  void _updateRecognitionStats() {
    final recognizedCount = isRecognized.values
        .where((recognized) => recognized)
        .length;
    recognitionStats('$recognizedCount/${faces.length} employees recognized');
  }

  void _updateDetectionStats(int faceCount) {
    if (faceCount == 0) {
      detectionStats('No faces detected');
    } else if (faceCount == 1) {
      detectionStats('1 face detected');
    } else {
      detectionStats('$faceCount faces detected');
    }
  }

  // Update attendance button visibility
  void _updateAttendanceButton() {
    final hasRecognizedEmployee = recognizedEmployees.values.any(
      (emp) => emp != null,
    );

    if (hasRecognizedEmployee) {
      // Auto-select first recognized face if none selected
      if (selectedFaceIndex.value == -1) {
        for (int i = 0; i < recognizedEmployees.length; i++) {
          if (recognizedEmployees[i] != null) {
            selectedFaceIndex.value = i;
            break;
          }
        }
      }
      showAttendanceButton.value = true;
    } else {
      showAttendanceButton.value = false;
      selectedFaceIndex.value = -1;
    }
  }

  // Handle face selection for multiple faces
  void selectFace(int faceIndex) {
    if (recognizedEmployees[faceIndex] != null) {
      selectedFaceIndex.value = faceIndex;
      print("Selected face: ${faceNames[faceIndex]}");
    }
  }

  void _triggerAutoAttendance(EmployeeModel employee) {
    if (!isAutoAttendanceEnabled.value) return;
    if (_autoAttendanceTimer != null) return; // Prevent multiple triggers
    if (isProcessingAttendance) {
      print("⏸️ Already processing attendance, skipping trigger");
      return;
    }

    // CHECK: Skip if employee was already processed in this session
    if (processedEmployeesThisSession.contains(employee.id)) {
      print(
        "⏭️ Employee ${employee.name} already processed in this session, skipping",
      );
      return;
    }

    // CHECK COOLDOWN - Prevent rapid re-attendance
    final lastTime = lastAttendanceTime[employee.id];
    if (lastTime != null) {
      final secondsSinceLastAttendance = DateTime.now()
          .difference(lastTime)
          .inSeconds;
      if (secondsSinceLastAttendance < attendanceCooldown) {
        print(
          "⏰ Cooldown active for ${employee.name}: ${attendanceCooldown - secondsSinceLastAttendance}s remaining",
        );
        return;
      }
    }

    pendingEmployee = employee;
    autoAttendanceCountdown.value = 3; // 3 second countdown

    print("🕐 Auto-attendance triggered for: ${employee.name}");

    // Find and store the correct confidence for this employee
    currentEmployeeConfidence = null;
    for (int i = 0; i < recognizedEmployees.length; i++) {
      if (recognizedEmployees[i]?.id == employee.id) {
        currentEmployeeConfidence = faceConfidences[i];
        break;
      }
    }

    // STOP DETECTION completely during countdown
    _stopDetectionCompletely();

    _autoAttendanceTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      autoAttendanceCountdown.value--;

      if (autoAttendanceCountdown.value <= 0) {
        timer.cancel();
        _autoAttendanceTimer = null;
        _processAutoAttendance();
      }
    });
  }

  Future<void> _processAutoAttendance() async {
    final employee = pendingEmployee;

    if (employee == null) {
      print("❌ No pending employee for auto-attendance");
      _restartDetectionWithDelay(); // Restart with delay
      return;
    }

    // MARK as processing to prevent multiple triggers
    isProcessingAttendance = true;

    try {
      // Tampilkan loading dialog
      dialog.showLoading();

      // Stop detection completely
      _stopDetectionCompletely();

      // Get user status
      final userStatus = await _attendanceService.getUserStatus(employee.id);

      if (userStatus == null) {
        SnackbarHelper.showError('Failed to get user status');
        _restartDetectionWithDelay();
        return;
      }

      // Check if no action available
      if (!userStatus.canPerformAttendance) {
        // Only show dialog if this is a fresh session (not returning from confirmation)
        if (!processedEmployeesThisSession.contains(employee.id)) {
          print(
            "ℹ️ No attendance action available for ${employee.name} - showing dialog",
          );
          _showAlreadyCompletedDialog(employee);
          // Mark as processed to prevent showing again
          processedEmployeesThisSession.add(employee.id);
        } else {
          print(
            "ℹ️ No attendance action available for ${employee.name} - already processed, skipping dialog",
          );
          _restartDetectionWithDelay();
        }
        // Still update cooldown even for completed
        lastAttendanceTime[employee.id] = DateTime.now();
        return;
      }

      // Perform attendance action
      AttendanceResult? result;

      if (userStatus.canCheckin) {
        print("📝 Performing CHECK-IN for ${employee.name}");
        result = await _attendanceService.checkIn(employee.id);
      } else if (userStatus.canCheckout) {
        print("📝 Performing CHECK-OUT for ${employee.name}");
        result = await _attendanceService.checkOut(employee.id);
      }

      // Handle result
      if (result != null && result.status) {
        print("✅ Attendance successful!");

        // UPDATE COOLDOWN - Prevent rapid re-attendance
        lastAttendanceTime[employee.id] = DateTime.now();

        //if all process successed
        // 1. Stop all processes
        _stopDetectionCompletely();

        // 2. Dispose camera properly
        await _cameraService.dispose();
        isInitialized(false);

        // 3. Clear face data
        faces.clear();
        faceNames.clear();
        faceConfidences.clear();

        // 4. Navigate to confirmation screen
        Get.toNamed(
          Routes.CONFIRMATION,
          arguments: {
            'employee': employee,
            'attendanceResult': result,
            'userStatus': userStatus,
            'confidence': currentEmployeeConfidence ?? 0.0,
          },
        );

        // DO NOT restart detection immediately!
        // Let user see confirmation screen first
        print("📱 Navigated to confirmation screen - detection paused");
      } else {
        print("❌ Attendance failed or no response");
        SnackbarHelper.showError('Attendance request failed');
        _restartDetectionWithDelay();
      }
    } catch (e) {
      SnackbarHelper.showError('Attendance process failed: ${e.toString()}');
      _restartDetectionWithDelay();
    } finally {
      pendingEmployee = null;
      isProcessingAttendance = false; // Release lock
    }
  }

  // NEW: Stop detection completely (no restart)
  void _stopDetectionCompletely() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
    isDetecting(false);
    _isProcessingFrame = false; // Also stop frame processing
    print("🛑 Face detection stopped completely for attendance");
  }

  //Restart detection with delay to prevent immediate re-trigger
  void _restartDetectionWithDelay() {
    Future.delayed(Duration(seconds: 5), () {
      if (!isDetecting.value &&
          isInitialized.value &&
          !isProcessingAttendance) {
        print("🔄 Restarting face detection after delay");
        _startDetection();
      }
    });
  }

  void _showAlreadyCompletedDialog(EmployeeModel employee) {
    dialog.showAlreadyCompleted(
      employee: employee,
      onBackToHome: () => Get.offAndToNamed(Routes.HOME),
      onRestartDetection: () => _restartDetectionWithDelay(),
    );
  }

  void _showCameraErrorDialog(String errorMessage) {
    DialogUtils.showCameraErrorDialog(
      errorMessage: errorMessage,
      onRetry: () => onInit(), // Pass onInit sebagai callback
    );
  }

  void cancelAutoAttendance() {
    _autoAttendanceTimer?.cancel();
    _autoAttendanceTimer = null;
    autoAttendanceCountdown.value = 0;
    pendingEmployee = null;
    isProcessingAttendance = false; // Release lock
    print("❌ Auto-attendance cancelled");
    _restartDetectionWithDelay(); // Use delay version
  }

  // Method to clear cooldown (for testing)
  void clearCooldown(int? employeeId) {
    if (employeeId != null) {
      lastAttendanceTime.remove(employeeId);
      print("🔄 Cooldown cleared for employee ID: $employeeId");
    } else {
      lastAttendanceTime.clear();
      print("🔄 All cooldowns cleared");
    }
  }

  // Method to check if employee is in cooldown
  bool isInCooldown(int employeeId) {
    final lastTime = lastAttendanceTime[employeeId];
    if (lastTime == null) return false;

    final secondsSinceLastAttendance = DateTime.now()
        .difference(lastTime)
        .inSeconds;
    return secondsSinceLastAttendance < attendanceCooldown;
  }

  void toggleDetection() {
    if (isDetecting.value) {
      _stopDetection();
    } else {
      _startDetection();
    }
  }

  void toggleRecognition() {
    isRecognitionEnabled(!isRecognitionEnabled.value);

    if (isDetecting.value) {
      _stopDetection();
      _startDetection();
    }
  }

  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;

    // Cancel auto-attendance
    cancelAutoAttendance();

    isDetecting(false);
    faces.clear();
    faceNames.clear();
    faceConfidences.clear();
    isRecognized.clear();
    recognizedEmployees.clear();
    selectedFaceIndex.value = -1;
    showAttendanceButton.value = false;

    print("Face detection stopped");
  }

  // Getters
  CameraController? get cameraController => _cameraService.controller;

  Size get previewSize {
    if (!isInitialized.value) return Size.zero;
    final controller = _cameraService.controller;
    if (controller == null) return Size.zero;
    return Size(
      controller.value.previewSize?.height ?? 0,
      controller.value.previewSize?.width ?? 0,
    );
  }

  Size get imageSize {
    if (!isInitialized.value) return Size.zero;
    final controller = _cameraService.controller;
    if (controller == null) return Size.zero;
    final previewSize = controller.value.previewSize;
    return Size(previewSize?.height ?? 0, previewSize?.width ?? 0);
  }

  @override
  void onClose() {
    _stopDetectionCompletely();
    cancelAutoAttendance();
    _faceDetector.close();
    _faceRecognitionService.dispose();
    _cameraService.dispose();
    super.onClose();
  }
}
