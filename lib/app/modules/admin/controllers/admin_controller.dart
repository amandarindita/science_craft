import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/api_service.dart';
import 'package:http/http.dart' as http; // <-- Package baru untuk nyambung ke Flask
import '../../../data/auth_service.dart'; // Tambahkan baris ini

class AdminController extends GetxController {
  // ==========================================
  // --- KONFIGURASI SERVER FLASK ---
  // ==========================================
  final String baseUrl = '${ApiService.baseUrl}/admin';
  String get authToken => Get.find<AuthService>().token; // Nanti diganti token asli dari fitur login
  
  // ==========================================
  // --- VARIABLES UI HELPER (TIDAK ADA YANG BERUBAH) ---
  // ==========================================
  var currentTab = 0.obs;
  var searchText = ''.obs; 
  var isEditMode = false.obs; 
  var editingId = 0.obs; 
  var isImportingCsv = false.obs;
  final ScrollController scrollController = ScrollController(); 

  // --- MATERI ---
  final titleController = TextEditingController();
  final introController = TextEditingController();
  final unitySceneController = TextEditingController(); // Baru: Untuk input ID Scene Unity
  var selectedCategory = 'Biologi'.obs;
  var selectedQuizCategory = 'Biologi'.obs;
  final List<String> categories = ['Biologi', 'Fisika', 'Kimia'];
  
  var sections = <Map<String, String>>[].obs; 
  var sectionQuillControllers = <QuillController>[].obs;
  var materialsList = <Map<String, dynamic>>[].obs;
  File? pickedMaterialImage;
  var currentImageUrl = ''.obs;
  final instructionsController = TextEditingController();

  // --- KUIS ---
  var selectedMaterialId = Rxn<int>(); 
  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  var correctAnswer = 'A'.obs;
  var questionType = 'pemahaman'.obs;

  final List<Map<String, String>> questionTypes = const [
    {'value': 'konsep', 'label': 'Konsep'},
    {'value': 'pemahaman', 'label': 'Pemahaman'},
    {'value': 'studi_kasus', 'label': 'Studi Kasus / HOTS'},
  ];
  List<Map<String, dynamic>> get quizMaterialsByCategory {
    return materialsList.where((m) {
      return m['category']?.toString() == selectedQuizCategory.value;
    }).toList();
  }
  String getQuestionTypeLabel(String value) {
    switch (value) {
      case 'konsep':
        return 'Konsep';
      case 'pemahaman':
        return 'Pemahaman';
      case 'studi_kasus':
        return 'Studi Kasus / HOTS';
      default:
        return 'Pemahaman';
    }
  }
  var quizzesList = <Map<String, dynamic>>[].obs;
  
  var isQuizEditMode = false.obs;
  var editingQuizId = 0.obs;

  // --- FUNFACT ---
  final ffDescController = TextEditingController();
  var funFactsList = <Map<String, dynamic>>[].obs;
  
  var isFunFactEditMode = false.obs;
  var editingFunFactId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    addSectionField(); 
    loadData();

    ever(selectedMaterialId, (id) {
      if (id != null) loadQuizzes(id);
    });
  }
  @override
void onClose() {
  titleController.dispose();
  introController.dispose();
  unitySceneController.dispose();
  instructionsController.dispose();

  questionController.dispose();
  optionAController.dispose();
  optionBController.dispose();
  optionCController.dispose();
  optionDController.dispose();

  ffDescController.dispose();

  for (final controller in sectionQuillControllers) {
    controller.dispose();
  }

  scrollController.dispose();

  super.onClose();
}

  // ==========================================
  // 1. LOGIC UTAMA: CRUD MATERI (VIA FLASK)
  // ==========================================
  void changeQuizCategory(String category) {
    selectedQuizCategory.value = category;

    final filteredMaterials = quizMaterialsByCategory;

    resetQuizForm();

    if (filteredMaterials.isNotEmpty) {
      selectedMaterialId.value = filteredMaterials.first['id'];
    } else {
      selectedMaterialId.value = null;
      quizzesList.clear();
    }
  }
  void addSectionField() {
    sections.add({'title': '', 'content': '', 'examples': '', 'image_path': ''}); 
    sectionQuillControllers.add(QuillController.basic());
  }

  void updateSection(int i, String key, String value) {
    var newMap = Map<String, String>.from(sections[i]);
    newMap[key] = value;
    sections[i] = newMap;
  }

