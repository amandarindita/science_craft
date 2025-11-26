import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Wajib ada
import 'app/routes/app_pages.dart';
import 'app/data/db/database_helper.dart'; 
import 'app/data/auth_service.dart'; 

void main() async {
  // 1. Wajib: Pastikan binding Flutter siap sebelum akses storage/db
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 2. Init Penyimpanan Lokal (GetStorage)
  // Ini penting untuk menyimpan status 'hasSeenOnboarding' dan 'authToken'
  await GetStorage.init();

  // 3. Inject AuthService (Otak Login) agar siap dipakai di mana saja
  Get.put(AuthService()); 

  // 4. Init Database SQLite
  try {
    await DatabaseHelper.instance.database;
    print("✅ Database SQLite lokal siap.");
  } catch (e) {
    print("❌ DATABASE LOKAL GAGAL !!!");
    print("Error: $e");
  }

  // 5. Jalankan Aplikasi
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
        useMaterial3: true, // Desain modern
      ),
      
      // --- BAGIAN PENTING: LOGIKA PENENTU HALAMAN AWAL ---
      // Kita tidak langsung tulis Routes.LOGIN atau Routes.ONBOARDING
      // Tapi kita panggil fungsi pintar ini:
      initialRoute: _determineInitialRoute(),
      
      getPages: AppPages.routes,
    );
  }

  /// Fungsi pintar untuk menentukan user harus masuk ke mana
  String _determineInitialRoute() {
    final box = GetStorage();
    
    // 1. CEK LOGIN: Apakah user sudah login sebelumnya?
    // Jika ada token, berarti sudah login -> Langsung ke Dashboard (ROOT)
    if (box.hasData('authToken')) {
      return Routes.ROOT; 
    }

    // 2. CEK ONBOARDING: Apakah user sudah pernah melihat onboarding?
    // Variabel 'hasSeenOnboarding' ini disimpan di OnboardingController saat tombol 'Selesai/Lewati' ditekan.
    bool hasSeenOnboarding = box.read('hasSeenOnboarding') ?? false;
    
    if (hasSeenOnboarding) {
      // Jika sudah pernah lihat -> Langsung ke Login
      return Routes.LOGIN; 
    }

    // 3. KASUS BARU: Belum login & Belum pernah lihat onboarding
    // Ini pasti pengguna baru yang baru install -> Masuk Onboarding
    return Routes.ONBOARDING;
  }
}