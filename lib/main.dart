import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Untuk "dompet" penyimpan token
import 'app/routes/app_pages.dart';
import 'app/data/db/database_helper.dart'; 
import 'app/data/auth_service.dart'; // Import "otak" login kita

void main() async {
  // Pastikan semua widget Flutter siap
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 1. Inisialisasi "dompet" penyimpan data
  await GetStorage.init();

  // 2. "Nyalakan" AuthService agar siap dipakai
  Get.put(AuthService()); 

  // 3. Inisialisasi database SQLite lokal (ini sudah benar)
  try {
    await DatabaseHelper.instance.database;
    print("✅ Database SQLite lokal siap.");
  } catch (e) {
    print("❌ DATABASE LOKAL GAGAL !!!");
    print("Error: $e");
  }

  // Jalankan aplikasi
  runApp(
    GetMaterialApp(
      title: "Application",
      // Cek apakah user sudah login, jika ya, langsung ke ROOT
      initialRoute: Routes.LOGIN,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}

