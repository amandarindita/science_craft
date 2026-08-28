import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/api_service.dart';
import '../../../widgets/app_snackbar.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile_learning/controllers/profile_learning_controller.dart';

class AvatarCharacter {
  final String path;
  final String name;
  final String element;
  final Color themeColor;
  final String category; // 'nature', 'energy', 'cosmic'
  final String lore;
  final String traitBadge;

  const AvatarCharacter({
    required this.path,
    required this.name,
    required this.element,
    required this.themeColor,
    this.category = 'nature',
    this.lore = 'Fokus pada eksplorasi dan metodologi sains modern.',
    this.traitBadge = 'General Science',
  });
}

class EditProfileLearningController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString selectedAvatar = 'assets/aira.png'.obs;
  final RxString selectedAvatarCategory = 'all'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool hasPassword = true.obs;

  final RxBool isCurrentPasswordObscure = true.obs;
  final RxBool isNewPasswordObscure = true.obs;
  final RxBool isConfirmPasswordObscure = true.obs;

  /// Daftar lengkap avatar karakter Science Craft dengan tema persona sains modern
  final RxList<AvatarCharacter> avatarList = <AvatarCharacter>[
    const AvatarCharacter(
      path: 'assets/aira.png',
      name: 'Aira',
      element: 'Aerodinamika',
      themeColor: Color(0xFF0284C7),
      category: 'nature',
      lore: 'Eksplorasi fluida udara, tekanan atmosfer, dan kinetika gerak.',
      traitBadge: 'Aerodynamics',
    ),
    const AvatarCharacter(
      path: 'assets/aqua.png',
      name: 'Aqua',
      element: 'Hidrodinamika',
      themeColor: Color(0xFF0EA5E9),
      category: 'nature',
      lore: 'Analisis larutan kimia, termodinamika zat cair, dan struktur molekul.',
      traitBadge: 'Hydrokinetics',
    ),
    const AvatarCharacter(
      path: 'assets/terra.png',
      name: 'Terra',
      element: 'Geosains & Bio',
      themeColor: Color(0xFF10B981),
      category: 'nature',
      lore: 'Penelitian ekosistem biologi, struktur geologi, dan keberlanjutan bumi.',
      traitBadge: 'Geoscience',
    ),
    const AvatarCharacter(
      path: 'assets/volt.png',
      name: 'Volt',
      element: 'Elektromagnetik',
      themeColor: Color(0xFFD97706),
      category: 'energy',
      lore: 'Fisika arus listrik, medan magnet, dan konversi energi terbarukan.',
      traitBadge: 'Electromagnetics',
    ),
    const AvatarCharacter(
      path: 'assets/nova.png',
      name: 'Nova',
      element: 'Optika & Foton',
      themeColor: Color(0xFFF59E0B),
      category: 'energy',
      lore: 'Spektrum gelombang elektromagnetik, radiasi foton, dan teknologi laser.',
      traitBadge: 'Photonics',
    ),
    const AvatarCharacter(
      path: 'assets/ferro.png',
      name: 'Ferro',
      element: 'Material Sains',
      themeColor: Color(0xFF64748B),
      category: 'energy',
      lore: 'Rekayasa material logam, kekuatan mekanik, dan struktur nanoteknologi.',
      traitBadge: 'Materials Science',
    ),
    const AvatarCharacter(
      path: 'assets/lyra.png',
      name: 'Lyra',
      element: 'Fisika Kuantum',
      themeColor: Color(0xFF8B5CF6),
      category: 'cosmic',
      lore: 'Mekanika kuantum partikel subatomik dan komputasi sains tingkat lanjut.',
      traitBadge: 'Quantum Physics',
    ),
    const AvatarCharacter(
      path: 'assets/orion.png',
      name: 'Orion',
      element: 'Astrofisika',
      themeColor: Color(0xFF6366F1),
      category: 'cosmic',
      lore: 'Observasi astronomi, relativitas kosmologi, dan dinamika ruang angkasa.',
      traitBadge: 'Astrophysics',
    ),
  ].obs;

  List<AvatarCharacter> get filteredAvatarList {
    final cat = selectedAvatarCategory.value;
    if (cat == 'all') {
      return avatarList;
    }
    return avatarList.where((char) => char.category == cat).toList();
  }

  AvatarCharacter get currentSelectedCharacter {
    final current = selectedAvatar.value.trim();
    for (final char in avatarList) {
      if (char.path == current) return char;
    }
    return AvatarCharacter(
      path: current,
      name: 'Custom',
      element: 'Peneliti Sains',
      themeColor: const Color(0xFF2563EB),
      lore: 'Persona kustom untuk eksplorasi modul pembelajaran sains.',
      traitBadge: 'Researcher',
    );
  }

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
            : (learningController?.avatarPath.value ?? 'assets/aira.png');

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
    if (avatar.isNotEmpty && !avatarList.any((char) => char.path == avatar)) {
      avatarList.insert(
        0,
        AvatarCharacter(
          path: avatar,
          name: 'Aktif',
          element: 'Peneliti Sains',
          themeColor: const Color(0xFF2563EB),
          category: 'nature',
          lore: 'Avatar aktif yang sedang digunakan.',
          traitBadge: 'Active Profile',
        ),
      );
    }
  }

  void selectAvatar(String avatarPath) {
    selectedAvatar.value = avatarPath;
  }

  void setAvatarCategory(String category) {
    selectedAvatarCategory.value = category;
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
      AppSnackbar.warning(
        'Nama Belum Diisi',
        'Silakan masukkan nama lengkap atau nama tampilan.',
      );
      return;
    }

    if (avatar.isEmpty) {
      AppSnackbar.warning(
        'Avatar Belum Dipilih',
        'Pilih salah satu karakter persona sains di atas.',
      );
      return;
    }

    isSaving.value = true;

    try {
      final bool success = await ApiService.updateProfile(newName, avatar);

      if (!success) {
        AppSnackbar.error(
          'Gagal Menyimpan',
          'Perubahan profil belum tersimpan di server. Silakan coba lagi.',
        );
        return;
      }

      // Sinkronkan langsung ke state Profil Pembelajaran
      final ProfileLearningController? learning = learningController;
      if (learning != null) {
        learning.userName.value = newName;
        learning.avatarPath.value = avatar;
      }

      legacyProfileController?.fetchUserProfile();

      if (learning != null) {
        await learning.loadProfile();
      }

      Get.back<bool>(result: true);
      AppSnackbar.success(
        'Profil Diperbarui',
        'Data nama dan avatar persona berhasil disimpan.',
      );
    } catch (_) {
      AppSnackbar.error(
        'Gagal Menyimpan',
        'Terjadi kendala jaringan saat menyimpan profil.',
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
      AppSnackbar.warning(
        'Data Belum Lengkap',
        'Isi password saat ini, password baru, dan konfirmasi password.',
      );
      return;
    }

    if (newPassword.length < 6) {
      AppSnackbar.warning(
        'Password Terlalu Pendek',
        'Password baru minimal terdiri dari 6 karakter.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      AppSnackbar.warning(
        'Konfirmasi Tidak Cocok',
        'Password baru dan konfirmasi password harus sesuai.',
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
        AppSnackbar.success('Password Diperbarui', message);
      } else {
        AppSnackbar.error('Gagal Mengubah Password', message);
      }
    } catch (_) {
      AppSnackbar.error(
        'Gagal Mengubah Password',
        'Terjadi kendala saat menghubungi server.',
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
