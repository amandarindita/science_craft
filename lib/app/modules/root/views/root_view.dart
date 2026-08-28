import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../root/controllers/root_controler.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _brightBlue = Color(0xFF3B82F6);
const Color _deepBlue = Color(0xFF1D4ED8);

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar item navigasi
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.science_outlined, 'label': 'Lab'},
      {'icon': Icons.menu_book_rounded, 'label': 'Materi'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background pattern
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pattern.png'),
                scale: 1.0,
                repeat: ImageRepeat.repeat,
                opacity: 0.05,
              ),
              color: _bg,
            ),
          ),

          // Halaman Utama
          Obx(() => controller.currentPage),

          // Tombol Chatbot AI
          _buildFloatingChatButton(),

          // Bottom Navigation Bar Custom (Terang & Segar)
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
          opacity: controller.selectedNavIndex.value == 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: controller.selectedNavIndex.value != 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 90.0, right: 20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _primaryBlue,
                        _brightBlue,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () => controller.goToChatbot(),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  // --- WIDGET CUSTOM NAVIGATION BAR (TERANG & MODERN) ---
  Widget _buildCustomBottomNavBar(
      BuildContext context, List<Map<String, dynamic>> navItems) {
    const double navBarHeight = 65.0;
    const double circleDiameter = 58.0;
    const double holeRadius = 34.0;

    return Obx(() {
      final screenWidth = MediaQuery.of(context).size.width;
      final double itemWidth = screenWidth / navItems.length;

      final double beginPosition =
          (itemWidth * controller.previousNavIndex.value) + (itemWidth / 2);
      final double endPosition =
          (itemWidth * controller.selectedNavIndex.value) + (itemWidth / 2);

      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: beginPosition, end: endPosition),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        builder: (context, animatedPosition, child) {
          return SizedBox(
            height: 90,
            width: screenWidth,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // LAPISAN 1: Bar Biru Terang & Segar
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _primaryBlue,
                            _brightBlue,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x3D2563EB),
                            blurRadius: 18,
                            offset: Offset(0, -4),
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
                  top: -14,
                  child: Container(
                    width: circleDiameter,
                    height: circleDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _deepBlue,
                          _primaryBlue,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Icon(
                      navItems[controller.selectedNavIndex.value]['icon'],
                      color: Colors.white,
                      size: 26,
                    ),
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
    final color = isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.88);

    return GestureDetector(
      onTap: () => controller.changeNavIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: itemWidth,
        height: 65.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- NAVBARCLIPPER ---
class NavBarClipper extends CustomClipper<Path> {
  NavBarClipper({required this.position, required this.holeRadius});

  final double position;
  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    const rounding = 15.0;

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