import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/api_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../rewards/controllers/xp_reward_controller.dart';

class LearningController extends GetxController {
  static LearningController ensureRegistered() {
    if (Get.isRegistered<LearningController>()) {
      return Get.find<LearningController>();
    }
    return Get.put(LearningController(), permanent: true);
  }

  final RxBool isLoadingLevels = false.obs;
  final RxBool isLoadingModules = false.obs;
  final RxBool isLoadingModuleDetail = false.obs;
  final RxBool isOpeningMode = false.obs;
  final RxBool isCompletingMode = false.obs;
  final RxBool isLoadingQuiz = false.obs;
  final RxBool isSubmittingQuiz = false.obs;
  final RxBool isLoadingOverview = false.obs;
  final RxBool isClaimingDailyQuest = false.obs;
  final RxSet<int> submittingCheckpointIds = <int>{}.obs;

  final RxList<Map<String, dynamic>> levels =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> modules =
      <Map<String, dynamic>>[].obs;

  static const List<String> categoryOptions = <String>[
    'Semua',
    'Biologi',
    'Fisika',
    'Kimia',
  ];

  final TextEditingController searchTextController =
      TextEditingController();

  final RxString selectedCategory = 'Semua'.obs;
  final RxString searchQuery = ''.obs;

  final RxInt selectedLevel = 1.obs;
  final Rxn<Map<String, dynamic>> selectedModule =
      Rxn<Map<String, dynamic>>();

  final RxString errorMessage = ''.obs;

  final Rxn<Map<String, dynamic>> activeQuiz =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> quizResult =
      Rxn<Map<String, dynamic>>();

  final Rxn<Map<String, dynamic>> learningProgress =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> gamificationData =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> dailyQuest =
      Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> initialize() async {
    await Future.wait<void>(<Future<void>>[
      loadLevels(),
      loadOverview(silent: true),
    ]);
  }

  Future<void> loadOverview({
    bool silent = false,
  }) async {
    if (isLoadingOverview.value) {
      return;
    }

    isLoadingOverview.value = true;

    try {
      final responses = await Future.wait<dynamic>(
        <Future<dynamic>>[
          ApiService.getLearningProgress(),
          ApiService.getUserData(),
          ApiService.getTodayDailyQuest(),
        ],
      );

      final progressResponse = responses[0];
      final gamificationResponse = responses[1];
      final dailyQuestResponse = responses[2];

      if (progressResponse is Map) {
        final progressMap =
            Map<String, dynamic>.from(
          progressResponse,
        );

        if (!isFailure(progressMap)) {
          learningProgress.value = progressMap;
        } else if (!silent) {
          showError(messageFrom(progressMap));
        }
      }

      if (gamificationResponse is Map) {
        gamificationData.value =
            Map<String, dynamic>.from(
          gamificationResponse,
        );
      }

      if (dailyQuestResponse is Map) {
        dailyQuest.value =
            Map<String, dynamic>.from(
          dailyQuestResponse,
        );
      }
    } catch (e) {
      if (!silent) {
        showError(
          'Gagal memuat ringkasan progres: $e',
        );
      }
    } finally {
      isLoadingOverview.value = false;
    }
  }

  Future<void> refreshAllLearningData() async {
    await Future.wait<void>(<Future<void>>[
      loadLevels(),
      loadOverview(),
    ]);
  }


