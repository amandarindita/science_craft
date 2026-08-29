import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/xp_reward_controller.dart';

const Color _background = Color(0xFFF4F8FF);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);
const Color _primary = Color(0xFF2563EB);
const Color _success = Color(0xFF16A34A);

class XpRewardView extends StatelessWidget {
  const XpRewardView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final XpRewardController controller =
        XpRewardController.ensureRegistered();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Koleksi Hadiah'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
      ),
      body: Obx(
        () {
          final XpRewardItem? next =
              controller.nextReward;

          return ListView(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              35,
            ),
            children: <Widget>[
              _RewardHeader(
                currentXp:
                    controller.currentXp.value,
                unlocked:
                    controller.unlockedCount,
                total:
                    controller.rewards.length,
                nextReward: next,
                nextProgress: next == null
                    ? 1
                    : controller
                        .progressRatioFor(next),
              ),
              const SizedBox(height: 18),
              const Text(
                'Hadiah XP',
                style: TextStyle(
                  color: _text,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hadiah ini hanya kosmetik dan tidak membuka Level Pembelajaran.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 13),
              ...controller.rewards.map(
                (XpRewardItem reward) =>
                    Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _RewardCard(
                    reward: reward,
                    currentXp:
                        controller
                            .currentXp.value,
                    unlocked:
                        controller
                            .isUnlocked(reward),
                    equipped:
                        controller
                            .isEquipped(reward),
                    progress:
                        controller
                            .progressRatioFor(
                      reward,
                    ),
                    remainingXp:
                        controller
                            .remainingXpFor(
                      reward,
                    ),
                    onUse: () =>
                        controller.equipReward(
                      reward,
                    ),
                    onDetails: () =>
                        _showRewardDetails(
                      reward,
                      controller,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _DummyNotice(),
            ],
          );
        },
      ),
    );
  }

  void _showRewardDetails(
    XpRewardItem reward,
    XpRewardController controller,
  ) {
    final bool unlocked =
        controller.isUnlocked(reward);
    final bool equipped =
        controller.isEquipped(reward);

    Get.bottomSheet<void>(
      Container(
        padding:
            const EdgeInsets.fromLTRB(
          22,
          13,
          22,
          28,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFCBD5E1),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              _RewardVisual(
                reward: reward,
                unlocked: unlocked,
                size: 96,
              ),
              const SizedBox(height: 15),
              Text(
                reward.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _text,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                reward.typeLabel,
                style: TextStyle(
                  color: reward.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                reward.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: unlocked
                      ? const Color(
                          0xFFE7F8EE,
                        )
                      : const Color(
                          0xFFFFF3E0,
                        ),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: Text(
                  unlocked
                      ? equipped
                          ? '✓ Sedang digunakan'
                          : '✓ Hadiah sudah terbuka'
                      : '🔒 Butuh ${controller.remainingXpFor(reward)} XP lagi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: unlocked
                        ? const Color(
                            0xFF166534,
                          )
                        : const Color(
                            0xFF9A3412,
                          ),
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: unlocked &&
                          !equipped
                      ? () {
                          Get.back<void>();
                          controller
                              .equipReward(
                            reward,
                          );
                        }
                      : null,
                  icon: Icon(
                    equipped
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .auto_awesome_rounded,
                  ),
                  label: Text(
                    equipped
                        ? 'Sedang Digunakan'
                        : unlocked
                            ? 'Gunakan Hadiah'
                            : 'Masih Terkunci',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _RewardHeader extends StatelessWidget {
  const _RewardHeader({
    required this.currentXp,
    required this.unlocked,
    required this.total,
    required this.nextReward,
    required this.nextProgress,
  });

  final int currentXp;
  final int unlocked;
  final int total;
  final XpRewardItem? nextReward;
  final double nextProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
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
            color: Color(0x242563EB),
            blurRadius: 19,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'TOTAL XP',
            style: TextStyle(
              color: Color(0xFFDCE9FF),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currentXp XP',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$unlocked dari $total hadiah terbuka',
            style: const TextStyle(
              color: Color(0xFFE0E7FF),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 17),
          if (nextReward != null) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Berikutnya: ${nextReward!.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${nextReward!.requiredXp} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: nextProgress,
                minHeight: 9,
                color:
                    const Color(0xFFFACC15),
                backgroundColor:
                    const Color(0x33FFFFFF),
              ),
            ),
          ] else
            const Text(
              'Hebat! Semua hadiah dummy sudah terbuka.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.currentXp,
    required this.unlocked,
    required this.equipped,
    required this.progress,
    required this.remainingXp,
    required this.onUse,
    required this.onDetails,
  });

  final XpRewardItem reward;
  final int currentXp;
  final bool unlocked;
  final bool equipped;
  final double progress;
  final int remainingXp;
  final VoidCallback onUse;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(19),
      child: InkWell(
        onTap: onDetails,
        borderRadius:
            BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(19),
            border: Border.all(
              color: equipped
                  ? reward.accentColor
                  : const Color(
                      0xFFE2E8F0,
                    ),
              width: equipped ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              _RewardVisual(
                reward: reward,
                unlocked: unlocked,
                size: 66,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            reward.name,
                            style:
                                const TextStyle(
                              color: _text,
                              fontSize: 15,
                              fontWeight:
                                  FontWeight
                                      .w900,
                            ),
                          ),
                        ),
                        if (equipped)
                          const Icon(
                            Icons
                                .check_circle_rounded,
                            color: _success,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      reward.typeLabel,
                      style: TextStyle(
                        color:
                            reward.accentColor,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                      child:
                          LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        color: unlocked
                            ? _success
                            : reward
                                .accentColor,
                        backgroundColor:
                            const Color(
                          0xFFE2E8F0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      unlocked
                          ? equipped
                              ? 'Sedang digunakan'
                              : 'Sudah terbuka • Ketuk untuk melihat'
                          : '$currentXp/${reward.requiredXp} XP • Kurang $remainingXp XP',
                      style: TextStyle(
                        color: unlocked
                            ? _success
                            : _muted,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    if (unlocked &&
                        !equipped) ...<Widget>[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 34,
                        child:
                            OutlinedButton.icon(
                          onPressed: onUse,
                          icon: const Icon(
                            Icons
                                .auto_awesome_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            'Gunakan',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardVisual extends StatelessWidget {
  const _RewardVisual({
    required this.reward,
    required this.unlocked,
    required this.size,
  });

  final XpRewardItem reward;
  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Widget visual =
        reward.assetPath.trim().isNotEmpty
            ? Image.asset(
                reward.assetPath,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) => Icon(
                  reward.icon,
                  color:
                      reward.accentColor,
                  size: size * 0.5,
                ),
              )
            : Icon(
                reward.icon,
                color: reward.accentColor,
                size: size * 0.5,
              );

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(
        size * 0.14,
      ),
      decoration: BoxDecoration(
        color: reward.accentColor
            .withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(
          size * 0.24,
        ),
      ),
      child: unlocked
          ? visual
          : ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: Opacity(
                opacity: 0.45,
                child: visual,
              ),
            ),
    );
  }
}

class _DummyNotice extends StatelessWidget {
  const _DummyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: _primary,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Nama dan visual hadiah masih dummy. Nanti cukup ganti data reward dan assetPath tanpa mengubah sistem XP.',
              style: TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
