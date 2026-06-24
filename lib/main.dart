import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/routes/app_pages.dart';
import 'app/data/db/database_helper.dart'; 
import 'app/data/auth_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await GetStorage.init();

  Get.put(AuthService()); 

  try {
    await DatabaseHelper.instance.database;
    print("✅ Database SQLite lokal siap.");
  } catch (e) {
    print("❌ DATABASE LOKAL GAGAL !!!");
    print("Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Science Craft",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: _determineInitialRoute(),
      getPages: AppPages.routes,
    );
  }

  String _determineInitialRoute() {
    final box = GetStorage();
    
    if (box.hasData('authToken')) {
      // --- LOGIKA BARU: CEK PANGKAT PAS AUTO-LOGIN ---
      String role = box.read('userRole') ?? 'user';
      if (role == 'admin') {
        return Routes.ADMIN; 
      } else {
        return Routes.ROOT; 
      }
    }

    return Routes.ONBOARDING;
  }
}