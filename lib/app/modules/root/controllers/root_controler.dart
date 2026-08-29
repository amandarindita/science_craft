import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 1. IMPORT DASHBOARD BARU (Ini kunci utamanya)
import '../../dashboard/views/dashboard_new_view.dart';
import '../../profile_learning/views/profile_learning_view.dart';
import '../../lab/views/lab_view.dart'; // 2. Lab tetap dipertahankan
import '../../learning/views/learning_view.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../../learning/controllers/learning_controller.dart';

import '../../../routes/app_pages.dart';

class RootController extends GetxController {
  final selectedNavIndex = 0.obs;
  final previousNavIndex = 0.obs;

  late final List<Widget> pages;

  @override
  void onInit() {
    super.onInit();

    if (!Get.isRegistered<LearningController>()) {
      Get.lazyPut<LearningController>(
        LearningController.new,
        fenix: true,
      );
    }

    // 3. UPDATE LIST PAGES (Cuma ganti index 0)
    pages = <Widget>[
      const DashboardNewView(), // Indeks 0: Sekarang langsung ke Home Baru
      LabView(),                // Indeks 1: Lab aman
      const LearningView(),     // Indeks 2: Materi
      const ProfileLearningView(),      // Indeks 3: Profil
    ];
  }

  Widget get currentPage => pages[selectedNavIndex.value];

  void changeNavIndex(int index) {
    if (index == selectedNavIndex.value) {
      if (index == 2 && Get.isRegistered<LearningController>()) {
        Get.find<LearningController>().initialize();
      }
      return;
    }

    previousNavIndex.value = selectedNavIndex.value;
    selectedNavIndex.value = index;

    if (index == 0) {
      if (Get.isRegistered<DashboardController>()) {
        final DashboardController dashController = Get.find<DashboardController>();
        dashController.fetchInProgressMaterials();
        dashController.fetchUserProfile();
      }
    }

    if (index == 2 && Get.isRegistered<LearningController>()) {
      Get.find<LearningController>().initialize();
    }
  }

  void goToChatbot() {
    Get.toNamed(Routes.CHATBOT);
  }
}