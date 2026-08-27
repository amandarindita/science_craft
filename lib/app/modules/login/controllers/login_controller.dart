import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/app_snackbar.dart';

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() {
    final String inputEmail = emailController.text.trim();
    final String inputPassword = passwordController.text.trim();

    if (inputEmail.isEmpty || inputPassword.isEmpty) {
      AppSnackbar.warning(
        'Perhatian',
        'Alamat email dan kata sandi harus diisi lengkap!',
      );
      return;
    }

    if (!GetUtils.isEmail(inputEmail)) {
      AppSnackbar.error(
        'Format Email Tidak Valid',
        'Silakan periksa dan masukkan format alamat email yang benar!',
      );
      return;
    }

    debugPrint('Mencoba Login ke Server: $inputEmail');
    authService.login(inputEmail, inputPassword);
  }

  void loginWithGoogle() {
    authService.loginWithGoogle();
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}