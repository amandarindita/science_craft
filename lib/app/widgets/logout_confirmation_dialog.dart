import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showLogoutConfirmation({
  required FutureOr<void> Function() onConfirm,
}) async {
  if (Get.isDialogOpen == true) {
    return;
  }

  final bool confirmed = await Get.dialog<bool>(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Icon Container with Soft Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFEE2E2),
                        border: Border.all(
                          color: const Color(0xFFFECACA),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  'Konfirmasi Keluar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'Apakah kamu yakin ingin keluar dari akun Science Craft? Sesi dan progres belajarmu tetap tersimpan aman di cloud.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),

                // Action Buttons
                Row(
                  children: <Widget>[
                    // Cancel Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back<bool>(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Confirm Logout Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.back<bool>(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 17,
                        ),
                        label: Text(
                          'Ya, Keluar',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: true,
      ) ??
      false;

  if (!confirmed) {
    return;
  }

  await onConfirm();
}
