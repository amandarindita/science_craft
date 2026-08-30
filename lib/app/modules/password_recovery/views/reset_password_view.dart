import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../routes/app_pages.dart';
import '../controllers/password_recovery_controller.dart';

class ResetPasswordView extends GetView<PasswordRecoveryController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Biru tua Science Craft
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF2563EB),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ================= HEADER =================
              _buildHeader(context),

              // ================= FORM CARD =================
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A0F172A),
                        blurRadius: 20,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atur Kata Sandi Baru 🔑',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pastikan kata sandi baru kuat dan minimal terdiri dari 6 karakter.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Input Password Baru
                        _buildFieldLabel('Kata Sandi Baru'),
                        const SizedBox(height: 8),
                        _buildNewPasswordField(),

                        const SizedBox(height: 18),

                        // Input Konfirmasi Password
                        _buildFieldLabel('Konfirmasi Kata Sandi'),
                        const SizedBox(height: 8),
                        _buildConfirmPasswordField(),

                        const SizedBox(height: 28),

                        // Tombol Simpan
                        _buildSaveButton(),

                        const SizedBox(height: 24),

                        // Footer Kembali ke Login
                        _buildFooterLogin(),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: HEADER
  // -------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/pattern.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.password_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Buat Password Baru',
                    style: GoogleFonts.inter(
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Langkah terakhir untuk mengamankan akunmu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
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

  // -------------------------------------------------------------
  // WIDGET: LABEL INPUT
  // -------------------------------------------------------------
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 13.5,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: FIELD PASSWORD BARU
  // -------------------------------------------------------------
  Widget _buildNewPasswordField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller.newPasswordController,
          obscureText: controller.obscureNewPassword.value,
          textInputAction: TextInputAction.next,
          style: GoogleFonts.inter(
            fontSize: 14.5,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: 'Minimal 6 karakter',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureNewPassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: controller.toggleNewPasswordVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: FIELD KONFIRMASI PASSWORD
  // -------------------------------------------------------------
  Widget _buildConfirmPasswordField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller.confirmPasswordController,
          obscureText: controller.obscureConfirmPassword.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.resetPassword(),
          style: GoogleFonts.inter(
            fontSize: 14.5,
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            hintText: 'Ulangi kata sandi baru',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.lock_reset_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscureConfirmPassword.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: TOMBOL SIMPAN
  // -------------------------------------------------------------
  Widget _buildSaveButton() {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x382563EB),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : controller.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Simpan Kata Sandi',
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: FOOTER LOGIN
  // -------------------------------------------------------------
  Widget _buildFooterLogin() {
    return Center(
      child: TextButton(
        onPressed: () => Get.offAllNamed(Routes.LOGIN),
        child: Text(
          'Kembali ke halaman masuk',
          style: GoogleFonts.inter(
            color: const Color(0xFF2563EB),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}