import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../root/controllers/root_controler.dart';


class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar item navigasi, sama seperti sebelumnya
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.science_outlined, 'label': 'Lab'},
      {'icon': Icons.book_outlined, 'label': 'Materi'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern yang menutupi seluruh layar
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pattern.png'),
                scale: 1.0,
                repeat: ImageRepeat.repeat,
                opacity: 0.07,
              ),
              color: Color(0xFFF4F6FA),
            ),
          ),

          // Obx akan otomatis mengganti "ruangan" (halaman)
          // berdasarkan `selectedNavIndex` di controller
          Obx(() => controller.currentPage),
          _buildFloatingChatButton(),
          // Bottom Navigation Bar yang permanen
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildCustomBottomNavBar(context, navItems),
          ),
        ],
      ),
    );
  }
  Widget _buildFloatingChatButton() {
    return Obx(() => AnimatedOpacity(
          // Tampilkan hanya jika di halaman Dashboard (indeks 0)
          opacity: controller.selectedNavIndex.value == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          // IgnorePointer mencegah tombol diklik saat disembunyikan
          child: IgnorePointer(
            ignoring: controller.selectedNavIndex.value != 0,
            child: Padding(
              // Posisikan 90px dari bawah (di atas nav bar) dan 24px dari kanan
              padding: const EdgeInsets.only(bottom: 90.0, right: 24.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () => controller.goToChatbot(),
                  backgroundColor: const Color(0xFF4A90E2),
                  splashColor: Colors.blue.shade300,
                  child: const Icon(
                    Icons.support_agent_rounded, // Ikon Chatbot
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ));
  }


  // --- WIDGET CUSTOM NAVIGATION BAR (Lengkap dengan animasi geser) ---
  Widget _buildCustomBottomNavBar(
      BuildContext context, List<Map<String, dynamic>> navItems) {
    const double navBarHeight = 65.0;
    const double circleDiameter = 60.0;
    const double holeRadius = 35.0;

    return Obx(() {
      final screenWidth = MediaQuery.of(context).size.width;
      final double itemWidth = screenWidth / navItems.length;

      // Tentukan titik AWAL dan AKHIR animasi dari controller
      final double beginPosition =
          (itemWidth * controller.previousNavIndex.value) + (itemWidth / 2);
      final double endPosition =
          (itemWidth * controller.selectedNavIndex.value) + (itemWidth / 2);

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: beginPosition, end: endPosition),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        builder: (context, animatedPosition, child) {
          return SizedBox(
            height: 90,
            width: screenWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // LAPISAN 1: Bar Biru dengan lekukan
                Positioned(
                  bottom: 0,
                  child: ClipPath(
                    clipper: NavBarClipper(
                      position: animatedPosition,
                      holeRadius: holeRadius,
                    ),
                    child: Container(
                      height: navBarHeight,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // LAPISAN 2: Ikon & Teks
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: navBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(navItems.length, (index) {
                        return _buildNavItem(
                          icon: navItems[index]['icon'],
                          label: navItems[index]['label'],
                          index: index,
                          isSelected:
                              controller.selectedNavIndex.value == index,
                        );
                      }),
                    ),
                  ),
                ),
                // LAPISAN 3: Lingkaran Aktif
                Positioned(
                  left: animatedPosition - (circleDiameter / 2),
                  top: -15,
                  child: Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2A65D8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(navItems[controller.selectedNavIndex.value]['icon'],
                        color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildNavItem(
      {required IconData icon,
      required String label,
      required int index,
      required bool isSelected}) {
    final screenWidth = Get.width;
    final double itemWidth = screenWidth / 4;
    final color = isSelected ? Colors.transparent : Colors.white.withOpacity(0.7);

    return GestureDetector(
      onTap: () => controller.changeNavIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        height: 65.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- KELAS "RESEP RAHASIA" NAVBARCLIPPER SEKARANG ADA DI SINI ---
class NavBarClipper extends CustomClipper<Path> {
  NavBarClipper({required this.position, required this.holeRadius});

  final double position;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    const rounding = 15.0; // Radius untuk sudut yang halus

    path.moveTo(0, rounding);
    path.quadraticBezierTo(0, 0, rounding, 0);
    path.lineTo(position - holeRadius - rounding, 0);
    path.quadraticBezierTo(
        position - holeRadius, 0, position - holeRadius, rounding);
    path.arcToPoint(
      Offset(position + holeRadius, rounding),
      radius: Radius.circular(holeRadius),
      clockwise: false,
    );
    path.quadraticBezierTo(
        position + holeRadius, 0, position + holeRadius + rounding, 0);
    path.lineTo(size.width - rounding, 0);
    path.quadraticBezierTo(size.width, 0, size.width, rounding);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

