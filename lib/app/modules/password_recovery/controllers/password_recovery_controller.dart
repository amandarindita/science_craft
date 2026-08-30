import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../widgets/app_snackbar.dart';

class PasswordRecoveryController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;

  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final RxInt remainingSeconds = 60.obs;
  final RxBool canResendOtp = false.obs;

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
      AppSnackbar.warning(
        'Perhatian',
        'Alamat email harus diisi terlebih dahulu!',
      );
      return;
    }

    if (!GetUtils.isEmail(emailValue)) {
      AppSnackbar.error(
        'Format Email Tidak Valid',
        'Silakan masukkan format alamat email yang benar!',
      );
      return;
    }

    isLoading.value = true;

    try {
      // Simulasi / koneksi pengiriman OTP via API
      await Future.delayed(const Duration(milliseconds: 600));

      startOtpCountdown();

      Get.toNamed(
        Routes.OTP_VERIFICATION,
        arguments: {
          'email': emailValue,
        },
      );
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengirim OTP',
        'Terjadi kesalahan saat mengirim kode OTP. Silakan coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      AppSnackbar.warning(
        'Perhatian',
        'Silakan masukkan 6 digit kode OTP!',
      );
      return;
    }

    if (otp.length != 6 || int.tryParse(otp) == null) {
      AppSnackbar.error(
        'Kode OTP Tidak Valid',
        'Kode OTP harus terdiri dari 6 angka!',
      );
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      Get.toNamed(Routes.RESET_PASSWORD);
    } catch (e) {
      AppSnackbar.error(
        'Verifikasi Gagal',
        'Kode OTP salah atau telah kedaluwarsa.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value || isLoading.value) return;

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      otpController.clear();
      startOtpCountdown();

      AppSnackbar.success(
        'OTP Berhasil Dikirim 🎉',
        'Kode OTP baru telah dikirimkan ke $email.',
      );
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengirim Ulang',
        'Kode OTP gagal dikirim ulang. Silakan coba lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      AppSnackbar.warning(
        'Perhatian',
        'Kata sandi baru dan konfirmasi kata sandi harus diisi!',
      );
      return;
    }

    if (newPassword.length < 6) {
      AppSnackbar.warning(
        'Kata Sandi Kurang Kuat',
        'Kata sandi minimal terdiri dari 6 karakter!',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppSnackbar.error(
        'Konfirmasi Kata Sandi Tidak Cocok',
        'Konfirmasi kata sandi tidak sama dengan kata sandi baru.',
      );
      return;
    }

    isLoading.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      AppSnackbar.success(
        'Kata Sandi Berhasil Diperbarui 🎉',
        'Silakan masuk menggunakan kata sandi barumu.',
      );

      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengubah Kata Sandi',
        'Terjadi kesalahan saat memperbarui kata sandi. Silakan coba lagi.',
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