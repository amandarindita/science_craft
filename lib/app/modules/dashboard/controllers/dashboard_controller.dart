import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../data/api_client.dart';
import '../../../data/api_service.dart';
import '../../../models/material_model.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../rewards/controllers/xp_reward_controller.dart';
import '../../learning/controllers/learning_controller.dart';
import '../../learning/views/learning_view.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  // =====================================================
  // DATA USER & GAMIFICATION
  // =====================================================
  final userName = 'Sobat Sains'.obs;
  final userEmail = ''.obs;
  final userStreak = 0.obs;

  // Tetap disimpan untuk kompatibilitas Daily Quest lama.
  // Dashboard baru tidak menampilkan Level dari XP.
  final userLevel = 1.obs;
  final userXp = 0.obs;
  

  // =====================================================
  // DATA "LANJUTKAN BELAJAR"
  // =====================================================
  final inProgressMaterials = <MaterialItem>[].obs;
  final isLoading = true.obs;

  // =====================================================
  // RINGKASAN PEMBELAJARAN AKADEMIK LEVEL 1–3
  // =====================================================
  final isLearningSummaryLoading = true.obs;
  final currentLearningLevel = 1.obs;
  final learningCompletedModules = 0.obs;
  final learningTotalModules = 0.obs;
  final currentLevelCompletedModules = 0.obs;
  final currentLevelTotalModules = 0.obs;
  final currentLevelProgress = 0.0.obs;

  // =====================================================
  // BAGIAN FAKTA SAINS
  // =====================================================
  var currentFact = <String, String>{}.obs;
  var allFactsFromDb = <Map<String, dynamic>>[].obs;
  int _lastFactIndex = -1;

  DateTime? _lastDashboardVisibleAt;

  // =====================================================
  // BAGIAN DAILY QUEST - BACKEND VERSION
  // =====================================================
  final dailyQuests = <Map<String, dynamic>>[].obs;
  final isDailyRewardClaimed = false.obs;
  final dailyRewardTickets = 1.obs;
  final isDailyQuestLoading = false.obs;
  final dailyRewardXp = 50.obs; // Tambahkan kembali variabel ini agar view tidak error

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    fetchUserProfile();
    fetchLearningSummary();
    fetchInProgressMaterials();
    fetchFunFacts();

    // Ambil Daily Quest dari backend.
    fetchDailyQuest();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  // =====================================================
  // APP LIFECYCLE
  // =====================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onDashboardVisible();
    }
  }

  // =====================================================
  // DASHBOARD DIBUKA / KEMBALI TERLIHAT
  // =====================================================
  void onDashboardVisible() {
    final DateTime now = DateTime.now();

    // Mencegah Fun Fact berganti dua kali karena rebuild cepat.
    if (_lastDashboardVisibleAt != null &&
        now.difference(_lastDashboardVisibleAt!).inMilliseconds < 700) {
      return;
    }

    _lastDashboardVisibleAt = now;

    fetchUserProfile();
    fetchLearningSummary();
    fetchInProgressMaterials();
    fetchDailyQuest();

    // Tidak perlu tombol refresh.
    // Fakta berganti otomatis ketika Dashboard dibuka kembali.
    if (allFactsFromDb.isNotEmpty) {
      randomizeFact();
    }
  }

  // =====================================================
  // HELPER KONVERSI DATA
  // =====================================================
  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final normalized = value.toLowerCase();

      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }

    return false;
  }

  double _normalizeProgress(dynamic value) {
    double progress = 0.0;

    if (value is num) {
      progress = value.toDouble();
    } else {
      progress = double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    // Mendukung respons 0–1 maupun 0–100.
    if (progress > 1.0) {
      progress = progress / 100;
    }

    return progress.clamp(0.0, 1.0);
  }

  List<Map<String, dynamic>> _mapList(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _levelTitle(int level) {
    if (level == 1) {
      return "Level 1: Siswa Baru 🔬";
    } else if (level == 2) {
      return "Level 2: Peneliti Junior 🧪";
    } else if (level == 3) {
      return "Level 3: Asisten Lab 🧬";
    } else if (level == 4) {
      return "Level 4: Ahli Sains 🌌";
    } else {
      return "Level $level: Professor Madya 🧠";
    }
  }

  // =====================================================
  // 1. AMBIL PROFIL, STREAK, DAN XP DARI SERVER
  // =====================================================
  void fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();

      if (userData != null) {
        if (userData['id'] != null) {
          GetStorage().write('userId', userData['id'].toString());
        }
        if (userData['email'] != null) {
          GetStorage().write('userEmail', userData['email'].toString());
        }

        userName.value = (userData['username'] ?? 'Sobat Sains').toString();
        userEmail.value = (userData['email'] ?? '').toString();

        // Backend memakai key streak, total_xp, dan level.
        userStreak.value = _toInt(
          userData['streak'] ?? userData['streak_count'],
        );

        userLevel.value = _toInt(userData['level'], fallback: 1);

        userXp.value = _toInt(userData['total_xp'] ?? userData['xp']);
      }
    } catch (e) {
      print("Error fetch profile: $e");
    }
  }

  // =====================================================
  // RINGKASAN LEVEL PEMBELAJARAN AKADEMIK
  // =====================================================
  Future<void> fetchLearningSummary() async {
    isLearningSummaryLoading.value = true;

    try {
      final Map<String, dynamic>? data = await ApiService.getLearningProgress();

      if (data == null || data['success'] == false) {
        _resetLearningSummary();
        return;
      }

      final List<Map<String, dynamic>> modules =
          _mapList(data['modules'])
              .where(
                (Map<String, dynamic> item) => !_toBool(item['legacy_mode']),
              )
              .toList();

      learningTotalModules.value = modules.length;
      learningCompletedModules.value =
          modules
              .where(
                (Map<String, dynamic> item) =>
                    _toBool(item['module_completed']),
              )
              .length;

      int activeLevel = 1;

      for (int level = 1; level <= 3; level++) {
        final List<Map<String, dynamic>> levelModules =
            modules
                .where(
                  (Map<String, dynamic> item) =>
                      _toInt(item['level'], fallback: 1) == level,
                )
                .toList();

        final bool isUnlocked =
            level == 1 ||
            levelModules.any(
              (Map<String, dynamic> item) => _toBool(item['is_unlocked']),
            );

        if (isUnlocked) {
          activeLevel = level;
        }
      }

      currentLearningLevel.value = activeLevel;

      final List<Map<String, dynamic>> currentModules =
          modules
              .where(
                (Map<String, dynamic> item) =>
                    _toInt(item['level'], fallback: 1) == activeLevel,
              )
              .toList();

      currentLevelTotalModules.value = currentModules.length;
      currentLevelCompletedModules.value =
          currentModules
              .where(
                (Map<String, dynamic> item) =>
                    _toBool(item['module_completed']),
              )
              .length;

      if (currentModules.isEmpty) {
        currentLevelProgress.value = 0.0;
      } else {
        final double totalProgress = currentModules.fold<double>(
          0.0,
          (double sum, Map<String, dynamic> item) =>
              sum + _normalizeProgress(item['progress']),
        );

        currentLevelProgress.value = (totalProgress / currentModules.length)
            .clamp(0.0, 1.0);
      }
    } catch (e) {
      print('[Dashboard] Error learning summary: $e');
      _resetLearningSummary();
    } finally {
      isLearningSummaryLoading.value = false;
    }
  }

  void _resetLearningSummary() {
    currentLearningLevel.value = 1;
    learningCompletedModules.value = 0;
    learningTotalModules.value = 0;
    currentLevelCompletedModules.value = 0;
    currentLevelTotalModules.value = 0;
    currentLevelProgress.value = 0.0;
  }

  // =====================================================
  // 2. AMBIL MATERI YANG BELUM SELESAI DARI SERVER
  // =====================================================
  Future<void> _recordCurrentFunFactSeen() async {
    final idRaw = currentFact['id'];

    if (idRaw == null || idRaw.isEmpty) return;

    final funfactId = int.tryParse(idRaw);
    if (funfactId == null) return;

    final result = await ApiService.readFunFact(funfactId);
    if (result == null) return;

    final rawBadges = result['new_badges_unlocked'] ?? [];
    final badges = rawBadges.map<String>((e) => e.toString()).toList();

    if (badges.isNotEmpty) {
      for (final badgeName in badges) {
        Get.dialog(
          _DashboardBadgeUnlockedPopup(badgeName: badgeName),
          barrierDismissible: false,
        );
      }

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }
    }
  }

  Future<void> fetchInProgressMaterials() async {
    isLoading.value = true;

    try {
      final List<Map<String, dynamic>> learningModules =
          await ApiService.getLearningModules();

      if (learningModules.isNotEmpty) {
        final List<MaterialItem> tempResult = <MaterialItem>[];

        final List<Map<String, dynamic>> validModules = learningModules
            .where((Map<String, dynamic> item) => !_toBool(item['legacy_mode']))
            .toList();

        // 1. Ambil daftar ID modul yang pernah diakses / dibuka user ini
        final String? currentUserId = GetStorage().read('userId')?.toString();
        final String? currentUserEmail =
            GetStorage().read('userEmail')?.toString();
        final String storageKey =
            (currentUserId != null && currentUserId.isNotEmpty)
                ? 'accessed_module_ids_$currentUserId'
                : (currentUserEmail != null && currentUserEmail.isNotEmpty)
                    ? 'accessed_module_ids_$currentUserEmail'
                    : 'accessed_module_ids';

        final dynamic rawAccessed = GetStorage().read(storageKey);
        final List<int> accessedIds = <int>[];
        if (rawAccessed is List) {
          for (final item in rawAccessed) {
            final int id = _toInt(item);
            if (id > 0 && !accessedIds.contains(id)) {
              accessedIds.add(id);
            }
          }
        }
        final int? singleLast = GetStorage().read<int>(
          (currentUserId != null && currentUserId.isNotEmpty)
              ? 'last_accessed_module_id_$currentUserId'
              : 'last_accessed_module_id',
        );
        if (singleLast != null &&
            singleLast > 0 &&
            !accessedIds.contains(singleLast)) {
          accessedIds.insert(0, singleLast);
        }

        // 2. Ambil modul yang sedang aktif berjalan (0% < progress < 100%)
        final List<Map<String, dynamic>> inProgressList = validModules
            .where((Map<String, dynamic> item) {
              final bool unlocked = _toBool(item['is_unlocked']);
              final bool completed = _toBool(item['module_completed']);
              final double prog = _normalizeProgress(item['progress']);
              return unlocked && !completed && prog > 0.0 && prog < 1.0;
            })
            .toList();

        final Set<int> addedIds = <int>{};

        // A. Masukkan semua modul yang pernah diakses/dibuka user (berurutan)
        for (final int accessedId in accessedIds) {
          final Map<String, dynamic>? mod = validModules.firstWhereOrNull(
            (m) =>
                _toInt(m['id']) == accessedId &&
                _toBool(m['is_unlocked']) &&
                !_toBool(m['module_completed']),
          );

          if (mod != null) {
            final int modId = _toInt(mod['id']);
            if (!addedIds.contains(modId)) {
              addedIds.add(modId);
              final String cat = mod['category']?.toString() ?? 'Sains';
              tempResult.add(
                MaterialItem(
                  id: modId,
                  title: mod['title']?.toString() ?? 'Modul Pembelajaran',
                  category: cat,
                  progress: _normalizeProgress(mod['progress']),
                  iconPath: _categoryIconPath(cat),
                  unitySceneId: mod['unity_scene_id']?.toString(),
                  imageUrl: mod['image_url']?.toString(),
                ),
              );
            }
          }
          if (tempResult.length >= 3) break;
        }

        // B. Masukkan modul-modul lain yang sedang in-progress jika slot masih ada
        if (tempResult.length < 3) {
          for (final Map<String, dynamic> mod in inProgressList) {
            final int modId = _toInt(mod['id']);
            if (!addedIds.contains(modId)) {
              addedIds.add(modId);
              final String cat = mod['category']?.toString() ?? 'Sains';
              tempResult.add(
                MaterialItem(
                  id: modId,
                  title: mod['title']?.toString() ?? 'Modul Pembelajaran',
                  category: cat,
                  progress: _normalizeProgress(mod['progress']),
                  iconPath: _categoryIconPath(cat),
                  unitySceneId: mod['unity_scene_id']?.toString(),
                  imageUrl: mod['image_url']?.toString(),
                ),
              );
            }
            if (tempResult.length >= 3) break;
          }
        }

        // Jika user belum pernah buka modul dan semua progress 0% (seperti akun baru),
        // inProgressMaterials akan kosong sehingga menampilkan Empty State yang bersih & ramah!
        inProgressMaterials.assignAll(tempResult);
        return;
      }

      inProgressMaterials.clear();
    } catch (e) {
      print("[Dashboard] Error fetchInProgress: $e");
      inProgressMaterials.clear();
    } finally {
      isLoading.value = false;
    }
  }

  static String _categoryIconPath(String category) {
    switch (category.toLowerCase()) {
      case 'biologi':
        return 'assets/biology.png';
      case 'fisika':
        return 'assets/physics.png';
      case 'kimia':
        return 'assets/chemistry.png';
      default:
        return 'assets/chemistry.png';
    }
  }

  // =====================================================
  // 3. AMBIL FUN FACTS DARI SERVER
  // =====================================================
  void fetchFunFacts() async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiService.baseUrl}/admin/funfacts'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          allFactsFromDb.assignAll(
            data.map((e) => Map<String, dynamic>.from(e)).toList(),
          );

          randomizeFact();
        } else {
          currentFact.value = {'desc': 'Belum ada fakta unik.'};
        }
      }
    } catch (e) {
      print("Error fakta: $e");
    }
  }

  void randomizeFact() {
    if (allFactsFromDb.isNotEmpty) {
      if (allFactsFromDb.length == 1) {
        currentFact.value = {
          'id': allFactsFromDb[0]['id'].toString(),
          'desc': allFactsFromDb[0]['fact_text'] ?? '',
        };

        _recordCurrentFunFactSeen();
        return;
      }

      int randomIndex;

      do {
        randomIndex = Random().nextInt(allFactsFromDb.length);
      } while (randomIndex == _lastFactIndex);

      _lastFactIndex = randomIndex;

      currentFact.value = {
        'id': allFactsFromDb[randomIndex]['id'].toString(),
        'desc': allFactsFromDb[randomIndex]['fact_text'] ?? '',
      };

      _recordCurrentFunFactSeen();
    }
  }

  // =====================================================
  // 4. UI HELPER
  // =====================================================
  void updateLastLearned(
    String id,
    String title,
    double progress,
    String iconPath,
  ) {
    inProgressMaterials.removeWhere((item) => item.id.toString() == id);

    final double normalizedProgress = _normalizeProgress(progress);

    if (normalizedProgress > 0.0 && normalizedProgress < 1.0) {
      final newItem = MaterialItem(
        id: int.parse(id),
        title: title,
        category: 'Lanjutkan',
        iconPath: iconPath,
        progress: normalizedProgress,
      );

      inProgressMaterials.insert(0, newItem);

      if (inProgressMaterials.length > 3) {
        inProgressMaterials.removeLast();
      }
    }

    inProgressMaterials.refresh();
  }

  void continueMaterial(MaterialItem item) async {
    // Trigger daily quest: lanjutkan belajar
    completeDailyQuest('continue_learning');

    try {
      final learningCtrl = LearningController.ensureRegistered();
      final opened = await learningCtrl.loadModuleDetail(item.id);
      if (opened) {
        await Get.to<void>(() => const LearningModuleDetailView());
        onDashboardVisible();
        return;
      }
    } catch (e) {
      print("[Dashboard] Error continuing learning module: $e");
    }

    await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    );

    onDashboardVisible();
  }

  void navigateToSubject(String subjectName) {
    Get.toNamed(Routes.MATERIAL_LIST, arguments: {'category': subjectName});
  }

  void refreshDashboardData() {
    fetchUserProfile();
    fetchLearningSummary();
    fetchInProgressMaterials();
    fetchDailyQuest();

    if (allFactsFromDb.isNotEmpty) {
      randomizeFact();
    }
  }

  // =====================================================
  // 5. DAILY QUEST BACKEND LOGIC
  // =====================================================

  Future<void> fetchDailyQuest() async {
    isDailyQuestLoading.value = true;

    try {
      final data = await ApiService.getTodayDailyQuest();

      if (data != null) {
        _applyDailyQuestData(data);
      }
    } catch (e) {
      print("[DailyQuest] Error fetchDailyQuest: $e");
    } finally {
      isDailyQuestLoading.value = false;
    }
  }

  void _applyDailyQuestData(Map<String, dynamic> data) {
    dailyRewardTickets.value = _toInt(data['reward_tickets'], fallback: 1);

    isDailyRewardClaimed.value = _toBool(data['is_claimed']);

    final questsRaw = data['quests'];

    if (questsRaw is List) {
      final loadedQuests =
          questsRaw.map((item) {
            final quest = Map<String, dynamic>.from(item);

            // Biar aman buat UI lama kamu
            quest['id'] = quest['id'] ?? quest['quest_key'];
            quest['desc'] = quest['desc'] ?? quest['description'] ?? '';
            quest['progress'] = _toInt(quest['progress']);
            quest['target'] = _toInt(quest['target'], fallback: 1);
            quest['is_completed'] = _toBool(quest['is_completed']);

            return quest;
          }).toList();

      dailyQuests.assignAll(loadedQuests);
    }
  }

  Future<void> completeDailyQuest(String questId, {int amount = 1}) async {
    try {
      final data = await ApiService.updateDailyQuestProgress(
        questId,
        amount: amount,
      );

      if (data != null) {
        _applyDailyQuestData(data);
      }

      print("[DailyQuest] Update progress $questId +$amount");
    } catch (e) {
      print("[DailyQuest] Error completeDailyQuest: $e");
    }
  }

  bool isQuestDone(Map<String, dynamic> quest) {
    if (quest.containsKey('is_completed')) {
      return _toBool(quest['is_completed']);
    }

    final progress = _toInt(quest['progress']);
    final target = _toInt(quest['target'], fallback: 1);

    return progress >= target;
  }

  String questProgressText(Map<String, dynamic> quest) {
    final progress = _toInt(quest['progress']);
    final target = _toInt(quest['target'], fallback: 1);

    return "$progress/$target";
  }

  double questProgressValue(Map<String, dynamic> quest) {
    final progress = _toInt(quest['progress']);
    final target = _toInt(quest['target'], fallback: 1);

    if (target <= 0) return 0.0;

    return (progress / target).clamp(0.0, 1.0);
  }

  bool get isAllDailyQuestDone {
    if (dailyQuests.isEmpty) return false;

    return dailyQuests.every((quest) => isQuestDone(quest));
  }

  bool get canClaimDailyReward {
    return isAllDailyQuestDone && !isDailyRewardClaimed.value;
  }

  Future<void> claimDailyReward() async {
    if (!isAllDailyQuestDone) {
      Get.snackbar(
        "Daily Quest",
        "Selesaikan semua quest dulu ya!",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (isDailyRewardClaimed.value) {
      Get.snackbar(
        "Daily Quest",
        "Reward hari ini sudah diklaim.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final result = await ApiService.claimDailyQuestReward();

      if (result == null) {
        Get.snackbar(
          "Gagal",
          "Reward gagal diklaim. Coba lagi nanti.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (result['daily_quest'] is Map<String, dynamic>) {
        _applyDailyQuestData(Map<String, dynamic>.from(result['daily_quest']));
      }

      if (result['error'] != null) {
        Get.snackbar(
          "Daily Quest",
          result['error'].toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final int rewardTickets = _toInt(result['reward_tickets'], fallback: 1);

      final currentXp = _toInt(result['current_xp'], fallback: userXp.value);

      final level = _toInt(result['level'], fallback: userLevel.value);

      final levelUp = _toBool(result['level_up']);

      userXp.value = currentXp;
      userLevel.value = level;

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }

      Get.snackbar(
        "Daily Quest Selesai!",
        "+$rewardTickets Tiket Gacha berhasil diklaim",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await XpRewardController.ensureRegistered().syncXp(
        currentXp,
        userKey: userEmail.value.isNotEmpty ? userEmail.value : userName.value,
        showUnlockDialog: true,
      );

      if (levelUp) {
        Get.dialog(
          LevelUpPopup(newLevel: _levelTitle(level)),
          barrierDismissible: false,
        );
      }

      print("[DailyQuest] Reward berhasil diklaim +$rewardTickets Tiket Gacha");
    } catch (e) {
      Get.snackbar(
        "Gagal",
        "Reward gagal diklaim. Coba lagi nanti.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print("[DailyQuest] Error claimDailyReward: $e");
    }
  }

  void resetDailyQuestForTesting() {
    // Karena sekarang Daily Quest sudah backend,
    // reset tidak bisa pakai GetStorage lagi.
    // Untuk testing cepat, cukup fetch ulang dari server.
    fetchDailyQuest();

    print("[DailyQuest] Refresh ulang dari backend");
  }
}

class _DashboardBadgeUnlockedPopup extends StatelessWidget {
  final String badgeName;

  const _DashboardBadgeUnlockedPopup({required this.badgeName});

  String _getBadgeImagePath(String name) {
    switch (name) {
      case "Darwin’s Successor":
        return "assets/badge/1.png";
      case "Quantum Overlord":
        return "assets/badge/2.png";
      case "The Modern Alchemist":
        return "assets/badge/3.png";
      case "Virtual Researcher":
        return "assets/badge/4.png";
      case "Mad Scientist":
        return "assets/badge/5.png";
      case "Grand Analyst":
        return "assets/badge/6.png";
      case "Lab Regular":
        return "assets/badge/7.png";
      case "First Spark":
        return "assets/badge/8.png";
      case "Trivia Rover":
        return "assets/badge/9.png";
      case "Night Owl":
        return "assets/badge/10.png";
      case "Flawless Victory":
        return "assets/badge/11.png";
      default:
        return "assets/badge/8.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getBadgeImagePath(badgeName);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // White Body Card
          Container(
            margin: const EdgeInsets.only(top: 52),
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pill Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PENCAPAIAN BARU',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E3A8A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  'Lencana Terbuka!',
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Badge Name Card
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Selamat! Kamu berhasil meraih:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badgeName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () => Get.back(),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                    ),
                    label: Text(
                      'Klaim & Lanjutkan',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating Badge Orb with Golden Aura Glow
          Positioned(
            top: 0,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFFEF3C7),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
