import 'package:get/get.dart';

import '../controllers/material_list_controller.dart';

class MaterialListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MaterialListController>(
      () => MaterialListController(),
    );
  }
}
