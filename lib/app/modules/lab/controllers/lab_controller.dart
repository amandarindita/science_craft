import 'package:get/get.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class LabController extends GetxController {
  UnityWidgetController? unityWidgetController;
  
  // Data materi yang dikirim dari halaman sebelumnya
  var currentMaterialId = 0.obs;
  var currentMaterialName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data arguments (ID & Nama Scene)
    if (Get.arguments != null) {
      currentMaterialId.value = Get.arguments['sceneID'] ?? 0;
      currentMaterialName.value = Get.arguments['sceneName'] ?? '';
    }
  }

  // 1. Dipanggil saat Unity sudah siap (WAJIB ADA)
  void onUnityCreated(controller) {
    unityWidgetController = controller;
    print("Unity Created! Loading Scene ID: ${currentMaterialId.value}");
    
    // Kirim perintah ke Unity buat load materi
    loadUnityScene(currentMaterialId.value);
  }

  // 2. Dipanggil kalau Unity kirim pesan balik ke Flutter (WAJIB ADA krn dipanggil di View)
  void onUnityMessage(message) {
    print('Pesan dari Unity: ${message.toString()}');
  }

  // 3. Dipanggil saat Scene Unity selesai loading (WAJIB ADA krn dipanggil di View)
  void onUnitySceneLoaded(SceneLoaded? scene) {
    print('Scene Loaded: ${scene?.name}');
  }

  // Fungsi kirim data ke Unity
  void loadUnityScene(int id) {
    if (unityWidgetController != null) {
      // PostMessage('NamaGameObject', 'NamaFungsiC#', 'Parameter')
      unityWidgetController!.postMessage(
        'GameManager', 
        'LoadContent', 
        id.toString(),
      );
    }
  }
}