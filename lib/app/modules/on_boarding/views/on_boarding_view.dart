import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/on_boarding_controller.dart';

class OnboardingView extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

  OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= 1. PAGEVIEW UTAMA (SLIDE GAMBAR & TEKS MENYATU) =================
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.updatePage,
                  itemCount: controller.onboardingPages.length,
                  itemBuilder: (context, index) {
                    final item = controller.onboardingPages[index];

                    return Column(
                      children: [
                        // A. BAGIAN GAMBAR HERO (Cover dengan Gradasi Bawah yang Halus)
                        Expanded(
                          flex: 11,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item.imageAsset,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: const Color(0xFFEBF3FE),
                                  child: const Center(
                                    child: Icon(
                                      Icons.science_rounded,
                                      size: 100,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ),
                              ),

                              // Fade Gradient Halus ke Background Putih
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.85),
                                        Colors.white,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // B. KONTEN TEKS MODERN (Badge Kategori + Judul + Deskripsi)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(26, 8, 26, 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badge Kategori Sains
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: item.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      item.tagIcon,
                                      size: 14,
                                      color: item.accentColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item.tag,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: item.accentColor,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Judul Onboarding
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  height: 1.25,
                                  letterSpacing: -0.4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Deskripsi Onboarding
                              Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // ================= 2. BOTTOM CONTROL BAR (INDIKATOR & TOMBOL UTAMA) =================
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  26,
                  14,
                  26,
                  bottomInset > 0 ? bottomInset + 8 : 22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indikator Titik Animasi
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.onboardingPages.length,
                          (index) {
                            final bool isSelected =
                                controller.selectedPageIndex.value == index;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 7,
                              width: isSelected ? 26 : 7,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Tombol Aksi Utama
                    Obx(
                      () => Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF1D4ED8),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x382563EB),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.isLastPage
                                    ? 'Mulai Petualangan Sains'
                                    : 'Lanjutkan',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                controller.isLastPage
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ================= 3. TOMBOL LEWATI (FROSTED GLASS CHIP DENGAN IKON) =================
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.isLastPage ? 0.0 : 1.0,
                    child: IgnorePointer(
                      ignoring: controller.isLastPage,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: controller.skipOnboarding,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.9),
                                width: 1.2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x140F172A),
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Lewati',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF1E293B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_double_arrow_right_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 17,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}