import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math'; 
import '../../../routes/app_pages.dart';
import '../../../data/db/database_helper.dart';
import '../../../data/api_service.dart';
import '../../../models/material_model.dart'; 

class DashboardController extends GetxController {
  // --- DATA USER ---
  final userName = 'Sobat Sains'.obs;
  final userStreak = 0.obs;

  // --- DATA "LANJUTKAN BELAJAR" ---
  final inProgressMaterials = <MaterialItem>[].obs;
  final isLoading = true.obs;
  final box = GetStorage();

  // --- [BAGIAN FAKTA SAINS] ---
  // Variabel untuk nampung fakta yang sedang tampil
  var currentFact = <String, String>{}.obs;

  // Database Fakta (Versi Clean: Hapus 'title' karena tidak dipakai di UI)
  final List<Map<String, String>> scienceFacts = [
    {'desc': 'Petir 5x lebih panas dari permukaan matahari (30.000°C).'},
    {'desc': 'Jika DNA dibentangkan, panjangnya bisa bolak-balik ke Bulan 6000x.'},
    {'desc': 'Asam lambung (pH 1-2) cukup kuat untuk melarutkan silet logam.'},
    {'desc': 'Di Saturnus dan Jupiter, tekanan atmosfer membuat hujan berlian.'},
    {'desc': 'Seperti sidik jari, setiap orang memiliki pola lidah yang unik.'},
    {'desc': 'Efek Mpemba: Air panas bisa membeku lebih cepat daripada air dingin.'},
    {'desc': 'Warna gas oksigen itu bening, tapi oksigen cair berwarna biru pucat.'},
    {'desc': 'Tulang paha manusia lebih kuat daripada beton dengan ketebalan sama.'},
    {'desc': 'Cahaya matahari butuh 8 menit 20 detik untuk sampai ke Bumi.'},
    {'desc': 'Kaca sebenarnya bukan benda padat sejati, melainkan cairan yang sangat lambat.'},
    {'desc': 'Otakmu menghasilkan listrik 23 watt saat bangun, cukup untuk nyalakan bohlam.'},
    {'desc': 'Satu sendok teh bintang neutron beratnya setara seluruh manusia di Bumi.'},
    {'desc': 'Suara tidak bisa merambat di ruang hampa udara (luar angkasa).'},
    {'desc': 'Kulit adalah organ terbesar di tubuh manusia.'},
    {'desc': 'Tubuh manusia mengandung sekitar 0.2mg emas, terbanyak di dalam darah.'},
    {'desc': 'Di Bulan, berat badanmu hanya 16.5% dari beratmu di Bumi.'},
    {'desc': 'Otot mata adalah otot yang paling cepat bereaksi di seluruh tubuh.'},
    {'desc': 'Helium cair bisa melawan gravitasi dan memanjat dinding wadahnya.'},
    {'desc': '99.99% bagian atom adalah ruang kosong.'},
    {'desc': 'Jumlah bakteri di mulutmu lebih banyak dari jumlah manusia di Bumi.'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    fetchInProgressMaterials();
    
    // Acak fakta saat aplikasi dibuka
    randomizeFact();
  }

  // Fungsi Pengacak (Sederhana)
  void randomizeFact() {
    if (scienceFacts.isNotEmpty) {
      int randomIndex = Random().nextInt(scienceFacts.length);
      currentFact.value = scienceFacts[randomIndex];
    }
  }

  // --- [BAGIAN LOGIKA LAINNYA BIARKAN TETAP SAMA] ---
  
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

  void fetchInProgressMaterials() async {
    isLoading.value = true;
    try {
      var allLocalMaterials = await DatabaseHelper.instance.getAllMaterials();
      var serverProgressMap = await ApiService.getAllProgress();
      List<MaterialItem> tempResult = [];

      for (var item in allLocalMaterials) {
        double progress = item.progress; 
        if (serverProgressMap.containsKey(item.id)) {
           progress = serverProgressMap[item.id]!;
        } else if (serverProgressMap.containsKey(item.id.toString())) {
           progress = serverProgressMap[item.id.toString()]!; 
        }

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

      if (tempResult.length > 3) {
        tempResult = tempResult.sublist(0, 3);
      }
      inProgressMaterials.assignAll(tempResult);

    } catch (e) {
      print("[Dashboard] Error fetchInProgress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void continueMaterial(MaterialItem item) {
    Get.toNamed(
      "${Routes.MATERIAL_DETAIL.replaceAll(':id', '')}${item.id}",
      arguments: item.progress,
    )?.then((value) {
      fetchInProgressMaterials();
      fetchUserProfile(); 
    });
  }
  
  void updateLastLearned(String id, String title, double progress, String iconPath){
    inProgressMaterials.removeWhere((item) => item.id.toString() == id);
    if (progress < 1.0 && progress > 0.0) {
        final newItem = MaterialItem(
          id: int.parse(id),
          title: title,
          category: 'Terbaru',
          iconPath: iconPath,
          progress: progress
        );
        inProgressMaterials.insert(0, newItem);
        if (inProgressMaterials.length > 3) {
          inProgressMaterials.removeLast();
        }
    } 
    fetchInProgressMaterials();
  }

  void navigateToSubject(String subjectName) {
     try {
       Get.snackbar("Info", "Filter $subjectName dipilih");
     } catch (e) {
       print("RootController belum siap: $e");
     }
  }
}