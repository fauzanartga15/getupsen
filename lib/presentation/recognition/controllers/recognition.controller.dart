// File: lib/presentation/recognition/controllers/recognition.controller.dart (Enhanced)
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../../data/models/employee_model.dart';
import '../../../data/services/employee_service.dart';
import '../../../services/camera_service.dart';
import '../../../services/face_recognition_service.dart';
import '../../../utils/snackbar_helper.dart';

class RecognitionController extends GetxController {
  // Services
  final CameraService _cameraService = CameraService();
  final EmployeeService employeeService = Get.find<EmployeeService>();
  final FaceRecognitionService _faceRecognitionService =
      FaceRecognitionService();
  late final FaceDetector _faceDetector;

  // Reactive variables
  var isInitialized = false.obs;
  var isDetecting = false.obs;
  var faces = <Face>[].obs;
  var faceNames = <int, String>{}.obs;
  var faceConfidences = <int, double>{}.obs;
  var isRecognized = <int, bool>{}.obs;
  var recognizedEmployees =
      <int, EmployeeModel?>{}.obs; // NEW: Store employee data
  var selectedFaceIndex = (-1).obs; // NEW: For multiple face selection
  var errorMessage = ''.obs;
  var detectionStats = ''.obs;

  // Camera info
  var cameraInfo = ''.obs;
  var isBackCamera = true.obs;

  // Face recognition control
  var isRecognitionEnabled = true.obs;
  var recognitionStats = ''.obs;

  // Attendance button control
  var showAttendanceButton = false.obs;
  var attendanceButtonText = 'Check In'.obs;

  // Detection control
  Timer? _detectionTimer;
  Timer? _recognitionTimer;
  bool _isProcessingFrame = false;
  bool _isProcessingRecognition = false;
  bool _isTakingPicture = false;
  static const int detectionIntervalMs = 100;
  static const int recognitionIntervalMs = 1000;
  static const double confidenceThreshold = 85.0; // Increased to 85%

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
      print("Loading face recognition model...");
      final success = await _faceRecognitionService.loadModel();

