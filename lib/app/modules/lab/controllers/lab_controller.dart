import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../data/api_service.dart'; 
import '../../profile/controllers/profile_controller.dart';
import '../../notification/notification_helper.dart'; // 🌟 Pastikan path ini bener ke lokasi helper lu


class LabController extends GetxController {
  UnityWidgetController? unityWidgetController;
  
  var currentSceneId = ''.obs; 
  var currentMaterialName = ''.obs;
  var currentMaterialId = Rxn<int>();

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
      currentMaterialId.value = int.tryParse(materialIdValue?.toString() ?? '');
    }
  }

    print("[LabController] Scene ID: ${currentSceneId.value}");
    print("[LabController] Material ID: ${currentMaterialId.value}");
    print("[LabController] Material Name: ${currentMaterialName.value}");
  }
  void onUnityCreated(controller) {
  unityWidgetController = controller;

  print("Unity Created! Scene ID yang akan dikirim: ${currentSceneId.value}");

  Future.delayed(const Duration(milliseconds: 500), () {
    loadUnityScene(currentSceneId.value);
   });
  }

  void onUnityMessage(message) async {
    print('Pesan mentah dari Unity: ${message.toString()}');
    String msg = message.toString();

    // 🎯 LOGIKA PERTAMA KALI BUKA LAB
    if (msg == "EXPERIMENTAL_DONE") {
      print("[Unity->Flutter] Eksperimen selesai! Sinkronisasi lab...");

      List<String> pialaBaru = [];
      final matId = currentMaterialId.value;

      if (matId == null) {
        print("[LabController] Material ID kosong, lab tidak disinkronkan.");
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
      pialaBaru = rawBadges.map<String>((e) => e.toString()).toList();

      final xpAdded = int.tryParse(
        (result['xp_added'] ?? 0).toString(),
      ) ?? 0;

      final levelUp = result['level_up'] == true ||
          result['level_up'].toString() == 'true';

      final level = int.tryParse(
        (result['level'] ?? 1).toString(),
      ) ?? 1;

      // Daily Quest lab
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
        Get.dialog(
          LevelUpPopup(newLevel: _levelTitle(level)),
          barrierDismissible: false,
        );
      }

      if (pialaBaru.isNotEmpty) {
        for (var badgeName in pialaBaru) {
          NotificationHelper().showInstantNotification(
            id: badgeName.hashCode,
            title: "Badge Baru Terbuka! 🎉",
            body: "Selamat! Kamu berhasil mendapatkan pencapaian '$badgeName'.",
          );

          Get.dialog(
            _LabBadgeUnlockedPopup(badgeName: badgeName),
            barrierDismissible: false,
          );
        }
      }
    }
    // 🌟 LOGIKA EKSPERIMEN SELESAI (JEDARRR!) 🌟
    if (msg == "EXPERIMENTAL_DONE") {
      print("[Unity->Flutter] Eksperimen selesai! Sinkronisasi & Cek Badge...");
      
      // 1. Tambah XP di server
      List<String> pialaBaru = [];

final matId = currentMaterialId.value;

if (matId != null) {
  final result = await ApiService.completeLab(matId);

  if (result != null) {
    final rawBadges = result['new_badges_unlocked'] ?? [];
    pialaBaru = rawBadges.map<String>((e) => e.toString()).toList();

    final xpAdded = int.tryParse(
      (result['xp_added'] ?? 0).toString(),
    ) ?? 0;

    if (xpAdded > 0 && Get.isRegistered<DashboardController>()) {
      final dash = Get.find<DashboardController>();
      dash.completeDailyQuest('collect_xp', amount: xpAdded);
    }

        Get.snackbar(
          "Eksperimen Selesai!",
          xpAdded > 0
              ? "Kamu mendapatkan +$xpAdded XP."
              : "Eksperimen sudah pernah diselesaikan sebelumnya.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } else {
      print("[LabController] Material ID kosong, lab tidak disinkronkan.");
    }

      // 4. Kalau dapet piala, tembak Pop-Up & Push Notif!
      if (pialaBaru.isNotEmpty) {
        for (var badgeName in pialaBaru) {
          
          // A. Munculin Notifikasi Latar (Push Notif)
          NotificationHelper().showInstantNotification(
            id: badgeName.hashCode, // Biar ID unik gak ketimpa
            title: "Badge Baru Terbuka! 🎉",
            body: "Selamat! Kamu berhasil mendapatkan pencapaian '$badgeName'.",
          );
          
          // B. Munculin Pop-up UI yang bersih & simpel (gak too much)
          Get.dialog(
            AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text("Pencapaian Baru! 🏆"),
              content: Text(
                "Kamu berhasil membuka lencana:\n\n$badgeName", 
                style: const TextStyle(fontSize: 16)
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(), 
                  child: const Text("Mantap!", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                ),
              ],
            ),
            barrierDismissible: false, // Wajib diklik 'Mantap!' baru ilang
          );
        }
      }
      
      // 5. Langsung update UI profil biar pialanya nampil di layar
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchUserProfile();
      }
    }
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
    'GameManager',
    'LoadContent',
    sceneId,
  );
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