  Future<void> loadLevels({
    bool alsoLoadModules = true,
  }) async {
    if (isLoadingLevels.value) {
      return;
    }

    isLoadingLevels.value = true;
    errorMessage.value = '';

    try {
      final result = await ApiService.getLearningLevels();
      levels.assignAll(result);

      if (result.isEmpty) {
        errorMessage.value =
            'Data level belum tersedia atau backend belum dapat dihubungi.';
        modules.clear();
        return;
      }

      final currentLevelData = result.firstWhereOrNull(
        (item) => intValue(item['level']) == selectedLevel.value,
      );

      final bool currentStillUnlocked =
          currentLevelData != null &&
          boolValue(currentLevelData['is_unlocked']);

      if (!currentStillUnlocked) {
        final firstUnlocked = result.firstWhereOrNull(
          (item) => boolValue(item['is_unlocked']),
        );

        selectedLevel.value = firstUnlocked == null
            ? 1
            : intValue(
                firstUnlocked['level'],
                fallback: 1,
              );
      }

      if (alsoLoadModules) {
        await loadModules(selectedLevel.value);
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat level: $e';
    } finally {
      isLoadingLevels.value = false;
    }
  }

  Future<void> refreshLevelsOnly() async {
    await loadLevels(alsoLoadModules: false);
  }

  Future<void> selectLevel(int level) async {
    final levelData = levels.firstWhereOrNull(
      (item) => intValue(item['level']) == level,
    );

    if (levelData == null) {
      showError('Level tidak ditemukan.');
      return;
    }

    if (!boolValue(levelData['is_unlocked'])) {
      AppSnackbar.warning(
        'Level Masih Terkunci',
        'Selesaikan level sebelumnya terlebih dahulu untuk membuka level ini.',
      );
      return;
    }

    selectedLevel.value = level;
    selectedModule.value = null;
    await loadModules(level);
  }

  Future<void> selectCategory(
    String category,
  ) async {
    if (!categoryOptions.contains(category)) {
      showError('Kategori materi tidak tersedia.');
      return;
    }

    if (selectedCategory.value == category) {
      return;
    }

    selectedCategory.value = category;
    selectedModule.value = null;
    await loadModules(selectedLevel.value);
  }

  void updateSearchQuery(String value) {
    searchQuery.value = value.trim();
  }

  void clearSearch() {
    searchTextController.clear();
    searchQuery.value = '';
  }

  List<Map<String, dynamic>> get filteredModules {
    final String selected =
        selectedCategory.value.trim().toLowerCase();
    final String query =
        searchQuery.value.trim().toLowerCase();

    return modules.where((module) {
      final String category =
          (module['category'] ?? '')
              .toString()
              .trim()
              .toLowerCase();

      final bool categoryMatches =
          selected == 'semua' ||
          category == selected;

      if (!categoryMatches) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final String searchableText = <dynamic>[
        module['title'],
        module['short_description'],
        module['category'],
        module['instructions'],
      ]
          .where((value) => value != null)
          .map((value) => value.toString())
          .join(' ')
          .toLowerCase();

      return searchableText.contains(query);
    }).toList();
  }

  String get activeFilterTitle {
    final String category = selectedCategory.value;

    if (category == 'Semua') {
      return 'Semua Materi • Level ${selectedLevel.value}';
    }

    return '$category • Level ${selectedLevel.value}';
  }

  Future<void> loadModules(int level) async {
    if (isLoadingModules.value) {
      return;
    }

    isLoadingModules.value = true;
    errorMessage.value = '';

    try {
      final String? category =
          selectedCategory.value == 'Semua'
              ? null
              : selectedCategory.value;

      final result = await ApiService.getLearningModules(
        level: level,
        category: category,
      );

      modules.assignAll(result);

      if (result.isEmpty) {
        final String categoryLabel =
            category == null ? '' : ' $category';

        errorMessage.value =
            'Belum ada modul$categoryLabel pada Level $level.';
      }
    } catch (e) {
      modules.clear();
      errorMessage.value = 'Gagal memuat modul: $e';
    } finally {
      isLoadingModules.value = false;
    }
  }

  Future<bool> loadModuleDetail(int materialId) async {
    if (isLoadingModuleDetail.value) {
      return false;
    }

    isLoadingModuleDetail.value = true;

    try {
      final result = await ApiService.getLearningModule(
        materialId,
      );

      if (result == null) {
        showError('Backend tidak mengirim data modul.');
        return false;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return false;
      }

      selectedModule.value = result;
      try {
        final box = GetStorage();
        final dynamic rawList = box.read('accessed_module_ids');
        final List<int> accessedIds = <int>[];
        if (rawList is List) {
          for (final item in rawList) {
            final int id = int.tryParse(item.toString()) ?? 0;
            if (id > 0 && !accessedIds.contains(id)) {
              accessedIds.add(id);
            }
          }
        }
        accessedIds.remove(materialId);
        accessedIds.insert(0, materialId);
        if (accessedIds.length > 5) {
          accessedIds.removeLast();
        }
        box.write('accessed_module_ids', accessedIds);
        box.write('last_accessed_module_id', materialId);

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchInProgressMaterials();
        }
      } catch (_) {}

      return true;
    } catch (e) {
      showError('Gagal membuka modul: $e');
      return false;
    } finally {
      isLoadingModuleDetail.value = false;
    }
  }

