import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../routes/app_pages.dart';
import '../widgets/app_snackbar.dart';

class ApiClient {
  // static const String baseUrl = 'http://192.168.0.111:5000';
  static const String baseUrl = 'https://delphia-formulable-kristyn.ngrok-free.dev';
  static const Duration defaultTimeout = Duration(seconds: 25);
  static final GetStorage _storage = GetStorage();

  static String? get token => _storage.read<String>('authToken');
  static String? get refreshToken => _storage.read<String>('refreshToken');

  static bool get hasToken {
    final t = token;
    return t != null && t.trim().isNotEmpty;
  }

  static Map<String, String> defaultHeaders({
    Map<String, String>? customHeaders,
    bool includeAuth = true,
  }) {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final currentToken = token;
      if (currentToken != null && currentToken.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer $currentToken';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  // Mutex to prevent multiple parallel refresh token calls
  static Completer<String?>? _refreshCompleter;

  static Future<String?> refreshAccessToken() async {
    // If a refresh is already happening, await the in-flight future
    if (_refreshCompleter != null) {
      debugPrint('[ApiClient] Token refresh already in progress. Waiting...');
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    final refresh = _storage.read<String>('refreshToken');
    if (refresh == null || refresh.trim().isEmpty) {
      debugPrint('[ApiClient] No refresh token found in storage.');
      _handleSessionExpired();
      completer.complete(null);
      _refreshCompleter = null;
      return null;
    }

    try {
      debugPrint('[ApiClient] Attempting to refresh access token via /auth/refresh...');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refresh',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('[ApiClient] Refresh endpoint responded with status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = decodeMap(response.body);
        final String? newAccessToken = data['access_token']?.toString();
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storage.write('authToken', newAccessToken);
          debugPrint('[ApiClient] ✅ Access token refreshed successfully!');
          completer.complete(newAccessToken);
          _refreshCompleter = null;
          return newAccessToken;
        }
      }

      debugPrint('[ApiClient] ❌ Token refresh rejected (${response.statusCode}): ${response.body}');
    } catch (e) {
      debugPrint('[ApiClient] ❌ Error refreshing access token: $e');
    }

    _handleSessionExpired();
    completer.complete(null);
    _refreshCompleter = null;
    return null;
  }

  static bool _isSessionExpiredHandling = false;

  static void _handleSessionExpired() {
    if (_isSessionExpiredHandling) return;
    _isSessionExpiredHandling = true;

    _storage.remove('authToken');
    _storage.remove('refreshToken');

    // Debounce navigation so it doesn't collide with dialogs/routes
    Future.microtask(() {
      if (Get.currentRoute != Routes.LOGIN &&
          Get.currentRoute != Routes.REGISTER &&
          Get.currentRoute != Routes.ONBOARDING) {
        Get.offAllNamed(Routes.LOGIN);
        AppSnackbar.warning(
          'Sesi Berakhir',
          'Sesi login kamu telah kedaluwarsa. Silakan masuk kembali.',
        );
      }
      _isSessionExpiredHandling = false;
    });
  }

  static bool _shouldAttemptRefresh(Uri url, int statusCode) {
    if (statusCode != 401) return false;
    final path = url.path.toLowerCase();
    // Do not attempt refresh on auth routes to avoid loops
    if (path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/google') ||
        path.contains('/auth/register') ||
        path.contains('/auth/forgot-password')) {
      return false;
    }
    return true;
  }

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final effectiveHeaders = defaultHeaders(customHeaders: headers);
    final response = await http
        .get(url, headers: effectiveHeaders)
        .timeout(timeout ?? defaultTimeout);

    if (_shouldAttemptRefresh(url, response.statusCode)) {
      debugPrint('[ApiClient] GET ${url.path} got 401. Triggering token refresh...');
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        final retryHeaders = Map<String, String>.from(effectiveHeaders);
        retryHeaders['Authorization'] = 'Bearer $newToken';
        debugPrint('[ApiClient] Retrying GET ${url.path} with new access token...');
        return await http
            .get(url, headers: retryHeaders)
            .timeout(timeout ?? defaultTimeout);
      }
    }

    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final effectiveHeaders = defaultHeaders(customHeaders: headers);
    final response = await http
        .post(url, headers: effectiveHeaders, body: body, encoding: encoding)
        .timeout(timeout ?? defaultTimeout);

    if (_shouldAttemptRefresh(url, response.statusCode)) {
      debugPrint('[ApiClient] POST ${url.path} got 401. Triggering token refresh...');
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        final retryHeaders = Map<String, String>.from(effectiveHeaders);
        retryHeaders['Authorization'] = 'Bearer $newToken';
        debugPrint('[ApiClient] Retrying POST ${url.path} with new access token...');
        return await http
            .post(url, headers: retryHeaders, body: body, encoding: encoding)
            .timeout(timeout ?? defaultTimeout);
      }
    }

    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final effectiveHeaders = defaultHeaders(customHeaders: headers);
    final response = await http
        .put(url, headers: effectiveHeaders, body: body, encoding: encoding)
        .timeout(timeout ?? defaultTimeout);

    if (_shouldAttemptRefresh(url, response.statusCode)) {
      debugPrint('[ApiClient] PUT ${url.path} got 401. Triggering token refresh...');
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        final retryHeaders = Map<String, String>.from(effectiveHeaders);
        retryHeaders['Authorization'] = 'Bearer $newToken';
        debugPrint('[ApiClient] Retrying PUT ${url.path} with new access token...');
        return await http
            .put(url, headers: retryHeaders, body: body, encoding: encoding)
            .timeout(timeout ?? defaultTimeout);
      }
    }

    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    final effectiveHeaders = defaultHeaders(customHeaders: headers);
    final response = await http
        .delete(url, headers: effectiveHeaders, body: body, encoding: encoding)
        .timeout(timeout ?? defaultTimeout);

    if (_shouldAttemptRefresh(url, response.statusCode)) {
      debugPrint('[ApiClient] DELETE ${url.path} got 401. Triggering token refresh...');
      final newToken = await refreshAccessToken();
      if (newToken != null) {
        final retryHeaders = Map<String, String>.from(effectiveHeaders);
        retryHeaders['Authorization'] = 'Bearer $newToken';
        debugPrint('[ApiClient] Retrying DELETE ${url.path} with new access token...');
        return await http
            .delete(url, headers: retryHeaders, body: body, encoding: encoding)
            .timeout(timeout ?? defaultTimeout);
      }
    }

    return response;
  }

  static Future<http.Response> sendMultipart(
    http.MultipartRequest request, {
    Duration? timeout,
  }) async {
    final currentToken = token;
    if (currentToken != null && currentToken.trim().isNotEmpty) {
      request.headers.putIfAbsent('Authorization', () => 'Bearer $currentToken');
    }

    final streamedResponse =
        await request.send().timeout(timeout ?? defaultTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (_shouldAttemptRefresh(request.url, response.statusCode)) {
      debugPrint('[ApiClient] Multipart request got 401. Refreshing token...');
      await refreshAccessToken();
    }

    return response;
  }

  static Map<String, dynamic> decodeMap(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static List<Map<String, dynamic>> decodeMapList(String body) {
    if (body.trim().isEmpty) return <Map<String, dynamic>>[];
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
