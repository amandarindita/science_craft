import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';
import '../routes/app_pages.dart';
// Pastikan path ini sesuai dengan struktur foldermu
import 'db/database_helper.dart'; 

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _googleSignIn = GoogleSignIn(
    // Client ID dari Google Cloud Console (Web Client ID)
    // Pastikan ini sama dengan GOOGLE_CLIENT_ID di .env Backend kamu
    serverClientId: '90764646083-urjenubpi8uoa5bbbmqsgia36pg62gl5.apps.googleusercontent.com',
  );

  // Fungsi pengecekan status login
  bool isLoggedIn() {
    return _storage.hasData('authToken');
  }

  void logout() async {
    await _storage.remove('authToken');
    try {
      await _googleSignIn.signOut(); 
    } catch (e) {
      print("Error google sign out: $e");
    }

    await DatabaseHelper.instance.clearUserData(); 
    Get.offAllNamed(Routes.LOGIN);
  }


  Future<void> loginWithGoogle() async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _googleSignIn.signOut(); 
      // -----------------------------------------------------
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.back();
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        Get.back();
        Get.snackbar('Login Gagal', 'Gagal mendapatkan token Google.');
        return;
      }
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );
      
      Get.back(); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final myAppToken = data['access_token']; 
        
        await _storage.write('authToken', myAppToken);
        
        Get.offAllNamed(Routes.ROOT);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Login Gagal', data['error'] ?? 'Server error');
      }

    } catch (e) {
      Get.back();
      print("Error Login Google: $e"); 
      Get.snackbar('Login Gagal', 'Terjadi kesalahan koneksi.');
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
        final data = jsonDecode(response.body);
        final myAppToken = data['access_token'];
        await _storage.write('authToken', myAppToken);
        Get.offAllNamed(Routes.ROOT);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Login Gagal', data['error'] ?? 'Email atau password salah.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Koneksi Gagal', 'Tidak bisa terhubung ke server: $e');
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email, 
          'password': password
        }),
      );
      
      Get.back(); 
      
      if (response.statusCode == 201) { 
        final data = jsonDecode(response.body);
        final myAppToken = data['access_token'];
        await _storage.write('authToken', myAppToken);
        Get.offAllNamed(Routes.ROOT);
      } else {
        final data = jsonDecode(response.body);
        Get.snackbar('Register Gagal', data['error'] ?? 'Email mungkin sudah dipakai.');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Koneksi Gagal', 'Tidak bisa terhubung ke server: $e');
    }
  }
}