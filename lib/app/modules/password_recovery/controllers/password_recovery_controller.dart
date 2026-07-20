import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class PasswordRecoveryController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;

  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final remainingSeconds = 60.obs;
  final canResendOtp = false.obs;

  Timer? _otpTimer;

  String get email => emailController.text.trim();

  void toggleNewPasswordVisibility() {
    obscureNewPassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  Future<void> sendOtp() async {
    final emailValue = emailController.text.trim();

    if (emailValue.isEmpty) {
      Get.snackbar(
        'Email belum diisi',
        'Masukkan email akun terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(emailValue)) {
      Get.snackbar(
        'Email tidak valid',
        'Masukkan format email yang benar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: Nanti sambungkan ke API Flask untuk mengirim OTP.
      await Future.delayed(const Duration(milliseconds: 500));

      startOtpCountdown();

      Get.toNamed(
        Routes.OTP_VERIFICATION,
        arguments: {
          'email': emailValue,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'OTP gagal dikirim. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar(
        'OTP belum diisi',
        'Masukkan kode OTP yang sudah dikirim.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (otp.length != 6 || int.tryParse(otp) == null) {
      Get.snackbar(
        'OTP tidak valid',
        'Kode OTP harus terdiri dari 6 angka.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: Nanti verifikasi OTP melalui API Flask.
      await Future.delayed(const Duration(milliseconds: 500));

      Get.toNamed(Routes.RESET_PASSWORD);
    } catch (e) {
      Get.snackbar(
        'Verifikasi gagal',
        'Kode OTP salah atau sudah kedaluwarsa.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value || isLoading.value) return;

    isLoading.value = true;

    try {
      // TODO: Nanti panggil API kirim ulang OTP.
      await Future.delayed(const Duration(milliseconds: 500));

      otpController.clear();
      startOtpCountdown();

      Get.snackbar(
        'OTP dikirim ulang',
        'Kode OTP baru telah dikirim ke $email.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'OTP gagal dikirim ulang.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Password belum lengkap',
        'Isi password baru dan konfirmasi password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar(
        'Password terlalu pendek',
        'Password minimal terdiri dari 8 karakter.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Password tidak sama',
        'Konfirmasi password harus sama dengan password baru.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: Nanti sambungkan ke API Flask untuk reset password.
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        'Password berhasil diubah',
        'Silakan masuk menggunakan password baru.',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Password gagal diubah. Silakan coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void startOtpCountdown() {
    _otpTimer?.cancel();

    remainingSeconds.value = 60;
    canResendOtp.value = false;

    _otpTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (remainingSeconds.value > 0) {
          remainingSeconds.value--;
        } else {
          canResendOtp.value = true;
          timer.cancel();
        }
      },
    );
  }

  @override
  void onClose() {
    _otpTimer?.cancel();

    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.onClose();
  }
}