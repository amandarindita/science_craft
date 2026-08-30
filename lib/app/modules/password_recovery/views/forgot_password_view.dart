import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/password_recovery_controller.dart';

class ForgotPasswordView extends GetView<PasswordRecoveryController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Biru tua Science Craft
      body: Container(
        // Background gradasi biru menyatu dari atas hingga ke belakang card putih
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E3A8A), // Biru tua atas
              Color(0xFF2563EB), // Biru terang bawah
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
                    color: Colors.white, // Putih bersih
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
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pemulihan Akun 🔐',
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Masukkan alamat email yang terdaftar pada akun Science Craft milikmu.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Input Email
                        _buildFieldLabel('Alamat Email'),
                        const SizedBox(height: 8),
                        _buildEmailField(),

                        const SizedBox(height: 28),

                        // Tombol Kirim OTP
                        _buildSubmitButton(),

                        const SizedBox(height: 26),

                        // Footer "Ingat kata sandi? Masuk"
                        _buildFooterBack(),

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
          // Background Pattern Sains
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
                // Tombol Kembali
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.arrow_back,
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
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Text(
                    'Lupa Password?',
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
                    'Kami akan mengirimkan 6 digit kode OTP\nuntuk mengatur ulang kata sandimu.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.white.withOpacity(0.85),
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
  // WIDGET: FIELD EMAIL
  // -------------------------------------------------------------
  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => controller.sendOtp(),
        style: GoogleFonts.inter(
          fontSize: 14.5,
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          hintText: 'nama@email.com',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.alternate_email_rounded,
            color: Color(0xFF2563EB),
            size: 20,
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
    );
  }

  // -------------------------------------------------------------
  // WIDGET: TOMBOL KIRIM OTP
  // -------------------------------------------------------------
  Widget _buildSubmitButton() {
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
          onPressed: controller.isLoading.value ? null : controller.sendOtp,
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
                      'Kirim Kode OTP',
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
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
  // WIDGET: FOOTER KEMBALI
  // -------------------------------------------------------------
  Widget _buildFooterBack() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ingat kata sandi kamu? ',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Masuk',
            style: GoogleFonts.inter(
              color: const Color(0xFF2563EB),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}