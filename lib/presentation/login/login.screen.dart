// File: lib/presentation/login/login.screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_theme.dart';
import 'controllers/login.controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.8),
              AppTheme.secondaryBlue.withValues(alpha: 0.9),
              AppTheme.accentCyan,
            ],
            stops: [0.1, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: controller.shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      controller.shakeAnimation.value *
                          10 *
                          ((controller.shakeController.value * 4) % 2 == 0
                              ? 1
                              : -1),
                      0,
                    ),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 500),
                      margin: EdgeInsets.all(24),
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusXLarge,
                        ),
                        boxShadow: AppTheme.strongShadow,
                      ),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo Section
                            _buildLogoSection(),

                            SizedBox(height: 32),

                            // Title Section
                            _buildTitleSection(),

                            SizedBox(height: 32),

                            // Error Message
                            _buildErrorMessage(),

                            // Email Field
                            _buildEmailField(),

                            SizedBox(height: 16),

                            // Password Field
                            _buildPasswordField(),

                            SizedBox(height: 32),

                            // Login Button
                            _buildLoginButton(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient.scale(0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(Icons.business_center_rounded, size: 60, color: Colors.white),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Login Tablet',
          style: AppTheme.titleLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Silakan login untuk masuk aplikasi presensi',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.darkTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: AppTheme.error,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.errorMessage.value,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox.shrink();
    });
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan email Anda',
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.lightSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.lightSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: AppTheme.error, width: 2),
        ),
        filled: true,
        fillColor: AppTheme.lightPrimary.withValues(alpha: 0.3),
      ),
      validator: controller.validateEmail,
      style: AppTheme.bodyMedium,
    );
  }

  Widget _buildPasswordField() {
    return Obx(
      () => TextFormField(
        controller: controller.passwordController,
        obscureText: !controller.isPasswordVisible.value,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Masukkan password Anda',
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.primaryPurple,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              controller.isPasswordVisible.value
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: AppTheme.darkTertiary,
            ),
            onPressed: controller.togglePasswordVisibility,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.lightSecondary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.lightSecondary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide(color: AppTheme.error, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.lightPrimary.withValues(alpha: 0.3),
        ),
        validator: controller.validatePassword,
        style: AppTheme.bodyMedium,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: controller.isLoading.value ? null : controller.login,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                alignment: Alignment.center,
                child: controller.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Login',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
