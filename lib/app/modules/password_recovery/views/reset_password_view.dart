import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/password_recovery_controller.dart';

class ResetPasswordView extends GetView<PasswordRecoveryController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      body: SafeArea(
        child: Stack(
          children: [
            // Background biru bagian atas
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  IconButton(
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Center(
                    child: Icon(
                      Icons.password_rounded,
                      size: 78,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      "Buat Password Baru",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      "Buat password baru yang kuat dan\nmudah kamu ingat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white70,
                      ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password Baru",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Obx(
                          () => TextField(
                            controller: controller.newPasswordController,
                            obscureText:
                                controller.obscureNewPassword.value,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: "Masukkan password baru",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: Color(0xFF3578E5),
                              ),
                              suffixIcon: IconButton(
                                onPressed:
                                    controller
                                        .toggleNewPasswordVisibility,
                                icon: Icon(
                                  controller.obscureNewPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3578E5),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Minimal 8 karakter.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Konfirmasi Password",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Obx(
                          () => TextField(
                            controller:
                                controller.confirmPasswordController,
                            obscureText:
                                controller
                                    .obscureConfirmPassword.value,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              controller.resetPassword();
                            },
                            decoration: InputDecoration(
                              hintText: "Ulangi password baru",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_reset_rounded,
                                color: Color(0xFF3578E5),
                              ),
                              suffixIcon: IconButton(
                                onPressed:
                                    controller
                                        .toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  controller
                                          .obscureConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF7F8FA),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF3578E5),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.resetPassword,
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
                                      "Simpan Password Baru",
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

                  Center(
                    child: TextButton(
                      onPressed: () => Get.offAllNamed('/login'),
                      child: const Text(
                        "Kembali ke halaman masuk",
                        style: TextStyle(
                          color: Color(0xFF3578E5),
                          fontWeight: FontWeight.w700,
                        ),
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