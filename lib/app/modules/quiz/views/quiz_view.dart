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
          // LAPISAN 1: Header Biru Melengkung (Paling Belakang)
          ClipPath(
            clipper: WaveClipper(), // Gunakan WaveClipper yang sama
            child: Container(
              height: 200,
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
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Tampilkan halaman hasil jika kuis selesai
                    if (controller.isQuizFinished.value) {
                      return _buildResultView();
                    }
                    // Tampilkan kuis jika sedang berlangsung
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          .copyWith(top: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const Expanded(
            child: Text(
              "Quiz Materi",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Tampilan saat kuis sedang berlangsung
  Widget _buildQuizView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 20),
          _buildQuestionCard(),
          const SizedBox(height: 32),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Indikator progres soal (misal: "Soal 5 dari 25")
  Widget _buildProgressIndicator() {
    return Obx(() => Text(
          "Soal ${controller.currentQuestionIndex.value + 1} dari ${controller.questions.length}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ));
  }

  /// Kartu yang berisi pertanyaan dan opsi jawaban
  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 25,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Obx(() {
        final qIndex = controller.currentQuestionIndex.value;
        final question = controller.questions[qIndex];
        final selectedAnswer = controller.selectedAnswers[qIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pertanyaan
            Text(
              question.question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Opsi Jawaban
            ...List.generate(question.options.length, (optIndex) {
              return RadioListTile<int>(
                title: Text(question.options[optIndex]),
                value: optIndex,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectAnswer(qIndex, value);
                  }
                },
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF1E3A8A),
              );
            }),
          ],
        );
      }),
    );
  }

  /// Tombol Navigasi (Kembali, Lanjut, Selesai)
  Widget _buildNavigationButtons() {
    return Obx(() {
      final isFirstQuestion = controller.currentQuestionIndex.value == 0;
      final isLastQuestion = controller.currentQuestionIndex.value == controller.questions.length - 1;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Kembali
          if (!isFirstQuestion)
            TextButton(
              onPressed: controller.previousQuestion,
              child: const Text(
                "<  Kembali",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          else
            Container(), // Placeholder agar tombol lanjut tetap di kanan

          // Tombol Lanjut atau Selesai
          ElevatedButton(
            onPressed: isLastQuestion
                ? controller.finishQuiz // Tampilkan tombol Selesai di soal terakhir
                : controller.nextQuestion, // Tampilkan tombol Lanjut
            style: ElevatedButton.styleFrom(
              backgroundColor: isLastQuestion
                  ? const Color(0xFF1E3A8A) // Warna beda untuk Selesai
                  : const Color(0xFFFFD166),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              isLastQuestion ? 'Selesai!' : 'Lanjut  >',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLastQuestion ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Tampilan hasil setelah kuis selesai
  Widget _buildResultView() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 25,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Kuis Selesai!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Skor Anda:",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            Obx(() => Text(
                  "${controller.score.value.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                )),
            const SizedBox(height: 40),
            
            // Tombol Mulai Eksperimen (sesuai permintaan)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.startExperiment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD166),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Mulai Eksperimen!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Tombol kembali
            TextButton(
              onPressed: controller.backToMaterial,
              child: Text(
                'Kembali ke Materi',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Clipper (Salin dari file MaterialDetailView Anda)
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // Mulai dari bawah
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0); // Ke sudut kanan atas
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}