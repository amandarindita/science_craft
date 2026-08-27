import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../data/api_client.dart';
import '../../../data/api_service.dart';

/// API khusus milestone.
/// Base URL tetap mengikuti ApiService / ApiClient.
class MilestoneApiService {
  static Future<Map<String, dynamic>?> getMilestones() async {
    if (!ApiClient.hasToken) return null;

    try {
      final http.Response response = await ApiClient.get(
        Uri.parse('${ApiService.baseUrl}/milestones'),
      );

      final Map<String, dynamic> data = ApiClient.decodeMap(response.body);
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
    if (!ApiClient.hasToken) return null;

    try {
      final http.Response response = await ApiClient.put(
        Uri.parse('${ApiService.baseUrl}/milestones/frame'),
        body: jsonEncode(<String, dynamic>{
          'reward_key': rewardKey ?? '',
        }),
      );

      final Map<String, dynamic> data = ApiClient.decodeMap(response.body);
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
}
