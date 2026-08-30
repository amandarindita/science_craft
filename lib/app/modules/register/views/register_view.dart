import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Biru atas
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
              // ================= HEADER BIRU (TRANSPARAN, MENYATU DENGAN BACKGROUND) =================
              _buildHeader(context),

              // ================= FORM REGISTER CARD PUTIH BERSIH =================
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
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul & Sambutan
                        Text(
                          'Buat Akun Baru 🚀',
                          style: GoogleFonts.inter(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Daftar sekarang untuk memulai eksplorasi sains interaktif di Science Craft.',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Input Username
                        _buildFieldLabel('Nama Pengguna (Username)'),
                        const SizedBox(height: 8),
                        _buildUsernameField(),

                        const SizedBox(height: 16),

                        // Input Email
                        _buildFieldLabel('Alamat Email'),
                        const SizedBox(height: 8),
                        _buildEmailField(),

                        const SizedBox(height: 16),

                        // Input Password
                        _buildFieldLabel('Kata Sandi'),
                        const SizedBox(height: 8),
                        _buildPasswordField(),

                        const SizedBox(height: 24),

                        // Tombol Register Utama
                        _buildRegisterButton(),

                        const SizedBox(height: 20),

                        // Divider "atau"
                        _buildDivider(),

                        const SizedBox(height: 18),

                        // Tombol Register with Google
                        _buildGoogleButton(),

                        const SizedBox(height: 24),

                        // Footer "Sudah punya akun? Masuk"
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
  // WIDGET: HEADER BERGRADASI DENGAN ILUSTRASI & TAB
  // -------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 205,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
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

          // Karakter Science Craft di Kiri Bawah (Menempel rapi di batas atas card)
          Positioned(
            bottom: 0,
            left: 14,
            child: Image.asset(
              'assets/chara_login.png',
              height: 175,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // Badge Mini Brand di Kanan Atas
          Positioned(
            top: 16,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.32),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.science_rounded,
                    color: Color(0xFFFFD166),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Science Craft',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Switcher Folder di Bawah Header
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tab Masuk (Tidak Aktif -> kembali ke login)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    child: Container(
                      width: 125,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.24),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Tab Daftar (Aktif di Register)
                Container(
                  width: 125,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Daftar',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ],
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
  // WIDGET: FIELD USERNAME
  // -------------------------------------------------------------
  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller.usernameController,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.inter(
          fontSize: 14.5,
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          hintText: 'nama_pengguna',
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.person_outline_rounded,
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
        textInputAction: TextInputAction.next,
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
  // WIDGET: FIELD PASSWORD
  // -------------------------------------------------------------
  Widget _buildPasswordField() {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordHidden.value,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => controller.register(),
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
                controller.isPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: controller.togglePasswordVisibility,
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
  // WIDGET: TOMBOL REGISTER UTAMA
  // -------------------------------------------------------------
  Widget _buildRegisterButton() {
    return Container(
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
        onPressed: () => controller.register(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Daftar Sekarang',
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
    );
  }

  // -------------------------------------------------------------
  // WIDGET: DIVIDER
  // -------------------------------------------------------------
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'atau daftar dengan',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFE2E8F0),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // WIDGET: TOMBOL GOOGLE
  // -------------------------------------------------------------
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => controller.registerWithGoogle(),
        icon: Image.asset(
          'assets/google.png',
          height: 20,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.g_mobiledata_rounded,
            size: 26,
            color: Color(0xFF4285F4),
          ),
        ),
        label: Text(
          'Daftar dengan Google',
          style: GoogleFonts.inter(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: FOOTER LOGIN
  // -------------------------------------------------------------
  Widget _buildFooterLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: GoogleFonts.inter(
            color: const Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () => Get.back(),
          child: Text(
            'Masuk Sekarang',
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
