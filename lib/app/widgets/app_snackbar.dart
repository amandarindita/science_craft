import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSnackbar {
  /// Snackbar Peringatan / Validasi Form
  static void warning(String title, String message) {
    _showCustomSnackbar(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFF59E0B), // Amber hangat
      icon: Icons.warning_amber_rounded,
    );
  }

  /// Snackbar Kesalahan / Error Server
  static void error(String title, String message) {
    _showCustomSnackbar(
      title: title,
      message: message,
      backgroundColor: const Color(0xFFEF4444), // Crimson Red modern
      icon: Icons.error_outline_rounded,
    );
  }

  /// Snackbar Berhasil / Sukses
  static void success(String title, String message) {
    _showCustomSnackbar(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF10B981), // Emerald Green
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Snackbar Info / Notifikasi Umum
  static void info(String title, String message) {
    _showCustomSnackbar(
      title: title,
      message: message,
      backgroundColor: const Color(0xFF2563EB), // Science Blue
      icon: Icons.info_outline_rounded,
    );
  }

  static void _showCustomSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      '',
      '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 16,
      boxShadows: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      titleText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 33),
        child: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1.35,
          ),
        ),
      ),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCubic,
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
