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
    BadgeItem(id: 'record', name: "New Record", imagePath: "assets/badge/1.png"),
    BadgeItem(id: 'first', name: "First Workout", imagePath: "assets/badge/2.png"),
    BadgeItem(id: '7day', name: "7 Day Streak", imagePath: "assets/badge/3.png"),
    BadgeItem(id: '30day', name: "30 Day Streak", imagePath: "assets/badge/4.png"),
    BadgeItem(id: '100', name: "100 Workout", imagePath: "assets/badge/5.png"),
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
    
    // 1. Isi data kosong dulu biar UI langsung muncul
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
        avatarPath.value = userData['avatar'] ?? 'assets/aira.png';
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

  // --- LOGIKA GENERATE HARI MINGGU INI ---
  void _generateWeeklyStreak(int streakCount) {
    DateTime now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    List<StreakDay> tempDays = [];
    List<String> dayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M']; // Senin - Minggu

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

  // --- [PERBAIKAN] LOGIKA ADD XP BIAR POPUP GAK MUNCUL 2X ---
  void addXp(int amount) async {
    // 1. Simpan level LAMA sebelum ditambah XP
    String previousLevel = userLevel.value;

    // 2. Tambah XP
    currentXp.value += amount;

    // 3. Hitung level BARU berdasarkan XP baru
    _calculateLevel(currentXp.value);

    // 4. BANDINGKAN: Apakah level berubah?
    // Jika string level berubah, berarti User naik level!
    if (userLevel.value != previousLevel) {
       _showLevelUpDialog(userLevel.value);
    }

    // 5. Simpan ke server (Background process)
    await ApiService.addXp(amount);
  }

  // --- [PERBAIKAN] MENAMPILKAN POPUP ---
  void _showLevelUpDialog(String newLevel) {
    Get.dialog(
      LevelUpPopup(newLevel: newLevel), // Menggunakan Widget Custom di bawah
      barrierDismissible: false,
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

// =========================================================
// WIDGET KHUSUS POPUP LEVEL UP (Simpan di file ini juga boleh)
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
    // Inisialisasi Controller Animasi agar bisa dikontrol (Play/Stop)
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
      backgroundColor: Colors.transparent, // Transparan agar bisa custom bentuk
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none, // PENTING: Biar animasi bisa "keluar" dari kotak
        alignment: Alignment.topCenter,
        children: [
          // --- LAYER 1: KARTU PUTIH ---
          Container(
            margin: const EdgeInsets.only(top: 60), // Ruang untuk Trophy
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
                    color: Color(0xFF6C63FF), // Warna ungu modern
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Dekorasi garis
                Container(
                  width: 50, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  "Selamat! Kamu sekarang adalah\n${widget.newLevel}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.4),
                ),
                const SizedBox(height: 25),

                // Tombol
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

          // --- LAYER 2: GLOW BACKGROUND ---
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

          // --- LAYER 3: LOTTIE ANIMATION ---
          Positioned(
            top: -10,
            child: Lottie.asset(
              'assets/animation/Trophy.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
              repeat: false, // Main sekali saja
              controller: _controller, // Pasang controller
              onLoaded: (composition) {
                // Saat file Lottie selesai dimuat, paksa main (PLAY)
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