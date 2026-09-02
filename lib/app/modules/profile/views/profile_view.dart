import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/logout_confirmation_dialog.dart';
import '../../../widgets/science_shimmer.dart';

import '../controllers/profile_controller.dart';
import 'badge_view.dart';
import '../../profile_learning/controllers/profile_learning_controller.dart';
import '../../edit_profile_learning/bindings/edit_profile_learning_binding.dart';
import '../../edit_profile_learning/views/edit_profile_learning_view.dart';
import '../../milestone/controllers/milestone_controller.dart';
import '../../milestone/views/milestone_collection_view.dart';
import '../../milestone/widgets/milestone_avatar_frame.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);
const Color _border = Color(0xFFE2E8F0);

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileLearningController controller;
  late final MilestoneController milestoneController;

  ProfileController? get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : null;

  @override
  void initState() {
    super.initState();

    milestoneController = MilestoneController.ensureRegistered();

    if (Get.isRegistered<ProfileLearningController>()) {
      controller = Get.find<ProfileLearningController>();
    } else {
      controller = Get.put<ProfileLearningController>(
        ProfileLearningController(),
      );
    }

    Future<void>.microtask(_refreshProfileAndMilestone);
  }

  Future<void> _refreshProfileAndMilestone() async {
    await controller.loadProfile();
    await milestoneController.loadMilestones();
  }

  Future<void> _openEditProfileLearning() async {
    final bool? updated = await Get.to<bool>(
      () => const EditProfileLearningView(),
      binding: EditProfileLearningBinding(),
    );

    if (updated == true) {
      await _refreshProfileAndMilestone();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          'Profil Pembelajaran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17.5,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _textDark,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refreshProfileAndMilestone,
            icon: const Icon(Icons.refresh_rounded, color: _textDark),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _primaryBlue,
        backgroundColor: Colors.white,
        onRefresh: _refreshProfileAndMilestone,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: <Widget>[
            Obx(
              () => _HeroCard(
                name: controller.userName.value,
                email: controller.userEmail.value,
                avatar: controller.avatarPath.value,
                frameId: milestoneController.equippedFrame.value?.id,
                level: controller.currentLearningLevel.value,
                onEdit: _openEditProfileLearning,
              ),
            ),
            Obx(
              () =>
                  controller.errorMessage.value.isNotEmpty
                      ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ErrorCard(
                          message: controller.errorMessage.value,
                          onRetry: _refreshProfileAndMilestone,
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
            Obx(() {
              // Mengambil data XP riil
              final int currentXp = controller.totalXp.value;
              final int targetXp = milestoneController.progressTargetXp.value;
              
              // Mencegah error pembagian nol jika target 0
              final double xpProgress = targetXp > 0 
                  ? (currentXp / targetXp).clamp(0.0, 1.0) 
                  : 1.0;

              return _ProgressCard(
                level: controller.currentLearningLevel.value,
                currentXp: currentXp,
                targetXp: targetXp,
                progress: xpProgress,
              );
            }),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Obx(
              () => _WeeklyStreakCard(
                streak: controller.dailyStreak.value,
                todayStatus: controller.todayActivityStatus.value,
                days: controller.weeklyActivity,
              ),
            ),
            const SizedBox(height: 14),
            _MilestonePreviewCard(
              controller: milestoneController,
              onTap: () async {
                await Get.to<void>(() => const MilestoneCollectionView());
                await milestoneController.loadMilestones();
              },
              
            ),
            const SizedBox(height: 12),

            const _GachaPreviewCard(),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Perjalanan Level',
              subtitle:
                  'Level dibuka dari penyelesaian modul pembelajaran sains.',
            ),
            const SizedBox(height: 11),
            Obx(
              () =>
                  controller.isLoading.value
                      ? const _LoadingCard()
                      : Column(
                        children:
                            controller.levelSummaries
                                .map(
                                  (LearningLevelSummary item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _LevelCard(
                                      summary: item,
                                      current:
                                          item.level ==
                                          controller.currentLearningLevel.value,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _BadgeCard(
                owned: controller.ownedBadgeCount.value,
                total: controller.totalBadgeCount.value,
                onTap:
                    profileController == null
                        ? null
                        : () => Get.to<void>(() => const BadgeView()),
              ),
            ),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Akun & Bantuan',
              subtitle: 'Kelola profil, preferensi, dan pusat bantuan.',
            ),
            const SizedBox(height: 11),
            _AccountCard(
              controller: profileController,
              onEditProfile: _openEditProfileLearning,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 1. HERO PROFILE CARD (MATCHING NOTIFICATION & EDIT PROFILE PALETTE)
// =============================================================================
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.name,
    required this.email,
    required this.avatar,
    required this.frameId,
    required this.level,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String avatar;
  final String? frameId;
  final int level;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          MilestoneAvatarFrame(
            frameId: frameId,
            size: 88,
            child: _Avatar(path: avatar),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFDCE9FF),
                      fontSize: 11.5,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF38BDF8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Level Pembelajaran $level',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            Material(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onEdit,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// 2. PROGRESS LEVEL CARD
// =============================================================================
// =============================================================================
// 2. PROGRESS LEVEL CARD (XP BASED)
// =============================================================================
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.level,
    required this.currentXp,
    required this.targetXp,
    required this.progress,
  });

  final int level;
  final int currentXp;
  final int targetXp;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Progres Level $level',
                  style: GoogleFonts.poppins(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  targetXp > 0 ? '$currentXp / $targetXp XP' : 'Maksimal',
                  style: GoogleFonts.poppins(
                    color: _primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: _warning, // Warna kuning XP agar senada dengan tema energi
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            targetXp > currentXp
                ? 'Kumpulkan ${targetXp - currentXp} XP lagi untuk naik ke level selanjutnya!'
                : 'Luar biasa! Kamu sudah menuntaskan semua target level.',
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================================
// 3. STATS GRID
// =============================================================================
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.completed,
    required this.total,
    required this.xp,
    required this.badges,
    required this.tickets,
    // HAPUS required this.shards
  });

  final int completed;
  final int total;
  final int xp;
  final int badges;
  final int tickets;
  // HAPUS final int shards;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: <Widget>[
        _Stat(
          icon: Icons.menu_book_rounded,
          color: _primaryBlue,
          value: '$completed/$total',
          label: 'Modul',
        ),
        _Stat(
          icon: Icons.bolt_rounded,
          color: _warning,
          value: '$xp',
          label: 'Total XP',
        ),
        _Stat(
          icon: Icons.workspace_premium_rounded,
          color: const Color(0xFF8B5CF6),
          value: '$badges',
          label: 'Badge',
        ),
        _Stat(
          icon: Icons.local_activity_rounded,
          color: const Color(0xFFEC4899),
          value: '$tickets',
          label: 'Tiket Gacha',
        ),
        // KOTAK _STAT SERPIHAN SUDAH DIHAPUS DARI SINI
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}



// =============================================================================
// 4. WEEKLY STREAK CARD
// =============================================================================
class _WeeklyStreakCard extends StatelessWidget {
  const _WeeklyStreakCard({
    required this.streak,
    required this.todayStatus,
    required this.days,
  });

  final int streak;
  final String todayStatus;
  final List<LearningStreakDay> days;

  @override
  Widget build(BuildContext context) {
    final bool active = todayStatus == 'active';
    final bool loginOnly = todayStatus == 'login';

    final Color statusColor =
        active
            ? _success
            : loginOnly
            ? _warning
            : _textMuted;

    final String subtitle =
        active
            ? 'Mantap! Kamu sudah aktif belajar hari ini.'
            : loginOnly
            ? 'Login sudah tercatat. Selesaikan materi untuk streak hijau.'
            : 'Login untuk mempertahankan streak belajarmu.';

    final String mascotAsset =
        active
            ? 'assets/fire.png'
            : loginOnly
            ? 'assets/ice.png'
            : 'assets/chara_login.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: statusColor,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streak Hari Streak',
                      style: GoogleFonts.poppins(
                        color: _textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List<Widget>.generate(7, (int index) {
                    final LearningStreakDay day =
                        index < days.length
                            ? days[index]
                            : LearningStreakDay(
                              label:
                                  const <String>[
                                    'S',
                                    'S',
                                    'R',
                                    'K',
                                    'J',
                                    'S',
                                    'M',
                                  ][index],
                              dayName: '',
                              date: '',
                              status: 'none',
                              isToday: false,
                              isFuture: false,
                            );

                    return _StreakDayBubble(day: day);
                  }),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 11,
                  runSpacing: 5,
                  children: <Widget>[
                    _StreakLegend(color: _warning, label: 'Login'),
                    _StreakLegend(color: _success, label: 'Aktif belajar'),
                    _StreakLegend(
                      color: Color(0xFFCBD5E1),
                      label: 'Belum login',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            mascotAsset,
            width: 66,
            height: 78,
            fit: BoxFit.contain,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return Icon(
                active
                    ? Icons.whatshot_rounded
                    : loginOnly
                    ? Icons.sentiment_satisfied_alt_rounded
                    : Icons.sentiment_neutral_rounded,
                size: 50,
                color: statusColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StreakDayBubble extends StatelessWidget {
  const _StreakDayBubble({required this.day});

  final LearningStreakDay day;

  @override
  Widget build(BuildContext context) {
    final Color fillColor =
        day.isActive
            ? _success
            : day.isLoginOnly
            ? _warning
            : Colors.transparent;

    final Color borderColor =
        day.isActive
            ? _success
            : day.isLoginOnly
            ? _warning
            : day.isToday
            ? _primaryBlue
            : const Color(0xFFCBD5E1);

    final Color textColor =
        day.hasActivity
            ? Colors.white
            : day.isToday
            ? _primaryBlue
            : _textMuted;

    return Tooltip(
      message:
          day.isActive
              ? '${day.dayName}: aktif belajar'
              : day.isLoginOnly
              ? '${day.dayName}: login saja'
              : '${day.dayName}: belum login',
      child: Column(
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: day.isToday ? 2.2 : 1.8,
              ),
            ),
            child:
                day.isActive
                    ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                    : Text(
                      day.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            day.label,
            style: TextStyle(
              color: day.isToday ? _primaryBlue : _textMuted,
              fontSize: 8.5,
              fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakLegend extends StatelessWidget {
  const _StreakLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 9.5),
        ),
      ],
    );
  }
}

// =============================================================================
// 5. MILESTONE PREVIEW CARD
// =============================================================================
class _MilestonePreviewCard extends StatelessWidget {
  const _MilestonePreviewCard({required this.controller, required this.onTap});

  final MilestoneController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final next = controller.nextReward.value;
      final bool hasData = controller.totalCount.value > 0;

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[_darkNavy, _primaryBlue],
                      ),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Milestone & Koleksi',
                          style: GoogleFonts.poppins(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasData
                              ? '${controller.unlockedCount.value} / ${controller.totalCount.value} item terbuka'
                              : 'Lihat pencapaian dan koleksi bingkai',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: _textMuted),
                ],
              ),
              if (hasData) ...<Widget>[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: next == null ? 1 : controller.progressToNext.value,
                    minHeight: 8,
                    color: _primaryBlue,
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        next == null
                            ? 'Semua milestone terbuka'
                            : 'Berikutnya: ${next.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: _textDark,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${controller.currentXp.value} XP',
                      style: GoogleFonts.poppins(
                        color: _primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

// =============================================================================
// 6. LEVEL JOURNEY CARD
// =============================================================================
class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.summary, required this.current});

  final LearningLevelSummary summary;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color color =
        summary.isCompleted
            ? _success
            : summary.isUnlocked
            ? _primaryBlue
            : _textMuted;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: current ? _primaryBlue : _border,
          width: current ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              summary.isCompleted
                  ? Icons.check_circle_rounded
                  : summary.isUnlocked
                  ? Icons.science_rounded
                  : Icons.lock_outline_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        summary.title,
                        style: GoogleFonts.poppins(
                          color: _textDark,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      summary.status,
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  summary.totalModules == 0
                      ? 'Belum ada modul'
                      : '${summary.completedModules}/${summary.totalModules} modul selesai',
                  style: GoogleFonts.plusJakartaSans(
                    color: _textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: summary.progress,
                    minHeight: 6,
                    color: color,
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 7. BADGE CARD
// =============================================================================
class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.owned,
    required this.total,
    required this.onTap,
  });

  final int owned;
  final int total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.workspace_premium_rounded,
            color: _warning,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              total > 0
                  ? '$owned dari $total badge sudah dimiliki.'
                  : '$owned badge sudah dimiliki.',
              style: GoogleFonts.poppins(
                color: _textDark,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (onTap != null)
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _warning,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Lihat'),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// 8. ACCOUNT CARD
// =============================================================================
class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.controller, required this.onEditProfile});

  final ProfileController? controller;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          
          _AccountItem(
            icon: Icons.edit_outlined,
            label: 'Edit Profil Pembelajaran',
            onTap: onEditProfile,
          ),
          const Divider(height: 1, color: _border),
          _AccountItem(
            icon: Icons.notifications_outlined,
            label: 'Pusat Notifikasi',
            onTap: controller!.goToNotifications,
          ),
          const Divider(height: 1, color: _border),
          _AccountItem(
            icon: Icons.quiz_outlined,
            label: 'FAQ',
            onTap: controller!.goToFaq,
          ),
          const Divider(height: 1, color: _border),
          _AccountItem(
            icon: Icons.info_outline_rounded,
            label: 'Tentang ScienceCraft',
            onTap: controller!.goToAboutApp,
          ),
          const Divider(height: 1, color: _border),
          _AccountItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () => showLogoutConfirmation(onConfirm: controller!.logout),
            danger: true,
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final Color color = danger ? const Color(0xFFEF4444) : _textDark;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 13.5,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: _textMuted,
      ),
    );
  }
}

// =============================================================================
// 9. HELPER COMPONENTS
// =============================================================================
class _Avatar extends StatelessWidget {
  const _Avatar({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _AvatarFallback(),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Icon(Icons.person_rounded, color: _textMuted, size: 42),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: _textMuted,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                color: _textDark,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const ProfileLevelShimmer();
  }
}

// =============================================================================
// GACHA PREVIEW CARD (MENCOLOK & MUDAH DI-NOTICE)
// =============================================================================
class _GachaPreviewCard extends StatelessWidget {
  const _GachaPreviewCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(Routes.GACHA),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF2563EB), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Laboratorium Gacha & Kartu',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Koleksi kartu ilmuwan sains dan tukar shards-mu!',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE2E8F0),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
