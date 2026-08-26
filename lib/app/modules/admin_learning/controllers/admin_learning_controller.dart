import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/admin_learning_api.dart';

class AdminLearningController
    extends GetxController {
  static const int maxIntroLength = 150;

  final RxList<Map<String, dynamic>> modules =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      submaterials =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      visualTypes =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      checkpointTypes =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      checkpoints =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      questions =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>>
      funFacts =
      <Map<String, dynamic>>[].obs;

  final RxString funFactSearchQuery =
      ''.obs;

  final Rxn<Map<String, dynamic>>
      activeModule =
      Rxn<Map<String, dynamic>>();

  final Rxn<Map<String, dynamic>>
      activeSubmaterial =
      Rxn<Map<String, dynamic>>();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingContent =
      false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isSavingSubmaterial =
      false.obs;
  final RxBool isLoadingCheckpoints =
      false.obs;
  final RxBool isSavingCheckpoint =
      false.obs;
  final RxBool isLoadingQuestions =
      false.obs;
  final RxBool isSavingQuestion =
      false.obs;
  final RxBool isLoadingFunFacts =
      false.obs;
  final RxBool isSavingFunFact =
      false.obs;
  final RxBool isDeletingFunFact =
      false.obs;
  final RxBool isDeleting = false.obs;
  final RxBool isImportingLearningContent =
      false.obs;

  final RxBool isImportingQuestions =
      false.obs;

  final Rxn<Map<String, dynamic>>
      lastLearningImportResult =
      Rxn<Map<String, dynamic>>();

  final Rxn<Map<String, dynamic>>
      lastQuestionImportResult =
      Rxn<Map<String, dynamic>>();

  final RxInt selectedLevel = 0.obs;
  final RxString selectedCategory =
      'Semua'.obs;

  final List<String> categories =
      const <String>[
    'Semua',
    'Fisika',
    'Kimia',
    'Biologi',
  ];

  @override
  void onInit() {
    super.onInit();
    loadModules();
    loadVisualTypes();
    loadCheckpointTypes();
  }

  // =======================================================
  // MODULE
  // =======================================================

  Future<void> loadModules() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      final List<Map<String, dynamic>>
          result =
          await AdminLearningApi.getModules(
        level: selectedLevel.value == 0
            ? null
            : selectedLevel.value,
        category:
            selectedCategory.value == 'Semua'
                ? null
                : selectedCategory.value,
      );

      modules.assignAll(result);
    } catch (e) {
      showError(
        'Gagal memuat modul: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveModule({
    int? materialId,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    if (isSaving.value) {
      return false;
    }

    final String intro =
        data['short_description']
                ?.toString() ??
            '';

    if (intro.length > maxIntroLength) {
      showError(
        'Intro maksimal $maxIntroLength karakter.',
      );
      return false;
    }

    isSaving.value = true;

    try {
      if (materialId == null) {
        await AdminLearningApi.createModule(
          data: data,
          imagePath: imagePath,
        );
      } else {
        await AdminLearningApi.updateModule(
          materialId: materialId,
          data: data,
          imagePath: imagePath,
        );
      }

      await loadModules();

      Get.snackbar(
        'Berhasil',
        materialId == null
            ? 'Modul berhasil dibuat.'
            : 'Modul berhasil diperbarui.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError(
        'Gagal menyimpan modul: $e',
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteModule(
    Map<String, dynamic> module,
  ) async {
    if (isDeleting.value) {
      return false;
    }

    final int materialId =
        intValue(module['id']);

    final bool confirmed =
        await Get.dialog<bool>(
              AlertDialog(
                title:
                    const Text('Hapus modul?'),
                content: Text(
                  'Modul "${module['title'] ?? ''}" beserta submateri, checkpoint, dan soal terkait akan dihapus permanen.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        Get.back<bool>(
                      result: false,
                    ),
                    child:
                        const Text('Batal'),
                  ),
                  FilledButton(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFDC2626,
                      ),
                    ),
                    onPressed: () =>
                        Get.back<bool>(
                      result: true,
                    ),
                    child:
                        const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirmed) {
      return false;
    }

    isDeleting.value = true;

    try {
      await AdminLearningApi.deleteModule(
        materialId,
      );

      await loadModules();

      Get.snackbar(
        'Modul dihapus',
        'Konten terkait berhasil dihapus.',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      showError(
        'Gagal menghapus modul: $e',
      );
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  void changeLevel(int level) {
    selectedLevel.value = level;
    loadModules();
  }

  void changeCategory(
    String category,
  ) {
    selectedCategory.value = category;
    loadModules();
  }

  // =======================================================
  // SUBMATERIAL
  // =======================================================

  Future<void> openModuleContent(
    Map<String, dynamic> module,
  ) async {
    activeModule.value =
        Map<String, dynamic>.from(module);

    await loadSubmaterials(
      intValue(module['id']),
    );
  }

  Future<void> loadSubmaterials(
    int materialId,
  ) async {
    if (isLoadingContent.value) {
      return;
    }

    isLoadingContent.value = true;

    try {
      final List<Map<String, dynamic>>
          result =
          await AdminLearningApi
              .getSubmaterials(materialId);

      submaterials.assignAll(result);

      final Map<String, dynamic> detail =
          await AdminLearningApi.getModule(
        materialId,
      );

      activeModule.value = detail;
    } catch (e) {
      showError(
        'Gagal memuat submateri: $e',
      );
    } finally {
      isLoadingContent.value = false;
    }
  }

  Future<void> loadVisualTypes() async {
    try {
      final result =
          await AdminLearningApi
              .getVisualTypes();

      visualTypes.assignAll(result);
    } catch (_) {
      visualTypes.assignAll(
        const <Map<String, dynamic>>[
          <String, dynamic>{
            'value': 'infographic',
            'label': 'Infografik',
          },
          <String, dynamic>{
            'value': 'comparison',
            'label': 'Perbandingan',
          },
          <String, dynamic>{
            'value': 'flow',
            'label': 'Alur',
          },
          <String, dynamic>{
            'value': 'chart',
            'label': 'Grafik/Data',
          },
          <String, dynamic>{
            'value': 'formula',
            'label': 'Rumus',
          },
          <String, dynamic>{
            'value': 'hotspot',
            'label': 'Titik Gambar',
          },
          <String, dynamic>{
            'value': 'sequence',
            'label': 'Urutan Proses',
          },
        ],
      );
    }
  }

  Future<bool> saveSubmaterial({
    int? submaterialId,
    required int materialId,
    required Map<String, dynamic> data,
    String? audioPath,
    String? imagePath,
  }) async {
    if (isSavingSubmaterial.value) {
      return false;
    }

    isSavingSubmaterial.value = true;

    try {
      if (submaterialId == null) {
        await AdminLearningApi
            .createSubmaterial(
          materialId: materialId,
          data: data,
          audioPath: audioPath,
          imagePath: imagePath,
        );
      } else {
        await AdminLearningApi
            .updateSubmaterial(
          submaterialId: submaterialId,
          data: data,
          audioPath: audioPath,
          imagePath: imagePath,
        );
      }

      await loadSubmaterials(materialId);
      await loadModules();

      Get.snackbar(
        'Berhasil',
        submaterialId == null
            ? 'Submateri berhasil dibuat.'
            : 'Submateri berhasil diperbarui.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError(
        'Gagal menyimpan submateri: $e',
      );
      return false;
    } finally {
      isSavingSubmaterial.value = false;
    }
  }

  Future<bool> deleteSubmaterial(
    Map<String, dynamic> submaterial,
  ) async {
    final int submaterialId =
        intValue(submaterial['id']);

    final int materialId =
        intValue(submaterial['material_id']);

    final bool confirmed =
        await Get.dialog<bool>(
              AlertDialog(
                title:
                    const Text('Hapus submateri?'),
                content: Text(
                  '"${submaterial['title'] ?? ''}" dan semua checkpoint di dalamnya akan dihapus permanen.',
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        Get.back<bool>(
                      result: false,
                    ),
                    child:
                        const Text('Batal'),
                  ),
                  FilledButton(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFDC2626,
                      ),
                    ),
                    onPressed: () =>
                        Get.back<bool>(
                      result: true,
                    ),
                    child:
                        const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirmed) {
      return false;
    }

    try {
      await AdminLearningApi
          .deleteSubmaterial(
        submaterialId,
      );

      await loadSubmaterials(materialId);
      await loadModules();

      Get.snackbar(
        'Submateri dihapus',
        'Konten dan checkpoint terkait berhasil dihapus.',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      showError(
        'Gagal menghapus submateri: $e',
      );
      return false;
    }
  }


  // =======================================================
  // CHECKPOINT & QUIZ (STEP 8C)
  // =======================================================

  Future<void> loadCheckpointTypes() async {
    try {
      checkpointTypes.assignAll(
        await AdminLearningApi.getCheckpointTypes(),
      );
    } catch (_) {
      checkpointTypes.assignAll(
        const <Map<String, dynamic>>[
          {'value': 'multiple_choice', 'label': 'Pilihan'},
          {'value': 'true_false', 'label': 'Benar/Salah'},
          {'value': 'matching', 'label': 'Pasangkan'},
          {'value': 'ordering', 'label': 'Urutkan'},
          {'value': 'image_hotspot', 'label': 'Tunjuk Bagian'},
          {'value': 'data_interpretation', 'label': 'Analisis Data'},
        ],
      );
    }
  }

  Future<void> openCheckpointManager(
    Map<String, dynamic> submaterial,
  ) async {
    activeSubmaterial.value =
        Map<String, dynamic>.from(submaterial);

    await loadCheckpoints(
      intValue(submaterial['id']),
    );
  }

  Future<void> loadCheckpoints(int submaterialId) async {
    if (isLoadingCheckpoints.value) return;

    isLoadingCheckpoints.value = true;

    try {
      checkpoints.assignAll(
        await AdminLearningApi.getCheckpoints(
          submaterialId,
        ),
      );
    } catch (e) {
      showError('Gagal memuat checkpoint: $e');
    } finally {
      isLoadingCheckpoints.value = false;
    }
  }

  Future<bool> saveCheckpoint({
    int? checkpointId,
    required int submaterialId,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    if (isSavingCheckpoint.value) return false;

    isSavingCheckpoint.value = true;

    try {
      await AdminLearningApi.saveCheckpoint(
        checkpointId: checkpointId,
        submaterialId: submaterialId,
        data: data,
        imagePath: imagePath,
      );

      await loadCheckpoints(submaterialId);

      final materialId = intValue(
        activeSubmaterial.value?['material_id'],
      );

      if (materialId > 0) {
        await loadSubmaterials(materialId);
      }

      Get.snackbar(
        'Berhasil',
        checkpointId == null
            ? 'Checkpoint berhasil dibuat.'
            : 'Checkpoint berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE7F8EE),
        colorText: const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError('Gagal menyimpan checkpoint: $e');
      return false;
    } finally {
      isSavingCheckpoint.value = false;
    }
  }

  Future<bool> deleteCheckpoint(
    Map<String, dynamic> checkpoint,
  ) async {
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Hapus checkpoint?'),
            content: Text(
              '"${checkpoint['title'] ?? 'Checkpoint'}" akan dihapus permanen.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back<bool>(
                  result: false,
                ),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Get.back<bool>(
                  result: true,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return false;

    try {
      final submaterialId = intValue(
        checkpoint['submaterial_id'],
      );

      await AdminLearningApi.deleteCheckpoint(
        intValue(checkpoint['id']),
      );

      await loadCheckpoints(submaterialId);

      final materialId = intValue(
        activeSubmaterial.value?['material_id'],
      );

      if (materialId > 0) {
        await loadSubmaterials(materialId);
      }

      return true;
    } catch (e) {
      showError('Gagal menghapus checkpoint: $e');
      return false;
    }
  }

  Future<void> loadQuestions(int materialId) async {
    if (isLoadingQuestions.value) return;

    isLoadingQuestions.value = true;

    try {
      questions.assignAll(
        await AdminLearningApi.getQuestions(materialId),
      );
    } catch (e) {
      showError('Gagal memuat soal kuis: $e');
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  Future<bool> saveQuestion({
    int? questionId,
    required int materialId,
    required Map<String, dynamic> data,
  }) async {
    if (isSavingQuestion.value) return false;

    isSavingQuestion.value = true;

    try {
      await AdminLearningApi.saveQuestion(
        questionId: questionId,
        materialId: materialId,
        data: data,
      );

      await loadQuestions(materialId);

      Get.snackbar(
        'Berhasil',
        questionId == null
            ? 'Soal kuis berhasil dibuat.'
            : 'Soal kuis berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE7F8EE),
        colorText: const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError('Gagal menyimpan soal kuis: $e');
      return false;
    } finally {
      isSavingQuestion.value = false;
    }
  }

  Future<bool> deleteQuestion(
    Map<String, dynamic> question,
    int materialId,
  ) async {
    final confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Hapus soal?'),
            content: Text(
              '"${question['question_text'] ?? 'Soal kuis'}" akan dihapus permanen.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Get.back<bool>(
                  result: false,
                ),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Get.back<bool>(
                  result: true,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return false;

    try {
      await AdminLearningApi.deleteQuestion(
        intValue(question['id']),
      );

      await loadQuestions(materialId);
      return true;
    } catch (e) {
      showError('Gagal menghapus soal kuis: $e');
      return false;
    }
  }

  Future<void> refreshModuleStructure(
    int materialId,
  ) async {
    await loadSubmaterials(materialId);
    await loadQuestions(materialId);
  }

  // =======================================================
  // FUN FACT
  // =======================================================

  List<Map<String, dynamic>>
      get filteredFunFacts {
    final String query =
        funFactSearchQuery.value
            .trim()
            .toLowerCase();

    if (query.isEmpty) {
      return funFacts.toList();
    }

    return funFacts.where((item) {
      final String text =
          (item['fact_text'] ?? '')
              .toString()
              .toLowerCase();

      return text.contains(query);
    }).toList();
  }

  void updateFunFactSearch(
    String value,
  ) {
    funFactSearchQuery.value =
        value.trim();
  }

  void clearFunFactSearch() {
    funFactSearchQuery.value = '';
  }

  Future<void> loadFunFacts() async {
    if (isLoadingFunFacts.value) {
      return;
    }

    isLoadingFunFacts.value = true;

    try {
      funFacts.assignAll(
        await AdminLearningApi.getFunFacts(),
      );
    } catch (e) {
      showError(
        'Gagal memuat Fun Fact: $e',
      );
    } finally {
      isLoadingFunFacts.value = false;
    }
  }

  Future<bool> saveFunFact({
    int? funFactId,
    required String factText,
  }) async {
    if (isSavingFunFact.value) {
      return false;
    }

    final String cleanText =
        factText.trim();

    if (cleanText.isEmpty) {
      showError(
        'Isi Fun Fact wajib diisi.',
      );
      return false;
    }

    isSavingFunFact.value = true;

    try {
      if (funFactId == null) {
        await AdminLearningApi
            .createFunFact(cleanText);
      } else {
        await AdminLearningApi
            .updateFunFact(
          funFactId: funFactId,
          factText: cleanText,
        );
      }

      // Refresh dan snackbar dilakukan setelah dialog ditutup
      // oleh AdminFunFactView. Urutan ini mencegah konflik
      // lifecycle overlay/dialog pada Flutter debug mode.
      return true;
    } catch (e) {
      showError(
        'Gagal menyimpan Fun Fact: $e',
      );
      return false;
    } finally {
      isSavingFunFact.value = false;
    }
  }

  Future<bool> deleteFunFact(
    Map<String, dynamic> funFact,
  ) async {
    if (isDeletingFunFact.value) {
      return false;
    }

    final bool confirmed =
        await Get.dialog<bool>(
              AlertDialog(
                title:
                    const Text('Hapus Fun Fact?'),
                content: Text(
                  '"${funFact['fact_text'] ?? 'Fun Fact'}" akan dihapus permanen.',
                  maxLines: 5,
                  overflow:
                      TextOverflow.ellipsis,
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () =>
                        Get.back<bool>(
                      result: false,
                    ),
                    child:
                        const Text('Batal'),
                  ),
                  FilledButton(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFDC2626,
                      ),
                    ),
                    onPressed: () =>
                        Get.back<bool>(
                      result: true,
                    ),
                    child:
                        const Text('Hapus'),
                  ),
                ],
              ),
            ) ??
            false;

    if (!confirmed) {
      return false;
    }

    isDeletingFunFact.value = true;

    try {
      await AdminLearningApi.deleteFunFact(
        intValue(funFact['id']),
      );

      await loadFunFacts();

      Get.snackbar(
        'Fun Fact dihapus',
        'Data berhasil dihapus.',
        snackPosition:
            SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      showError(
        'Gagal menghapus Fun Fact: $e',
      );
      return false;
    } finally {
      isDeletingFunFact.value = false;
    }
  }

  // =======================================================
  // TWO CSV IMPORT
  // =======================================================

  Future<bool> importLearningContent({
    required String filePath,
    required bool replaceExisting,
  }) async {
    if (isImportingLearningContent.value) {
      return false;
    }

    isImportingLearningContent.value = true;
    lastLearningImportResult.value = null;

    try {
      final result =
          await AdminLearningApi
              .importLearningContent(
        filePath: filePath,
        replaceExisting:
            replaceExisting,
      );

      lastLearningImportResult.value =
          result;

      await loadModules();

      final totals = mapValue(
        result['totals'],
      );

      Get.snackbar(
        'Konten berhasil diimpor',
        '${intValue(totals['imported'])} baru, '
        '${intValue(totals['updated'])} diperbarui, '
        '${intValue(totals['skipped'])} dilewati.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError(
        'Gagal import learning_content.csv: $e',
      );
      return false;
    } finally {
      isImportingLearningContent.value =
          false;
    }
  }

  Future<bool> importQuestionsCsv({
    required String filePath,
  }) async {
    if (isImportingQuestions.value) {
      return false;
    }

    isImportingQuestions.value = true;
    lastQuestionImportResult.value = null;

    try {
      final result =
          await AdminLearningApi
              .importQuestionsCsv(
        filePath: filePath,
      );

      lastQuestionImportResult.value =
          result;

      Get.snackbar(
        'Kuis berhasil diimpor',
        '${intValue(result['imported'])} baru, '
        '${intValue(result['updated'])} diperbarui, '
        '${mapList(result['skipped']).length} dilewati.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
      );

      return true;
    } catch (e) {
      showError(
        'Gagal import questions.csv: $e',
      );
      return false;
    } finally {
      isImportingQuestions.value = false;
    }
  }

  void clearImportResults() {
    lastLearningImportResult.value = null;
    lastQuestionImportResult.value = null;
  }

  // =======================================================
  // COMMON
  // =======================================================

  void showError(String message) {
    Get.snackbar(
      'Terjadi kesalahan',
      message,
      snackPosition:
          SnackPosition.BOTTOM,
      backgroundColor:
          const Color(0xFFFFE8E8),
      colorText:
          const Color(0xFF8C1D18),
    );
  }

  static int intValue(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }

  static bool boolValue(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    final String text =
        value?.toString().toLowerCase() ??
            '';

    if (text == 'true' || text == '1') {
      return true;
    }

    if (text == 'false' || text == '0') {
      return false;
    }

    return fallback;
  }

  static Map<String, dynamic> mapValue(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>>
      mapList(
    dynamic value,
  ) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();
  }
}
