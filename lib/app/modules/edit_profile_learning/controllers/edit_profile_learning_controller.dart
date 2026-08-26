import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile_learning/controllers/profile_learning_controller.dart';

class EditProfileLearningController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxString selectedAvatar = 'assets/amanda.png'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool hasPassword = true.obs;

  final RxBool isCurrentPasswordObscure = true.obs;
  final RxBool isNewPasswordObscure = true.obs;
  final RxBool isConfirmPasswordObscure = true.obs;

  /// Avatar yang sudah diketahui dipakai oleh project/backend saat ini.
  /// Avatar user yang sedang aktif otomatis ikut dimasukkan ke daftar,
  /// jadi data lama tetap aman walau tidak ada di list ini.
  final RxList<String> avatarOptions = <String>[
    'assets/aira.png',
    'assets/aqua.png',
    'assets/amanda.png',
  ].obs;

  ProfileLearningController? get learningController =>
      Get.isRegistered<ProfileLearningController>()
          ? Get.find<ProfileLearningController>()
          : null;

  ProfileController? get legacyProfileController =>
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : null;

  @override
  void onInit() {
    super.onInit();
    loadInitialProfile();
  }

  Future<void> loadInitialProfile() async {
    isLoading.value = true;

    try {
      final Map<String, dynamic>? data = await ApiService.getUserData();

      if (data != null) {
        final String username = (data['username'] ?? '').toString().trim();
        final String email = (data['email'] ?? '').toString().trim();
        final String avatar = (data['avatar'] ?? '').toString().trim();

        nameController.text = username.isNotEmpty
            ? username
            : (learningController?.userName.value ?? '');
        emailController.text = email.isNotEmpty
            ? email
            : (learningController?.userEmail.value ?? '');

        selectedAvatar.value = avatar.isNotEmpty
            ? avatar
            : (learningController?.avatarPath.value ?? 'assets/amanda.png');

        hasPassword.value = data['has_password'] is bool
            ? data['has_password'] as bool
            : data['has_password'].toString().toLowerCase() != 'false';
      } else {
        _fillFromLearningProfile();
      }

      _ensureCurrentAvatarIsVisible();
    } catch (_) {
      _fillFromLearningProfile();
      _ensureCurrentAvatarIsVisible();
    } finally {
      isLoading.value = false;
    }
  }

  void _fillFromLearningProfile() {
    final ProfileLearningController? learning = learningController;
    if (learning == null) return;

    nameController.text = learning.userName.value;
    emailController.text = learning.userEmail.value;
    selectedAvatar.value = learning.avatarPath.value;
  }

  void _ensureCurrentAvatarIsVisible() {
    final String avatar = selectedAvatar.value.trim();
    if (avatar.isNotEmpty && !avatarOptions.contains(avatar)) {
      avatarOptions.insert(0, avatar);
    }
  }

  void selectAvatar(String avatarPath) {
    selectedAvatar.value = avatarPath;
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordObscure.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordObscure.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure.toggle();
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;

    final String newName = nameController.text.trim();
    final String avatar = selectedAvatar.value.trim();

    if (newName.isEmpty) {
      Get.snackbar(
        'Nama belum diisi',
        'Masukkan nama lengkap terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (avatar.isEmpty) {
      Get.snackbar(
        'Avatar belum dipilih',
        'Pilih avatar terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSaving.value = true;

    try {
      final bool success = await ApiService.updateProfile(newName, avatar);

      if (!success) {
        Get.snackbar(
          'Gagal menyimpan profil',
          'Perubahan belum tersimpan. Coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFF1F2),
          colorText: const Color(0xFF991B1B),
        );
        return;
      }

      // Sinkronkan langsung ke state Profil Pembelajaran agar UI tidak
      // menunggu request berikutnya untuk menampilkan perubahan.
      final ProfileLearningController? learning = learningController;
      if (learning != null) {
        learning.userName.value = newName;
        learning.avatarPath.value = avatar;
      }

      // Profile lama tetap disegarkan karena user ingin versi lama tetap
      // dapat dibandingkan, tetapi module lama tidak diubah.
      legacyProfileController?.fetchUserProfile();

      // Ambil ulang data server untuk memastikan nama/avatar yang tersimpan
      // benar-benar menjadi sumber data utama.
      if (learning != null) {
        await learning.loadProfile();
      }

      Get.back<bool>(result: true);
      Get.snackbar(
        'Profil diperbarui',
        'Nama dan avatar berhasil disimpan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFECFDF5),
        colorText: const Color(0xFF166534),
      );
    } catch (_) {
      Get.snackbar(
        'Gagal menyimpan profil',
        'Terjadi kendala saat menyimpan perubahan.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword() async {
    if (isChangingPassword.value || !hasPassword.value) return;

    final String oldPassword = currentPasswordController.text;
    final String newPassword = newPasswordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Data belum lengkap',
        'Isi password saat ini, password baru, dan konfirmasi password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Konfirmasi tidak sama',
        'Password baru dan konfirmasi password harus sama.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isChangingPassword.value = true;

    try {
      final Map<String, dynamic> result = await ApiService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final bool success = result['success'] == true;
      final String message = (result['message'] ??
              (success
                  ? 'Password berhasil diperbarui.'
                  : 'Gagal mengubah password.'))
          .toString();

      if (success) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      }

      Get.snackbar(
        success ? 'Password diperbarui' : 'Gagal mengubah password',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: success
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFFF1F2),
        colorText: success
            ? const Color(0xFF166534)
            : const Color(0xFF991B1B),
      );
    } catch (_) {
      Get.snackbar(
        'Gagal mengubah password',
        'Terjadi kendala saat menghubungi server.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isChangingPassword.value = false;
    }
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
