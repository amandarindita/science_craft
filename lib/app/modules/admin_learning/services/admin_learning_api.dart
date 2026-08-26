import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../../data/api_service.dart';

class AdminLearningApi {
  AdminLearningApi._();

  static const Duration _timeout =
      Duration(seconds: 40);

  static final GetStorage _storage =
      GetStorage();

  static String? get _token =>
      _storage.read<String>('authToken');

  static Map<String, String> get _jsonHeaders {
    final String? token = _token;

    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null &&
          token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Map<String, String>
      get _authHeaders {
    final String? token = _token;

    return <String, String>{
      if (token != null &&
          token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // =======================================================
  // TWO CSV IMPORT
  // =======================================================

  static Future<Map<String, dynamic>>
      importLearningContent({
    required String filePath,
    required bool replaceExisting,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiService.baseUrl}/admin/import/learning-content',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields['replace_existing'] =
        replaceExisting ? 'true' : 'false';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
      ),
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      importQuestionsCsv({
    required String filePath,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiService.baseUrl}/admin/import/questions',
      ),
    );

    request.headers.addAll(_authHeaders);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
      ),
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  // =======================================================
  // MODULE
  // =======================================================

  static Future<List<Map<String, dynamic>>>
      getModules({
    int? level,
    String? category,
  }) async {
    final Map<String, String> query =
        <String, String>{};

    if (level != null) {
      query['level'] = level.toString();
    }

    if (category != null &&
        category.trim().isNotEmpty) {
      query['category'] = category.trim();
    }

    final Uri uri = Uri.parse(
      '${ApiService.baseUrl}/admin/materials',
    ).replace(
      queryParameters:
          query.isEmpty ? null : query,
    );

    final http.Response response =
        await http
            .get(
              uri,
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      getModule(int materialId) async {
    final http.Response response =
        await http
            .get(
              Uri.parse(
                '${ApiService.baseUrl}/admin/material/$materialId',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      createModule({
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiService.baseUrl}/admin/material',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields.addAll(
      _multipartFields(data),
    );

    await _attachFiles(
      request,
      imagePath: imagePath,
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 201) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      updateModule({
    required int materialId,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'PUT',
      Uri.parse(
        '${ApiService.baseUrl}/admin/material/$materialId',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields.addAll(
      _multipartFields(data),
    );

    await _attachFiles(
      request,
      imagePath: imagePath,
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<void> deleteModule(
    int materialId,
  ) async {
    final http.Response response =
        await http
            .delete(
              Uri.parse(
                '${ApiService.baseUrl}/admin/material/$materialId',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AdminApiException.fromResponse(
        response,
      );
    }
  }

  // =======================================================
  // SUBMATERIAL
  // =======================================================

  static Future<List<Map<String, dynamic>>>
      getSubmaterials(
    int materialId,
  ) async {
    final http.Response response =
        await http
            .get(
              Uri.parse(
                '${ApiService.baseUrl}/admin/submaterials/$materialId',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      createSubmaterial({
    required int materialId,
    required Map<String, dynamic> data,
    String? audioPath,
    String? imagePath,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiService.baseUrl}/admin/submaterial',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields.addAll(
      _multipartFields(
        <String, dynamic>{
          ...data,
          'material_id': materialId,
        },
      ),
    );

    await _attachFiles(
      request,
      audioPath: audioPath,
      imagePath: imagePath,
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 201) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      updateSubmaterial({
    required int submaterialId,
    required Map<String, dynamic> data,
    String? audioPath,
    String? imagePath,
  }) async {
    final http.MultipartRequest request =
        http.MultipartRequest(
      'PUT',
      Uri.parse(
        '${ApiService.baseUrl}/admin/submaterial/$submaterialId',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields.addAll(
      _multipartFields(data),
    );

    await _attachFiles(
      request,
      audioPath: audioPath,
      imagePath: imagePath,
    );

    final http.Response response =
        await _sendMultipart(request);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<void> deleteSubmaterial(
    int submaterialId,
  ) async {
    final http.Response response =
        await http
            .delete(
              Uri.parse(
                '${ApiService.baseUrl}/admin/submaterial/$submaterialId',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AdminApiException.fromResponse(
        response,
      );
    }
  }

  static Future<List<Map<String, dynamic>>>
      getVisualTypes() async {
    final http.Response response =
        await http
            .get(
              Uri.parse(
                '${ApiService.baseUrl}/admin/visual-types',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }


  // =======================================================
  // CHECKPOINT & QUIZ (STEP 8C)
  // =======================================================

  static Future<List<Map<String, dynamic>>> getCheckpointTypes() async {
    final response = await http
        .get(
          Uri.parse('${ApiService.baseUrl}/admin/checkpoint-types'),
          headers: _jsonHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(response);
  }

  static Future<List<Map<String, dynamic>>> getCheckpoints(
    int submaterialId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiService.baseUrl}/admin/checkpoints/$submaterialId',
          ),
          headers: _jsonHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(response);
  }

  static Future<Map<String, dynamic>> saveCheckpoint({
    int? checkpointId,
    required int submaterialId,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest(
      checkpointId == null ? 'POST' : 'PUT',
      Uri.parse(
        checkpointId == null
            ? '${ApiService.baseUrl}/admin/checkpoint'
            : '${ApiService.baseUrl}/admin/checkpoint/$checkpointId',
      ),
    );

    request.headers.addAll(_authHeaders);
    request.fields.addAll(
      _multipartFields({
        ...data,
        if (checkpointId == null) 'submaterial_id': submaterialId,
      }),
    );

    await _attachFiles(request, imagePath: imagePath);
    final response = await _sendMultipart(request);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(response);
  }

  static Future<void> deleteCheckpoint(int checkpointId) async {
    final response = await http
        .delete(
          Uri.parse(
            '${ApiService.baseUrl}/admin/checkpoint/$checkpointId',
          ),
          headers: _jsonHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AdminApiException.fromResponse(response);
    }
  }

  static Future<List<Map<String, dynamic>>> getQuestions(
    int materialId,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '${ApiService.baseUrl}/admin/questions/$materialId',
          ),
          headers: _jsonHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(response);
  }

  static Future<Map<String, dynamic>> saveQuestion({
    int? questionId,
    required int materialId,
    required Map<String, dynamic> data,
  }) async {
    final payload = {
      ...data,
      if (questionId == null) 'material_id': materialId,
    };

    final response = questionId == null
        ? await http
            .post(
              Uri.parse('${ApiService.baseUrl}/admin/question'),
              headers: _jsonHeaders,
              body: jsonEncode(payload),
            )
            .timeout(_timeout)
        : await http
            .put(
              Uri.parse(
                '${ApiService.baseUrl}/admin/question/$questionId',
              ),
              headers: _jsonHeaders,
              body: jsonEncode(payload),
            )
            .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(response);
  }

  static Future<void> deleteQuestion(int questionId) async {
    final response = await http
        .delete(
          Uri.parse(
            '${ApiService.baseUrl}/admin/question/$questionId',
          ),
          headers: _jsonHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AdminApiException.fromResponse(response);
    }
  }

  // =======================================================
  // FUN FACT
  // =======================================================

  static Future<List<Map<String, dynamic>>>
      getFunFacts() async {
    final http.Response response =
        await http
            .get(
              Uri.parse(
                '${ApiService.baseUrl}/admin/funfacts',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      createFunFact(
    String factText,
  ) async {
    final http.Response response =
        await http
            .post(
              Uri.parse(
                '${ApiService.baseUrl}/admin/funfact',
              ),
              headers: _jsonHeaders,
              body: jsonEncode(
                <String, dynamic>{
                  'fact_text': factText,
                },
              ),
            )
            .timeout(_timeout);

    if (response.statusCode == 201) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<Map<String, dynamic>>
      updateFunFact({
    required int funFactId,
    required String factText,
  }) async {
    final http.Response response =
        await http
            .put(
              Uri.parse(
                '${ApiService.baseUrl}/admin/funfact/$funFactId',
              ),
              headers: _jsonHeaders,
              body: jsonEncode(
                <String, dynamic>{
                  'fact_text': factText,
                },
              ),
            )
            .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response.body);
    }

    throw AdminApiException.fromResponse(
      response,
    );
  }

  static Future<void> deleteFunFact(
    int funFactId,
  ) async {
    final http.Response response =
        await http
            .delete(
              Uri.parse(
                '${ApiService.baseUrl}/admin/funfact/$funFactId',
              ),
              headers: _jsonHeaders,
            )
            .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AdminApiException.fromResponse(
        response,
      );
    }
  }

  // =======================================================
  // HELPERS
  // =======================================================

  static Map<String, String>
      _multipartFields(
    Map<String, dynamic> data,
  ) {
    final Map<String, String> fields =
        <String, String>{};

    for (final MapEntry<String, dynamic>
        entry in data.entries) {
      final dynamic value = entry.value;

      if (value == null) {
        continue;
      }

      if (value is Map || value is List) {
        fields[entry.key] = jsonEncode(value);
      } else if (value is bool) {
        fields[entry.key] =
            value ? 'true' : 'false';
      } else {
        fields[entry.key] =
            value.toString();
      }
    }

    return fields;
  }

  static Future<void> _attachFiles(
    http.MultipartRequest request, {
    String? audioPath,
    String? imagePath,
  }) async {
    if (audioPath != null &&
        audioPath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
        ),
      );
    }

    if (imagePath != null &&
        imagePath.trim().isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePath,
        ),
      );
    }
  }

  static Future<http.Response>
      _sendMultipart(
    http.MultipartRequest request,
  ) async {
    final http.StreamedResponse streamed =
        await request.send().timeout(_timeout);

    return http.Response.fromStream(
      streamed,
    );
  }

  static List<Map<String, dynamic>>
      _decodeList(
    String body,
  ) {
    if (body.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final dynamic decoded =
        jsonDecode(body);

    if (decoded is! List) {
      return <Map<String, dynamic>>[];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();
  }

  static Map<String, dynamic> _decodeMap(
    String body,
  ) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded =
        jsonDecode(body);

    if (decoded is Map) {
      return Map<String, dynamic>.from(
        decoded,
      );
    }

    return <String, dynamic>{
      'data': decoded,
    };
  }
}

class AdminApiException implements Exception {
  const AdminApiException(
    this.message, {
    this.statusCode,
  });

  factory AdminApiException.fromResponse(
    http.Response response,
  ) {
    String message =
        'Request gagal (${response.statusCode}).';

    try {
      final dynamic decoded =
          jsonDecode(response.body);

      if (decoded is Map) {
        message = (
          decoded['error'] ??
          decoded['message'] ??
          message
        ).toString();
      }
    } catch (_) {
      if (response.body.trim().isNotEmpty) {
        message = response.body;
      }
    }

    return AdminApiException(
      message,
      statusCode: response.statusCode,
    );
  }

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
