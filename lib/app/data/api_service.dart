import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';

class ApiService {
  static String get baseUrl => ApiClient.baseUrl;

  static bool get hasToken => ApiClient.hasToken;

  static String? get _token => ApiClient.token;

  static Map<String, String> get _headers => ApiClient.defaultHeaders();

  static Map<String, dynamic> _decodeMap(String body) =>
      ApiClient.decodeMap(body);

  static List<Map<String, dynamic>> _decodeMapList(String body) =>
      ApiClient.decodeMapList(body);

  static Map<String, dynamic> _failureData(http.Response response) {
    Map<String, dynamic> data;

    try {
      data = _decodeMap(response.body);
    } catch (_) {
      data = <String, dynamic>{
        'error': response.body.isEmpty
            ? 'Server tidak mengirim respons.'
            : response.body,
      };
    }

    data['success'] = false;
    data['status_code'] = response.statusCode;
    data.putIfAbsent(
      'error',
      () => 'Request gagal dengan status ${response.statusCode}.',
    );

    return data;
  }

  static String? resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final String cleaned = path.trim();
    final Uri? parsed = Uri.tryParse(cleaned);

    if (parsed != null && parsed.hasScheme) {
      return cleaned;
    }

    return cleaned.startsWith('/')
        ? '$baseUrl$cleaned'
        : '$baseUrl/$cleaned';
  }

  // =====================================================
  // STEP 6A — LEARNING API BARU
  // =====================================================

  static Future<List<Map<String, dynamic>>> getLearningLevels() async {
    if (!hasToken) {
      return <Map<String, dynamic>>[];
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/learning/levels'),
      );

      if (response.statusCode == 200) {
        return _decodeMapList(response.body);
      }

      debugPrint(
        '[API] getLearningLevels gagal '
        '${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      debugPrint('[API] Error getLearningLevels: $e');
    }

    return <Map<String, dynamic>>[];
  }

  static Future<List<Map<String, dynamic>>> getLearningModules({
    int? level,
    String? category,
  }) async {
    if (!hasToken) {
      return <Map<String, dynamic>>[];
    }

    try {
      final Map<String, String> query = <String, String>{};

      if (level != null) {
        query['level'] = level.toString();
      }

      if (category != null && category.trim().isNotEmpty) {
        query['category'] = category.trim();
      }

      final Uri uri = Uri.parse('$baseUrl/learning/modules').replace(
        queryParameters: query.isEmpty ? null : query,
      );

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        return _decodeMapList(response.body);
      }

      debugPrint(
        '[API] getLearningModules gagal '
        '${response.statusCode}: ${response.body}',
      );
    } catch (e) {
      debugPrint('[API] Error getLearningModules: $e');
    }

    return <Map<String, dynamic>>[];
  }

  static Future<Map<String, dynamic>?> getLearningModule(
    int materialId,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/learning/module/$materialId'),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error getLearningModule: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> getModuleStatus(
    int materialId,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/learning/module/$materialId/status'),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error getModuleStatus: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> openSubmaterial(
    int submaterialId, {
    required String mode,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/submaterial/$submaterialId/open',
        ),
        body: jsonEncode(<String, dynamic>{
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error openSubmaterial: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> completeLearningMode(
    int submaterialId, {
    required String mode,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/submaterial/$submaterialId/complete-mode',
        ),
        body: jsonEncode(<String, dynamic>{
          'mode': mode,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error completeLearningMode: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> submitCheckpoint(
    int checkpointId, {
    required dynamic answer,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/checkpoint/$checkpointId/submit',
        ),
        body: jsonEncode(<String, dynamic>{
          'answer': answer,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error submitCheckpoint: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> getModuleQuiz(
    int materialId,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/learning/module/$materialId/quiz'),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error getModuleQuiz: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  /// Format answers:
  /// [
  ///   {'question_id': 10, 'answer': 'A'},
  ///   {'question_id': 11, 'answer': 'B'},
  /// ]
  static Future<Map<String, dynamic>?> submitModuleQuiz(
    int materialId, {
    required List<Map<String, dynamic>> answers,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/module/$materialId/quiz/submit',
        ),
        body: jsonEncode(<String, dynamic>{
          'answers': answers,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error submitModuleQuiz: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> saveModuleLabResult(
    int materialId, {
    required Map<String, dynamic> payload,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/module/$materialId/lab/result',
        ),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error saveModuleLabResult: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> completeModuleLab(
    int materialId, {
    int? resultId,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(
          '$baseUrl/learning/module/$materialId/lab/complete',
        ),
        body: jsonEncode(<String, dynamic>{
          if (resultId != null) 'result_id': resultId,
        }),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error completeModuleLab: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>?> getLearningProgress() async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/learning/progress'),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }

      return _failureData(response);
    } catch (e) {
      debugPrint('[API] Error getLearningProgress: $e');
      return <String, dynamic>{
        'success': false,
        'error': 'Gagal terhubung ke server: $e',
      };
    }
  }

  // =====================================================
  // API LAMA — DIPERTAHANKAN AGAR SCREEN LAMA TIDAK RUSAK
  // Untuk alur belajar baru, jangan panggil syncProgress/addXp
  // secara manual karena backend Step 5 sudah menghitung progress
  // dan XP secara otomatis.
  // =====================================================

  static Future<List<String>> syncProgress(
    int materialId,
    double progress,
  ) async {
    if (!hasToken) {
      return <String>[];
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/sync/progress'),
        body: jsonEncode(<String, dynamic>{
          'material_id': materialId,
          'progress': progress,
        }),
      );

      if (response.statusCode == 200) {
        final data = _decodeMap(response.body);
        final List<dynamic> rawBadges =
            data['new_badges_unlocked'] as List<dynamic>? ?? <dynamic>[];

        return rawBadges.map((item) => item.toString()).toList();
      }
    } catch (e) {
      debugPrint('[API] Error syncProgress: $e');
    }

    return <String>[];
  }

  static Future<Map<int, double>> getAllProgress() async {
    if (!hasToken) {
      return <int, double>{};
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/sync/all-progress'),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is! List) {
          return <int, double>{};
        }

        final Map<int, double> progressMap = <int, double>{};

        for (final dynamic item in decoded) {
          if (item is! Map) {
            continue;
          }

          final int? materialId = int.tryParse(
            item['material_id'].toString(),
          );

          final double? progress = double.tryParse(
            item['progress'].toString(),
          );

          if (materialId != null && progress != null) {
            progressMap[materialId] = progress;
          }
        }

        return progressMap;
      }
    } catch (e) {
      debugPrint('[API] Error getAllProgress: $e');
    }

    return <int, double>{};
  }

  static Future<void> addXp(int amount) async {
    if (!hasToken) {
      return;
    }

    try {
      await ApiClient.post(
        Uri.parse('$baseUrl/gamification/xp'),
        body: jsonEncode(<String, dynamic>{
          'amount': amount,
        }),
      );

      debugPrint('[API] +$amount XP berhasil dikirim ke server');
    } catch (e) {
      debugPrint('[API] Error addXp: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/gamification/user-data'),
      );

      if (response.statusCode == 200) {
        return _decodeMap(response.body);
      }
    } catch (e) {
      debugPrint('[API] Error getUserData: $e');
    }

    return null;
  }

  // =====================================================
  // DAILY QUEST API
  // =====================================================

  static Future<Map<String, dynamic>?> getTodayDailyQuest() async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/daily-quests/today'),
      );

      debugPrint(
        '[API] getTodayDailyQuest status: ${response.statusCode}',
      );
      debugPrint(
        '[API] getTodayDailyQuest body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = _decodeMap(response.body);
        final dynamic dailyQuest = data['daily_quest'];

        if (dailyQuest is Map) {
          return Map<String, dynamic>.from(dailyQuest);
        }
      }
    } catch (e) {
      debugPrint('[API] Error getTodayDailyQuest: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>?> updateDailyQuestProgress(
    String questKey, {
    int amount = 1,
  }) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/daily-quests/progress'),
        body: jsonEncode(<String, dynamic>{
          'quest_key': questKey,
          'amount': amount,
        }),
      );

      debugPrint(
        '[API] updateDailyQuestProgress status: ${response.statusCode}',
      );
      debugPrint(
        '[API] updateDailyQuestProgress body: ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = _decodeMap(response.body);
        final dynamic dailyQuest = data['daily_quest'];

        if (dailyQuest is Map) {
          return Map<String, dynamic>.from(dailyQuest);
        }
      }
    } catch (e) {
      debugPrint('[API] Error updateDailyQuestProgress: $e');
    }

    return null;
  }

  static Future<Map<String, dynamic>?> claimDailyQuestReward() async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/daily-quests/claim'),
      );

      final data = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      return data;
    } catch (e) {
      debugPrint('[API] Error claimDailyQuestReward: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getNotifications() async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.get(
        Uri.parse('$baseUrl/notifications'),
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('[API] Error getNotifications: $e');
    }

    return null;
  }

  static Future<bool> markNotificationAsRead(int notifId) async {
    if (!hasToken) return false;

    try {
      final response = await ApiClient.put(
        Uri.parse('$baseUrl/notifications/$notifId/read'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error markNotificationAsRead: $e');
      return false;
    }
  }

  static Future<bool> markAllNotificationsAsRead() async {
    if (!hasToken) return false;

    try {
      final response = await ApiClient.put(
        Uri.parse('$baseUrl/notifications/read-all'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error markAllNotificationsAsRead: $e');
      return false;
    }
  }

  static Future<bool> deleteNotification(int notifId) async {
    if (!hasToken) return false;

    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/notifications/$notifId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error deleteNotification: $e');
      return false;
    }
  }

  static Future<bool> clearAllNotifications() async {
    if (!hasToken) return false;

    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/notifications'),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error clearAllNotifications: $e');
      return false;
    }
  }

  static Future<bool> unlockBadge(String badgeName) async {
    if (!hasToken) {
      return false;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/gamification/badge'),
        body: jsonEncode(<String, dynamic>{
          'badge_name': badgeName,
        }),
      );

      if (response.statusCode == 200) {
        final data = _decodeMap(response.body);

        return data['message']
            .toString()
            .contains('berhasil dibuka');
      }
    } catch (e) {
      debugPrint('[API] Error unlockBadge: $e');
    }

    return false;
  }

  static Future<Map<String, dynamic>?> syncProgressDetail(
    int materialId,
    double progress,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/sync/progress'),
        body: jsonEncode(<String, dynamic>{
          'material_id': materialId,
          'progress': progress,
        }),
      );

      final data = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      debugPrint(
        '[API] syncProgressDetail gagal: ${response.body}',
      );

      return data;
    } catch (e) {
      debugPrint('[API] Error syncProgressDetail: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> readFunFact(
    int funfactId,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/funfacts/read'),
        body: jsonEncode(<String, dynamic>{
          'funfact_id': funfactId,
        }),
      );

      final data = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      debugPrint('[API] readFunFact gagal: ${response.body}');
      return data;
    } catch (e) {
      debugPrint('[API] Error readFunFact: $e');
      return null;
    }
  }

  /// Endpoint lab lama. Pertahankan hanya untuk screen lama.
  static Future<Map<String, dynamic>?> completeLab(
    int materialId,
  ) async {
    if (!hasToken) {
      return null;
    }

    try {
      final response = await ApiClient.post(
        Uri.parse('$baseUrl/lab/complete'),
        body: jsonEncode(<String, dynamic>{
          'material_id': materialId,
        }),
      );

      final data = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      debugPrint('[API] completeLab gagal: ${response.body}');
      return data;
    } catch (e) {
      debugPrint('[API] Error completeLab: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(
    String newName,
    String avatarPath,
  ) async {
    if (!hasToken) {
      return false;
    }

    try {
      final response = await ApiClient.put(
        Uri.parse('$baseUrl/auth/update-profile'),
        body: jsonEncode(<String, dynamic>{
          'username': newName,
          'avatar': avatarPath,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(
          '[API] Update Profile Sukses: $newName, $avatarPath',
        );
        return true;
      }

      debugPrint(
        '[API] Gagal Update Profile: ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint('[API] Error updateProfile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!hasToken) {
      return <String, dynamic>{
        'success': false,
        'message': 'Token tidak ditemukan',
      };
    }

    try {
      final response = await ApiClient.put(
        Uri.parse('$baseUrl/auth/change-password'),
        body: jsonEncode(<String, dynamic>{
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }),
      );

      final data = _decodeMap(response.body);

      if (response.statusCode == 200) {
        return <String, dynamic>{
          'success': true,
          'message': data['message'] ??
              'Password berhasil diperbarui.',
        };
      }

      return <String, dynamic>{
        'success': false,
        'message': data['error'] ??
            'Gagal mengubah password.',
      };
    } catch (e) {
      return <String, dynamic>{
        'success': false,
        'message': 'Gagal konek ke server: $e',
      };
    }
  }

  static Future<bool> deleteAccount() async {
    if (!hasToken) {
      return false;
    }

    try {
      final response = await ApiClient.delete(
        Uri.parse('$baseUrl/auth/delete'),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error hapus akun: $e');
      return false;
    }
  }
}
