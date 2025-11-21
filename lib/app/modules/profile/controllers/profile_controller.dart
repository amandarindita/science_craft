import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/auth_service.dart';
import '../../../data/api_service.dart';

// --- MODEL TAMBAHAN ---

// 1. Model Badge
class BadgeItem {
  final String id;
  final String name;
  final String imagePath;
  bool isOwned;

  BadgeItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isOwned = false,
  });
}

// 2. Model Streak Day (Untuk UI Duolingo)
class StreakDay {
  final String label;    // S, S, R, K...
  final bool isCompleted; // Apakah apinya nyala?
  final bool isToday;     // Apakah ini hari ini?

  StreakDay({
    required this.label,
    required this.isCompleted, 
    required this.isToday
  });
}

class ProfileController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  // --- DATA PROFIL ---
  final userName = 'Loading...'.obs;
  final userLevel = '...'.obs;
  final avatarPath = 'assets/amanda.png'.obs;

  // --- DATA STATISTIK ---
  final experimentsCompleted = 0.obs;
  final dailyStreak = 0.obs; // Default 0

  // --- DATA MINGGUAN (UNTUK UI STREAK) ---
  final weeklyStreak = <StreakDay>[].obs; 

  // --- DATA BADGE ---
  final badges = <BadgeItem>[
    BadgeItem(id: 'record', name: "New Record", imagePath: "assets/badge_record.png"),
    BadgeItem(id: 'first', name: "First Workout", imagePath: "assets/badge_first.png"),
    BadgeItem(id: '7day', name: "7 Day Streak", imagePath: "assets/badge_7day.png"),
    BadgeItem(id: '30day', name: "30 Day Streak", imagePath: "assets/badge_30day.png"),
    BadgeItem(id: '100', name: "100 Workout", imagePath: "assets/badge_100.png"),
  ].obs;

  // --- DATA HISTORY ---
  final lastLearnedTitle = 'Belum ada aktivitas'.obs;
  final lastLearnedProgress = 0.0.obs;
  final lastLearnedIcon = ''.obs; // Tambahan icon path

  // --- DATA XP & LEVEL ---
  final currentXp = 0.obs;
  final nextLevelXp = 100.obs; 

  @override
  void onInit() {
    super.onInit();
    
    // --- PERBAIKAN UTAMA DISINI ---
    // 1. Isi data kosong dulu biar UI langsung muncul (gak loading terus)
    _generateWeeklyStreak(0);
    
    // 2. Baru ambil data asli dari server
    fetchUserProfile();
  }

  // --- FUNGSI: AMBIL DATA USER ---
  void fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      
      if (userData != null) {
        userName.value = userData['username'] ?? 'User';
        int xpFromServer = userData['total_xp'] ?? 0;
        
        // 1. Set XP & Level
        currentXp.value = xpFromServer;
        _calculateLevel(xpFromServer);
        
        // 2. Set Streak (Integer)
        int streakCount = userData['streak'] ?? 0;
        dailyStreak.value = streakCount;

        // 3. UPDATE VISUAL MINGGUAN (Pakai data asli)
        _generateWeeklyStreak(streakCount);
        
        // 4. Update Badge
        List<dynamic> ownedBadgeCodes = userData['badges'] ?? [];
        for (var b in badges) b.isOwned = false;
        for (var b in badges) {
          if (ownedBadgeCodes.contains(b.id)) {
            b.isOwned = true;
          }
        }
        badges.refresh();
      }
    } catch (e) {
      print("[Profile] Error: $e");
      // Fallback biar gak 'Loading...' selamanya kalau internet mati
      if (userName.value == 'Loading...') {
         userName.value = 'Offline User';
      }
    }
  }

  // --- LOGIKA PINTAR: GENERATE HARI MINGGU INI ---
  void _generateWeeklyStreak(int streakCount) {
    DateTime now = DateTime.now();
    
    // 1. Cari hari Senin minggu ini
    // (now.weekday: Senin=1 ... Minggu=7)
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<StreakDay> tempDays = [];
    List<String> dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M']; // Senin - Minggu

    for (int i = 0; i < 7; i++) {
      // Tanggal yang sedang dicek (Senin + i hari)
      DateTime checkDate = monday.add(Duration(days: i));
      
      // Cek apakah ini hari ini? (Abaikan jam/menit)
      bool isToday = (checkDate.year == now.year && 
                      checkDate.month == now.month && 
                      checkDate.day == now.day);

      // Cek apakah "Selesai" (Completed)?
      bool isCompleted = false;
      
      // Logic Simulasi Sederhana:
      // Jika hari ini atau sebelumnya, dan masuk dalam range streak, anggap selesai.
      if (checkDate.isBefore(now) || isToday) {
          int diffDays = DateTime(now.year, now.month, now.day)
              .difference(DateTime(checkDate.year, checkDate.month, checkDate.day))
              .inDays;
          
          // Jika selisih hari lebih kecil dari jumlah streak, berarti masuk streak!
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

  // Helper: Hitung level
  void _calculateLevel(int xp) {
    if (xp < 100) {
      userLevel.value = "Level 1: Siswa Baru";
      nextLevelXp.value = 100;
    } else if (xp < 250) {
      userLevel.value = "Level 2: Peneliti Junior";
      nextLevelXp.value = 250;
    } else if (xp < 500) {
      userLevel.value = "Level 3: Asisten Lab";
      nextLevelXp.value = 500;
    } else if (xp < 1000) {
      userLevel.value = "Level 4: Ahli Sains";
      nextLevelXp.value = 1000;
    } else {
      userLevel.value = "Level 5: Professor";
      nextLevelXp.value = 2000; 
    }
  }

  // --- SISA FUNGSI LAINNYA SAMA ---
  void addXp(int amount) async {
    currentXp.value += amount;
    if (nextLevelXp.value > 0 && currentXp.value >= nextLevelXp.value) {
       _showLevelUpDialog("Level Up!", "Selamat!");
    }
    _calculateLevel(currentXp.value);
    await ApiService.addXp(amount);
  }

  void _showLevelUpDialog(String newLevel, String reward) {
    Get.dialog(
      Stack(
        alignment: Alignment.center,
        children: [
          Lottie.asset('assets/animations/confetti.json', repeat: false),
          AlertDialog(
            title: const Text('NAIK LEVEL!'),
            content: Text('Selamat datang di $newLevel'),
            actions: [TextButton(onPressed: ()=>Get.back(), child: const Text('OK'))]
          )
        ]
      )
    );
  }

  // Navigasi Dummy
  void viewAllHistory() => Get.snackbar('Info', 'Coming soon');
  void goToNotifications() => Get.toNamed(Routes.NOTIFICATION);
  void goToAboutApp() => Get.toNamed(Routes.ABOUT);
  void goToFaq() => Get.toNamed(Routes.FAQ);
  void gotoEditProfile() => Get.toNamed(Routes.EDITPROFILE);
  void goToLevelBenefits() => Get.toNamed(Routes.ROADMAP); 
  void logout() => authService.logout();
}