import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/science_shimmer.dart';
import '../../milestone/controllers/milestone_controller.dart';
import '../../milestone/widgets/milestone_avatar_frame.dart';

const Color _background =
    Color(0xFFF5F8FE);
const Color _text =
    Color(0xFF263238);
const Color _muted =
    Color(0xFF64748B);
const Color _blue =
    Color(0xFF4285F4);
const Color _blueDark =
    Color(0xFF1E3A8A);
const Color _green =
    Color(0xFF22A06B);
const Color _orange =
    Color(0xFFF57C00);
const Color _funFactColor =
    Color(0xFFFFD166);

class DashboardNewView
    extends StatefulWidget {
  const DashboardNewView({
    super.key,
  });

  @override
  State<DashboardNewView> createState() =>
      _DashboardNewViewState();
}

class _DashboardNewViewState
    extends State<DashboardNewView> {
  late final DashboardController
      controller;
  late final ProfileController
      profileController;
  late final MilestoneController
      milestoneController;

  @override
  void initState() {
    super.initState();

    controller =
        Get.find<DashboardController>();
    profileController =
        Get.find<ProfileController>();
    milestoneController =
        MilestoneController.ensureRegistered();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      controller.onDashboardVisible();
      milestoneController.loadMilestones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: _background,
        foregroundColor: _text,
        surfaceTintColor: _background,
        elevation: 0,
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () =>
            Get.toNamed(
          Routes.CHATBOT,
        ),
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 7,
        icon: const Icon(
          Icons.smart_toy_rounded,
        ),
        label: const Text(
          'Tanya Aira',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          controller.refreshDashboardData();
          await milestoneController.loadMilestones();

          await Future<void>.delayed(
            const Duration(
              milliseconds: 550,
            ),
          );
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: <Widget>[
            _buildHeader(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        122,
      ),
      child: Row(
        children: <Widget>[
          Obx(
            () => MilestoneAvatarFrame(
              size: 60,
              frameId: milestoneController
                  .equippedFrame.value?.id,
              child: Image.asset(
                profileController
                    .avatarPath.value,
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) {
                  return Container(
                    color: const Color(
                      0xFFEFF6FF,
                    ),
                    alignment:
                        Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: _blue,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Obx(
                  () => Text(
                    'Hai ${profileController.userName.value}! 👋',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _text,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Siap belajar sains hari ini?',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFFFEDD5,
                  ),
                ),
                boxShadow:
                    const <BoxShadow>[
                  BoxShadow(
                    color:
                        Color(0x120F172A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${controller.userStreak.value}',
                    style:
                        const TextStyle(
                      color: _orange,
                      fontSize: 19,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          margin:
              const EdgeInsets.only(
            top: 105,
          ),
          padding:
              const EdgeInsets.fromLTRB(
            20,
            118,
            20,
            110,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: <Widget>[
              _buildLearningSummary(),
              const SizedBox(height: 25),
              const _SectionTitle(
                title: 'Lanjutkan Belajar',
                subtitle:
                    'Materi yang sedang kamu pelajari akan muncul di sini.',
              ),
              const SizedBox(height: 13),
              _buildContinueLearning(),
              const SizedBox(height: 26),
              const _SectionTitle(
                title: 'Misi Harian 🎯',
                subtitle:
                    'Selesaikan target untuk memperoleh bonus XP.',
              ),
              const SizedBox(height: 13),
              _buildDailyQuest(),
            ],
          ),
        ),

        // Fun Fact tetap menjadi kartu utama di bagian atas dashboard.
        Positioned(
          top: -80,
          left: 20,
          right: 20,
          child: _buildFunFact(),
        ),
      ],
    );
  }

  Widget _buildFunFact() {
    return SizedBox(
      height: 250,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: _funFactColor,
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
                boxShadow:
                    const <BoxShadow>[
                  BoxShadow(
                    color:
                        Color(0x14000000),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
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
          Positioned(
            bottom: 10,
            left: 12,
            right: 12,
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Obx(
                () {
                  if (controller
                      .currentFact.isEmpty) {
                    return const ScienceShimmer(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: <Widget>[
                          ShimmerBox(
                            width: 155,
                            height: 18,
                          ),
                          SizedBox(height: 8),
                          ShimmerBox(
                            height: 13,
                          ),
                          SizedBox(height: 6),
                          ShimmerBox(
                            width: 220,
                            height: 13,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    mainAxisSize:
                        MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Tahukah Kamu?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.currentFact[
                                'desc'] ??
                            '',
                        style:
                            const TextStyle(
                          fontSize: 14,
                          color:
                              Color(0xFF555555),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis,
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

  Widget _buildLearningSummary() {
    return Obx(
      () {
        if (controller
            .isLearningSummaryLoading
            .value) {
          return const ScienceShimmer(
            child: ShimmerBox(
              height: 145,
              radius: 24,
            ),
          );
        }

        final double progress =
            controller
                .currentLevelProgress
                .value
                .clamp(0.0, 1.0);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                Get.toNamed(
              Routes.LEARNING,
            ),
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            child: Container(
              padding:
                  const EdgeInsets.all(
                18,
              ),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin:
                      Alignment.topLeft,
                  end:
                      Alignment.bottomRight,
                  colors: <Color>[
                    Color(
                      0xFFEAF3FF,
                    ),
                    Color(
                      0xFFF3EEFF,
                    ),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
                border: Border.all(
                  color: const Color(
                    0xFFD7E5FF,
                  ),
                ),
                boxShadow:
                    const <BoxShadow>[
                  BoxShadow(
                    color:
                        Color(0x122563EB),
                    blurRadius: 16,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .route_rounded,
                          color: _blue,
                          size: 27,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: <Widget>[
                            Text(
                              'Level Pembelajaran ${controller.currentLearningLevel.value}',
                              style:
                                  const TextStyle(
                                color: _text,
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              '${controller.currentLevelCompletedModules.value} dari ${controller.currentLevelTotalModules.value} modul level ini selesai',
                              style:
                                  const TextStyle(
                                color:
                                    _muted,
                                fontSize:
                                    11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        color: _blue,
                        size: 17,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                          child:
                              LinearProgressIndicator(
                            value:
                                progress,
                            minHeight: 9,
                            color: _blue,
                            backgroundColor:
                                Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style:
                            const TextStyle(
                          color:
                              _blueDark,
                          fontSize: 12,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '${controller.learningCompletedModules.value}/${controller.learningTotalModules.value} modul keseluruhan selesai',
                    style:
                        const TextStyle(
                      color: _blueDark,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueLearning() {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const ScienceShimmer(
            child: Column(
              children: <Widget>[
                ShimmerBox(
                  height: 96,
                  radius: 21,
                ),
                SizedBox(height: 11),
                ShimmerBox(
                  height: 96,
                  radius: 21,
                ),
              ],
            ),
          );
        }

        final items = controller
            .inProgressMaterials
            .where(
          (item) =>
              item.progress > 0 &&
              item.progress < 1,
        )
            .toList();

        if (items.isEmpty) {
          return const _EmptyCard(
            icon:
                Icons.rocket_launch_rounded,
            title:
                'Mulai Petualangan Sainsmu!',
            message:
                'Materi akan muncul di sini setelah progresnya lebih dari 0% dan belum mencapai 100%.',
          );
        }

        return Column(
          children: items.map(
            (item) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 11,
                ),
                child:
                    _ContinueLearningCard(
                  title: item.title,
                  iconPath:
                      item.iconPath,
                  progress:
                      item.progress,
                  onTap: () =>
                      controller
                          .continueMaterial(
                    item,
                  ),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }

  Widget _buildDailyQuest() {
    return Obx(
      () {
        if (controller
            .isDailyQuestLoading
            .value) {
          return const ScienceShimmer(
            child: ShimmerBox(
              height: 330,
              radius: 26,
            ),
          );
        }

        if (controller
            .dailyQuests.isEmpty) {
          return const _EmptyCard(
            icon:
                Icons.track_changes_rounded,
            title:
                'Misi harian belum tersedia',
            message:
                'Coba buka kembali Dashboard beberapa saat lagi.',
          );
        }

        final int completedCount =
            controller.dailyQuests.where(
          controller.isQuestDone,
        ).length;
        final int total =
            controller.dailyQuests.length;
        final double totalProgress =
            total == 0
                ? 0
                : (
                    completedCount /
                    total
                  ).clamp(0.0, 1.0);

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              27,
            ),
            boxShadow:
                const <BoxShadow>[
              BoxShadow(
                color:
                    Color(0x1F2563EB),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  18,
                  17,
                  18,
                  18,
                ),
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topLeft,
                    end:
                        Alignment.bottomRight,
                    colors: <Color>[
                      Color(
                        0xFF2563EB,
                      ),
                      Color(
                        0xFF5B4FD8,
                      ),
                    ],
                  ),
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: -32,
                      right: -20,
                      child: Container(
                        width: 105,
                        height: 105,
                        decoration:
                            const BoxDecoration(
                          color: Color(
                            0x1FFFFFFF,
                          ),
                          shape:
                              BoxShape.circle,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 45,
                              height: 45,
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0x26FFFFFF,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                              child:
                                  const Icon(
                                Icons
                                    .track_changes_rounded,
                                color:
                                    Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(
                              width: 11,
                            ),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: <
                                    Widget>[
                                  Text(
                                    'Papan Misi Hari Ini',
                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .white,
                                      fontSize:
                                          17,
                                      fontWeight:
                                          FontWeight
                                              .w900,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Sedikit progres setiap hari membuat belajar lebih konsisten.',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFDCE9FF,
                                      ),
                                      fontSize:
                                          10,
                                      height:
                                          1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    10,
                                vertical: 7,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors
                                        .white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                              ),
                              child: Text(
                                '+${controller.dailyRewardXp.value} XP',
                                style:
                                    const TextStyle(
                                  color:
                                      _blueDark,
                                  fontSize:
                                      11,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  20,
                                ),
                                child:
                                    LinearProgressIndicator(
                                  value:
                                      totalProgress,
                                  minHeight:
                                      8,
                                  color:
                                      const Color(
                                    0xFFFACC15,
                                  ),
                                  backgroundColor:
                                      const Color(
                                    0x33FFFFFF,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '$completedCount/$total',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    11,
                                fontWeight:
                                    FontWeight
                                        .w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(
                  0xFFF5F8FF,
                ),
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  14,
                  15,
                  14,
                  15,
                ),
                child: Column(
                  children: <Widget>[
                    ...controller
                        .dailyQuests
                        .map(
                      (
                        Map<String,
                                dynamic>
                            quest,
                      ) =>
                          _QuestTile(
                        quest: quest,
                        isDone: controller
                            .isQuestDone(
                          quest,
                        ),
                        progress:
                            controller
                                .questProgressValue(
                          quest,
                        ),
                        progressText:
                            controller
                                .questProgressText(
                          quest,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed: controller
                                .canClaimDailyReward
                            ? controller
                                .claimDailyReward
                            : null,
                        style:
                            FilledButton
                                .styleFrom(
                          backgroundColor:
                              _green,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              const Color(
                            0xFFDDE4EE,
                          ),
                          disabledForegroundColor:
                              _muted,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 14,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                          elevation: controller
                                  .canClaimDailyReward
                              ? 4
                              : 0,
                        ),
                        icon: Icon(
                          controller
                                  .isDailyRewardClaimed
                                  .value
                              ? Icons
                                  .check_circle_rounded
                              : Icons
                                  .redeem_rounded,
                        ),
                        label: Text(
                          controller
                                  .isDailyRewardClaimed
                                  .value
                              ? 'Reward Sudah Diklaim'
                              : controller
                                      .isAllDailyQuestDone
                                  ? 'Ambil Reward +${controller.dailyRewardXp.value} XP'
                                  : 'Selesaikan Semua Misi',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w900,
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
          style: const TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard
    extends StatelessWidget {
  const _ContinueLearningCard({
    required this.title,
    required this.iconPath,
    required this.progress,
    required this.onTap,
  });

  final String title;
  final String iconPath;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double safeProgress =
        progress.clamp(0.0, 1.0);
    final int percentage =
        (safeProgress * 100).round();

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(21),
        child: Container(
          padding:
              const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              21,
            ),
            border: Border.all(
              color: const Color(
                0xFFDBEAFE,
              ),
            ),
            boxShadow:
                const <BoxShadow>[
              BoxShadow(
                color:
                    Color(0x0F0F172A),
                blurRadius: 13,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 61,
                height: 61,
                padding:
                    const EdgeInsets.all(
                  9,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEFF6FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    17,
                  ),
                ),
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace?
                        stackTrace,
                  ) =>
                      const Icon(
                    Icons.science_rounded,
                    color: _blue,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: _text,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Lanjutkan dari progres terakhir',
                      style:
                          TextStyle(
                        color: _muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(
                      height: 9,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            child:
                                LinearProgressIndicator(
                              value:
                                  safeProgress,
                              minHeight: 7,
                              color: _blue,
                              backgroundColor:
                                  const Color(
                                0xFFE2E8F0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 9,
                        ),
                        Text(
                          '$percentage%',
                          style:
                              const TextStyle(
                            color: _blue,
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFEAF1FF,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: const Icon(
                  Icons
                      .arrow_forward_rounded,
                  color: _blue,
                  size: 20,
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
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(17),
        border: Border.all(
          color: isDone
              ? const Color(
                  0xFFBBF7D0,
                )
              : const Color(
                  0xFFE2E8F0,
                ),
        ),
        boxShadow:
            const <BoxShadow>[
          BoxShadow(
            color:
                Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(
                      0xFFE7F8EE,
                    )
                  : const Color(
                      0xFFEAF1FF,
                    ),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              isDone
                  ? Icons
                      .check_circle_rounded
                  : Icons
                      .push_pin_rounded,
              color: isDone
                  ? _green
                  : _blue,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (
                    quest['title'] ??
                        'Misi Harian'
                  ).toString(),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDone
                        ? const Color(
                            0xFF15803D,
                          )
                        : _text,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                if (
                  (quest['desc'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty
                ) ...<Widget>[
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    quest['desc']
                        .toString(),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      color: _muted,
                      fontSize: 9,
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  child:
                      LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    color: isDone
                        ? _green
                        : _blue,
                    backgroundColor:
                        const Color(
                      0xFFE2E8F0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isDone
                  ? const Color(
                      0xFFE7F8EE,
                    )
                  : const Color(
                      0xFFF1F5F9,
                    ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              progressText,
              style: TextStyle(
                color: isDone
                    ? _green
                    : _muted,
                fontSize: 10,
                fontWeight:
                    FontWeight.w900,
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
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF8FBFF,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(
            0xFFDBEAFE,
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            icon,
            color: _blue,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _text,
              fontSize: 15,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
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
