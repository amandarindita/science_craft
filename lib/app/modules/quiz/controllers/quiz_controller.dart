import 'package:get/get.dart';
import '../../../data/db/database_helper.dart';

// Model sederhana (Boleh dipisah ke file model sendiri kalau mau rapi)
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
  // --- STATE ---
  final isLoading = true.obs;
  final isQuizFinished = false.obs;
  final questions = <QuizQuestion>[].obs;
  final currentQuestionIndex = 0.obs;
  final selectedAnswers = <int, int?>{}.obs; // Map<IndexSoal, IndexJawabanUser>
  final score = 0.0.obs;

  late int materialId;

  @override
void onInit() {
  super.onInit();
  
  // Ambil dari arguments, bukan parameters
  var arg = Get.arguments;
  
  if (arg != null) {
    // Jika materialId di detail adalah String, pakai int.parse
    // Jika sudah int, tinggal masukkan langsung
    materialId = (arg is int) ? arg : int.parse(arg.toString());
    loadQuizData();
  } else {
    print("Error: Tidak ada ID yang dikirim lewat arguments!");
    isLoading.value = false;
  }
}
  // --- LOAD DATA DARI SQLITE ---
  Future<void> loadQuizData() async {
    isLoading(true);
    try {
      // Panggil Database Helper
      final dbData = await DatabaseHelper.instance.getQuizzesByMaterial(materialId);

      if (dbData.isEmpty) {
        questions.clear(); // Kosongkan list
      } else {
        // Mapping dari Database (Map) ke Model (QuizQuestion)
        questions.assignAll(dbData.map((item) {
          return QuizQuestion(
            question: item['question'],
            options: [
              item['option_a'],
              item['option_b'],
              item['option_c'],
              item['option_d'],
            ],
            // Konversi "A" -> 0, "B" -> 1, dst.
            correctAnswerIndex: _parseAnswer(item['correct_answer']),
          );
        }).toList());

        // Siapkan slot jawaban kosong
        selectedAnswers.value = Map.fromIterables(
          List.generate(questions.length, (i) => i),
          List.generate(questions.length, (i) => null),
        );
      }
    } catch (e) {
      print("Error load quiz: $e");
    } finally {
      isLoading(false);
    }
  }

  // Helper konversi Huruf ke Angka
  int _parseAnswer(String letter) {
    switch (letter.toUpperCase()) {
      case 'A': return 0;
      case 'B': return 1;
      case 'C': return 2;
      case 'D': return 3;
      default: return 0;
    }
  }

  // --- LOGIKA GAMEPLAY ---
  
  void selectAnswer(int qIndex, int ansIndex) {
    selectedAnswers[qIndex] = ansIndex;
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
    }
  }

  void finishQuiz() {
    int correctCount = 0;
    selectedAnswers.forEach((qIndex, ansIndex) {
      if (ansIndex != null) {
        if (ansIndex == questions[qIndex].correctAnswerIndex) {
          correctCount++;
        }
      }
    });

    // Hitung Nilai (0 - 100)
    if (questions.isNotEmpty) {
      score.value = (correctCount / questions.length) * 100;
    } else {
      score.value = 0;
    }
    
    isQuizFinished(true);
  }

  void startExperiment() {
    // Pastikan route '/experiment' sudah ada di AppPages
    Get.toNamed('/experiment'); 
  }

  void backToMaterial() {
    Get.back(); // Tutup kuis
  }
}