import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/on_boarding_controller.dart';

class OnboardingView extends StatelessWidget {
  final controller = Get.put(OnboardingController()); 

  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. KONTEN UTAMA (PAGE VIEW)
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.updatePage,
            itemCount: controller.onboardingPages.length,
            itemBuilder: (context, index) {
              final item = controller.onboardingPages[index];
              
              return Column(
                children: [
                  // A. BAGIAN GAMBAR (Atas - Lebih Luas)
                  // Kita ubah rasionya jadi 2 (Gambar) : 1 (Teks)
                  Expanded(
                    flex: 2, 
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFE3F2FD), 
                      child: Image.asset(
                        item.imageAsset,
                        fit: BoxFit.cover, 
                        alignment: Alignment.topCenter,
                        errorBuilder: (ctx, err, stack) => 
                            const Center(child: Icon(Icons.image, size: 100, color: Colors.blue)),
                      ),
                    ),
                  ),

                  // B. BAGIAN TEKS (Bawah - Lebih Pendek)
                  Expanded(
                    flex: 1, 
                    child: Transform.translate(
                      offset: const Offset(0, -30), 
                      child: Container(
                        width: double.infinity,
                        // Padding disesuaikan biar muat font gede
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 0), 
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            // Judul (Font Lebih Besar)
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26, // DINAICIN DARI 22 JADI 26
                                fontWeight: FontWeight.w800, // LEBIH TEBAL
                                color: Color(0xFF1E3A8A),
                                height: 1.1, // Rapatkan baris sedikit
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Deskripsi (Font Lebih Besar)
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, // DINAICIN DARI 14 JADI 16
                                color: Colors.grey.shade600,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3, 
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. TOMBOL SKIP (Kanan Atas)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    "Lewati",
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. INDIKATOR & TOMBOL NEXT (Paling Bawah)
          Positioned(
            bottom: 30,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indikator Titik
                Obx(() => Row(
                  children: List.generate(
                    controller.onboardingPages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: controller.selectedPageIndex.value == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: controller.selectedPageIndex.value == index
                            ? const Color(0xFF1E3A8A)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )),

                // Tombol Next (Lebih Besar Dikit)
                Obx(() {
                  return SizedBox(
                    height: 56, // Tombol lebih tinggi biar enak dipencet
                    width: 56,
                    child: ElevatedButton(
                      onPressed: controller.nextPage,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFFFD166),
                        elevation: 3,
                      ),
                      child: Icon(
                        controller.isLastPage ? Icons.check : Icons.arrow_forward,
                        color: Colors.black87,
                        size: 28,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}