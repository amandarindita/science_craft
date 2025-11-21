import 'package:get/get.dart';
// Impor ProfileController untuk mengambil data XP user
import 'package:science_craft/app/modules/profile/controllers/profile_controller.dart';

// Enum untuk status level, biar di view lebih gampang
enum LevelStatus {
  locked,
  current,
  completed,
}

// Model untuk data satu level
class LevelModel {
  final int levelNumber;
  final String title;
  final String rewardDescription;
  final int xpRequired; // XP minimal untuk mencapai level ini

  LevelModel({
    required this.levelNumber,
    required this.title,
    required this.rewardDescription,
    required this.xpRequired,
  });
}

class LevelRoadmapController extends GetxController {
  // Ambil ProfileController yang sudah di-init di halaman profil
  final ProfileController profileController = Get.find<ProfileController>();

  // Buat variabel userCurrentXp yang "mendengarkan" perubahan dari ProfileController
  RxInt get userCurrentXp => profileController.currentXp;

  // --- Daftar Semua Level di Aplikasi Kamu ---
  // Kamu bisa isi ini dari database nanti, tapi sekarang kita hardcode
  final allLevels = <LevelModel>[
    LevelModel(
        levelNumber: 1,
        title: "Siswa Baru",
        rewardDescription: "Membuka Lab Fisika",
        xpRequired: 0),
    LevelModel(
        levelNumber: 2,
        title: "Peneliti Junior",
        rewardDescription: "Badge 'Rookie'",
        xpRequired: 100),
    LevelModel(
        levelNumber: 3,
        title: "Ahli Biologi",
        rewardDescription: "Avatar Jas Lab",
        xpRequired: 250),
    LevelModel(
        levelNumber: 4,
        title: "Master Kimia",
        rewardDescription: "Eksperimen 'Roket Air' (Unity)",
        xpRequired: 500),
    LevelModel(
        levelNumber: 5,
        title: "Cendekiawan Muda",
        rewardDescription: "Badge 'Si Cepat'",
        xpRequired: 750),
    LevelModel(
        levelNumber: 6,
        title: "Profesor Sains",
        rewardDescription: "Tema Aplikasi 'Galaxy'",
        xpRequired: 1000),
  ].obs;

  // Fungsi untuk menentukan status level berdasarkan XP user
  LevelStatus getLevelStatus(LevelModel level) {
    int currentXp = userCurrentXp.value;

    // Cari tahu XP untuk level BERIKUTNYA
    int nextLevelXp = 999999; // Default untuk level terakhir
    try {
      final nextLevel = allLevels
          .firstWhere((l) => l.levelNumber == level.levelNumber + 1);
      nextLevelXp = nextLevel.xpRequired;
    } catch (e) {
      // Ini adalah level terakhir, tidak ada level selanjutnya
    }

    if (currentXp >= nextLevelXp) {
      // Jika XP user sudah melebihi XP level berikutnya
      return LevelStatus.completed;
    } else if (currentXp >= level.xpRequired && currentXp < nextLevelXp) {
      // Jika XP user ada di rentang level ini
      return LevelStatus.current;
    } else {
      // Jika XP user belum cukup
      return LevelStatus.locked;
    }
  }
}