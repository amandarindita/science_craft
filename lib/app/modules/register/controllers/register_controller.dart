import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/auth_service.dart';
import '../../../widgets/app_snackbar.dart';

class RegisterController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void register() {
    final String username = usernameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      AppSnackbar.warning(
        'Perhatian',
        'Semua kolom pendaftaran wajib diisi lengkap!',
      );
      return;
    }

    if (username.length < 3) {
      AppSnackbar.warning(
        'Username Kurang Panjang',
        'Nama pengguna minimal terdiri dari 3 karakter!',
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      AppSnackbar.error(
        'Format Email Tidak Valid',
        'Silakan masukkan format alamat email yang benar!',
      );
      return;
    }

    if (password.length < 6) {
      AppSnackbar.warning(
        'Kata Sandi Kurang Kuat',
        'Kata sandi minimal terdiri dari 6 karakter!',
      );
      return;
    }

    debugPrint('Mencoba Mendaftarkan Akun Baru: $username ($email)');
    authService.register(username, email, password);
  }

  void registerWithGoogle() {
    authService.loginWithGoogle();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
