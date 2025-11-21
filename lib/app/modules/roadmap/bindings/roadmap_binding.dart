import 'package:get/get.dart';
import '../controllers/roadmap_controller.dart';

class LevelRoadmapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelRoadmapController>(
      () => LevelRoadmapController(),
    );
  }
}