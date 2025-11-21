import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Menggunakan lazyPut agar controller hanya di-instance saat pertama kali dibutuhkan.
    // Ini lebih efisien dari segi memori.
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
  }
}
