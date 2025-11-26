import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../widgets/shared_cards.dart'; 
import 'badge_view.dart'; 

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // --- STATS & STREAK BARU ---
          _buildNewStatsSection(), 
          // ---------------------------

          const SizedBox(height: 30),
          _buildBadgesSection(),
          const SizedBox(height: 30),
          _buildHistorySection(),
          const SizedBox(height: 30),
          _buildSettingsSection(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- 1. HEADER (TETAP SAMA) ---
 Widget _buildProfileHeader() {
  return Center(
    child: Column(
      children: [
        // --- BAGIAN AVATAR YANG DIPERBAIKI ---
        Obx(() {
          // Radius 50 berarti diameter (lebar & tinggi) adalah 100
          const double size = 100.0;
          
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200, // Warna dasar jika gambar loading
              border: Border.all(color: Colors.white, width: 2), // Opsional: border putih biar rapi
            ),
            child: ClipOval(
              child: Image.asset(
                controller.avatarPath.value,
                width: size,
                height: size,
                // BoxFit.cover = Gambar di-zoom biar penuh lingkaran (tidak gepeng)
                fit: BoxFit.cover, 
                // Error handling kalau gambar tidak ditemukan
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        }),
        // -------------------------------------

        const SizedBox(height: 12),
        
        // Nama User
        Obx(() => Text(
              controller.userName.value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            )),
            
        const SizedBox(height: 4),
        
        // Level dan Tombol Edit
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
                  controller.userLevel.value,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                )),
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
              onPressed: () => controller.gotoEditProfile(),
            )
          ],
        ),
        
        const SizedBox(height: 12),
        
        // XP Bar (Progress Bar)
        GestureDetector(
          onTap: () => controller.goToLevelBenefits(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Obx(() => LinearProgressIndicator(
                        value: (controller.nextLevelXp.value == 0)
                            ? 0.0
                            : controller.currentXp.value / controller.nextLevelXp.value,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.blueAccent,
                      )),
                ),
                const SizedBox(height: 6),
                Obx(() => Text(
                      '${controller.currentXp.value} / ${controller.nextLevelXp.value} XP',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600),
                    )),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  // --- 2. BAGIAN STATS (Eksperimen + Streak ala Duolingo) ---
  Widget _buildNewStatsSection() {
    return Column(
      children: [
        // KOTAK EKSPERIMEN (Kuning)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD166), 
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Eksperimen Selesai',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.experimentsCompleted.value.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 28),
                      )),
                ],
              ),
              const Text('🔬', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
        
        const SizedBox(height: 16), 

        // KOTAK STREAK (Putih ala Duolingo dengan Gambar Samping)
        _buildDuolingoStreakCard(),
      ],
    );
  }

  // --- WIDGET STREAK ALA DUOLINGO (MODIFIKASI ROW) ---
  Widget _buildDuolingoStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Padding agak dikecilin biar muat gambar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Rata tengah vertikal
        children: [
          // --- BAGIAN KIRI (TEKS & BUBBLES) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Streak
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, 
                        color: Colors.orange, size: 24),
                    const SizedBox(width: 6),
                    Obx(() => Text(
                          "${controller.dailyStreak.value} Day Streak",
                          style: const TextStyle(
                            fontSize: 18, // Font agak kecil dikit biar muat
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 4),
                // 2. Subtitle Motivasi
                Text(
                  "Kamu on fire! Pertahankan 🔥",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 3. Row Bubble Hari
                Obx(() {
                  if (controller.weeklyStreak.isEmpty) {
                    return const LinearProgressIndicator(); // Loading tipis
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.weeklyStreak.map((day) {
                      return _buildDayBubble(
                        day.label,
                        day.isCompleted,
                        isToday: day.isToday
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          // --- SPASI ANTARA KIRI & KANAN ---
          const SizedBox(width: 12),

          // --- BAGIAN KANAN (GAMBAR MASKOT) ---
          // Logika gambar berubah tergantung streak
          Obx(() {
            return _buildMascotImage(controller.dailyStreak.value);
          }),
        ],
      ),
    );
  }

  // Helper untuk memilih gambar maskot
  Widget _buildMascotImage(int streak) {
    String imageAsset;
    
    // LOGIKA GANTI GAMBAR (Contoh)
    // Kamu bisa sesuaikan nama file asset kamu di sini
    if (streak == 0) {
      // Kalau 0, maskot sedih/tidur
      imageAsset = 'assets/chara_login.png'; 
      return const Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.grey);
    } else if (streak >= 7) {
      // Kalau > 7, maskot berapi-api
      imageAsset = 'assets/fire.png';
      return const Icon(Icons.whatshot, size: 60, color: Colors.orange);
    } else {
      // Normal
      imageAsset = 'assets/ice.png';
      return const Icon(Icons.sentiment_very_satisfied, size: 60, color: Colors.green);
    }

    // JIKA SUDAH ADA GAMBAR ASLI, PAKAI INI:
    return Image.asset(imageAsset, height: 70, fit: BoxFit.contain);
  }

  // Widget Helper Bubble Hari (Diperkecil sedikit agar muat)
  Widget _buildDayBubble(String day, bool isCompleted, {bool isToday = false}) {
    Color bgColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade400;
    Widget content = Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 10));

    if (isCompleted) {
      bgColor = Colors.orange;
      borderColor = Colors.orange;
      content = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (isToday) {
      borderColor = Colors.orange;
      textColor = Colors.orange;
      content = Text(day, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 10));
    }

    return Column(
      children: [
        // Hapus label hari atas biar hemat tempat, kan di dalam bubble udh ada (kalau mau)
        // Atau biarkan kecil
        Container(
          width: 28, // Ukuran diperkecil biar muat di Row sebelah gambar
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(child: content),
        ),
        const SizedBox(height: 4),
        Text(day, style: TextStyle(fontSize: 8, color: Colors.grey.shade400)),
      ],
    );
  }

  // --- 3, 4, 5 (BAGIAN LAIN TETAP SAMA) ---
  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Get.to(() => const BadgeView()),
          child: Container(
            height: 80,
            color: Colors.transparent,
            child: Obx(
              () => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.badges.length > 5 ? 5 : controller.badges.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final badge = controller.badges[index];
                  return SizedBox(
                    width: 70,
                    height: 70,
                    child: badge.isOwned
                        ? Image.asset(badge.imagePath)
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ]),
                            child: Opacity(
                              opacity: 0.5,
                              child: Image.asset(badge.imagePath),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('History Belajar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => controller.viewAllHistory(),
              child: const Text('View all', style: TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => ContinueLearningCard(
              title: controller.lastLearnedTitle.value,
              progress: controller.lastLearnedProgress.value,
              iconPath: controller.lastLearnedIcon.value.isEmpty 
                  ? 'assets/chemistry.png' 
                  : controller.lastLearnedIcon.value,
            )),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _SettingsItem(
            icon: Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap: () => controller.goToNotifications()),
        const SizedBox(height: 12),
        _SettingsItem(
            icon: Icons.info_outline,
            label: 'Tentang Science Craft',
            onTap: () => controller.goToAboutApp()),
        const SizedBox(height: 12),
        _SettingsItem(
            icon: Icons.quiz_outlined,
            label: 'FAQ',
            onTap: () => controller.goToFaq()),
        const SizedBox(height: 12),
        _SettingsItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () => controller.logout(),
            isLogout: true),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  const _SettingsItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isLogout ? Colors.red : Colors.black87;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1)
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}