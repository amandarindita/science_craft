import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/password_recovery_controller.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  late final PasswordRecoveryController controller;
  final FocusNode otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<PasswordRecoveryController>()
        ? Get.find<PasswordRecoveryController>()
        : Get.put(PasswordRecoveryController());

    controller.initFromArguments();
    controller.otpController.addListener(_refreshOtpBoxes);
    otpFocusNode.addListener(_refreshOtpBoxes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        otpFocusNode.requestFocus();
      }
    });
  }

  void _refreshOtpBoxes() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.otpController.removeListener(_refreshOtpBoxes);
    otpFocusNode.removeListener(_refreshOtpBoxes);
    otpFocusNode.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final otpValue = controller.otpController.text;

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
                    padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Masukkan Kode OTP ✉️',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kode 6 digit telah dikirimkan ke email kamu.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 6 Digit OTP Box Inputs
                        _buildOtpBoxes(otpValue),

                        const SizedBox(height: 24),

                        // Timer / Kirim Ulang OTP
                        _buildResendSection(),

                        const SizedBox(height: 28),

                        // Tombol Verifikasi
                        _buildVerifyButton(),

                        const SizedBox(height: 20),

                        // Ubah Email
                        TextButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          label: Text(
                            'Ubah alamat email',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),

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
                      Icons.mark_email_read_outlined,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.isRegistration.value
                            ? 'Verifikasi Akun Baru'
                            : 'Verifikasi OTP',
                        style: GoogleFonts.inter(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dikirim ke: ${controller.emailText.value.isNotEmpty ? controller.emailText.value : controller.email}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
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
  // WIDGET: OTP BOXES
  // -------------------------------------------------------------
  Widget _buildOtpBoxes(String otpValue) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!otpFocusNode.hasFocus) {
          otpFocusNode.requestFocus();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. 6 Digit Visual Boxes (Behind, IgnorePointer so taps pass through)
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                final bool hasValue = index < otpValue.length;
                final bool isActive =
                    otpFocusNode.hasFocus &&
                    (index == otpValue.length ||
                        (index == 5 && otpValue.length == 6));

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: hasValue
                        ? const Color(0xFFEFF6FF)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : hasValue
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFFE2E8F0),
                      width: isActive ? 2.0 : 1.2,
                    ),
                    boxShadow: isActive
                        ? const [
                            BoxShadow(
                              color: Color(0x292563EB),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x080F172A),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    hasValue ? otpValue[index] : '',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 2. Invisible TextField covering the FULL area ON TOP for direct native touch
          Positioned.fill(
            child: Opacity(
              opacity: 0.01,
              child: TextField(
                controller: controller.otpController,
                focusNode: otpFocusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enableSuggestions: false,
                autocorrect: false,
                showCursor: false,
                cursorColor: Colors.transparent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) {
                  setState(() {});
                  if (value.length == 6) {
                    FocusScope.of(context).unfocus();
                    controller.verifyOtp();
                  }
                },
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: RESEND SECTION
  // -------------------------------------------------------------
  Widget _buildResendSection() {
    return Obx(
      () => Column(
        children: [
          Text(
            controller.canResendOtp.value
                ? 'Kode OTP sudah kedaluwarsa.'
                : 'Kirim ulang kode dalam ${formatTime(controller.remainingSeconds.value)}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: controller.canResendOtp.value
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: controller.canResendOtp.value &&
                    !controller.isLoading.value
                ? controller.resendOtp
                : null,
            child: Text(
              'Kirim Ulang OTP',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: controller.canResendOtp.value
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // WIDGET: VERIFY BUTTON
  // -------------------------------------------------------------
  Widget _buildVerifyButton() {
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
          onPressed: controller.isLoading.value ? null : controller.verifyOtp,
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
                      'Verifikasi OTP',
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}