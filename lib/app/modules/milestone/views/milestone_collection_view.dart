import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/milestone_controller.dart';
import '../models/milestone_reward.dart';
import '../widgets/milestone_avatar_frame.dart';

const Color _background = Color(0xFFF4F8FF);
const Color _primary = Color(0xFF2563EB);
const Color _purple = Color(0xFF7C3AED);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _success = Color(0xFF16A34A);
const Color _border = Color(0xFFE2E8F0);

class MilestoneCollectionView extends StatefulWidget {
  const MilestoneCollectionView({super.key});

  @override
  State<MilestoneCollectionView> createState() =>
      _MilestoneCollectionViewState();
}

class _MilestoneCollectionViewState extends State<MilestoneCollectionView> {
  late final MilestoneController controller;
  DiscoveryCategory? selectedCategory;
  bool showFrames = false;

  @override
  void initState() {
    super.initState();
    controller = MilestoneController.ensureRegistered();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          title: const Text('Milestone & Koleksi'),
          backgroundColor: Colors.white,
          foregroundColor: _text,
          elevation: 0,
        ),
        body: Column(
          children: <Widget>[
            _XpJourneyHeader(controller: controller),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  labelColor: _primary,
                  unselectedLabelColor: _muted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                  tabs: const <Widget>[
                    Tab(text: 'Milestone'),
                    Tab(text: 'Koleksi'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value &&
                      controller.rewards.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (controller.errorMessage.value.isNotEmpty &&
                      controller.rewards.isEmpty) {
                    return _LoadError(
                      message: controller.errorMessage.value,
                      onRetry: controller.loadMilestones,
                    );
                  }

                  return TabBarView(
                    children: <Widget>[
                      _buildMilestoneTab(),
                      _buildCollectionTab(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneTab() {
    final List<MilestoneReward> rewards = controller.rewards.toList();
    final String? nextId = controller.nextReward.value?.id;

    return RefreshIndicator(
      onRefresh: controller.loadMilestones,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
        children: <Widget>[
          const _SectionHeading(
            title: 'Perjalanan Milestone',
            subtitle:
                'XP adalah jejak aktivitas belajar. Hadiah tidak membuka materi atau Level Pembelajaran.',
          ),
          const SizedBox(height: 16),
          if (rewards.isEmpty)
            const _EmptyCard(
              icon: Icons.route_rounded,
              title: 'Milestone belum tersedia',
              subtitle: 'Tarik layar ke bawah untuk memuat ulang.',
            )
          else
            ...List<Widget>.generate(
              rewards.length,
              (int index) {
                final MilestoneReward reward = rewards[index];
                final bool isNext = !reward.unlocked && reward.id == nextId;
                final bool hideIdentity = !reward.unlocked && !isNext;

                return _JourneyItem(
                  reward: reward,
                  isNext: isNext,
                  hideIdentity: hideIdentity,
                  isLast: index == rewards.length - 1,
                  onTap: reward.unlocked
                      ? () => _showRewardDetail(reward)
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCollectionTab() {
    return RefreshIndicator(
      onRefresh: controller.loadMilestones,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionHeading(
                    title: 'Koleksi Penemuan',
                    subtitle:
                        'Enrichment sains yang terbuka otomatis ketika milestone XP tercapai.',
                  ),
                  const SizedBox(height: 14),
                  _collectionTypeSwitch(),
                  if (!showFrames) ...<Widget>[
                    const SizedBox(height: 12),
                    _categoryFilters(),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (showFrames)
            _buildFrameGrid()
          else
            _buildDiscoveryGrid(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _collectionTypeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MiniSegment(
              icon: Icons.auto_awesome_rounded,
              label: 'Penemuan',
              selected: !showFrames,
              onTap: () => setState(() => showFrames = false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _MiniSegment(
              icon: Icons.hexagon_outlined,
              label: 'Bingkai',
              selected: showFrames,
              onTap: () => setState(() => showFrames = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilters() {
    final List<_CategoryChoice> choices = <_CategoryChoice>[
      const _CategoryChoice(null, 'Semua'),
      const _CategoryChoice(DiscoveryCategory.scientist, 'Tokoh'),
      const _CategoryChoice(DiscoveryCategory.phenomenon, 'Fenomena'),
      const _CategoryChoice(DiscoveryCategory.application, 'Penerapan'),
      const _CategoryChoice(DiscoveryCategory.technology, 'Teknologi'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: choices.map((_CategoryChoice choice) {
          final bool selected = selectedCategory == choice.category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(choice.label),
              selected: selected,
              onSelected: (_) {
                setState(() => selectedCategory = choice.category);
              },
              selectedColor: const Color(0xFFDCE9FF),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? const Color(0xFF93B4F8) : _border,
              ),
              labelStyle: TextStyle(
                color: selected ? _primary : _muted,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscoveryGrid() {
    final List<MilestoneReward> cards = controller.rewards
        .where((MilestoneReward item) =>
            item.isDiscoveryCard &&
            (selectedCategory == null || item.category == selectedCategory))
        .toList();

    MilestoneReward? nearestLocked;
    for (final MilestoneReward item in controller.rewards) {
      if (item.isDiscoveryCard && !item.unlocked) {
        nearestLocked = item;
        break;
      }
    }

    if (cards.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: _EmptyCard(
            icon: Icons.collections_bookmark_outlined,
            title: 'Belum ada kartu pada kategori ini',
            subtitle: 'Pilih kategori lain untuk melihat koleksi.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final MilestoneReward reward = cards[index];
            return _DiscoveryCollectibleCard(
              reward: reward,
              revealLockedIdentity: nearestLocked?.id == reward.id,
              onTap: () {
                if (reward.unlocked) {
                  _showRewardDetail(reward);
                } else {
                  _showLockedMessage(reward);
                }
              },
            );
          },
          childCount: cards.length,
        ),
      ),
    );
  }

  Widget _buildFrameGrid() {
    final List<MilestoneReward> frames = controller.rewards
        .where((MilestoneReward item) => item.isAvatarFrame)
        .toList();

    if (frames.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverToBoxAdapter(
          child: _EmptyCard(
            icon: Icons.hexagon_outlined,
            title: 'Belum ada bingkai',
            subtitle: 'Bingkai avatar akan muncul sebagai reward milestone.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final MilestoneReward reward = frames[index];
            return _FrameCollectionCard(
              reward: reward,
              onTap: () {
                if (reward.unlocked) {
                  _showRewardDetail(reward);
                } else {
                  _showLockedMessage(reward);
                }
              },
            );
          },
          childCount: frames.length,
        ),
      ),
    );
  }

  void _showLockedMessage(MilestoneReward reward) {
    Get.snackbar(
      'Belum Terbuka',
      'Capai ${reward.requiredXp} XP untuk membuka reward ini.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      colorText: _text,
      icon: const Icon(Icons.lock_outline_rounded, color: _primary),
    );
  }

  void _showRewardDetail(MilestoneReward reward) {
    if (reward.isDiscoveryCard) {
      Get.dialog<void>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SingleChildScrollView(
            child: _FullCollectibleCardView(
              reward: reward,
              controller: controller,
            ),
          ),
        ),
      );
      return;
    }

    Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  reward.isAvatarFrame
                      ? MilestoneFramePlaceholder(
                          frameId: reward.id,
                          size: 64,
                        )
                      : _RewardIconBox(reward: reward, size: 54),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          reward.title,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${reward.subtitle} • ${reward.requiredXp} XP',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (reward.unlocked)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: _success,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                reward.description,
                style: const TextStyle(
                  color: _text,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              if (reward.isAvatarFrame) ...<Widget>[
                const SizedBox(height: 18),
                Center(
                  child: MilestoneFramePlaceholder(
                    frameId: reward.id,
                    size: 132,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: reward.isEquipped
                        ? const Color(0xFFEAF8EF)
                        : const Color(0xFFF4F7FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: reward.isEquipped
                          ? const Color(0xFFB8E6C7)
                          : const Color(0xFFDCE7FA),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        reward.isEquipped
                            ? Icons.verified_rounded
                            : Icons.auto_awesome_rounded,
                        color: reward.isEquipped ? _success : _primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reward.isEquipped
                              ? 'Bingkai ini sedang digunakan di Profil Pembelajaran.'
                              : 'Gunakan bingkai ini untuk menghias avatar Profil Pembelajaran.',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: reward.isEquipped
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final bool success =
                                await controller.clearEquippedFrame();
                            if (!success) {
                              Get.snackbar(
                                'Bingkai belum berubah',
                                controller.errorMessage.value.isEmpty
                                    ? 'Coba lagi beberapa saat.'
                                    : controller.errorMessage.value,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            Get.back();
                            Get.snackbar(
                              'Bingkai dilepas',
                              'Avatar kembali menggunakan tampilan standar.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Lepas Bingkai'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: () async {
                            final bool success =
                                await controller.equipFrame(reward);
                            if (!success) {
                              Get.snackbar(
                                'Bingkai belum digunakan',
                                controller.errorMessage.value.isEmpty
                                    ? 'Coba lagi beberapa saat.'
                                    : controller.errorMessage.value,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                              );
                              return;
                            }

                            Get.back();
                            Get.snackbar(
                              'Bingkai digunakan',
                              '${reward.title} sekarang aktif di profilmu.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              backgroundColor: Colors.white,
                              colorText: _text,
                              icon: const Icon(
                                Icons.check_circle_rounded,
                                color: _success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Gunakan Bingkai'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

}

class _XpJourneyHeader extends StatelessWidget {
  const _XpJourneyHeader({required this.controller});

  final MilestoneController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final MilestoneReward? next = controller.nextReward.value;
        final int current = controller.currentXp.value;
        final int target = controller.progressTargetXp.value;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF1D4ED8), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x242563EB),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$current XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Terus belajar, milestone berikutnya semakin dekat!',
                            style: TextStyle(
                              color: Color(0xFFE8EEFF),
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: next == null ? 1 : controller.progressToNext.value,
                    minHeight: 9,
                    backgroundColor: Colors.white.withOpacity(0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        next == null ? 'Semua milestone terbuka' : '$current / $target XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.unlockedCount.value}/${controller.totalCount.value} terbuka',
                      style: const TextStyle(
                        color: Color(0xFFE8EEFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.14)),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        next == null ? Icons.verified_rounded : Icons.lock_open_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              next == null ? 'Koleksi milestone lengkap' : 'Berikutnya: ${next.title}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              next == null
                                  ? 'Semua reward yang tersedia sudah kamu buka.'
                                  : '${next.subtitle} • ${next.requiredXp} XP • kurang ${controller.remainingXpToNext.value} XP',
                              style: const TextStyle(
                                color: Color(0xFFE8EEFF),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JourneyItem extends StatelessWidget {
  const _JourneyItem({
    required this.reward,
    required this.isNext,
    required this.hideIdentity,
    required this.isLast,
    required this.onTap,
  });

  final MilestoneReward reward;
  final bool isNext;
  final bool hideIdentity;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = reward.unlocked;
    final Color stateColor = unlocked ? _success : (isNext ? _primary : const Color(0xFF94A3B8));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 42,
            child: Column(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? const Color(0xFFE8F7ED)
                        : isNext
                            ? const Color(0xFFE8F0FF)
                            : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(color: stateColor, width: 2),
                  ),
                  child: Icon(
                    unlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
                    color: stateColor,
                    size: 17,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: unlocked ? const Color(0xFFA7E1B8) : const Color(0xFFD7DEE8),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isNext ? const Color(0xFF9AB8F5) : _border,
                      width: isNext ? 1.5 : 1,
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      _RewardIconBox(reward: reward, size: 46, muted: hideIdentity),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  '${reward.requiredXp} XP',
                                  style: TextStyle(
                                    color: stateColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                if (isNext) ...<Widget>[
                                  const SizedBox(width: 7),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0FF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      'BERIKUTNYA',
                                      style: TextStyle(
                                        color: _primary,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hideIdentity ? '???' : reward.title,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hideIdentity ? 'Hadiah masih rahasia' : reward.subtitle,
                              style: const TextStyle(
                                color: _muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unlocked)
                        const Icon(Icons.chevron_right_rounded, color: _muted),
                    ],
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

class _DiscoveryCollectibleCard extends StatelessWidget {
  const _DiscoveryCollectibleCard({
    required this.reward,
    required this.revealLockedIdentity,
    required this.onTap,
  });

  final MilestoneReward reward;
  final bool revealLockedIdentity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = reward.unlocked;
    final bool reveal = unlocked || revealLockedIdentity;
    final List<Color> colors = _categoryGradient(reward.category);
    final String? imageAsset = reward.resolvedVisualAsset;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked ? colors.first.withOpacity(0.42) : _border,
            width: unlocked ? 1.5 : 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0C0F172A),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: unlocked
                        ? LinearGradient(
                            colors: colors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: <Color>[Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
                          ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: imageAsset != null
                            ? ColorFiltered(
                                colorFilter: unlocked
                                    ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                                    : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                child: _buildRewardImageWidget(
                                  imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: () => _buildFallbackIcon(unlocked, reward),
                                ),
                              )
                            : _buildFallbackIcon(unlocked, reward),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            reward.resolvedRarity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            unlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
                            color: unlocked ? _success : _muted,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        reveal ? reward.subtitle : 'Koleksi Penemuan',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unlocked ? colors.first : _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        reveal ? reward.title : '???',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 13,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        unlocked ? 'Koleksi terbuka' : '${reward.requiredXp} XP',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon(bool unlocked, MilestoneReward reward) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(unlocked ? 0.2 : 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          unlocked ? _rewardIcon(reward) : Icons.lock_rounded,
          color: unlocked ? Colors.white : const Color(0xFF94A3B8),
          size: unlocked ? 34 : 28,
        ),
      ),
    );
  }
}

class _FullCollectibleCardView extends StatelessWidget {
  const _FullCollectibleCardView({
    required this.reward,
    required this.controller,
  });

  final MilestoneReward reward;
  final MilestoneController controller;

  IconData _getHighlightIcon(String iconKey) {
    switch (iconKey) {
      case 'tune':
        return Icons.tune_rounded;
      case 'biotech':
        return Icons.biotech_rounded;
      case 'auto_stories':
        return Icons.auto_stories_rounded;
      default:
        return Icons.science_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? imageAsset = reward.resolvedVisualAsset;
    final List<CardHighlight> highlights = reward.resolvedHighlights;
    final int totalDiscoveryCards = controller.rewards.where((r) => r.isDiscoveryCard).length;
    final int unlockedDiscoveryCards = controller.unlockedDiscoveryCards.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDCE7FA), width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x280F172A),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Top Ribbon & Badges
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Color(0x227C3AED), blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.science_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        reward.category.label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            reward.resolvedRarity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => Get.back(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded, color: _muted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Illustration Image Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFEBF3FF), Color(0xFFF3EEFF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (imageAsset != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: _buildRewardImageWidget(
                        imageAsset,
                        fit: BoxFit.contain,
                        errorBuilder: () => Icon(_rewardIcon(reward), size: 80, color: _primary),
                      ),
                    )
                  else
                    Icon(_rewardIcon(reward), size: 80, color: _primary),
                  Positioned(
                    bottom: -1,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: Color(0x180F172A), blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFF7C3AED),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title Pill Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Color(0x0F0F172A), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.eco_rounded, color: Color(0xFF93C5FD), size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          reward.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.eco_rounded, color: Color(0xFF93C5FD), size: 18),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(width: 20, height: 1, color: const Color(0xFF94A3B8)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          reward.subtitle,
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(width: 20, height: 1, color: const Color(0xFF94A3B8)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Biography
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              reward.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Highlights Grid
          if (highlights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: highlights.map((CardHighlight item) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getHighlightIcon(item.icon.toString()),
                              color: const Color(0xFF4338CA),
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 8,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 14),

          // Quote Box
          if (reward.resolvedQuote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '"${reward.resolvedQuote}"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reward.resolvedYears.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        '— ${reward.resolvedYears} —',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Footer Collection Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: _primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'KOLEKSI ILMUWAN',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '$unlockedDiscoveryCards / $totalDiscoveryCards',
                    style: const TextStyle(
                      color: _primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
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

class _FrameCollectionCard extends StatelessWidget {
  const _FrameCollectionCard({required this.reward, required this.onTap});

  final MilestoneReward reward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = reward.unlocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: reward.isEquipped ? const Color(0xFF86A9F3) : _border,
            width: reward.isEquipped ? 1.6 : 1,
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0C0F172A),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Center(
                child: MilestoneFramePlaceholder(
                  frameId: reward.id,
                  size: 108,
                  locked: !unlocked,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              unlocked ? reward.title : '???',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: reward.isEquipped
                    ? const Color(0xFFE8F7ED)
                    : unlocked
                        ? const Color(0xFFE8F0FF)
                        : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                reward.isEquipped
                    ? 'Digunakan'
                    : unlocked
                        ? 'Ketuk untuk gunakan'
                        : '${reward.requiredXp} XP',
                style: TextStyle(
                  color: reward.isEquipped
                      ? _success
                      : unlocked
                          ? _primary
                          : _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RewardIconBox extends StatelessWidget {
  const _RewardIconBox({
    required this.reward,
    required this.size,
    this.muted = false,
  });

  final MilestoneReward reward;
  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = muted
        ? const <Color>[Color(0xFFE2E8F0), Color(0xFFF1F5F9)]
        : _categoryGradient(reward.category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        muted ? Icons.question_mark_rounded : _rewardIcon(reward),
        color: muted ? _muted : Colors.white,
        size: size * 0.5,
      ),
    );
  }
}

class _MiniSegment extends StatelessWidget {
  const _MiniSegment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x110F172A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 17, color: selected ? _primary : _muted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? _primary : _muted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: _text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: _muted,
            fontSize: 11,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

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
      child: Column(
        children: <Widget>[
          Icon(icon, color: _primary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _text, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _EmptyCard(
          icon: Icons.cloud_off_rounded,
          title: 'Milestone belum dapat dimuat',
          subtitle: message,
        ),
      ),
    );
  }
}

class _CategoryChoice {
  const _CategoryChoice(this.category, this.label);

  final DiscoveryCategory? category;
  final String label;
}

IconData _rewardIcon(MilestoneReward reward) {
  if (reward.isAvatarFrame) return Icons.hexagon_outlined;

  switch (reward.category) {
    case DiscoveryCategory.scientist:
      return Icons.biotech_rounded;
    case DiscoveryCategory.phenomenon:
      return Icons.auto_awesome_rounded;
    case DiscoveryCategory.application:
      return Icons.precision_manufacturing_rounded;
    case DiscoveryCategory.technology:
      return Icons.hub_rounded;
    case DiscoveryCategory.none:
      return Icons.science_rounded;
  }
}

List<Color> _categoryGradient(DiscoveryCategory category) {
  switch (category) {
    case DiscoveryCategory.scientist:
      return const <Color>[Color(0xFF2563EB), Color(0xFF7C3AED)];
    case DiscoveryCategory.phenomenon:
      return const <Color>[Color(0xFF0F9F94), Color(0xFF7C3AED)];
    case DiscoveryCategory.application:
      return const <Color>[Color(0xFF16A34A), Color(0xFFF59E0B)];
    case DiscoveryCategory.technology:
      return const <Color>[Color(0xFF0891B2), Color(0xFF2563EB)];
    case DiscoveryCategory.none:
      return const <Color>[Color(0xFF2563EB), Color(0xFF7C3AED)];
  }
}

Widget _buildRewardImageWidget(
  String path, {
  BoxFit fit = BoxFit.cover,
  required Widget Function() errorBuilder,
}) {
  final String trimmed = path.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Image.network(
      trimmed,
      fit: fit,
      errorBuilder: (_, __, ___) => errorBuilder(),
    );
  }

  return Image.asset(
    trimmed,
    fit: fit,
    errorBuilder: (_, __, ___) => errorBuilder(),
  );
}
