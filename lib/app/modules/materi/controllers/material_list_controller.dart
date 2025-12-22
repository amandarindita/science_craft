import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/db/database_helper.dart'; 
import '../../../models/material_model.dart'; 
import '../../../data/api_service.dart';

class MaterialListController extends GetxController {
  final searchController = TextEditingController();
  final selectedCategory = 'Biologi'.obs;
  final isLoading = true.obs;

  final _allMaterials = <MaterialItem>[].obs; 
  final filteredMaterials = <MaterialItem>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    ever(selectedCategory, (_) => _filterMaterials());
    ever(searchQuery, (_) => _filterMaterials());
    
    loadMaterialsHybrid();
  }

  // --- LOGIKA LOAD DATA AMAN (OFFLINE FIRST) ---
  Future<void> loadMaterialsHybrid() async {
    isLoading.value = true;
    print("[ListController] Memuat data materi...");

    try {
      // 1. Ambil Data dari SQLite (Inputan Admin kamu)
      var localMaterials = await DatabaseHelper.instance.getAllMaterials();
      
      // List sementara buat nampung hasil gabungan
      List<MaterialItem> finalResult = [];

      // 2. Coba Ambil Progress dari Server (Kalo server nyala)
      Map<dynamic, double> serverProgressMap = {};
      try {
        serverProgressMap = await ApiService.getAllProgress();
      } catch (e) {
        print("[ListController] Server offline/error, pakai data lokal saja.");
        // Gak masalah error, kita lanjut pakai data lokal
      }

      // 3. Gabungkan Data
      for (var item in localMaterials) {
        double currentProgress = item.progress;

        // Kalau server punya data progress yg lebih baru, pakai itu
        if (serverProgressMap.containsKey(item.id)) {
           currentProgress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           currentProgress = serverProgressMap[item.id.toString()]!;
        }

        finalResult.add(MaterialItem(
          id: item.id,
          title: item.title,
          category: item.category,
          iconPath: item.iconPath,
          progress: currentProgress,
        ));
      }

      // 4. Tampilkan ke Layar
      _allMaterials.assignAll(finalResult);
      _filterMaterials(); // Refresh filter

    } catch (e) {
      print("[ListController] Error fatal: $e");
      Get.snackbar("Error", "Gagal memuat materi database");
    } finally {
      isLoading.value = false;
    }
  }

  void _filterMaterials() {
    List<MaterialItem> results;
    if (searchQuery.isEmpty) {
      results = _allMaterials
          .where((item) => item.category == selectedCategory.value)
          .toList();
    } else {
      results = _allMaterials
          .where((item) =>
              item.category == selectedCategory.value &&
              item.title.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
    filteredMaterials.assignAll(results);
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void openMaterial(MaterialItem item) async { 
    // Tunggu user balik dari detail
    await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress 
    );
    
    // Refresh otomatis pas balik, biar progress bar update
    print("[ListController] Refresh data setelah belajar...");
    loadMaterialsHybrid(); 
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}