import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/auth_service.dart';
import '../../../data/api_service.dart';

// =========================================================
// 📑 MODEL DATA SINKRON DENGAN BACKEND
// =========================================================

class BadgeItem {
  final String name;
  final String description;
  final String imagePath;
  bool isOwned;

  BadgeItem({
    required this.name,
    required this.description,
    required this.imagePath,
    this.isOwned = false,
  });
}

class StreakDay {
  final String label;    // S, S, R, K...
  final bool isCompleted; 
  final bool isToday;    

  StreakDay({
    required this.label,
    required this.isCompleted, 
    required this.isToday
  });
}

// =========================================================
// 🧠 GETX CONTROLLER (OTAK PROFIL)
// =========================================================
// --- DATA STATISTIK ---
 
class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  // --- DATA PROFIL ---
  final userName = 'Loading...'.obs;
  final userLevel = 'Level 1: Siswa Baru'.obs;
  final avatarPath = 'assets/amanda.png'.obs;
  final isLoading = false.obs;
  final userEmail = ''.obs;
  final hasPassword = true.obs;

  // --- DATA STATISTIK ---
  final experimentsCompleted = 0.obs;
  final dailyStreak = 0.obs; 
  final dailyStatus = 'login'.obs;

  // --- DATA MINGGUAN (UI STREAK DUOLINGO) ---
  final weeklyStreak = <StreakDay>[].obs; 

  // --- 🏆 KATALOG PUSAT 10 BADGE SKRIPSI LU 🏆 ---
  // Kita daftarkan semua secara default (isOwned = false) biar yang belum didapet keliatan abu-abu/terkunci