  Future<bool> refreshSelectedModule() async {
    final module = selectedModule.value;

    if (module == null) {
      return false;
    }

    return loadModuleDetail(
      intValue(module['id']),
    );
  }

  Future<bool> openMode({
    required int submaterialId,
    required String mode,
  }) async {
    if (isOpeningMode.value) {
      return false;
    }

    isOpeningMode.value = true;

    try {
      final result = await ApiService.openSubmaterial(
        submaterialId,
        mode: mode,
      );

      if (result == null) {
        showError('Backend tidak mengirim respons.');
        return false;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return false;
      }

      return true;
    } catch (e) {
      showError('Gagal membuka mode belajar: $e');
      return false;
    } finally {
      isOpeningMode.value = false;
    }
  }

  Future<bool> completeMode({
    required int submaterialId,
    required String mode,
  }) async {
    if (isCompletingMode.value) {
      return false;
    }

    isCompletingMode.value = true;

    try {
      final result = await ApiService.completeLearningMode(
        submaterialId,
        mode: mode,
      );

      if (result == null) {
        showError('Backend tidak mengirim respons.');
        return false;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return false;
      }

      await refreshSelectedModule();
      await loadModules(selectedLevel.value);
      await refreshLevelsOnly();
      if (boolValue(
        result['submaterial_completed'],
      )) {
        final quest =
            await ApiService.updateDailyQuestProgress(
          'read_material',
        );

        if (quest != null) {
          dailyQuest.value = quest;
        }
      }

      await loadOverview(silent: true);
      await refreshExternalControllers();
      await showBadgePopups(
        stringList(
          result['new_badges_unlocked'],
        ),
      );

      if (result['submaterial_completed'] == true) {
        AppSnackbar.success(
          'Aktivitas Selesai',
          'Aktivitas dan checkpoint selesai. Submateri berhasil dituntaskan!',
        );
      } else {
        AppSnackbar.info(
          'Progres Tersimpan',
          'Progres belajar disimpan. Lanjutkan ke tahap checkpoint.',
        );
      }

      return true;
    } catch (e) {
      showError('Gagal menyelesaikan mode belajar: $e');
      return false;
    } finally {
      isCompletingMode.value = false;
    }
  }


  bool isSubmittingCheckpoint(int checkpointId) {
    return submittingCheckpointIds.contains(checkpointId);
  }

  Future<Map<String, dynamic>?> submitCheckpointAnswer({
    required int checkpointId,
    required dynamic answer,
  }) async {
    if (isSubmittingCheckpoint(checkpointId)) {
      return null;
    }

    submittingCheckpointIds.add(checkpointId);

    try {
      final result = await ApiService.submitCheckpoint(
        checkpointId,
        answer: answer,
      );

      if (result == null) {
        showError('Backend tidak mengirim respons checkpoint.');
        return null;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return result;
      }

      await refreshSelectedModule();
      await loadModules(selectedLevel.value);
      await refreshLevelsOnly();
      if (boolValue(
        result['submaterial_completed'],
      )) {
        final quest =
            await ApiService.updateDailyQuestProgress(
          'read_material',
        );

        if (quest != null) {
          dailyQuest.value = quest;
        }
      }

      await loadOverview(silent: true);
      await refreshExternalControllers();
      await showBadgePopups(
        stringList(
          result['new_badges_unlocked'],
        ),
      );

      final bool correct = boolValue(
        result['is_correct'],
      );

      final int checkpointXp =
          intValue(result['total_xp_added']);
      final bool xpAlreadyReceived =
          boolValue(result['xp_already_received']);

      if (!correct) {
        AppSnackbar.warning(
          'Jawaban Belum Tepat',
          (result['feedback'] ?? 'Pelajari kembali materi lalu coba lagi.').toString(),
        );
      } else if (checkpointXp > 0) {
        AppSnackbar.success(
          'Checkpoint Selesai • +$checkpointXp XP',
          (result['feedback'] ?? 'Jawabanmu benar dan progres sudah disimpan.').toString(),
        );
      } else if (xpAlreadyReceived) {
        AppSnackbar.info(
          'Checkpoint Sudah Selesai',
          'Jawabanmu benar. XP dari checkpoint ini sudah pernah diterima.',
        );
      } else {
        AppSnackbar.success(
          'Jawaban Benar',
          (result['feedback'] ?? 'Checkpoint berhasil diselesaikan.').toString(),
        );
      }

      if (correct) {
        await _syncXpRewardsFromResult(
          result,
        );
      }

      return result;
    } catch (e) {
      showError('Gagal mengirim jawaban checkpoint: $e');
      return null;
    } finally {
      submittingCheckpointIds.remove(checkpointId);
    }
  }


