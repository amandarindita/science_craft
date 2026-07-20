import 'package:get/get.dart';

import '../controllers/password_recovery_controller.dart';

class PasswordRecoveryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordRecoveryController>(
      () => PasswordRecoveryController(),
    );
  }
}