import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/learning_controller.dart';

const Color _progressPrimary = Color(0xFF2563EB);
const Color _progressPrimaryDark = Color(0xFF1E3A8A);
const Color _progressBackground = Color(0xFFF5F8FF);
const Color _progressText = Color(0xFF172033);
const Color _progressMuted = Color(0xFF64748B);
const Color _progressSuccess = Color(0xFF16A34A);
const Color _progressWarning = Color(0xFFF59E0B);
const Color _progressPurple = Color(0xFF7C3AED);

class LearningProgressView
    extends GetView<LearningController> {
  const LearningProgressView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _progressBackground,
      appBar: AppBar(
        title: const Text('Progress Saya'),
        backgroundColor: Colors.white,
        foregroundColor: _progressText,
        elevation: 0,
        actions: <Widget>[
          Obx(
            () => IconButton(
              tooltip: 'Muat ulang',
              onPressed:
                  controller.isLoadingOverview.value
                      ? null
                      : controller.refreshAllLearningData,
              icon: controller.isLoadingOverview.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                    ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh:
            controller.refreshAllLearningData,
        child: Obx(
          () {
            if (controller.isLoadingOverview.value &&
                controller.learningProgress.value ==
                    null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                36,
              ),
              children: <Widget>[
                _OverallProgressCard(
                  overallProgress:
                      controller.overallProgress,
                  completedModules:
                      controller.completedModuleCount,
                  moduleCount:
                      controller.progressModules.length,
                ),
                const SizedBox(height: 16),
                _XpCard(
                  totalXp: controller.totalXp,
                  level:
                      controller.gamificationLevel,
                  progress:
                      controller.xpLevelProgress,
                  xpInLevel:
                      controller.xpInCurrentLevel,
                  xpToNext:
                      controller.xpToNextLevel,
                  streak: controller.streak,
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Level Belajar',
                  subtitle:
                      'Level 2 dan 3 terbuka setelah level sebelumnya selesai.',
                ),
                const SizedBox(height: 12),
                ...controller.levels.map(
                  (level) => Padding(
                    padding:
                        const EdgeInsets.only(
                      bottom: 11,
                    ),
                    child: _LearningLevelCard(
                      level: level,
                      onOpen: () async {
                        final levelNumber =
                            LearningController
                                .intValue(
                          level['level'],
                        );

                        await controller.selectLevel(
                          levelNumber,
                        );

                        if (controller
                                .selectedLevel
                                .value ==
                            levelNumber) {
                          Get.back<void>();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const _SectionHeader(
                  title: 'Daily Quest',
                  subtitle:
                      'Selesaikan tiga aktivitas inti dan klaim 50 XP.',
                ),
                const SizedBox(height: 12),
                _DailyQuestCard(
                  controller: controller,
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Badge',
                  subtitle:
                      '${controller.badges.length} pencapaian telah terbuka.',
                ),
                const SizedBox(height: 12),
                _BadgesSection(
                  badges: controller.badges,
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Progress Modul',
                  subtitle:
                      'Rincian materi, kuis, dan laboratorium setiap modul.',
                ),
                const SizedBox(height: 12),
                if (controller.progressModules.isEmpty)
                  const _ProgressEmptyCard(
                    message:
                        'Belum ada modul yang dapat ditampilkan.',
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
            (item) =>
                LearningController.intValue(
                  item['level'],
                ) ==
                level,
          )
          .toList();

      if (levelModules.isEmpty) {
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(
            top: 4,
            bottom: 9,
          ),
          child: Text(
            'LEVEL $level',
            style: const TextStyle(
              color: _progressPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      );

      widgets.addAll(
        levelModules.map(
          (module) => Padding(
            padding: const EdgeInsets.only(
              bottom: 11,
            ),
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

class _OverallProgressCard
    extends StatelessWidget {
  const _OverallProgressCard({
    required this.overallProgress,
    required this.completedModules,
    required this.moduleCount,
  });

  final double overallProgress;
  final int completedModules;
  final int moduleCount;

  @override
  Widget build(BuildContext context) {
    final int percentage =
        (overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            _progressPrimaryDark,
            _progressPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _progressPrimary.withValues(
              alpha: 0.23,
            ),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 102,
            height: 102,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CircularProgressIndicator(
                  value: overallProgress,
                  strokeWidth: 10,
                  backgroundColor:
                      Colors.white.withValues(
                    alpha: 0.20,
                  ),
                  valueColor:
                      const AlwaysStoppedAnimation<
                          Color>(
                    Colors.white,
                  ),
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Progress Belajar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$completedModules dari $moduleCount modul selesai',
                  style: const TextStyle(
                    color: Color(0xFFDCE9FF),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  percentage >= 100
                      ? 'Seluruh jalur belajar telah selesai.'
                      : 'Lanjutkan modul untuk membuka level berikutnya.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: _progressWarning,
                  size: 31,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Level XP $level',
                      style: const TextStyle(
                        color: _progressText,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$totalXp XP total',
                      style: const TextStyle(
                        color: _progressMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFF97316),
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$streak hari',
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: <Widget>[
              Text(
                '$xpInLevel / 200 XP',
                style: const TextStyle(
                  color: _progressMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$xpToNext XP lagi',
                style: const TextStyle(
                  color: _progressPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 9,
            borderRadius:
                BorderRadius.circular(20),
            backgroundColor:
                const Color(0xFFE2E8F0),
            valueColor:
                const AlwaysStoppedAnimation<
                    Color>(
              _progressWarning,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningLevelCard
    extends StatelessWidget {
  const _LearningLevelCard({
    required this.level,
    required this.onOpen,
  });

  final Map<String, dynamic> level;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final int number =
        LearningController.intValue(
      level['level'],
    );
    final bool unlocked =
        LearningController.boolValue(
      level['is_unlocked'],
    );
    final double progress =
        LearningController.doubleValue(
      level['progress'],
    ).clamp(0.0, 1.0);
    final int moduleCount =
        LearningController.intValue(
      level['module_count'],
    );

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(19),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(19),
        onTap: unlocked ? onOpen : null,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: unlocked
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(0xFFEAF1FF)
                      : const Color(0xFFF1F5F9),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  unlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_rounded,
                  color: unlocked
                      ? _progressPrimary
                      : _progressMuted,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          'Level Belajar $number',
                          style: const TextStyle(
                            color: _progressText,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: unlocked
                                ? _progressPrimary
                                : _progressMuted,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      unlocked
                          ? '$moduleCount modul tersedia'
                          : 'Selesaikan Level ${number - 1}',
                      style: const TextStyle(
                        color: _progressMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      borderRadius:
                          BorderRadius.circular(20),
                      backgroundColor:
                          const Color(0xFFE2E8F0),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        unlocked
                            ? _progressPrimary
                            : _progressMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                unlocked
                    ? Icons.chevron_right_rounded
                    : Icons.lock_rounded,
                color: unlocked
                    ? _progressPrimary
                    : _progressMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyQuestCard
    extends StatelessWidget {
  const _DailyQuestCard({
    required this.controller,
  });

  final LearningController controller;

  @override
  Widget build(BuildContext context) {
    final items =
        controller.dailyQuestItems;
    final bool claimed =
        controller.dailyQuestClaimed;
    final bool completed =
        controller.allDailyQuestsCompleted;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: <Widget>[
          if (items.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Text(
                'Daily Quest belum tersedia.',
                style: TextStyle(
                  color: _progressMuted,
                ),
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 11,
                ),
                child: _QuestItem(
                  quest: item,
                ),
              ),
            ),
          const SizedBox(height: 3),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => FilledButton.icon(
                onPressed:
                    claimed ||
                            !completed ||
                            controller
                                .isClaimingDailyQuest
                                .value
                        ? null
                        : () async {
                            await controller
                                .claimDailyQuest();
                          },
                icon: controller
                        .isClaimingDailyQuest
                        .value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        claimed
                            ? Icons
                                .check_circle_rounded
                            : Icons
                                .redeem_rounded,
                      ),
                label: Text(
                  claimed
                      ? 'Reward Sudah Diklaim'
                      : completed
                          ? 'Klaim ${controller.dailyQuestRewardXp} XP'
                          : 'Selesaikan Semua Quest',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _progressPurple,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 14,
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
        LearningController.boolValue(
      quest['is_completed'],
    );
    final int progress =
        LearningController.intValue(
      quest['progress'],
    );
    final int target =
        LearningController.intValue(
      quest['target'],
      fallback: 1,
    );

    final String key =
        (quest['quest_key'] ??
                quest['id'] ??
                '')
            .toString();

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: completed
                ? const Color(0xFFE7F8EE)
                : const Color(0xFFF3E8FF),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            _questIcon(key),
            color: completed
                ? _progressSuccess
                : _progressPurple,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                quest['title']?.toString() ??
                    _questFallbackTitle(key),
                style: const TextStyle(
                  color: _progressText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                (quest['description'] ??
                        quest['desc'] ??
                        '')
                    .toString(),
                style: const TextStyle(
                  color: _progressMuted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 7),
              LinearProgressIndicator(
                value: target <= 0
                    ? 0
                    : (progress / target)
                        .clamp(0.0, 1.0),
                minHeight: 5,
                borderRadius:
                    BorderRadius.circular(20),
                backgroundColor:
                    const Color(0xFFE2E8F0),
                valueColor:
                    AlwaysStoppedAnimation<Color>(
                  completed
                      ? _progressSuccess
                      : _progressPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          completed
              ? 'Selesai'
              : '$progress/$target',
          style: TextStyle(
            color: completed
                ? _progressSuccess
                : _progressMuted,
            fontSize: 12,
            fontWeight: FontWeight.w800,
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
            'Belum ada badge. Selesaikan aktivitas pertama untuk membuka pencapaian.',
      );
    }

    return SizedBox(
      height: 174,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 11),
        itemBuilder: (context, index) {
          final badge = badges[index];
          final String name =
              badge['name']?.toString() ??
                  'Badge';

          return Container(
            width: 154,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(19),
              border: Border.all(
                color:
                    const Color(0xFFFDE68A),
              ),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(
                  width: 62,
                  height: 62,
                  child: Image.asset(
                    LearningController
                        .badgeImagePath(name),
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons
                            .emoji_events_rounded,
                        color: _progressWarning,
                        size: 54,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  name,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _progressText,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    badge['description']
                            ?.toString() ??
                        '',
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _progressMuted,
                      fontSize: 10,
                      height: 1.3,
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

class _ModuleProgressCard
    extends StatelessWidget {
  const _ModuleProgressCard({
    required this.module,
  });

  final Map<String, dynamic> module;

  @override
  Widget build(BuildContext context) {
    final double progress =
        LearningController.doubleValue(
      module['progress'],
    ).clamp(0.0, 1.0);
    final bool completed =
        LearningController.boolValue(
      module['module_completed'],
    );

    final bool quizRequired =
        LearningController.boolValue(
      module['quiz_required'],
    );
    final bool labRequired =
        LearningController.boolValue(
      module['lab_required'],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color: completed
              ? const Color(0xFF86EFAC)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  module['title']?.toString() ??
                      'Modul',
                  style: const TextStyle(
                    color: _progressText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: completed
                      ? _progressSuccess
                      : _progressPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius:
                BorderRadius.circular(20),
            backgroundColor:
                const Color(0xFFE2E8F0),
            valueColor:
                AlwaysStoppedAnimation<Color>(
              completed
                  ? _progressSuccess
                  : _progressPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: <Widget>[
              _StatusChip(
                label: 'Materi',
                completed:
                    LearningController.boolValue(
                  module['learning_completed'],
                ),
                required: true,
              ),
              _StatusChip(
                label: 'Kuis',
                completed:
                    LearningController.boolValue(
                  module['quiz_passed'],
                ),
                required: quizRequired,
              ),
              _StatusChip(
                label: 'Lab',
                completed:
                    LearningController.boolValue(
                  module['lab_completed'],
                ),
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
        ? 'Tidak wajib'
        : completed
            ? 'Selesai'
            : 'Belum';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            !required
                ? Icons.remove_circle_outline
                : completed
                    ? Icons.check_circle_rounded
                    : Icons.schedule_rounded,
            color: color,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            '$label: $status',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: _progressText,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _progressMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ProgressEmptyCard
    extends StatelessWidget {
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
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _progressMuted,
          height: 1.45,
        ),
      ),
    );
  }
}