  Future<void> _syncXpRewardsFromResult(
    Map<String, dynamic> result,
  ) async {
    final int xp =
        intValue(
      result['current_xp'],
      fallback: -1,
    );

    if (xp < 0) {
      return;
    }

    final Map<String, dynamic> userData =
        gamificationData.value ??
            <String, dynamic>{};

    final String userKey =
        (userData['email'] ??
                userData['username'] ??
                '')
            .toString();

    await XpRewardController
        .ensureRegistered()
        .syncXp(
      xp,
      userKey: userKey,
      showUnlockDialog: true,
    );
  }

  Future<bool> loadQuiz(int materialId) async {
    if (isLoadingQuiz.value) {
      return false;
    }

    isLoadingQuiz.value = true;
    quizResult.value = null;

    try {
      final result = await ApiService.getModuleQuiz(
        materialId,
      );

      if (result == null) {
        showError('Backend tidak mengirim data kuis.');
        return false;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return false;
      }

      final questions = mapList(
        result['questions'],
      );

      if (questions.isEmpty) {
        showError('Soal kuis belum tersedia.');
        return false;
      }

      activeQuiz.value = result;
      return true;
    } catch (e) {
      showError('Gagal memuat kuis: $e');
      return false;
    } finally {
      isLoadingQuiz.value = false;
    }
  }

  Future<Map<String, dynamic>?> submitQuizAnswers({
    required int materialId,
    required List<Map<String, dynamic>> answers,
  }) async {
    if (isSubmittingQuiz.value) {
      return null;
    }

    isSubmittingQuiz.value = true;

    try {
      final result = await ApiService.submitModuleQuiz(
        materialId,
        answers: answers,
      );

      if (result == null) {
        showError('Backend tidak mengirim hasil kuis.');
        return null;
      }

      if (isFailure(result)) {
        showError(messageFrom(result));
        return result;
      }

      quizResult.value = result;

      await refreshSelectedModule();
      await loadModules(selectedLevel.value);
      await refreshLevelsOnly();
      final quest =
          await ApiService.updateDailyQuestProgress(
        'do_quiz',
      );

      if (quest != null) {
        dailyQuest.value = quest;
      }

      await loadOverview(silent: true);
      await refreshExternalControllers();
      await showBadgePopups(
        stringList(
          result['new_badges_unlocked'],
        ),
      );

      final bool passed = boolValue(
        result['passed'],
      );

      final int quizScore =
          intValue(result['score']);
      final int passingScore =
          intValue(
        result['passing_score'],
        fallback: 75,
      );
      final int quizXp =
          intValue(result['total_xp_added']);
      final bool quizXpAlreadyReceived =
          boolValue(result['xp_already_received']);

      if (!passed) {
        AppSnackbar.warning(
          'Kuis Belum Mencapai Target',
          'Nilai $quizScore (Target Minimal $passingScore). Pelajari pembahasan lalu coba lagi.',
        );
      } else if (quizXp > 0) {
        AppSnackbar.success(
          'Kuis Lulus • +$quizXp XP',
          'Nilai $quizScore. Hasil kuis dan hadiah XP berhasil disimpan!',
        );
      } else if (quizXpAlreadyReceived) {
        AppSnackbar.info(
          'Kuis Sudah Lulus',
          'Nilai $quizScore. XP kuis ini sudah pernah diterima.',
        );
      } else {
        AppSnackbar.success(
          'Kuis Lulus',
          'Nilai $quizScore. Hasil kuis berhasil disimpan.',
        );
      }

      if (passed) {
        await _syncXpRewardsFromResult(
          result,
        );
      }

      return result;
    } catch (e) {
      showError('Gagal mengirim kuis: $e');
      return null;
    } finally {
      isSubmittingQuiz.value = false;
    }
  }

