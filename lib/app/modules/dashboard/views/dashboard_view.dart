import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/science_shimmer.dart';
import '../../../models/material_model.dart';
import '../../milestone/controllers/milestone_controller.dart';
import '../../milestone/widgets/milestone_avatar_frame.dart';

// Palette Design System
const Color _background = Color(0xFFF5F8FE);
const Color _text = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _blue = Color(0xFF2563EB);
const Color _blueDark = Color(0xFF1E3A8A);
const Color _green = Color(0xFF16A34A);
const Color _funFactColor = Color(0xFFFFD166);

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardController controller;
  late final ProfileController profileController;
  late final MilestoneController milestoneController;

  @override
  void initState() {
    super.initState();

    controller = Get.find<DashboardController>();
    profileController = Get.find<ProfileController>();
    milestoneController = MilestoneController.ensureRegistered();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onDashboardVisible();
      milestoneController.loadMilestones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _blue,
          onRefresh: () async {
            controller.refreshDashboardData();
            await milestoneController.loadMilestones();
            await Future<void>.delayed(const Duration(milliseconds: 500));
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildHeader(),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. HEADER (AVATAR, GREETING & ANIMATED BURNING STREAK PILL)
  // ===========================================================================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 122),
      child: Row(
        children: <Widget>[
          Obx(
            () => MilestoneAvatarFrame(
              size: 54,
              frameId: milestoneController.equippedFrame.value?.id,
              child: Image.asset(
                profileController.avatarPath.value,
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Container(
                    color: const Color(0xFFEFF6FF),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: _blue,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => Text(
                    'Hai, ${profileController.userName.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: _text,
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Siap belajar sains hari ini?',
                  style: GoogleFonts.plusJakartaSans(
                    color: _muted,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Burning Animated Streak Badge
          Obx(
            () {
              final int streak = controller.userStreak.value;
              final _StreakTier tier = _StreakTier.fromDays(streak);

              return _AnimatedStreakBadge(
                streak: streak,
                tier: tier,
                onTap: () => _showStreakDetailsModal(context, streak, tier),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. BODY SHEET & OVERLAPPING FUN FACT CARD
  // ===========================================================================
  Widget _buildBody() {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 105),
          padding: const EdgeInsets.fromLTRB(20, 90, 20, 100),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildLearningSummary(),
              const SizedBox(height: 25),
              const _SectionTitle(
                title: 'Lanjutkan Belajar',
                subtitle: 'Materi yang sedang aktif kamu pelajari.',
              ),
              const SizedBox(height: 12),
              _buildContinueLearning(),
              const SizedBox(height: 28),
              const _SectionTitle(
                title: 'Misi Harian',
                subtitle:
                    'Selesaikan misi setiap hari untuk mengumpulkan bonus XP.',
              ),
              const SizedBox(height: 12),
              _buildDailyQuest(),
            ],
          ),
        ),

        // Fun Fact Overlapping Hero Card
        Positioned(
          top: -80,
          left: 20,
          right: 20,
          child: _buildFunFact(),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. FUN FACT HERO CARD (TAHUKAH KAMU?)
  // ===========================================================================
  Widget _buildFunFact() {
    return SizedBox(
      height: 255,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // Background Golden Container
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _funFactColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          // Lab Scientist Illustration
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/fact_card.png',
              height: 180,
              fit: BoxFit.contain,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) =>
                  const SizedBox(),
            ),
          ),
          // White Speech / Fact Content Container
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFEF3C7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Obx(
                () {
                  if (controller.currentFact.isEmpty) {
                    return const ScienceShimmer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ShimmerBox(
                            width: 130,
                            height: 15,
                          ),
                          SizedBox(height: 7),
                          ShimmerBox(
                            height: 11,
                          ),
                          SizedBox(height: 5),
                          ShimmerBox(
                            width: 200,
                            height: 11,
                          ),
                        ],
                      ),
                    );
                  }

                  final String desc =
                      controller.currentFact['desc']?.toString() ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.lightbulb_rounded,
                              color: Color(0xFFD97706),
                              size: 15,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Tahukah Kamu?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        desc.isNotEmpty
                            ? desc
                            : 'Eksplorasi konsep sains baru setiap hari untuk membuka wawasanmu!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF334155),
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. LEARNING SUMMARY (LEVEL PEMBELAJARAN)
  // ===========================================================================
  Widget _buildLearningSummary() {
    return Obx(
      () {
        if (controller.isLearningSummaryLoading.value) {
          return const ScienceShimmer(
            child: ShimmerBox(
              height: 135,
              radius: 22,
            ),
          );
        }

        final double progress =
            controller.currentLevelProgress.value.clamp(0.0, 1.0);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(Routes.LEARNING),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFEAF3FF),
                    Color(0xFFF3EEFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFD7E5FF),
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x102563EB),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.route_rounded,
                          color: _blue,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Level Pembelajaran ${controller.currentLearningLevel.value}',
                              style: GoogleFonts.poppins(
                                color: _text,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${controller.currentLevelCompletedModules.value} dari ${controller.currentLevelTotalModules.value} modul level ini selesai',
                              style: GoogleFonts.plusJakartaSans(
                                color: _muted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _blue,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: _blue,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.learningCompletedModules.value}/${controller.learningTotalModules.value} modul keseluruhan',
                        style: GoogleFonts.plusJakartaSans(
                          color: _muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: GoogleFonts.poppins(
                          color: _blueDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 5. LANJUTKAN BELAJAR (CONTINUE LEARNING)
  // ===========================================================================
  Widget _buildContinueLearning() {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const ScienceShimmer(
            child: Column(
              children: <Widget>[
                ShimmerBox(
                  height: 86,
                  radius: 18,
                ),
                SizedBox(height: 10),
                ShimmerBox(
                  height: 86,
                  radius: 18,
                ),
              ],
            ),
          );
        }

        final List<MaterialItem> items = controller.inProgressMaterials;

        if (items.isEmpty) {
          return _EmptyCard(
            icon: Icons.rocket_launch_rounded,
            title: 'Mulai Petualangan Sainsmu',
            message:
                'Kamu belum memulai materi apapun. Yuk, jelajahi materi pertamamu di Jalur Belajar!',
            actionLabel: 'Buka Jalur Belajar',
            onAction: () => Get.toNamed(Routes.LEARNING),
          );
        }

        return Column(
          children: items.map(
            (MaterialItem item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _ContinueLearningCard(
                  title: item.title,
                  category: item.category,
                  iconPath: item.iconPath,
                  progress: item.progress,
                  onTap: () => controller.continueMaterial(item),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  // ===========================================================================
  // 6. DAILY QUEST (PAPAN MISI HARIAN)
  // ===========================================================================
  Widget _buildDailyQuest() {
    return Obx(
      () {
        if (controller.isDailyQuestLoading.value) {
          return const ScienceShimmer(
            child: ShimmerBox(
              height: 280,
              radius: 24,
            ),
          );
        }

        if (controller.dailyQuests.isEmpty) {
          return const _EmptyCard(
            icon: Icons.track_changes_rounded,
            title: 'Misi harian belum tersedia',
            message: 'Coba buka kembali Dashboard beberapa saat lagi.',
          );
        }

        final int completedCount =
            controller.dailyQuests.where(controller.isQuestDone).length;
        final int total = controller.dailyQuests.length;
        final double totalProgress =
            total == 0 ? 0 : (completedCount / total).clamp(0.0, 1.0);

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x142563EB),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF1E3A8A),
                      Color(0xFF2563EB),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.track_changes_rounded,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Target Misi Hari Ini',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Konsistensi harian mempercepat capaianmu',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFDCE9FF),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '+${controller.dailyRewardTickets.value} Tiket',
                            style: GoogleFonts.poppins(
                              color: _blueDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: totalProgress,
                              minHeight: 7,
                              color: const Color(0xFFFDE047),
                              backgroundColor: const Color(0x33FFFFFF),
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '$completedCount/$total',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Quest Items List
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.all(13),
                child: Column(
                  children: <Widget>[
                    ...controller.dailyQuests.map(
                      (Map<String, dynamic> quest) => _QuestTile(
                        quest: quest,
                        isDone: controller.isQuestDone(quest),
                        progress: controller.questProgressValue(quest),
                        progressText: controller.questProgressText(quest),
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: controller.canClaimDailyReward
                            ? controller.claimDailyReward
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          disabledForegroundColor: _muted,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: controller.canClaimDailyReward ? 2 : 0,
                        ),
                        icon: Icon(
                          controller.isDailyRewardClaimed.value
                              ? Icons.check_circle_rounded
                              : Icons.redeem_rounded,
                          size: 18,
                        ),
                        label: Text(
                          controller.isDailyRewardClaimed.value
                              ? 'Reward Sudah Diklaim'
                              : controller.isAllDailyQuestDone
                                  ? 'Klaim Bonus +${controller.dailyRewardTickets.value} Tiket'
                                  : 'Selesaikan Semua Misi',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODAL DETAIL STREAK INTERAKTIF & TESTING PRATINJAU
  // ===========================================================================
  void _showStreakDetailsModal(
    BuildContext context,
    int initialStreak,
    _StreakTier initialTier,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final int streak = controller.userStreak.value;
        final _StreakTier tier = _StreakTier.fromDays(streak);
        final bool isTier7 = streak >= 7 && streak < 14;
        final bool isTier14 = streak >= 14;

        return Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Drag indicator bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Super Spectacular Animated Burning Flame
              _AnimatedBurningFlame(
                size: 104,
                streak: streak,
                tier: tier,
              ),
              const SizedBox(height: 10),

              // Title & Count
              Text(
                '$streak Hari Streak',
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),

              // Tier Level Badge & Milestone Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: tier.bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: tier.borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: tier.glowColor.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isTier7 || isTier14) ...[
                          Icon(
                            isTier14
                                ? Icons.military_tech_rounded
                                : Icons.auto_awesome,
                            size: 14,
                            color: isTier14
                                ? const Color(0xFF9333EA)
                                : const Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          tier.levelName,
                          style: GoogleFonts.poppins(
                            color: tier.textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isTier7 || isTier14) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isTier14
                              ? [
                                  const Color(0xFFFAF5FF),
                                  const Color(0xFFF3E8FF)
                                ]
                              : [
                                  const Color(0xFFFEF08A),
                                  const Color(0xFFFDE047)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isTier14
                              ? const Color(0xFFC084FC)
                              : const Color(0xFFF59E0B),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTier14
                                ? Icons.workspace_premium_rounded
                                : Icons.local_fire_department_rounded,
                            size: 13,
                            color: isTier14
                                ? const Color(0xFF7E22CE)
                                : const Color(0xFFB45309),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isTier14 ? '14+ HARI ULTIMATE!' : '7+ HARI!',
                            style: GoogleFonts.poppins(
                              color: isTier14
                                  ? const Color(0xFF6B21A8)
                                  : const Color(0xFF78350F),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Motivation text
              Text(
                tier.desc,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF475569),
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // 7-Day Activity Indicator
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aktivitas Belajar Pekan Ini',
                          style: GoogleFonts.poppins(
                            color: _text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          tier.isMaxTier
                              ? 'Target Puncak Tercapai! 👑'
                              : 'Target: ${tier.nextGoalDays} Hari',
                          style: GoogleFonts.plusJakartaSans(
                            color: tier.textColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (BuildContext _) {
                        final int todayWeekday = DateTime.now().weekday;
                        final int todayIndex = todayWeekday - 1;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (int index) {
                            const List<String> days = <String>[
                              'Sen',
                              'Sel',
                              'Rab',
                              'Kam',
                              'Jum',
                              'Sab',
                              'Min',
                            ];
                            final bool isToday = index == todayIndex;
                            final bool isActive = streak > 0 &&
                                index <= todayIndex &&
                                index > (todayIndex - streak);

                            return Column(
                              children: <Widget>[
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 250),
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? tier.bgColor
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive
                                          ? tier.borderColor
                                          : (isToday
                                              ? _blue
                                              : const Color(0xFFE2E8F0)),
                                      width:
                                          isToday || isActive ? 1.5 : 1,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: tier.glowColor
                                                  .withValues(alpha: 0.25),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    isActive
                                        ? Icons
                                            .local_fire_department_rounded
                                        : (isToday
                                            ? Icons
                                                .radio_button_unchecked_rounded
                                            : Icons.circle_outlined),
                                    color: isActive
                                        ? tier.iconColor
                                        : (isToday
                                            ? _blue
                                            : const Color(0xFFCBD5E1)),
                                    size: isActive ? 18 : 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  days[index],
                                  style: GoogleFonts.plusJakartaSans(
                                    color: isToday
                                        ? _blueDark
                                        : (isActive ? _text : _muted),
                                    fontSize: 10.5,
                                    fontWeight: isToday || isActive
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action / Close Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.local_fire_department_rounded,
                    size: 18,
                  ),
                  label: Text(
                    'Pertahankan Semangat Belajar!',
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// SOLAR BEAMS PAINTER FOR SUPER FLAME (7+ HARI) & ULTIMATE (14+ HARI)
// =============================================================================

class _SunbeamRaysPainter extends CustomPainter {
  _SunbeamRaysPainter({
    required this.color,
    required this.rotation,
    required this.rayCount,
  });

  final Color color;
  final double rotation;
  final int rayCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2;
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.60),
          color.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final double step = (2 * math.pi) / rayCount;
    final double halfStep = step / 2;

    for (int i = 0; i < rayCount; i++) {
      final double angle = i * step;
      final Path path = Path()
        ..moveTo(0, 0)
        ..lineTo(radius * 0.95 * math.cos(angle - halfStep * 0.45),
            radius * 0.95 * math.sin(angle - halfStep * 0.45))
        ..lineTo(radius * math.cos(angle), radius * math.sin(angle))
        ..lineTo(radius * 0.95 * math.cos(angle + halfStep * 0.45),
            radius * 0.95 * math.sin(angle + halfStep * 0.45))
        ..close();

      canvas.drawPath(path, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunbeamRaysPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.color != color;
  }
}

// =============================================================================
// SPECTACULAR ANIMATED BURNING FLAME & SOLAR FLARE SYSTEM
// =============================================================================

class _AnimatedBurningFlame extends StatefulWidget {
  const _AnimatedBurningFlame({
    required this.size,
    required this.streak,
    required this.tier,
  });

  final double size;
  final int streak;
  final _StreakTier tier;

  @override
  State<_AnimatedBurningFlame> createState() => _AnimatedBurningFlameState();
}

class _AnimatedBurningFlameState extends State<_AnimatedBurningFlame>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _flickerController;
  late final AnimationController _solarRotationController;
  late final AnimationController _emberController;
  late final AnimationController _shockwaveController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..repeat(reverse: true);

    _solarRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _emberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shockwaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flickerController.dispose();
    _solarRotationController.dispose();
    _emberController.dispose();
    _shockwaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streak <= 0) {
      // Inactive / extinguished flame state
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.tier.bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: widget.tier.borderColor, width: 2),
        ),
        child: Icon(
          Icons.local_fire_department_rounded,
          color: widget.tier.iconColor,
          size: widget.size * 0.52,
        ),
      );
    }

    final bool isSuperFlame = widget.streak >= 7;
    final bool isUltimate = widget.streak >= 14;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseController,
        _flickerController,
        _solarRotationController,
        _emberController,
        _shockwaveController,
      ]),
      builder: (BuildContext context, Widget? child) {
        final double pulse = _pulseController.value;
        final double flicker = _flickerController.value;
        final double solarRot = _solarRotationController.value * 2 * math.pi;
        final double emberProg = _emberController.value;
        final double shockwave = _shockwaveController.value;

        final double scale = 0.94 + (pulse * (isUltimate ? 0.16 : 0.12)) + (flicker * 0.05);
        final double rotation = (flicker - 0.5) * (isUltimate ? 0.15 : 0.12);
        final double bobY = (pulse - 0.5) * (isUltimate ? 8.0 : 6.0);

        return SizedBox(
          width: widget.size * (isUltimate ? 1.75 : 1.6),
          height: widget.size * (isUltimate ? 1.75 : 1.6),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. ROTATING SOLAR BEAM RAYS (FOR 7+ AND 14+ DAYS)
              if (isSuperFlame)
                SizedBox(
                  width: widget.size * (isUltimate ? 1.7 : 1.55),
                  height: widget.size * (isUltimate ? 1.7 : 1.55),
                  child: CustomPaint(
                    painter: _SunbeamRaysPainter(
                      color: widget.tier.flameGradient[0],
                      rotation: isUltimate ? -solarRot * 1.3 : solarRot,
                      rayCount: isUltimate ? 16 : 14,
                    ),
                  ),
                ),

              // 2. EXPANDING SHOCKWAVE ENERGY RING
              Transform.scale(
                scale: 0.95 + (shockwave * (isUltimate ? 0.85 : 0.65)),
                child: Container(
                  width: widget.size * 0.9,
                  height: widget.size * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.tier.flameGradient[0]
                          .withValues(alpha: 0.7 * (1.0 - shockwave)),
                      width: (isUltimate ? 3.5 : 2.5) * (1.0 - shockwave),
                    ),
                  ),
                ),
              ),

              // 3. OUTER PULSING FIERY AURA
              Transform.scale(
                scale: 1.0 + (pulse * (isUltimate ? 0.40 : 0.32)),
                child: Container(
                  width: widget.size * 0.98,
                  height: widget.size * 0.98,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.tier.glowColor,
                        blurRadius: isUltimate ? 42 : (isSuperFlame ? 34 : 22),
                        spreadRadius: isUltimate
                            ? 12 + (pulse * 8)
                            : (isSuperFlame ? 8 + (pulse * 6) : 4 + (pulse * 3)),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. FLOATING FIRE PARTICLES & EMBERS
              ...List.generate(isUltimate ? 14 : 10, (int i) {
                final double seed = (i * (isUltimate ? 0.07 : 0.10) + emberProg) % 1.0;
                final double yOffset = (1.0 - seed) * (widget.size * (isUltimate ? 1.15 : 0.95)) -
                    (widget.size * 0.45);
                final double xWobble =
                    ((i % 2 == 0 ? 1 : -1) * (14.0 + (i * 4.5))) *
                        (1.0 - (seed - 0.5).abs() * 2.0);
                final double particleOpacity = (1.0 - seed).clamp(0.0, 1.0) *
                    (seed < 0.2 ? seed / 0.2 : 1.0);
                final double pSize =
                    (4.0 + (i % 3) * 2.5) * (1.0 - seed * 0.45);

                return Positioned(
                  bottom: widget.size * 0.52 - yOffset,
                  left: (widget.size * (isUltimate ? 1.75 : 1.6)) / 2 + xWobble - (pSize / 2),
                  child: Opacity(
                    opacity: particleOpacity.clamp(0.0, 1.0),
                    child: Container(
                      width: pSize,
                      height: pSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.tier.flameGradient[
                            i % widget.tier.flameGradient.length],
                        boxShadow: [
                          BoxShadow(
                            color: widget.tier.flameGradient[0],
                            blurRadius: isUltimate ? 8 : 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // 5. ORBITING DIAMOND STARS / SPARKLES (FOR 7+ & 14+ DAYS)
              if (isSuperFlame)
                ...List.generate(isUltimate ? 6 : 4, (int i) {
                  final int totalStars = isUltimate ? 6 : 4;
                  final double angle = solarRot + (i * ((2 * math.pi) / totalStars));
                  final double orbitRadius = widget.size * (isUltimate ? 0.68 : 0.62) + (pulse * 6);
                  final double starX = orbitRadius * math.cos(angle);
                  final double starY = orbitRadius * math.sin(angle);

                  return Transform.translate(
                    offset: Offset(starX, starY),
                    child: Transform.rotate(
                      angle: -solarRot,
                      child: Icon(
                        isUltimate ? Icons.workspace_premium_rounded : Icons.auto_awesome,
                        color: isUltimate ? const Color(0xFFF0ABFC) : const Color(0xFFFDE047),
                        size: isUltimate ? 20 : 18,
                        shadows: [
                          Shadow(
                            color: isUltimate ? const Color(0xFF9333EA) : const Color(0xFFD97706),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              // 6. CORE FLAME ORB CONTAINER
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.tier.bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.tier.borderColor,
                    width: isUltimate ? 3.5 : (isSuperFlame ? 3.0 : 2.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.tier.glowColor,
                      blurRadius: isUltimate ? 32 : (isSuperFlame ? 24 : 16),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),

              // 7. TRIPLE-LAYER BURNING FLAME (BACK GLOW, MAIN FLAME & INNER WHITE-HOT CORE)
              Transform.translate(
                offset: Offset(0, bobY),
                child: Transform.rotate(
                  angle: rotation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Layer A: Blurred Raging Fire Back-Glow
                      Transform.scale(
                        scale: scale * (isUltimate ? 1.25 : 1.15),
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: widget.tier.flameGradient[0].withValues(alpha: 0.65),
                          size: widget.size * (isUltimate ? 0.70 : 0.64),
                        ),
                      ),
                      // Layer B: Main Molten Gradient Flame
                      Transform.scale(
                        scale: scale,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: widget.tier.flameGradient,
                            ).createShader(bounds);
                          },
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            color: Colors.white,
                            size: widget.size * 0.60,
                          ),
                        ),
                      ),
                      // Layer C: White-Hot Center Flame Core
                      Transform.scale(
                        scale: scale * 0.65,
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white.withValues(alpha: 0.90),
                          size: widget.size * 0.50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// ANIMATED HEADER STREAK BADGE (LIVING BURNING FLAME IN HEADER)
// =============================================================================

class _AnimatedStreakBadge extends StatefulWidget {
  const _AnimatedStreakBadge({
    required this.streak,
    required this.tier,
    required this.onTap,
  });

  final int streak;
  final _StreakTier tier;
  final VoidCallback onTap;

  @override
  State<_AnimatedStreakBadge> createState() => _AnimatedStreakBadgeState();
}

class _AnimatedStreakBadgeState extends State<_AnimatedStreakBadge>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _flickerController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flickerController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.streak > 0;
    final bool isSuper = widget.streak >= 7;
    final bool isUltimate = widget.streak >= 14;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _flickerController,
            _sparkleController,
          ]),
          builder: (BuildContext context, Widget? child) {
            final double pulse = isActive ? _pulseController.value : 0.0;
            final double flicker = isActive ? _flickerController.value : 0.0;
            final double sparkleVal = _sparkleController.value;

            final double flameScale =
                0.95 + (pulse * (isUltimate ? 0.28 : (isSuper ? 0.22 : 0.15))) + (flicker * 0.06);
            final double flameRotation = (flicker - 0.5) * (isUltimate ? 0.18 : (isSuper ? 0.14 : 0.08));
            final double flameBobY = (pulse - 0.5) * (isUltimate ? 4.0 : 3.0);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: widget.tier.bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUltimate
                      ? Color.lerp(const Color(0xFFC084FC), const Color(0xFF9333EA), pulse)!
                      : (isSuper
                          ? Color.lerp(const Color(0xFFFDE047), const Color(0xFFD97706), pulse)!
                          : widget.tier.borderColor),
                  width: isUltimate ? 2.0 : (isSuper ? 1.8 : (isActive ? 1.5 : 1.2)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.tier.glowColor.withValues(
                      alpha: isActive ? (isUltimate ? 0.55 : (isSuper ? 0.45 : 0.25)) * (0.8 + pulse * 0.4) : 0.0,
                    ),
                    blurRadius: 10 + (pulse * (isUltimate ? 16 : (isSuper ? 12 : 8))),
                    spreadRadius: pulse * (isUltimate ? 3.5 : (isSuper ? 2.5 : 1.5)),
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Mini Floating Embers on the Flame
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Floating Tiny Sparks
                        if (isActive)
                          ...List.generate(3, (int i) {
                            final double seed = (i * 0.33 + sparkleVal) % 1.0;
                            final double yOff = (1.0 - seed) * 16.0 - 4.0;
                            final double xOff = ((i % 2 == 0 ? 1 : -1) * 4.0) * (1.0 - seed);
                            final double op = (1.0 - seed).clamp(0.0, 1.0);

                            return Positioned(
                              top: 2 - yOff,
                              left: 11 + xOff - 1.5,
                              child: Opacity(
                                opacity: op,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.tier.flameGradient[0],
                                  ),
                                ),
                              ),
                            );
                          }),

                        // Living Burning Flame Icon
                        Transform.translate(
                          offset: Offset(0, flameBobY),
                          child: Transform.rotate(
                            angle: flameRotation,
                            child: Transform.scale(
                              scale: flameScale,
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: widget.tier.flameGradient,
                                  ).createShader(bounds);
                                },
                                child: const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${widget.streak}',
                    style: GoogleFonts.poppins(
                      color: widget.tier.textColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (isUltimate) ...[
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: (flicker - 0.5) * 0.15,
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF9333EA),
                        size: 14,
                      ),
                    ),
                  ] else if (isSuper) ...[
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: sparkleVal * 2 * math.pi,
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFD97706),
                        size: 13,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGETS & MODELS (TARGET: 2 HARI, 7 HARI, 14 HARI)
// =============================================================================

class _StreakTier {
  const _StreakTier({
    required this.levelName,
    required this.title,
    required this.desc,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.glowColor,
    required this.nextGoalDays,
    required this.flameGradient,
    required this.isMaxTier,
  });

  final String levelName;
  final String title;
  final String desc;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color glowColor;
  final int nextGoalDays;
  final List<Color> flameGradient;
  final bool isMaxTier;

  static _StreakTier fromDays(int days) {
    if (days <= 0) {
      return const _StreakTier(
        levelName: 'Belum Aktif',
        title: 'Mulai Streak Pertamamu',
        desc:
            'Buka dan pelajari materi sains hari ini untuk menyalakan api belajarmu!',
        bgColor: Color(0xFFF1F5F9),
        borderColor: Color(0xFFCBD5E1),
        iconColor: Color(0xFF94A3B8),
        textColor: Color(0xFF64748B),
        glowColor: Colors.transparent,
        nextGoalDays: 2,
        isMaxTier: false,
        flameGradient: [
          Color(0xFF64748B),
          Color(0xFF94A3B8),
          Color(0xFFCBD5E1),
        ],
      );
    } else if (days < 7) {
      return const _StreakTier(
        levelName: 'Spark Starter',
        title: 'Percikan Api Menyala!',
        desc:
            'Awal yang hebat! Pertahankan konsistensimu hingga 7 hari untuk membuka Super Flame berkobar emas.',
        bgColor: Color(0xFFFFF7ED),
        borderColor: Color(0xFFFED7AA),
        iconColor: Color(0xFFEA580C),
        textColor: Color(0xFFC2410C),
        glowColor: Color(0x44EA580C),
        nextGoalDays: 7,
        isMaxTier: false,
        flameGradient: [
          Color(0xFFEA580C),
          Color(0xFFF97316),
          Color(0xFFFDBA74),
        ],
      );
    } else if (days < 14) {
      return const _StreakTier(
        levelName: 'Super Flame',
        title: 'Super Flame 7+ Hari!',
        desc:
            'Hebat! 1 pekan penuh konsisten. Lanjutkan hingga 14 hari untuk membuka puncak Ultimate Flame!',
        bgColor: Color(0xFFFEFCE8),
        borderColor: Color(0xFFFDE047),
        iconColor: Color(0xFFD97706),
        textColor: Color(0xFFB45309),
        glowColor: Color(0x80F59E0B),
        nextGoalDays: 14,
        isMaxTier: false,
        flameGradient: [
          Color(0xFFB45309),
          Color(0xFFD97706),
          Color(0xFFF59E0B),
          Color(0xFFFEF08A),
        ],
      );
    } else {
      return const _StreakTier(
        levelName: 'Ultimate Flame',
        title: 'Ultimate Flame 14+ Hari!',
        desc:
            'Luar biasa! Kamu telah mencapai puncak kedisiplinan tertinggi dengan api abadi kosmik berkobar penuh energi!',
        bgColor: Color(0xFFFAF5FF),
        borderColor: Color(0xFFE9D5FF),
        iconColor: Color(0xFF9333EA),
        textColor: Color(0xFF7E22CE),
        glowColor: Color(0x999333EA),
        nextGoalDays: 14,
        isMaxTier: true,
        flameGradient: [
          Color(0xFF7E22CE),
          Color(0xFF9333EA),
          Color(0xFFE879F9),
          Color(0xFF38BDF8),
        ],
      );
    }
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.title,
    required this.category,
    required this.iconPath,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String category;
  final String iconPath;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double safeProgress = progress.clamp(0.0, 1.0);
    final int percentage = (safeProgress * 100).round();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) =>
                      const Icon(
                    Icons.science_rounded,
                    color: _blue,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      percentage > 0
                          ? 'Lanjutkan dari progres terakhir ($percentage%)'
                          : 'Mulai pelajari modul ${category.isNotEmpty ? category : "ini"}',
                      style: GoogleFonts.plusJakartaSans(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: safeProgress,
                              minHeight: 6,
                              color: _blue,
                              backgroundColor: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$percentage%',
                          style: GoogleFonts.poppins(
                            color: _blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: _blue,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.quest,
    required this.isDone,
    required this.progress,
    required this.progressText,
  });

  final Map<String, dynamic> quest;
  final bool isDone;
  final double progress;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.track_changes_rounded,
              color: isDone ? _green : _blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (quest['title'] ?? 'Misi Harian').toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: isDone
                        ? const Color(0xFF15803D)
                        : _text,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((quest['desc'] ?? '').toString().trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 1),
                  Text(
                    quest['desc'].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: _muted,
                      fontSize: 10.5,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    color: isDone ? _green : _blue,
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isDone ? Colors.white : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFBFDBFE),
              ),
            ),
            child: Text(
              progressText,
              style: GoogleFonts.poppins(
                color: isDone ? _green : _blue,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 18,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _blue,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _muted,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.route_rounded, size: 16),
              label: Text(
                actionLabel!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
