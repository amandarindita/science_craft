import 'package:get/get.dart';

import '../controllers/edit_profile_learning_controller.dart';

class EditProfileLearningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileLearningController>(
      () => EditProfileLearningController(),
    );
  }
}