  void clearQuizSession() {
    activeQuiz.value = null;
    quizResult.value = null;
  }


  Future<bool> claimDailyQuest() async {
    if (isClaimingDailyQuest.value) {
      return false;
    }

    final quest = dailyQuest.value;

    if (quest == null) {
      showError('Daily Quest belum tersedia.');
      return false;
    }

    if (boolValue(quest['is_claimed'])) {
      showError(
        'Reward Daily Quest hari ini sudah diklaim.',
      );
      return false;
    }

    if (!allDailyQuestsCompleted) {
      showError(
        'Selesaikan tiga Daily Quest terlebih dahulu.',
      );
      return false;
    }

    isClaimingDailyQuest.value = true;

    try {
      final result =
          await ApiService.claimDailyQuestReward();

      if (result == null) {
        showError(
          'Backend tidak mengirim respons klaim.',
        );
        return false;
      }

      final resultMap =
          Map<String, dynamic>.from(result);

      final refreshedQuest = mapValue(
        resultMap['daily_quest'],
      );

      if (refreshedQuest.isNotEmpty) {
        dailyQuest.value = refreshedQuest;
      }

      if (resultMap['error'] != null) {
        showError(
          resultMap['error'].toString(),
        );
        return false;
      }

      await loadOverview(silent: true);
      await refreshExternalControllers();

      final int rewardXp = intValue(
        resultMap['reward_xp'],
        fallback: 50,
      );

      AppSnackbar.success(
        'Reward Berhasil Diklaim',
        '+$rewardXp XP berhasil masuk ke akun belajarmu!',
      );

      if (boolValue(resultMap['level_up'])) {
        await Get.dialog<void>(
          _LearningLevelUpDialog(
            level: intValue(
              resultMap['level'],
              fallback: gamificationLevel,
            ),
          ),
          barrierDismissible: false,
        );
      }

      return true;
    } catch (e) {
      showError(
        'Gagal mengklaim Daily Quest: $e',
      );
      return false;
    } finally {
      isClaimingDailyQuest.value = false;
    }
  }

