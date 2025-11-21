import 'package:get/get.dart';

import '../controllers/materi_controller.dart';
class MaterialDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Mendaftarkan MaterialListController agar bisa digunakan oleh View-nya
    Get.lazyPut<MaterialDetailController>(
      () => MaterialDetailController(),
    );
  }
}

