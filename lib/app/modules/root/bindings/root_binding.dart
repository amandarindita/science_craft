import 'package:get/get.dart';
import '../controllers/root_controler.dart'; // Path yang benar (biasanya)

// Import semua controller untuk tab di Bottom Nav Bar kamu
import '../../dashboard/controllers/dashboard_controller.dart';
// --- PERBAIKAN DI SINI ---
import '../../materi/controllers/material_list_controller.dart'; 
import '../../profile/controllers/profile_controller.dart'; 

class RootBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RootController>(
      () => RootController(),
    );

    // --- DAFTARKAN SEMUA CONTROLLER TAB DI SINI ---
    
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
    
    // --- PERBAIKAN DI SINI ---
    Get.lazyPut<MaterialListController>( 
      () => MaterialListController(),
    );

    Get.put(ProfileController());
  }
}