Future<void> pickImageForSection(int index) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    pickedMaterialImage = File(image.path);

    // Ini cuma buat preview sementara di UI admin.
    // Nanti yang disimpan ke server adalah image_url, bukan path lokal ini.
    updateSection(index, 'image_path', image.path);

    Get.snackbar(
      "Berhasil",
      "Gambar dipilih. Nanti akan diupload ke server saat materi disimpan.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
  void removeImageFromSection(int index) {
  pickedMaterialImage = null;
  currentImageUrl.value = '';
  updateSection(index, 'image_path', '');
  }

  String buildImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  if (path.startsWith('/')) return '${ApiService.baseUrl}$path';
  return path;
}

  void removeSection(int i) {
    if (sections.length > 1) {
      sections.removeAt(i);
      sectionQuillControllers[i].dispose(); 
      sectionQuillControllers.removeAt(i);
    } else {
      Get.snackbar("Info", "Minimal harus ada satu sub-bab.");
    }
  }
Future<void> saveMaterial() async {
  if (titleController.text.isEmpty) {
    Get.snackbar("Error", "Judul materi wajib diisi");
    return;
  }

  // Convert konten Quill ke JSON
  for (int i = 0; i < sections.length; i++) {
    var delta = sectionQuillControllers[i].document.toDelta();
    String jsonContent = jsonEncode(delta.toJson());
    updateSection(i, 'content', jsonContent);
  }

  // Supaya path lokal HP tidak ikut kesimpan ke database
  final sectionsForPayload = sections.map((s) {
    final map = Map<String, String>.from(s);
    map['image_path'] = '';
    return map;
  }).toList();

  String combinedContent = jsonEncode({
    "intro": introController.text,
    "sections": sectionsForPayload,
  });

  try {
    final url = isEditMode.value
        ? '$baseUrl/material/${editingId.value}'
        : '$baseUrl/material';

    final method = isEditMode.value ? 'PUT' : 'POST';

    final request = http.MultipartRequest(method, Uri.parse(url));

    request.headers['Authorization'] = 'Bearer $authToken';

    request.fields['title'] = titleController.text;
    request.fields['content'] = combinedContent;
    request.fields['category'] = selectedCategory.value;
    request.fields['unity_scene_id'] = unitySceneController.text;
    request.fields['instructions'] = instructionsController.text;

    if (pickedMaterialImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          pickedMaterialImage!.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    print("[Admin] saveMaterial status: ${res.statusCode}");
    print("[Admin] saveMaterial body: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      Get.snackbar(
        isEditMode.value ? "Updated" : "Sukses",
        isEditMode.value
            ? "Materi diperbarui di Server!"
            : "Materi tersimpan di Server!",
        backgroundColor: isEditMode.value ? Colors.orange : Colors.green,
        colorText: Colors.white,
      );

      resetMaterialForm();
      loadData();
    } else {
      Get.snackbar(
        "Error",
        "Gagal menyimpan materi: ${res.body}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    Get.snackbar(
      "Error",
      "Gagal konek ke Flask: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
} Future<void> editMaterial(Map<String, dynamic> item) async {
  isEditMode.value = true;
  editingId.value = int.tryParse(item['id'].toString()) ?? 0;

  Map<String, dynamic> materialData = Map<String, dynamic>.from(item);

  // Ambil detail materi dari server biar content lama ikut kebawa
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/material/${editingId.value}'),
      headers: {
        "Authorization": "Bearer $authToken",
      },
    );

    print("[Admin] editMaterial detail status: ${res.statusCode}");
    print("[Admin] editMaterial detail body: ${res.body}");

    if (res.statusCode == 200) {
      materialData = Map<String, dynamic>.from(jsonDecode(res.body));
    }
  } catch (e) {
    print("[Admin] Gagal ambil detail materi untuk edit: $e");
  }

  titleController.text = materialData['title']?.toString() ?? '';
  selectedCategory.value = materialData['category']?.toString() ?? 'Biologi';
  unitySceneController.text = materialData['unity_scene_id']?.toString() ?? '';
  instructionsController.text = materialData['instructions']?.toString() ?? '';
  currentImageUrl.value = materialData['image_url']?.toString() ?? '';
  pickedMaterialImage = null;

  try {
    final rawContent = materialData['content']?.toString() ?? '';

    introController.clear();
    sections.clear();

    for (final controller in sectionQuillControllers) {
      controller.dispose();
    }
    sectionQuillControllers.clear();

    if (rawContent.trim().startsWith('{')) {
      final parsed = jsonDecode(rawContent);

      introController.text = parsed['intro']?.toString() ?? '';

      final dbSections = parsed['sections'];

      if (dbSections is List && dbSections.isNotEmpty) {
        for (final s in dbSections) {
          final sectionMap = <String, String>{
            'title': s['title']?.toString() ?? '',
            'content': s['content']?.toString() ?? '',
            'examples': s['examples']?.toString() ?? '',
            'image_path': s['image_path']?.toString() ?? '',
          };

          sections.add(sectionMap);

          final contentRaw = sectionMap['content'] ?? '';

          try {
            if (contentRaw.trim().startsWith('[')) {
              final quillJson = jsonDecode(contentRaw);

              sectionQuillControllers.add(
                QuillController(
                  document: Document.fromJson(quillJson),
                  selection: const TextSelection.collapsed(offset: 0),
                ),
              );
            } else {
              final doc = Document();
              doc.insert(0, contentRaw);

              sectionQuillControllers.add(
                QuillController(
                  document: doc,
                  selection: const TextSelection.collapsed(offset: 0),
                ),
              );
            }
          } catch (e) {
            final doc = Document();
            doc.insert(0, contentRaw);

            sectionQuillControllers.add(
              QuillController(
                document: doc,
                selection: const TextSelection.collapsed(offset: 0),
              ),
            );
          }
        }
      } else {
        addSectionField();
      }
    } else {
      // Kalau content lama bukan JSON, masukin ke intro biar nggak hilang
      introController.text = rawContent;
      addSectionField();
    }
  } catch (e) {
    print("[Admin] Error parse material content: $e");

    introController.clear();
    sections.clear();

    for (final controller in sectionQuillControllers) {
      controller.dispose();
    }
    sectionQuillControllers.clear();

    addSectionField();
  }

  if (scrollController.hasClients) {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
void resetMaterialForm() {
  isEditMode.value = false;
  editingId.value = 0;

  titleController.clear();
  introController.clear();
  unitySceneController.clear();
  instructionsController.clear();

  pickedMaterialImage = null;
  currentImageUrl.value = '';

  sections.clear();

  for (final controller in sectionQuillControllers) {
    controller.dispose();
  }
  sectionQuillControllers.clear();

  addSectionField();
}
  Future<void> deleteMaterial(int id) async {
    Get.defaultDialog(
      title: "Hapus Materi?",
      middleText: "Materi ini akan dihapus permanen dari Server.",
      textConfirm: "Hapus", confirmTextColor: Colors.white, buttonColor: Colors.red,
      onConfirm: () async {
        await http.delete(Uri.parse('$baseUrl/material/$id'), headers: {"Authorization": "Bearer $authToken"});
        loadData();
        Get.back(); 
        Get.snackbar("Dihapus", "Materi telah dihapus.");
      },
      textCancel: "Batal"
    );
  }
  
  // ==========================================
  // 2. FUNGSI LOAD DATA DARI FLASK
  // ==========================================
  void loadData() async {
  try {
    var resMat = await http.get(
      Uri.parse('$baseUrl/materials'),
      headers: {"Authorization": "Bearer $authToken"},
    );

    if (resMat.statusCode == 200) {
      materialsList.value = List<Map<String, dynamic>>.from(
        jsonDecode(resMat.body),
      );

      // Biar soal langsung muncul untuk materi pertama
      if (materialsList.isNotEmpty && selectedMaterialId.value == null) {
        final filteredMaterials = quizMaterialsByCategory;

        if (filteredMaterials.isNotEmpty) {
          selectedMaterialId.value = filteredMaterials.first['id'];
        } else {
          selectedMaterialId.value = null;
          quizzesList.clear();
        }
      }
    }

    var resFF = await http.get(
      Uri.parse('$baseUrl/funfacts'),
      headers: {"Authorization": "Bearer $authToken"},
    );

    if (resFF.statusCode == 200) {
      funFactsList.value = List<Map<String, dynamic>>.from(
        jsonDecode(resFF.body),
      );
    }
  } catch (e) {
    print("Gagal Load Data: $e");
  }
}
 void loadQuizzes(int materialId) async {
  try {
    final res = await http.get(
      Uri.parse('$baseUrl/questions/$materialId'),
      headers: {"Authorization": "Bearer $authToken"},
    );

    print("[Admin] loadQuizzes status: ${res.statusCode}");
    print("[Admin] loadQuizzes body: ${res.body}");

    if (res.statusCode == 200) {
      quizzesList.value = List<Map<String, dynamic>>.from(
        jsonDecode(res.body),
      );
    } else {
      quizzesList.clear();
      Get.snackbar(
        "Error",
        "Gagal mengambil soal.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    quizzesList.clear();
    print("[Admin] Gagal load quizzes: $e");
  }
}

  // ==========================================
  // 3. LOGIC KUIS (VIA FLASK)
  // ==========================================
  Future<void> saveQuiz() async {
  if (selectedMaterialId.value == null) {
    Get.snackbar(
      "Error",
      "Pilih materi dulu.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  if (questionController.text.trim().isEmpty ||
      optionAController.text.trim().isEmpty ||
      optionBController.text.trim().isEmpty ||
      optionCController.text.trim().isEmpty ||
      optionDController.text.trim().isEmpty) {
    Get.snackbar(
      "Error",
      "Pertanyaan dan semua opsi jawaban wajib diisi.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final payload = {
    "material_id": selectedMaterialId.value,
    "question_text": questionController.text.trim(),
    "question_type": questionType.value,
    "option_a": optionAController.text.trim(),
    "option_b": optionBController.text.trim(),
    "option_c": optionCController.text.trim(),
    "option_d": optionDController.text.trim(),
    "correct_answer": correctAnswer.value,
  };

  final url = isQuizEditMode.value
      ? '$baseUrl/question/${editingQuizId.value}'
      : '$baseUrl/question';

  try {
    final res = isQuizEditMode.value
        ? await http.put(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $authToken",
            },
            body: jsonEncode(payload),
          )
        : await http.post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $authToken",
            },
            body: jsonEncode(payload),
          );

    print("[Admin] saveQuiz status: ${res.statusCode}");
    print("[Admin] saveQuiz body: ${res.body}");

    if (res.statusCode == 201 || res.statusCode == 200) {
      Get.snackbar(
        "Sukses",
        isQuizEditMode.value
            ? "Soal berhasil diperbarui."
            : "Soal berhasil ditambahkan.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetQuizForm();
      loadQuizzes(selectedMaterialId.value!);
    } else {
      Get.snackbar(
        "Error",
        "Gagal simpan soal: ${res.body}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print("[Admin] Error saveQuiz: $e");

    Get.snackbar(
      "Error",
      "Gagal konek ke server: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  void editQuiz(Map<String, dynamic> item) {
    isQuizEditMode.value = true;
    editingQuizId.value = item['id'];
    questionController.text = item['question_text'] ?? '';
    optionAController.text = item['option_a'] ?? '';
    optionBController.text = item['option_b'] ?? '';
    optionCController.text = item['option_c'] ?? '';
    optionDController.text = item['option_d'] ?? '';
    correctAnswer.value = item['correct_answer'] ?? 'A';
    questionType.value = item['question_type'] ?? 'pemahaman';
    
    if(scrollController.hasClients) scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void resetQuizForm() {
    isQuizEditMode.value = false;
    editingQuizId.value = 0;
    questionController.clear(); 
    optionAController.clear(); optionBController.clear(); 
    optionCController.clear(); optionDController.clear();
    correctAnswer.value = 'A'; 
    questionType.value = 'pemahaman';
  }
  Future<void> deleteQuiz(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/question/$id'),
        headers: {
          "Authorization": "Bearer $authToken",
        },
      );

      print("[Admin] deleteQuiz status: ${res.statusCode}");
      print("[Admin] deleteQuiz body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 204) {
        Get.snackbar(
          "Dihapus",
          "Soal berhasil dihapus.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        if (selectedMaterialId.value != null) {
          loadQuizzes(selectedMaterialId.value!);
        }
      } else {
        Get.snackbar(
          "Error",
          "Gagal hapus soal: ${res.body}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("[Admin] Error deleteQuiz: $e");

      Get.snackbar(
        "Error",
        "Gagal konek ke server: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> importMaterialsCsv() async {
  await _importCsv(
    endpoint: '$baseUrl/import/materials',
    successMessage: 'Import CSV materi selesai.',
    onSuccess: () async {
      loadData();
    },
  );
}

Future<void> importQuestionsCsv() async {
  await _importCsv(
    endpoint: '$baseUrl/import/questions',
    successMessage: 'Import CSV soal selesai.',
    onSuccess: () async {
      loadData();

      if (selectedMaterialId.value != null) {
        loadQuizzes(selectedMaterialId.value!);
      }
    },
  );
}

Future<void> _importCsv({
    required String endpoint,
    required String successMessage,
    required Future<void> Function() onSuccess,
  }) async {
    if (isImportingCsv.value) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;

      if (file.bytes == null) {
        Get.snackbar(
          "Error",
          "File CSV gagal dibaca.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isImportingCsv.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(endpoint),
      );

      request.headers['Authorization'] = 'Bearer $authToken';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      print("[Admin] import CSV status: ${res.statusCode}");
      print("[Admin] import CSV body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);

        final imported = data['imported'] ?? 0;
        final updated = data['updated'] ?? 0;
        final skipped = data['skipped'];

        int skippedCount = 0;
        if (skipped is List) {
          skippedCount = skipped.length;
        }

        Get.snackbar(
          "Sukses",
          "$successMessage\nImport: $imported | Update: $updated | Skip: $skippedCount",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        await onSuccess();
      } else {
        Get.snackbar(
          "Error",
          "Gagal import CSV: ${res.body}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      print("[Admin] Error import CSV: $e");

      Get.snackbar(
        "Error",
        "Gagal import CSV: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImportingCsv.value = false;
    }
  }

  // ==========================================
  // 4. LOGIC FUNFACT (VIA FLASK)
  // ==========================================
  Future<void> saveFunFact() async {
  if (ffDescController.text.trim().isEmpty) {
    Get.snackbar(
      "Error",
      "Isi FunFact tidak boleh kosong.",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final payload = {
    "fact_text": ffDescController.text.trim(),
  };

  final url = isFunFactEditMode.value
      ? '$baseUrl/funfact/${editingFunFactId.value}'
      : '$baseUrl/funfact';

  try {
    final res = isFunFactEditMode.value
        ? await http.put(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $authToken",
            },
            body: jsonEncode(payload),
          )
        : await http.post(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $authToken",
            },
            body: jsonEncode(payload),
          );

    print("[Admin] saveFunFact status: ${res.statusCode}");
    print("[Admin] saveFunFact body: ${res.body}");

    if (res.statusCode == 201 || res.statusCode == 200) {
      Get.snackbar(
        "Sukses",
        isFunFactEditMode.value
            ? "FunFact berhasil diperbarui."
            : "FunFact berhasil ditambahkan.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      resetFunFactForm();
      loadData();
    } else {
      Get.snackbar(
        "Error",
        "Gagal simpan FunFact: ${res.body}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print("[Admin] Error saveFunFact: $e");

    Get.snackbar(
      "Error",
      "Gagal konek ke server: $e",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
  void editFunFact(Map<String, dynamic> item) {
    isFunFactEditMode.value = true;
    editingFunFactId.value = item['id'];
    ffDescController.text = item['fact_text'] ?? '';
  }

  void resetFunFactForm() {
    isFunFactEditMode.value = false;
    editingFunFactId.value = 0;
    ffDescController.clear();
  }
  Future<void> deleteFunFact(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/funfact/$id'),
        headers: {
          "Authorization": "Bearer $authToken",
        },
      );

      print("[Admin] deleteFunFact status: ${res.statusCode}");
      print("[Admin] deleteFunFact body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 204) {
        Get.snackbar(
          "Dihapus",
          "FunFact berhasil dihapus.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        loadData();
      } else {
        Get.snackbar(
          "Error",
          "Gagal hapus FunFact: ${res.body}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("[Admin] Error deleteFunFact: $e");

      Get.snackbar(
        "Error",
        "Gagal konek ke server: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}