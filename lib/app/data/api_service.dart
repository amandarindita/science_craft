import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://dangling-unpainted-manhole.ngrok-free.dev';

  static const Duration _timeout = Duration(seconds: 25);
  static final GetStorage _storage = GetStorage();

  static String? get _token => _storage.read<String>('authToken');

  static bool get hasToken {
    final token = _token;
    return token != null && token.trim().isNotEmpty;
  }

  static Map<String, String> get _headers {
    final token = _token;

    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{'data': decoded};
  }

  static List<Map<String, dynamic>> _decodeMapList(String body) {
    if (body.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final dynamic decoded = jsonDecode(body);

    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/learning/levels'),
            headers: _headers,
          )
          .timeout(_timeout);

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

      final response = await http
          .get(uri, headers: _headers)
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/learning/module/$materialId'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/learning/module/$materialId/status'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/submaterial/$submaterialId/open',
            ),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'mode': mode,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/submaterial/$submaterialId/complete-mode',
            ),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'mode': mode,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/checkpoint/$checkpointId/submit',
            ),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'answer': answer,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/learning/module/$materialId/quiz'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/module/$materialId/quiz/submit',
            ),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'answers': answers,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/module/$materialId/lab/result',
            ),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse(
              '$baseUrl/learning/module/$materialId/lab/complete',
            ),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              if (resultId != null) 'result_id': resultId,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/learning/progress'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/sync/progress'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'material_id': materialId,
              'progress': progress,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/sync/all-progress'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      await http
          .post(
            Uri.parse('$baseUrl/gamification/xp'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'amount': amount,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/gamification/user-data'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/daily-quests/today'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/daily-quests/progress'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'quest_key': questKey,
              'amount': amount,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/daily-quests/claim'),
            headers: _headers,
          )
          .timeout(_timeout);

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
      final response = await http
          .get(
            Uri.parse('$baseUrl/notifications'),
            headers: _headers,
          )
          .timeout(_timeout);

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

  static Future<bool> unlockBadge(String badgeName) async {
    if (!hasToken) {
      return false;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/gamification/badge'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'badge_name': badgeName,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/sync/progress'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'material_id': materialId,
              'progress': progress,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/funfacts/read'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'funfact_id': funfactId,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .post(
            Uri.parse('$baseUrl/lab/complete'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'material_id': materialId,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/update-profile'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'username': newName,
              'avatar': avatarPath,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/change-password'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'old_password': oldPassword,
              'new_password': newPassword,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(_timeout);

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
      final response = await http
          .delete(
            Uri.parse('$baseUrl/auth/delete'),
            headers: _headers,
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[API] Error hapus akun: $e');
      return false;
    }
  }
}
