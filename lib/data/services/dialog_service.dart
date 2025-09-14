import 'package:get/get.dart';
import 'package:upsen_entrance/utils/dialog_utils.dart';

import '../models/employee_model.dart';

class DialogService {
  DialogService._();
  static final DialogService _instance = DialogService._();
  static DialogService get instance => _instance;

  /// Loading operations
  void showLoading({String? message, String? subtitle}) {
    DialogUtils.showLoading(message: message, subtitle: subtitle);
  }

  void showSimpleLoading({String? message}) {
    DialogUtils.showSimpleLoading(message: message);
  }

  void showPremiumLoading({String? message, String? subtitle}) {
    DialogUtils.showPremiumLoading(message: message, subtitle: subtitle);
  }

  void hideLoading() {
    DialogUtils.hideLoading();
  }

  /// Success operations
  void showSuccess({
    required String message,
    String? title,
    Function()? onPressed,
  }) {
    DialogUtils.showSuccess(
      message: message,
      title: title,
      onPressed: onPressed,
    );
  }

  /// Error operations
  void showError({
    required String message,
    String? title,
    Function()? onPressed,
  }) {
    DialogUtils.showError(message: message, title: title, onPressed: onPressed);
  }

  /// Confirmation operations
  void showConfirmation({
    required String message,
    String? title,
    String? confirmText,
    String? cancelText,
    Function()? onConfirm,
    Function()? onCancel,
  }) {
    DialogUtils.showConfirmation(
      message: message,
      title: title,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  /// Quick methods dengan default messages
  void showLoadingLogin() {
    showLoading(message: 'Sedang masuk...', subtitle: 'Mohon tunggu sebentar');
  }

  void showLoadingLogout() {
    showLoading(message: 'Sedang keluar...', subtitle: 'Proses logout');
  }

  void showLoadingUpload() {
    showPremiumLoading(
      message: 'Sedang mengupload...',
      subtitle: 'Jangan tutup aplikasi',
    );
  }

  void showLoadingSave() {
    showSimpleLoading(message: 'Menyimpan data...');
  }

  void showSuccessLogin() {
    showSuccess(
      title: 'Selamat Datang!',
      message: 'Login berhasil',
      onPressed: () => Get.back(),
    );
  }

  void showSuccessSave() {
    showSuccess(message: 'Data berhasil disimpan', onPressed: () => Get.back());
  }

  void showErrorNetwork() {
    showError(
      title: 'Koneksi Bermasalah',
      message: 'Periksa koneksi internet Anda',
    );
  }

  void showErrorServer() {
    showError(title: 'Server Error', message: 'Terjadi kesalahan pada server');
  }

  void showConfirmLogout({Function()? onConfirm}) {
    showConfirmation(
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      onConfirm: onConfirm,
    );
  }

  void showConfirmDelete({Function()? onConfirm, String? itemName}) {
    showConfirmation(
      title: 'Konfirmasi Hapus',
      message: 'Apakah Anda yakin ingin menghapus ${itemName ?? 'item ini'}?',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      onConfirm: onConfirm,
    );
  }

  //show complete attendance
  void showAlreadyCompleted({
    required EmployeeModel employee,
    Function()? onBackToHome,
    Function()? onRestartDetection,
    bool autoCloseAfter5Seconds = true,
  }) {
    DialogUtils.showAlreadyCompletedDialog(
      employee: employee,
      onBackToHome: onBackToHome,
      onRestartDetection: onRestartDetection,
      autoCloseAfter5Seconds: autoCloseAfter5Seconds,
    );
  }
}

// recognition controller show camera error
void showCameraError({required String errorMessage, Function()? onRetry}) {
  DialogUtils.showCameraErrorDialog(
    errorMessage: errorMessage,
    onRetry: onRetry,
  );
}

// Extension untuk akses yang lebih mudah
extension DialogExtension on GetxController {
  DialogService get dialog => DialogService.instance;
}
