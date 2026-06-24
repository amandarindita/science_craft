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
              childAspectRatio: 0.8, // Sedikit disesuaikan
            ),
            itemBuilder: (context, index) {
              final badge = controller.badges[index];
              
              // 🌟 1. BUNGKUS PAKAI GESTURE DETECTOR BIAR BISA DIKLIK 🌟
              return GestureDetector(
                onTap: () => _showBadgeInfo(context, badge),
                child: Column(
                  children: [
                    // --- GAMBAR BADGE (TANPA LINGKARAN) ---
                    Expanded(
                      // Langsung tampilkan gambarnya tanpa Container/Decoration
                      child: badge.isOwned
                          // KONDISI 1: SUDAH PUNYA (Full Color)
                          ? Image.asset(badge.imagePath, fit: BoxFit.contain)
                          
                          // KONDISI 2: BELUM PUNYA (Hitam Putih + Transparan)
                          : ColorFiltered(
                              colorFilter: const ColorFilter.matrix(<double>[
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      0.5, 0, // Opacity di sini
                              ]),
                              child: Image.asset(badge.imagePath, fit: BoxFit.contain),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 🌟 2. FUNGSI UNTUK MUNCULIN BOTTOM SHEET (LACI INFO BADGE) 🌟
  void _showBadgeInfo(BuildContext context, dynamic badge) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Biar tingginya nyesuaiin isi konten
          children: [
            // Garis abu-abu di atas (Drag handle)
            Container(
              width: 50, height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),

            // Gambar Badge (Gedein dikit biar mantap!)
            Container(
              height: 120, width: 120,
              decoration: badge.isOwned ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4), // Glow tipis kalau udah punya
                    blurRadius: 20, spreadRadius: 5,
                  )
                ]
              ) : null,
              child: badge.isOwned
                  ? Image.asset(badge.imagePath, fit: BoxFit.contain)
                  : ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      0.5, 0, 
                      ]),
                      child: Image.asset(badge.imagePath, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(height: 20),

            // Judul Badge
            Text(
              badge.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Indikator Status (Dimiliki / Terkunci)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: badge.isOwned ? Colors.green.shade100 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badge.isOwned ? Colors.green.shade300 : Colors.red.shade200)
              ),
              child: Text(
                badge.isOwned ? "✅ Telah Didapatkan" : "🔒 Masih Terkunci",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: badge.isOwned ? Colors.green.shade700 : Colors.red.shade400,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deskripsi / Syarat Dapetin Badge
            const Text(
              "Cara Mendapatkan:",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description, // Menampilkan deskripsi dari controller lu
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      isScrollControlled: true, // Wajib true biar desain bottomsheet lu gak gampang kepotong
    );
  }
}