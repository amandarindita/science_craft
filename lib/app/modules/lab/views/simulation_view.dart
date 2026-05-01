import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../controllers/lab_controller.dart';

// Kita pakai GetView biar langsung dapet akses ke LabController
class SimulationView extends GetView<LabController> {
  const SimulationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack dipakai buat numpuk Tombol Back di atas Unity
      body: Stack(
        children: [
          // LAYER 1: Unity Engine
          UnityWidget(
            onUnityCreated: controller.onUnityCreated,
            onUnityMessage: controller.onUnityMessage,
            onUnitySceneLoaded: controller.onUnitySceneLoaded,
            useAndroidViewSurface: true, // Wajib TRUE buat Android
            fullscreen: true,            // Set TRUE biar full layar
            borderRadius: BorderRadius.zero,
          ),

          // LAYER 2: Tombol Back (Pojok Kiri Atas)
          Positioned(
            top: 50, // Sesuaikan jarak dari atas (biar ga ketabrak poni HP)
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  // PENTING: Pake Get.back() buat keluar dari halaman ini
                  // dan balik ke menu list eksperimen
                  Get.back(); 
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}