import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:science_craft/app/modules/notification/notification_helper.dart';
import '../../../data/db/database_helper.dart';
import '../../../models/material_model.dart'; 
import '../../../routes/app_pages.dart';
import '../../../data/api_client.dart';
import '../../../data/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart'; 

class MaterialDetailController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final currentProgress = 0.0.obs;
  late double initialProgress;

  final Rx<MaterialContent?> materialContent = Rx<MaterialContent?>(null);
  late String materialId;

  final ProfileController profileController = Get.find<ProfileController>();

  bool _isSaving = false;
  bool _hasProgressChanged = false;
  bool _hasRecordedReadMaterialQuest = false;

  @override
  void onInit() {
    super.onInit();
    materialId = Get.parameters['id'] ?? '1';
    initialProgress = (Get.arguments is double) ? Get.arguments as double : 0.0;
    
    // Modal Awal
    if (initialProgress <= 0.0) {
      currentProgress.value = 0.05; 
      _hasProgressChanged = true;
    } else {
      currentProgress.value = initialProgress;
    }

    fetchMaterialContent(materialId);

    ever(currentProgress, (double newProgress) {
      if (newProgress > initialProgress && !_hasProgressChanged) {
        _hasProgressChanged = true;
      }
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;

    // TRIK 1: Kalau materi pendek banget (nggak bisa discroll)
    if (maxScroll <= 0) {
      currentProgress.value = 1.0;
      _hasProgressChanged = true;
      return;
    }

    // TRIK 2: Toleransi Scroll (Kalau kurang 50 pixel nyentuh bawah, anggap aja 100% tamat)
    if (currentScroll >= (maxScroll - 50)) {
       currentProgress.value = 1.0;
       _hasProgressChanged = true;
       return;
    }

    double progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    if (progress > currentProgress.value) {
      currentProgress.value = progress;
      _hasProgressChanged = true; // Nyalakan saklar kalau progress nambah
    }
  }
  Future<void> _recordReadMaterialQuest() async {
    if (_hasRecordedReadMaterialQuest) return;

    _hasRecordedReadMaterialQuest = true;

    await ApiService.updateDailyQuestProgress('read_material');

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().fetchDailyQuest();
    }
  }

 Future<void> fetchMaterialContent(String id) async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiService.baseUrl}/admin/material/$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        data['progress'] = initialProgress; 
        materialContent.value = MaterialContent.fromMap(data);
        await _recordReadMaterialQuest();

        // TRIK 3: Pengecekan otomatis setelah materi selesai di-load di layar
        Future.delayed(const Duration(milliseconds: 500), () {
          if (scrollController.hasClients && scrollController.position.maxScrollExtent <= 0) {
            currentProgress.value = 1.0;
            _hasProgressChanged = true;
          }
        });

      } else {
        _loadDummyData(id, "Materi tidak ditemukan di server");
      }
    } catch (e) {
      _loadDummyData(id, "Kesalahan koneksi ke server");
    }
  }

  void _loadDummyData(String id, String message) {
    materialContent.value = MaterialContent(
        id: int.parse(id), 
        title: "Error Memuat Data",
        introduction: message,
        theorySections: [],
        progress: 0.0,
        iconPath: 'assets/chemistry.png');
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

  void goToQuiz() async {
    bool wasAlreadyCompleted = (initialProgress >= 0.99);

    if (!wasAlreadyCompleted) {
      currentProgress.value = 1.0;
      _hasProgressChanged = true;
    }

    await _saveData(forceSave: true);

    if (!wasAlreadyCompleted) {
      Get.snackbar(
        "Materi Selesai!",
        "Progress materi berhasil disimpan dan XP diperbarui.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }

    Get.toNamed(Routes.QUIZ, arguments: materialId);
  }
Future<void> _saveData({bool forceSave = false}) async {
    if (_isSaving) return;
    if (!_hasProgressChanged && !forceSave) return; 
    
    _isSaving = true; 

    try {
      double progressToSave = currentProgress.value;
      final title = materialContent.value?.title ?? 'Judul Tidak Ditemukan';
      final iconPath = materialContent.value?.iconPath ?? 'assets/default_icon.png';
      final db = DatabaseHelper.instance;

      await db.saveSetting('lastLearnedId', materialId);
      await db.saveSetting('lastLearnedTitle', title);
      await db.saveSetting('lastLearnedProgress', progressToSave.toString());
      await db.saveSetting('lastLearnedIconPath', iconPath);

      if (Get.isRegistered<DashboardController>()) {
        final dashController = Get.find<DashboardController>();
        dashController.updateLastLearned(materialId, title, progressToSave, iconPath);
      }
      
      await db.updateMaterialProgress(int.parse(materialId), progressToSave);
      
      // 🌟 PERBAIKAN UTAMA: Tembak API pake format List<String> yang baru! 🌟
      final result = await ApiService.syncProgressDetail(
        int.parse(materialId),
        progressToSave,
      );

      final List<String> pialaBaru = ((result?['new_badges_unlocked'] ?? []) as List)
          .map((e) => e.toString())
          .toList();

      final xpAdded = int.tryParse(
        (result?['xp_added'] ?? 0).toString(),
      ) ?? 0;

      final levelUp = result?['level_up'] == true ||
          result?['level_up'].toString() == 'true';

      final level = int.tryParse(
        (result?['level'] ?? 1).toString(),
      ) ?? 1;
      print("Data 100% masuk ke Flask cok! Piala didapat: $pialaBaru");
     
      // 🌟 REFRESH PROFIL BIAR API JADI IJO HABIS BACA MATERI! 🌟
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }
      if (xpAdded > 0) {
        await ApiService.updateDailyQuestProgress(
          'collect_xp',
          amount: xpAdded,
        );

        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDailyQuest();
        }
      }

      if (levelUp) {
        Get.dialog(
          LevelUpPopup(newLevel: _levelTitle(level)),
          barrierDismissible: false,
        );
      }

      // 🚀 JEDARRR! Kalau baca materi ini bikin dapet piala, keluarin pop-up!
      if (pialaBaru.isNotEmpty) {
        for (var badgeName in pialaBaru) {
          
          // Push Notif Lokal
          NotificationHelper().showInstantNotification(
            id: badgeName.hashCode, 
            title: "Badge Baru Terbuka! 🎉",
            body: "Selamat! Kamu berhasil mendapatkan pencapaian '$badgeName'.",
          );
          
          // Pop-up UI yang bersih (Sesuai artstyle lu)
          Get.dialog(
            BadgeUnlockedPopup(badgeName: badgeName),
            barrierDismissible: false,
          );
        }
      }
      
      initialProgress = progressToSave;
      _hasProgressChanged = false; 

    } catch (e) {
      print("Error saat _saveData: $e");
    } finally {
      _isSaving = false; 
    }
  }
  void saveAndReturn() async {
    bool didChange = _hasProgressChanged;
    // Tungguin proses save beneran kelar sebelum nutup halaman
    await _saveData(); 
    Get.back(result: didChange); 
  }

  @override
  void onClose() {
    _saveData();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}
// =========================================================
// 🏆 WIDGET CUSTOM: POPUP LOGO BADGE DENGAN EFEK GLOW (NO LOTTIE)
// =========================================================
class BadgeUnlockedPopup extends StatelessWidget {
  final String badgeName;
  const BadgeUnlockedPopup({Key? key, required this.badgeName}) : super(key: key);

  // Helper pintar untuk mencocokkan nama badge dengan file gambar lu
  String _getBadgeImagePath(String name) {
    switch (name) {
      case "Darwin’s Successor": return "assets/badge/1.png";
      case "Quantum Overlord": return "assets/badge/2.png";
      case "The Modern Alchemist": return "assets/badge/3.png";
      case "Virtual Researcher": return "assets/badge/4.png";
      case "Mad Scientist": return "assets/badge/5.png";
      case "Grand Analyst": return "assets/badge/6.png";
      case "Lab Regular": return "assets/badge/7.png";
      case "First Spark": return "assets/badge/8.png";
      case "Trivia Rover": return "assets/badge/9.png";
      case "Night Owl": return "assets/badge/10.png";
      case "Flawless Victory": return "assets/badge/11.png";
      default: return "assets/badge/8.png"; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath = _getBadgeImagePath(badgeName);
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4.5),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
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