  Future<void> refreshExternalControllers() async {
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>()
          .fetchDailyQuest();
    }

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>()
          .fetchUserProfile();
    }
  }

  Future<void> showBadgePopups(
    List<String> badgeNames,
  ) async {
    for (final badgeName in badgeNames) {
      await Get.dialog<void>(
        _LearningBadgeDialog(
          badgeName: badgeName,
          imagePath: badgeImagePath(
            badgeName,
          ),
        ),
        barrierDismissible: false,
      );
    }
  }

  double get overallProgress {
    return doubleValue(
      learningProgress.value?['overall_progress'],
    ).clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> get progressModules {
    return mapList(
      learningProgress.value?['modules'],
    );
  }

  int get completedModuleCount {
    return progressModules
        .where(
          (item) => boolValue(
            item['module_completed'],
          ),
        )
        .length;
  }

  int get totalXp {
    return intValue(
      gamificationData.value?['total_xp'],
    );
  }

  int get gamificationLevel {
    return intValue(
      gamificationData.value?['level'],
      fallback: (totalXp ~/ 200) + 1,
    );
  }

  int get xpInCurrentLevel {
    return totalXp % 200;
  }

  int get xpToNextLevel {
    return 200 - xpInCurrentLevel;
  }

  double get xpLevelProgress {
    return (xpInCurrentLevel / 200)
        .clamp(0.0, 1.0);
  }

  int get streak {
    return intValue(
      gamificationData.value?['streak'],
    );
  }

  List<Map<String, dynamic>> get badges {
    return mapList(
      gamificationData.value?['badges'],
    );
  }

  List<Map<String, dynamic>> get dailyQuestItems {
    return mapList(
      dailyQuest.value?['quests'],
    );
  }

  bool get allDailyQuestsCompleted {
    final quest = dailyQuest.value;

    if (quest == null) {
      return false;
    }

    if (quest.containsKey('all_completed')) {
      return boolValue(
        quest['all_completed'],
      );
    }

    final items = dailyQuestItems;

    return items.isNotEmpty &&
        items.every(
          (item) => boolValue(
            item['is_completed'],
          ),
        );
  }

  bool get dailyQuestClaimed {
    return boolValue(
      dailyQuest.value?['is_claimed'],
    );
  }

  int get dailyQuestRewardXp {
    return intValue(
      dailyQuest.value?['reward_xp'],
      fallback: 50,
    );
  }

  static List<String> stringList(dynamic value) {
    if (value is! List) {
      return <String>[];
    }

    return value
        .map((item) => item.toString())
        .where(
          (item) => item.trim().isNotEmpty,
        )
        .toList();
  }

  static String badgeImagePath(String name) {
    switch (name) {
      case 'Darwin’s Successor':
        return 'assets/badge/1.png';
      case 'Quantum Overlord':
        return 'assets/badge/2.png';
      case 'The Modern Alchemist':
        return 'assets/badge/3.png';
      case 'Virtual Researcher':
        return 'assets/badge/4.png';
      case 'Mad Scientist':
        return 'assets/badge/5.png';
      case 'Grand Analyst':
        return 'assets/badge/6.png';
      case 'Lab Regular':
        return 'assets/badge/7.png';
      case 'First Spark':
        return 'assets/badge/8.png';
      case 'Trivia Rover':
        return 'assets/badge/9.png';
      case 'Night Owl':
        return 'assets/badge/10.png';
      case 'Flawless Victory':
        return 'assets/badge/11.png';
      default:
        return 'assets/badge/8.png';
    }
  }

  Map<String, dynamic>? findSubmaterial(int submaterialId) {
    final module = selectedModule.value;

    if (module == null) {
      return null;
    }

    final items = mapList(module['submaterials']);

    return items.firstWhereOrNull(
      (item) => intValue(item['id']) == submaterialId,
    );
  }

  bool isModeAvailable(
    Map<String, dynamic> submaterial,
    String mode,
  ) {
    final available = mapValue(
      submaterial['available_modes'],
    );

    return boolValue(available[mode]);
  }

  bool isFailure(Map<String, dynamic> data) {
    return data['success'] == false ||
        intValue(data['status_code']) >= 400;
  }

  String messageFrom(Map<String, dynamic> data) {
    return (data['error'] ??
            data['message'] ??
            'Terjadi kesalahan.')
        .toString();
  }

  void showError(String message) {
    AppSnackbar.error(
      'Perhatian',
      message,
    );
  }

  static bool boolValue(dynamic value) {
    if (value is bool) {
      return value;
    }

    return value.toString().toLowerCase() == 'true' ||
        value.toString() == '1';
  }

  static int intValue(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ??
        fallback;
  }

  static double doubleValue(
    dynamic value, {
    double fallback = 0,
  }) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ??
        fallback;
  }

  static Map<String, dynamic> mapValue(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> mapList(
    dynamic value,
  ) {
    if (value is! List) {
      return <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }
}


class _LearningBadgeDialog extends StatelessWidget {
  const _LearningBadgeDialog({
    required this.badgeName,
    required this.imagePath,
  });

  final String badgeName;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFDE68A),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                imagePath,
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.military_tech_rounded,
                    color: Color(0xFFD97706),
                    size: 42,
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'LENCANA PENCAPAIAN',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              badgeName,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lencana baru berhasil ditambahkan ke profil belajarmu.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Get.back<void>(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Lanjutkan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningLevelUpDialog extends StatelessWidget {
  const _LearningLevelUpDialog({
    required this.level,
  });

  final int level;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFBFDBFE),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF2563EB),
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'LEVEL BERTAMBAH',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Naik ke Level $level',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selamat, pengalaman belajarmu meningkat. Terus pertahankan konsistensimu!',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () => Get.back<void>(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Lanjutkan Belajar',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
