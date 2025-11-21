import 'package:get/get.dart';

// Model sederhana untuk data pertanyaan kuis
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class QuizController extends GetxController {
  // --- STATE VARIABLES ---

  // Menandakan apakah data kuis sedang dimuat
  final isLoading = true.obs;

  // Menandakan apakah kuis telah selesai
  final isQuizFinished = false.obs;

  // Daftar total pertanyaan kuis
  final questions = <QuizQuestion>[].obs;

  // Indeks pertanyaan yang sedang ditampilkan
  final currentQuestionIndex = 0.obs;

  // Menyimpan jawaban yang dipilih pengguna (Map<questionIndex, optionIndex>)
  final selectedAnswers = <int, int?>{}.obs;

  // Skor akhir
  final score = 0.0.obs;

  // --- LIFECYCLE ---

  @override
  void onInit() {
    super.onInit();
    // Ambil materiId dari argumen jika diperlukan
    // final String materialId = Get.arguments as String;
    // loadQuizData(materialId);
    loadQuizData(); // Panggil fungsi untuk memuat data
  }

  // --- CORE METHODS ---

  /// Mensimulasikan pengambilan data 25 soal dari database/API
  Future<void> loadQuizData() async {
    isLoading(true);
    // Simulasi delay jaringan
    await Future.delayed(const Duration(seconds: 1));

    // Buat 25 soal dummy
    List<QuizQuestion> dummyQuestions = List.generate(25, (index) {
      return QuizQuestion(
        question: "Ini adalah pertanyaan nomor ${index + 1}. Apa jawaban yang benar?",
        options: [
          "Opsi A (Benar)",
          "Opsi B",
          "Opsi C",
          "Opsi D",
        ],
        correctAnswerIndex: 0, // Jawaban benar selalu A untuk demo ini
      );
    });

    questions.assignAll(dummyQuestions);
    // Inisialisasi map jawaban dengan null
    selectedAnswers.value = Map.fromIterables(
      List.generate(dummyQuestions.length, (i) => i),
      List.generate(dummyQuestions.length, (i) => null),
    );
    isLoading(false);
  }

  /// Dipanggil saat pengguna memilih jawaban
  void selectAnswer(int questionIndex, int optionIndex) {
    selectedAnswers[questionIndex] = optionIndex;
  }

  /// Pindah ke pertanyaan berikutnya
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  /// Kembali ke pertanyaan sebelumnya
  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  /// Dipanggil saat pengguna menekan tombol "Selesai"
  void finishQuiz() {
    int correctCount = 0;
    selectedAnswers.forEach((questionIndex, selectedOptionIndex) {
      if (selectedOptionIndex != null) {
        if (selectedOptionIndex == questions[questionIndex].correctAnswerIndex) {
          correctCount++;
        }
      }
    });

    // Hitung skor (jumlah benar / total soal) * 100
    score.value = (correctCount / questions.length) * 100;
    isQuizFinished(true); // Ubah state untuk menampilkan halaman hasil
  }

  /// Dipanggil dari halaman hasil untuk memulai eksperimen
  void startExperiment() {
    // Navigasi ke halaman eksperimen
    // Pastikan Anda punya route bernama '/experiment'
    Get.toNamed('/experiment'); 
    print("Memulai Eksperimen...");
  }

  /// Kembali ke halaman detail materi
  void backToMaterial() {
    Get.back();
  }
}