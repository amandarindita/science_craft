import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_client.dart';
import 'api_service.dart';
import '../routes/app_pages.dart';
import '../widgets/app_snackbar.dart';
import 'db/database_helper.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final _googleSignIn = GoogleSignIn(
    serverClientId:
        '911457315564-3kvld75e6jneg80m4fql95to0n2n45mh.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  String get token => _storage.read('authToken') ?? '';
  String get refreshToken => _storage.read('refreshToken') ?? '';

  bool isLoggedIn() {
    return _storage.hasData('authToken') || _storage.hasData('refreshToken');
  }

  // --- LOGIKA TERPUSAT (Anti-Gagal) ---
  void _handleLoginResult(
    Map<String, dynamic> data, {
    bool isNewUser = false,
    String? customTitle,
    String? customMessage,
    bool suppressSnackbar = false,
  }) async {
    debugPrint('[AuthService] 🔑 Menangani hasil login...');
    debugPrint('[AuthService] Raw data keys: ${data.keys.toList()}');

    if (data['access_token'] != null) {
      await _storage.write('authToken', data['access_token']);
      debugPrint('[AuthService] ✅ authToken tersimpan');
    }
    if (data['refresh_token'] != null) {
      await _storage.write('refreshToken', data['refresh_token']);
      debugPrint('[AuthService] ✅ refreshToken tersimpan');
    }

    // Simpan userId dan email jika ada
    if (data['user'] != null) {
      if (data['user']['id'] != null) {
        await _storage.write('userId', data['user']['id'].toString());
      }
      if (data['user']['email'] != null) {
        await _storage.write('userEmail', data['user']['email'].toString());
      }
    } else if (data['user_id'] != null) {
      await _storage.write('userId', data['user_id'].toString());
    }

    // Nangkep role dari manapun asalnya
    String userRole = 'user';
    if (data['user'] != null && data['user']['role'] != null) {
      userRole = data['user']['role'].toString();
    } else if (data['role'] != null) {
      userRole = data['role'].toString();
    }

    await _storage.write('userRole', userRole);
    debugPrint("[AuthService] ✅ User Role = $userRole");

    // Tampilkan snackbar yang sesuai (User Baru vs User Lama)
    if (!suppressSnackbar) {
      if (isNewUser) {
        AppSnackbar.success(
          customTitle ?? 'Selamat Datang',
          customMessage ??
              'Akun berhasil dibuat. Selamat datang di Science Craft!',
        );
      } else {
        AppSnackbar.success(
          customTitle ?? 'Login Berhasil',
          customMessage ?? 'Selamat datang kembali di Science Craft!',
        );
      }
    }

    // Navigasi
    if (userRole.toLowerCase() == 'admin') {
      debugPrint('[AuthService] Navigasi ke Halaman ADMIN');
      Get.offAllNamed(Routes.ADMIN);
    } else {
      debugPrint('[AuthService] Navigasi ke Halaman ROOT');
      Get.offAllNamed(Routes.ROOT);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      debugPrint('==================================================');
      debugPrint('[AuthService] 🚀 Memulai login email: $email');
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
        barrierDismissible: false,
      );
      final targetUrl = Uri.parse('${ApiService.baseUrl}/auth/login');
      debugPrint('[AuthService] 📡 Mengirim POST ke $targetUrl');
      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint(
        '[AuthService] 📥 Login Response Status: ${response.statusCode}',
      );
      debugPrint('[AuthService] 📥 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        _handleLoginResult(ApiClient.decodeMap(response.body));
      } else {
        final resData = ApiClient.decodeMap(response.body);
        final String message =
            resData['message'] ??
            resData['error'] ??
            'Email atau kata sandi tidak sesuai.';
        debugPrint('[AuthService] ❌ Login gagal: $message');
        AppSnackbar.error('Login Gagal', message);
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('[AuthService] ❌ Error Login Exception: $e');
      debugPrint('[AuthService] ❌ StackTrace: $stackTrace');
      AppSnackbar.error(
        'Gangguan Koneksi',
        'Tidak dapat terhubung ke server: ${e.toString().split('\n').first}',
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      debugPrint('==================================================');
      debugPrint('[GoogleAuth] 🚀 Memulai alur Login with Google...');
      debugPrint(
        '[GoogleAuth] 🔧 Server Client ID: ${_googleSignIn.serverClientId}',
      );

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
        barrierDismissible: false,
      );

      debugPrint(
        '[GoogleAuth] 🔄 Memanggil signOut() untuk memastikan akun bersih...',
      );
      try {
        await _googleSignIn.signOut();
      } catch (signOutErr) {
        debugPrint(
          '[GoogleAuth] ⚠️ Info: signOut error (dapat diabaikan): $signOutErr',
        );
      }

      debugPrint('[GoogleAuth] 📱 Membuka Google Sign-In prompt...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint(
          '[GoogleAuth] ⚠️ Pengguna membatalkan dialog pemilihan akun Google.',
        );
        if (Get.isDialogOpen ?? false) Get.back();
        return;
      }

      debugPrint('[GoogleAuth] ✅ Akun Google berhasil dipilih:');
      debugPrint('[GoogleAuth]    - Email: ${googleUser.email}');
      debugPrint('[GoogleAuth]    - Nama: ${googleUser.displayName}');
      debugPrint('[GoogleAuth]    - ID: ${googleUser.id}');

      debugPrint(
        '[GoogleAuth] 🔐 Mengambil authentication tokens (idToken & accessToken)...',
      );
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      debugPrint(
        '[GoogleAuth] 🔑 idToken: ${idToken != null ? "Ada (panjang: ${idToken.length} karakter, prefix: ${idToken.substring(0, idToken.length > 25 ? 25 : idToken.length)}...)" : "NULL ⚠️"}',
      );
      debugPrint(
        '[GoogleAuth] 🔑 accessToken: ${accessToken != null ? "Ada (panjang: ${accessToken.length} karakter)" : "NULL ⚠️"}',
      );

      if (idToken == null || idToken.isEmpty) {
        debugPrint('[GoogleAuth] ❌ KRITIS: idToken bernilai NULL!');
        debugPrint('[GoogleAuth] 💡 Penyebab umum:');
        debugPrint(
          '[GoogleAuth]    1. SHA-1 Fingerprint debug.keystore belum dimasukkan ke Google Cloud Console / Firebase.',
        );
        debugPrint(
          '[GoogleAuth]    2. serverClientId harus berupa Web Application Client ID (bukan Android Client ID).',
        );
        debugPrint(
          '[GoogleAuth]    3. Package name di Google Cloud Console tidak cocok dengan "com.amanda.sciencecraft".',
        );

        if (Get.isDialogOpen ?? false) Get.back();
        AppSnackbar.error(
          'Google Token Kosong',
          'Gagal mendapatkan idToken dari Google. Periksa konfigurasi SHA-1 / Web Client ID di Google Cloud Console.',
        );
        return;
      }

      final targetUrl = Uri.parse('${ApiService.baseUrl}/auth/google');
      debugPrint('[GoogleAuth] 📡 Mengirim idToken ke Backend: $targetUrl');

      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint('[GoogleAuth] 📥 Response Status: ${response.statusCode}');
      debugPrint('[GoogleAuth] 📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('[GoogleAuth] 🎉 Autentikasi Google sukses di server!');
        final Map<String, dynamic> resData = ApiClient.decodeMap(response.body);
        final bool isNew = resData['is_new_user'] == true ||
            resData['is_new'] == true ||
            resData['new_user'] == true;

        _handleLoginResult(
          resData,
          isNewUser: isNew,
          customTitle: isNew ? 'Selamat Datang 🎉' : 'Login Berhasil',
          customMessage: isNew
              ? 'Akun Google berhasil terdaftar. Selamat datang di Science Craft!'
              : 'Selamat datang kembali di Science Craft!',
        );
      } else {
        final resData = ApiClient.decodeMap(response.body);
        final String message =
            resData['message'] ??
            resData['error'] ??
            'Gagal masuk menggunakan akun Google (Status ${response.statusCode}).';
        debugPrint('[GoogleAuth] ❌ Server menolak login Google: $message');
        AppSnackbar.error('Autentikasi Gagal', message);
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint('==================================================');
      debugPrint('[GoogleAuth] ❌ EXCEPTION TERJADI: $e');
      debugPrint('[GoogleAuth] ❌ Tipe Exception: ${e.runtimeType}');

      if (e is PlatformException) {
        debugPrint('[GoogleAuth] 🚨 PlatformException Details:');
        debugPrint('[GoogleAuth]    - Code: ${e.code}');
        debugPrint('[GoogleAuth]    - Message: ${e.message}');
        debugPrint('[GoogleAuth]    - Details: ${e.details}');

        if (e.code == 'sign_in_failed' ||
            e.toString().contains('10') ||
            e.toString().contains('12500')) {
          debugPrint(
            '[GoogleAuth] 💡 ANALISIS ERROR GOOGLE (Code 10 / 12500 / sign_in_failed):',
          );
          debugPrint(
            '[GoogleAuth]    1. SHA-1 Fingerprint belum didaftarkan di Google Cloud Console.',
          );
          debugPrint(
            '[GoogleAuth]    2. Package name "com.amanda.sciencecraft" belum terdaftar di OAuth Android Client.',
          );
          debugPrint(
            '[GoogleAuth]    3. serverClientId harus Web Client ID yang satu project Google Cloud.',
          );
        }
      }

      debugPrint('[GoogleAuth] ❌ STACKTRACE:\n$stackTrace');
      debugPrint('==================================================');

      AppSnackbar.error(
        'Gangguan Google Sign-In',
        'Error: ${e.toString().split('\n').first}',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      debugPrint('==================================================');
      debugPrint(
        '[AuthService] 🚀 Memulai registrasi akun: $username ($email)',
      );
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
        barrierDismissible: false,
      );
      final targetUrl = Uri.parse('${ApiService.baseUrl}/auth/register');
      debugPrint('[AuthService] 📡 Mengirim POST ke $targetUrl');
      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint(
        '[AuthService] 📥 Register Response Status: ${response.statusCode}',
      );
      debugPrint('[AuthService] 📥 Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = ApiClient.decodeMap(response.body);

        // Jika backend langsung mengembalikan access_token (direct login)
        if (resData['access_token'] != null) {
          _handleLoginResult(
            resData,
            isNewUser: true,
            customTitle: 'Registrasi Berhasil 🎉',
            customMessage:
                'Akun kamu berhasil dibuat. Selamat datang di Science Craft!',
          );
        } else {
          // Backend mengirimkan OTP ke email
          final String message = resData['message'] ??
              'Registrasi awal berhasil! Silakan cek kode OTP di email Anda.';
          AppSnackbar.success('Kode OTP Terkirim ✉️', message);

          Get.toNamed(
            Routes.OTP_VERIFICATION,
            arguments: {
              'email': email,
              'username': username,
              'password': password,
              'isRegistration': true,
            },
          );
        }
      } else {
        final resData = ApiClient.decodeMap(response.body);
        final String message =
            resData['message'] ??
            resData['error'] ??
            'Gagal mendaftarkan akun. Email/Username mungkin sudah terdaftar.';
        debugPrint('[AuthService] ❌ Register gagal: $message');
        AppSnackbar.error('Registrasi Gagal', message);
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('[AuthService] ❌ Error Register Exception: $e');
      debugPrint('[AuthService] ❌ StackTrace: $stackTrace');
      AppSnackbar.error(
        'Gangguan Koneksi',
        'Tidak dapat terhubung ke server pendaftaran: ${e.toString().split('\n').first}',
      );
    }
  }

  Future<bool> verifyRegisterOtp(String email, String otp) async {
    try {
      debugPrint('==================================================');
      debugPrint(
        '[AuthService] 🚀 Memulai verifikasi OTP registrasi: $email, OTP: $otp',
      );
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2563EB)),
        ),
        barrierDismissible: false,
      );

      final targetUrl =
          Uri.parse('${ApiService.baseUrl}/auth/register/verify-otp');
      debugPrint('[AuthService] 📡 Mengirim POST ke $targetUrl');
      final response = await http.post(
        targetUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );
      if (Get.isDialogOpen ?? false) Get.back();

      debugPrint(
        '[AuthService] 📥 Verify OTP Status: ${response.statusCode}',
      );
      debugPrint('[AuthService] 📥 Verify OTP Body: ${response.body}');

      final resData = ApiClient.decodeMap(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        _handleLoginResult(
          resData,
          isNewUser: true,
          customTitle: 'Akun Terverifikasi 🎉',
          customMessage:
              resData['message'] ?? 'Selamat! Akun kamu berhasil diverifikasi.',
        );
        return true;
      } else {
        final String message = resData['error'] ??
            resData['message'] ??
            'Kode OTP salah atau telah kedaluwarsa.';
        debugPrint('[AuthService] ❌ Verifikasi OTP gagal: $message');
        AppSnackbar.error('Verifikasi Gagal', message);
        return false;
      }
    } catch (e, stackTrace) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('[AuthService] ❌ Error Verify OTP Exception: $e');
      debugPrint('[AuthService] ❌ StackTrace: $stackTrace');
      AppSnackbar.error(
        'Gangguan Koneksi',
        'Tidak dapat terhubung ke server verifikasi: ${e.toString().split('\n').first}',
      );
      return false;
    }
  }

  void logout() async {
    debugPrint('[AuthService] 🚪 Melakukan logout...');
    final String? userId = _storage.read('userId')?.toString();
    final String? userEmail = _storage.read('userEmail')?.toString();

    await _storage.remove('authToken');
    await _storage.remove('refreshToken');
    await _storage.remove('userRole');
    await _storage.remove('userId');
    await _storage.remove('userEmail');
    await _storage.remove('accessed_module_ids');
    await _storage.remove('last_accessed_module_id');

    if (userId != null && userId.isNotEmpty) {
      await _storage.remove('accessed_module_ids_$userId');
      await _storage.remove('last_accessed_module_id_$userId');
    }
    if (userEmail != null && userEmail.isNotEmpty) {
      await _storage.remove('accessed_module_ids_$userEmail');
      await _storage.remove('last_accessed_module_id_$userEmail');
    }

    await DatabaseHelper.instance.clearUserData();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    Get.offAllNamed(Routes.LOGIN);
  }
}