      if (success) {
        print("Face recognition model loaded successfully");
      } else {
        print("Face recognition model failed to load");
      }
    } catch (e) {
      print("Error loading face recognition model: $e");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      errorMessage('');
      print("Starting camera initialization...");

      final success = await _cameraService.initialize();
      if (success) {
        isInitialized(true);
        _updateCameraInfo();
        _startDetection();
        print("Camera initialized successfully");
      } else {
        errorMessage('Gagal menginisialisasi kamera');
        print("Camera initialization failed");
      }
    } catch (e) {
      errorMessage('Error: ${e.toString()}');
      print("Camera initialization error: $e");
    }
  }

  void _updateCameraInfo() {
    cameraInfo(_cameraService.getCameraInfo());
    isBackCamera(
      _cameraService.currentCamera?.lensDirection == CameraLensDirection.back,
    );
  }

  void _startDetection() {
    if (!isInitialized.value) return;

    isDetecting(true);

    // Start face detection timer
    _detectionTimer = Timer.periodic(
      Duration(milliseconds: detectionIntervalMs),
      (_) => _processFrame(),
    );

    // Start face recognition timer
    if (isRecognitionEnabled.value) {
      _recognitionTimer = Timer.periodic(
        Duration(milliseconds: recognitionIntervalMs),
        (_) => _processRecognition(),
      );
    }

    print("Face detection and recognition started");
  }

  void _stopDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;

    _recognitionTimer?.cancel();
    _recognitionTimer = null;

    isDetecting(false);
    faces.clear();
    faceNames.clear();
    faceConfidences.clear();
    isRecognized.clear();
    recognizedEmployees.clear(); // NEW: Clear employee data
    selectedFaceIndex.value = -1; // NEW: Reset selection
    showAttendanceButton.value = false; // NEW: Hide button
    print("Face detection stopped");
  }

  // UNCHANGED: Original face detection logic
  Future<void> _processFrame() async {
    if (_isProcessingFrame || !isInitialized.value) return;
    if (_cameraService.controller == null) return;
    if (_isTakingPicture) return;

    try {
      _isProcessingFrame = true;
      _isTakingPicture = true;

      final XFile imageFile = await _cameraService.controller!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      final List<Face> detectedFaces = await _faceDetector.processImage(
        inputImage,
      );

      faces.assignAll(detectedFaces);
      _updateDetectionStats(detectedFaces.length);

      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("Frame processing error: $e");
    } finally {
      _isProcessingFrame = false;
      _isTakingPicture = false; // Reset both flags
    }
  }

  // ENHANCED: Employee recognition with face matching
  Future<void> _processRecognition() async {
    if (_isProcessingRecognition || !isInitialized.value) return;
    if (_cameraService.controller == null || faces.isEmpty) return;
    if (!_faceRecognitionService.isModelLoaded ||
        employeeService.employeesWithEmbedding.isEmpty)
      return;

    try {
      _isProcessingRecognition = true;
      print("Starting employee recognition for ${faces.length} faces...");

      final XFile imageFile = await _cameraService.controller!.takePicture();
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) return;

      // Process each detected face
      for (int i = 0; i < faces.length; i++) {
        await _recognizeEmployeeFace(i, faces[i], originalImage);
      }

      // Update stats and attendance button
      _updateRecognitionStats();
      _updateAttendanceButton();

      final tempFile = File(imageFile.path);
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    } catch (e) {
      print("Employee recognition error: $e");
    } finally {
      _isProcessingRecognition = false;
    }
  }

  // NEW: Recognize employee face
  Future<void> _recognizeEmployeeFace(
    int faceIndex,
    Face face,
    img.Image originalImage,
  ) async {
    try {
      // Crop face from image
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
      final faceBytes = Uint8List.fromList(img.encodeJpg(resizedFace));

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
        // Employee recognized
        final employee = matchResult['employee'] as EmployeeModel;
        final confidence = matchResult['confidence'] as double;

        faceNames[faceIndex] = employee.name;
        faceConfidences[faceIndex] = confidence;
        isRecognized[faceIndex] = true;
        recognizedEmployees[faceIndex] = employee;

        print(
          "Employee recognized: ${employee.name} (${confidence.toStringAsFixed(1)}%)",
        );
      } else {
        _setUnknownFace(faceIndex);
      }
    } catch (e) {
      print("Error recognizing employee face $faceIndex: $e");
      _setUnknownFace(faceIndex);
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
    recognitionStats('${recognizedCount}/${faces.length} employees recognized');
  }

  // NEW: Update attendance button visibility
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
      _updateAttendanceButtonText();
    } else {
      showAttendanceButton.value = false;
      selectedFaceIndex.value = -1;
    }
  }

  // NEW: Update attendance button text
  void _updateAttendanceButtonText() {
    if (selectedFaceIndex.value >= 0 &&
        recognizedEmployees[selectedFaceIndex.value] != null) {
      final employee = recognizedEmployees[selectedFaceIndex.value]!;
      attendanceButtonText.value = 'Check Attendance - ${employee.name}';
    } else {
      attendanceButtonText.value = 'Check Attendance';
    }
  }

  // NEW: Handle face selection for multiple faces
  void selectFace(int faceIndex) {
    if (recognizedEmployees[faceIndex] != null) {
      selectedFaceIndex.value = faceIndex;
      _updateAttendanceButtonText();
      print("Selected face: ${faceNames[faceIndex]}");
    }
  }

  // NEW: Handle attendance button press
  void handleAttendanceAction() {
    if (selectedFaceIndex.value >= 0 &&
        recognizedEmployees[selectedFaceIndex.value] != null) {
      final employee = recognizedEmployees[selectedFaceIndex.value]!;
      print("Starting attendance process for: ${employee.name}");

      // TODO: Navigate to attendance confirmation screen
      SnackbarHelper.showInfo(
        'Attendance process for ${employee.name} - Coming soon',
      );
    }
  }

  void _updateDetectionStats(int faceCount) {
    if (faceCount == 0) {
      detectionStats('Tidak ada wajah terdeteksi');
    } else if (faceCount == 1) {
      detectionStats('1 wajah terdeteksi');
    } else {
      detectionStats('$faceCount wajah terdeteksi');
    }
  }

  // UNCHANGED: Camera controls
  Future<void> switchCamera() async {
    try {
      if (!isInitialized.value) return;

      _stopDetection();
      isInitialized(false);

      final success = await _cameraService.switchCamera();

      if (success) {
        await Future.delayed(Duration(milliseconds: 500));
        _updateCameraInfo();
        isInitialized(true);
        await Future.delayed(Duration(milliseconds: 200));
        _startDetection();
      } else {
        isInitialized(true);
        _startDetection();
        SnackbarHelper.showError('Failed to switch camera');
      }
    } catch (e) {
      isInitialized(true);
      _startDetection();
      SnackbarHelper.showError('Camera switch error: ${e.toString()}');
    }
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

  // Getters (UNCHANGED)
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
    print("Disposing recognition controller...");
    _stopDetection();
    _faceDetector.close();
    _faceRecognitionService.dispose();
    _cameraService.dispose();
    super.onClose();
  }
}
