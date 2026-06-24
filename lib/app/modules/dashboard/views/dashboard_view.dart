import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
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

  // =====================================================
  // HEADER: PROFILE & STREAK
  // =====================================================
  Widget _buildHeader(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 130,
      ),
      child: Row(
        children: [
          // Avatar
          Obx(
            () => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: DecorationImage(
                  image: AssetImage(profileController.avatarPath.value),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    print(
                      "Error loading avatar: ${profileController.avatarPath.value}",
                    );
                  },
                ),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nama user
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => Text(
                  'Hai ${profileController.userName.value}! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Text(
                'Siap belajar sains hari ini?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Streak Counter
          Row(
            children: [
              Obx(
                () => Text(
                  '${profileController.dailyStreak.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '🔥',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BODY: KONTEN UTAMA DASHBOARD
  // =====================================================
  Widget _buildBody(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Container Putih Utama
        Container(
          margin: const EdgeInsets.only(top: 100),
          padding: const EdgeInsets.only(
            top: 45,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 0),

              // DAILY QUEST BARU
              _buildDailyQuestSection(),

              const SizedBox(height: 24),

              // Lanjutkan Belajar
              const Text(
                'Lanjutkan Belajar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // List Lanjutkan Belajar
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
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

        // Kartu Tahukah Kamu
        Positioned(
          top: -80,
          left: 20,
          right: 20,
          child: SizedBox(
            height: 215,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background kuning
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  bottom: 0,
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

                // Gambar dekorasi
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/fact_card.png',
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const SizedBox(),
                  ),
                ),

                // Konten teks
                Positioned(
                  bottom: 0,
                  left: 12,
                  right: 12,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() {
                      if (controller.currentFact.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Tahukah Kamu?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            controller.currentFact['desc'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF555555),
                              height: 1.5,
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

  // =====================================================
  // DAILY QUEST SECTION
  // =====================================================
  Widget _buildDailyQuestSection() {
    return Obx(() {
      if (controller.dailyQuests.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          // Header Daily Quest
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Misi Harian 🎯',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200,
                  ),
                ),
                child: Text(
                  'Hadiah: ✨ +${controller.dailyRewardXp.value} XP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Card Daily Quest
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: controller.isAllDailyQuestDone
                    ? Colors.green.shade400
                    : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // List Quest
                ...controller.dailyQuests.map((quest) {
                  return _buildQuestItem(quest);
                }).toList(),

                const SizedBox(height: 14),

                // Tombol Claim Reward
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.canClaimDailyReward
                        ? () => controller.claimDailyReward()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.grey.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      controller.isDailyRewardClaimed.value
                          ? 'Reward Sudah Diklaim'
                          : controller.isAllDailyQuestDone
                              ? 'Ambil Reward +${controller.dailyRewardXp.value} XP'
                              : 'Selesaikan Semua Misi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // =====================================================
  // ITEM DAILY QUEST
  // =====================================================
  Widget _buildQuestItem(Map<String, dynamic> quest) {
    final bool isDone = controller.isQuestDone(quest);
    final String progressText = controller.questProgressText(quest);
    final double progressValue = controller.questProgressValue(quest);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Icon Quest
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: isDone ? Colors.green.shade50 : const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                isDone ? '✅' : '📌',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Text dan progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest['title'] ?? 'Misi Harian',
                  style: TextStyle(
                    color: isDone
                        ? Colors.green.shade700
                        : const Color(0xFF1E3A8A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  quest['desc'] ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? Colors.green : const Color(0xFF4285F4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Angka progress
          Text(
            progressText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPTY HISTORY CARD
  // =====================================================
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
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.rocket_launch_rounded,
              size: 60,
              color: Colors.orangeAccent,
            ),
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

// =====================================================
// WIDGET KARTU MATA PELAJARAN
// Ini masih aku biarin karena ada di file lama kamu.
// Kalau memang tidak dipakai, nanti boleh dihapus.
// =====================================================
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
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}