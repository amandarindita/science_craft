import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          // --- BACKGROUND BIRU (HEADER) ---
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 220, // Sedikit lebih tinggi biar lega
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                ),
              ),
            ),
          ),

          // --- KONTEN UTAMA ---
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(), // Tombol back & Judul
                Expanded(
                  child: Obx(() {
                    // 1. CEK LOADING
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // 2. CEK JIKA SOAL KOSONG (Admin belum isi)
                    if (controller.questions.isEmpty) {
                      return _buildEmptyState();
                    }

                    // 3. CEK JIKA KUIS SELESAI
                    if (controller.isQuizFinished.value) {
                      return _buildResultView();
                    }

                    // 4. TAMPILKAN SOAL
                    return _buildQuizView();
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Expanded(
            child: Text(
              "Kuis Materi",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 48), // Spacer penyeimbang tombol back
        ],
      ),
    );
  }

  // --- STATE 1: JIKA ADMIN BELUM ISI SOAL ---
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Soal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            const Text(
              "Admin belum menambahkan soal untuk materi ini.\nSilakan coba materi lain.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text("Kembali"),
            )
          ],
        ),
      ),
    );
  }

  // --- STATE 2: TAMPILAN KUIS BERLANGSUNG ---
  Widget _buildQuizView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Kartu Soal
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0,5))],
            ),
            child: Obx(() {
              final qIndex = controller.currentQuestionIndex.value;
              final question = controller.questions[qIndex];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Soal 1/10
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pertanyaan ${qIndex + 1}/${controller.questions.length}",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(10)),
                        child: const Text("Pilihan Ganda", style: TextStyle(fontSize: 10, color: Colors.deepOrange)),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Teks Soal
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Opsi Jawaban
                  ...List.generate(question.options.length, (optIndex) {
                    return Obx(() {
                      final isSelected = controller.selectedAnswers[qIndex] == optIndex;
                      return GestureDetector(
                        onTap: () => controller.selectAnswer(qIndex, optIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!,
                              width: isSelected ? 2 : 1
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30, height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  String.fromCharCode(65 + optIndex), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600]
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question.options[optIndex],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  }),
                ],
              );
            }),
          ),
          
          const SizedBox(height: 30),
          
          // Tombol Navigasi
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Obx(() {
      final isFirst = controller.currentQuestionIndex.value == 0;
      final isLast = controller.currentQuestionIndex.value == controller.questions.length - 1;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          if (!isFirst)
            TextButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text("Kembali"),
              onPressed: controller.previousQuestion,
            )
          else
            const SizedBox(width: 80), // Spacer

          // Tombol Lanjut / Selesai
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLast ? Colors.green : const Color(0xFFFFD166),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: isLast ? controller.finishQuiz : controller.nextQuestion,
            child: Row(
              children: [
                Text(isLast ? "Selesai" : "Lanjut"),
                const SizedBox(width: 8),
                Icon(isLast ? Icons.check_circle : Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ],
      );
    });
  }

  // --- STATE 3: HASIL KUIS ---
  Widget _buildResultView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar Piala
            Image.asset('assets/trophy.png', height: 120, errorBuilder: (c,o,s)=> const Icon(Icons.emoji_events, size: 100, color: Colors.amber)),
            const SizedBox(height: 24),
            
            const Text("Kuis Selesai!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
            const SizedBox(height: 10),
            
            Text("Skor Kamu:", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Obx(() => Text(
              "${controller.score.value.toInt()}",
              style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.orangeAccent),
            )),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.backToMaterial,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
                child: const Text("Kembali ke Materi"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WAVE CLIPPER (Desain Gelombang Biru Kamu) ---
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}