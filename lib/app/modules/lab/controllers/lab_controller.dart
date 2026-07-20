import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../data/api_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../notification/notification_helper.dart';


class LabController extends GetxController {
  UnityWidgetController? unityWidgetController;

  var currentSceneId = ''.obs;
  var currentMaterialName = ''.obs;
  var currentMaterialId = Rxn<int>();

  bool _isSubmittingExperiment = false;

  @override
  void onInit() {
    super.onInit();

    print("[LabController] Arguments masuk: ${Get.arguments}");

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;

      final sceneValue =
          args['sceneId'] ??
          args['sceneID'] ??
          args['unity_scene_id'] ??
          args['unitySceneId'] ??
          '';

      final nameValue =
          args['sceneName'] ??
          args['materialName'] ??
          args['title'] ??
          '';

      final materialIdValue =
          args['materialId'] ??
          args['material_id'] ??
          args['id'];

      currentSceneId.value = sceneValue.toString().trim();
      currentMaterialName.value = nameValue.toString();

      if (materialIdValue is int) {
        currentMaterialId.value = materialIdValue;
      } else {
        currentMaterialId.value =
            int.tryParse(materialIdValue?.toString() ?? '');
      }
    }

    print("[LabController] Scene ID: ${currentSceneId.value}");
    print("[LabController] Material ID: ${currentMaterialId.value}");
    print("[LabController] Material Name: ${currentMaterialName.value}");
  }

  void onUnityCreated(UnityWidgetController controller) {
    unityWidgetController = controller;

    print(
      "Unity Created! Scene ID yang akan dikirim: ${currentSceneId.value}",
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      loadUnityScene(currentSceneId.value);
    });
  }

  void onUnitySceneLoaded(SceneLoaded? scene) {
    print('Scene Loaded: ${scene?.name}');
  }

  void loadUnityScene(String id) {
    final sceneId = id.trim();

    if (sceneId.isEmpty) {
      print("[LabController] Scene ID kosong. Unity tidak akan load scene.");

      Get.snackbar(
        "Eksperimen belum tersedia",
        "Materi ini belum memiliki praktikum virtual.",
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    if (unityWidgetController == null) {
      print("[LabController] Unity controller belum siap.");
      return;
    }

    print("[LabController] Mengirim scene ke Unity: $sceneId");

    unityWidgetController!.postMessage(
      'FlutterBridge',
      'LoadContent',
      sceneId,
    );
  }

  void onUnityMessage(dynamic message) async {
    final String rawMessage = message.toString();

    print('Pesan mentah dari Unity: $rawMessage');

    String? eventType;
    Map<String, dynamic>? unityPayload;

    try {
      final decoded = jsonDecode(rawMessage);

      if (decoded is Map<String, dynamic>) {
        unityPayload = decoded;
        eventType = decoded['eventType']?.toString();
      }
    } catch (e) {
      // Fallback kalau Unity hanya kirim string biasa.
      eventType = rawMessage;
    }

    print("[LabController] Event Type dari Unity: $eventType");

    if (eventType == "EXPERIMENTAL_DONE") {
      await _handleExperimentDone(unityPayload);
    }
  }

  Future<void> _handleExperimentDone(
    Map<String, dynamic>? unityPayload,
  ) async {
    if (_isSubmittingExperiment) {
      print("[LabController] Submit experiment sedang berjalan, skip duplikat.");
      return;
    }

    _isSubmittingExperiment = true;

    try {
      print("[Unity->Flutter] Eksperimen selesai. Sinkronisasi lab...");

      final matId = currentMaterialId.value;

      if (matId == null) {
        print("[LabController] Material ID kosong, lab tidak disinkronkan.");

        Get.snackbar(
          "Gagal Sinkronisasi",
          "Material ID tidak ditemukan.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return;
      }

      final result = await ApiService.completeLab(matId);

      if (result == null) {
        Get.snackbar(
          "Gagal",
          "Eksperimen selesai, tapi data gagal dikirim ke server.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        return;
      }

      final rawBadges = result['new_badges_unlocked'] ?? [];
      final List<String> pialaBaru =
          rawBadges.map<String>((e) => e.toString()).toList();

      final xpAdded = int.tryParse(
            (result['xp_added'] ?? 0).toString(),
          ) ??
          0;

      final levelUp = result['level_up'] == true ||
          result['level_up'].toString() == 'true';

      final level = int.tryParse(
            (result['level'] ?? 1).toString(),
          ) ??
          1;

      await ApiService.updateDailyQuestProgress('open_lab');

      if (xpAdded > 0) {
        await ApiService.updateDailyQuestProgress(
          'collect_xp',
          amount: xpAdded,
        );
      }

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().fetchDailyQuest();
      }

      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }

      Get.snackbar(
        "Eksperimen Selesai!",
        xpAdded > 0
            ? "Kamu mendapatkan +$xpAdded XP."
            : "Eksperimen ini sudah pernah kamu selesaikan sebelumnya.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      if (levelUp) {
        await Get.dialog(
          LevelUpPopup(newLevel: _levelTitle(level)),
          barrierDismissible: false,
        );
      }

      if (pialaBaru.isNotEmpty) {
        for (final badgeName in pialaBaru) {
          NotificationHelper().showInstantNotification(
            id: badgeName.hashCode,
            title: "Badge Baru Terbuka! 🎉",
            body:
                "Selamat! Kamu berhasil mendapatkan pencapaian '$badgeName'.",
          );

          await Get.dialog(
            _LabBadgeUnlockedPopup(badgeName: badgeName),
            barrierDismissible: false,
          );
        }
      }

      if (unityPayload != null) {
        await _showUnityExperimentHistory(unityPayload);
      } else {
        print("[LabController] Unity payload kosong. History tidak ditampilkan.");
      }
    } catch (e) {
      print("[LabController] Error handle experiment done: $e");

      Get.snackbar(
        "Lab selesai",
        "Eksperimen selesai, tapi sinkronisasi gagal.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      _isSubmittingExperiment = false;
    }
  }

  Future<void> _showUnityExperimentHistory(
    Map<String, dynamic> payload,
  ) async {
    final String displayName =
        payload['displayName']?.toString().isNotEmpty == true
            ? payload['displayName'].toString()
            : currentMaterialName.value.isNotEmpty
                ? currentMaterialName.value
                : "Hasil Eksperimen";

    final int elapsedSeconds = int.tryParse(
          payload['elapsedSeconds']?.toString() ?? '0',
        ) ??
        0;

    final int durationSeconds = int.tryParse(
          payload['durationSeconds']?.toString() ?? '0',
        ) ??
        0;

    final List<dynamic> activities =
        payload['activities'] is List ? payload['activities'] as List : [];

    final Map<String, dynamic> summary = _parseSummaryJson(payload);

    await Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 5,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            Row(
              children: [
                const Icon(
                  Icons.science,
                  color: Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              durationSeconds > 0
                  ? "Durasi: $elapsedSeconds detik / $durationSeconds detik"
                  : "Durasi: $elapsedSeconds detik",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 18),

            if (summary.isNotEmpty) ...[
              const Text(
                "Ringkasan Eksperimen",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: summary.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        "${_formatKey(entry.key)}: ${entry.value}",
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 18),
            ],

            const Text(
              "Riwayat Aktivitas",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: activities.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada riwayat aktivitas.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const Divider(height: 18),
                      itemBuilder: (context, index) {
                        final activity = activities[index];

                        final timeLabel =
                            activity is Map
                                ? activity['timeLabel']?.toString() ?? "--:--"
                                : "--:--";

                        final actionKey =
                            activity is Map
                                ? activity['actionKey']?.toString() ?? "-"
                                : "-";

                        final description =
                            activity is Map
                                ? activity['description']?.toString() ?? "-"
                                : activity.toString();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 62,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                timeLabel,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    actionKey,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Tutup",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  Map<String, dynamic> _parseSummaryJson(Map<String, dynamic> payload) {
    try {
      final rawSummary =
          payload['summaryJson'] ??
          payload['summary_json'] ??
          payload['summary'];

      if (rawSummary == null) {
        return {};
      }

      if (rawSummary is Map<String, dynamic>) {
        return rawSummary;
      }

      if (rawSummary is String && rawSummary.trim().isNotEmpty) {
        final decoded = jsonDecode(rawSummary);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (e) {
      print("[LabController] Gagal parsing summaryJson: $e");
    }

    return {};
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        );
  }

  String _levelTitle(int level) {
    if (level == 1) {
      return "Level 1: Siswa Baru 🔬";
    } else if (level == 2) {
      return "Level 2: Peneliti Junior 🧪";
    } else if (level == 3) {
      return "Level 3: Asisten Lab 🧬";
    } else if (level == 4) {
      return "Level 4: Ahli Sains 🌌";
    } else {
      return "Level $level: Professor Madya 🧠";
    }
  }
}
class _LabBadgeUnlockedPopup extends StatelessWidget {
  final String badgeName;

  const _LabBadgeUnlockedPopup({
    Key? key,
    required this.badgeName,
  }) : super(key: key);

  String _getBadgeImagePath(String name) {
    switch (name) {
      case "Darwin’s Successor":
        return "assets/badge/1.png";
      case "Quantum Overlord":
        return "assets/badge/2.png";
      case "The Modern Alchemist":
        return "assets/badge/3.png";
      case "Virtual Researcher":
        return "assets/badge/4.png";
      case "Mad Scientist":
        return "assets/badge/5.png";
      case "Grand Analyst":
        return "assets/badge/6.png";
      case "Lab Regular":
        return "assets/badge/7.png";
      case "First Spark":
        return "assets/badge/8.png";
      case "Trivia Rover":
        return "assets/badge/9.png";
      case "Night Owl":
        return "assets/badge/10.png";
      case "Flawless Victory":
        return "assets/badge/11.png";
      default:
        return "assets/badge/8.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _getBadgeImagePath(badgeName);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.only(
              top: 80,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "PENCAPAIAN BARU!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF6C63FF),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Selamat! Kamu berhasil membuka lencana:\n\n$badgeName",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "MANTAP!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.6),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}