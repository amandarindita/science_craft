import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/views/dashboard_view.dart';
import '../../profile/views/profile_view.dart';
import '../../lab/views/lab_view.dart';
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

    // Karena LearningView dibuka langsung dari bottom navigation,
    // LearningController harus didaftarkan di sini.
    if (!Get.isRegistered<LearningController>()) {
      Get.lazyPut<LearningController>(
        LearningController.new,
        fenix: true,
      );
    }

    pages = <Widget>[
      const DashboardView(), // Indeks 0: Home
      LabView(),             // Indeks 1: Lab
      const LearningView(),  // Indeks 2: Materi baru
      const ProfileView(),   // Indeks 3: Profil
    ];
  }

  Widget get currentPage =>
      pages[selectedNavIndex.value];

  void changeNavIndex(int index) {
    if (index == selectedNavIndex.value) {
      // Saat tab materi ditekan ulang, muat ulang kontennya.
      if (index == 2 &&
          Get.isRegistered<LearningController>()) {
        Get.find<LearningController>().initialize();
      }
      return;
    }

    previousNavIndex.value =
        selectedNavIndex.value;
    selectedNavIndex.value = index;

    if (index == 0) {
      if (Get.isRegistered<DashboardController>()) {
        final DashboardController dashController =
            Get.find<DashboardController>();

        dashController.fetchInProgressMaterials();
        dashController.fetchUserProfile();
      }
    }

    if (index == 2 &&
        Get.isRegistered<LearningController>()) {
      Get.find<LearningController>().initialize();
    }
  }

  void goToChatbot() {
    Get.toNamed(Routes.CHATBOT);
  }
}