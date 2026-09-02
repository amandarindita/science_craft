import 'package:get/get.dart';

import '../models/milestone_reward.dart';
import '../services/milestone_api_service.dart';

/// State milestone Flutter.
///
/// Penting: controller ini BUKAN mesin penentu unlock.
/// Source of truth reward berada di Flask + database.
class MilestoneController extends GetxController {
  static MilestoneController ensureRegistered() {
    if (Get.isRegistered<MilestoneController>()) {
      return Get.find<MilestoneController>();
    }

    return Get.put<MilestoneController>(
      MilestoneController(),
      permanent: true,
    );
  }

  final RxBool isLoading = false.obs;
  final RxBool isUpdatingFrame = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentXp = 0.obs;
  final RxInt unlockedCount = 0.obs;
  final RxInt totalCount = 0.obs;

  final RxInt progressStartXp = 0.obs;
  final RxInt progressTargetXp = 0.obs;
  final RxInt remainingXpToNext = 0.obs;
  final RxDouble progressToNext = 0.0.obs;

  final RxList<MilestoneReward> rewards = <MilestoneReward>[].obs;
  final Rxn<MilestoneReward> nextReward = Rxn<MilestoneReward>();
  final Rxn<MilestoneReward> equippedFrame = Rxn<MilestoneReward>();

  List<MilestoneReward> get unlockedRewards =>
      rewards.where((MilestoneReward item) => item.unlocked).toList();

  List<MilestoneReward> get unlockedAvatarFrames => rewards
      .where((MilestoneReward item) => item.unlocked && item.isAvatarFrame)
      .toList();

  @override
  void onInit() {
    super.onInit();
    loadMilestones();
  }

  Future<void> loadMilestones() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final Map<String, dynamic>? data =
          await MilestoneApiService.getMilestones();

      if (data == null) {
        errorMessage.value = 'Data milestone belum dapat dimuat.';
        return;
      }

      if (data['error'] != null) {
        errorMessage.value = data['error'].toString();
        return;
      }

      _applyState(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> equipFrame(MilestoneReward reward) async {
    if (!reward.isAvatarFrame || !reward.unlocked) return false;

    return _setFrame(reward.id);
  }

  Future<bool> clearEquippedFrame() => _setFrame(null);

  bool isFrameEquipped(MilestoneReward reward) {
    return equippedFrame.value?.id == reward.id;
  }

  Future<bool> _setFrame(String? rewardKey) async {
    if (isUpdatingFrame.value) return false;

    isUpdatingFrame.value = true;
    errorMessage.value = '';

    try {
      final Map<String, dynamic>? result =
          await MilestoneApiService.equipFrame(rewardKey);

      if (result == null) {
        errorMessage.value = 'Bingkai belum dapat diperbarui.';
        return false;
      }

      if (result['error'] != null) {
        errorMessage.value = result['error'].toString();
        return false;
      }

      final dynamic milestone = result['milestone'];
      if (milestone is Map) {
        _applyState(Map<String, dynamic>.from(milestone));
      } else {
        await loadMilestones();
      }

      return true;
    } finally {
      isUpdatingFrame.value = false;
    }
  }

  void _applyState(Map<String, dynamic> data) {
    currentXp.value = _toInt(data['total_xp']);
    unlockedCount.value = _toInt(data['unlocked_count']);
    totalCount.value = _toInt(data['total_count']);

    final dynamic rawRewards = data['rewards'];
    if (rawRewards is List) {
      rewards.assignAll(
        rawRewards
            .whereType<Map>()
            .map(
              (Map item) => MilestoneReward.fromJson(
                Map<String, dynamic>.from(item),
              ),
            ),
      );
    } else {
      rewards.clear();
    }

    final dynamic rawNext = data['next_milestone'];
    nextReward.value = rawNext is Map
        ? MilestoneReward.fromJson(Map<String, dynamic>.from(rawNext))
        : null;

    final dynamic rawEquipped = data['equipped_frame'];
    equippedFrame.value = rawEquipped is Map
        ? MilestoneReward.fromJson(Map<String, dynamic>.from(rawEquipped))
        : null;

    final dynamic rawProgress = data['progress'];
    if (rawProgress is Map) {
      final Map<String, dynamic> progress =
          Map<String, dynamic>.from(rawProgress);
      progressStartXp.value = _toInt(progress['start_xp']);
      progressTargetXp.value = _toInt(progress['target_xp']);
      remainingXpToNext.value = _toInt(progress['remaining_xp']);
      progressToNext.value =
          _toDouble(progress['value']).clamp(0.0, 1.0).toDouble();
    } else {
      progressStartXp.value = 0;
      progressTargetXp.value = 0;
      remainingXpToNext.value = 0;
      progressToNext.value = 0.0;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0.0;
  }
}
