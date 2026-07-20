import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/password_recovery_controller.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() =>
      _OtpVerificationViewState();
}

class _OtpVerificationViewState
    extends State<OtpVerificationView> {
  final PasswordRecoveryController controller =
      Get.find<PasswordRecoveryController>();

  final FocusNode otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller.otpController.addListener(_refreshOtpBoxes);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      otpFocusNode.requestFocus();
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
    otpFocusNode.dispose();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final otpValue = controller.otpController.text;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 285,
              decoration: const BoxDecoration(
                color: Color(0xFF3578E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(70),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Icon(
                    Icons.mark_email_read_outlined,
                    color: Colors.white,
                    size: 78,
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Verifikasi OTP",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Masukkan 6 digit kode yang dikirim ke\n"
                    "${controller.email}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 45),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Kode OTP",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Kode OTP berlaku selama 60 detik.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 25),

                        GestureDetector(
                          onTap: () {
                            otpFocusNode.requestFocus();
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: TextField(
                                  controller:
                                      controller.otpController,
                                  focusNode: otpFocusNode,
                                  keyboardType:
                                      TextInputType.number,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      6,
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {});

                                    if (value.length == 6) {
                                      FocusScope.of(context)
                                          .unfocus();
                                    }
                                  },
                                  decoration:
                                      const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  final hasValue =
                                      index < otpValue.length;

                                  final isActive =
                                      index == otpValue.length &&
                                          otpValue.length < 6;

                                  return Container(
                                    width: 43,
                                    height: 55,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: hasValue
                                          ? const Color(0xFFEAF2FF)
                                          : const Color(0xFFF7F8FA),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isActive
                                            ? const Color(
                                                0xFF3578E5,
                                              )
                                            : hasValue
                                                ? const Color(
                                                    0xFF3578E5,
                                                  )
                                                : const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                        width: isActive ? 1.8 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      hasValue
                                          ? otpValue[index]
                                          : "",
                                      style: const TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        Obx(
                          () => Text(
                            controller.canResendOtp.value
                                ? "Kode OTP sudah kedaluwarsa."
                                : "Kirim ulang dalam "
                                    "${formatTime(controller.remainingSeconds.value)}",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  controller.canResendOtp.value
                                      ? Colors.red
                                      : const Color(0xFF6B7280),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Obx(
                          () => TextButton(
                            onPressed:
                                controller.canResendOtp.value &&
                                        !controller
                                            .isLoading.value
                                    ? controller.resendOtp
                                    : null,
                            child: Text(
                              "Kirim Ulang OTP",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color:
                                    controller.canResendOtp.value
                                        ? const Color(0xFF3578E5)
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  controller.isLoading.value
                                      ? null
                                      : controller.verifyOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF3578E5),
                                disabledBackgroundColor:
                                    const Color(0xFF3578E5)
                                        .withOpacity(0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Verifikasi OTP",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      "Ubah alamat email",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}