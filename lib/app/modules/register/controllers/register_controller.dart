import 'package:flutter/material.dart';
import 'package:get/get.dart';
// 1. Import AuthService
import '../../../data/auth_service.dart';

class RegisterController extends GetxController {
  // 2. Panggil instance AuthService
  final AuthService authService = Get.find<AuthService>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // 3. Buat fungsi untuk tombol register
  void register() {
    // (Opsional) Tambahkan validasi di sini
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }

    authService.register(
      usernameController.text,
      emailController.text,
      passwordController.text,
    );
  }

  // 4. Buat fungsi untuk register via Google
  void registerWithGoogle() {
    // Register dan Login Google alurnya sama
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
