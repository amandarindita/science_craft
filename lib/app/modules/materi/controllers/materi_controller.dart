// --- GANTI SEMUA ISI FILE material_detail_controller.dart KAMU DENGAN INI ---

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/db/database_helper.dart';
import '../../../models/material_model.dart';
import '../../../routes/app_pages.dart';
import '../../../data/api_service.dart';

// --- 1. IMPORT CONTROLLER YANG DIBUTUHKAN ---
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart'; // Untuk 'addXp()'

class MaterialDetailController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final currentProgress = 0.0.obs;
  late double initialProgress;

  final Rx<MaterialContent?> materialContent = Rx<MaterialContent?>(null);
  late String materialId;

  // --- 2. TEMUKAN PROFILE CONTROLLER ---
  final ProfileController profileController = Get.find<ProfileController>();

  // --- 3. UBAH LOGIKA 'SAVING' ---
  bool _isSaving = false;
  // 'Saklar' untuk melacak apakah ada perubahan yang BELUM DISIMPAN
  bool _hasProgressChanged = false;

  @override
  void onInit() {
    super.onInit();
    materialId = Get.parameters['id'] ?? '1';
    initialProgress = (Get.arguments as double?) ?? 0.0;
    currentProgress.value = initialProgress;

    fetchMaterialContent(materialId);

    // --- 4. 'ever' UNTUK MENYALAKAN SAKLAR ---
    // 'ever' akan mendengarkan 'currentProgress'
    // Jika nilainya berubah dan lebih besar dari progress awal,
    // kita nyalakan 'saklar' _hasProgressChanged
    ever(currentProgress, (double newProgress) {
      if (newProgress > initialProgress && !_hasProgressChanged) {
        print("Progress baru terdeteksi!");
        _hasProgressChanged = true;
      }
    });

    scrollController.addListener(_onScroll);
  }

 void _onScroll() {
    if (!scrollController.hasClients) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;

    // --- PERBAIKAN: Jika materi pendek (tidak bisa discroll), anggap langsung 100% ---
    if (maxScroll <= 0) {
      if (currentProgress.value < 1.0) {
         print("Materi pendek terdeteksi, set progress 100%");
         currentProgress.value = 1.0;
      }
      return;
    }
    // -----------------------------------------------------------------------------

    double progress = (currentScroll / maxScroll).clamp(0.0, 1.0);

    // Hanya update jika progress bertambah (biar tidak turun saat scroll ke atas)
    if (progress > currentProgress.value) {
      currentProgress.value = progress;
      // Debugging: Cek di console apakah angka jalan
      print("Scroll Progress: ${(progress * 100).toStringAsFixed(1)}%"); 
    }
  }

  Future<void> fetchMaterialContent(String id) async {
    final dataFromDb =
        await DatabaseHelper.instance.getMaterialById(int.parse(id));

    if (dataFromDb != null) {
      materialContent.value = dataFromDb;
      // Set progress awal dari DB
      initialProgress = dataFromDb.progress;
      currentProgress.value = initialProgress;
    } else {
      // Data dummy jika error
      materialContent.value = MaterialContent(
          title: "Error: Data Tidak Ditemukan",
          introduction:
              "Data untuk materi dengan ID $id tidak ditemukan di database.",
          theorySections: [],
          progress: 0.0,
          iconPath: 'assets/chemistry.png');
    }
  }

  // --- 5. FUNGSI 'goToQuiz' DENGAN LOGIKA XP ---
  void goToQuiz() async {
    // Cek dulu, apakah materi ini SEBELUMNYA sudah 100%?
    bool wasAlreadyCompleted = (initialProgress == 1.0);

    if (!wasAlreadyCompleted) {
      print("Materi selesai! Memberikan XP...");
      
      // 1. Paksa progress jadi 100%
      currentProgress.value = 1.0; 
      _hasProgressChanged = true; // Nyalakan saklar manual

      // 2. Beri 50 XP (panggil fungsi dari ProfileController)
      //    Ini akan OTOMATIS memanggil pop-up Level Up jika XP-nya cukup!
      profileController.addXp(50); 
      
      Get.snackbar(
        "Materi Selesai!", 
        "Kamu mendapatkan 50 XP!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white
      );

    } else {
      print("Materi ini sudah selesai sebelumnya. Tidak ada XP diberikan.");
    }

    // 3. Simpan data (termasuk progress 100% jika ada)
    //    'forceSave: true' memastikan data TETAP tersimpan
    //    walaupun user tidak scroll (misal materi sangat pendek)
    await _saveData(forceSave: true);

    // 4. Lanjut navigasi ke Kuis
    Get.toNamed("${Routes.QUIZ.replaceAll(':id', '')}$materialId");
  }


  // --- 6. FUNGSI '_saveData' YANG LEBIH CERDAS ---
  Future<void> _saveData({bool forceSave = false}) async {
    // Cek agar tidak menyimpan dua kali (misal dari back + onClose)
    if (_isSaving) return;
    
    // HANYA simpan jika 'saklar' nyala, ATAU jika 'dipaksa' (dari goToQuiz)
    if (!_hasProgressChanged && !forceSave) {
      print("[SaveData] Tidak ada progress baru, tidak perlu simpan.");
      return; // Langsung keluar
    }
    
    _isSaving = true; // Tandai sedang menyimpan
    print("[SaveData] Menyimpan progress...");

    try {
      double progressToSave = currentProgress.value;
      final title = materialContent.value?.title ?? 'Judul Tidak Ditemukan';
      final iconPath = materialContent.value?.iconPath ?? 'assets/default_icon.png';
      final db = DatabaseHelper.instance;

      // --- BAGIAN A: SIMPAN HISTORY "LAST LEARNED" ---
      await db.saveSetting('lastLearnedId', materialId);
      await db.saveSetting('lastLearnedTitle', title);
      await db.saveSetting('lastLearnedProgress', progressToSave.toString());
      await db.saveSetting('lastLearnedIconPath', iconPath);
      
      print("History terakhir disimpan (ID: $materialId, Icon: $iconPath).");

      if (Get.isRegistered<DashboardController>()) {
        final dashController = Get.find<DashboardController>();
        dashController.updateLastLearned(materialId, title, progressToSave, iconPath);
      }
      
      // --- BAGIAN B: SIMPAN PROGRESS MATERI ---
      // (Kita hapus 'if (progressToSave > initialProgress)' 
      //  karena sudah ditangani 'saklar' _hasProgressChanged)
      
      await db.updateMaterialProgress(int.parse(materialId), progressToSave);
      await ApiService.syncProgress(int.parse(materialId), progressToSave);
      
      // Reset state setelah berhasil simpan
      initialProgress = progressToSave;
      _hasProgressChanged = false; // Matikan saklar, progress sudah 'up-to-date'

      // Hapus 'teriakan' ke MaterialListController, kita tidak pakai lagi
      // if (Get.isRegistered<MaterialListController>()) { ... }

    } catch (e) {
      print("Error saat _saveData: $e");
    } finally {
      _isSaving = false; // Selesai mencoba simpan
    }
  }

  // --- 7. FUNGSI 'saveAndReturn' YANG BARU ---
  void saveAndReturn() async {
    // Ambil status saklar SEBELUM disimpan
    bool didChange = _hasProgressChanged;

    // 1. Simpan semua data (history dan progress)
    await _saveData(); 
    
    // 2. Kembali dengan mengirim "surat balasan"
    //    (Kirim 'true' JIKA TADI ADA perubahan, 'false' jika tidak)
    Get.back(result: didChange); 
  }

  // --- 8. FUNGSI 'onClose' YANG BARU ---
  @override
  void onClose() {
    print("MaterialDetailController onClose dipanggil.");
    
    // Panggil save DI SINI juga untuk jaga-jaga
    // jika user pakai tombol back fisik (system back button)
    // JANGAN 'await' di sini agar tidak memblokir penutupan halaman
    _saveData();

    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}