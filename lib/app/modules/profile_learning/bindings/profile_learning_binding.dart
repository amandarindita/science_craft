import 'package:get/get.dart';
import '../controllers/profile_learning_controller.dart';

class ProfileLearningBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileLearningController>(
      () => ProfileLearningController(),
    );
  }
}