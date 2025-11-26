import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';

class OnboardingController extends GetxController {
  var selectedPageIndex = 0.obs;
  var pageController = PageController();
  bool get isLastPage => selectedPageIndex.value == onboardingPages.length - 1;

  // Data Halaman Onboarding
  final List<OnboardingInfo> onboardingPages = [
    OnboardingInfo(
      imageAsset: 'assets/onboarding_1.png', // Pastikan gambar ini ada
      title: 'Selamat Datang di Lab Rahasia Kamu 🔬',
      description: 'Semua alat eksperimen, langsung di genggaman.',
    ),
    OnboardingInfo(
      imageAsset: 'assets/onboarding_2.png',
      title: 'Eksperimen Seru Tanpa Ribet',
      description: 'Campur, uji, dan lihat hasilnya... tanpa takut berantakan!',
    ),
    OnboardingInfo(
      imageAsset: 'assets/onboarding_3.png',
      title: 'Petualangan Belajar Tanpa Batas!',
      description: 'Jelajahi eksperimen, pecahkan misteri, dan temukan pengetahuan baru setiap hari.',
    ),
  ];

  // Fungsi ganti halaman saat di-swipe
  void updatePage(int index) {
    selectedPageIndex.value = index;
  }

  // Fungsi tombol "Lanjut" (Panah Kanan)
  void nextPage() {
    if (isLastPage) {
      finishOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
    }
  }

  // Fungsi tombol "Lewati" (Skip)
  void skipOnboarding() {
    finishOnboarding();
  }

  // --- FUNGSI PENTING: SIMPAN STATUS & PINDAH KE LOGIN ---
  void finishOnboarding() {
    final box = GetStorage();
    // Simpan tanda bahwa user sudah pernah lihat onboarding
    box.write('hasSeenOnboarding', true);
    
    // Pindah ke halaman Login (Hapus history onboarding biar ga bisa back)
    Get.offAllNamed(Routes.LOGIN);
  }
}

// Model Data Sederhana
class OnboardingInfo {
  final String imageAsset;
  final String title;
  final String description;

  OnboardingInfo({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}