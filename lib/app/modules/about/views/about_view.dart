import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/about_controller.dart';

class AboutAppView extends GetView<AboutAppController> {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A), // Latar belakang biru tua
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white, // Background putih
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/pattern.png'),
                    repeat: ImageRepeat.repeat,
                    scale: 5.0,
                    opacity: 0.05,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logo_app.png', // Ganti dengan path logo Anda
                          height: 120,
                          errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.science, size: 120, color: Color(0xFF1E3A8A)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Science Craft',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      Center(
                        child: Obx(() => Text(
                          'Versi ${controller.appVersion.value}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        )),
                      ),
                      const SizedBox(height: 30),
                      _buildSectionTitle('Tentang Aplikasi'),
                      const SizedBox(height: 12),
                      const Text(
                        'Science Craft adalah aplikasi edukasi interaktif yang dirancang untuk membuat pembelajaran sains (Fisika, Kimia, Biologi) menjadi lebih menyenangkan dan mudah dipahami. Melalui simulasi, materi yang ringkas, dan kuis yang menantang, kami berharap dapat menumbuhkan kecintaan siswa terhadap sains.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Dikembangkan Oleh'),
                      const SizedBox(height: 12),
                      const Text(
                        'Aplikasi ini dibuat dengan penuh semangat oleh [Nama Anda / Nama Tim Anda].\n\nTerima kasih telah menggunakan Science Craft!',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
    );
  }
}
