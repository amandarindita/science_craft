import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../routes/app_pages.dart';
import 'db/database_helper.dart'; 

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _googleSignIn = GoogleSignIn(
    serverClientId: '90764646083-urjenubpi8uoa5bbbmqsgia36pg62gl5.apps.googleusercontent.com',
  );

  String get token => _storage.read('authToken') ?? '';

  bool isLoggedIn() {
    return _storage.hasData('authToken');
  }

  // --- LOGIKA TERPUSAT (Anti-Gagal) ---
  void _handleLoginResult(Map<String, dynamic> data) async {
    await _storage.write('authToken', data['access_token']);
    
    // Nangkep role dari manapun asalnya
    String userRole = 'user';
    if (data['user'] != null && data['user']['role'] != null) {
      userRole = data['user']['role'].toString();
    } else if (data['role'] != null) {
      userRole = data['role'].toString();
    }
    
    await _storage.write('userRole', userRole);
    print("DEBUG: User Role = $userRole");

    // Navigasi
    if (userRole.toLowerCase() == 'admin') {
      Get.offAllNamed(Routes.ADMIN);
    } else {
      Get.offAllNamed(Routes.ROOT);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      Get.back(); 

      if (response.statusCode == 200) {
        _handleLoginResult(jsonDecode(response.body));
      } else {
        Get.snackbar('Login Gagal', 'Email atau password salah.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal konek ke server.');
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { Get.back(); return; }
      
      final String? idToken = (await googleUser.authentication).idToken;
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );
      Get.back(); 

      if (response.statusCode == 200) {
        _handleLoginResult(jsonDecode(response.body));
      } else {
        Get.snackbar('Login Gagal', 'Google Auth gagal.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Kesalahan koneksi.');
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );
      Get.back(); 

      if (response.statusCode == 201) {
        _handleLoginResult(jsonDecode(response.body));
      } else {
        Get.snackbar('Register Gagal', 'Cek email lu lagi.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal konek.');
    }
  }

  void logout() async {
    await _storage.remove('authToken');
    await _storage.remove('userRole');
    await DatabaseHelper.instance.clearUserData();
    Get.offAllNamed(Routes.LOGIN);
  }
}