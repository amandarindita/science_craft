import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../data/db/database_helper.dart';
import '../../../data/api_service.dart';
// Pastikan import model ini ada
import '../../../models/material_model.dart'; 

class DashboardController extends GetxController {
  // --- DATA USER ---
  final userName = 'Sobat Sains'.obs;
  final userStreak = 0.obs;

  // --- DATA "LANJUTKAN BELAJAR" ---
  final inProgressMaterials = <MaterialItem>[].obs;
  
  final isLoading = true.obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    // 1. Ambil Nama & Streak
    fetchUserProfile();
    
    // 2. Ambil Materi yang "Sedang Berjalan"
    fetchInProgressMaterials();
  }

  // --- FUNGSI 1: AMBIL PROFIL USER ---
  void fetchUserProfile() async {
    try {
      final userData = await ApiService.getUserData();
      if (userData != null) {
        userName.value = userData['username'] ?? 'User';
        userStreak.value = userData['streak'] ?? 0; 
      }
    } catch (e) {
      print("[Dashboard] Gagal ambil data user: $e");
    }
  }

  // --- FUNGSI 2: CARI MATERI YANG BELUM SELESAI (HYBRID FIX) ---
  void fetchInProgressMaterials() async {
    isLoading.value = true;
    try {
      // A. Ambil Semua Judul Materi dari HP (SQLite)
      var allLocalMaterials = await DatabaseHelper.instance.getAllMaterials();

      // B. Ambil Semua Progress dari Server (Flask)
      var serverProgressMap = await ApiService.getAllProgress();

      List<MaterialItem> tempResult = [];

      for (var item in allLocalMaterials) {
        // 1. Default pakai progress LOKAL dulu (dari SQLite)
        double progress = item.progress; 
        
        // 2. Cek apakah server punya data progress? Jika ada, timpa.
        if (serverProgressMap.containsKey(item.id)) {
           progress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           progress = serverProgressMap[item.id.toString()]!; 
        }

        // SYARAT MASUK LIST "LANJUTKAN BELAJAR":
        // - Harus sudah dimulai (> 0.0)
        // - Harus BELUM selesai (< 1.0). Kalau sudah 100% (1.0), jangan tampilkan.
        if (progress > 0.0 && progress < 1.0) {
          tempResult.add(MaterialItem(
            id: item.id,
            title: item.title,
            category: item.category,
            iconPath: item.iconPath,
            progress: progress,
          ));
        }
      }

      // D. Ambil maksimal 3 item saja
      if (tempResult.length > 3) {
        tempResult = tempResult.sublist(0, 3);
      }

      // E. Update UI
      inProgressMaterials.assignAll(tempResult);

    } catch (e) {
      print("[Dashboard] Error fetchInProgress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI 3: NAVIGASI SAAT KARTU DIKLIK ---
  void continueMaterial(MaterialItem item) {
    Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    )?.then((value) {
      // Saat kembali, refresh data agar progress terupdate
      print("[Dashboard] Kembali dari materi, refresh data...");
      fetchInProgressMaterials();
      fetchUserProfile(); 
    });
  }
  
  // --- FUNGSI 4: UPDATE DARI DETAIL PAGE (INSTANT UPDATE) ---
  // Ini dipanggil dari MaterialDetailController saat tombol back ditekan
  void updateLastLearned(String id, String title, double progress, String iconPath){
    print("[Dashboard] Menerima update terakhir: $title ($progress)");

    // LOGIKA BARU: Manipulasi List Secara Manual biar Langsung Muncul
    
    // 1. Hapus item ini dari list jika sudah ada (biar tidak duplikat)
    inProgressMaterials.removeWhere((item) => item.id.toString() == id);

    // 2. Cek Syarat: Kalau progress < 100% dan > 0%, Masukkan ke Paling Atas
    if (progress < 1.0 && progress > 0.0) {
        final newItem = MaterialItem(
          id: int.parse(id),
          title: title,
          category: 'Terbaru', // Kategori dummy, tidak ditampilkan di kartu dashboard
          iconPath: iconPath,
          progress: progress
        );
        
        // Masukkan ke index 0 (Paling Kiri/Atas)
        inProgressMaterials.insert(0, newItem);
        
        // Pastikan list tidak lebih dari 3
        if (inProgressMaterials.length > 3) {
          inProgressMaterials.removeLast();
        }
    } 
    // Jika progress sudah 100% (1.0), item otomatis hilang karena tadi sudah di-remove (langkah 1)
    
    // 3. Refresh Data Penuh di Background (untuk sinkronisasi DB)
    // Kita panggil ini belakangan biar UI-nya update duluan lewat langkah 1 & 2
    fetchInProgressMaterials();
  }

  // --- FUNGSI NAVIGASI MENU ---
  void navigateToSubject(String subjectName) {
     try {
       // Navigasi tab logika (sesuaikan dengan RootController kamu)
       Get.snackbar("Info", "Filter $subjectName dipilih");
     } catch (e) {
       print("RootController belum siap: $e");
     }
  }
}