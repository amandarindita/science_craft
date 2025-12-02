import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
// Import ProfileController untuk ambil data Avatar
import '../../profile/controllers/profile_controller.dart'; 
import '../../../widgets/shared_cards.dart'; 

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Column(
        children: [
          _buildHeader(context),
          _buildBody(context),
        ],
      ),
    );
  }

  // --- HEADER (PROFILE & STREAK) ---
  Widget _buildHeader(BuildContext context) {
    // Panggil ProfileController
    final ProfileController profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 130),
      child: Row(
        children: [
          // --- AVATAR ---
          Obx(() => Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              image: DecorationImage(
                image: AssetImage(profileController.avatarPath.value),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                   print("Error loading avatar: ${profileController.avatarPath.value}");
                }
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
          )),
          
          const SizedBox(width: 12),
          
          // Nama User
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                    'Hai ${controller.userName.value}! 👋',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  )),
              const Text(
                'Siap belajar sains hari ini?',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const Spacer(),
          
          // Streak Counter
          Row(
            children: [
              Obx(() => Text(
                    '${controller.userStreak.value}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF57C00)),
                  )),
              const SizedBox(width: 4),
              const Text('🔥', style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  // --- BODY (KONTEN UTAMA) ---
  Widget _buildBody(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Container Putih Utama
        Container(
          margin: const EdgeInsets.only(top: 100),
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Bagian 1: Pilihan Mata Pelajaran
              const Text('Mulai Eksperimen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SubjectCard(
                      height: 120,
                      label: 'Biologi',
                      iconPath: 'assets/biology.png',
                      onTap: () => controller.navigateToSubject('Biologi')),
                  _SubjectCard(
                      height: 120,
                      label: 'Fisika',
                      iconPath: 'assets/physics.png',
                      onTap: () => controller.navigateToSubject('Fisika')),
                  _SubjectCard(
                      height: 120,
                      label: 'Kimia',
                      iconPath: 'assets/chemistry.png',
                      onTap: () => controller.navigateToSubject('Kimia')),
                ],
              ),
              const SizedBox(height: 30),

              // Bagian 2: Lanjutkan Belajar
              const Text('Lanjutkan Belajar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // --- LOGIKA TAMPILAN LIST ---
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (controller.inProgressMaterials.isEmpty) {
                  return _buildEmptyHistoryCard();
                }

                return Column(
                  children: controller.inProgressMaterials.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0), 
                      child: ContinueLearningCard(
                        title: item.title,
                        progress: item.progress,
                        iconPath: item.iconPath,
                        onTap: () => controller.continueMaterial(item),
                      ),
                    );
                  }).toList(),
                );
              }),
              
              const SizedBox(height: 20),
            ],
          ),
        ),

        // --- KARTU "TAHUKAH KAMU?" (VERSI BERSIH/CLEAN) ---
        Positioned(
          top: -80,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 215,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Kuning
                Positioned(
                  top: 40, left: 0, right: 0, bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD166),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gambar Dekorasi
                Positioned(
                  top: -50, left: 0, right: 0,
                  child: Image.asset(
                    'assets/fact_card.png', 
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const SizedBox(), 
                  ),
                ),
                // Konten Teks (White Card - Clean Version)
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: Container(
                    width: double.infinity, // Lebar penuh
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() {
                      // Cek jika data kosong
                      if (controller.currentFact.isEmpty) return const SizedBox();
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Saja
                          const Text(
                            'Tahukah Kamu?',
                            style: TextStyle(
                              fontSize: 18, // Ukuran font pas
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF333333)
                            )
                          ),
                          
                          const SizedBox(height: 8),

                          // Deskripsi Langsung (Tanpa Judul Kategori)
                          Text(
                            controller.currentFact['desc'] ?? '',
                            style: const TextStyle(
                              fontSize: 14, 
                              color: Color(0xFF555555),
                              height: 1.5, // Spasi baris biar enak dibaca
                            ),
                            maxLines: 3, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET: TAMPILAN JIKA HISTORY KOSONG ---
  Widget _buildEmptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/rocket_start.png', 
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.rocket_launch_rounded, size: 60, color: Colors.orangeAccent),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            "Mulai Petualangan Sainsmu!",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8), 
          
          Text(
            "Pilih materi di atas untuk mulai belajar.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- WIDGET: KARTU MATA PELAJARAN ---
class _SubjectCard extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;
  final double? height;

  const _SubjectCard({
    Key? key,
    required this.label,
    required this.iconPath,
    required this.onTap,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height,
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath, 
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}