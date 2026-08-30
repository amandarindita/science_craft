import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/milestone_controller.dart';
import '../models/milestone_reward.dart';
import '../widgets/milestone_avatar_frame.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _purple = Color(0xFF7C3AED);
const Color _textDark = Color(0xFF0F172A);
const Color _textMuted = Color(0xFF64748B);
const Color _success = Color(0xFF10B981);
const Color _warning = Color(0xFFF59E0B);
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
        backgroundColor: _bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: _textDark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            'Milestone & Koleksi',
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: -0.2,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x140F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: _primaryBlue,
                  unselectedLabelColor: _textMuted,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  tabs: const <Widget>[
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Milestone XP'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Koleksi Sains'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: <Widget>[
            _XpJourneyHeader(controller: controller),
            Expanded(
              child: Obx(
                () {
                  if (controller.isLoading.value &&
                      controller.rewards.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _primaryBlue,
                      ),
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

  // ===========================================================================
  // TAB 1: MILESTONE XP ROADMAP
  // ===========================================================================
  Widget _buildMilestoneTab() {
    final List<MilestoneReward> rewards = controller.rewards.toList();
    final String? nextId = controller.nextReward.value?.id;

    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: controller.loadMilestones,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
        children: <Widget>[
          const _SectionHeading(
            title: 'Perjalanan Milestone XP',
            subtitle:
                'Setiap XP yang kamu kumpulkan otomatis membuka lencana, kartu penemuan, dan bingkai eksklusif!',
          ),
          const SizedBox(height: 16),
          if (rewards.isEmpty)
            const _EmptyCard(
              icon: Icons.route_rounded,
              title: 'Milestone Belum Tersedia',
              subtitle: 'Tarik layar ke bawah untuk memuat ulang data.',
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

  // ===========================================================================
  // TAB 2: KOLEKSI PENEMUAN & BINGKAI
  // ===========================================================================
  Widget _buildCollectionTab() {
    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: controller.loadMilestones,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionHeading(
                    title: 'Galeri Koleksi Sains',
                    subtitle:
                        'Eksplorasi kartu ilmuwan, fenomena menakjubkan, dan koleksi bingkai avatar profilmu.',
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
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  Widget _collectionTypeSwitch() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MiniSegment(
              icon: Icons.science_rounded,
              label: 'Kartu Penemuan',
              selected: !showFrames,
              onTap: () => setState(() => showFrames = false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _MiniSegment(
              icon: Icons.workspace_premium_rounded,
              label: 'Bingkai Avatar',
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
      const _CategoryChoice(DiscoveryCategory.scientist, 'Tokoh Sains'),
      const _CategoryChoice(DiscoveryCategory.phenomenon, 'Fenomena'),
      const _CategoryChoice(DiscoveryCategory.application, 'Penerapan'),
      const _CategoryChoice(DiscoveryCategory.technology, 'Teknologi'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: choices.map((_CategoryChoice choice) {
          final bool selected = selectedCategory == choice.category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => selectedCategory = choice.category),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? _primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _primaryBlue : _border,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _primaryBlue.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  choice.label,
                  style: GoogleFonts.plusJakartaSans(
                    color: selected ? Colors.white : _textMuted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
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
        padding: EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: _EmptyCard(
            icon: Icons.collections_bookmark_outlined,
            title: 'Belum Ada Kartu pada Kategori Ini',
            subtitle: 'Pilih kategori lain untuk melihat koleksi penemuan.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.66,
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
        padding: EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: _EmptyCard(
            icon: Icons.workspace_premium_rounded,
            title: 'Belum Ada Bingkai Avatar',
            subtitle: 'Bingkai avatar akan terbuka sebagai reward milestone XP.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
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
      'Koleksi Masih Terkunci',
      'Kumpulkan hingga ${reward.requiredXp} XP untuk membuka ${reward.title}.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      colorText: _textDark,
      borderRadius: 16,
      borderColor: const Color(0xFFCBD5E1),
      borderWidth: 1,
      icon: const Icon(Icons.lock_rounded, color: _warning),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _showRewardDetail(MilestoneReward reward) {
    if (reward.isDiscoveryCard) {
      Get.dialog<void>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
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
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
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
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
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
                          style: GoogleFonts.poppins(
                            color: _textDark,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${reward.subtitle} • ${reward.requiredXp} XP',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textMuted,
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
                      size: 26,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                reward.description,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF334155),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              if (reward.isAvatarFrame) ...<Widget>[
                const SizedBox(height: 20),
                Center(
                  child: MilestoneFramePlaceholder(
                    frameId: reward.id,
                    size: 136,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: reward.isEquipped
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: reward.isEquipped
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        reward.isEquipped
                            ? Icons.verified_rounded
                            : Icons.auto_awesome_rounded,
                        color: reward.isEquipped ? _success : _primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          reward.isEquipped
                              ? 'Bingkai ini sedang aktif digunakan di Profil Pembelajaranmu.'
                              : 'Gunakan bingkai ini untuk mempercantik avatar Profil Pembelajaranmu.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _textDark,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: reward.isEquipped
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final bool success =
                                await controller.clearEquippedFrame();
                            if (!success) {
                              Get.snackbar(
                                'Gagal Melepas',
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
                              'Bingkai Dilepas',
                              'Avatar kembali menggunakan tampilan standar.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              backgroundColor: Colors.white,
                              colorText: _textDark,
                              icon: const Icon(Icons.check_circle_rounded, color: _success),
                            );
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: Text(
                            'Lepas Bingkai',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _textMuted,
                            side: const BorderSide(color: _border),
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
                                'Gagal Menggunakan',
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
                              'Bingkai Dipasang! ✨',
                              '${reward.title} sekarang aktif menghias profilmu.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                              backgroundColor: Colors.white,
                              colorText: _textDark,
                              icon: const Icon(Icons.verified_rounded, color: _success),
                            );
                          },
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(
                            'Gunakan Bingkai Ini',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _primaryBlue,
                            foregroundColor: Colors.white,
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

// =============================================================================
// XP JOURNEY HEADER (PREMIUM GLASS CARD)
// =============================================================================
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[_darkNavy, _primaryBlue, _purple],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
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
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFFDE047),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                '$current XP',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${controller.unlockedCount.value}/${controller.totalCount.value} Terbuka',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Jejak akumulasi aktivitas belajarmu di Science Craft',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFE2E8F0),
                              fontSize: 11,
                              height: 1.3,
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
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF67E8F9),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      next == null ? 'Semua Milestone Terbuka! 👑' : '$current / $target XP',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (next != null)
                      Text(
                        'Kurang ${controller.remainingXpToNext.value} XP lagi',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFDE047),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (next != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.radar_rounded,
                          color: Color(0xFF67E8F9),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Target Berikutnya: ${next.title} (${next.requiredXp} XP)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
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

// =============================================================================
// JOURNEY ROADMAP ITEM (VERTICAL TIMELINE)
// =============================================================================
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
    final Color stateColor = unlocked
        ? _success
        : (isNext ? _primaryBlue : const Color(0xFF94A3B8));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 38,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? const Color(0xFFDCFCE7)
                        : isNext
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: stateColor,
                      width: isNext || unlocked ? 2.5 : 1.5,
                    ),
                    boxShadow: isNext
                        ? [
                            BoxShadow(
                              color: _primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    unlocked
                        ? Icons.check_rounded
                        : (isNext
                            ? Icons.radar_rounded
                            : Icons.lock_outline_rounded),
                    color: stateColor,
                    size: 16,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: unlocked
                            ? const Color(0xFF86EFAC)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isNext
                          ? const Color(0xFF93C5FD)
                          : (unlocked ? const Color(0xFFBBF7D0) : _border),
                      width: isNext ? 1.8 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isNext
                            ? _primaryBlue.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      _RewardIconBox(
                        reward: reward,
                        size: 48,
                        muted: hideIdentity,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: unlocked
                                        ? const Color(0xFFDCFCE7)
                                        : (isNext
                                            ? const Color(0xFFDBEAFE)
                                            : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bolt_rounded,
                                        size: 11,
                                        color: stateColor,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${reward.requiredXp} XP',
                                        style: GoogleFonts.poppins(
                                          color: stateColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isNext) ...<Widget>[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [_primaryBlue, _purple],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'TARGET BERIKUTNYA',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              hideIdentity ? 'Hadiah Rahasia' : reward.title,
                              style: GoogleFonts.poppins(
                                color: _textDark,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hideIdentity
                                  ? 'Buka dengan mengumpulkan XP materi sains'
                                  : reward.subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                color: _textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (unlocked)
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _textMuted,
                        ),
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

// =============================================================================
// DISCOVERY COLLECTIBLE CARD (TRADING CARD GAME STYLE)
// =============================================================================
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
            color: unlocked ? colors.first.withValues(alpha: 0.4) : _border,
            width: unlocked ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: unlocked
                  ? colors.first.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                                    ? const ColorFilter.mode(
                                        Colors.transparent,
                                        BlendMode.dst,
                                      )
                                    : const ColorFilter.mode(
                                        Colors.grey,
                                        BlendMode.saturation,
                                      ),
                                child: _buildRewardImageWidget(
                                  imageAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: () =>
                                      _buildFallbackIcon(unlocked, reward),
                                ),
                              )
                            : _buildFallbackIcon(unlocked, reward),
                      ),
                      // Category Tag
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reward.resolvedRarity,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      // Status Lock/Check
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            unlocked
                                ? Icons.check_rounded
                                : Icons.lock_outline_rounded,
                            color: unlocked ? _success : _textMuted,
                            size: 14,
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
                        style: GoogleFonts.poppins(
                          color: unlocked ? colors.first : _textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reveal ? reward.title : '???',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _textDark,
                          fontSize: 12.5,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 11,
                            color: unlocked ? _success : _textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            unlocked
                                ? 'Terbuka'
                                : '${reward.requiredXp} XP',
                            style: GoogleFonts.plusJakartaSans(
                              color: unlocked ? _success : _textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: unlocked ? 0.25 : 0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          unlocked ? _rewardIcon(reward) : Icons.lock_rounded,
          color: unlocked ? Colors.white : const Color(0xFF94A3B8),
          size: unlocked ? 32 : 26,
        ),
      ),
    );
  }
}

// =============================================================================
// FRAME COLLECTION CARD
// =============================================================================
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: reward.isEquipped
                ? _primaryBlue
                : (unlocked ? const Color(0xFFBFDBFE) : _border),
            width: reward.isEquipped ? 1.8 : 1,
          ),
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
            Expanded(
              child: Center(
                child: MilestoneFramePlaceholder(
                  frameId: reward.id,
                  size: 96,
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
              style: GoogleFonts.poppins(
                color: _textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: reward.isEquipped
                    ? const Color(0xFFDCFCE7)
                    : unlocked
                        ? const Color(0xFFDBEAFE)
                        : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                reward.isEquipped
                    ? 'Sedang Aktif'
                    : unlocked
                        ? 'Pasang Bingkai'
                        : '${reward.requiredXp} XP',
                style: GoogleFonts.poppins(
                  color: reward.isEquipped
                      ? _success
                      : unlocked
                          ? _primaryBlue
                          : _textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FULL COLLECTIBLE CARD VIEW (3D / MODAL TCG DISPLAY)
// =============================================================================
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
    final int totalDiscoveryCards =
        controller.rewards.where((r) => r.isDiscoveryCard).length;
    final int unlockedDiscoveryCards = controller.unlockedDiscoveryCards.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
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
          // Top Ribbon
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Color(0xFF8B5CF6), Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.science_rounded,
                          color: Colors.white, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        reward.category.label.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: <Color>[Color(0xFF3B82F6), _primaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.star_rounded,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            reward.resolvedRarity,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => Get.back(),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close_rounded, color: _textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Illustration Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
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
                        errorBuilder: () => Icon(_rewardIcon(reward),
                            size: 70, color: _primaryBlue),
                      ),
                    )
                  else
                    Icon(_rewardIcon(reward), size: 70, color: _primaryBlue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    reward.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reward.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: _primaryBlue,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              reward.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF334155),
                fontSize: 11.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Highlights Grid
          if (highlights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: highlights.map((CardHighlight item) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE0E7FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getHighlightIcon(item.icon.toString()),
                              color: const Color(0xFF4338CA),
                              size: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: _textDark,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: _textMuted,
                              fontSize: 7.5,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),

          // Quote Box
          if (reward.resolvedQuote.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '"${reward.resolvedQuote}"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF475569),
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (reward.resolvedYears.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        '— ${reward.resolvedYears} —',
                        style: GoogleFonts.poppins(
                          color: _textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Footer Collection Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: _primaryBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Koleksi Kartu Penemuan',
                    style: GoogleFonts.poppins(
                      color: _textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    '$unlockedDiscoveryCards / $totalDiscoveryCards',
                    style: GoogleFonts.poppins(
                      color: _primaryBlue,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
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

// =============================================================================
// HELPER WIDGETS
// =============================================================================
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
        color: muted ? _textMuted : Colors.white,
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
        padding: const EdgeInsets.symmetric(vertical: 9),
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
            Icon(icon, size: 16, color: selected ? _primaryBlue : _textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected ? _primaryBlue : _textMuted,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
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
          style: GoogleFonts.poppins(
            color: _textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            color: _textMuted,
            fontSize: 11.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: _primaryBlue, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: _textMuted,
              fontSize: 11.5,
            ),
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
          title: 'Milestone Belum Dapat Dimuat',
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
  if (reward.isAvatarFrame) return Icons.workspace_premium_rounded;

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
      return const <Color>[Color(0xFF0D9488), Color(0xFF0284C7)];
    case DiscoveryCategory.application:
      return const <Color>[Color(0xFF16A34A), Color(0xFFD97706)];
    case DiscoveryCategory.technology:
      return const <Color>[Color(0xFF0284C7), Color(0xFF4F46E5)];
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
