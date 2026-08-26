import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showLogoutConfirmation({
  required FutureOr<void> Function() onConfirm,
}) async {
  if (Get.isDialogOpen == true) {
    return;
  }

  final bool confirmed =
      await Get.dialog<bool>(
            AlertDialog(
              icon: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4E6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFDC2626),
                  size: 31,
                ),
              ),
              title: const Text(
                'Keluar dari akun?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: const Text(
                'Kamu perlu login kembali untuk menggunakan ScienceCraft.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
              actionsPadding:
                  const EdgeInsets.fromLTRB(
                18,
                0,
                18,
                18,
              ),
              actions: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            Get.back<bool>(
                          result: false,
                        ),
                        style:
                            OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            Get.back<bool>(
                          result: true,
                        ),
                        style:
                            FilledButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFDC2626,
                          ),
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                        ),
                        icon: const Icon(
                          Icons.logout_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Ya, Keluar',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            barrierDismissible: true,
          ) ??
          false;

  if (!confirmed) {
    return;
  }

  await onConfirm();
}
