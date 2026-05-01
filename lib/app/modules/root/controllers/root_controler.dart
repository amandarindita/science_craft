import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Import View
import '../../dashboard/views/dashboard_view.dart';
import '../../materi/views/material_list_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../routes/app_pages.dart';

// --- IMPORT VIEW LAB (YANG ISINYA MENU LIST) ---
import '../../lab/views/lab_view.dart'; 

import '../../dashboard/controllers/dashboard_controller.dart';

class RootController extends GetxController {
  final selectedNavIndex = 0.obs;
  final previousNavIndex = 0.obs;

  final List<Widget> pages = [
    const DashboardView(),      // Indeks 0: Home
    
    // --- GANTI BAGIAN INI ---
    // Dulu: Container(color: Colors.green...),
    // Sekarang:
    const LabView(),            // Indeks 1: Lab (Menu List Eksperimen)
    
    const MaterialListView(),   // Indeks 2: Materi
    const ProfileView(),        // Indeks 3: Profil
  ];

  Widget get currentPage => pages[selectedNavIndex.value];

  void changeNavIndex(int index) {
    if (index == selectedNavIndex.value) return;

    previousNavIndex.value = selectedNavIndex.value;
    selectedNavIndex.value = index;

    // Logika refresh data Dashboard
    if (index == 0) {
      if (Get.isRegistered<DashboardController>()) {
        final dashController = Get.find<DashboardController>();
        dashController.fetchInProgressMaterials();
        dashController.checkLocalStreak();
      }
    }
  }

  void goToChatbot() {
    Get.toNamed(Routes.CHATBOT);
  }
}