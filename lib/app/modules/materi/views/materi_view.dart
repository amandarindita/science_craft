import 'package:flutter/material.dart';
import 'package:get/get.dart';
// --- 1. PASTIKAN IMPORT CONTROLLER BENAR ---
import '../controllers/materi_controller.dart';
// --- 2. IMPORT MODEL BARU ---
import '../../../models/material_model.dart';

class MaterialDetailView extends GetView<MaterialDetailController> {
  const MaterialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA), // Warna dasar abu-abu pattern
      body: Stack(
        children: [
          // LAPISAN 1: Header Biru Melengkung (Paling Belakang)
          ClipPath(
            clipper: WaveClipper(), // Clipper untuk bentuk melengkung
            child: Container(
              height: 200, // Tinggi area biru
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),

          // LAPISAN 2: Konten Utama
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Obx(() {
                    if (controller.materialContent.value == null) {
                      // Tampilkan loading di tengah area putih
                      return Container(
                         width: double.infinity,
                         margin: const EdgeInsets.only(top: 10),
                         decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                         ),
                         child: const Center(child: CircularProgressIndicator())
                      );
                    }
                    final content = controller.materialContent.value!;
                    return Container(
                      // Container ini untuk background pattern putih
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10), 
                      decoration: const BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/pattern.png'),
                          repeat: ImageRepeat.repeat,
                          scale: 5.0,
                          opacity: 0.05, // Opacity pattern
                        ),
                      ),
                      // --- 3. SAMBUNGKAN SCROLL CONTROLLER ---
                      child: SingleChildScrollView(
                        controller: controller.scrollController, // <-- INI DIA
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            _buildIntroductionCard(content.introduction),
                            const SizedBox(height: 24),
                            ...content.theorySections
                                .map((section) => _buildTheoryCard(section))
                                .toList(),
                            
                            // --- 4. KARTU KUIS DIHAPUS DARI SINI ---
                            
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
 Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(top: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => controller.saveAndReturn(),
          ),
          Expanded(
            child: Column( // Gunakan Column untuk menampilkan Judul & Progress
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.materialContent.value?.title ?? "Memuat...",
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    )),
                // --- TEKS DEBUG (HAPUS NANTI KALAU SUDAH FIX) ---
                Obx(() => Text(
                      "Progress: ${(controller.currentProgress.value * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(color: Colors.yellow, fontSize: 12),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (sisa kode _buildIntroductionCard dan _buildTheoryCard tetap sama)
  Widget _buildIntroductionCard(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEF), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD166).withOpacity(0.8), width: 2), 
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), 
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style:
            const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
      ),
    );
  }

  Widget _buildTheoryCard(TheorySection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 25,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                section.imagePath, 
                height: 80, 
                width: 80,
                fit: BoxFit.cover, 
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  section.content,
                  style: const TextStyle(
                      fontSize: 15, height: 1.5, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Contoh gampang:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          ...section.examples
              .map((example) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• ",
                            style:
                                TextStyle(fontSize: 15, color: Colors.black54)),
                        Expanded(
                            child: Text(example,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black54))),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // --- WIDGET KUIS DIHAPUS ---
  // Widget _buildQuizCard(QuizSection quiz) { ... }

  // --- 6. TOMBOL DIPERBARUI ---
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.goToQuiz(), // <-- PANGGIL FUNGSI BARU
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD166),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Lanjut ke Kuis!', // <-- UBAH TEKS TOMBOL
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => controller.saveAndReturn(),
          child: Text(
            'Simpan dan Kembali',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ... (WaveClipper tetap sama) ...
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); 
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0); 
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

