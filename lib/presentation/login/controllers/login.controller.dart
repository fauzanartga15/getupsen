// File: lib/presentation/login/controllers/login.controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../utils/snackbar_helper.dart';

// CATATAN: GetSingleTickerProviderMixin adalah dari Flutter (bukan Provider state management)
// Fungsinya untuk menyediakan Ticker untuk AnimationController
// Jalankan: flutter pub add shared_preferences http

class LoginController extends GetxController with GetTickerProviderStateMixin {
  // Form controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Reactive variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var errorMessage = ''.obs;

  // Animation untuk shake effect
  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  // Auth service
  final AuthService _authService = AuthService.instance;

  @override
  void onInit() {
    super.onInit();
    _setupShakeAnimation();

    // Clear any previous error when user starts typing
    emailController.addListener(_clearError);
    passwordController.addListener(_clearError);
  }

  void _setupShakeAnimation() {
    shakeController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );
  }

  void _clearError() {
    if (errorMessage.value.isNotEmpty) {
      errorMessage.value = '';
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading(true);
      errorMessage('');

      final success = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        // Login berhasil - navigasi akan ditangani oleh AuthService
        SnackbarHelper.showSuccess('Login successful!');
      }
    } catch (e) {
      // Handle error
      String message = 'Login failed. Please try again.';

      if (e.toString().contains('401')) {
        message = 'Invalid email or password';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        message = 'Network error. Please check your connection.';
      } else if (e.toString().contains('timeout')) {
        message = 'Connection timeout. Please try again.';
      }

      errorMessage(message);

      // Trigger shake animation
      shakeController.reset();
      shakeController.forward();

      // Show error snackbar
      SnackbarHelper.showError(message, title: 'Login Error');
    } finally {
      isLoading(false);
    }
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  @override
  void onClose() {
    shakeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
