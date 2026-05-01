import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lab_controller.dart';
// Import Routes biar bisa panggil nama rutenya
import '../../../routes/app_pages.dart'; 

class LabView extends GetView<LabController> {
  const LabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Laboratorium Virtual", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- HEADER ---
          const Text(
            "Pilih Eksperimen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          // --- ITEM 1: REAKSI KIMIA ---
          _buildLabItem(
            title: "Praktikum Kimia Dasar",
            desc: "Simulasi pencampuran larutan Asam & Basa",
            color: Colors.blue.shade50,
            icon: Icons.science,
            iconColor: Colors.blue,
            onTap: () {
              // PERBAIKAN DI SINI:
              // Kita kirim ID = 1 (misalnya) buat Kimia
              Get.toNamed(
                Routes.SIMULATION, 
                arguments: {
                  'sceneID': 1, 
                  'sceneName': "Praktikum Kimia Dasar"
                },
              );
            },
          ),

          const SizedBox(height: 15),

          // --- ITEM 2: HUKUM NEWTON ---
          _buildLabItem(
            title: "Hukum Newton (Fisika)",
            desc: "Simulasi gerak benda pada bidang miring",
            color: Colors.orange.shade50,
            icon: Icons.biotech,
            iconColor: Colors.orange,
            onTap: () {
              // PERBAIKAN DI SINI:
              // Kita kirim ID = 2 (misalnya) buat Fisika
              Get.toNamed(
                Routes.SIMULATION, 
                arguments: {
                  'sceneID': 2, 
                  'sceneName': "Hukum Newton"
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget custom (Tetap sama, tidak perlu diubah)
  Widget _buildLabItem({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}