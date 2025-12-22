import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/auth_service.dart';
import '../../../routes/app_pages.dart'; 

class LoginController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final isLoginTab = true.obs; 

  void login() {
    // Ambil teks dan hapus spasi di awal/akhir (biar gak error kalau typo spasi)
    String inputUsername = usernameController.text.trim();
    String inputPassword = passwordController.text.trim();

    // --- 1. CEK APAKAH INI ADMIN? (LOGIKA BARU) ---
    // Kita set username: 'admin' dan password: '123'
    if (inputUsername == 'admin' && inputPassword == '123') {
      print("Login berhasil sebagai ADMIN");
      
      // Arahkan ke halaman Admin
      // Pastikan '/admin' sudah terdaftar di AppPages ya!
      Get.offAllNamed(Routes.ADMIN); 
      
      return; // STOP DI SINI! Jangan lanjut ke login user biasa.
    }

    // --- 2. JIKA BUKAN ADMIN, LANJUTKAN LOGIN USER BIASA (KODE LAMA) ---
    print("Login sebagai User Biasa...");
    authService.login(
      inputUsername,
      inputPassword,
    );
  }

  void loginWithGoogle() {
    authService.loginWithGoogle();
  }
  
  void goToRegister() {
    Get.toNamed(Routes.REGISTER); 
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}