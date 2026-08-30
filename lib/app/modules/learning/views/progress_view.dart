import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/learning_controller.dart';

const Color _progressPrimary = Color(0xFF2563EB);
const Color _progressPrimaryDark = Color(0xFF1E3A8A);
const Color _progressBackground = Color(0xFFF8FAFC);
const Color _progressText = Color(0xFF1E293B);
const Color _progressMuted = Color(0xFF64748B);
const Color _progressSuccess = Color(0xFF10B981);
const Color _progressWarning = Color(0xFFF59E0B);
const Color _progressPurple = Color(0xFF8B5CF6);
const Color _border = Color(0xFFE2E8F0);

class LearningProgressView extends GetView<LearningController> {
  const LearningProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _progressBackground,
      appBar: AppBar(
        title: Text(
          'Progres Belajar & Pencapaian',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
            color: _progressText,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _progressText,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        actions: <Widget>[
          Obx(
            () => IconButton(
              tooltip: 'Muat ulang data',
              onPressed: controller.isLoadingOverview.value
                  ? null
                  : controller.refreshAllLearningData,
              icon: controller.isLoadingOverview.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _progressPrimary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: _progressText,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: _progressPrimary,
        backgroundColor: Colors.white,
        onRefresh: controller.refreshAllLearningData,
        child: Obx(
          () {
            if (controller.isLoadingOverview.value &&
                controller.learningProgress.value == null) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _progressPrimary,
                ),
              );
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
              children: <Widget>[
                // 1. Overall Hero Progress Card
                _OverallProgressCard(
                  overallProgress: controller.overallProgress,
                  completedModules: controller.completedModuleCount,
                  moduleCount: controller.progressModules.length,
                  totalXp: controller.totalXp,
                  streak: controller.streak,
                  level: controller.gamificationLevel,
                ),
                const SizedBox(height: 16),

                // 2. XP & Rank Progression
                _XpCard(
                  totalXp: controller.totalXp,
                  level: controller.gamificationLevel,
                  progress: controller.xpLevelProgress,
                  xpInLevel: controller.xpInCurrentLevel,
                  xpToNext: controller.xpToNextLevel,
                  streak: controller.streak,
                ),
                const SizedBox(height: 22),

                // 3. Level Milestones
                const _SectionHeader(
                  title: 'Jenjang Level Pembelajaran',
                  subtitle:
                      'Selesaikan modul di setiap level untuk membuka materi level berikutnya.',
                ),
                const SizedBox(height: 12),
                ...controller.levels.map(
                  (level) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _LearningLevelCard(
                      level: level,
                      onOpen: () async {
                        final levelNumber = LearningController.intValue(
                          level['level'],
                        );

                        await controller.selectLevel(levelNumber);

                        if (controller.selectedLevel.value == levelNumber) {
                          Get.back<void>();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 4. Daily Quest Section
                const _SectionHeader(
                  title: 'Misi Harian Sains (Daily Quest)',
                  subtitle:
                      'Selesaikan 3 aktivitas harian dan klaim reward bonus XP.',
                ),
                const SizedBox(height: 12),
                _DailyQuestCard(
                  controller: controller,
                ),
                const SizedBox(height: 22),

                // 5. Badges Carousel Section
                _SectionHeader(
                  title: 'Koleksi Lencana Prestasi',
                  subtitle:
                      '${controller.badges.length} lencana kehormatan telah kamu raih.',
                ),
                const SizedBox(height: 12),
                _BadgesSection(
                  badges: controller.badges,
                ),
                const SizedBox(height: 22),

                // 6. Detailed Module Breakdown
                const _SectionHeader(
                  title: 'Rincian Modul Pembelajaran',
                  subtitle:
                      'Status ketuntasan materi submateri, kuis evaluasi, dan laboratorium virtual.',
                ),
                const SizedBox(height: 12),
                if (controller.progressModules.isEmpty)
                  const _ProgressEmptyCard(
                    message: 'Belum ada modul yang dapat ditampilkan.',
                  )
                else
                  ..._buildModuleGroups(
                    controller.progressModules,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildModuleGroups(
    List<Map<String, dynamic>> modules,
  ) {
    final List<Widget> widgets = <Widget>[];

    for (final int level in <int>[1, 2, 3]) {
      final levelModules = modules
          .where(
            (item) => LearningController.intValue(item['level']) == level,
          )
          .toList();

      if (levelModules.isEmpty) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _progressPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LEVEL $level',
                  style: GoogleFonts.poppins(
                    color: _progressPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: _border,
                ),
              ),
            ],
          ),
        ),
      );

      widgets.addAll(
        levelModules.map(
          (module) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _ModuleProgressCard(
              module: module,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}

// =============================================================================
// 1. OVERALL PROGRESS HERO CARD
// =============================================================================
class _OverallProgressCard extends StatelessWidget {
  const _OverallProgressCard({
    required this.overallProgress,
    required this.completedModules,
    required this.moduleCount,
    required this.totalXp,
    required this.streak,
    required this.level,
  });

  final double overallProgress;
  final int completedModules;
  final int moduleCount;
  final int totalXp;
  final int streak;
  final int level;

  @override
  Widget build(BuildContext context) {
    final int percentage = (overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            _progressPrimaryDark,
            _progressPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _progressPrimaryDark.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CircularProgressIndicator(
                      value: overallProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Center(
                      child: Text(
                        '$percentage%',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Kelulusan Jalur Belajar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedModules dari $moduleCount modul telah tuntas',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFDCE9FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      percentage >= 100
                          ? 'Selamat! Seluruh kurikulum sains telah tuntas.'
                          : 'Lanjutkan modul aktif untuk membuka level berikutnya.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Micro Quick Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _HeroMiniStat(
                  icon: Icons.military_tech_rounded,
                  label: 'Pangkat Level $level',
                  iconColor: const Color(0xFFFDE68A),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _HeroMiniStat(
                  icon: Icons.bolt_rounded,
                  label: '$totalXp XP',
                  iconColor: const Color(0xFFFDE68A),
                ),
                Container(
                  width: 1,
                  height: 18,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                _HeroMiniStat(
                  icon: Icons.local_fire_department_rounded,
                  label: '$streak Hari',
                  iconColor: const Color(0xFFFED7AA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 2. XP & STREAK CARD
// =============================================================================
class _XpCard extends StatelessWidget {
  const _XpCard({
    required this.totalXp,
    required this.level,
    required this.progress,
    required this.xpInLevel,
    required this.xpToNext,
    required this.streak,
  });

  final int totalXp;
  final int level;
  final double progress;
  final int xpInLevel;
  final int xpToNext;
  final int streak;

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
            color: Colors.black.withValues(alpha: 0.025),
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
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _progressWarning,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Pangkat Sains: Tingkat $level',
                      style: GoogleFonts.poppins(
                        color: _progressText,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$totalXp Total XP Terkumpul',
                      style: GoogleFonts.plusJakartaSans(
                        color: _progressMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFF97316),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak Hari',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF9A3412),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '$xpInLevel / 200 XP',
                style: GoogleFonts.plusJakartaSans(
                  color: _progressMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$xpToNext XP menuju Tingkat ${level + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: _progressPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_progressWarning),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. LEARNING LEVEL CARD
// =============================================================================
class _LearningLevelCard extends StatelessWidget {
  const _LearningLevelCard({
    required this.level,
    required this.onOpen,
  });

  final Map<String, dynamic> level;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final int number = LearningController.intValue(level['level']);
    final bool unlocked = LearningController.boolValue(level['is_unlocked']);
    final double progress =
        LearningController.doubleValue(level['progress']).clamp(0.0, 1.0);
    final int moduleCount = LearningController.intValue(level['module_count']);
    final bool isCompleted = progress >= 1.0;

    final String subtitle = number == 1
        ? 'Tingkat Dasar Sains'
        : number == 2
            ? 'Tingkat Menengah Sains'
            : 'Tingkat Mahir Sains';

    final Color cardBorderColor = isCompleted
        ? const Color(0xFFBBF7D0)
        : unlocked
            ? const Color(0xFFBFDBFE)
            : _border;

    final Color badgeBgColor = isCompleted
        ? const Color(0xFFDCFCE7)
        : unlocked
            ? const Color(0xFFEFF6FF)
            : const Color(0xFFF1F5F9);

    final Color iconColor = isCompleted
        ? _progressSuccess
        : unlocked
            ? _progressPrimary
            : _progressMuted;

    final IconData leadingIcon = isCompleted
        ? Icons.check_circle_rounded
        : unlocked
            ? Icons.auto_stories_rounded
            : Icons.lock_rounded;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: unlocked ? onOpen : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cardBorderColor,
              width: isCompleted || unlocked ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? _progressSuccess.withValues(alpha: 0.04)
                    : unlocked
                        ? _progressPrimary.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  leadingIcon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Level $number: $subtitle',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: _progressText,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.plusJakartaSans(
                            color: isCompleted
                                ? _progressSuccess
                                : (unlocked
                                    ? _progressPrimary
                                    : _progressMuted),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted
                          ? 'Semua modul level ini tuntas diselesaikan'
                          : (unlocked
                              ? '$moduleCount modul pembelajaran aktif'
                              : 'Selesaikan seluruh modul pada Level ${number - 1}'),
                      style: GoogleFonts.plusJakartaSans(
                        color: _progressMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? _progressSuccess
                              : (unlocked ? _progressPrimary : _progressMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                unlocked
                    ? Icons.chevron_right_rounded
                    : Icons.lock_outline_rounded,
                color: unlocked ? _progressPrimary : _progressMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. DAILY QUEST CARD
// =============================================================================
class _DailyQuestCard extends StatelessWidget {
  const _DailyQuestCard({
    required this.controller,
  });

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final items = controller.dailyQuestItems;
    final bool claimed = controller.dailyQuestClaimed;
    final bool completed = controller.allDailyQuestsCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Misi harian sedang disiapkan.',
                style: GoogleFonts.plusJakartaSans(
                  color: _progressMuted,
                  fontSize: 12,
                ),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _QuestItem(
                  quest: item,
                ),
              ),
            ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: claimed ||
                        !completed ||
                        controller.isClaimingDailyQuest.value
                    ? null
                    : () async {
                        await controller.claimDailyQuest();
                      },
                icon: controller.isClaimingDailyQuest.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        claimed
                            ? Icons.check_circle_rounded
                            : Icons.redeem_rounded,
                        size: 18,
                      ),
                label: Text(
                  claimed
                      ? 'Hadiah Sudah Diklaim'
                      : completed
                          ? 'Klaim Hadiah ${controller.dailyQuestRewardXp} XP'
                          : 'Selesaikan Semua Misi Harian',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _progressPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _QuestItem extends StatelessWidget {
  const _QuestItem({
    required this.quest,
  });

  final Map<String, dynamic> quest;

  @override
  Widget build(BuildContext context) {
    final bool completed =
        LearningController.boolValue(quest['is_completed']);
    final int progress =
        LearningController.intValue(quest['progress']);
    final int target =
        LearningController.intValue(quest['target'], fallback: 1);

    final String key =
        (quest['quest_key'] ?? quest['id'] ?? '').toString();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: completed
                ? const Color(0xFFECFDF5)
                : const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _questIcon(key),
            color: completed ? _progressSuccess : _progressPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      quest['title']?.toString() ?? _questFallbackTitle(key),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _progressText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    completed ? 'Selesai' : '$progress/$target',
                    style: GoogleFonts.plusJakartaSans(
                      color: completed ? _progressSuccess : _progressMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                (quest['description'] ?? quest['desc'] ?? '').toString(),
                style: GoogleFonts.plusJakartaSans(
                  color: _progressMuted,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: target <= 0
                      ? 0
                      : (progress / target).clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completed ? _progressSuccess : _progressPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _questIcon(String key) {
    switch (key) {
      case 'read_material':
        return Icons.menu_book_rounded;
      case 'do_quiz':
        return Icons.quiz_rounded;
      case 'open_lab':
        return Icons.science_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  String _questFallbackTitle(String key) {
    switch (key) {
      case 'read_material':
        return 'Baca 1 Materi';
      case 'do_quiz':
        return 'Kerjakan 1 Kuis';
      case 'open_lab':
        return 'Buka 1 Simulasi Lab';
      default:
        return 'Aktivitas Belajar';
    }
  }
}

// =============================================================================
// 5. BADGES SECTION
// =============================================================================
class _BadgesSection extends StatelessWidget {
  const _BadgesSection({
    required this.badges,
  });

  final List<Map<String, dynamic>> badges;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const _ProgressEmptyCard(
        message:
            'Belum ada lencana. Selesaikan aktivitas pembelajaran untuk membuka pencapaian baru.',
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final badge = badges[index];
          final String name = badge['name']?.toString() ?? 'Badge';

          return Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFDE68A)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.asset(
                    LearningController.badgeImagePath(name),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.military_tech_rounded,
                        color: _progressWarning,
                        size: 44,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: _progressText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    badge['description']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: _progressMuted,
                      fontSize: 10,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// 6. MODULE PROGRESS CARD
// =============================================================================
class _ModuleProgressCard extends StatelessWidget {
  const _ModuleProgressCard({
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    final double progress =
        LearningController.doubleValue(module['progress']).clamp(0.0, 1.0);
    final bool completed =
        LearningController.boolValue(module['module_completed']);
    final bool quizRequired =
        LearningController.boolValue(module['quiz_required']);
    final bool labRequired =
        LearningController.boolValue(module['lab_required']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? const Color(0xFFA7F3D0) : _border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  module['title']?.toString() ?? 'Modul',
                  style: GoogleFonts.poppins(
                    color: _progressText,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: GoogleFonts.plusJakartaSans(
                  color: completed ? _progressSuccess : _progressPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                completed ? _progressSuccess : _progressPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              _StatusChip(
                label: 'Materi',
                completed:
                    LearningController.boolValue(module['learning_completed']),
                required: true,
              ),
              _StatusChip(
                label: 'Kuis',
                completed: LearningController.boolValue(module['quiz_passed']),
                required: quizRequired,
              ),
              _StatusChip(
                label: 'Lab',
                completed: LearningController.boolValue(module['lab_completed']),
                required: labRequired,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.completed,
    required this.required,
  });

  final String label;
  final bool completed;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final Color color = !required
        ? _progressMuted
        : completed
            ? _progressSuccess
            : _progressWarning;

    final String status = !required
        ? 'Opsional'
        : completed
            ? 'Selesai'
            : 'Belum';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            !required
                ? Icons.remove_circle_outline_rounded
                : completed
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: $status',
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

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
            color: _progressText,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: _progressMuted,
            fontSize: 11.5,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ProgressEmptyCard extends StatelessWidget {
  const _ProgressEmptyCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: _progressMuted,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }
}
