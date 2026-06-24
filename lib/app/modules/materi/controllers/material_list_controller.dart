import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart'; 
import '../../../models/material_model.dart'; 
import '../../../data/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../data/auth_service.dart';

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
    
    loadMaterialsFromServer();
  }

Future<void> loadMaterialsFromServer() async {
    isLoading.value = true;
    try {
      // 1. Ambil list materi dari Flask
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/admin/materials'),
        headers: {'Authorization': 'Bearer ${Get.find<AuthService>().token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        
Map<int, double> progressMap = {};
        try {
          progressMap = await ApiService.getAllProgress();
        } catch (e) {
          print("[ListController] Error Map: $e"); // Biar kalau error ketahuan di terminal!
        }

        // 3. Map data ke Model dengan konversi ID yang aman
        var results = data.map((m) {
          double p = 0.0;
          
          // Paksa ID dari API jadi Integer biar seragam!
          int currentId = int.parse(m['id'].toString());
          
          if (progressMap.containsKey(currentId)) {
            p = progressMap[currentId]!;
          }
          
          return MaterialItem.fromMap({...m, 'progress': p});
        }).toList();

        _allMaterials.assignAll(results);
        _filterMaterials();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat materi dari server");
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
    // Tangkap status perubahan dari halaman Detail
    final didProgressChange = await Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress 
    );
    
    // Refresh otomatis HANYA jika ada progres bacaan yang nambah
    if (didProgressChange == true) {
      print("[ListController] Progres nambah! Refresh data list...");
      loadMaterialsFromServer(); 
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}