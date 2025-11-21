import 'package:get/get.dart';
import 'package:flutter/material.dart';

// Import semua view yang akan kita tampilkan
import '../../dashboard/views/dashboard_view.dart';
import '../../materi/views/material_list_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../routes/app_pages.dart'; // <-- JANGAN LUPA IMPORT INI

class RootController extends GetxController {
  final selectedNavIndex = 0.obs;
  final previousNavIndex = 0.obs;

  // --- PERBAIKI DAFTAR HALAMAN DI SINI ---
  final List<Widget> pages = [
    const DashboardView(),      // Indeks 0: Home
    Container(color: Colors.green, child: const Center(child: Text("Halaman Lab"))), // Indeks 1: Lab (Placeholder)
    const MaterialListView(),   // Indeks 2: Materi
    const ProfileView(),        // Indeks 3: Profil <-- GANTI DARI CONTAINER MENJADI PROFILEVIEW
  ];

  Widget get currentPage => pages[selectedNavIndex.value];

  void changeNavIndex(int index) {
    if (index == selectedNavIndex.value) return;

    previousNavIndex.value = selectedNavIndex.value;
    selectedNavIndex.value = index;
  }
  void goToChatbot() {
    Get.toNamed(Routes.CHATBOT);
  }
}

