import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../data/api_service.dart';

class EditProfileController extends GetxController {
  // Menangkap ProfileController yang sudah ada
  final ProfileController profileController = Get.find<ProfileController>();

  // State untuk menyimpan nama (diambil dari ProfileController)
  late final TextEditingController nameController;
  // State untuk email
  late final TextEditingController emailController;

  // State untuk password
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // State untuk visibility password
  final isCurrentPasswordObscure = true.obs;
  final isNewPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;

  // State untuk menyimpan avatar yang sedang dipilih di halaman ini
  final selectedAvatar = ''.obs;

  // Daftar semua pilihan avatar yang tersedia
  final List<String> avatarOptions = [
    'assets/volt.png',
    'assets/aira.png',
    'assets/aqua.png', // <-- Path assetmu ada spasi, 'assetsA/'
    'assets/ferro.png',
    'assets/lyra.png',
    'assets/nova.png',
    'assets/orion.png', // Tambah jika ada
    'assets/terra.png', // Tambah jika ada
  ];

  @override
  void onInit() {
    super.onInit();
    // Saat halaman dibuka, isi data awal dari ProfileController
    nameController =
        TextEditingController(text: profileController.userName.value);
    selectedAvatar.value = profileController.avatarPath.value;

    // --- PERBAIKAN DI SINI ---
    // Karena ProfileController tidak punya .userEmail, kita isi dummy
    // Anggap saja emailnya "amanda@example.com"
    emailController = TextEditingController(text: "amanda@example.com");
    // -------------------------

    // Inisialisasi controller password
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  // Fungsi untuk memilih avatar baru dari grid
  void selectAvatar(String newAvatarPath) {
    selectedAvatar.value = newAvatarPath;
  }

  // Fungsi untuk menyimpan perubahan NAMA dan AVATAR
  void saveProfile() async {
    // 1. Validasi nama tidak boleh kosong
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // --- 2. KIRIM KE SERVER (API) ---
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    
    // Panggil fungsi update di API Service
    bool success = await ApiService.updateProfile(nameController.text);
    
    Get.back(); // Tutup loading

    if (success) {
      // --- 3. UPDATE DATA LOKAL (AGAR UI BERUBAH INSTAN) ---
      
      // A. Update Halaman Profil (Ini kode lamamu)
      profileController.userName.value = nameController.text;
      profileController.avatarPath.value = selectedAvatar.value;

      // B. UPDATE DASHBOARD JUGA (INI YANG KURANG)
      // Kita cek apakah DashboardController sedang hidup?
      if (Get.isRegistered<DashboardController>()) {
         // Kita paksa DashboardController untuk update nama user-nya
         final dashboard = Get.find<DashboardController>();
         dashboard.userName.value = nameController.text;
         
         // Atau kalau mau lebih pasti, suruh dia fetch ulang dari server:
         // dashboard.fetchUserProfile(); 
      }

      // 4. Kembali ke halaman sebelumnya
      Get.back();

      // 5. Tampilkan notifikasi sukses
      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // 6. Refresh data profil dari server untuk memastikan sinkronisasi
      profileController.fetchUserProfile(); 
      
    } else {
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan ke server. Cek koneksi internet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // Fungsi untuk mengganti password
  void changePassword() {
    // 1. Validasi field kosong
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Semua field password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 2. Validasi password baru (contoh: minimal 6 karakter)
    if (newPasswordController.text.length < 6) {
      Get.snackbar(
        'Gagal',
        'Password baru minimal harus 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 3. Validasi konfirmasi password
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Gagal',
        'Password baru dan konfirmasi tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 4. (MOCK) Validasi password saat ini
    // Di aplikasi nyata, ini akan dicek ke server
    if (currentPasswordController.text != "123456") {
      // Ganti "123456" dengan logika cek password asli
      Get.snackbar(
        'Gagal',
        'Password saat ini salah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 5. Jika semua validasi lolos (LOGIKA SUKSES)
    // Di sini kamu akan memanggil API untuk ganti password

    // Kosongkan field setelah sukses
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    // Tampilkan notifikasi sukses
    Get.snackbar(
      'Berhasil',
      'Password berhasil diubah!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Fungsi untuk "Ganti Foto"
  void pickImageFromGallery() {
    // Di sini kamu bisa menggunakan package seperti 'image_picker'
    //
    // final ImagePicker picker = ImagePicker();
    // final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //
    // if (image != null) {
    //   // Lakukan sesuatu dengan image.path,
    //   // mungkin upload ke server dan dapatkan URL baru
    //   // Untuk saat ini, kita tampilkan snackbar
    // }

    Get.snackbar(
      'Fitur',
      'Logika ganti foto dari galeri belum diimplementasi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Toggle Functions ---
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordObscure.value = !isCurrentPasswordObscure.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordObscure.value = !isNewPasswordObscure.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

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

