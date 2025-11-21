import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Latar belakang biru tua
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white, // Background putih
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/pattern.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 5.0,
                    opacity: 0.05,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAvatarPreview(),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Informasi Akun'),
                      const SizedBox(height: 16),
                      _buildNameTextField(),
                      const SizedBox(height: 16),
                      _buildEmailTextField(),
                      const SizedBox(height: 30),
                      _buildAvatarGrid(), // Ini sudah punya title sendiri
                      const SizedBox(height: 30),
                      _buildSectionTitle('Ubah Password'),
                      const SizedBox(height: 16),
                      _buildCurrentPasswordField(),
                      const SizedBox(height: 16),
                      _buildNewPasswordField(),
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 24),
                      _buildChangePasswordButton(),
                      const SizedBox(height: 40),
                      _buildSaveButton(), // Tombol simpan utama
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Edit Profil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return Center(
      child: Column(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(controller.selectedAvatar.value),
              onBackgroundImageError: (exception, stackTrace) =>
                  const Icon(Icons.person, size: 60),
            ),
          ),
          TextButton(
            onPressed: () {
              // Logika ganti foto (misal: image_picker) bisa ditambah di controller
              controller.pickImageFromGallery();
            },
            child: const Text(
              'Ganti Foto dari Galeri',
              style: TextStyle(color: Color(0xFF1E3A8A)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widget untuk TextField ---
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isObscure = false,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    const primaryColor = Color(0xFF1E3A8A);
    return TextField(
      controller: controller,
      obscureText: isObscure,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly ? Colors.grey[200] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildNameTextField() {
    return _buildCustomTextField(
      controller: controller.nameController,
      labelText: 'Nama Lengkap',
      icon: Icons.person_outline,
    );
  }

  Widget _buildEmailTextField() {
    return _buildCustomTextField(
      controller: controller.emailController,
      labelText: 'Email',
      icon: Icons.email_outlined,
      readOnly: true, // Email biasanya tidak bisa diubah
    );
  }

  Widget _buildCurrentPasswordField() {
    return Obx(
      () => _buildCustomTextField(
        controller: controller.currentPasswordController,
        labelText: 'Password Saat Ini',
        icon: Icons.lock_outline,
        isObscure: controller.isCurrentPasswordObscure.value,
        suffixIcon: IconButton(
          icon: Icon(
            controller.isCurrentPasswordObscure.value
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: controller.toggleCurrentPasswordVisibility,
        ),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    return Obx(
      () => _buildCustomTextField(
        controller: controller.newPasswordController,
        labelText: 'Password Baru',
        icon: Icons.lock_open_outlined,
        isObscure: controller.isNewPasswordObscure.value,
        suffixIcon: IconButton(
          icon: Icon(
            controller.isNewPasswordObscure.value
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: controller.toggleNewPasswordVisibility,
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Obx(
      () => _buildCustomTextField(
        controller: controller.confirmPasswordController,
        labelText: 'Konfirmasi Password Baru',
        icon: Icons.check_circle_outline,
        isObscure: controller.isConfirmPasswordObscure.value,
        suffixIcon: IconButton(
          icon: Icon(
            controller.isConfirmPasswordObscure.value
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: controller.toggleConfirmPasswordVisibility,
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pilih Avatar'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.avatarOptions.length,
          itemBuilder: (context, index) {
            final avatarPath = controller.avatarOptions[index];
            return Obx(
              () {
                final isSelected = controller.selectedAvatar.value == avatarPath;
                return GestureDetector(
                  onTap: () => controller.selectAvatar(avatarPath),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2A65D8)
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: const Color(0xFF2A65D8).withOpacity(0.3),
                            blurRadius: 10,
                          )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(avatarPath),
                      onBackgroundImageError: (exception, stackTrace) =>
                          const Icon(Icons.person),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => controller.changePassword(),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFF1E3A8A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Ubah Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.saveProfile(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD166), // Tombol kuning
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Simpan Perubahan Profil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
