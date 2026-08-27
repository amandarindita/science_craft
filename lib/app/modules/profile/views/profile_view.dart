import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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

const Color _background = Color(0xFFF4F8FF);
const Color _primary = Color(0xFF2563EB);
const Color _purple = Color(0xFF7C3AED);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _success = Color(0xFF16A34A);
const Color _warning = Color(0xFFF59E0B);

class ProfileView
    extends StatefulWidget {
  const ProfileView({
    super.key,
  });

  @override
  State<ProfileView> createState() =>
      _ProfileViewState();
}

class _ProfileViewState
    extends State<ProfileView> {
  late final ProfileLearningController
      controller;
  late final MilestoneController milestoneController;

  ProfileController? get profileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : null;

  @override
  void initState() {
    super.initState();

    milestoneController =
        MilestoneController.ensureRegistered();

    if (Get.isRegistered<
        ProfileLearningController>()) {
      controller =
          Get.find<ProfileLearningController>();
    } else {
      controller =
          Get.put<ProfileLearningController>(
        ProfileLearningController(),
      );
    }

    // Profile tetap memuat data akademik seperti sebelumnya.
    // Milestone kemudian diambil dari Flask, bukan dihitung dari GetStorage.
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
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          'Profil Pembelajaran',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0.5,
        shadowColor: Colors.black12,
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _refreshProfileAndMilestone,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfileAndMilestone,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              () => controller.errorMessage.value.isNotEmpty
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
            Obx(
              () => _ProgressCard(
                level: controller.currentLearningLevel.value,
                progress: controller.currentLevelProgress.value,
                message: controller.nextLearningMessage,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _StatsGrid(
                completed: controller.completedModules.value,
                total: controller.totalModules.value,
                xp: controller.totalXp.value,
                badges: controller.ownedBadgeCount.value,
              ),
            ),
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
                await Get.to<void>(
                  () => const MilestoneCollectionView(),
                );
                await milestoneController.loadMilestones();
              },
            ),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Perjalanan Level',
              subtitle:
                  'Level dibuka dari penyelesaian modul, bukan dari jumlah XP.',
            ),
            const SizedBox(height: 11),
            Obx(
              () => controller.isLoading.value
                  ? const _LoadingCard()
                  : Column(
                      children: controller.levelSummaries
                          .map(
                            (LearningLevelSummary item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _LevelCard(
                                summary: item,
                                current: item.level ==
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
                onTap: profileController == null
                    ? null
                    : () => Get.to<void>(
                          () => const BadgeView(),
                        ),
              ),
            ),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'Akun & Bantuan',
              subtitle: 'Kelola profil, keamanan akun, dan bantuan aplikasi.',
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


class _MilestonePreviewCard extends StatelessWidget {
  const _MilestonePreviewCard({
    required this.controller,
    required this.onTap,
  });

  final MilestoneController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
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
              border: Border.all(
                color: const Color(0xFFDCE7FA),
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0D0F172A),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color(0xFF2563EB),
                            Color(0xFF7C3AED),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 25,
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
                              color: _text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hasData
                                ? '${controller.unlockedCount.value} / ${controller.totalCount.value} item terbuka'
                                : 'Lihat koleksimu di sini',
                            style: GoogleFonts.inter(
                              color: _muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _muted,
                    ),
                  ],
                ),
                if (hasData) ...<Widget>[
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: next == null
                          ? 1
                          : controller.progressToNext.value,
                      minHeight: 8,
                      color: _primary,
                      backgroundColor: const Color(0xFFE8EEF7),
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
                          style: const TextStyle(
                            color: _text,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.currentXp.value} XP',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

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
          colors: <Color>[
            Color(0xFF1D4ED8),
            Color(0xFF7C3AED),
          ],
        ),
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x262563EB),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          MilestoneAvatarFrame(
            frameId: frameId,
            size: 92,
            child: _Avatar(path: avatar),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                if (email.trim().isNotEmpty) ...<
                    Widget>[
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFDCE9FF),
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0x33FFFFFF),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Level Pembelajaran $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              tooltip: 'Edit profil',
              onPressed: onEdit,
              style: IconButton.styleFrom(
                foregroundColor:
                    Colors.white,
                backgroundColor:
                    const Color(0x26FFFFFF),
              ),
              icon: const Icon(
                Icons.edit_rounded,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.level,
    required this.progress,
    required this.message,
  });

  final int level;
  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final int percent =
        (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.auto_graph_rounded,
                color: _primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Progres Level $level',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: _primary,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              color: _primary,
              backgroundColor:
                  const Color(0xFFE2E8F0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.completed,
    required this.total,
    required this.xp,
    required this.badges,
  });

  final int completed;
  final int total;
  final int xp;
  final int badges;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Stat(
            icon: Icons.menu_book_rounded,
            color: _primary,
            value: '$completed/$total',
            label: 'Modul',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _Stat(
            icon: Icons.bolt_rounded,
            color: _warning,
            value: '$xp',
            label: 'Total XP',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _Stat(
            icon:
                Icons.workspace_premium_rounded,
            color: _purple,
            value: '$badges',
            label: 'Badge',
          ),
        ),
      ],
    );
  }
}

