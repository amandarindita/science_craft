import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/auth_service.dart';
import '../../../routes/app_pages.dart'; // <-- 1. Pastikan import routes ini ada

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final isLoginTab = true.obs; 

  void login() {
    authService.login(
      usernameController.text,
      passwordController.text,
    );
  }

  void loginWithGoogle() {
    authService.loginWithGoogle();
  }
  
  // --- 2. INI FUNGSI YANG HILANG DARI FILE-MU ---
  void goToRegister() {
    Get.toNamed(Routes.REGISTER); // Pindah ke halaman Register
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

