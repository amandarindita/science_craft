import 'package:get/get.dart';
import '../controllers/gacha_controller.dart';

class GachaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GachaController>(() => GachaController());
  }
}