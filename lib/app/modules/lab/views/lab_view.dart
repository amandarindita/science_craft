import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lab_controller.dart';
import '../../materi/controllers/material_list_controller.dart'; // Import controller materi
import '../../../routes/app_pages.dart'; 

class LabView extends GetView<LabController> {
  const LabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita panggil MaterialListController buat ngambil datanya
    final materiController = Get.put(MaterialListController()); 

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
      body: Obx(() { // Pakai Obx supaya otomatis update kalau data dari API baru masuk
        if (materiController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Kita saring, HANYA tampilkan materi yang punya unity_scene_id dari admin
        final labMaterials = materiController.filteredMaterials
            .where((m) => m.unitySceneId != null && m.unitySceneId!.isNotEmpty)
            .toList();

        if (labMaterials.isEmpty) {
          return const Center(child: Text("Belum ada eksperimen yang tersedia."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: labMaterials.length,
          itemBuilder: (context, index) {
            final item = labMaterials[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildLabItem(
                title: "Praktikum: ${item.title}",
                desc: "Kategori: ${item.category}",
                color: Colors.blue.shade50, // Bisa di-custom sesuai kategori nanti
                icon: Icons.science,
                iconColor: Colors.blue,
                onTap: () {
                  // 🚀 JEDARRR! Panggil BottomSheet Instruksi sebelum masuk Unity
                  Get.bottomSheet(
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Biar tinggi laci menyesuaikan isi teks
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Garis handle estetik di tengah atas
                          Center(
                            child: Container(
                              width: 40, height: 5,
                              margin: const EdgeInsets.only(bottom:20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          // Judul Laci
                          const Row(
                            children: [
                              Icon(Icons.assignment_outlined, color: Colors.blue, size: 28),
                              SizedBox(width: 10),
                              Text("Petunjuk Praktikum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Teks Instruksi dari Database Flask
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(
                                item.instructions ?? "Ikuti petunjuk di dalam simulasi virtual.",
                                style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Tombol Masuk Unity
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: () {
                                Get.back(); // Tutup BottomSheet dulu
                                
                                // Lanjut terbang ke Unity bawa data scene-nya
                                Get.toNamed(
                                  Routes.SIMULATION, 
                                  arguments: {
                                    'sceneID': item.unitySceneId, 
                                    'sceneName': item.title
                                  },
                                );
                              },
                              child: const Text("Paham, Mulai Eksperimen 🚀", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isScrollControlled: true, // Wajib TRUE biar teks panjang gak error ngelebihi layar
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  // Widget custom _buildLabItem biarkan sama seperti sebelumnya
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
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
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