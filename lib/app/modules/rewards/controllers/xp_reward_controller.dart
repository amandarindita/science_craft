import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum XpRewardType {
  avatarFrame,
  title,
  profileTheme,
  avatar,
}

class XpRewardItem {
  const XpRewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredXp,
    required this.type,
    required this.icon,
    required this.accentColor,
    this.assetPath = '',
    this.titleText = '',
    this.themeColors = const <Color>[],
  });

  final String id;
  final String name;
  final String description;
  final int requiredXp;
  final XpRewardType type;
  final IconData icon;
  final Color accentColor;

  /// Isi dengan asset asli nanti, misalnya:
  /// assets/rewards/avatar_scientist.png
  ///
  /// Saat kosong, UI memakai ikon placeholder.
  final String assetPath;

  /// Dipakai untuk hadiah jenis gelar.
  final String titleText;

  /// Dipakai untuk hadiah jenis tema profil.
  final List<Color> themeColors;

  String get typeLabel {
    switch (type) {
      case XpRewardType.avatarFrame:
        return 'Bingkai Avatar';
      case XpRewardType.title:
        return 'Gelar';
      case XpRewardType.profileTheme:
        return 'Tema Profil';
      case XpRewardType.avatar:
        return 'Avatar';
    }
  }
}

class XpRewardController
    extends GetxController {
  static XpRewardController ensureRegistered() {
    if (Get.isRegistered<XpRewardController>()) {
      return Get.find<XpRewardController>();
    }

    return Get.put<XpRewardController>(
      XpRewardController(),
      permanent: true,
    );
  }

  final GetStorage _storage = GetStorage();

  final currentXp = 0.obs;
  final userStorageKey = 'guest'.obs;

  final equippedRewardIds =
      <XpRewardType, String>{}.obs;

  // BATAS XP MODE UJI COBA.
  // Setelah alur unlock dan apply terverifikasi,
  // angka ini dapat dinaikkan tanpa mengubah sistem.
  final rewards = const <XpRewardItem>[
    XpRewardItem(
      id: 'frame_lab_blue',
      name: 'Bingkai Laboratorium',
      description:
          'Bingkai avatar edisi awal untuk siswa yang aktif mengumpulkan XP.',
      requiredXp: 10,
      type: XpRewardType.avatarFrame,
      icon: Icons.hexagon_outlined,
      accentColor: Color(0xFF2563EB),
    ),
    XpRewardItem(
      id: 'title_junior_researcher',
      name: 'Gelar Peneliti Junior',
      description:
          'Gelar khusus yang tampil di bawah nama pada Profil Pembelajaran.',
      requiredXp: 50,
      type: XpRewardType.title,
      icon: Icons.military_tech_rounded,
      accentColor: Color(0xFFF59E0B),
      titleText: 'Peneliti Junior',
    ),
    XpRewardItem(
      id: 'theme_cosmic_lab',
      name: 'Tema Cosmic Lab',
      description:
          'Tema warna profil bernuansa laboratorium dan luar angkasa.',
      requiredXp: 100,
      type: XpRewardType.profileTheme,
      icon: Icons.palette_rounded,
      accentColor: Color(0xFF7C3AED),
      themeColors: <Color>[
        Color(0xFF4338CA),
        Color(0xFF9333EA),
      ],
    ),
    XpRewardItem(
      id: 'avatar_scientist_dummy',
      name: 'Avatar Ilmuwan Spesial',
      description:
          'Avatar dummy untuk menguji sistem hadiah. Gambar dapat diganti nanti.',
      requiredXp: 150,
      type: XpRewardType.avatar,
      icon: Icons.science_rounded,
      accentColor: Color(0xFF0F766E),
    ),
  ].obs;

  bool isUnlocked(
    XpRewardItem reward,
  ) {
    return currentXp.value >=
        reward.requiredXp;
  }

  bool isEquipped(
    XpRewardItem reward,
  ) {
    return equippedRewardIds[reward.type] ==
        reward.id;
  }

  int get unlockedCount {
    return rewards
        .where(isUnlocked)
        .length;
  }

  XpRewardItem? get nextReward {
    for (final XpRewardItem reward
        in rewards) {
      if (!isUnlocked(reward)) {
        return reward;
      }
    }

    return null;
  }

  XpRewardItem? equippedReward(
    XpRewardType type,
  ) {
    final String? selectedId =
        equippedRewardIds[type];

    if (selectedId == null) {
      return null;
    }

    for (final XpRewardItem reward
        in rewards) {
      if (reward.id == selectedId &&
          reward.type == type &&
          isUnlocked(reward)) {
        return reward;
      }
    }

    return null;
  }

  String get equippedTitle {
    final XpRewardItem? reward =
        equippedReward(
      XpRewardType.title,
    );

    return reward?.titleText ?? '';
  }

  Color? get equippedFrameColor {
    return equippedReward(
      XpRewardType.avatarFrame,
    )?.accentColor;
  }

  List<Color> get equippedThemeColors {
    final XpRewardItem? reward =
        equippedReward(
      XpRewardType.profileTheme,
    );

    if (reward != null &&
        reward.themeColors.length >= 2) {
      return reward.themeColors;
    }

    return const <Color>[
      Color(0xFF1D4ED8),
      Color(0xFF7C3AED),
    ];
  }

  XpRewardItem? get equippedAvatar {
    return equippedReward(
      XpRewardType.avatar,
    );
  }

  int progressFor(
    XpRewardItem reward,
  ) {
    return currentXp.value
        .clamp(0, reward.requiredXp);
  }

  double progressRatioFor(
    XpRewardItem reward,
  ) {
    if (reward.requiredXp <= 0) {
      return 1;
    }

    return (
      currentXp.value / reward.requiredXp
    ).clamp(0.0, 1.0);
  }

  int remainingXpFor(
    XpRewardItem reward,
  ) {
    final int remaining =
        reward.requiredXp -
        currentXp.value;

    return remaining > 0 ? remaining : 0;
  }

  Future<void> syncXp(
    int xp, {
    String? userKey,
    bool showUnlockDialog = true,
  }) async {
    final String resolvedKey =
        _normalizeUserKey(userKey);

    final bool userChanged =
        resolvedKey != userStorageKey.value;

    userStorageKey.value = resolvedKey;

    if (userChanged) {
      _restoreEquippedRewards();
    }

    currentXp.value = xp < 0 ? 0 : xp;

    _removeInvalidEquippedRewards();

    final List<XpRewardItem> unlocked =
        rewards.where(isUnlocked).toList();

    final Set<String> seen =
        _readSeenRewardIds();

    final List<XpRewardItem> newlyUnlocked =
        unlocked.where(
      (XpRewardItem reward) =>
          !seen.contains(reward.id),
    ).toList();

    if (newlyUnlocked.isEmpty) {
      return;
    }

    seen.addAll(
      newlyUnlocked.map(
        (XpRewardItem reward) => reward.id,
      ),
    );
    _writeSeenRewardIds(seen);

    if (!showUnlockDialog) {
      return;
    }

    // Tunggu sampai snackbar XP sempat terlihat.
    await Future<void>.delayed(
      const Duration(milliseconds: 550),
    );

    if (Get.isDialogOpen == true) {
      return;
    }

    await Get.dialog<void>(
      _RewardUnlockedDialog(
        rewards: newlyUnlocked,
      ),
      barrierDismissible: false,
    );
  }

  Future<void> equipReward(
    XpRewardItem reward,
  ) async {
    if (!isUnlocked(reward)) {
      Get.snackbar(
        'Hadiah masih terkunci',
        'Kumpulkan ${remainingXpFor(reward)} XP lagi untuk membuka ${reward.name}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFFFF3E0),
        colorText:
            const Color(0xFF9A3412),
        icon: const Icon(
          Icons.lock_rounded,
          color: Color(0xFF9A3412),
        ),
        margin: const EdgeInsets.all(14),
        borderRadius: 16,
      );
      return;
    }

    equippedRewardIds[reward.type] =
        reward.id;

    await _storage.write(
      _equippedStorageKey(
        reward.type,
      ),
      reward.id,
    );

    equippedRewardIds.refresh();

    Get.snackbar(
      'Hadiah digunakan',
      '${reward.name} sekarang aktif di Profil Pembelajaran.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          const Color(0xFFE7F8EE),
      colorText:
          const Color(0xFF166534),
      icon: const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFF166534),
      ),
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
    );
  }

  Future<void> removeEquippedReward(
    XpRewardType type,
  ) async {
    equippedRewardIds.remove(type);
    await _storage.remove(
      _equippedStorageKey(type),
    );
    equippedRewardIds.refresh();
  }

  void _restoreEquippedRewards() {
    equippedRewardIds.clear();

    for (final XpRewardType type
        in XpRewardType.values) {
      final String? id =
          _storage.read<String>(
        _equippedStorageKey(type),
      );

      if (id != null &&
          id.trim().isNotEmpty) {
        equippedRewardIds[type] = id;
      }
    }

    equippedRewardIds.refresh();
  }

  void _removeInvalidEquippedRewards() {
    final List<XpRewardType> invalid =
        <XpRewardType>[];

    for (final MapEntry<
        XpRewardType,
        String> entry
        in equippedRewardIds.entries) {
      bool valid = false;

      for (final XpRewardItem reward
          in rewards) {
        if (reward.type == entry.key &&
            reward.id == entry.value &&
            isUnlocked(reward)) {
          valid = true;
          break;
        }
      }

      if (!valid) {
        invalid.add(entry.key);
      }
    }

    for (final XpRewardType type
        in invalid) {
      equippedRewardIds.remove(type);
      _storage.remove(
        _equippedStorageKey(type),
      );
    }

    if (invalid.isNotEmpty) {
      equippedRewardIds.refresh();
    }
  }

  Set<String> _readSeenRewardIds() {
    final List<dynamic>? raw =
        _storage.read<List<dynamic>>(
      _seenStorageKey,
    );

    if (raw == null) {
      return <String>{};
    }

    return raw
        .map(
          (dynamic item) =>
              item.toString(),
        )
        .toSet();
  }

  Future<void> _writeSeenRewardIds(
    Set<String> ids,
  ) async {
    await _storage.write(
      _seenStorageKey,
      ids.toList()..sort(),
    );
  }

  String _normalizeUserKey(
    String? value,
  ) {
    final String cleaned =
        (value ?? '').trim().toLowerCase();

    if (cleaned.isEmpty) {
      return 'guest';
    }

    return cleaned.replaceAll(
      RegExp(r'[^a-z0-9@._-]'),
      '_',
    );
  }

  String get _seenStorageKey =>
      'xp_rewards_seen_${userStorageKey.value}';

  String _equippedStorageKey(
    XpRewardType type,
  ) {
    return 'xp_reward_equipped_'
        '${userStorageKey.value}_'
        '${type.name}';
  }
}

class _RewardUnlockedDialog
    extends StatelessWidget {
  const _RewardUnlockedDialog({
    required this.rewards,
  });

  final List<XpRewardItem> rewards;

  @override
  Widget build(BuildContext context) {
    final XpRewardItem first =
        rewards.first;

    return AlertDialog(
      icon: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: first.accentColor
              .withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          first.icon,
          color: first.accentColor,
          size: 40,
        ),
      ),
      title: const Text(
        'Hadiah Baru Terbuka! 🎉',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            rewards.length == 1
                ? first.name
                : '${rewards.length} hadiah berhasil dibuka',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rewards.length == 1
                ? first.description
                : rewards
                    .map(
                      (XpRewardItem reward) =>
                          '• ${reward.name}',
                    )
                    .join('\n'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Buka Koleksi Hadiah untuk menggunakannya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Keren!'),
        ),
      ],
    );
  }
}
