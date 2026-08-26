import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../data/api_service.dart';

/// API khusus milestone.
///
/// Sengaja dipisah dari ApiService lama agar Step koreksi ini tidak perlu
/// menimpa seluruh api_service.dart. Base URL tetap mengikuti ApiService.
class MilestoneApiService {
  static const Duration _timeout = Duration(seconds: 25);
  static final GetStorage _storage = GetStorage();

  static String? get _token => _storage.read<String>('authToken');

  static Map<String, String> get _headers {
    final String? token = _token;
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> getMilestones() async {
    final String? token = _token;
    if (token == null || token.trim().isEmpty) return null;

    try {
      final http.Response response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/milestones'),
            headers: _headers,
          )
          .timeout(_timeout);

      final Map<String, dynamic> data = _decodeMap(response.body);
      if (response.statusCode == 200) return data;

      debugPrint(
        '[MilestoneAPI] getMilestones gagal '
        '${response.statusCode}: ${response.body}',
      );
      return data;
    } catch (e) {
      debugPrint('[MilestoneAPI] getMilestones error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> equipFrame(String? rewardKey) async {
    final String? token = _token;
    if (token == null || token.trim().isEmpty) return null;

    try {
      final http.Response response = await http
          .put(
            Uri.parse('${ApiService.baseUrl}/milestones/frame'),
            headers: _headers,
            body: jsonEncode(<String, dynamic>{
              'reward_key': rewardKey ?? '',
            }),
          )
          .timeout(_timeout);

      final Map<String, dynamic> data = _decodeMap(response.body);
      if (response.statusCode == 200) return data;

      debugPrint(
        '[MilestoneAPI] equipFrame gagal '
        '${response.statusCode}: ${response.body}',
      );
      return data;
    } catch (e) {
      debugPrint('[MilestoneAPI] equipFrame error: $e');
      return null;
    }
  }

  static Map<String, dynamic> _decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }
}
