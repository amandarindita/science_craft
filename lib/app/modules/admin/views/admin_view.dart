import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../admin_learning/controllers/admin_learning_controller.dart';
import '../../admin_learning/views/admin_learning_view.dart';

/// Kompatibilitas route admin lama.
///
/// Login dan Routes.ADMIN tidak perlu diubah. Saat route lama membuka
/// AdminView, aplikasi langsung menampilkan Panel Guru yang baru.
class AdminView extends StatefulWidget {
  const AdminView({
    super.key,
  });

  @override
  State<AdminView> createState() =>
      _AdminViewState();
}

class _AdminViewState
    extends State<AdminView> {
  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<
        AdminLearningController>()) {
      Get.put<AdminLearningController>(
        AdminLearningController(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const AdminLearningView();
  }
}
