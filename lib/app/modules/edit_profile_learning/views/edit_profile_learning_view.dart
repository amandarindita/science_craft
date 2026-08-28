import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/edit_profile_learning_controller.dart';

const Color _bg = Color(0xFFF8FAFC);
const Color _primaryBlue = Color(0xFF2563EB);
const Color _darkNavy = Color(0xFF1E3A8A);
const Color _textDark = Color(0xFF1E293B);
const Color _textMuted = Color(0xFF64748B);

class EditProfileLearningView extends GetView<EditProfileLearningController> {
  const EditProfileLearningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              _buildHeroHeader(context),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                  children: [
                    _buildAvatarPickerCard(),
                    const SizedBox(height: 16),
                    _buildAccountInfoCard(),
                    const SizedBox(height: 16),
                    _buildSecurityCard(),
                    const SizedBox(height: 16),
                    _buildScienceTipCard(),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return _buildStickyBottomBar();
      }),
    );
  }

  // ===========================================================================
  // 1. HERO HEADER WITH INTERACTIVE AVATAR STAGE
  // ===========================================================================
  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkNavy, _primaryBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Nav Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => Get.back(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Title
              Column(
                children: [
                  Text(
                    'Edit Profil Pelajar',
                    style: GoogleFonts.poppins(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'SMA Science Explorer 🎓',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF93C5FD),
                    ),
                  ),
                ],
              ),

              // Info / Reset Button
              Material(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Get.dialog(_buildInfoDialog(), barrierDismissible: true);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Interactive Avatar Stage
          Obx(() {
            final activeChar = controller.currentSelectedCharacter;
            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dynamic Theme Glow Ring
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 106,
                      height: 106,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: activeChar.themeColor.withValues(
                              alpha: 0.55,
                            ),
                            blurRadius: 24,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    // White Frame
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeChar.themeColor.withValues(alpha: 0.8),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: _AvatarImage(
                          path: controller.selectedAvatar.value,
                        ),
                      ),
                    ),
                    // Edit Icon Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: activeChar.themeColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Character Identity Chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    // Character & Element Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Color(0xFFFDE047),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${activeChar.name} • ${activeChar.element}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trait Badge Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        activeChar.traitBadge,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE0F2FE),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. AVATAR CHARACTER PICKER CARD
  // ===========================================================================
  Widget _buildAvatarPickerCard() {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.face_retouching_natural_rounded,
            iconColor: Color(0xFF8B5CF6),
            title: 'Karakter Avatar Pelajar',
            subtitle:
                'Pilih persona elemen sains yang mewakili jiwa eksplorasimu!',
          ),
          const SizedBox(height: 8),

          // Category Filter Tabs
          Obx(() {
            final currentCategory = controller.selectedAvatarCategory.value;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterTab(
                    label: 'Semua',
                    badge: '${controller.avatarList.length}',
                    isSelected: currentCategory == 'all',
                    onTap: () => controller.setAvatarCategory('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: '🌿 Alam',
                    isSelected: currentCategory == 'nature',
                    onTap: () => controller.setAvatarCategory('nature'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: '⚡ Energi',
                    isSelected: currentCategory == 'energy',
                    onTap: () => controller.setAvatarCategory('energy'),
                  ),
                  const SizedBox(width: 8),
                  _FilterTab(
                    label: '✨ Kosmik',
                    isSelected: currentCategory == 'cosmic',
                    onTap: () => controller.setAvatarCategory('cosmic'),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // Responsive Avatar Grid
          Obx(() {
            final list = controller.filteredAvatarList;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.74,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final char = list[index];
                final isSelected = controller.selectedAvatar.value == char.path;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.selectAvatar(char.path),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              isSelected
                                  ? _primaryBlue
                                  : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1.2,
                        ),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: _primaryBlue.withValues(alpha: 0.22),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Avatar Circle with Stack Indicator
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? char.themeColor
                                            : const Color(0xFFE2E8F0),
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _AvatarImage(path: char.path),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(2.5),
                                  decoration: const BoxDecoration(
                                    color: _primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Name
                          Text(
                            char.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                              color: isSelected ? _primaryBlue : _textDark,
                            ),
                          ),

                          // Element Tag
                          Text(
                            char.element,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 14),

          // Selected Character Lore & Trait Card
          Obx(() {
            final activeChar = controller.currentSelectedCharacter;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activeChar.themeColor.withValues(alpha: 0.08),
                    const Color(0xFFF8FAFC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: activeChar.themeColor.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: activeChar.themeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tips_and_updates_rounded,
                      color: activeChar.themeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Persona: ${activeChar.name} (${activeChar.element})',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeChar.lore,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: _textMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. ACCOUNT INFORMATION CARD
  // ===========================================================================
  Widget _buildAccountInfoCard() {
    return _ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.badge_outlined,
            iconColor: Color(0xFF0284C7),
            title: 'Informasi Pelajar',
            subtitle:
                'Identitas nama yang tampil di Leaderboard, Lab, dan Quiz.',
          ),
          const SizedBox(height: 18),

          // Name Input
          Text(
            'Nama Lengkap / Tampilan',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.nameController,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
            decoration: _inputDecoration(
              hint: 'Masukkan nama panggilan atau aslimu',
              prefixIcon: Icons.person_rounded,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '💡 Nama ini akan dicantumkan pada sertifikat dan pencapaian milestone.',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted),
          ),
          const SizedBox(height: 16),

          // Email Input (Read-only)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alamat Email Pelajar',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 11, color: _textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Terkunci 🔒',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.emailController,
            readOnly: true,
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textMuted),
            decoration: _inputDecoration(
              hint: 'Email akun terdaftar',
              prefixIcon: Icons.alternate_email_rounded,
              isReadOnly: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Email terhubung langsung dengan akun autentikasi data belajar kamu.',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: _textMuted),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. SECURITY & PASSWORD CARD
  // ===========================================================================
  Widget _buildSecurityCard() {
    return _ModernCard(
      child: Obx(() {
        if (!controller.hasPassword.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _CardHeader(
                icon: Icons.security_rounded,
                iconColor: Color(0xFF10B981),
                title: 'Keamanan Akun Pelajar',
                subtitle:
                    'Pengaturan keamanan akun terkelola lewat akun pihak ketiga.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.g_mobiledata_rounded,
                        color: _primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akun Google Terhubung',
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _darkNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Akun ini masuk menggunakan Google Sign-In. Password dan keamanan dikelola langsung melalui akun Google kamu.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: _textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CardHeader(
              icon: Icons.lock_outline_rounded,
              iconColor: Color(0xFF10B981),
              title: 'Ubah Kata Sandi',
              subtitle:
                  'Opsional. Isi formulir jika ingin mengganti password login.',
            ),
            const SizedBox(height: 18),

            // Current Password
            _buildPasswordField(
              controller: controller.currentPasswordController,
              label: 'Password Saat Ini',
              obscure: controller.isCurrentPasswordObscure.value,
              onToggle: controller.toggleCurrentPasswordVisibility,
            ),
            const SizedBox(height: 14),

            // New Password
            _buildPasswordField(
              controller: controller.newPasswordController,
              label: 'Password Baru',
              obscure: controller.isNewPasswordObscure.value,
              onToggle: controller.toggleNewPasswordVisibility,
            ),
            const SizedBox(height: 14),

            // Confirm Password
            _buildPasswordField(
              controller: controller.confirmPasswordController,
              label: 'Konfirmasi Password Baru',
              obscure: controller.isConfirmPasswordObscure.value,
              onToggle: controller.toggleConfirmPasswordVisibility,
            ),
            const SizedBox(height: 18),

            // Change Password Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    controller.isChangingPassword.value
                        ? null
                        : controller.changePassword,
                icon:
                    controller.isChangingPassword.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryBlue,
                          ),
                        )
                        : const Icon(Icons.lock_reset_rounded, size: 18),
                label: Text(
                  controller.isChangingPassword.value
                      ? 'Menyimpan Password...'
                      : 'Perbarui Kata Sandi',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBlue,
                  side: const BorderSide(color: Color(0xFFBFDBFE), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // 5. HIGH SCHOOL SCIENCE TIP BANNER
  // ===========================================================================
  Widget _buildScienceTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.science_rounded,
              color: _primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡 Tips Eksplorasi Sains SMA',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _darkNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selesaikan eksperimen virtual di Lab Sains dan kuis harian untuk membuka bingkai avatar eksklusif di menu Koleksi Milestone!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. STICKY BOTTOM SAVE BUTTON
  // ===========================================================================
  Widget _buildStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed:
                controller.isSaving.value ? null : controller.saveProfile,
            icon:
                controller.isSaving.value
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.rocket_launch_rounded, size: 20),
            label: Text(
              controller.isSaving.value
                  ? 'Menyimpan Perubahan...'
                  : 'Simpan Perubahan Profil',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: _primaryBlue.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 7. HELPER COMPONENTS & DIALOG
  // ===========================================================================
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textDark,
      ),
      decoration: _inputDecoration(
        hint: label,
        prefixIcon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: _textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryBlue),
          SizedBox(height: 16),
          Text(
            'Memuat data profil pelajar...',
            style: TextStyle(color: _textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: _primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Profil Pelajar SMA',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Avatar dan nama yang kamu atur di sini akan menjadi identitas sainsmu di seluruh aplikasi Science Craft, termasuk pada peringkat leaderboard, catatan lab virtual, dan kuis sains.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: _textMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Mengerti 👍'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// FILTER PILL TAB WIDGET (MATCHING NOTIFICATION STYLE)
// =============================================================================
class _FilterTab extends StatelessWidget {
  final String label;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6.5),
          decoration: BoxDecoration(
            gradient:
                isSelected
                    ? const LinearGradient(
                      colors: [_darkNavy, _primaryBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _primaryBlue : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: _primaryBlue.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : _textDark,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MODERN CARD & HEADER WIDGETS
// =============================================================================
class _ModernCard extends StatelessWidget {
  final Widget child;

  const _ModernCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _CardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: _textMuted,
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
  final String path;

  const _AvatarImage({required this.path});

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
      child: const Icon(Icons.person_rounded, color: _textMuted, size: 36),
    );
  }
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData prefixIcon,
  bool isReadOnly = false,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 13.5,
      color: _textMuted.withValues(alpha: 0.7),
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: isReadOnly ? _textMuted : _primaryBlue,
      size: 20,
    ),
    filled: true,
    fillColor: isReadOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: _primaryBlue, width: 1.8),
    ),
  );
}
