import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/api_client.dart';
import '../../../data/api_service.dart';
import '../../../data/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_snackbar.dart';

class PasswordRecoveryController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isRegistration = false.obs;
  final RxString emailText = ''.obs;

  String username = '';
  String password = '';

  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  final RxInt remainingSeconds = 60.obs;
  final RxBool canResendOtp = false.obs;

  Timer? _otpTimer;

  String get email =>
      emailText.value.isNotEmpty ? emailText.value : emailController.text.trim();

  @override
  void onInit() {
    super.onInit();
    initFromArguments();
  }

  void initFromArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['email'] != null) {
        final emailStr = args['email'].toString();
        emailController.text = emailStr;
        emailText.value = emailStr;
      }
      if (args['isRegistration'] == true) {
        isRegistration.value = true;
      } else if (args['isRegistration'] == false) {
        isRegistration.value = false;
      }
      if (args['username'] != null) {
        username = args['username'].toString();
      }
      if (args['password'] != null) {
        password = args['password'].toString();
      }
      if (args['otp'] != null) {
        otpController.text = args['otp'].toString();
      }
    }
    startOtpCountdown();
  }

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
      final targetUrl =
          Uri.parse('${ApiService.baseUrl}/auth/forgot-password/request-otp');
      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailValue}),
      );

      final resData = ApiClient.decodeMap(response.body);

      if (response.statusCode == 200) {
        startOtpCountdown();
        AppSnackbar.success(
          'Kode OTP Terkirim ✉️',
          resData['message'] ??
              'Kode OTP reset password telah dikirim ke email kamu.',
        );
        Get.toNamed(
          Routes.OTP_VERIFICATION,
          arguments: {
            'email': emailValue,
            'isRegistration': false,
          },
        );
      } else {
        final String message = resData['error'] ??
            resData['message'] ??
            'Gagal mengirim kode OTP.';
        AppSnackbar.error('Gagal Mengirim OTP', message);
      }
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengirim OTP',
        'Terjadi kesalahan saat mengirim kode OTP: ${e.toString().split('\n').first}',
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
      if (isRegistration.value) {
        await authService.verifyRegisterOtp(email, otp);
      } else {
        // Alur Lupa Password: Langsung arahkan ke halaman reset password
        Get.toNamed(
          Routes.RESET_PASSWORD,
          arguments: {
            'email': email,
            'otp': otp,
          },
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (!canResendOtp.value || isLoading.value) return;

    isLoading.value = true;

    try {
      if (isRegistration.value) {
        final targetUrl = Uri.parse('${ApiService.baseUrl}/auth/register');
        final response = await http.post(
          targetUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username.isNotEmpty ? username : 'User',
            'email': email,
            'password': password.isNotEmpty ? password : 'password123',
          }),
        );
        final resData = ApiClient.decodeMap(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          otpController.clear();
          startOtpCountdown();
          AppSnackbar.success(
            'OTP Berhasil Dikirim 🎉',
            resData['message'] ?? 'Kode OTP baru telah dikirimkan ke $email.',
          );
        } else {
          final String message = resData['error'] ??
              resData['message'] ??
              'Gagal mengirim ulang OTP.';
          AppSnackbar.error('Gagal Mengirim Ulang', message);
        }
      } else {
        final targetUrl =
            Uri.parse('${ApiService.baseUrl}/auth/forgot-password/request-otp');
        final response = await http.post(
          targetUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        );
        final resData = ApiClient.decodeMap(response.body);
        if (response.statusCode == 200) {
          otpController.clear();
          startOtpCountdown();
          AppSnackbar.success(
            'OTP Berhasil Dikirim 🎉',
            resData['message'] ?? 'Kode OTP baru telah dikirimkan ke $email.',
          );
        } else {
          final String message = resData['error'] ??
              resData['message'] ??
              'Gagal mengirim ulang OTP.';
          AppSnackbar.error('Gagal Mengirim Ulang', message);
        }
      }
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengirim Ulang',
        'Kode OTP gagal dikirim ulang: ${e.toString().split('\n').first}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;
    final otp = otpController.text.trim();

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
      final targetUrl =
          Uri.parse('${ApiService.baseUrl}/auth/forgot-password/reset');
      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      final resData = ApiClient.decodeMap(response.body);

      if (response.statusCode == 200) {
        AppSnackbar.success(
          'Kata Sandi Berhasil Diperbarui 🎉',
          resData['message'] ??
              'Silakan masuk menggunakan kata sandi barumu.',
        );
        Get.offAllNamed(Routes.LOGIN);
      } else {
        final String message = resData['error'] ??
            resData['message'] ??
            'Gagal memperbarui kata sandi.';
        AppSnackbar.error('Gagal Mengubah Kata Sandi', message);
      }
    } catch (e) {
      AppSnackbar.error(
        'Gagal Mengubah Kata Sandi',
        'Terjadi kesalahan saat memperbarui kata sandi: ${e.toString().split('\n').first}',
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