import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // --- PASTIKAN IP INI SAMA DENGAN TERMINAL FLASK KAMU ---
  static const String baseUrl = 'https://dangling-unpainted-manhole.ngrok-free.dev';
  static final _storage = GetStorage();

  static String? get _token => _storage.read('authToken');

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

// 🌟 UPGRADE: Sekarang dia nge-return List<String> berisi nama-nama piala baru!
  static Future<List<String>> syncProgress(int materialId, double progress) async {
    if (_token == null) return [];
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync/progress'),
        headers: _headers,
        body: jsonEncode({'material_id': materialId, 'progress': progress}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Nangkep list badge yang dikirim Flask
        List<dynamic> rawBadges = data['new_badges_unlocked'] ?? [];
        
        // Ubah jadi List<String> biar gampang dibaca Flutter
        return rawBadges.map((e) => e.toString()).toList();
      }
      return []; // Kalau gagal, balikin list kosong
    } catch (e) {
      print("[API] Error syncProgress: $e");
      return [];
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
          // Paksa jadi integer dan double dengan aman!
          int matId = int.parse(item['material_id'].toString());
          double prog = double.parse(item['progress'].toString());
          progressMap[matId] = prog;
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
    // =====================================================
  // DAILY QUEST API
  // =====================================================

  static Future<Map<String, dynamic>?> getTodayDailyQuest() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-quests/today'),
        headers: _headers,
      );

      print("[API] getTodayDailyQuest status: ${response.statusCode}");
      print("[API] getTodayDailyQuest body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['daily_quest'];
      }
    } catch (e) {
      print("[API] Error getTodayDailyQuest: $e");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> updateDailyQuestProgress(
    String questKey, {
    int amount = 1,
  }) async {
    if (_token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-quests/progress'),
        headers: _headers,
        body: jsonEncode({
          'quest_key': questKey,
          'amount': amount,
        }),
      );

      print("[API] updateDailyQuestProgress status: ${response.statusCode}");
      print("[API] updateDailyQuestProgress body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['daily_quest'];
      }
    } catch (e) {
      print("[API] Error updateDailyQuestProgress: $e");
    }

    return null;
  }

  static Future<Map<String, dynamic>?> claimDailyQuestReward() async {
    if (_token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/daily-quests/claim'),
        headers: _headers,
      );

      print("[API] claimDailyQuestReward status: ${response.statusCode}");
      print("[API] claimDailyQuestReward body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      // Kalau gagal karena belum selesai / sudah diklaim,
      // tetap balikin data biar Flutter bisa nampilin pesan errornya.
      return data;
    } catch (e) {
      print("[API] Error claimDailyQuestReward: $e");
    }

    return null;
  }
  static Future<List<dynamic>?> getNotifications() async {
    if (_token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[API] Error getNotifications: $e");
    }
    return null;
  }  
  static Future<bool> unlockBadge(String badgeName) async { // 🌟 Ganti jadi badgeName
    if (_token == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gamification/badge'),
        headers: _headers,
        body: jsonEncode({'badge_name': badgeName}), // 🌟 Ganti key jadi 'badge_name'
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
  static Future<Map<String, dynamic>?> syncProgressDetail(
      int materialId,
      double progress,
    ) async {
      if (_token == null) return null;

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/sync/progress'),
          headers: _headers,
          body: jsonEncode({
            'material_id': materialId,
            'progress': progress,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return data;
        }

        print("[API] syncProgressDetail gagal: ${response.body}");
        return data;
      } catch (e) {
        print("[API] Error syncProgressDetail: $e");
        return null;
      }
    }
  static Future<Map<String, dynamic>?> readFunFact(int funfactId) async {
  if (_token == null) return null;

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/funfacts/read'),
      headers: _headers,
      body: jsonEncode({
        'funfact_id': funfactId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    print("[API] readFunFact gagal: ${response.body}");
    return data;
  } catch (e) {
    print("[API] Error readFunFact: $e");
    return null;
  }
}
  static Future<Map<String, dynamic>?> completeLab(int materialId) async {
    if (_token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/lab/complete'),
        headers: _headers,
        body: jsonEncode({
          'material_id': materialId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      print("[API] completeLab gagal: ${response.body}");
      return data;
    } catch (e) {
      print("[API] Error completeLab: $e");
      return null;
    }
  }
  static Future<bool> updateProfile(String newName, String avatarPath) async {
    if (_token == null) return false;
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/update-profile'),
        headers: _headers,
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
  static Future<Map<String, dynamic>> changePassword({
  required String oldPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  if (_token == null) {
    return {"success": false, "message": "Token tidak ditemukan"};
  }

  try {
    final response = await http.put(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: _headers,
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
        "confirm_password": confirmPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": data["message"] ?? "Password berhasil diperbarui."
      };
    }

    return {
      "success": false,
      "message": data["error"] ?? "Gagal mengubah password."
    };
  } catch (e) {
    return {
      "success": false,
      "message": "Gagal konek ke server: $e"
    };
  }
}
  static Future<bool> deleteAccount() async {
    if (_token == null) return false;
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/auth/delete'),
        headers: _headers, // Cukup pakai _headers yang udah ada tokennya
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print("Error hapus akun: $e");
      return false;
    }
  }
}