class _WeeklyStreakCard
    extends StatelessWidget {
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
    final bool active =
        todayStatus == 'active';
    final bool loginOnly =
        todayStatus == 'login';

    final Color statusColor = active
        ? _success
        : loginOnly
            ? _warning
            : _muted;

    final String subtitle = active
        ? 'Mantap! Kamu sudah aktif belajar hari ini.'
        : loginOnly
            ? 'Login sudah tercatat. Mulai satu aktivitas agar hari ini menjadi hijau.'
            : 'Login untuk mempertahankan streak belajarmu.';

    final String mascotAsset = active
        ? 'assets/fire.png'
        : loginOnly
            ? 'assets/ice.png'
            : 'assets/chara_login.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons
                          .local_fire_department_rounded,
                      color: statusColor,
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$streak Day Streak',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: List<Widget>.generate(
                    7,
                    (int index) {
                      final LearningStreakDay day =
                          index < days.length
                              ? days[index]
                              : LearningStreakDay(
                                  label: const <
                                      String>[
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

                      return _StreakDayBubble(
                        day: day,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 11),
                const Wrap(
                  spacing: 11,
                  runSpacing: 5,
                  children: <Widget>[
                    _StreakLegend(
                      color: _warning,
                      label: 'Login',
                    ),
                    _StreakLegend(
                      color: _success,
                      label: 'Aktif belajar',
                    ),
                    _StreakLegend(
                      color: Color(
                        0xFFCBD5E1,
                      ),
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
            width: 68,
            height: 82,
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
                        ? Icons
                            .sentiment_satisfied_alt_rounded
                        : Icons
                            .sentiment_neutral_rounded,
                size: 54,
                color: statusColor,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StreakDayBubble
    extends StatelessWidget {
  const _StreakDayBubble({
    required this.day,
  });

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
                    ? _primary
                    : const Color(
                        0xFFCBD5E1,
                      );

    final Color textColor =
        day.hasActivity
            ? Colors.white
            : day.isToday
                ? _primary
                : _muted;

    return Tooltip(
      message: day.isActive
          ? '${day.dayName}: aktif belajar'
          : day.isLoginOnly
              ? '${day.dayName}: login saja'
              : '${day.dayName}: belum login',
      child: Column(
        children: <Widget>[
          Container(
            width: 29,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor,
                width: day.isToday ? 2.5 : 2,
              ),
            ),
            child: day.isActive
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    day.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            day.label,
            style: TextStyle(
              color: day.isToday
                  ? _primary
                  : _muted,
              fontSize: 8,
              fontWeight: day.isToday
                  ? FontWeight.w900
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakLegend
    extends StatelessWidget {
  const _StreakLegend({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
          ),
        ),
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 29),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
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

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.summary,
    required this.current,
  });

  final LearningLevelSummary summary;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color color =
        summary.isCompleted
            ? _success
            : summary.isUnlocked
                ? _primary
                : _muted;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: current
              ? _primary
              : const Color(0xFFE2E8F0),
          width: current ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.11,
              ),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Icon(
              summary.isCompleted
                  ? Icons
                      .check_circle_rounded
                  : summary.isUnlocked
                      ? Icons
                          .science_rounded
                      : Icons.lock_rounded,
              color: color,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        summary.title,
                        style:
                            const TextStyle(
                          color: _text,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                    Text(
                      summary.status,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  summary.totalModules == 0
                      ? 'Belum ada modul'
                      : '${summary.completedModules}/${summary.totalModules} modul selesai',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: summary.progress,
                  minHeight: 7,
                  color: color,
                  backgroundColor:
                      const Color(
                    0xFFE2E8F0,
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.workspace_premium_rounded,
            color: _warning,
            size: 38,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              total > 0
                  ? '$owned dari $total badge sudah dimiliki.'
                  : '$owned badge sudah dimiliki.',
              style: const TextStyle(
                color: _text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (onTap != null)
            FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: _warning,
                foregroundColor:
                    Colors.white,
              ),
              child: const Text('Lihat'),
            ),
        ],
      ),
    );
  }
}


class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.controller,
    required this.onEditProfile,
  });

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
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          _AccountItem(
            icon: Icons.edit_rounded,
            label: 'Edit Profil Pembelajaran',
            onTap: onEditProfile,
          ),
          const Divider(height: 1),
          _AccountItem(
            icon:
                Icons.notifications_outlined,
            label: 'Notifikasi',
            onTap:
                controller!.goToNotifications,
          ),
          const Divider(height: 1),
          _AccountItem(
            icon: Icons.quiz_outlined,
            label: 'FAQ',
            onTap: controller!.goToFaq,
          ),
          const Divider(height: 1),
          _AccountItem(
            icon: Icons.info_outline_rounded,
            label: 'Tentang ScienceCraft',
            onTap:
                controller!.goToAboutApp,
          ),
          const Divider(height: 1),
          _AccountItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            onTap: () =>
                showLogoutConfirmation(
              onConfirm: controller!.logout,
            ),
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
    final Color color =
        danger
            ? const Color(0xFFDC2626)
            : _text;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 15,
        color: _muted,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const _AvatarFallback(),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: const Icon(
        Icons.person_rounded,
        color: _muted,
        size: 46,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: _muted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: _text,
                fontSize: 11,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
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