// --- 🏆 KATALOG PUSAT 11 BADGE SKRIPSI LU (TERBARU) 🏆 ---
  final badges = <BadgeItem>[
    BadgeItem(name: "Darwin’s Successor", description: "Berhasil menyelesaikan seluruh modul teori dan eksperimen Biologi.", imagePath: "assets/badge/1.png"),
    BadgeItem(name: "Quantum Overlord", description: "Sukses menaklukkan seluruh tantangan hukum alam dan mekanika Fisika.", imagePath: "assets/badge/2.png"),
    BadgeItem(name: "The Modern Alchemist", description: "Berhasil memahami seluruh reaksi zat dan struktur senyawa Kimia.", imagePath: "assets/badge/3.png"),
    BadgeItem(name: "Virtual Researcher", description: "Pertama kali berhasil melakukan simulasi laboratorium eksperimen 2D.", imagePath: "assets/badge/4.png"),
    BadgeItem(name: "Mad Scientist", description: "Berhasil menyelesaikan 3 atau lebih simulasi eksperimen di laboratorium virtual.", imagePath: "assets/badge/5.png"),
    BadgeItem(name: "Grand Analyst", description: "Berhasil menjawab soal studi kasus kuis dengan nilai sempurna (100) pada percobaan pertama.", imagePath: "assets/badge/6.png"),
    BadgeItem(name: "Lab Regular", description: "Mempertahankan streak belajar selama 7 hari berturut-turut.", imagePath: "assets/badge/7.png"),
    BadgeItem(name: "First Spark", description: "Memulai perjalanan sains dengan menyelesaikan 1 materi pertamamu.", imagePath: "assets/badge/8.png"),
    BadgeItem(name: "Trivia Rover", description: "Menemukan dan membaca 5 fakta unik sains (FunFact) di halaman utama.", imagePath: "assets/badge/9.png"),
    BadgeItem(name: "Night Owl", description: "Membaca materi atau menyelesaikan kuis di atas jam 10 malam.", imagePath: "assets/badge/10.png"),
    BadgeItem(name: "Flawless Victory", description: "Mendapatkan nilai sempurna (100) di 3 kuis yang berbeda.", imagePath: "assets/badge/11.png"),
  ].obs;

  // --- DATA HISTORY ---
  final lastLearnedTitle = 'Belum ada aktivitas'.obs;
  final lastLearnedProgress = 0.0.obs;
  final lastLearnedIcon = ''.obs; 

  // --- DATA XP & LEVEL ---
  final currentXp = 0.obs;
  final nextLevelXp = 200.obs; // Mengikuti standarisasi kelipatan 200 XP server

  @override
  void onInit() {
    super.onInit();
    _generateWeeklyStreak(0);
    fetchUserProfile(); // Sikat panggil API pas halaman dibuka!
  }

  // --- 🔄 FUNGSI UTAMA: TARIK DATA DARI SERVER FLASK ---
  void fetchUserProfile() async {
    try {
      isLoading.value = true;
      final userData = await ApiService.getUserData();
      
      if (userData != null) {
        userName.value = userData['username'] ?? 'User';
        avatarPath.value = userData['avatar'] ?? 'assets/amanda.png';
        userEmail.value = userData['email'] ?? '';
        hasPassword.value = userData['has_password'] ?? true;
        // 1. Sinkronisasi Data XP & Hitung Level Berdasarkan Aturan Kelipatan 200 XP
        int xpFromServer = userData['total_xp'] ?? 0;
        currentXp.value = xpFromServer;
        _calculateLevel(xpFromServer);
        
        // 2. Sinkronisasi Data Streak
        int streakCount = userData['streak'] ?? 0;
        dailyStreak.value = streakCount;
        _generateWeeklyStreak(streakCount);

        String statusFromServer = userData['daily_status'] ?? 'login';
        dailyStatus.value = statusFromServer;
        
        // 3. 🎯 SINKRONISASI BADGE DINAMIS DARI SERVER FLASK 🎯
        List<dynamic> ownedBadgesFromServer = userData['badges'] ?? [];
        
        // Ambil semua daftar nama piala yang dikirim oleh Flask
        List<String> ownedNames = ownedBadgesFromServer
            .map((b) => b['name'].toString())
            .toList();

        // COCOKKAN: Jika nama piala ada di daftar server, set isOwned = true!
        for (var b in badges) {
          if (ownedNames.contains(b.name)) {
            b.isOwned = true;
          } else {
            b.isOwned = false; // Reset jaga-jaga
          }
        }
        badges.refresh(); // Paksa UI GetX buat nge-render ulang piala terbaru
      }
    } catch (e) {
      print("[ProfileController] Gagal sinkronisasi data: $e");
      if (userName.value == 'Loading...') {
        userName.value = 'Offline User';
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- 🦉 LOGIKA HITUNG LEVEL (SINKRON SAMA RUMUS FLASK KELIPATAN 200 XP) ---
  void _calculateLevel(int xp) {
    // Rumus linear matematika backend: level = (xp // 200) + 1
    int lvl = (xp ~/ 200) + 1; 
    nextLevelXp.value = lvl * 200; // Batas menuju level berikutnya

    // Kasih gelar nama keren berdasarkan levelnya biar dosen lu takjub wkwk
    if (lvl == 1) {
      userLevel.value = "Level 1: Siswa Baru 🔬";
    } else if (lvl == 2) {
      userLevel.value = "Level 2: Peneliti Junior 🧪";
    } else if (lvl == 3) {
      userLevel.value = "Level 3: Asisten Lab 🧬";
    } else if (lvl == 4) {
      userLevel.value = "Level 4: Ahli Sains 🌌";
    } else {
      userLevel.value = "Level $lvl: Professor Madya 🧠";
    }
  }

  // --- 🆙 LOGIKA ADD XP + TRIGGER POPUP ANIMASI LEVEL UP ---
  void addXp(int amount) async {
    String previousLevel = userLevel.value;

    currentXp.value += amount;
    _calculateLevel(currentXp.value);

    // Jika string tingkat levelnya berubah, jebret munculin animasi confetti Lottie!
    if (userLevel.value != previousLevel) {
       _showLevelUpDialog(userLevel.value);
    }

    // Kirim data ke server Flask di latar belakang biar gak bikin UI lag
    await ApiService.addXp(amount);
  }

  void _showLevelUpDialog(String newLevel) {
    Get.dialog(
      LevelUpPopup(newLevel: newLevel),
      barrierDismissible: false,
    );
  }

  // --- LOGIKA GENERATE HARI MINGGU INI (STREAK) ---
  void _generateWeeklyStreak(int streakCount) {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<StreakDay> tempDays = [];
    List<String> dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    for (int i = 0; i < 7; i++) {
      DateTime checkDate = monday.add(Duration(days: i));
      
      bool isToday = (checkDate.year == now.year && 
                      checkDate.month == now.month && 
                      checkDate.day == now.day);

      bool isCompleted = false;
      
      if (checkDate.isBefore(now) || isToday) {
          int diffDays = DateTime(now.year, now.month, now.day)
              .difference(DateTime(checkDate.year, checkDate.month, checkDate.day))
              .inDays;
          
          if (diffDays < streakCount) {
            isCompleted = true;
          }
      }

      tempDays.add(StreakDay(
        label: dayLabels[i],
        isCompleted: isCompleted,
        isToday: isToday
      ));
    }
    weeklyStreak.assignAll(tempDays);
  }

  // Navigasi Eksternal
  void viewAllHistory() => Get.snackbar('Info', 'Coming soon');
  void goToNotifications() => Get.toNamed(Routes.NOTIFICATION);
  void goToAboutApp() => Get.toNamed(Routes.ABOUT);
  void goToFaq() => Get.toNamed(Routes.FAQ);
  void gotoEditProfile() => Get.toNamed(Routes.EDITPROFILE);
  void goToLevelBenefits() => Get.toNamed(Routes.ROADMAP); 
  void logout() => authService.logout();

  // --- ❌ LOGIKA HAPUS AKUN PERMANEN ---
  void deleteAccount() {
    Get.defaultDialog(
      title: "HAPUS AKUN?",
      titleStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      middleText: "PERINGATAN: Semua progress, level, streak, dan badge akan hilang PERMANEN. \n\nTindakan ini tidak bisa dibatalkan.",
      textConfirm: "Ya, Hapus Permanen",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black,
      onConfirm: () async {
        bool success = await ApiService.deleteAccount();
        Get.back(); 
        if (success) {
           authService.logout(); 
           Get.snackbar("Akun Dihapus", "Sayonara! Akunmu sudah dihapus.", 
             backgroundColor: Colors.grey, colorText: Colors.white);
        } else {
           Get.snackbar("Gagal", "Gagal menghapus akun. Coba lagi nanti.",
             backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    );
  }
}

// =========================================================
// 🏆 WIDGET CUSTOM: POPUP ANIMASI LEVEL UP LOTTIE
// =========================================================
class LevelUpPopup extends StatefulWidget {
  final String newLevel;
  const LevelUpPopup({Key? key, required this.newLevel}) : super(key: key);

  @override
  State<LevelUpPopup> createState() => _LevelUpPopupState();
}

class _LevelUpPopupState extends State<LevelUpPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.only(top: 70, left: 20, right: 20, bottom: 20),
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
                  "LEVEL UP!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6C63FF),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "Selamat! Kamu sekarang berada di\n${widget.newLevel}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 5,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("KEREN!", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)
                ],
              ),
            ),
          ),
          Positioned(
            top: -10,
            child: Lottie.asset(
              'assets/animation/Trophy.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              repeat: false,
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..forward(); 
              },
            ),
          ),
        ],
      ),
    );
  }
}