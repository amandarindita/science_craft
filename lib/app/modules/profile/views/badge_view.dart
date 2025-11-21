import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import controller profil biar bisa baca data badge
import '../controllers/profile_controller.dart';

class BadgeView extends GetView<ProfileController> {
  const BadgeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Cream lembut sesuai desain
      backgroundColor: const Color(0xFFFFFBEF), 
      
      appBar: AppBar(
        title: const Text(
          "Koleksi Badge",
          style: TextStyle(
            color: Color(0xFF1E3A8A), // Warna biru tua
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A8A)),
          onPressed: () => Get.back(),
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Obx(
          () => GridView.builder(
            itemCount: controller.badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 Kolom ke samping
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.85, // Sedikit lebih tinggi biar muat teks
            ),
            itemBuilder: (context, index) {
              final badge = controller.badges[index];
              
              return Column(
                children: [
                  // --- GAMBAR BADGE ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        // Lingkaran background tipis (opsional)
                        shape: BoxShape.circle,
                        color: badge.isOwned 
                            ? Colors.white 
                            : Colors.grey.shade300,
                        boxShadow: badge.isOwned ? [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: badge.isOwned
                          // KONDISI 1: SUDAH PUNYA (Full Color)
                          ? Image.asset(badge.imagePath, fit: BoxFit.contain)
                          
                          // KONDISI 2: BELUM PUNYA (Hitam Putih + Transparan)
                          : ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]),
                              child: Opacity(
                                opacity: 0.5, // Bikin agak pudar
                                child: Image.asset(badge.imagePath, fit: BoxFit.contain),
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // --- NAMA BADGE ---
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      // Kalau belum punya, teksnya abu-abu
                      color: badge.isOwned ? Colors.black87 : Colors.grey, 
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}