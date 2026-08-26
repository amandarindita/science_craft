import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../rewards/controllers/xp_reward_controller.dart';

class LearningStreakDay {
  const LearningStreakDay({
    required this.label,
    required this.dayName,
    required this.date,
    required this.status,
    required this.isToday,
    required this.isFuture,
  });

  final String label;
  final String dayName;
  final String date;
  final String status;
  final bool isToday;
  final bool isFuture;

  bool get isLoginOnly => status == 'login';
  bool get isActive => status == 'active';
  bool get hasActivity =>
      isLoginOnly || isActive;
}

class LearningLevelSummary {
  const LearningLevelSummary({
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.isCompleted,
    required this.completedModules,
    required this.totalModules,
  });

  final int level;
  final double progress;
  final bool isUnlocked;
  final bool isCompleted;
  final int completedModules;
  final int totalModules;

  String get title {
    switch (level) {
      case 1:
        return 'Level 1 • Dasar';
      case 2:
        return 'Level 2 • Menengah';
      case 3:
        return 'Level 3 • Lanjutan';
      default:
        return 'Level $level';
    }
  }

  String get status {
    if (isCompleted) {
      return 'Selesai';
    }

    if (isUnlocked) {
      return 'Sedang dipelajari';
    }

    return 'Terkunci';
  }
}

