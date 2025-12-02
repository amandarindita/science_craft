import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../data/api_service.dart';

class EditProfileController extends GetxController {
  // Menangkap ProfileController yang sudah ada
  final ProfileController profileController = Get.find<ProfileController>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;

  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  final isCurrentPasswordObscure = true.obs;
  final isNewPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;

  // State untuk menyimpan avatar yang sedang dipilih di halaman ini
  final selectedAvatar = ''.obs;

  // Daftar semua pilihan avatar
  final List<String> avatarOptions = [
    'assets/volt.png',
    'assets/aira.png',
    'assets/aqua.png', 
    'assets/ferro.png',
    'assets/lyra.png',
    'assets/nova.png',
    'assets/orion.png',
    'assets/terra.png',
  ];

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: profileController.userName.value);
    
    // Set avatar awal sesuai yang ada di profil sekarang
    selectedAvatar.value = profileController.avatarPath.value;

    emailController = TextEditingController(text: "siswa@sciencecraft.id");
    
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  // Fungsi untuk memilih avatar baru dari grid
  void selectAvatar(String newAvatarPath) {
    selectedAvatar.value = newAvatarPath;
    // Debug: Pastikan path terpilih benar
    print("Avatar dipilih: $newAvatarPath");
  }

  // --- FUNGSI SAVE PROFILE (DIPERBAIKI) ---
  void saveProfile() async {
    // 1. Validasi
    if (nameController.text.isEmpty) {
      Get.snackbar('Gagal', 'Nama tidak boleh kosong', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // 2. Loading
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    // 3. Kirim ke Server
    bool success = await ApiService.updateProfile(
        nameController.text, 
        selectedAvatar.value
    );
    
    Get.back(); // Tutup loading

    if (success) {
      // --- PERBAIKAN DISINI ---
      
      // A. Update Data Lokal SECARA PAKSA
      // Kita "percaya" bahwa server sukses, jadi kita update tampilan HP duluan.
      profileController.userName.value = nameController.text;
      profileController.avatarPath.value = selectedAvatar.value; // <--- INI KUNCINYA

      // B. Update DashboardController juga biar sinkron
      if (Get.isRegistered<DashboardController>()) {
         final dashboard = Get.find<DashboardController>();
         dashboard.userName.value = nameController.text;
         // dashboard.fetchUserProfile(); // JANGAN PANGGIL INI
      }

      // C. Kembali ke halaman sebelumnya
      Get.back();

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // D. JANGAN PANGGIL fetchUserProfile() DISINI
      // profileController.fetchUserProfile();  <-- INI SAYA HAPUS/KOMENTAR
      // Kenapa? Karena kalau server belum selesai nulis ke DB, dia bakal balikin data lama.
      // Biarkan aplikasi pakai data lokal yang baru saja kita set di poin A.
      
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan ke server.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ... (Sisa fungsi biarkan sama) ...
  
  void changePassword() {
    // ... code change password kamu ...
     if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('Gagal', 'Semua field password harus diisi',
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    // ... validasi lainnya ...
    Get.snackbar('Berhasil', 'Password berhasil diubah (Simulasi)',
      backgroundColor: Colors.green, colorText: Colors.white);
  }

  void pickImageFromGallery() {
    Get.snackbar('Fitur', 'Belum tersedia', snackPosition: SnackPosition.BOTTOM);
  }

  void toggleCurrentPasswordVisibility() => isCurrentPasswordObscure.toggle();
  void toggleNewPasswordVisibility() => isNewPasswordObscure.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordObscure.toggle();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}