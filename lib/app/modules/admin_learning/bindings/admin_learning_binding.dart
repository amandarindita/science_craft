import 'package:get/get.dart';

import '../controllers/admin_learning_controller.dart';

class AdminLearningBinding
    extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminLearningController>(
      AdminLearningController.new,
    );
  }
}
