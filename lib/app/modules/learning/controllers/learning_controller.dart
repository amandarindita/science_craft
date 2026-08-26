import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../rewards/controllers/xp_reward_controller.dart';

class LearningController extends GetxController {
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
      Get.snackbar(
        'Level masih terkunci',
        'Selesaikan level sebelumnya terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFE8E8),
        colorText: const Color(0xFF8C1D18),
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

      Get.snackbar(
        'Aktivitas selesai ✓',
        result['submaterial_completed'] == true
            ? 'Aktivitas dan checkpoint selesai. Submateri berhasil dituntaskan.'
            : 'Progres berhasil disimpan. Lanjutkan ke checkpoint.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE7F8EE),
        colorText: const Color(0xFF166534),
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF166534),
        ),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
        duration: const Duration(seconds: 3),
      );

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

      final String checkpointTitle;
      final String checkpointMessage;
      final Color checkpointBackground;
      final Color checkpointText;
      final IconData checkpointIcon;

      if (!correct) {
        checkpointTitle =
            'Jawaban belum tepat';
        checkpointMessage =
            (result['feedback'] ??
                    'Pelajari kembali materi lalu coba lagi.')
                .toString();
        checkpointBackground =
            const Color(0xFFFFF3E0);
        checkpointText =
            const Color(0xFF9A3412);
        checkpointIcon =
            Icons.lightbulb_outline_rounded;
      } else if (checkpointXp > 0) {
        checkpointTitle =
            'Checkpoint selesai • +$checkpointXp XP';
        checkpointMessage =
            (result['feedback'] ??
                    'Jawabanmu benar dan progres sudah disimpan.')
                .toString();
        checkpointBackground =
            const Color(0xFFE7F8EE);
        checkpointText =
            const Color(0xFF166534);
        checkpointIcon =
            Icons.check_circle_rounded;
      } else if (xpAlreadyReceived) {
        checkpointTitle =
            'Checkpoint sudah selesai';
        checkpointMessage =
            'Jawabanmu benar. XP dari checkpoint ini sudah pernah diterima.';
        checkpointBackground =
            const Color(0xFFEAF1FF);
        checkpointText =
            const Color(0xFF1E40AF);
        checkpointIcon =
            Icons.info_rounded;
      } else {
        checkpointTitle = 'Jawaban benar';
        checkpointMessage =
            (result['feedback'] ??
                    'Checkpoint berhasil diselesaikan.')
                .toString();
        checkpointBackground =
            const Color(0xFFE7F8EE);
        checkpointText =
            const Color(0xFF166534);
        checkpointIcon =
            Icons.check_circle_rounded;
      }

      Get.snackbar(
        checkpointTitle,
        checkpointMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: checkpointBackground,
        colorText: checkpointText,
        icon: Icon(
          checkpointIcon,
          color: checkpointText,
        ),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
        duration: const Duration(seconds: 4),
      );

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

      final String quizTitle;
      final String quizMessage;
      final Color quizBackground;
      final Color quizText;
      final IconData quizIcon;

      if (!passed) {
        quizTitle = 'Kuis belum lulus';
        quizMessage =
            'Nilai $quizScore. Nilai minimal $passingScore. Pelajari pembahasan lalu coba lagi.';
        quizBackground =
            const Color(0xFFFFF3E0);
        quizText =
            const Color(0xFF9A3412);
        quizIcon =
            Icons.restart_alt_rounded;
      } else if (quizXp > 0) {
        quizTitle =
            'Kuis lulus • +$quizXp XP';
        quizMessage =
            'Nilai $quizScore. Hasil kuis dan XP berhasil disimpan.';
        quizBackground =
            const Color(0xFFE7F8EE);
        quizText =
            const Color(0xFF166534);
        quizIcon =
            Icons.emoji_events_rounded;
      } else if (quizXpAlreadyReceived) {
        quizTitle = 'Kuis sudah lulus';
        quizMessage =
            'Nilai $quizScore. XP kuis ini sudah pernah diterima.';
        quizBackground =
            const Color(0xFFEAF1FF);
        quizText =
            const Color(0xFF1E40AF);
        quizIcon = Icons.info_rounded;
      } else {
        quizTitle = 'Kuis lulus';
        quizMessage =
            'Nilai $quizScore. Hasil kuis berhasil disimpan.';
        quizBackground =
            const Color(0xFFE7F8EE);
        quizText =
            const Color(0xFF166534);
        quizIcon =
            Icons.check_circle_rounded;
      }

      Get.snackbar(
        quizTitle,
        quizMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: quizBackground,
        colorText: quizText,
        icon: Icon(
          quizIcon,
          color: quizText,
        ),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
        duration: const Duration(seconds: 4),
      );

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

      Get.snackbar(
        'Reward berhasil diklaim',
        '+$rewardXp XP masuk ke akunmu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
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
    Get.snackbar(
      'Tidak dapat melanjutkan',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFE8E8),
      colorText: const Color(0xFF8C1D18),
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
    return AlertDialog(
      icon: SizedBox(
        width: 84,
        height: 84,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFF59E0B),
              size: 68,
            );
          },
        ),
      ),
      title: const Text(
        'Pencapaian Baru!',
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Kamu berhasil membuka badge:\n\n$badgeName',
        textAlign: TextAlign.center,
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Mantap'),
        ),
      ],
    );
  }
}

class _LearningLevelUpDialog
    extends StatelessWidget {
  const _LearningLevelUpDialog({
    required this.level,
  });

  final int level;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.rocket_launch_rounded,
        color: Color(0xFF2563EB),
        size: 48,
      ),
      title: const Text(
        'Level XP Naik!',
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Selamat, sekarang kamu mencapai Level XP $level.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }
}
