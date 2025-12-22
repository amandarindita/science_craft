import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math'; 
import '../../../routes/app_pages.dart';
import '../../../data/db/database_helper.dart';
import '../../../data/api_service.dart';
import '../../../models/material_model.dart'; 

class DashboardController extends GetxController {
  // --- DATA USER ---
  final userName = 'Sobat Sains'.obs;
  
  // STREAK KITA UBAH JADI LOKAL BIAR STABIL & PASTI JALAN
  final userStreak = 0.obs;

  // --- DATA "LANJUTKAN BELAJAR" ---
  final inProgressMaterials = <MaterialItem>[].obs;
  final isLoading = true.obs;
  final box = GetStorage();

  // --- BAGIAN FAKTA SAINS ---
  var currentFact = <String, String>{}.obs;
  var allFactsFromDb = <Map<String, dynamic>>[].obs;
  // Variabel untuk mencegah fakta muncul 2x berturut-turut
  int _lastFactIndex = -1;

  @override
  void onInit() {
    super.onInit();
    
    // 1. Cek Streak (Logika Lokal - Pasti Jalan)
    checkLocalStreak();

    // 2. Ambil Nama User (Dari Backend/Server)
    fetchUserProfile();

    // 3. Load Materi & Fakta
    fetchInProgressMaterials();
    fetchFunFacts();
  }

  // ==========================================
  // 1. LOGIKA BARU: STREAK LOKAL (SOLUSI FINAL)
  // ==========================================
  void checkLocalStreak() async {
    final db = DatabaseHelper.instance;
    
    // Ambil tanggal hari ini (Format: 2025-12-09) di HP User
    String today = DateTime.now().toString().split(' ')[0];
    
    // Ambil data history dari SQLite
    String? lastLoginDate = await db.getSetting('last_login_date');
    String? savedStreakStr = await db.getSetting('current_streak');
    int currentStreak = int.parse(savedStreakStr ?? '0');

    // LOGIKA HITUNG STREAK
    if (lastLoginDate == today) {
      // User sudah buka app hari ini -> Streak tetap
      userStreak.value = currentStreak;
    } else {
      // Cek selisih hari
      DateTime dateToday = DateTime.parse(today);
      // Kalau belum pernah login, anggap kemarin baru install
      DateTime dateLast = lastLoginDate != null ? DateTime.parse(lastLoginDate) : dateToday.subtract(Duration(days: 2));
      
      int difference = dateToday.difference(dateLast).inDays;

      if (difference == 1) {
        // Login berturut-turut -> Nambah!
        currentStreak++;
      } else if (lastLoginDate == null) {
        // Baru pertama kali install
        currentStreak = 1;
      } else {
        // Bolos lebih dari 1 hari -> Reset
        currentStreak = 1;
      }
      
      // Simpan Balik ke SQLite (Biar besok diingat)
      await db.saveSetting('last_login_date', today);
      await db.saveSetting('current_streak', currentStreak.toString());
      
      // Update Tampilan
      userStreak.value = currentStreak;
    }
  }

  // ==========================================
  // 2. LOGIKA BARU: FUNFACT (ANTI-KEMBAR)
  // ==========================================
  void fetchFunFacts() async {
    try {
      final data = await DatabaseHelper.instance.getAllFunFacts();
      if (data.isNotEmpty) {
        allFactsFromDb.assignAll(data);
        randomizeFact();
      } else {
        currentFact.value = {'desc': 'Belum ada fakta unik. Admin, tolong isi dong!'};
      }
    } catch (e) {
      print("Error fakta: $e");
    }
  }

  void randomizeFact() {
    if (allFactsFromDb.isNotEmpty) {
      // Kalau datanya cuma 1, ya mau gimana lagi
      if (allFactsFromDb.length == 1) {
        currentFact.value = {'desc': allFactsFromDb[0]['description']};
        return;
      }

      int randomIndex;
      // LOOPING: Cari terus sampai dapat angka yg BEDA dari sebelumnya
      do {
        randomIndex = Random().nextInt(allFactsFromDb.length);
      } while (randomIndex == _lastFactIndex);

      _lastFactIndex = randomIndex; // Kunci index ini

      currentFact.value = {
        'desc': allFactsFromDb[randomIndex]['description']
      };
    }
  }

  // ==========================================
  // 3. LOGIKA LAINNYA (USER & MATERI)
  // ==========================================
  void fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      if (userData != null) {
        userName.value = userData['username'] ?? 'User';
        // Note: Kita abaikan streak dari server, kita pakai yg lokal di atas biar aman
      }
    } catch (e) {
      print("[Dashboard] Gagal ambil user server, pakai default.");
    }
  }

  void fetchInProgressMaterials() async {
    isLoading.value = true;
    try {
      var allLocalMaterials = await DatabaseHelper.instance.getAllMaterials();
      
      // Tetap Hybrid: Cek server kalau ada progress
      var serverProgressMap = {};
      try { serverProgressMap = await ApiService.getAllProgress(); } catch (_) {}

      List<MaterialItem> tempResult = [];

      for (var item in allLocalMaterials) {
        double progress = item.progress; 
        if (serverProgressMap.containsKey(item.id)) {
           progress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           progress = serverProgressMap[item.id.toString()]!; 
        }

        if (progress > 0.0 && progress < 1.0) {
          tempResult.add(MaterialItem(
            id: item.id,
            title: item.title,
            category: item.category,
            iconPath: item.iconPath,
            progress: progress,
          ));
        }
      }

      if (tempResult.length > 3) {
        tempResult = tempResult.sublist(0, 3);
      }
      inProgressMaterials.assignAll(tempResult);

    } catch (e) {
      print("[Dashboard] Error fetchInProgress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void continueMaterial(MaterialItem item) {
    Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    )?.then((value) {
      fetchInProgressMaterials();
      // fetchUserProfile(); // Gak perlu panggil ini lagi buat streak, udh otomatis lokal
    });
  }
  
  void updateLastLearned(String id, String title, double progress, String iconPath){
    inProgressMaterials.removeWhere((item) => item.id.toString() == id);
    if (progress < 1.0 && progress > 0.0) {
        final newItem = MaterialItem(
          id: int.parse(id),
          title: title,
          category: 'Terbaru',
          iconPath: iconPath,
          progress: progress
        );
        inProgressMaterials.insert(0, newItem);
        if (inProgressMaterials.length > 3) {
          inProgressMaterials.removeLast();
        }
    } 
    fetchInProgressMaterials();
  }

  void navigateToSubject(String subjectName) {
     try {
       Get.snackbar("Info", "Menampilkan materi $subjectName");
     } catch (e) {
       print("Error navigasi: $e");
     }
  }
}