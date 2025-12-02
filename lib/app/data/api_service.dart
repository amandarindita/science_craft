import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Ganti dengan IP Flask kamu yang aktif
  static const String baseUrl = 'http://192.168.0.28:5000'; 
  static final _storage = GetStorage();

  // --- HELPER: Ambil Token ---
  static String? get _token => _storage.read('authToken');

  // --- HELPER: Header Standar ---
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // --- 1. PROGRESS ---

  // Simpan satu progress (Dipakai di Detail Materi)
  static Future<bool> syncProgress(int materialId, double progress) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync/progress'),
        headers: _headers,
        body: jsonEncode({'material_id': materialId, 'progress': progress}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("[API] Error syncProgress: $e");
      return false;
    }
  }

  // Ambil SEMUA progress user (Dipakai di List Materi)
  static Future<Map<int, double>> getAllProgress() async {
    if (_token == null) return {};
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sync/all-progress'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        Map<int, double> progressMap = {};
        for (var item in data) {
          progressMap[item['material_id']] = (item['progress'] as num).toDouble();
        }
        return progressMap;
      }
    } catch (e) {
      print("[API] Error getAllProgress: $e");
    }
    return {}; 
  }

  // --- 2. GAMIFICATION (XP & USER DATA) ---

  // Tambah XP
  static Future<void> addXp(int amount) async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/gamification/xp'),
        headers: _headers,
        body: jsonEncode({'amount': amount}),
      );
      print("[API] +$amount XP berhasil dikirim ke server");
    } catch (e) {
      print("[API] Error addXp: $e");
    }
  }

  // Ambil Data Profil
  static Future<Map<String, dynamic>?> getUserData() async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gamification/user-data'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[API] Error getUserData: $e");
    }
    return null;
  }
  
  // Unlock Badge
  static Future<bool> unlockBadge(String badgeCode) async {
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gamification/badge'),
        headers: _headers,
        body: jsonEncode({'badge_code': badgeCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'].toString().contains("berhasil dibuka");
      }
    } catch (e) {
      print("[API] Error unlockBadge: $e");
    }
    return false;
  }

  // --- 3. UPDATE PROFILE (INI YANG TADI HILANG) ---
static Future<bool> updateProfile(String newName, String avatarPath) async {
    if (_token == null) return false;
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-profile'),
        headers: _headers,
        // Kirim username DAN avatar
        body: jsonEncode({
          'username': newName,
          'avatar': avatarPath 
        }),
      );

      if (response.statusCode == 200) {
        print("[API] Update Profile Sukses: $newName, $avatarPath");
        return true;
      } else {
        print("[API] Gagal Update Profile: ${response.body}");
        return false;
      }
    } catch (e) {
      print("[API] Error updateProfile: $e");
      return false;
    }
}
}