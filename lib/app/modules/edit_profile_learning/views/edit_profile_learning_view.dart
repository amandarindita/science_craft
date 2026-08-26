import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/edit_profile_learning_controller.dart';

const Color _bg = Color(0xFFF4F8FF);
const Color _primary = Color(0xFF2563EB);
const Color _purple = Color(0xFF7C3AED);
const Color _text = Color(0xFF172033);
const Color _muted = Color(0xFF64748B);

class EditProfileLearningView extends GetView<EditProfileLearningController> {
  const EditProfileLearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Edit Profil Pembelajaran'),
        backgroundColor: Colors.white,
        foregroundColor: _text,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                children: <Widget>[
                  _AvatarHero(controller: controller),
                  const SizedBox(height: 16),
                  _AccountInformationCard(controller: controller),
                  const SizedBox(height: 16),
                  _AvatarPickerCard(controller: controller),
                  const SizedBox(height: 16),
                  _PasswordCard(controller: controller),
                  const SizedBox(height: 20),
                  _SaveButton(controller: controller),
                ],
              ),
      ),
    );
  }
}

class _AvatarHero extends StatelessWidget {
  const _AvatarHero({required this.controller});

  final EditProfileLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF1D4ED8),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x242563EB),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Obx(
            () => Container(
              width: 112,
              height: 112,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: _AvatarImage(path: controller.selectedAvatar.value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Profilmu, versi pembelajaran',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Perubahan nama dan avatar akan langsung tampil di Profil Pembelajaran.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFDCE9FF),
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInformationCard extends StatelessWidget {
  const _AccountInformationCard({required this.controller});

  final EditProfileLearningController controller;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardTitle(
            icon: Icons.person_outline_rounded,
            title: 'Informasi Akun',
            subtitle: 'Ubah identitas profil yang tampil di aplikasi.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.nameController,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              label: 'Nama Lengkap',
              icon: Icons.person_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.emailController,
            readOnly: true,
            decoration: _inputDecoration(
              label: 'Email',
              icon: Icons.email_outlined,
              readOnly: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPickerCard extends StatelessWidget {
  const _AvatarPickerCard({required this.controller});

  final EditProfileLearningController controller;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardTitle(
            icon: Icons.face_retouching_natural_rounded,
            title: 'Pilih Avatar',
            subtitle: 'Gunakan avatar bawaan. Bingkai milestone nanti dipilih dari Koleksi.',
          ),
          const SizedBox(height: 16),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: controller.avatarOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final String avatar = controller.avatarOptions[index];
                final bool selected = controller.selectedAvatar.value == avatar;

                return InkWell(
                  onTap: () => controller.selectAvatar(avatar),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.all(selected ? 4 : 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFF8FAFC),
                      border: Border.all(
                        color: selected
                            ? _primary
                            : const Color(0xFFE2E8F0),
                        width: selected ? 3 : 1,
                      ),
                    ),
                    child: ClipOval(child: _AvatarImage(path: avatar)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded, color: _muted, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Step 1 fokus menyatukan data profil. Avatar frame belum dimasukkan ke Edit Profil karena nanti menjadi reward milestone dan diatur dari halaman Koleksi.',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  const _PasswordCard({required this.controller});

  final EditProfileLearningController controller;

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Obx(() {
        if (!controller.hasPassword.value) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CardTitle(
                icon: Icons.security_rounded,
                title: 'Keamanan Akun',
                subtitle: 'Pengaturan password mengikuti metode login akun.',
              ),
              SizedBox(height: 14),
              _GooglePasswordNotice(),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _CardTitle(
              icon: Icons.security_rounded,
              title: 'Ubah Password',
              subtitle: 'Opsional. Tidak perlu diisi jika hanya ingin mengubah profil.',
            ),
            const SizedBox(height: 16),
            _PasswordField(
              controller: controller.currentPasswordController,
              label: 'Password Saat Ini',
              obscure: controller.isCurrentPasswordObscure.value,
              onToggle: controller.toggleCurrentPasswordVisibility,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: controller.newPasswordController,
              label: 'Password Baru',
              obscure: controller.isNewPasswordObscure.value,
              onToggle: controller.toggleNewPasswordVisibility,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              controller: controller.confirmPasswordController,
              label: 'Konfirmasi Password Baru',
              obscure: controller.isConfirmPasswordObscure.value,
              onToggle: controller.toggleConfirmPasswordVisibility,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: controller.isChangingPassword.value
                    ? null
                    : controller.changePassword,
                icon: controller.isChangingPassword.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_reset_rounded),
                label: Text(
                  controller.isChangingPassword.value
                      ? 'Memproses...'
                      : 'Ubah Password',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _GooglePasswordNotice extends StatelessWidget {
  const _GooglePasswordNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, color: Color(0xFFD97706)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Akun ini menggunakan Google, sehingga password tidak dapat diubah melalui aplikasi.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.controller});

  final EditProfileLearningController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: controller.isSaving.value ? null : controller.saveProfile,
          icon: controller.isSaving.value
              ? const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(
            controller.isSaving.value
                ? 'Menyimpan...'
                : 'Simpan Perubahan Profil',
          ),
          style: FilledButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF93C5FD),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(
        label: label,
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          ),
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFDBEAFE), Color(0xFFEDE9FE)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _primary, size: 22),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _AvatarFallback(),
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, color: _muted, size: 42),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  bool readOnly = false,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: _primary),
    filled: true,
    fillColor: readOnly ? const Color(0xFFF1F5F9) : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _primary, width: 1.7),
    ),
  );
}
