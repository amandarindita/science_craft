import 'package:get/get.dart';
import '../controllers/lab_controller.dart';

class LabBinding extends Bindings {
  @override
  void dependencies() {
    // "lazyPut" artinya controller baru dibuat saat halaman dipakai
    Get.lazyPut<LabController>(
      () => LabController(),
    );
  }
}