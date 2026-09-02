import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/gacha_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class TestingController extends GetxController {
  // 1. Simulasi Naik Level Instan
  void triggerLevelUp() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_rounded, color: Colors.amber, size: 60),
              const SizedBox(height: 12),
              Text(
                'Level Up! 🚀',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Selamat! Kamu berhasil naik ke Level 3 (Asisten Lab).', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Keren!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. Simulasi Unlock Badge Baru
  void triggerUnlockBadge() {
    final sampleBadges = ['Quantum Overlord', 'Mad Scientist', 'Darwin’s Successor'];
    final randomBadge = sampleBadges[DateTime.now().second % sampleBadges.length];

    Get.snackbar(
      'Pencapaian Baru! 🏆',
      'Lencana "$randomBadge" berhasil dibuka!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.purple,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.workspace_premium, color: Colors.white),
    );

    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchUserProfile();
    }
  }

  // 3. Simulasi Tambah Tiket Gacha Instan
  void triggerAddTickets() {
    if (Get.isRegistered<GachaController>()) {
      final gachaCtrl = Get.find<GachaController>();
      gachaCtrl.gachaTickets.value += 3;
    }
    Get.snackbar(
      'Cheat Aktif! 🎟️',
      '+3 Tiket Gacha ditambahkan ke dompetmu.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}