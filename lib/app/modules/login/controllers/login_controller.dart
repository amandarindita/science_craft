import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/auth_service.dart';
import '../../../routes/app_pages.dart'; 

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final isLoginTab = true.obs; 

  void login() {
    String inputEmail = emailController.text.trim();
    String inputPassword = passwordController.text.trim();

    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      Get.snackbar("Error", "Email dan Password harus diisi!");
      return;
    }

    print("Mencoba Login ke Server Flask...");
    authService.login(inputEmail, inputPassword);
  }

  void loginWithGoogle() {
    authService.loginWithGoogle();
  }
  
  void goToRegister() {
    Get.toNamed(Routes.REGISTER); 
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}