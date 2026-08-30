import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  final RxInt selectedPageIndex = 0.obs;
  late final PageController pageController;

  bool get isLastPage => selectedPageIndex.value == onboardingPages.length - 1;

  final List<OnboardingInfo> onboardingPages = [
    OnboardingInfo(
      tag: 'LABORATORIUM VIRTUAL',
      tagIcon: Icons.science_rounded,
      accentColor: const Color(0xFF2563EB),
      imageAsset: 'assets/onboarding_1.png',
      title: 'Lab Sains di Genggamanmu 🔬',
      description:
          'Eksplorasi puluhan alat praktikum fisika, kimia, dan biologi secara interaktif kapan pun kamu mau.',
    ),
    OnboardingInfo(
      tag: 'SIMULASI INTERAKTIF',
      tagIcon: Icons.biotech_rounded,
      accentColor: const Color(0xFF7C3AED),
      imageAsset: 'assets/onboarding_2.png',
      title: 'Eksperimen Bebas & Aman 🧪',
      description:
          'Campur larutan kimia, uji hipotesis, dan amati reaksi ilmiah secara real-time tanpa takut berantakan.',
    ),
    OnboardingInfo(
      tag: 'GAMIFIKASI & HADIAH',
      tagIcon: Icons.emoji_events_rounded,
      accentColor: const Color(0xFFF59E0B),
      imageAsset: 'assets/onboarding_3.png',
      title: 'Kumpulkan XP & Lencana 🚀',
      description:
          'Selesaikan misi harian, taklukkan kuis seru, dan jadilah ilmuwan muda terbaik di Science Craft!',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  void updatePage(int index) {
    selectedPageIndex.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void skipOnboarding() {
    finishOnboarding();
  }

  void finishOnboarding() {
    final box = GetStorage();
    box.write('hasSeenOnboarding', true);
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingInfo {
  final String tag;
  final IconData tagIcon;
  final Color accentColor;
  final String imageAsset;
  final String title;
  final String description;

  OnboardingInfo({
    required this.tag,
    required this.tagIcon,
    required this.accentColor,
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}