import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../../routes/app_pages.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class LabController extends GetxController {
  UnityWidgetController? unityWidgetController;

  final RxString currentSceneId = ''.obs;
  final RxString currentMaterialName = ''.obs;
  final RxnInt currentMaterialId = RxnInt();

  final RxBool isSyncingLab = false.obs;
  final RxBool labCompleted = false.obs;
  final RxString labStatusMessage = ''.obs;

  // Step 8 — semua jalur masuk Lab harus lolos validasi backend.
  final RxBool isCheckingAccess = false.obs;
  final RxBool labAccessGranted = false.obs;

  int? _latestResultId;

  @override
  void onInit() {
    super.onInit();

    final dynamic arguments = Get.arguments;

    if (arguments is Map) {
      final dynamic sceneValue =
          arguments['sceneId'] ??
          arguments['sceneID'] ??
          arguments['unity_scene_id'] ??
          arguments['unitySceneId'] ??
          '';

      final dynamic nameValue =
          arguments['sceneName'] ??
          arguments['materialName'] ??
          arguments['title'] ??
          '';

      final dynamic materialIdValue =
          arguments['materialId'] ??
          arguments['material_id'] ??
          arguments['id'];

      currentSceneId.value =
          sceneValue.toString().trim();
      currentMaterialName.value =
          nameValue.toString().trim();

      if (materialIdValue is int) {
        currentMaterialId.value =
            materialIdValue;
      } else {
        currentMaterialId.value =
            int.tryParse(
          materialIdValue?.toString() ?? '',
        );
      }
    }

    debugPrint(
      '[LabController] scene=${currentSceneId.value}, '
      'material=${currentMaterialId.value}, '
      'name=${currentMaterialName.value}',
    );
  }

  void onUnityCreated(
    UnityWidgetController controller,
  ) {
    unityWidgetController = controller;

    Future<void>.delayed(
      const Duration(milliseconds: 500),
      _validateAccessAndLoadScene,
    );
  }

  void onUnitySceneLoaded(
    SceneLoaded? scene,
  ) {
    debugPrint(
      '[LabController] Unity scene loaded: '
      '${scene?.name}',
    );
  }

  Future<void> onUnityMessage(
    dynamic message,
  ) async {
    final String rawMessage =
        message.toString().trim();

    debugPrint(
      '[Unity -> Flutter] $rawMessage',
    );

    if (rawMessage.isEmpty) {
      return;
    }

    final Map<String, dynamic> payload =
        _decodeUnityPayload(rawMessage);

    final String eventName =
        _eventNameFrom(
      rawMessage,
      payload,
    );

    if (_isResultEvent(eventName)) {
      await _saveResultOnly(payload);
      return;
    }

    if (_isCompletionEvent(eventName)) {
      await _saveAndCompleteLab(payload);
    }
  }

  Future<void> _validateAccessAndLoadScene() async {
    if (isCheckingAccess.value) {
      return;
    }

    final int? materialId = currentMaterialId.value;

    if (materialId == null) {
      labAccessGranted.value = false;
      labStatusMessage.value =
          'Laboratorium belum dapat dibuka.';
      _showError(
        'Data modul tidak ditemukan. Buka laboratorium dari modul pembelajaran.',
      );
      return;
    }

    isCheckingAccess.value = true;
    labStatusMessage.value =
        'Memeriksa syarat laboratorium...';

    try {
      final Map<String, dynamic>? status =
          await ApiService.getModuleStatus(
        materialId,
      );

      if (status == null || _isFailure(status)) {
        labAccessGranted.value = false;
        _showError(
          'Status pembelajaran belum dapat diperiksa. Coba lagi sebentar.',
        );
        return;
      }

      final bool levelUnlocked =
          _toBool(status['level_unlocked']);
      final bool labRequired =
          _toBool(status['lab_required']);
      final bool labUnlocked =
          _toBool(status['lab_unlocked']);

      if (!levelUnlocked ||
          !labRequired ||
          !labUnlocked) {
        labAccessGranted.value = false;
        labStatusMessage.value =
            'Laboratorium belum terbuka.';
        await _showLabLockedDialog();
        return;
      }

      labAccessGranted.value = true;
      labStatusMessage.value =
          'Laboratorium siap dibuka.';
      loadUnityScene(currentSceneId.value);
    } catch (_) {
      labAccessGranted.value = false;
      _showError(
        'Status pembelajaran belum dapat diperiksa. Coba lagi sebentar.',
      );
    } finally {
      isCheckingAccess.value = false;
    }
  }

  Future<void> _showLabLockedDialog() async {
    await Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: <Widget>[
            Icon(
              Icons.lock_rounded,
              color: Color(0xFF64748B),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Laboratorium belum terbuka',
              ),
            ),
          ],
        ),
        content: const Text(
          'Selesaikan materi dan raih nilai kuis minimal 75 pada modul ini terlebih dahulu.',
          style: TextStyle(height: 1.45),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: Get.back,
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              Get.offNamed(
                Routes.LEARNING,
              );
            },
            child: const Text('Ke Modul'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void loadUnityScene(String id) {
    if (!labAccessGranted.value) {
      debugPrint(
        '[LabController] Scene diblokir karena syarat Lab belum tervalidasi.',
      );
      return;
    }

    final String sceneId = id.trim();

    if (sceneId.isEmpty) {
      Get.snackbar(
        'Eksperimen belum tersedia',
        'Modul ini belum memiliki scene Unity.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final controller = unityWidgetController;

    if (controller == null) {
      debugPrint(
        '[LabController] Unity controller belum siap.',
      );
      return;
    }

    controller.postMessage(
      'FlutterBridge',
      'LoadContent',
      sceneId,
    );
  }

  Future<void> _saveResultOnly(
    Map<String, dynamic> unityPayload,
  ) async {
    if (isSyncingLab.value) {
      return;
    }

    final int? materialId =
        currentMaterialId.value;

    if (materialId == null) {
      _showError(
        'Data modul tidak ditemukan.',
      );
      return;
    }

    isSyncingLab.value = true;
    labStatusMessage.value =
        'Menyimpan hasil simulasi...';

    try {
      final result =
          await ApiService.saveModuleLabResult(
        materialId,
        payload: _buildBackendPayload(
          unityPayload,
          completed: false,
        ),
      );

      if (result == null) {
        _showError(
          'Hasil laboratorium belum dapat disimpan. Coba lagi.',
        );
        return;
      }

      if (_isFailure(result)) {
        _showError(
          _messageFrom(result),
        );
        return;
      }

      _latestResultId =
          _toInt(result['result_id']);

      labStatusMessage.value =
          'Hasil simulasi tersimpan.';
    } catch (e) {
      _showError(
        'Hasil laboratorium belum dapat disimpan. Coba lagi.',
      );
    } finally {
      isSyncingLab.value = false;
    }
  }

  Future<void> _saveAndCompleteLab(
    Map<String, dynamic> unityPayload,
  ) async {
    if (isSyncingLab.value ||
        labCompleted.value) {
      return;
    }

    final int? materialId =
        currentMaterialId.value;

    if (materialId == null) {
      _showError(
        'Data modul tidak ditemukan.',
      );
      return;
    }

    isSyncingLab.value = true;
    labStatusMessage.value =
        'Mengirim hasil eksperimen...';

    try {
      int? resultId = _latestResultId;

      if (resultId == null) {
        final saved =
            await ApiService.saveModuleLabResult(
          materialId,
          payload: _buildBackendPayload(
            unityPayload,
            completed: true,
          ),
        );

        if (saved == null) {
          _showError(
            'Hasil laboratorium belum dapat disimpan. Coba lagi.',
          );
          return;
        }

        if (_isFailure(saved)) {
          _showError(
            _messageFrom(saved),
          );
          return;
        }

        resultId =
            _toInt(saved['result_id']);
        _latestResultId = resultId;
      }

      labStatusMessage.value =
          'Memvalidasi penyelesaian lab...';

      final completed =
          await ApiService.completeModuleLab(
        materialId,
        resultId: resultId,
      );

      if (completed == null) {
        _showError(
          'Penyelesaian laboratorium belum dapat diproses. Coba lagi.',
        );
        return;
      }

      if (_isFailure(completed)) {
        _showError(
          _messageFrom(completed),
        );
        return;
      }

      labCompleted.value = true;
      labStatusMessage.value =
          'Laboratorium selesai.';

      await _refreshRelatedFeatures();

      final int xpAdded =
          _toInt(
            completed['total_xp_added'],
          ) ??
          0;

      final bool moduleCompleted =
          _toBool(
        completed['module_completed'],
      );

      Get.snackbar(
        'Eksperimen selesai',
        xpAdded > 0
            ? 'Kamu mendapatkan +$xpAdded XP.'
            : 'Hasil lab sudah tersimpan.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            const Color(0xFFE7F8EE),
        colorText:
            const Color(0xFF166534),
        duration:
            const Duration(seconds: 4),
      );

      if (_toBool(
        completed['level_up'],
      )) {
        await Get.dialog<void>(
          _LabLevelUpDialog(
            level: _toInt(
                  completed[
                      'gamification_level'],
                ) ??
                1,
          ),
          barrierDismissible: false,
        );
      }

      if (moduleCompleted) {
        await Get.dialog<void>(
          const _ModuleCompletedDialog(),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      _showError(
        'Penyelesaian laboratorium belum dapat diproses. Coba lagi.',
      );
    } finally {
      isSyncingLab.value = false;
    }
  }

  Map<String, dynamic> _buildBackendPayload(
    Map<String, dynamic> unityPayload, {
    required bool completed,
  }) {
    final String timestamp =
        DateTime.now()
            .toUtc()
            .toIso8601String();

    final Map<String, dynamic> summary =
        _mapFrom(
      unityPayload['summary_json'] ??
          unityPayload['summaryJson'] ??
          unityPayload['summary'],
    );

    summary.putIfAbsent(
      'status',
      () => completed
          ? 'completed'
          : 'result_received',
    );

    summary.putIfAbsent(
      'source',
      () => 'unity',
    );

    final dynamic rawActivities =
        unityPayload['activities'];

    final List<dynamic> activities =
        rawActivities is List
            ? List<dynamic>.from(
                rawActivities,
              )
            : <dynamic>[
                <String, dynamic>{
                  'event': completed
                      ? 'EXPERIMENTAL_DONE'
                      : 'LAB_RESULT',
                  'timestamp_utc':
                      timestamp,
                },
              ];

    return <String, dynamic>{
      'experiment_id':
          unityPayload['experiment_id'] ??
          unityPayload['experimentId'] ??
          currentSceneId.value,
      'display_name':
          unityPayload['display_name'] ??
          unityPayload['displayName'] ??
          currentMaterialName.value,
      'duration_seconds': _numberValue(
        unityPayload['duration_seconds'] ??
            unityPayload[
                'durationSeconds'],
      ),
      'remaining_seconds': _numberValue(
        unityPayload[
                'remaining_seconds'] ??
            unityPayload[
                'remainingSeconds'],
      ),
      'elapsed_seconds': _numberValue(
        unityPayload['elapsed_seconds'] ??
            unityPayload[
                'elapsedSeconds'],
      ),
      'timestamp_utc':
          unityPayload['timestamp_utc'] ??
          unityPayload['timestampUtc'] ??
          timestamp,
      'summary_json': summary,
      'activities': activities,
      'unity_payload': unityPayload,
    };
  }

  Map<String, dynamic> _decodeUnityPayload(
    String rawMessage,
  ) {
    try {
      final dynamic decoded =
          jsonDecode(rawMessage);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }

      return <String, dynamic>{
        'message': rawMessage,
        'data': decoded,
      };
    } catch (_) {
      return <String, dynamic>{
        'message': rawMessage,
      };
    }
  }

  String _eventNameFrom(
    String rawMessage,
    Map<String, dynamic> payload,
  ) {
    final dynamic event =
        payload['event'] ??
        payload['type'] ??
        payload['status'] ??
        payload['message'] ??
        rawMessage;

    return event
        .toString()
        .trim()
        .toUpperCase();
  }

  bool _isResultEvent(
    String eventName,
  ) {
    return eventName == 'LAB_RESULT' ||
        eventName == 'EXPERIMENT_RESULT' ||
        eventName == 'RESULT_READY';
  }

  bool _isCompletionEvent(
    String eventName,
  ) {
    return eventName ==
            'EXPERIMENTAL_DONE' ||
        eventName ==
            'EXPERIMENT_DONE' ||
        eventName == 'LAB_DONE' ||
        eventName == 'LAB_COMPLETED' ||
        eventName == 'COMPLETED';
  }

  Future<void>
      _refreshRelatedFeatures() async {
    await ApiService.updateDailyQuestProgress(
      'open_lab',
    );

    if (Get.isRegistered<
        DashboardController>()) {
      Get.find<DashboardController>()
          .fetchDailyQuest();
    }

    if (Get.isRegistered<
        ProfileController>()) {
      Get.find<ProfileController>()
          .fetchUserProfile();
    }
  }

  bool _isFailure(
    Map<String, dynamic> data,
  ) {
    return data['success'] == false ||
        (_toInt(data['status_code']) ??
                0) >=
            400;
  }

  String _messageFrom(
    Map<String, dynamic> data,
  ) {
    return (data['error'] ??
            data['message'] ??
            'Terjadi kesalahan.')
        .toString();
  }

  void _showError(String message) {
    labStatusMessage.value = message;

    Get.snackbar(
      'Laboratorium belum berhasil',
      message,
      snackPosition:
          SnackPosition.BOTTOM,
      backgroundColor:
          const Color(0xFFFFE8E8),
      colorText:
          const Color(0xFF8C1D18),
    );
  }

  Map<String, dynamic> _mapFrom(
    dynamic value,
  ) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  int _numberValue(dynamic value) {
    if (value is num) {
      return value.round();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    );
  }

  bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final String text =
        value?.toString().toLowerCase() ??
            '';

    return text == 'true' ||
        text == '1';
  }
}

class _LabLevelUpDialog
    extends StatelessWidget {
  const _LabLevelUpDialog({
    required this.level,
  });

  final int level;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.rocket_launch_rounded,
        color: Color(0xFF2563EB),
        size: 46,
      ),
      title: const Text(
        'Level naik!',
        textAlign: TextAlign.center,
      ),
      content: Text(
        'Selamat, sekarang kamu mencapai level gamifikasi $level.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton(
          onPressed: Get.back,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }
}

class _ModuleCompletedDialog
    extends StatelessWidget {
  const _ModuleCompletedDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.emoji_events_rounded,
        color: Color(0xFF16A34A),
        size: 48,
      ),
      title: const Text(
        'Modul selesai!',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Seluruh materi, kuis, dan laboratorium pada modul ini telah diselesaikan.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton(
          onPressed: Get.back,
          child: const Text('Mantap'),
        ),
      ],
    );
  }
}
