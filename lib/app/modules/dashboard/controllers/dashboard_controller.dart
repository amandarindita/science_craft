import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/api_service.dart';
import '../../../data/auth_service.dart';
import '../../../models/material_model.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardController extends GetxController with WidgetsBindingObserver {
  // =====================================================
  // DATA USER & GAMIFICATION
  // =====================================================
  final userName = 'Sobat Sains'.obs;
  final userStreak = 0.obs;
  final userLevel = 1.obs;
  final userXp = 0.obs;

  // =====================================================
  // DATA "LANJUTKAN BELAJAR"
  // =====================================================
  final inProgressMaterials = <MaterialItem>[].obs;
  final isLoading = true.obs;

  // =====================================================
  // BAGIAN FAKTA SAINS
  // =====================================================
  var currentFact = <String, String>{}.obs;
  var allFactsFromDb = <Map<String, dynamic>>[].obs;
  int _lastFactIndex = -1;

  // =====================================================
  // BAGIAN DAILY QUEST - BACKEND VERSION
  // =====================================================
  final dailyQuests = <Map<String, dynamic>>[].obs;
  final isDailyRewardClaimed = false.obs;
  final dailyRewardXp = 50.obs;
  final isDailyQuestLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);

    fetchUserProfile();
    fetchInProgressMaterials();
    fetchFunFacts();

    // Ambil daily quest dari backend
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
      randomizeFact();
      fetchUserProfile();

      // Kalau app dibuka lagi, ambil ulang Daily Quest dari backend
      fetchDailyQuest();
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
    if (value is String) return value.toLowerCase() == 'true';
    return false;
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
        userName.value = userData['username'] ?? 'Sobat Sains';

        // Backend kamu pakai key: streak, total_xp, level
        userStreak.value = _toInt(
          userData['streak'] ?? userData['streak_count'],
        );

        userLevel.value = _toInt(
          userData['level'],
          fallback: 1,
        );

        userXp.value = _toInt(
          userData['total_xp'] ?? userData['xp'],
        );
      }
    } catch (e) {
      print("Error fetch profile: $e");
    }
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
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/materials'),
        headers: {
          'Authorization': 'Bearer ${Get.find<AuthService>().token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        Map<dynamic, double> serverProgressMap = {};

        try {
          serverProgressMap = await ApiService.getAllProgress();
        } catch (_) {}

        List<MaterialItem> tempResult = [];

        for (var m in data) {
          double progress = 0.0;

          if (serverProgressMap.containsKey(m['id'])) {
            progress = serverProgressMap[m['id']]!;
          } else if (serverProgressMap.containsKey(m['id'].toString())) {
            progress = serverProgressMap[m['id'].toString()]!;
          }

          if (progress > 0.0 && progress < 1.0) {
            tempResult.add(
              MaterialItem.fromMap({
                ...m,
                'progress': progress,
              }),
            );
          }
        }

        if (tempResult.length > 3) {
          tempResult = tempResult.sublist(0, 3);
        }

        inProgressMaterials.assignAll(tempResult);
      }
    } catch (e) {
      print("[Dashboard] Error fetchInProgress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // 3. AMBIL FUN FACTS DARI SERVER
  // =====================================================
  void fetchFunFacts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/funfacts'),
        headers: {
          'Authorization': 'Bearer ${Get.find<AuthService>().token}',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          allFactsFromDb.assignAll(
            data.map((e) => Map<String, dynamic>.from(e)).toList(),
          );

          randomizeFact();
        } else {
          currentFact.value = {
            'desc': 'Belum ada fakta unik.',
          };
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
    inProgressMaterials.removeWhere(
      (item) => item.id.toString() == id,
    );

    if (progress < 0.99 && progress > 0.0) {
      final newItem = MaterialItem(
        id: int.parse(id),
        title: title,
        category: 'Lanjutkan',
        iconPath: iconPath,
        progress: progress,
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

    await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    );

    fetchUserProfile();
    fetchInProgressMaterials();
    fetchDailyQuest();
  }

  void navigateToSubject(String subjectName) {
    Get.toNamed(
      Routes.MATERIAL_LIST,
      arguments: {
        'category': subjectName,
      },
    );
  }

  void refreshDashboardData() {
    fetchUserProfile();
    fetchInProgressMaterials();
    randomizeFact();
    fetchDailyQuest();
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
    dailyRewardXp.value = _toInt(
      data['reward_xp'],
      fallback: 50,
    );

    isDailyRewardClaimed.value = _toBool(data['is_claimed']);

    final questsRaw = data['quests'];

    if (questsRaw is List) {
      final loadedQuests = questsRaw.map((item) {
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
        _applyDailyQuestData(
          Map<String, dynamic>.from(result['daily_quest']),
        );
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

      final rewardXp = _toInt(
        result['reward_xp'],
        fallback: dailyRewardXp.value,
      );

      final currentXp = _toInt(
        result['current_xp'],
        fallback: userXp.value,
      );

      final level = _toInt(
        result['level'],
        fallback: userLevel.value,
      );

      final levelUp = _toBool(result['level_up']);

      userXp.value = currentXp;
      userLevel.value = level;

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }

      Get.snackbar(
        "Daily Quest Selesai!",
        "+$rewardXp XP berhasil diklaim.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (levelUp) {
        Get.dialog(
          LevelUpPopup(newLevel: _levelTitle(level)),
          barrierDismissible: false,
        );
      }

      print("[DailyQuest] Reward berhasil diklaim +$rewardXp XP");
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

  const _DashboardBadgeUnlockedPopup({
    Key? key,
    required this.badgeName,
  }) : super(key: key);

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
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.only(
              top: 80,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "PENCAPAIAN BARU!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6C63FF),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Selamat! Kamu berhasil membuka lencana:\n\n$badgeName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "MANTAP!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}