import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../data/db/database_helper.dart'; 
import '../../../models/material_model.dart'; 
// --- IMPORT API SERVICE ---
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
    
    // Panggil fungsi loading saat controller dibuat
    loadMaterialsHybrid();
  }

  // --- FUNGSI PERBAIKAN: HYBRID LOADING (MERGE LOGIC) ---
  Future<void> loadMaterialsHybrid() async {
    isLoading.value = true;
    print("[ListController] Memulai Hybrid Loading...");

    try {
      // 1. Ambil Data Statis dari SQLite (Ini sudah membawa progress lokal yg benar)
      var localMaterials = await DatabaseHelper.instance.getAllMaterials();

      // 2. Ambil Data Progress dari Server Flask
      var serverProgressMap = await ApiService.getAllProgress();

      List<MaterialItem> mergedList = [];

      for (var item in localMaterials) {
        // --- PERBAIKAN UTAMA DI SINI ---
        
        // Langkah A: Mulai dengan progress yang ada di HP (SQLite)
        // Jadi kalau HP bilang 1.0 (100%), kita pegang angka itu dulu.
        double finalProgress = item.progress; 

        // Langkah B: Cek apakah Server punya data untuk ID ini?
        // Kita cek ID versi int maupun String untuk jaga-jaga
        if (serverProgressMap.containsKey(item.id)) {
           finalProgress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           finalProgress = serverProgressMap[item.id.toString()]!;
        }

        // Langkah C: Masukkan data yang sudah digabung ke list
        mergedList.add(MaterialItem(
          id: item.id,
          title: item.title,
          category: item.category,
          iconPath: item.iconPath,
          progress: finalProgress, // <--- Kita pakai hasil gabungan, bukan 0.0
        ));
      }

      // 3. Simpan ke state dan tampilkan
      _allMaterials.assignAll(mergedList);
      _filterMaterials();

    } catch (e) {
      print("[ListController] Error loading materials: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // --- SELESAI LOGIKA BARU ---

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
    // Kita tunggu sampai user kembali dari halaman detail
    final result = await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress 
    );
    
    // --- PERBAIKAN KEDUA: REFRESH TANPA SYARAT ---
    // Hapus "if (result == true)".
    // Kenapa? Supaya kalau user tekan 'Back' biasa pun, 
    // list tetap mengecek database barangkali ada update.
    print("[ListController] Kembali dari detail, refresh data...");
    loadMaterialsHybrid(); 
  }
  
  // Fungsi updateProgress manual (opsional, tapi bagus disimpan)
  void updateProgress(int id, double newProgress) {
    final index = _allMaterials.indexWhere((item) => item.id == id);
    if (index != -1) {
      final currentItem = _allMaterials[index];
      final updatedItem = MaterialItem(
        id: currentItem.id,
        title: currentItem.title,
        category: currentItem.category,
        progress: newProgress.clamp(0.0, 1.0),
        iconPath: currentItem.iconPath,
      );
      _allMaterials[index] = updatedItem;
      _filterMaterials();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}