class ProfileLearningController
    extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  final userName = 'Siswa'.obs;
  final userEmail = ''.obs;
  final avatarPath = 'assets/amanda.png'.obs;

  final currentLearningLevel = 1.obs;
  final currentLevelProgress = 0.0.obs;
  final overallProgress = 0.0.obs;

  final completedModules = 0.obs;
  final totalModules = 0.obs;
  final totalXp = 0.obs;
  final dailyStreak = 0.obs;
  final todayActivityStatus = 'none'.obs;
  final weeklyActivity =
      <LearningStreakDay>[].obs;

  final ownedBadgeCount = 0.obs;
  final totalBadgeCount = 0.obs;

  final levelSummaries =
      <LearningLevelSummary>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final List<dynamic> results =
          await Future.wait<dynamic>(
        <Future<dynamic>>[
          ApiService.getUserData(),
          ApiService.getLearningProgress(),
        ],
      );

      final Map<String, dynamic>? userData =
          results[0] is Map
              ? Map<String, dynamic>.from(
                  results[0] as Map,
                )
              : null;

      final Map<String, dynamic>? learningData =
          results[1] is Map
              ? Map<String, dynamic>.from(
                  results[1] as Map,
                )
              : null;

      _applyUserData(userData);
      _applyLearningData(learningData);

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>()
            .fetchUserProfile();
      }
    } catch (e) {
      debugPrint(
        '[ProfileLearningController] $e',
      );
      errorMessage.value =
          'Profil pembelajaran belum dapat dimuat. Tarik layar ke bawah untuk mencoba lagi.';
    } finally {
      isLoading.value = false;
    }
  }

  void _applyUserData(
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return;
    }

    userName.value =
        (data['username'] ?? 'Siswa').toString();
    userEmail.value =
        (data['email'] ?? '').toString();
    avatarPath.value =
        (data['avatar'] ?? 'assets/amanda.png')
            .toString();

    totalXp.value = _intValue(
      data['total_xp'],
    );
    dailyStreak.value = _intValue(
      data['streak'],
    );
    todayActivityStatus.value =
        (data['daily_status'] ?? 'none')
            .toString();

    final List<Map<String, dynamic>>
        weeklyItems = _mapList(
      data['weekly_activity'],
    );

    if (weeklyItems.isEmpty) {
      _buildFallbackWeek();
    } else {
      weeklyActivity.assignAll(
        weeklyItems.map(
          (Map<String, dynamic> item) =>
              LearningStreakDay(
            label:
                (item['label'] ?? '').toString(),
            dayName:
                (item['day_name'] ?? '').toString(),
            date:
                (item['date'] ?? '').toString(),
            status:
                (item['status'] ?? 'none')
                    .toString(),
            isToday: _boolValue(
              item['is_today'],
            ),
            isFuture: _boolValue(
              item['is_future'],
            ),
          ),
        ),
      );
    }

    final List<dynamic> badges =
        data['badges'] is List
            ? data['badges'] as List
            : <dynamic>[];

    ownedBadgeCount.value = badges.length;

    if (Get.isRegistered<ProfileController>()) {
      totalBadgeCount.value =
          Get.find<ProfileController>()
              .badges
              .length;
    } else {
      totalBadgeCount.value =
          badges.length;
    }

    final XpRewardController rewardController =
        XpRewardController.ensureRegistered();

    rewardController.syncXp(
      totalXp.value,
      userKey: userEmail.value.isNotEmpty
          ? userEmail.value
          : userName.value,
      showUnlockDialog: true,
    );
  }

  void _buildFallbackWeek() {
    final DateTime now = DateTime.now();
    final DateTime monday = now.subtract(
      Duration(days: now.weekday - 1),
    );
    const List<String> labels =
        <String>['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    const List<String> names =
        <String>[
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];

    weeklyActivity.assignAll(
      List<LearningStreakDay>.generate(
        7,
        (int index) {
          final DateTime date =
              monday.add(
            Duration(days: index),
          );
          final bool isToday =
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;

          return LearningStreakDay(
            label: labels[index],
            dayName: names[index],
            date:
                '${date.year.toString().padLeft(4, '0')}-'
                '${date.month.toString().padLeft(2, '0')}-'
                '${date.day.toString().padLeft(2, '0')}',
            status: isToday
                ? todayActivityStatus.value
                : 'none',
            isToday: isToday,
            isFuture: date.isAfter(now),
          );
        },
      ),
    );
  }

  void _applyLearningData(
    Map<String, dynamic>? data,
  ) {
    if (data == null ||
        data['success'] == false) {
      _setEmptyLearningData();
      return;
    }

    final List<Map<String, dynamic>>
        modules = _mapList(
      data['modules'],
    ).where((Map<String, dynamic> item) {
      return !_boolValue(
        item['legacy_mode'],
      );
    }).toList();

    overallProgress.value = _progressValue(
      data['overall_progress'],
    );

    totalModules.value = modules.length;
    completedModules.value =
        modules.where((item) {
      return _boolValue(
        item['module_completed'],
      );
    }).length;

    final List<LearningLevelSummary>
        summaries =
        <LearningLevelSummary>[];

    for (int level = 1;
        level <= 3;
        level++) {
      final List<Map<String, dynamic>>
          levelModules =
          modules.where((item) {
        return _intValue(
              item['level'],
              fallback: 1,
            ) ==
            level;
      }).toList();

      final int completed =
          levelModules.where((item) {
        return _boolValue(
          item['module_completed'],
        );
      }).length;

      final double progress =
          levelModules.isEmpty
              ? 0.0
              : levelModules.fold<double>(
                    0.0,
                    (
                      double sum,
                      Map<String, dynamic>
                          item,
                    ) =>
                        sum +
                        _progressValue(
                          item['progress'],
                        ),
                  ) /
                  levelModules.length;

      final bool unlocked =
          level == 1 ||
          levelModules.any((item) {
            return _boolValue(
              item['is_unlocked'],
            );
          });

      summaries.add(
        LearningLevelSummary(
          level: level,
          progress: progress.clamp(
            0.0,
            1.0,
          ),
          isUnlocked: unlocked,
          isCompleted:
              levelModules.isNotEmpty &&
              completed ==
                  levelModules.length,
          completedModules: completed,
          totalModules:
              levelModules.length,
        ),
      );
    }

    levelSummaries.assignAll(summaries);

    int activeLevel = 1;

    for (final LearningLevelSummary item
        in summaries) {
      if (item.isUnlocked &&
          item.level > activeLevel) {
        activeLevel = item.level;
      }
    }

    currentLearningLevel.value =
        activeLevel;

    final LearningLevelSummary current =
        summaries.firstWhere(
      (LearningLevelSummary item) =>
          item.level == activeLevel,
      orElse: () => summaries.first,
    );

    currentLevelProgress.value =
        current.progress;
  }

  void _setEmptyLearningData() {
    overallProgress.value = 0.0;
    completedModules.value = 0;
    totalModules.value = 0;
    currentLearningLevel.value = 1;
    currentLevelProgress.value = 0.0;

    levelSummaries.assignAll(
      const <LearningLevelSummary>[
        LearningLevelSummary(
          level: 1,
          progress: 0.0,
          isUnlocked: true,
          isCompleted: false,
          completedModules: 0,
          totalModules: 0,
        ),
        LearningLevelSummary(
          level: 2,
          progress: 0.0,
          isUnlocked: false,
          isCompleted: false,
          completedModules: 0,
          totalModules: 0,
        ),
        LearningLevelSummary(
          level: 3,
          progress: 0.0,
          isUnlocked: false,
          isCompleted: false,
          completedModules: 0,
          totalModules: 0,
        ),
      ],
    );
  }

  String get nextLearningMessage {
    if (currentLearningLevel.value == 3) {
      LearningLevelSummary? level3;

      for (final LearningLevelSummary item
          in levelSummaries) {
        if (item.level == 3) {
          level3 = item;
          break;
        }
      }

      if (level3?.isCompleted ?? false) {
        return 'Hebat! Seluruh Level Pembelajaran sudah selesai.';
      }

      return 'Selesaikan seluruh modul Level 3 untuk menuntaskan perjalanan belajarmu.';
    }

    return 'Selesaikan seluruh modul Level ${currentLearningLevel.value} untuk membuka Level ${currentLearningLevel.value + 1}.';
  }

  static List<Map<String, dynamic>>
      _mapList(dynamic raw) {
    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (Map<dynamic, dynamic> item) =>
              Map<String, dynamic>.from(
            item,
          ),
        )
        .toList();
  }

  static int _intValue(
    dynamic raw, {
    int fallback = 0,
  }) {
    if (raw is int) {
      return raw;
    }

    return int.tryParse(
          raw?.toString() ?? '',
        ) ??
        fallback;
  }

  static bool _boolValue(
    dynamic raw,
  ) {
    if (raw is bool) {
      return raw;
    }

    final String value =
        raw?.toString().toLowerCase() ??
            '';

    return value == 'true' ||
        value == '1' ||
        value == 'yes';
  }

  static double _progressValue(
    dynamic raw,
  ) {
    final double value =
        double.tryParse(
              raw?.toString() ?? '',
            ) ??
            0.0;

    final double normalized =
        value > 1 ? value / 100 : value;

    return normalized.clamp(
      0.0,
      1.0,
    );
  }
}
