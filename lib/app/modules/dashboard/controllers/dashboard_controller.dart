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
  final userStreak = 0.obs;

  // --- DATA "LANJUTKAN BELAJAR" ---
  final inProgressMaterials = <MaterialItem>[].obs;
  final isLoading = true.obs;
  final box = GetStorage();

  // --- BAGIAN FAKTA SAINS ---
  var currentFact = <String, String>{}.obs;
  var allFactsFromDb = <Map<String, dynamic>>[].obs;
  int _lastFactIndex = -1;

  @override
  void onInit() {
    super.onInit();
    checkLocalStreak();
    fetchUserProfile();
    fetchInProgressMaterials(); // Load awal
    fetchFunFacts();
  }

  Future<void> fetchInProgressMaterials() async {
        try {
      var allLocalMaterials = await DatabaseHelper.instance.getAllMaterials();
      
      // Ambil data server (optional, skip error kalau offline)
      var serverProgressMap = {};
      try { serverProgressMap = await ApiService.getAllProgress(); } catch (_) {}

      List<MaterialItem> tempResult = [];

      for (var item in allLocalMaterials) {
        double progress = item.progress; 
        
        // Prioritas data server jika ada
        if (serverProgressMap.containsKey(item.id)) {
           progress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           progress = serverProgressMap[item.id.toString()]!; 
        }

        // HANYA ambil yang > 0% dan < 100% (Materi Sedang Berjalan)
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

  void updateLastLearned(String id, String title, double progress, String iconPath){
    print("[Dashboard] Updating UI manual untuk ID: $id -> ${(progress*100).toInt()}%");

    inProgressMaterials.removeWhere((item) => item.id.toString() == id);
    
       if (progress < 0.99 && progress > 0.0) {
        final newItem = MaterialItem(
          id: int.parse(id),
          title: title,
          category: 'Lanjutkan', 
          iconPath: iconPath,
          progress: progress
        );
  
        inProgressMaterials.insert(0, newItem);
        
          if (inProgressMaterials.length > 5) {
          inProgressMaterials.removeLast();
        }
    } 
    
    inProgressMaterials.refresh(); 
  }

  void continueMaterial(MaterialItem item) async {
    // Tunggu user balik dari detail
    await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    );
    fetchInProgressMaterials();
  }


  
  void checkLocalStreak() async {
    final db = DatabaseHelper.instance;
    String today = DateTime.now().toString().split(' ')[0];
    String? lastLoginDate = await db.getSetting('last_login_date');
    String? savedStreakStr = await db.getSetting('current_streak');
    int currentStreak = int.parse(savedStreakStr ?? '0');

    if (lastLoginDate == today) {
      userStreak.value = currentStreak;
    } else {
      DateTime dateToday = DateTime.parse(today);
      DateTime dateLast = lastLoginDate != null ? DateTime.parse(lastLoginDate) : dateToday.subtract(Duration(days: 2));
      int difference = dateToday.difference(dateLast).inDays;

      if (difference == 1) {
        currentStreak++;
      } else if (lastLoginDate == null) {
        currentStreak = 1;
      } else {
        currentStreak = 1;
      }
      
      await db.saveSetting('last_login_date', today);
      await db.saveSetting('current_streak', currentStreak.toString());
      userStreak.value = currentStreak;
    }
  }

  void fetchFunFacts() async {
    try {
      final data = await DatabaseHelper.instance.getAllFunFacts();
      if (data.isNotEmpty) {
        allFactsFromDb.assignAll(data);
        randomizeFact();
      } else {
        currentFact.value = {'desc': 'Belum ada fakta unik.'};
      }
    } catch (e) {
      print("Error fakta: $e");
    }
  }

  void randomizeFact() {
    if (allFactsFromDb.isNotEmpty) {
      if (allFactsFromDb.length == 1) {
        currentFact.value = {'desc': allFactsFromDb[0]['description']};
        return;
      }
      int randomIndex;
      do {
        randomIndex = Random().nextInt(allFactsFromDb.length);
      } while (randomIndex == _lastFactIndex);
      _lastFactIndex = randomIndex;
      currentFact.value = {
        'desc': allFactsFromDb[randomIndex]['description']
      };
    }
  }

  void fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      if (userData != null) {
        userName.value = userData['username'] ?? 'Sobat Sains';
      }
    } catch (e) {}
  }

  void navigateToSubject(String subjectName) {
     // Implementasi navigasi kategori dashboard
     Get.toNamed(Routes.MATERIAL_LIST); 
     // Tips: Bisa set filter kategori di MaterialListController di sini jika mau
  }
}