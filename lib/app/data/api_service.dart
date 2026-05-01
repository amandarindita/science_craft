import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {

  static const String baseUrl = 'http://192.168.56.35:5000';
  static final _storage = GetStorage();

  static String? get _token => _storage.read('authToken');

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

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
static Future<bool> deleteAccount() async {
    final box = GetStorage();
    final token = box.read('authToken'); // Ambil token biar server tau siapa yg dihapus
    
    // Kalau gak ada token, dianggap gagal/sudah logout
    if (token == null) return false;
    final String baseUrl = 'http://192.168.56.35:5000'; 
    final url = Uri.parse('$baseUrl/auth/delete');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' // Wajib bawa "KTP" (Token)
        },
      );
      
      // Kalau server bilang OK (200), berarti berhasil
      return response.statusCode == 200;
    } catch (e) {
      print("Error hapus akun: $e");
      return false;
    }
  }
}